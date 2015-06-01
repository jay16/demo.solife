#encoding: utf-8
module Utils
  module DataMapper
    module Model
      def self.included(base)
        base.send(:property, :delete_status, ::String, :default => "normal")
        base.send(:property, :ip,            ::String)
        base.send(:property, :browser,       ::DataMapper::Property::Text)
        base.send(:property, :created_at,    ::DateTime)
        base.send(:property, :created_on,    ::Date)
        base.send(:property, :updated_at,    ::DateTime)
        base.send(:property, :updated_on,    ::Date)
        base.send(:include, InstanceMethods)

        #class << base
        #  include ClassMethods
        #  [:all, :get, :first, :last].each do |method|
        #    send(:alias_method_chain, method, :print_sql)
        #  end
        #end
      end

      module InstanceMethods
        def _diff_(new, old)
          old.inject({}) do |_diff, array|
            key, _old = array
            _new = new.fetch(key)
            if ["updated_at"].include?(key) or _new == _old 
              _diff
            else
              puts "%s - %s: %s => %s" % [timestamp, key, _old, _new]
              _diff.merge!({ key => { "new" => _new, "old" => _old } })
            end
          end
        end
        def timestamp
          Time.now.strftime("%Y/%m/%d %H:%M:%S")
        end
        def _update_with_logger_(&block)
          old = to_params
          yield block
          new = to_params
          _diff = _diff_(new, old)
          if _diff.has_key?("delete_status")
            _action = "trash#%s" % delete_status
          end
          action_logger(self, _action || "update", _diff.to_s)
        end
        def soft_destroy
          update(delete_status: "soft")
        end
        def soft_destroy_with_logger
          _update_with_logger_ { soft_destroy }
        end
        def hard_destroy
          update(delete_status: "hard")
        end
        def hard_destroy_with_logger
          _update_with_logger_ { hard_destroy }
        end
        def update_with_logger(params)
          _update_with_logger_ { update(params) }
        end
        def delete?
          %w[soft hard].include?(delete_status)
        end
        def to_params
          self.class.properties.map(&:name)
            .reject(&:empty?)
            .inject({}) do |hash, property| 
              hash.merge!({ "%s" % property => self.send(property) })
            end
        end
        # 打印保存状态
        # TODO print Colorfully
        def save_with_logger
          _template = "\n\nModel - %s saved" % self.class.name
          status = true
          if self.save
            puts "%s successfully." % _template
          else
            puts "%s failed:" % _template
            self.errors.each_pair do |key, value|
              puts "%-15s => %s" % [key, value]
            end
            status = false
          end
          puts "\n\n"
          return status
        end
      end

      module ClassMethods
        # default methods to call delete status
        def normals
          all(delete_status: "normal")
        end
        def not_normals
          all(:delete_status.not => "normal")
        end
        def softs
          all(delete_status: "soft")
        end
        def hards
          all(delete_status: "hard")
        end
        
        # print query sql when call methods below.
        #
        # example:
        #   users = User.all
        #   => 
        #   User Load (0ms) ELECT "id", "name", "email" FROM "users"
        #   
        [:all, :get, :first, :last].each do |method|
          with_method, without_method = 
            "%s_with_print_sql" % method.to_s,
            "%s_without_print_sql" % method.to_s
          if method_defined?(method)
            warn "%s - already defiend!" % method
          else
            define_method with_method do |options|
              _t = Time.now.to_f
              # ==== important point!
              #
              #   self.send(without_mothod) 
              #   not 
              #   self.send(method)
              #
              _collection = self.send(without_method, options)
              _sql = ::DataMapper.repository.adapter
                .send(:select_statement,_collection.query).join(" ")
              puts "%s Load (%dms) %s" % [self.name, ((Time.now.to_f - _t)*1000).to_i, _sql]
              return _collection
            end
          end
        end
      end
    end
  end
end
