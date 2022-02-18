require 'digest'

class Wordle
  ESCAPES = {
    :white => "30;107m",
    :yellow => "30;103m",
    :green => "30;102m"
  }

  def initialize
    main_loop
  end

  def max_guesses
    6
  end

  def words
    @words ||= File.read('/usr/share/dict/british-english').scan(/^\w\w\w\w\w$/).map(&:downcase)
  end

  def actual
    @actual ||= words.sample.downcase
  end

  def incorrect_size?(guess)
    return false if guess.size == actual.size

    puts "You must enter a 5 letter word"
    true
  end

  def invalid_characters?(guess)
    return false if guess.match(/[A-Za-z]/)

    puts "Your guess must be a valid word"
    true
  end

  def invalid_word?(guess)
    return false if words.include?(guess)

    puts "You must enter a valid 5 letter word"
    true
  end

  def invalid_guess?(guess)
    invalid_word?(guess) || invalid_characters?(guess) || incorrect_size?(guess)
  end

  def main_loop
    (1..max_guesses).each do |cnt|

      puts "Enter your guess #{cnt}/#{max_guesses}:"
      guess = gets.chomp.downcase

      next if invalid_guess?(guess)

      return success(guess) if guess == actual

      puts format_word(guess)
    end
    puts "You lose! The word was:"
    puts actual.upcase
  end

  def format_word(guess)
    output = []

    remaining = actual.split('').each_with_index.map { |letter, index|
      letter if letter != guess[index]
    }.compact

    actual.split('').each_with_index do |letter, index|
      if letter == guess[index]
        output << square(letter, :green)
        next
      end
      if letter != guess[index]
        if remaining.include?(guess[index])
          output << square(guess[index], :yellow)
          remaining.delete(guess[index])
          next
        end
      end
      output << square(guess[index])
    end
    output.join
  end

  def success(guess)
    puts "You guessed right"
    output = guess.split('').map do |letter|
      square letter, :green
    end
    puts output.join
  end

  def square(letter, colour=:white)
    "\033[#{ESCAPES[colour]} #{letter.upcase} \e[0m "
  end

end

class SHA256dle < Wordle
  def actual; end

  def invalid_guess?(guess)
    false
  end
end


class WordleSolver
  attr_accessor :includers, :excluders
  def initalize(includers=[], excluders=[])
    @includers = includers
    @excluders = excluders
  end

  def guess
    shortlist.sample
  end

  private

  def include_chars?(word, includers, excluders)
    include_array, exclude_array = [], []
    includers.each do |ch|
      include_array << true if word.include?(ch)
    end
    excluders.each do |ch|
      exclude_array << true unless word.include?(ch)
    end
    if (include_array.size == includers.size) && (exclude_array.size == excluders.size)
      return true
    else
      return false
    end
  end

  def shortlist
    words.select do |word|
      include_chars?(word)
    end
  end
end


Wordle.new()
