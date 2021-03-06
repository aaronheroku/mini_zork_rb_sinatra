require "./lib/room"
require "json"

class GameMap
  attr_accessor :rooms, :valid_directions, :goal

  def initialize(input)
    @valid_directions = [:north, :south, :east, :west ]
    @rooms = {}
    @game_map_data = JSON.parse(input, symbolize_names: true)

    #setup the map, which is a hash of Room objects
    @game_map_data[:rooms].each do |room|
      exit_array = []
      @game_map_data[:exits].each do |exit|
        if exit[:from_room] == room[:color]
          exit_array << Room::Exit.new(
            exit[:from_room].downcase.to_sym, 
            exit[:from_direction].downcase.to_sym, 
            exit[:to_room].downcase.to_sym, 
            exit[:to_direction].downcase.to_sym )
        end
      end
      @rooms[room[:color].to_sym] = Room.new(
        room[:color], 
        room[:adjective], 
        exit_array, 
        description: room[:description],
        gems: room[:gems] )
    end

    # check the rooms hash for any two-way corridors. 
    # This prints a message if it finds one, but currently 
    # leaves it up to the user to modify map_config.json
    @rooms.each_key do |from_room|
      @rooms[from_room].exits.each do |from_exit|
        @rooms[from_exit.to_room].exits.each do |to_exit|
          if two_way_corridor?(from_exit, to_exit)
            puts "map_config.json warning: There is a two-way corridor between #{from_exit.from_room} and #{from_exit.to_room}"
          end
        end
      end
    end
  end

  def two_way_corridor?(first_exit, second_exit)
    opposite_exit = Room::Exit.new(
      first_exit.to_room, 
      first_exit.to_direction, 
      first_exit.from_room, 
      first_exit.from_direction )
    second_exit == opposite_exit
  end

  def set_goal(goal)
    if @rooms[goal].nil?
      puts "ERROR! invalid goal set in map_config.json!"
    else
      @goal = goal
      @rooms[goal].switch_flag(:goal)
    end
  end

  def randomize_goal
    @rooms.each_value {|room| room.flags[:goal] = false}
    set_goal(@rooms.keys.sample)
  end

  def random_gems(chance)
    @rooms.each_value do |room|
      if rand(chance) == 0
        room.gems += 1
        room.flags[:loot] = true
      end
    end
  end

  def reset_gems
    @game_map_data[:rooms].each do |r|
      @rooms[r[:color].to_sym].gems = r[:gems]
    end
  end
end
