
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

    until ['r','f','s','c'].include?(input)
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
