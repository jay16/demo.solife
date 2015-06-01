class Transaction
    include DataMapper::Resource

    property :id, Serial 
    property :gmt_send_goods, String
    property :discount, String
    property :logistics_type, String
    property :receive_zip, String
    property :payment_type, String
    property :subject, String
    property :logistics_fee, String
    property :trade_no, String
    property :buyer_email, String
    property :gmt_create, String
    property :notify_type, String
    property :quantity, String
    property :logistics_payment, String
    property :out_trade_no, String
    property :seller_id, String
    property :notify_time, String
    property :trade_status, String
    property :is_total_fee_adjust, String
    property :gmt_payment, String
    property :total_fee, String
    property :seller_email, String
    property :gmt_close, String
    property :price, String
    property :buyer_id, String
    property :receive_mobile, String
    property :gmt_logistics_modify, String
    property :notify_id, String
    property :receive_name, String
    property :use_coupon, String
    property :sign_type, String
    property :sign, String
    property :receive_address, String
    property :created_at, DateTime
    property :updated_at, DateTime
end
