require 'colorize'

class Tile
  OFFSETS = [-1, 0, 1].product([-1, 0, 1]) - [[0, 0]]
  DISPLAYS = { 
    0 => "0", 
    1 => "1".blue, 
    2 => "2".blue, 
    3 => "3".blue,
    4 => "4".blue, 
    5 => "5".blue, 
    6 => "6".blue, 
    7 => "7".blue, 
    8 => "8".blue,
    :bomb => "#".red,
    :flag => "F".green,
    :hidden => "*",
    :explosion => "X".on_red
  }
  
  attr_accessor :revealed
  
  def initialize(board, pos)
    @revealed = false
    @flagged = false
    @bombed = false
    @board = board
    @pos = pos
    @explode = false
  end
  
  def display_char
    display = :hidden
    display = neighbor_bomb_count if revealed? && !is_bomb?
    display = :flag if flagged?
    display = :bomb if revealed? && is_bomb?
    display = :explosion if exploded?
  
    DISPLAYS[display]
  end
  
  def plant_bomb!
    @bombed = true
  end
  
  def reveal!
    return if flagged?
    @revealed = true
    @exploded = true if is_bomb?

    return if neighbor_bomb_count > 0
    
    neighbors.each do |tile|
      tile.reveal! unless tile.is_bomb? || tile.revealed?
    end
  end
  
  def toggle_flag!
    @flagged = !@flagged unless revealed?
  end
  
  def is_bomb?
    @bombed
  end
  
  def exploded?
    @exploded && revealed?
  end
  
  def flagged?
    @flagged
  end
  
  def revealed?
    @revealed
  end
  
  def neighbors
    @neighbors ||= [].tap do |neighbors|
      OFFSETS.each do |offset|
        dpos = [@pos[0] + offset[0], @pos[1] + offset[1]]
        neighbors << @board[dpos] if @board.valid_pos?(dpos)
      end
    end
  end
  
  def neighbor_bomb_count
    @count ||= neighbors.count { |tile| tile.is_bomb? }
  end  
end
