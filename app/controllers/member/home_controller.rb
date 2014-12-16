#encoding: utf-8 
class Carder::HomeController < Carder::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/carder/home"

  before do
    authenticate!
  end

  # get /carder
  get "/" do
    @cards_my  = current_user.cards
    @cards_wait = Card.all(:is_over => false)
    @cards_with_vcf = Card.all(:intsig.not => nil)

    haml :index, layout: :"../layouts/layout"
  end

  # get /carder/workspace
  get "/workspace" do
    @cards = Card.all(:is_over => false)
    @card  = @cards.first

    haml :workspace, layout: :"../layouts/layout"
  end
end
