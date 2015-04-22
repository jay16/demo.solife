#encoding: utf-8
module Utils
  class SqlAround
    class << self
      def parse_insert_with_values sql = ""
        transfer = {} 
        # 处理两种情况: 连续单引号/单引号括住的内容(包含单引号)
        [/'{2,}/, /'.*?'/].each do |regexp|
          sql.scan(regexp).uniq.sort.reverse.each do |quota|
            sql.gsub! quota do
              transfer[quota] = "!__!%d!__!" % transfer.size
            end
          end
        end

        # 分解sql
        scan = sql.scan(/\((.*?)\)/)
        insert, _values = *scan.first(2).map(&:first)
          .map { |line| line.split(/,/).map(&:strip) }
        values = _values.map { |v| transfer.key(v) }

        return [insert, values]
      end
    end
  end
end
