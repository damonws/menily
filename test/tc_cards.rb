#!/usr/bin/ruby -w
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

$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'test/unit'
require 'cards'

class TcSortableSymbol < Test::Unit::TestCase
  # Only derived classes of SortableSymbol can be instantiated
  def test_instantiation
    assert_raise(NoMethodError) { SortableSymbol.new() }
  end
end

class TcRank < Test::Unit::TestCase
  def test_instantiation
    assert_nothing_raised       { Rank.new() }
    assert_nothing_raised       { Rank.new(:seven) }
    assert_raise(ArgumentError) { Rank.new(:eleven) }
  end

  def test_range_display
    SortableSymbol.use_display_ord = true
    str = ''
    (Rank.new(:ace)..Rank.new(:two)).each do |x|
      str += x.to_s
    end
    assert_equal('AKQJ1098765432', str)
  end

  def test_range_internal
    SortableSymbol.use_display_ord = false
    str = ''
    (Rank.new(:two)..Rank.new(:ace)).each do |x|
      str += x.to_s
    end
    assert_equal('2345678910JQKA', str)
  end

  def test_succ
    SortableSymbol.use_display_ord = true
    assert_equal(Rank.new(:three).succ, Rank.new(:two))
    assert_nil(Rank.new(:two).succ)
    SortableSymbol.use_display_ord = false
    assert_equal(Rank.new(:three).succ, Rank.new(:four))
    assert_nil(Rank.new(:ace).succ)
  end

  def test_first
    SortableSymbol.use_display_ord = true
    assert_equal(Rank.new(:eight).first, Rank.new(:ace))
    SortableSymbol.use_display_ord = false
    assert_equal(Rank.new(:eight).first, Rank.new(:two))
  end

  def test_spaceship
    SortableSymbol.use_display_ord = true
    assert(Rank.new(:jack) < Rank.new(:four))
    SortableSymbol.use_display_ord = false
    assert(Rank.new(:jack) > Rank.new(:four))
  end
end

class TcSuit < Test::Unit::TestCase
  def test_instantiation
    assert_nothing_raised       { Suit.new() }
    assert_nothing_raised       { Suit.new(:spades) }
    assert_raise(ArgumentError) { Suit.new(:swords) }
  end

  def test_range_display
    SortableSymbol.use_display_ord = true
    str = ''
    (Suit.new(:spades)..Suit.new(:diamonds)).each { |x| str += x.to_s }
    assert_equal(Suit::SPADE + Suit::HEART + Suit::CLUB + Suit::DIAMOND, str)
  end

  def test_range_internal
    SortableSymbol.use_display_ord = false
    str = ''
    (Suit.new(:clubs)..Suit.new(:spades)).each { |x| str += x.to_s }
    assert_equal(Suit::CLUB + Suit::DIAMOND + Suit::HEART + Suit::SPADE, str)
  end

  def test_succ
    SortableSymbol.use_display_ord = true
    assert_equal(Suit.new(:hearts).succ, Suit.new(:clubs))
    assert_nil(Suit.new(:diamonds).succ)
    SortableSymbol.use_display_ord = false
    assert_equal(Suit.new(:diamonds).succ, Suit.new(:hearts))
    assert_nil(Suit.new(:spades).succ)
  end

  def test_first
    SortableSymbol.use_display_ord = true
    assert_equal(Suit.new(:hearts).first, Suit.new(:spades))
    SortableSymbol.use_display_ord = false
    assert_equal(Suit.new(:hearts).first, Suit.new(:clubs))
  end

  def test_spaceship
    SortableSymbol.use_display_ord = true
    assert(Suit.new(:hearts) < Suit.new(:diamonds))
    SortableSymbol.use_display_ord = false
    assert(Suit.new(:hearts) > Suit.new(:diamonds))
  end
end

