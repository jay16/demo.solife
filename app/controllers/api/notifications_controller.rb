# encoding: utf-8
class API::NotificationController < API::ApplicationController

  # root page
  get '/:user_name/list' do
    notifications = notifications_list(params[:user_name])
    timestamp = Time.now.strftime("%y%m%d%H")
    notification = notifications[timestamp.to_sym]

    respond_with_json notification
  end

  get '/:user_name' do
    notifications = notifications_list(params[:user_name])
    
    respond_with_json notifications
  end

  post '/:user_name/read/:notification_type' do
    notifications = notifications_list(params[:user_name])
    notifications_readed(params[:user_name], params[:notification_type])

    respond_with_json(notifications, 201)
  end

  def notifications_readed(user_name, notification_type)
    timestamp = Time.now.strftime("%y%m%d%H")
    notifications = notifications_list(user_name)

    notifications[timestamp.to_sym][notification_type.to_sym] = 0
    notifications[:actions].push(timestamp: Time.now.to_s, notification_type: notification_type)

    notifications_write(user_name, notifications)
  end

  def notifications_list(user_name)
    filepath = notifications_filepath(user_name)
    timestamp = Time.now.strftime("%y%m%d%H")

    if File.exist?(filepath)
      notifications = JSON.parse(IO.read(filepath))
    else
      notifications = {
        user_name: user_name,
        timestamp: timestamp,
        actions: [], 
        filepath: filepath
      }
    end

    notifications[timestamp.to_sym] = {
      app: rand(1000) % 12,
      tab_kpi: rand(1000) % 12,
      tab_analyse: rand(1000) % 12,
      tab_app: rand(1000) % 12,
      tab_message: rand(1000) % 12,
      setting: rand(1000) % 12
    }

    notifications_write(user_name, notifications) unless File.exist?(filepath)

    notifications.deep_symbolize_keys!
  end

  def notifications_write(user_name, notifications)
    File.open(notifications_filepath(user_name), 'w:utf-8') do |file|
      file.puts(notifications.to_json)
    end
  end

  def notifications_filepath(user_name)
    app_root_join("tmp/#{user_name}.json")
  end
end
