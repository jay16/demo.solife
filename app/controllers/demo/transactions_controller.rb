#encoding: utf-8 
class Demo::TransactionsController < Demo::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/demo/transactions"

  # /alipay
  get "/" do
    @transactions = Transaction.all
    haml :index, layout: :"../layouts/layout"
  end


  # post /alipay/checkout
  post "/checkout" do
    options = {
      :partner           => Settings.alipay.pid,
      :key               => Settings.alipay.secret,
      :seller_email      => Settings.alipay.seller_email,
      :description       => 'Lovely description',
      :out_trade_no      => Time.now.to_i.to_s,
      :subject           => "支付宝demo@" + Time.now.strftime("%Y-%m-%d %H:%M"),
      :price             => params[:price],
      :quantity          => params[:quantity],
      :discount          => '0.00',
      :return_url        => Settings.alipay.return_url,
      :notify_url        => Settings.alipay.notify_url
    }
    redirect AlipayDualfun.trade_create_by_buyer_url(options)
  end

  # post /alipay/transactions/notify
  post "/transactions/notify" do
    find_or_create_transaction!

    haml :notify
  end

  # get /alipay/transactions/done
  get "/transactions/done" do
    find_or_create_transaction!

    flash[:success] = "付款成功啦!"
    redirect "/alipay"#, :notice => "done"
  end

  # show
  # get /alipay/transactions/:out_trade_no
  get "/transactions/:out_trade_no" do
    @transaction = Transaction.first(:out_trade_no => params[:out_trade_no])
    haml :modal
  end

  def find_or_create_transaction!
    transaction = Transaction.all(:out_trade_no => params[:out_trade_no]).first
    if params[:trade_status] == 'TRADE_FINISHED' && transaction.nil?
      params.merge({ created_at: DateTime.now, updated_at: DateTime.now })
      Transaction.create(params)
    end
  end

  not_found do
    "sorry"
    #haml :not_fount
  end
end
