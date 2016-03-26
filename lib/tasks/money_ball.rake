# encoding: utf-8
require 'json'

desc "乐课力台球八球赛事."
namespace :money_ball do
  def random_match_result(stage)
    result = case stage
             when '初赛'
               [[2, 0], [2, 1]]
             when '1/4决赛'
               [[3, 0], [3, 1], [3, 2]]
             when '1/2决赛'
               [[5, 0], [5, 1], [5, 2], [5, 3], [5, 4]]
             when '总决赛'
               [[5, 0], [5, 1], [5, 2], [5, 3], [5, 4]]
    end.sample
    
    result.reverse! if Random.rand(100) % 2  == 0

    result
  end

  def init_players_score    
    player_path = File.join(ENV['APP_ROOT_PATH'], 'app/views/demo/money_ball/2016-spring/players.json')
    players = JSON.parse(IO.read(player_path))
    players = players.map { |h| { h['name'] => -1 } }
    File.open(player_path, "w:utf-8") { |f| f.puts(players.to_json) }
  end

  def generate_match(stage)
    player_path = File.join(ENV['APP_ROOT_PATH'], 'app/views/demo/money_ball/2016-spring/players.json')
    match_path = File.join(ENV['APP_ROOT_PATH'], 'app/views/demo/money_ball/2016-spring/matches.json')
    players = JSON.parse(IO.read(player_path))
    matches = JSON.parse(IO.read(match_path))
    players = players.sort { |h| h['score'] }
    num = case stage
          when '初赛'
            players.length
          when '1/4决赛'
            players.length / 2
          when '1/2决赛'
            players.length / 4
          when '总决赛'
            2
        end
    players = players.first(num)

    # 初赛
    caculate_scores = Hash.new(0)
    players.each do |h|
      caculate_scores[h['name']] = h['score']
    end

    i = 0
    while i < players.length-1
      j = i + 1

      while j < players.length
        match = {
          players: [players[i]['name'], players[j]['name']],
          scores: random_match_result(stage),
          date: Time.now.strftime("%Y-%m-%d %H:%M"),
          stage: stage
        }
        puts match.to_json

        caculate_scores[match[:players][0]] += match[:scores][0]
        caculate_scores[match[:players][1]] += match[:scores][1]

        matches.push(match)
        j += 1
      end
      i += 1
    end

    File.open(match_path, "w:utf-8") { |f| f.puts(matches.to_json) }
    players = JSON.parse(IO.read(player_path))
    caculate_scores.each do |k, v|
      puts [k, v].to_json
      index = players.find_index { |h| h['name'] == k }
      puts index
      puts players[index]
      players[index]['score'] = v 
    end
    players = players.sort { |h| h['score'] }
    File.open(player_path, "w:utf-8") { |f| f.puts(players.to_json) }
  end

  desc "生成模拟数据"
  task seeds: :environment do
    init_players_score
    #generate_match('初赛')
    # generate_match('1/4决赛')
    # generate_match('1/2决赛')
    # generate_match('总决赛')
  end
end
