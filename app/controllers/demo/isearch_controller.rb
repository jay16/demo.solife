#encoding: utf-8 
class Demo::ISearchController < Demo::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/demo"
  set :layout, :"layouts/layout"

  before do
    @structure = [{
      :path => "/",
      :type => "dir",
      :datas => [
        {
        :path => "一级目录1",
        :type => "dir",
        :datas => [
          { :path => "二级目录1.1",
            :type => "dir",
            :datas => [ 
              { :path => "三级文件1.1.1", :type => "file" },
              { :path => "三级文件1.1.2", :type => "file" },
              { :path => "三级文件1.1.3", :type => "file" },
              { :path => "三级文件1.1.4", :type => "file" }
            ]
          },
          { :path => "二级目录1.2",
            :type => "dir",
            :datas => [ 
              { :path => "三级文件1.2.1", :type => "file" },         
              { :path => "三级文件1.2.2", :type => "file" },
              { :path => "三级文件1.2.3", :type => "file" },
              { :path => "三级文件1.2.4", :type => "file" }
            ]
          },
          { :path => "二级目录1.3",
            :type => "dir",
            :datas => [ 
              { :path => "三级文件1.3.1", :type => "file" },
              { :path => "三级文件1.3.2", :type => "file" },
              { :path => "三级文件1.3.3", :type => "file" },
              { :path => "三级文件1.3.4", :type => "file" }
            ]
          }
        ]
      },
      {
      :path => "一级目录2",
      :type => "dir",
      :datas => [
        { :path => "二级目录2.1",
          :type => "dir",
          :datas => [ 
            { :path => "三级文件2.1.1", :type => "file" },
            { :path => "三级文件2.1.2", :type => "file" }
          ]
        },
        { :path => "二级目录2.2",
          :type => "dir",
          :datas => [ 
            { :path => "三级文件2.2.1", :type => "file" },
            { :path => "三级文件2.2.2", :type => "file" },
            { :path => "三级文件2.2.3", :type => "file" }
          ]
        },
        { :path => "二级目录1.3",
          :type => "dir",
          :datas => [ 
            { :path => "三级文件1.3.1", :type => "file" },
            { :path => "三级文件1.3.2", :type => "file" },
            { :path => "三级文件1.3.3", :type => "file" },
            { :path => "三级文件1.3.4", :type => "file" }
          ]
        }
      ]
      },
      {
        :path => "一级文件3",
        :type => "file",
      }
      ]
    }]
  end
  # get /demo/isearch
  get "/" do
    @structure = JSON.pretty_generate(@structure[0])
    haml :index, layout: settings.layout
  end
  template :index do
    "%pre= @structure"
  end

  # get /demo/isearch/api
  get "/api" do
    paths = (params[:path] || "/").split("/").map { |i| i.empty? ? nil : i }.compact.unshift("/")
    current, _structure = 0, Marshal.load(Marshal.dump(@structure))
    begin
      while current < paths.length
        structure = _structure.find { |hash| hash[:path] == paths[current] }
        _structure = structure[:datas]
        current += 1
      end
    rescue => e
      structure = e.message
    end
    hash = simple(structure)

    respond_with_json hash, 200
  end

  route :get, :post, "/login" do
    username = params[:user] || ""
    password = params[:password] || ""
    error = []
    error << "user name is incorrect" unless username.eql?("root") 
    error << "password is incorrect" unless password.eql?("admin")

    if error.empty?
      info = "login successfully."
      code = 1
    else
      info = "login fails for: %s." % error.join(", ")
      code = -1
    end

    hash = { code: code, info: info }
    respond_with_json hash, 200
  end

  private 

  def simple(hash)
    hash[:datas].each do |h|
      h.delete(:datas) if h.has_key?(:datas)
    end if hash.has_key?(:datas)
    return hash
  end
end
