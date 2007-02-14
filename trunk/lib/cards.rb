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

class SortableSymbolInfo
  attr_reader :display_str

  @@use_display_ord = true

  def SortableSymbolInfo.use_display_ord=(value)
    @@use_display_ord = value
  end

  def ordinal
    if @@use_display_ord
      @display_ord
    else
      @value_ord
    end
  end

  def initialize(value_ord, display_ord, display_str)
    @value_ord = value_ord
    @display_ord = display_ord 
    @display_str = display_str 
  end
end

class SortableSymbol
  include Comparable

  def SortableSymbol.use_display_ord=(value)
    SortableSymbolInfo.use_display_ord = value
  end

  def get_info
    # Derived classes must override this function
    raise NoMethodError
  end

  def new_instance(symbol)
    # Derived classes must override this function
    raise NoMethodError
  end

  def initialize(symbol = nil)
    @first_symbol = get_info.index(
      get_info.values.detect { |obj| obj.ordinal == 0 } )
    if symbol
      raise ArgumentError.new("illegal symbol") unless get_info[symbol]
      @symbol = symbol
    else
      @symbol = @first_symbol
    end
  end

  def to_s
    get_info[@symbol].display_str
  end

  def <=>(other)
    get_info[@symbol].ordinal <=> get_info[other.symbol].ordinal
  end

  def succ
    succ_symbol = get_info.index(
      get_info.values.detect do |obj|
        obj.ordinal == get_info[@symbol].ordinal + 1
      end)
    new_instance(succ_symbol) if succ_symbol
  end

  def first
    new_instance(@first_symbol) if @first_symbol
  end

  protected
    attr_reader :symbol
end

class Rank < SortableSymbol
  @@rank_info = { :two   => SortableSymbolInfo.new( 0, 12, '2'),
                  :three => SortableSymbolInfo.new( 1, 11, '3'),
                  :four  => SortableSymbolInfo.new( 2, 10, '4'),
                  :five  => SortableSymbolInfo.new( 3,  9, '5'),
                  :six   => SortableSymbolInfo.new( 4,  8, '6'),
                  :seven => SortableSymbolInfo.new( 5,  7, '7'),
                  :eight => SortableSymbolInfo.new( 6,  6, '8'),
                  :nine  => SortableSymbolInfo.new( 7,  5, '9'),
                  :ten   => SortableSymbolInfo.new( 8,  4, '10'),
                  :jack  => SortableSymbolInfo.new( 9,  3, 'J'),
                  :queen => SortableSymbolInfo.new(10,  2, 'Q'),
                  :king  => SortableSymbolInfo.new(11,  1, 'K'),
                  :ace   => SortableSymbolInfo.new(12,  0, 'A') }
  def get_info
    @@rank_info
  end

  def new_instance(symbol)
    Rank.new(symbol)
  end
end

class Suit < SortableSymbol
  CLUB    = "\005"
  DIAMOND = "\004"
  HEART   = "\003"
  SPADE   = "\006"

  @@suit_info = { :clubs    => SortableSymbolInfo.new( 0, 2, CLUB),
                  :diamonds => SortableSymbolInfo.new( 1, 3, DIAMOND),
                  :hearts   => SortableSymbolInfo.new( 2, 1, HEART),
                  :spades   => SortableSymbolInfo.new( 3, 0, SPADE)}
  def get_info
    @@suit_info
  end

  def new_instance(symbol)
    Suit.new(symbol)
  end
end

class Card
  include Comparable

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
    return Card.new(@rank.succ, @suit) if @rank.succ
    return Card.new(@rank.first, @suit.succ) if @suit.succ
    nil
  end

  def Card.first
    return Card.new(Rank.new, Suit.new)
  end

  attr_reader :rank, :suit
end

class Cards
  def initialize
    card = Card.first
    @cards = []
    while card
      @cards <<= card
      card = card.succ
    end
  end

  def dup
    new_from_cards(@cards)
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

    def new_from_cards(cards)
      new = Cards.new
      new.cards = cards.dup
      new
    end
end

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
