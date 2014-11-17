class Game
end

class Board

  def initialize( size = 9, bombs = 10)
    @bombs = bombs
    @board = generate_board(size)
    place_bombs(@board)
  end

  protected



  private

  def generate_board(size)
    board = Array.new(size) { Array.new(size)}

    board.each_index do |row|
      board.each_index do |col|
        board[row][col] = Tile.new(self)
        p board[row][col].class
      end
    end

  end

  def place_bombs(board)
    bombs_left = @bombs

    until bombs_left == 0
      row = rand(board.count)
      col = rand(board.count)

      unless board[row][col].is_bomb
        #p board[row][col].class
        board[row][col].make_bomb
        set_neighbor_bomb_counts( row, col)
        bombs_left -= 1
      end
    end

    board
  end

  def set_neighbor_bomb_counts (row, col)
    deltas = [-1,0,1].product([-1,0,1]) - [[0,0]]

    neighbors = deltas.map {|delta| [row + delta[0], col + delta[1]]}

    neighbors = neighbors.reject do |neighbor|
      neighbor.any? {|coord| !coord.between?(0, @board.size-1)}
    end

    neighbors.each {|neighbor| self[neighbor].increase_bomb_count }

    nil
  end

  def [] (pos)
    @board[pos[0]][pos[1]]
  end

end


class Tile

  attr_reader :is_bomb,  :bomb_count

  def initialize(board, initial_state = :hidden)
    @board = board
    @state = initial_state
    @is_bomb = false
    @bomb_count = 0
  end


  def make_bomb
    @is_bomb = true
  end

  def increase_bomb_count
    @bomb_count += 1
  end


end

class Player
end
