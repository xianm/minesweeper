#!/usr/bin/env ruby

require 'yaml'
require_relative 'board'

class Game
  MOVE_ACTIONS = ["r", "f"]
  GAME_ACTIONS = ["quit", "q", "save", "s"]
  
  def initialize(board = Board.new)
    @board = board
    @time_elapsed = 0.0
  end
  
  def play
    last_time = Time.new
    
    until game_over?
      draw_board
      player_action = get_input
      return if handle_action(player_action)
      @time_elapsed += Time.new - last_time
      last_time = Time.new
    end

    show_board
    draw_board

    puts "You won in #{@time_elapsed.round(2)} seconds!" if won?
    puts "You lost in #{@time_elapsed.round(2)} seconds!" if lost?
  end
  
  def handle_action(player_action)
    action = player_action[:action]
    data = player_action[:data]

    if action == "quit" || action == "q"
      return true
    elsif action == "save" || action == "s"
      save_game(data)
    elsif action == "r"
      @board.reveal!(data)
    else
      @board[data].toggle_flag!
    end
    
    false
  end
  
  def get_input
    begin
      puts "Input F or R for flag or reveal followed by coordinates."
      print "> "
      response = STDIN.gets.chomp.downcase.split
      action = response[0]
      data = nil
      
      # early termination
      if GAME_ACTIONS.include?(action)
        data = true
        data = response[1] if action == "s" || action == "save" 
      elsif MOVE_ACTIONS.include?(action)
        data = [Integer(response[2]) - 1, Integer(response[1]) - 1]
        raise ArgumentError unless @board.valid_pos?(data)
      else
        raise ArgumentError
      end

      { action: action, data: data }
    rescue
      puts "Invalid input. Example: 'F 4 2'"
      retry
    end
  end
  
  def show_board
    @board.grid.flatten.each { |tile| tile.revealed = true }
  end
  
  def draw_board
    print "   |  "
    @board.size.times do |i|
      print "#{i + 1}  "
    end
    
    puts "\n-------------------------------"
    
    i = 0
    @board.grid.each do |row|
      print " #{i + 1} | "
      row.each do |tile|
        print "#{tile.display_char}  "
      end
      puts ""
      i += 1
    end
  end
  
  def game_over?
    won? || lost?
  end
  
  def won?
    safe_tiles = []
    bomb_tiles = []
    
    @board.grid.flatten.each do |tile|
      bomb_tiles << tile if tile.is_bomb?
      safe_tiles << tile unless tile.is_bomb?
    end
    
    bomb_tiles.none? { |tile| tile.exploded? } &&
      safe_tiles.all? { |tile| tile.revealed? }
  end
  
  def lost?
    @board.grid.flatten.any?(&:exploded?)
  end
  
  def save_game(file)
    print "Saving game to #{file}..."
    
    File.open(file, "w") do |file|
      file << self.to_yaml
    end
    
    puts "done!"
  end
  
  def self.load_game(file)
    puts "Loading game from #{file}..."    
    YAML::load_file(file)
  end
end

if __FILE__ == $PROGRAM_NAME
  game = Game.new

  unless ARGV.empty?
    game = Game.load_game(ARGV[0])
  end

  game.play
end
