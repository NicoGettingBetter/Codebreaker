require_relative 'spec_helper'

module Codebreaker
  RSpec.describe Game do
      before do
        subject.start
      end
    describe "#start" do

      it "generates secret code" do
        expect(subject.instance_variable_get(:@secret_code)).not_to be_empty
      end
      it "saves 4 numbers secret code" do
        expect(subject.instance_variable_get(:@secret_code)).to have_exactly(4).items
      end
      it "saves secret code with numbers from 1 to 6" do
        expect(subject.instance_variable_get(:@secret_code).join).to match(/[1-6]+/)
      end
      it "generates count of try" do
        expect(subject.instance_variable_get(:@count_of_try)).to be_integer
      end
      it "saves number between 10 and 20" do
        expect(subject.instance_variable_get(:@count_of_try)).to be_between(10, 20).inclusive
      end
      it "generates new secret code after calling start" do
      	old_value = subject.instance_variable_get(:@secret_code)
      	begin
      		subject.start
      	end while old_value == subject.instance_variable_get(:@secret_code)
      	expect(subject.instance_variable_get(:@secret_code)).not_to eql(old_value)
      end
    end

    describe "#is_right_code?" do
      it "return false if user code has wrong format" do
        expect(subject.send(:is_right_code?, "23di")).to be_falsey
      end
      it "return false if user code too long" do
        expect(subject.send(:is_right_code?, "12345")).to be_falsey
      end
      it "return false if user code too short" do
        expect(subject.send(:is_right_code?, "123")).to be_falsey
      end
    end

    describe "#match_secret_code" do 
      before do
        allow(subject).to receive(:is_right_code?).and_return(true)
      end

      it "increments num_of_try" do
        before = subject.num_of_try
        subject.match_secret_code('1234')
        after = subject.num_of_try
        expect(after - before).to eql(1)
      end 

      [
        ['1234', '1234', '++++ You win!!!'], ['1234', '4321', '----'],
        ['1231', '1234', '+++'],  ['1134', '1431', '++--'],
        ['1324', '1234', '++--'], ['1111', '1321', '++'],
        ['1234', '1111', '+'],    ['2552', '1221', '--'],
        ['1234', '2332', '+-'],   ['4441', '2233', ''],
        ['1234', '5561', '-'],    ['1234', '1342', '+---'],
        ['3211', '1561', '+-'],   ['1666', '6661', '++--']
      ].each do |item|
        it "return #{item[2]} if user code is #{item[1]} and secret code is #{item[0]}" do
          subject.instance_variable_set(:@secret_code, item[0].chars.map(&:to_i))
          expect(subject.match_secret_code(item[1])).to eql(item[2])
        end
      end

      it "return Game Over when num of try ended" do
      	guess = (subject.instance_variable_get(:@secret_code).join.to_i + 1).to_s
      	until (subject.match_secret_code(guess)[/Game Over/]) ; end
      	expect(subject.match_secret_code('1234')).to eql('Game Over')
      end
    end

    describe "#hint" do
      it "return hint" do
        expect(subject.hint).to be_between(1, 6).inclusive
      end

      it "return false if hint was call earlier" do
        subject.hint
        expect(subject.hint).to eql("hint already used")
      end

      it "return hint on new game" do
        subject.hint
        subject.start
        expect(subject.hint).to be_between(1, 6).inclusive
      end
    end

    describe "#save_result" do
    	it "saves results to yaml file" do
	    	subject.match_secret_code(subject.instance_variable_get(:@secret_code).join)
	    	subject.save_result("test #{subject.instance_variable_get(:@secret_code)}")    	
	      from_file = []
	      Psych.load_stream(File.read('../data/results.yml')) do |item|
	        from_file << item
	      end
	      res = from_file.pop
	      expect(res).to eql({
	        user_name: "test #{subject.instance_variable_get(:@secret_code)}",
	        game_status: 'win',
	        count_of_try: 1,
	        is_hint_used: false,
	      })
	    end
    end
  end
end