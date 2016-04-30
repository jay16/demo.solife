# encoding: utf-8
# 台球联赛
class Demo::MoneyBallController < Demo::ApplicationController
  set :views, File.join(ENV['VIEW_PATH'], 'demo/money_ball')
  set :layout, :"../../layouts/layout"
  helpers Demo::MoneyBallHelper

  before do
    @page_header = '乐课力台球联赛'
    @current_stage = '积分赛'
    @current_season_human = '16春'
    @current_season = '16-mar'
    set_seo_meta(@page_header, "八球，2016春季，赛事", "八球，2016春季，赛事，乐课力")
  end

  # Get /money_ball
  get '/' do
    rank_json_path = mb_json_path('rank')
    cache_with_custom_defined([File.mtime(rank_json_path)])
    @results = json_parse(File.read(rank_json_path))

    haml :index, layout: settings.layout
  end

  # Get /money_ball/matches
  get '/matches' do
    matches_json_path = mb_json_path('matches')
    cache_with_custom_defined([File.mtime(matches_json_path)])
    @matches = json_parse(File.read(matches_json_path))

    haml :matches, layout: settings.layout
  end

  get '/new' do
    @players = json_parse(File.read(mb_json_path('players')))
    @matches = json_parse(File.read(mb_json_path('matches')))
    @match = { players: @matches.sample(2), scores: [0, 0], stage: '初赛' }

    haml :new, layout: settings.layout
  end

  get '/edits' do
    matches_json_path = mb_json_path('matches')
    @matches = json_parse(File.read(matches_json_path))

    haml :edits, layout: settings.layout
  end
 
  post '/' do
    players = [params[:player0], params[:player1]]
    scores = [params[:score0], params[:score1]].map(&:to_i)
    if scores[0] < scores[1]
      players = players.reverse
      scores = scores.reverse
    end
    id = md5("#{Time.now.to_f}#{params}")
    matches = json_parse(File.read(mb_json_path('matches')))
    match = { id: id, players: players, scores: scores, stage: params[:stage], date: Time.now.strftime('%m/%d %H:%M') }
    matches.push(match)

    File.open(mb_json_path('matches'), "w:utf-8") { |file| file.puts(matches.to_json) }
    rank_matches

    MoneyBallWorker.perform_async('add')

    redirect to('/')
  end

  get '/:id/edit' do
    @match = json_parse(File.read(mb_json_path('matches')))
      .map(&:deep_symbolize_keys!)
      .bsearch { |h| h[:id] == params[:id] }
    @players = json_parse(File.read(mb_json_path('players')))

    haml :edit, layout: settings.layout
  end

  post '/:id' do    
    matches = json_parse(File.read(mb_json_path('matches')))
      .map(&:deep_symbolize_keys!)
    index = matches.bsearch_index { |h| h[:id] == params[:id] }
    match = matches[index]
    match[:players] = [params[:player0], params[:player1]]
    match[:scores] = [params[:score0], params[:score1]].map(&:to_i)
    match[:stage] = params[:stage]
    matches[index] = match
    File.open(mb_json_path('matches'), "w:utf-8") { |file| file.puts(matches.to_json) }
    rank_matches

    MoneyBallWorker.perform_async('update')

    redirect to('edits')
  end

  private

  def mb_json_path(filename)
    app_root_join("config/money_ball/#{@current_season}/#{filename}.json")
  end

  def rank_matches
    results = Hash.new(0)
    no_match_players = json_parse(File.read(mb_json_path('players'))).map { |p| p['name'] }
    json_parse(File.read(mb_json_path('matches'))).each do |match|
      if match['scores'][0] > match['scores'][1]
        results[match['players'][0]] += 1
        results[match['players'][1]] += 0
      else
        results[match['players'][0]] += 0
        results[match['players'][1]] += 1
      end

      no_match_players -= match['players']
    end

    no_match_players.each do |player|
      results[player] = -1
    end

    players = json_parse(File.read(mb_json_path('players')))
    matches = json_parse(File.read(mb_json_path('matches')))
    hash_result = results.map { |k, v|
      player = players.select { |h| h['name'] == k }[0]
      count = matches.select { |m| m['players'].include?(k) }.count
      [k, v, count, player['company'], player['gender']] 
    }.group_by { |a| a[1] }

    rank_result = hash_result.map do |k, v|
      [k.to_i, v]
    end

    result = []
    rank_index = 1
    rank_result.sort_by { |a| a[0] }.reverse_each do |a|
      a[1].each do |play_result|
        result.push(play_result.unshift(a[0] == -1 ? '-' : rank_index))
      end

      rank_index += 1 if a[0] > -1
    end

    json_path = mb_json_path('rank')
    File.open(json_path, "w:utf-8") { |file| file.puts(result.to_json) }
  end
end
