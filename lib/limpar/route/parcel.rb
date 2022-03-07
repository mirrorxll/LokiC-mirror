# frozen_string_literal: true

module Limpar
  module Route
    module Parcel

      API = '/api/v1'

      ### Athletic_Association ###

      def collect_athletic_association(params)
        get("#{API}/athletic_associations", params)
      end

      def create_athletic_association(name = {})
        post("#{API}/athletic_associations", name)
      end

      def get_athletic_association(name)
        get("#{API}/athletic_associations", name)
      end

      def update_athletic_association(id, name = {})
        put("#{API}/athletic_associations/#{id}", name)
      end

      def delete_athletic_association(id)
        delete("#{API}/athletic_associations/#{id}")
      end
      ############################

      ### Athletic_Conference ###

      def collect_athletic_сonference
        get("#{API}/athletic_conferences")
      end

      def create_athletic_сonference(body = {})
        post("#{API}/athletic_conferences", body) ##Limpar::Client.new.create_athletic_сonference({"athletic_association_id": "string", "abbreviation": "string", "name": "string"})
      end

      def get_athletic_сonference(id)
        get("#{API}/athletic_conferences/#{id}")
      end

      def update_athletic_сonference(id, body = {})
        put("#{API}/athletic_conferences/#{id}", body) ##Limpar::Client.new.update_athletic_сonference({""abbreviation": "string", "name": "string"})
      end

      def delete_athletic_сonference(id)
        delete("#{API}/athletic_conferences/#{id}")
      end
      ######################

      ### Athletic_Level ###
      def collect_athletic_level
        get("#{API}/athletic_levels")
      end

      def create_athletic_level(name = {})
        post("#{API}/athletic_levels", name)
      end

      def get_athletic_level(id)
        get("#{API}/athletic_levels/#{id}")
      end

      def update_athletic_level(id, name = {})
        put("#{API}/athletic_levels/#{id}", name)
      end

      def update_athletic_level(id, name = {})
        put("#{API}/athletic_levels/#{id}", name)
      end

      def delete_athletic_level(id)
        delete("#{API}/athletic_levels/#{id}")
      end
      ######################

      ### Athletic_Roster ###

      def collect_athletic_roster
        get("#{API}/athletic_rosters")
      end

      def create_athletic_roster(body = {})
        post("#{API}/athletic_rostes", body) ##Limpar::Client.new.create_athletic_roster({"team_id": "string", "name": "string", "athletic_season_id": "string", "athlete_class": "string", "feet": "string", "first_name": "string", "high_school": "string", "hometown": "string", "inches": "string", "jersey_number": "string", "last_name": "string", "position": "string", "redshirt": "string", "weight": "string"})
      end

      def get_athletic_roster(id)
        get("#{API}/athletic_rosters/#{id}")
      end

      def update_athletic_roster(id, body = {})
        put("#{API}/athletic_rosters/#{id}", body) ##Limpar::Client.new.update_athletic_roster({"team_id": "string", "name": "string", "athletic_season_id": "string", "athlete_class": "string", "feet": "string", "first_name": "string", "high_school": "string", "hometown": "string", "inches": "string", "jersey_number": "string", "last_name": "string", "position": "string", "redshirt": "string", "weight": "string"})
      end

      def delete_athletic_roster(id)
        put("#{API}/athletic_rosters/#{id}")
      end
      #####################

      ## Athletic_Season ##

      def collect_athletic_seasons
        get("#{API}/athletic_seasons")
      end

      def create_athletic_season(body = {})
        post("#{API}/athletic_seasons", body)  ##Limpar::Client.new.create_athletic_season({"season_end": 0, "season_start": 0})
      end

      def get_athletic_season(id)
        get("#{API}/athletic_seasons/#{id}")
      end

      def update_athletic_season(id, body = {}) ##Limpar::Client.new.update_athletic_season({"season_end": 0, "season_start": 0})
        put("#{API}/athletic_seasons/#{id}", body)
      end

      def delete_athletic_season(id)
        delete("#{API}/athletic_seasons/#{id}")
      end
      #####################

      ### AthleticSport ###

      def collect_athletic_sports
        get("#{API}/athletic_sports")
      end

      def create_athletic_sports(body = {})
        post("#{API}/athletic_seasons", body)  ##Limpar::Client.new.create_athletic_sports({"additional_fields": [{"name": "string"}], "final_score_field": "string", "name": "string"})
      end

      def get_athletic_sports(id)
        get("#{API}/athletic_seasons/#{id}")
      end

      def update_athletic_sports(id, body = {}) ##Limpar::Client.new.update_athletic_sports({"additional_fields": [{"name": "string"}], "final_score_field": "string", "name": "string"})
        put("#{API}/athletic_seasons/#{id}", body)
      end

      def delete_athletic_sports(id)
        delete("#{API}/athletic_seasons/#{id}")
      end
      #####################

      ### BOX_SCORES ###

      def get_collection_box_score
        get("#{API}/box_scores")
      end

      def create_box_score(body = {})
        post("#{API}/box_scores", body) ##Limpar::Client.new.create_box_score({athletic_roster_id: '2c481d3e-5ad8-426b-974a-5c452b66bf6a', statistic_id: '75c2f424-e4fd-4a79-a916-fd89b274bfb1', game_id: '57184c25-835c-4b8d-b347-46dbd85bbeae', value: 0})
      end

      def get_box_score(id)
        get("#{API}/box_scores/#{id}") ##Limpar::Client.new.get_box_score('a3030275-7fa6-4c43-844a-616d7406eadd')
      end

      def update_box_score(id, body = {})
        put("#{API}/box_scores/#{id}", body) ####Limpar::Client.new.update_box_score('a3030275-7fa6-4c43-844a-616d7406eadd', {value: 0})
      end

      def delete_box_score(id)
        delete("#{API}/box_scores/#{id}")
      end
      #############################

      #### Game_Match ######

      def get_collection_game_match
        get("#{API}/game_matches")
      end

      def create_game_match(body = {})
        post("#{API}/game_matches", body) ##Limpar::Client.new.create_game_match({"game_id": "129babd7-0a5a-4108-81e4-77c8f2b49aed","sport_match_id": "920ff8a2-f7e4-499e-a9cc-41be969bebda", "away_team_points": 0, "home_team_points": 0})
      end

      def get_game_match(id)
        get("#{API}/game_matches/#{id}")
      end

      def update_game_match(id, body = {})
        put("#{API}/game_matches/#{id}", body) ##Limpar::Client.new.update_game_match({away_team_points": 0, "home_team_points": 0})
      end

      def delete_game_match(id)
        delete("#{API}/game_matches/#{id}")
      end
      #########################

      ## Game ##

      def get_collection_games
        get("#{API}/games")
      end

      def create_game(body = {})
        post("#{API}/games", body) ##Limpar::Client.new.create_game({"athletic_season_id": "a0a46a8f-63fc-443b-bbb5-36a1d2a2e6d4","home_team_id": "e50d3428-8c9d-4dec-8edd-a34182365d86", "away_team_id": "aaa4d0cf-1aff-466c-bba4-dfe4a3e9d33c", "date_time": "2019-08-24T14:15:22Z", "home": true, "venue": "string"})
      end

      def get_game(id)
        get("#{API}/games/#{id}")
      end

      def update_game(id, body = {})
        put("#{API}/games/#{id}", body) ##Limpar::Client.new.create_game({"date_time": "2019-08-24T14:15:22Z", "home": true, "venue": "string"})
      end

      def delete_game(id)
        delete("#{API}/games/#{id}")
      end
      #######################

      #### Sport_Match

      def get_collection_sports_match
        get("#{API}/sport_matches")
      end

      def create_sport_match(body = {})
        post("#{API}/sport_matches", body) ##Limpar::Client.new.create_sport_match({"athletic_sport_id": "f87bfac6-c981-4ebb-bbfc-05c7aaa78b54", "match": "string"})
      end

      def get_sport_match(id)
        get("#{API}/sport_matches/#{id}")
      end

      def update_sport_match(id, body = {})
        put("#{API}/sport_matches/#{id}", body) ##Limpar::Client.new.update_sport_match({match": "string"})
      end

      def delete_sport_match(id)
        delete("#{API}/sport_matches/#{id}")
      end
      ########################

      ##### Statistic ########

      def get_collection_statistic
        get("#{API}/statistics")
      end

      def create_statistic(body = {})
        post("#{API}/statistics", body) ##Limpar::Client.new.create_statistic({ "abbreviation": "string", "description": "string" })
      end

      def get_statistic(id)
        get("#{API}/statistics/#{id}")
      end

      def update_statistic(id, body = {})
        put("#{API}/statistics/#{id}", body) ##Limpar::Client.new.update_statistic({"abbreviation": "string", "description": "string"})
      end

      def delete_statistic(id)
        delete("#{API}/statistics/#{id}")
      end
      #########################

      ####### API_TEAMS #######

      def collect_team
        get("#{API}/teams")
      end

      def create_team(body = {})
        post("#{API}/teams", body)
      end

      def get_teams_id(id)
        get("#{API}/teams/#{id}")
      end

      def update_teams(id, body = {})
        put("#{API}/teams/#{id}", body)
      end

      def delete_team(id)
        delete("#{API}/teams/#{id}")
      end
    end
  end
end
