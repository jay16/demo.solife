# [名片转家](http://carder.solife.us)

## 启动服务

````
bundle install
bundle exec thin start
````


## 功能说明 

### models

  1. 每个model通用属性、实例方法、类方法放在/lib/utils/data_mapper/model.rb
  2. action_logger在/lib/utils/action_logger.rb定义
  3. 利用DataMapp的[hooks](!http://datamapper.org/docs/callbacks.html)调用action_logger

  ps: action_logger与model间的关联(需关联到user)/实例方法(需要logger的model都要有human_name方法)等，修改model时记得查看是否被action_logger绊到了。

### TODO

  [x]. WeixinRobot添加处理消息类型#video/music...
  []. WeixinRobot Xml自定义类处理，替换字符串处理.
  [x]. ReplyRobot各消息类型处理.

	
## 坑汇总
### 技术相关

  1. jquery#bootstrapValidator

    input[type=submit]的name不可以设置为name => [name conflict](!http://bootstrapvalidator.com/getting-started/#name-conflict)

  2. DataMapper#自动更新字段

    [dm-timestamps](!http://datamapper.org/docs/dm_more/timestamps.html)

    ````
      property :created_at, DateTime
      property :created_on, Date
      property :updated_at, DateTime
      property :updated_on, Date
    ````

  3. DataMapper#保存失败

    Gemfile

    ````
      gem "dm-validations", "~>1.2.0"
    ````

    model

    ````
      require "dm-validations"
    ````

    controller

    ````
      Order.raise_on_save_failure = false
      order = current_user.orders.new(order_params)
      if not order.save
        puts "Failed to save order: %s" % order.errors.inspect
      end
    ````

  4. DataObjects::IntegrityError# column track_id not unique

    只针对colun#track_id, 不知道它在DataMapper中扮演什么角色，但这个字段属性unique?是false,但创建时报上述错误。

    原来的model设置逻辑:

    ````
    class Track
      has n, :records
    end
    class Record
      belongs_to :track, :required => false
    end

    track = Track.first(id: id)
    # error line
    track.records.create(record_params)

    # debug lines
    record = track.records.first
    record.class.properties.map do |property|
      [property.name, property.unique?].join("=>")
    end
    .join("<br>")
    ````

    现在直接把Model名称换了(track_id自然也变了)，同样的关联逻辑，运行正常！

  5. inject的使用

    算不上坑,算是用法要点易忽视, 坑人的用法:

    ````
      hash.inject({}) do |sum, _hash|
        next if _hash[0] == "updated_at" # 坑
        sum.merge!({ _hash.first => _hash.last })
      end
    ````

    inject每次循环的返回值赋值给sum，使用next相当于把sum置为nil，next后的循环中就会报错nil没有方法merge!

    正确的用法:

    ````
      hash.inject({}) do |sum, _hash|
        if _hash[0] == "updated_at" # 不知道有没有更优雅的方法
          return sum
        else
          sum.merge!({ _hash.first => _hash.last })
        end
      end
      # 优雅点的用法？
      hash.grep(...).inject({}) do |sum, _hash|
          sum.merge!({ _hash.first => _hash.last })
      end
      # 但如果平行对比的话, 好像就优雅不起来了
      # one, two hash结构一致
      one.inject({}) do |diff, array|
        key, _one = array
        _two = two.fetch(key)
        if _one == _two
          return diff
        else
          sum.merge!({ key => { "one" => _one, "two" => _two }})
        end
      end
    ````

## 更新日志

1. 2014/11/09

  1. Sinatra::ReplyRobot

2. 2014/11/12

  1. assets#files可以使用cdn#qiniu, ENV["ASSET_CDN"] = "true"
  2. assets#sass files移入assets/sass
    
    修改coffee/sass文件后记得编译、上传至qiniu

    ````
      bundle exec rake cs2js:compile
      bundle exec rake cdn:qiniu
    ````

  3. git

    ````
      git rm --cached remove_file_from_cached
      git reset --hard HEAD
    ````
3. 2014/11/14

