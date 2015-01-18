class Tile

  attr_reader :is_bomb,  :bomb_count, :state

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

  def reveal
    @state = :revealed
  end

  def flag
    case @state
    when :flagged
      @state = :hidden
    when :hidden
      @state = :flagged
    end

    nil
  end


end
