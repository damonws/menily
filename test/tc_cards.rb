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

class TcGenericSymbol < Test::Unit::TestCase

  ORD = [ 'ABC', 'BCA' ]
  
  class TestSymbol < GenericSymbol
    @symbol_info = { :a => SymbolInfo.new([ 5, 7], 'A'),
                     :b => SymbolInfo.new([10, 1], 'B'),
                     :c => SymbolInfo.new([20, 3], 'C') }
  end

  def test_order_validation
    assert_equal(true, TestSymbol.order_valid?(ORD.length - 1))
    assert_equal(false, TestSymbol.order_valid?(ORD.length))
  end

  def test_ordering
    (0...ORD.length).each do |order|
      TestSymbol.ordering = order
      assert_equal(order, TestSymbol.ordering)
    end
    assert_raise(ArgumentError) { TestSymbol.ordering = ORD.length }
  end

  def test_first
    (0...ORD.length).each do |order|
      TestSymbol.ordering = order
      assert_equal(ORD[order][0,1], TestSymbol.first.to_s)
    end
  end

  def test_last
    (0...ORD.length).each do |order|
      TestSymbol.ordering = order
      assert_equal(ORD[order][-1,1], TestSymbol.last.to_s)
    end
  end

  def test_spaceship
    (0...ORD.length).each do |order|
      TestSymbol.ordering = order
      assert(TestSymbol.first < TestSymbol.last)
    end
    TestSymbol.ordering = 0
    assert(TestSymbol.new(:a) < TestSymbol.new(:b))
    TestSymbol.ordering = 1
    assert(TestSymbol.new(:a) > TestSymbol.new(:b))
  end

  def test_succ
    (0...ORD.length).each do |order|
      TestSymbol.ordering = order
      assert_nil(TestSymbol.last.succ)
      assert_equal(ORD[order][1,1], TestSymbol.first.succ.to_s)
      assert_equal(ORD[order][2,1], TestSymbol.first.succ.succ.to_s)
    end
  end

  def test_gen_all
    (0...ORD.length).each do |order|
      TestSymbol.ordering = order
      sym_str = ''
      TestSymbol.gen_all { |sym| sym_str += sym.to_s }
      assert_equal(ORD[order], sym_str)
    end
  end
end

class TcRank < Test::Unit::TestCase
  def test_instantiation
    assert_raise(ArgumentError) { Rank.new() }
    assert_nothing_raised       { Rank.new(:seven) }
    assert_raise(ArgumentError) { Rank.new(:eleven) }
  end

  def test_get_all
    Rank.ordering = Rank::VALUE
    ranks = ''
    Rank.gen_all { |rank| ranks += rank.to_s }
    assert_equal('2345678910JQKA', ranks)
    Rank.ordering = Rank::DISPLAY
    ranks = ''
    Rank.gen_all { |rank| ranks += rank.to_s }
    assert_equal('AKQJ1098765432', ranks)
  end
end

class TcSuit < Test::Unit::TestCase
  def test_instantiation
    assert_raise(ArgumentError) { Suit.new() }
    assert_nothing_raised       { Suit.new(:diamonds) }
    assert_raise(ArgumentError) { Suit.new(:swords) }
  end

  def test_get_all
    Suit.ordering = Suit::VALUE
    suits = ''
    Suit.gen_all { |suit| suits += suit.to_s }
    assert_equal("#{Suit::CLUB}#{Suit::DIAMOND}#{Suit::HEART}#{Suit::SPADE}",
                 suits)
    Suit.ordering = Suit::DISPLAY
    suits = ''
    Suit.gen_all { |suit| suits += suit.to_s }
    assert_equal("#{Suit::SPADE}#{Suit::HEART}#{Suit::CLUB}#{Suit::DIAMOND}",
                 suits)
  end

end

class TcRankAndSuit < Test::Unit::TestCase
  def test_independent_ordering
    Rank.ordering = Rank::VALUE
    Suit.ordering = Suit::DISPLAY
    ranks = ''
    suits = ''
    Rank.gen_all { |rank| ranks += rank.to_s }
    Suit.gen_all { |suit| suits += suit.to_s }
    assert_equal('2345678910JQKA', ranks)
    assert_equal("#{Suit::SPADE}#{Suit::HEART}#{Suit::CLUB}#{Suit::DIAMOND}",
                 suits)
    Rank.ordering = Rank::DISPLAY
    Suit.ordering = Suit::VALUE
    ranks = ''
    suits = ''
    Rank.gen_all { |rank| ranks += rank.to_s }
    Suit.gen_all { |suit| suits += suit.to_s }
    assert_equal('AKQJ1098765432', ranks)
    assert_equal("#{Suit::CLUB}#{Suit::DIAMOND}#{Suit::HEART}#{Suit::SPADE}",
                 suits)
  end
