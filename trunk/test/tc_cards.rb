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

  def test_instantiation
    assert_equal(TestSymbol.get(:a).object_id,
                 TestSymbol.get(:a).object_id)
    assert_not_equal(TestSymbol.get(:a).object_id,
                     TestSymbol.get(:b).object_id)
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
    assert(TestSymbol.get(:a) < TestSymbol.get(:b))
    TestSymbol.ordering = 1
    assert(TestSymbol.get(:a) > TestSymbol.get(:b))
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
    assert_raise(ArgumentError) { Rank.get() }
    assert_nothing_raised       { Rank.get(:seven) }
    assert_raise(ArgumentError) { Rank.get(:eleven) }
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
    assert_raise(ArgumentError) { Suit.get() }
    assert_nothing_raised       { Suit.get(:diamonds) }
    assert_raise(ArgumentError) { Suit.get(:swords) }
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
    assert_equal(card_str, Card.get(:five, :hearts).to_s)
    assert_equal(card_str, Card.get(Rank.get(:five), :hearts).to_s)
    assert_equal(card_str, Card.get(Rank.get(:five), Suit.get(:hearts)).to_s)
    assert_equal(card_str, Card.get(:five, Suit.get(:hearts)).to_s)
    assert_raise(ArgumentError) { Card.get(5, :hearts) }
    assert_raise(ArgumentError) { Card.get(:five, 'H') }
    assert_raise(ArgumentError) { Card.get(:five, :swords) }
    assert_raise(ArgumentError) { Card.get(:eleven, :hearts) }
    assert_equal(Card.get(:jack, :clubs).object_id,
                 Card.get(Rank.get(:jack), Suit.get(:clubs)).object_id)
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
    assert(Card.get(:king, :spades) > Card.get(:ace, :hearts))
    assert(Card.get(:king, :clubs) < Card.get(:ace, :diamonds))
    Card.ordering = 1
    assert(Card.get(:king, :spades) < Card.get(:ace, :hearts))
    assert(Card.get(:king, :clubs) < Card.get(:ace, :diamonds))
  end

  def test_succ
    (0...ORD.length).each do |order|
      Card.ordering = order
      assert_nil(Card.last.succ)
      for rank, suit, str1, str2 in CARDSUCC[order]
        assert_equal(str1, Card.get(rank, suit).succ.to_s)
        assert_equal(str2, Card.get(rank, suit).succ.succ.to_s)
      end
    end
  end

  def test_gen_all_value
    Card.ordering = Card::VALUE
    card_str = ''
    Card.gen_all { |x| card_str += x.to_s }
    compare_str = ''
    [Suit::CLUB, Suit::DIAMOND, Suit::HEART, Suit::SPADE].each do |suit|
      %w{ 2 3 4 5 6 7 8 9 10 J Q K A }.each do |rank|
        compare_str += rank + suit
      end
    end
    assert_equal(card_str, compare_str)
  end

  def test_gen_all_display
    Card.ordering = Card::DISPLAY
    card_str = ''
    Card.gen_all { |x| card_str += x.to_s }
    compare_str = ''
    [Suit::SPADE, Suit::HEART, Suit::CLUB, Suit::DIAMOND].each do |suit|
      %w{ A K Q J 10 9 8 7 6 5 4 3 2 }.each do |rank|
        compare_str += rank + suit
      end
    end
    assert_equal(card_str, compare_str)
  end

  def test_to_a
    (0...ORD.length).each do |order|
      Card.ordering = order
      i = 0
      Card.gen_all do |card|
        assert_equal(card, Card.to_a[i])
        i += 1
      end
    end
    assert_equal(52, Card.to_a.length)
  end

  def test_attr
    assert_equal(Card.get(Rank.get(:four), Suit.get(:clubs)).suit,
                 Suit.get(:clubs))
    assert_equal(Card.get(Rank.get(:two), Suit.get(:clubs)).rank,
                 Rank.get(:two))
  end
end

class TcCards < Test::Unit::TestCase
  ORD = [Card::VALUE, Card::DISPLAY]

  def all_card_str(order)
    suit = [ [Suit::CLUB, Suit::DIAMOND, Suit::HEART, Suit::SPADE],
             [Suit::SPADE, Suit::HEART, Suit::CLUB, Suit::DIAMOND] ]
    rank = [ %w{ 2 3 4 5 6 7 8 9 10 J Q K A },
             %w{ A K Q J 10 9 8 7 6 5 4 3 2 } ]

    suit[order].inject('') do |str, s|
      str + rank[order].inject('') do |str, r|
        str + ' ' + r + s
      end
    end.strip
  end

  def test_instantiate
    (0...ORD.length).each do |order|
      Card.ordering = order
      assert_equal(all_card_str(order), Cards.new.to_s)
      assert_raise(ArgumentError) { Cards.new(:blah) }
    end
  end

  def test_dup
    (0...ORD.length).each do |order|
      Card.ordering = order
      deck1 = Cards.new
      deck2 = deck1.dup
      assert_not_equal(deck1.object_id, deck2.object_id)
      assert_equal(deck1.to_s, deck2.to_s)
    end
  end

  def test_length
    assert_equal(52, Cards.new.length)
  end

  def test_shuffle
    (0...ORD.length).each do |order|
      Card.ordering = order
      deck = Cards.new
      deck1 = deck.shuffle
      deck2 = deck.shuffle
      deck3 = deck.shuffle
      assert_not_equal(deck.to_s, deck1.to_s)
      assert_not_equal(deck.to_s, deck2.to_s)
      assert_not_equal(deck.to_s, deck3.to_s)
    end
  end
end