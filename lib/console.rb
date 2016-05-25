require_relative "codebreaker.rb"

module Codebreaker
  class GameConsole
    def initialize
      @game = Game.new
    end

    def play
      loop do
        choice = menu
        break if choice == '0'
        case choice
        when '1'
          play_game
          save
        when '2'
          show_table
        end
      end
    end

private
    def show_table
      puts Game.load_results
    end

    def play_game      
      @game.start
      while (@game.num_of_try <= @game.count_of_try && !@game.game_status)
        puts 'Input 4 digits between 1 and 6 (q for quit or h for hint):'
        user_input = gets.chomp
        if user_input == 's'
          @game.instance_variable_set(:@secret_code, gets.chomp.chars.map(&:to_i))
          next
        end
        break if user_input == 'q'
        puts (user_input == 'h' ? @game.hint : @game.match_secret_code(user_input))
      end
    end

    def save
      puts 'Do you want to save results(y/n)?'
      if (gets.chomp == 'y')
        puts 'Input your name:'
        @game.save_result(gets.chomp)
      end
    end

    def menu
      choice = nil
      begin
        puts '1: Play codebreaker'
        puts '2: Show table of score'
        puts '0: Exit'
        choice = gets.chomp
        puts 'Invalid value (input digit between 0 fnd 2)' unless choice[/[0-2]/]
      end until choice
      choice
    end
  end
end