end

class TcCard < Test::Unit::TestCase

  ORD = [Card::VALUE, Card::DISPLAY]
  FIRSTCARD = ["2#{Suit::CLUB}", "A#{Suit::SPADE}"]
  LASTCARD = ["A#{Suit::SPADE}", "2#{Suit::DIAMOND}"]
  CARDSUCC = [[[:ace, :clubs,    "2#{Suit::DIAMOND}", "3#{Suit::DIAMOND}"],
               [:ace, :diamonds, "2#{Suit::HEART}"  , "3#{Suit::HEART}"  ],
               [:king, :hearts,  "A#{Suit::HEART}"  , "2#{Suit::SPADE}"  ]],
              [[:two, :spades,   "A#{Suit::HEART}"  , "K#{Suit::HEART}"  ],
               [:three, :hearts, "2#{Suit::HEART}"  , "A#{Suit::CLUB}"   ],
               [:two, :clubs,    "A#{Suit::DIAMOND}", "K#{Suit::DIAMOND}"]]]

  def test_instantiation
    card_str = "5#{Suit::HEART}"
    assert_equal(card_str, Card.new(:five, :hearts).to_s)
    assert_equal(card_str, Card.new(Rank.new(:five), :hearts).to_s)
    assert_equal(card_str, Card.new(Rank.new(:five), Suit.new(:hearts)).to_s)
    assert_equal(card_str, Card.new(:five, Suit.new(:hearts)).to_s)
    assert_raise(ArgumentError) { Card.new(5, :hearts) }
    assert_raise(ArgumentError) { Card.new(:five, 'H') }
    assert_raise(ArgumentError) { Card.new(:five, :swords) }
    assert_raise(ArgumentError) { Card.new(:eleven, :hearts) }
  end

  def test_order_validation
    (0...ORD.length).each do |order|
      assert_equal(true, Card.order_valid?(order))
    end
    assert_equal(false, Card.order_valid?(ORD.length))
  end

  def test_ordering
    (0...ORD.length).each do |order|
      Card.ordering = order
      assert_equal(order, Card.ordering)
    end
    assert_raise(ArgumentError) { Card.ordering = ORD.length }
  end

  def test_first
    (0...ORD.length).each do |order|
      Card.ordering = order
      assert_equal(FIRSTCARD[order], Card.first.to_s)
    end
  end

  def test_last
    (0...ORD.length).each do |order|
      Card.ordering = order
      assert_equal(LASTCARD[order], Card.last.to_s)
    end
  end

  def test_spaceship
    (0...ORD.length).each do |order|
      Card.ordering = order
      assert(Card.first < Card.last)
    end
    Card.ordering = 0
    assert(Card.new(:king, :spades) > Card.new(:ace, :hearts))
    assert(Card.new(:king, :clubs) < Card.new(:ace, :diamonds))
    Card.ordering = 1
    assert(Card.new(:king, :spades) < Card.new(:ace, :hearts))
    assert(Card.new(:king, :clubs) < Card.new(:ace, :diamonds))
  end

  def test_succ
    (0...ORD.length).each do |order|
      Card.ordering = order
      assert_nil(Card.last.succ)
      for rank, suit, str1, str2 in CARDSUCC[order]
        assert_equal(str1, Card.new(rank, suit).succ.to_s)
        assert_equal(str2, Card.new(rank, suit).succ.succ.to_s)
      end
    end
  end

=begin
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

  def test_gen_all
    (0...ORD.length).each do |order|
      TestSymbol.ordering = order
      sym_str = ''
      TestSymbol.gen_all { |sym| sym_str += sym.to_s }
      assert_equal(ORD[order], sym_str)
    end
  end

  def test_attr
    assert_equal(Card.new(Rank.new(:four), Suit.new(:clubs)).suit,
                 Suit.new(:clubs))
    assert_equal(Card.new(Rank.new(:two), Suit.new(:clubs)).rank,
                 Rank.new(:two))
  end
=end
end

__END__

class TcCard < Test::Unit::TestCase

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

__END__

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
