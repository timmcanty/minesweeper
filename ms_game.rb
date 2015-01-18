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
