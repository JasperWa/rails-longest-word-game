require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @grid = generate_grid
  end

  def score
    @attempt = params[:word]
    @grid = params[:grid].split
    run_game
  end

  private

  def generate_grid(grid_size = 10)
    alphabet_array = ('a'..'z').to_a
    vowels_array = ['a', 'e', 'o', 'u', 'i']
    nr_of_vowels = grid_size / 3
    letter_grid = vowels_array.sample(nr_of_vowels) + alphabet_array.sample(grid_size - nr_of_vowels)
    return letter_grid
  end

  def run_game
    grid_match = valid_grid?
    valid_word = valid_word?

    if grid_match && valid_word
      score, bonus = score_calculator
      bonus_message = bonus.positive? ? "(#{bonus} bonus points) " : ''
      @message = "Congratulations! You scored #{score} points #{bonus_message}with the word #{@attempt.upcase}"
      update_total(score)
    else
      if grid_match
        @message = "Sorry but #{@attempt.upcase} does not seem to be a valid English word..."
      else
        @message = "Sorry but #{@attempt.upcase} cannot be built out of #{@grid}"
      end
    end
  end

  def valid_grid?
    grid_copy = @grid.map { |letter| letter.downcase }
    @attempt.chars.each.all? do |char|
      grid_copy.delete_at(grid_copy.index(char)) if grid_copy.include?(char)
    end
  end

  def valid_word?
    url = "https://wagon-dictionary.herokuapp.com/#{@attempt}"
    user_serialized = URI.open(url).read
    user = JSON.parse(user_serialized)
    return user['found']
  end
end

def score_calculator
  bonus = @attempt.length == @grid.length ? 3 : 0
  score = @attempt.length + bonus
  return score, bonus
end

def update_total(score)
  if session[:total_score]
    session[:total_score] += score
  else
    session[:total_score] = score
  end
end
