# encoding: utf-8
require 'json'

desc "乐课力台球八球赛事."
namespace :mb do

  def current_season
    "16-mar"
  end

  def app_root_join(path)
    File.join(Dir.pwd, path)
  end

  # [
  #   {
  #     "name": "albert",
  #     "company": "intfocus",
  #     "gender": "male"
  #   }
  # ]
  def parse_players
    json_path = app_root_join("config/money_ball/#{current_season}/players.json")
    JSON.parse(File.read(json_path))
  end

  # [
  #   {
  #     "players": [
  #       "arthur",
  #       "jay"
  #     ],
  #     "scores": [
  #       "3",
  #       "2"
  #     ],
  #     "stage": "积分赛",
  #     "date": "2016/03/28 12:50"
  #   }
  # ]
  def parse_matches
    json_path = app_root_join("config/money_ball/#{current_season}/matches.json")
    JSON.parse(File.read(json_path))
  end

  desc '根据比赛成绩，生成排名'
  task :rank do
    results = Hash.new(0)
    no_match_players = parse_players.map { |p| p['name'] }
    parse_matches.each do |match|
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

    players = parse_players
    matches = parse_matches
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

    json_path = app_root_join("config/money_ball/#{current_season}/rank.json")
    File.open(json_path, "w:utf-8") { |file| file.puts(result.to_json) }
  end

  desc '添加比赛结果'
  task :add do
    if ENV['MATCH'].nil? || ENV['MATCH'].split(",").length != 6
      puts %(bundle exec rake mb:add MATCH='player0, score0, player1, score1, stage, date')
      exit
    end

    player0, score0, player1, score1, stage, date = ENV['MATCH'].split(",").map(&:strip)

    not_found_players = [player0, player1] - parse_players.map { |p| p['name'] }
    unless not_found_players.empty?
      puts "#{not_found_players.join(',')} not found in players.json"
      exit
    end

    players = [player0, player1]
    scores = [score0, score1]
    if score0 < score1
      players = players.reverse
      scores = scores.reverse
    end
    matches = parse_matches.push(players: players, scores: scores, stage: stage, date: date)

    json_path = app_root_join("config/money_ball/#{current_season}/matches.json")
    File.open(json_path, "w:utf-8") { |file| file.puts(matches.to_json) }
    puts "now already done #{matches.length} matches."
  end

end