class TcCard < Test::Unit::TestCase
  def test_instantiation
    assert_nothing_raised { Card.new(Rank.new(:seven), Suit.new(:diamonds)) }
  end

  def test_range_display
    SortableSymbol.use_display_ord = true
    range_str = ''
    (Card.new(Rank.new(:ace), Suit.new(:spades))..
     Card.new(Rank.new(:two), Suit.new(:diamonds))).each do |x|
      range_str += x.to_s
    end
    compare_str = ''
    [Suit::SPADE, Suit::HEART, Suit::CLUB, Suit::DIAMOND].each do |suit|
      %w{ A K Q J 10 9 8 7 6 5 4 3 2 }.each do |rank|
        compare_str += rank + suit
      end
    end
    assert_equal(range_str, compare_str)
  end

  def test_range_internal
    SortableSymbol.use_display_ord = false
    range_str = ''
    (Card.new(Rank.new(:two), Suit.new(:clubs))..
     Card.new(Rank.new(:ace), Suit.new(:spades))).each do |x|
      range_str += x.to_s
    end
    compare_str = ''
    [Suit::CLUB, Suit::DIAMOND, Suit::HEART, Suit::SPADE].each do |suit|
      %w{ 2 3 4 5 6 7 8 9 10 J Q K A }.each do |rank|
        compare_str += rank + suit
      end
    end
    assert_equal(range_str, compare_str)
  end

  def test_succ
    SortableSymbol.use_display_ord = true
    assert_equal(Card.new(Rank.new(:jack), Suit.new(:spades)).succ,
                 Card.new(Rank.new(:ten), Suit.new(:spades)))
    assert_equal(Card.new(Rank.new(:two), Suit.new(:hearts)).succ,
                 Card.new(Rank.new(:ace), Suit.new(:clubs)))
    assert_nil(Card.new(Rank.new(:two), Suit.new(:diamonds)).succ)
    SortableSymbol.use_display_ord = false
    assert_equal(Card.new(Rank.new(:ten), Suit.new(:spades)).succ,
                 Card.new(Rank.new(:jack), Suit.new(:spades)))
    assert_equal(Card.new(Rank.new(:ace), Suit.new(:clubs)).succ,
                 Card.new(Rank.new(:two), Suit.new(:diamonds)))
    assert_nil(Card.new(Rank.new(:ace), Suit.new(:spades)).succ)
  end

  def test_first
    SortableSymbol.use_display_ord = true
    assert_equal(Card.first, Card.new(Rank.new(:ace), Suit.new(:spades)))
    SortableSymbol.use_display_ord = false
    assert_equal(Card.first, Card.new(Rank.new(:two), Suit.new(:clubs)))
  end

  def test_spaceship
    SortableSymbol.use_display_ord = true
    assert(Card.new(Rank.new(:king), Suit.new(:spades)) <
           Card.new(Rank.new(:ace), Suit.new(:hearts)))
    assert(Card.new(Rank.new(:king), Suit.new(:clubs)) <
           Card.new(Rank.new(:ace), Suit.new(:diamonds)))
    SortableSymbol.use_display_ord = false
    assert(Card.new(Rank.new(:king), Suit.new(:spades)) >
           Card.new(Rank.new(:ace), Suit.new(:hearts)))
    assert(Card.new(Rank.new(:king), Suit.new(:clubs)) <
           Card.new(Rank.new(:ace), Suit.new(:diamonds)))
  end

  def test_attr
    assert_equal(Card.new(Rank.new(:four), Suit.new(:clubs)).suit,
                 Suit.new(:clubs))
    assert_equal(Card.new(Rank.new(:two), Suit.new(:clubs)).rank,
                 Rank.new(:two))
  end
end

#class Cards
#  def initialize
#    card = Card.first
#    @cards = []
#    while card
#      @cards <<= card
#      card = card.succ
#    end
#  end
#
#  def dup
#    new_from_cards(@cards)
#  end
#
#  def to_s
#    @cards.inject { |str,card| "#{str} #{card}" }
#  end
#
#  def shuffle!
#    @cards = @cards.dup.collect { @cards.slice!(rand(@cards.length)) }
#    self
#  end
#
#  def shuffle
#    self.dup.shuffle!
#  end
#
#  # hands is an array of empty Hand-derived objects
#  def deal(hands)
#    @cards.each_with_index { |card,i| hands[i%hands.length].add(card) }
#    hands
#  end
#
#  def length
#    @cards.length
#  end
#
#  protected
#    attr_writer :cards
#
#    def new_from_cards(cards)
#      new = Cards.new
#      new.cards = cards.dup
#      new
#    end
#end
#
#class Hand < Cards
#  def initialize
#    @cards = []
#  end
#
#  def add(card)
#    @cards <<= card
#  end
#
#  def remove(card)
#    @cards.delete(card)
#  end
#end
#
#class BridgeHand < Hand
#  def sort!
#    @cards.sort!
#  end
#
#  def to_s
#    str = ''
#    for suit in [Suit.new(:spades), Suit.new(:hearts),
#                 Suit.new(:diamonds), Suit.new(:clubs)]
#      str = "#{str}#{suit} "
#      @cards.inject(str) do |s,card|
#        str = "#{str} #{card.rank}" if card.suit == suit
#      end
#      str += "\n"
#    end
#    str
#  end
#end
#
#class BridgeDeal
#  attr_reader :hands
#
#  def initialize
#    SortableSymbol.use_display_ord=true
#    @hands = []
#    4.times { @hands <<= BridgeHand.new }
#    Cards.new.shuffle.deal(@hands)
#    @hands.each { |hand| hand.sort! }
#  end
#
#  def to_s
#    "North\n#{@hands[0]}\n" +
#    "\nEast\n#{@hands[1]}\n" +
#    "\nSouth\n#{@hands[2]}\n" +
#    "\nWest\n#{@hands[3]}"
#  end
#end
#
