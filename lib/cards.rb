#!/usr/bin/env ruby -w
#
# Copyright (c) 2007 Damon W. Smith
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

class SymbolInfo
  attr_reader :display_str
  attr_reader :ordinal_array

  def initialize(ordinal_array, display_str)
    @ordinal_array = ordinal_array
    @display_str = display_str 
  end
end

class SymbolError < StandardError
end

class GenericSymbol
  include Comparable

  # Force use of custom constructor
  # Each unique symbol will only be instantiated once
  private_class_method :new

  # Class definitions
  @@sym_map = {}
  class << self

    attr_reader :symbol_info
    attr_reader :ordering
    attr_reader :ordered_info

    # Only allow each symbol to be created once
    def get(symbol)
      sym_key = [self.class, symbol]
      @@sym_map[sym_key] = new(symbol) unless @@sym_map[sym_key]
      @@sym_map[sym_key]
    end

    def order_valid?(order)
      @symbol_info and order >= 0 and
        order < @symbol_info.values[0].ordinal_array.length
    end

    def ordering=(order)
      if order_valid?(order)
        @ordering = order
        @ordered_info = @symbol_info.values.sort { |a,b|
          a.ordinal_array[order] <=> b.ordinal_array[order] }
      else
        raise ArgumentError.new("ordering does not exist: #{order}")
      end
    end

    def first
      raise SymbolError.new("ordering not specified") unless @ordering
      new(@symbol_info.index(@ordered_info[0]))
    end

    def last
      raise SymbolError.new("ordering not specified") unless @ordering
      new(@symbol_info.index(@ordered_info[-1]))
    end

    def gen_all
      (first..last).each do |sym|
        yield sym
      end
    end
  end

  # Object definitions

  def initialize(symbol)
    raise ArgumentError.new("illegal symbol: #{symbol}") unless
      self.class.symbol_info[symbol]
    @symbol = symbol
  end

  def to_s
    self.class.symbol_info[@symbol].display_str
  end

  def <=>(other)
    self.class.symbol_info[@symbol].ordinal_array[self.class.ordering] <=>
      self.class.symbol_info[other.symbol].ordinal_array[self.class.ordering]
  end

  def succ
    self.class.ordered_info.each_with_index do |obj, i|
      if obj == self.class.symbol_info[@symbol]
        if self.class.ordered_info[i+1]
          return self.class.get(
            self.class.symbol_info.index(self.class.ordered_info[i+1]))
        else
          return nil
        end
      end
    end
  end

  protected
    attr_reader :symbol
end

class Rank < GenericSymbol
  VALUE = 0
  DISPLAY = 1

  @symbol_info = { :two   => SymbolInfo.new([ 0, 12], '2'),
                   :three => SymbolInfo.new([ 1, 11], '3'),
                   :four  => SymbolInfo.new([ 2, 10], '4'),
                   :five  => SymbolInfo.new([ 3,  9], '5'),
                   :six   => SymbolInfo.new([ 4,  8], '6'),
                   :seven => SymbolInfo.new([ 5,  7], '7'),
                   :eight => SymbolInfo.new([ 6,  6], '8'),
                   :nine  => SymbolInfo.new([ 7,  5], '9'),
                   :ten   => SymbolInfo.new([ 8,  4], '10'),
                   :jack  => SymbolInfo.new([ 9,  3], 'J'),
                   :queen => SymbolInfo.new([10,  2], 'Q'),
                   :king  => SymbolInfo.new([11,  1], 'K'),
                   :ace   => SymbolInfo.new([12,  0], 'A') }
end

class Suit < GenericSymbol
  VALUE = 0
  DISPLAY = 1

  CLUB    = "\005"
  DIAMOND = "\004"
  HEART   = "\003"
  SPADE   = "\006"

  @symbol_info = { :clubs    => SymbolInfo.new([0, 2], CLUB),
                   :diamonds => SymbolInfo.new([1, 3], DIAMOND),
                   :hearts   => SymbolInfo.new([2, 1], HEART),
                   :spades   => SymbolInfo.new([3, 0], SPADE)}
end

class Card
  include Comparable

  VALUE = 0
  DISPLAY = 1

  # Force use of custom constructor
  # Each card will only be instantiated once
  private_class_method :new

  # Class definitions
  @@card_map = {}
  class << self
    attr_reader :ordering

    # Only allow each card to be created once
    def get(rank, suit)
      rank = Rank.get(rank) if rank.class == Symbol
      suit = Suit.get(suit) if suit.class == Symbol
      raise ArgumentError.new("Illegal card (#{rank}, #{suit})") unless
        rank.class == Rank and suit.class == Suit
      card_key = [rank, suit]
      @@card_map[card_key] = new(rank, suit) unless @@card_map[card_key]
      @@card_map[card_key]
    end

    def order_valid?(order)
      Rank.order_valid?(order) and Suit.order_valid?(order)
    end

    def ordering=(order)
      if order_valid?(order)
        Rank.ordering = order
        Suit.ordering = order
        @ordering = order
      else
        raise ArgumentError.new("ordering does not exist: #{order}")
      end
    end

    def first
      new(Rank.first, Suit.first)
    end

    def last
      new(Rank.last, Suit.last)
    end

    def gen_all
      (first..last).each do |card|
        yield card
      end
    end

    def to_a
      (first..last).to_a
    end
  end

  # Object definitions

  attr_reader :rank, :suit

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def to_s
    "#@rank#@suit"
  end

  def <=>(other)
    @suit != other.suit ? @suit <=> other.suit : @rank <=> other.rank 
  end

  def succ
    return Card.get(@rank.succ, @suit) if @rank.succ
    return Card.get(Rank.first, @suit.succ) if @suit.succ
    nil
  end
end

class Cards
  def initialize
    @cards = Card.to_a
  end

  def dup
    dup_cards = Cards.new
    dup_cards.cards = @cards.dup
    dup_cards
  end

  def to_s
    @cards.inject { |str,card| "#{str} #{card}" }
  end

  def shuffle!
    @cards = @cards.dup.collect { @cards.slice!(rand(@cards.length)) }
    self
  end

  def shuffle
    self.dup.shuffle!
  end

  # hands is an array of empty Hand-derived objects
  def deal(hands)
    @cards.each_with_index { |card,i| hands[i%hands.length].add(card) }
    hands
  end

  def length
    @cards.length
  end

  protected
    attr_writer :cards
end

__END__

class Hand < Cards
  def initialize
    @cards = []
  end

  def add(card)
    @cards <<= card
  end

  def remove(card)
    @cards.delete(card)
  end
end

class BridgeHand < Hand
  def sort!
    @cards.sort!
  end

  def to_s
    str = ''
    for suit in [Suit.new(:spades), Suit.new(:hearts),
                 Suit.new(:diamonds), Suit.new(:clubs)]
      str = "#{str}#{suit} "
      @cards.inject(str) do |s,card|
        str = "#{str} #{card.rank}" if card.suit == suit
      end
      str += "\n"
    end
    str
  end
end

class BridgeDeal
  attr_reader :hands

  def initialize
    SortableSymbol.use_display_ord=true
    @hands = []
    4.times { @hands <<= BridgeHand.new }
    Cards.new.shuffle.deal(@hands)
    @hands.each { |hand| hand.sort! }
  end

  def to_s
    "North\n#{@hands[0]}\n" +
    "\nEast\n#{@hands[1]}\n" +
    "\nSouth\n#{@hands[2]}\n" +
    "\nWest\n#{@hands[3]}"
  end
end
