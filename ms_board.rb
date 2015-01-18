class Board

  attr_reader :bombs, :size, :start_time
  def initialize( size = 9, bombs = 10)
    @size = size
    @bombs = bombs
    @board = generate_board(size)
    place_bombs(@board)
    @start_time = Time.now
  end

  def process_command(command)
    if command[0] == :f
      toggle_flag(command[1])
    elsif command[0] == :r
      reveal_tile(command[1])
    else
      flag_click(command[1])
    end
  end

  def tiles
    @board.flatten
  end

  def won? #can flatten this
    tiles.all? do |tile|
      tile.is_bomb ? tile.state == :flagged : tile.state == :revealed
    end
  end

  def lost? #can flatten this with method tiles (flattens)
    tiles.any? do |tile|
      tile.is_bomb && tile.state == :revealed
    end
  end


  def reveal_tile(pos)
    return if self[pos].state == :flagged || self[pos].state == :revealed
    self[pos].reveal

    if self[pos].bomb_count == 0
      neighbors(pos).each { |coord| reveal_tile(coord)}
    end

    nil
  end

  def flag_click(pos)
    return if [:flagged,:hidden].include?(self[pos].state)
    adj_flags =   neighbors(pos).select { |neighbor| self[neighbor].state == :flagged}.size
    if adj_flags == self[pos].bomb_count
      neighbors(pos).select { |neighbor| self[neighbor].state == :hidden}.each do |neighbor|
        self.reveal_tile(neighbor)
      end
    end
  end

  def toggle_flag(pos)
    self[pos].flag
    nil
  end

  def render
    print "# |"
    @board.size.times {|i| print "#{i+1}|"}
    puts
    print "--+"
    @board.size.times { print '-+'}
    puts
    @board.each_with_index do |row, index|
      print "#{index+1} |"
      row.each do |tile|
        char = char_to_render(tile)
        print char
        print '|'
      end
      puts
      print "--+"
      @board.size.times { print '-+'}
      puts
    end

    nil
  end

  def char_to_render(tile)
    case tile.state
    when :hidden
       ' '.on_black
    when :flagged
      '⚑'.colorize(:red)
    when :revealed
      if tile.is_bomb
        '⚛'
      elsif tile.bomb_count == 0
       ' '
      else
        "#{color_case(tile.bomb_count)}"
      end
    end
  end

  def color_case(number)
    case number
    when 1
      number.to_s.colorize(:light_blue)
    when 2
      number.to_s.colorize(:green)
    when 3
      number.to_s.colorize(:light_red)
    when 4
      number.to_s.colorize(:blue)
    when 5
      number.to_s.colorize(:light_black)
    when 6
      number.to_s.colorize(:light_cyan)
    when 7
      number.to_s.colorize(:magenta)
    when 8
      number.to_s.colorize(:cyan)
    end
  end


  protected



  private

  def generate_board(size)
    board = Array.new(size) { Array.new(size) { Tile.new(self)} }
  end

  def place_bombs(board)
    bombs_left = @bombs

    until bombs_left == 0
      row = rand(board.count)
      col = rand(board.count)
      pos = [row,col]

      unless self[pos].is_bomb
        self[pos].make_bomb
        set_neighbor_bomb_counts(pos)
        bombs_left -= 1
      end
    end

    board
  end

  def set_neighbor_bomb_counts (pos)

    neighbors(pos).each {|neighbor| self[neighbor].increase_bomb_count }

    nil
  end

  def [] (pos)
    @board[pos[0]][pos[1]]
  end

  def neighbors(pos)
    deltas = [-1,0,1].product([-1,0,1]) - [[0,0]]

    pot_neighbors = deltas.map {|delta| [pos[0] + delta[0], pos[1] + delta[1]]}

    neighbors = pot_neighbors.reject do |neighbor|
      neighbor.any? {|coord| !coord.between?(0, @board.size-1)}
    end
  end
end
