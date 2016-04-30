# encoding: utf-8
class MoneyBallWorker
  include Sidekiq::Worker

  def perform(action)
    `cd #{ENV['APP_ROOT_PATH']} && git commit -a -m '#{action} match' && git push origin master`
  end
end