class Game
end

class Board

  def initialize( size = 9, bombs = 10)
    @board = generate_board(size)
    @bombs = bombs
  end

  private

  def generate_board(size)
    board = Array.new(size) { Array.new(size)}

    

    # bombs variable that goes down
    # generate random indices
    # place bombs
  end



end

class Tile
end

class Player
end
