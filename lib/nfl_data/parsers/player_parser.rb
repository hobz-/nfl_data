require 'nokogiri'

module NflData
  class PlayerParser

    def initialize
      @url = "http://www.nfl.com/players/search?category=position&conferenceAbbr=null&playerType=current&conference=ALL&filter="
    end

    def get_by_position(position)
      baseurl = @url + position
      url = baseurl
      returnVal = []
      page_num = 1

      count = 100

      loop do
        page_num += 1
        players_found = update_or_create_players(url)
        returnVal.push(players_found[1])
        break if players_found[0] == 0
        url = baseurl + '&d-447263-p='
        url += page_num.to_s
      end

      returnVal.flatten
    end

    def update_or_create_players(url)
      # puts "Pulling from url = #{url}"
      doc = open(url) { |f| Nokogiri(f) }
      if doc.nil?
        return 0
      end

      #NFL.com stores players in 2 types of rows. Class = Odd or Even. This pulls them all.
      odds = doc.search("tr.odd")
      evens = doc.search("tr.even")

      all = odds + evens

      players = all.map do |p|
        player = Player.new
        elements = p.search("td")
        player.position = elements[0].inner_text.strip
        player.number = elements[1].inner_text.strip
        player.name = elements[2].inner_text.strip
        player.status = elements[3].inner_text.strip
        player.team = elements[12].inner_text.strip

        #Get NFL.com Unique player id
        player.nfl_player_id = elements[2].to_s.split('/')[3]

        names = player.name.split(',')

        player.first_name = names[1].strip
        player.last_name = names[0].strip

        player.full_name = [player.first_name, player.last_name].join(' ')
        player
      end

      [players.count, players]
    end

  end
end