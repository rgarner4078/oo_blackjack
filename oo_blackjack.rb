require 'rubygems'
require 'pry'


class Card
  attr_accessor :suit, :face_value

  def initialize(s, fv)
    @suit = s
    @face_value = fv
  end

  def to_s
    "The #{face_value} of #{find_suit}"
  end

  def find_suit
    case suit
      when 'H' then 'Hearts'
      when 'D' then 'Diamonds'
      when 'S' then 'Spades'
      when 'C' then 'Clubs'
    end
  end
end


class Deck
  attr_accessor :cards

  def initialize
    @cards = []
    ['H', 'D', 'S', 'C'].each do |suit|
      ['2','3','4','5','6','7','8','9','10','Jack','Queen','King','Ace'].each do |face_value|
        @cards << Card.new(suit, face_value)
      end
    end
    cards.shuffle!
  end

  def draw_card
    cards.pop
  end
end


module Hand
  def show_hand
    puts "--- #{name}'s Hand ---"
    cards.each do |card|
      puts card.to_s
    end
    puts "Total: #{total}"
  end

  def total
    face_values = cards.map{|card| card.face_value}

    total = 0
    face_values.each do |val|
      if val == "Ace"
        if total + 11 <= 21
          total += 11
        else
          total += 1
        end
      else
        total += (val.to_i == 0 ? 10 : val.to_i)
      end
    end
    total
  end

  def add_card(new_card)
    cards << new_card
  end

  def is_busted?
    total > Blackjack::BLACKJACK_AMOUNT
  end
end


class Player
  include Hand

  attr_accessor :name, :cards

  def initialize(n)
    @name = n
    @cards = []
  end

  def show_flop
    show_hand
  end
end


class Dealer
  include Hand

  attr_accessor :name, :cards

  def initialize
    @name = "Dealer"
    @cards = []
  end

  def show_flop
    puts "--- Dealer's Hand ---"
    puts "First card is hidden"
    puts "Second card is #{cards[1]}"
  end
end


class Blackjack
  attr_accessor :deck, :player, :dealer

  BLACKJACK_AMOUNT = 21
  DEALER_HIT_LIMIT = 17

  def initialize
    @deck = Deck.new
    @player = Player.new("Player1")
    @dealer = Dealer.new
  end

  def set_player_name
    puts "=> Enter player name"
    player.name = gets.chomp
  end

  def deal_cards
    player.add_card(deck.draw_card)
    dealer.add_card(deck.draw_card)
    player.add_card(deck.draw_card)
    dealer.add_card(deck.draw_card)
  end

  def show_flops
    player.show_flop
    dealer.show_flop
  end

  def blackjack_or_bust?(player_or_dealer)
    if player_or_dealer.total == BLACKJACK_AMOUNT
      if player_or_dealer.is_a?(Dealer)
        puts "Dealer hit blackjack. #{player.name} loses"
      else
        puts "#{player.name} hit blackjack. #{player.name} wins!"
      end
      play_again?
    elsif player_or_dealer.is_busted?
      if player_or_dealer.is_a?(Dealer)
        puts "Dealer busted. #{player.name} wins!"
      else
        puts "#{player.name} busted. #{player.name} loses."
      end
      play_again?
    end
  end

  def player_turn
    puts "--- #{player.name}'s turn ---"
    blackjack_or_bust?(player)

    while !player.is_busted?
      puts "Hit? (y/n)"
      response = gets.chomp

      if !['y','n'].include?(response)
        puts "Error: you must choose yes or no (y/n)"
        next
      end

      if response == 'n'
        puts "#{player.name} stays at #{player.total}"
        break
      end

      new_card = deck.draw_card
      puts "Dealing card to #{player.name}: #{new_card}"
      player.add_card(new_card)
      puts "#{player.name}'s total is now: #{player.total}"

      blackjack_or_bust?(player)
    end
  end

  def dealer_turn
    puts "--- Dealer's turn ---"
    blackjack_or_bust?(dealer)
    while dealer.total < DEALER_HIT_LIMIT
      new_card = deck.draw_card
      puts "Dealing card to #{dealer.name}: #{new_card}"
      dealer.add_card(new_card)
      puts "#{dealer.name}'s total is now: #{dealer.total}"

      blackjack_or_bust?(dealer)
    end
    puts "Dealer stays at #{dealer.total}"
  end

  def who_won?
    puts "---------------------"
    puts "#{player.name}'s hand at #{player.total}"
    puts "Dealer's hand at #{dealer.total}"
    if player.total > dealer.total
      puts "#{player.name} wins!"
    elsif player.total < dealer.total
      puts "#{player.name} loses."
    else
      puts "Its a tie."
    end
    play_again?
  end
  
  def play_again?
    puts ""
    puts "Play again? (y/n)"
    if gets.chomp == 'y'
      deck = Deck.new
      player.cards = []
      dealer.cards = []
      start
    else
      exit
    end
  end

  def start
    system 'clear'
    set_player_name
    deal_cards
    show_flops
    player_turn
    dealer_turn
    who_won?
    play_again?
  end
end

Blackjack.new.start