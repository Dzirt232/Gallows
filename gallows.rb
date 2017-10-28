require "yaml"

class Game

  class Player
    attr_accessor :name, :attempts, :word, :guessed_letters, :wrong_letters

    def initialize(name, word)
      @name = name == "" ? "Player" : name
      @attempts = 9
      @word = word.split("")
      @guessed_letters = []
      @wrong_letters = []
    end

    def show_result
      puts
      @word.each { |letter|
        if @guessed_letters.include?(letter)
          print " #{letter} "
        else
          print " _ "
        end
      }
      puts
    end

    def xod
      self.show_result
      print "\nYour wrong letters: #{@wrong_letters.join(", ")}" if @wrong_letters.length != 0
      print "\nYour attempts: #{@attempts}. Enter your letter:\n"
      letter = gets.chomp.strip.downcase
      if @word.include?(letter)
        @guessed_letters.push(letter)
        puts "You guess the letter!"
      else
        puts "Sorry, you are wrong..."
        @wrong_letters.push(letter)
        @attempts -= 1
      end
      puts "Press enter to continue or 'save' to save your game"
      Game.save_game if gets.chomp.strip.downcase == "save"
    end

    def win?
      @word.all? { |letter| @guessed_letters.include?(letter) }
    end

  def game_over?
    if self.win?
      puts "Player #{@name} win!!! Your result: #{@attempts}"
      true
    elsif @attempts == 0
      puts "Player #{@name}, you loser..."
      true
    else
      false
    end
  end
end

  def self.take_word
    words = File.readlines("dictionary.txt")
    word = ""
    until word.length > 5 && word.length < 12 do
      word = words.sample.chomp.downcase
    end
    word
  end

  def self.otvet?
    loop do
      otvet = gets.chomp.strip.downcase
      if otvet == "y"
        return true
      elsif otvet == "n"
        return false
      else
        puts "I don't understand you, puts 'Y' or 'N' again."
      end
    end
  end

  def self.load_game
    saves = {}
    saved_games = Dir.entries("saves")[2..-1]
    saved_games.each_with_index {|save,index|
      puts "#{index}: #{save}"
      saves[index] = save
    }

    while true do
      puts "Choice save game: "
      number = gets.chomp.strip.to_i
      if saves.has_key?(number)
        save_name = saves[number]
        puts save_name
        break
      else
        puts "Right again"
      end
    end
    puts save_name
    file = File.new("saves/#{save_name}")
    yaml = file.read
    file.close
    @player = YAML::load(yaml)
  end

  def self.save_game
    puts "Enter the file name"
    file_name = gets.chomp.strip
    if Dir.entries("saves").include?("#{file_name}.txt")
      puts "Want you rewrite this game? (Y/N)"
      if !otvet?
        number_same_saves = 0
        Dir.entries("saves").each {|name_file|
          number_same_saves += 1 if name_file.match(/#{file_name}/)
        }
        file_name = "#{file_name}_#{number_same_saves}"
      end
    end
    file = File.new("saves/#{file_name}.txt", "w")
    file.puts YAML::dump(@player)
    file.close
  end

  def self.start
    puts "Want you load old game? (Y/N)"
    load_game if otvet?
    print "Welcome to gallows!!!\nOn each word you get 9 attempts.\n"
    puts "Enter save, when you wish save your game."
    puts "Enter your name: "
    @player ||= Player.new(gets.chomp.strip,take_word)
    loop do
      @player.xod
      break if @player.game_over?
    end
  end
end

Game.start
