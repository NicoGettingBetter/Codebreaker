require_relative "codebreaker/version"
require 'psych'

module Codebreaker
  class Game
    attr_reader :is_hint_used, :num_of_try, :count_of_try, :game_status

    def initialize
      @secret_code = nil
      @count_of_try = nil
      @game_status = nil
      @num_of_try = nil
      @game_status = nil
    end

    def start
      @secret_code = (1..4).map { rand(1..6) }
      @num_of_try = 0
      @count_of_try = rand(10..20)
      @is_hint_used = false
      @game_status = nil
    end

    def match_secret_code user_code
      return 'Game Over' if @game_status == 'lose'
      return 'You win!' if @game_status == 'win'
      return 'Wrong format (input 4 digit without spaces). Try again' unless is_right_code? user_code
      user_code = user_code.chars.map(&:to_i)
      @num_of_try += 1
      if user_code == @secret_code
        @game_status = "win"
        return "++++ You win!!!" 
      end
      res = match_codes user_code
      if @num_of_try == @count_of_try
        @game_status = "lose"
        res += ' Game Over'
      end
      res
    end

    def hint
      unless (@is_hint_used) 
        @is_hint_used = true
        return @secret_code.sample
      end
      'hint already used'
    end

    def save_result(name)
      res = {
        user_name: name,
        game_status: @game_status,
        count_of_try: @num_of_try,
        is_hint_used: @is_hint_used
      }

      File.open('../data/results.yml', 'a') {|f| f.write(res.to_yaml) }
    end

    def self.load_results
      res = []
      Psych.load_stream(File.read('../data/results.yml')) do |item|
        res << item
      end
      return res.map do |item|
        "#{item[:user_name]}:\
        \n\tgame status:  #{item[:game_status]}\
        \n\tcount of try: #{item[:count_of_try]}\
        \n\tis hint used: #{item[:is_hint_used]}\n\n"
      end.join if res
      res
    end

  private
    def match_codes user_code
      res = ''
      code_with_no_plus = @secret_code.zip(user_code).delete_if{ |item| item[0] == item[1]}.transpose
      res += '+' * (4 - code_with_no_plus[0].length)
      res += '-' * minus_count(code_with_no_plus)
    end

    def minus_count(code_with_no_plus)
      plus_count = 4 - code_with_no_plus[0].length
      code_with_no_plus[0].length.times do
        item = code_with_no_plus[0].pop
        code_with_no_plus[1].delete_at(code_with_no_plus[1].index(item)) if code_with_no_plus[1].include? item
      end
      4 - plus_count - code_with_no_plus[1].length
    end

    def is_right_code? code
      code.length == 4 && code[/[1-6]{4}/]
    end
  end
end