# encoding: utf-8
class MoneyBallWorker
  include Sidekiq::Worker

  def perform()
    `cd #{ENV['APP_ROOT_PATH']} && git commit -a -m 'add match: #{match}' && git push origin master &`
  end
end