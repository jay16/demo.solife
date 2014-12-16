module ModuleMethods
  def self.included(base)
    base.class_eval do
      if method_defined?(:alias_method_chain)
        location = self.method(:alias_method_chain).source_location
        warn "Remove Method - alias_method_chain defiend in:\n%s\nand reload file in %s" % [location, __FILE__]
        remove_method :alias_method_chain
      end
    end
  end

  def alias_method_chain(target, feature, &block)
    #Backports.alias_method_chain(self, target, feature, &block)
    aliased_target, punctuation = target.to_s.sub(/([?!=])$/, ""), $1

    _args = [aliased_target, feature, punctuation].map(&:to_s)
    with_method, without_method = "%s_with_%s%s" % _args, "%s_without_%s%s" % _args
    
    raise "NoMethod defined - %s" % with_method unless method_defined?(with_method)
    
    alias_method without_method, target
    alias_method target, with_method

    case
    when public_method_defined?(without_method) then public target
    when protected_method_defined?(without_method) then protected target
    when private_method_defined?(without_method) then private target
    else puts "WARNING: Ghost Method - %s" % without_method
    end
  end
end
class Module
  include ModuleMethods
end
