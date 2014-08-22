require_relative 'tile'

class Board
  attr_reader :size, :grid
  
  def initialize(size = 9, bomb_num = 12)
    @size = size
    @grid = Array.new(size) { |x| Array.new(size) { |y| Tile.new(self, [x, y]) } }
    populate_bombs(bomb_num)
  end
  
  def populate_bombs(bomb_num)
    all_pos = (0...size).to_a.product((0...size).to_a)
    all_pos.sample(bomb_num).each do |pos|
      self[pos].plant_bomb!
    end
  end
  
  def reveal!(pos)
    self[pos].reveal!
  end
  
  def valid_pos?(pos)
    pos[0].between?(0, size - 1) && pos[1].between?(0, size - 1)
  end
  
  def [](pos)
    @grid[pos[0]][pos[1]]
  end
  
  def []=(pos, value)
    @grid[pos[0]][pos[1]] = value
  end
end
