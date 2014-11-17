class Game
  require 'yaml'
  require 'colorize'


  def Game.load_game(file_name)
    board = YAML.load(File.read( file_name) )
    Game.new( size: board.size, bombs: board.bombs, board: board)
  end


  def initialize(options = {})
    defaults = {size: 9,
                bombs: 10,
                board: nil}

    options = defaults.merge(options)
    @size = options[:size]
    @bombs = options[:bombs]
    if options[:board]
      @board = options[:board]
    else
      @board = Board.new( @size, @bombs)
    end
    @player = Player.new
  end

  def run

    until over?
      @board.render
      command = @player.get_command(@size)   # [command_type, pos]
      if command == :s
        save
        break
      end
      puts
      @board.process_command(command)
    end

    @board.render

    if @board.won?
      @time_elapsed = Time.now - @board.start_time
      puts "Congratulations, you cleared the minefield in #{@time_elapsed.to_i}s!"
      high_score(@time_elapsed) if (@board.bombs == 10 && @size == 9)
    elsif @board.lost?
      puts "You exploded"
    else
      puts "Game saved! "
    end

  end

  def high_score(time_elapsed)
    if File.exists?('high_scores.txt')
      current_high_scores =  YAML.load(File.read('high_scores.txt')).sort
    else
      current_high_scores = []
    end

    if current_high_scores.size == 10 && time_elapsed > current_high_scores.last[0]
      puts "Not Good enough"
    else
      puts "New high score! Input your name."
      name = gets.chomp
      current_high_scores << [time_elapsed, name]
      current_high_scores = current_high_scores.sort.take(10)
    end

    print_scores(current_high_scores)
    f = File.open('high_scores.txt', 'w')
    f.puts current_high_scores.to_yaml
    f.close
  end

  def print_scores(high_scores)
    high_scores.each_with_index do |score,index|
      place = (index+1).to_s.ljust(2)
      name = score[1][0...15].ljust(15)
      time = score[0].to_i.to_s.rjust(9)

      puts "#{place}: #{name} | #{time}s"
    end
  end

  def over?
    @board.won? || @board.lost?
  end

  def save
    saved_game = @board.to_yaml
    puts "Enter file name"
    file_name = gets.chomp
    f = File.open(file_name, 'w')
    f.puts saved_game
    f.close
  end
end

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
    else
      reveal_tile(command[1])
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

class Player

  def get_command(size) # [command_type, pos]  (command_type is :r or :f)
    puts "Enter a command ( r - reveal, f - flag, s - save)"
    command_type = command
    return command_type if command_type == :s
    puts "Enter a position ( 1,1 is the top left corner)"
    given_position = position(size)

    [command_type, given_position]
  end

  def command
    input = gets.chomp

    until (input == 'r') || ( input == 'f') || (input == 's')
      puts "Invalid Command! ( r - reveal, f - flag, s - save)"
      input = gets.chomp
    end

    input.to_sym
  end

  def position(size)
    input = gets.chomp.split(",")

    until input.all? { |coord| coord.to_i.between?(1, size)}
      puts "Invalid position! (1 - #{size})"
      input = gets.chomp.split(',')
    end

    input.map {|el| el.to_i-1}
  end

end
