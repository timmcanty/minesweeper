class Game
end

class Board

  def initialize( size = 9, bombs = 10)
    @bombs = bombs
    @board = generate_board(size)

  end

  protected



  private

  def generate_board(size)
    board = Array.new(size) { Array.new(size)}

    board.each_index do |row|
      board.each_index do |col|
        board[row][col] = Tile.new(self)
      end
    end

    place_bombs(board)

  end

  def place_bombs(board)
    bombs_left = @bombs

    until bombs_left == 0
      row = rand(board.count)
      col = rand(board.count)

      unless board[row][col].is_bomb
        board[row][col].make_bomb
        bombs_left -= 1
      end
    end

    board
  end




end

class Tile

  attr_reader :is_bomb

  def initialize(board, initial_state = :hidden)
    @board = board
    @state = initial_state
    @is_bomb = false
  end

  def make_bomb
    @is_bomb = true
  end

end

class Player
end
