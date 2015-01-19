#encoding: utf-8
@app_routes_map = {
  "/"                 => "HomeController",
  "/users"            => "UsersController",
  "/weixin"           => "WeixinController",
  "/account"          => "Account::HomeController",
  "/account/users"    => "Account::UsersController",
  "/account/weixiners"=> "Account::WeixinersController",
  "/account/messages" => "Account::MessagesController",
  "/cpanel"           => "Cpanel::HomeController",
  "/cpanel/users"     => "Cpanel::UsersController",
  "/cpanel/weixiners" => "Cpanel::WeixinersController",
  "/cpanel/messages"  => "Cpanel::MessagesController"
}

require "./config/boot.rb"

@app_routes_map.each_pair do |path, mod|
  clazz = mod.split("::").inject(Object) {|o,c| o.const_get c}
  map(path) { run clazz }
end
