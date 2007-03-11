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
require 'bridge'

class TcBridgeHand < Test::Unit::TestCase
  def test_sort
    hand = [BridgeHand.new]
    Cards.new.new_deck.shuffle.deal(hand)
    hand[0].sort!
    Card.to_a.each { |card| assert_equal(card, hand[0].top) }
  end

  def test_to_s
    all_card_hand =
      "#{Suit::SPADE}  A K Q J 10 9 8 7 6 5 4 3 2\n" +
      "#{Suit::HEART}  A K Q J 10 9 8 7 6 5 4 3 2\n" +
      "#{Suit::DIAMOND}  A K Q J 10 9 8 7 6 5 4 3 2\n" +
      "#{Suit::CLUB}  A K Q J 10 9 8 7 6 5 4 3 2\n"
    hand = [BridgeHand.new]
    Cards.new.new_deck.deal(hand)
    assert_equal(all_card_hand, hand.to_s)
  end

  def test_hcp
    north_hand = [ [:ace, :spades],     [:king, :spades],
                   [:queen, :spades],   [:jack, :spades] ]
    east_hand  = [ [:ace, :hearts],     [:king, :hearts],
                   [:queen, :hearts],   [:jack, :hearts] ]
    south_hand = [ [:ace, :clubs],      [:king, :clubs],
                   [:queen, :clubs],    [:jack, :clubs] ]
    west_hand  = [ [:ace, :diamonds],   [:king, :diamonds],
                   [:queen, :diamonds], [:jack, :diamonds] ]
    deal = BridgeDeal.new(:north => north_hand, :south => south_hand,
                          :west  => west_hand , :east  => east_hand)
    deal.hands.each { |hand| assert_equal(10, hand.hcp) }

    3.times do
      deal = BridgeDeal.new
      assert_equal(40, deal.hands.inject(0) { |pts,hand| pts + hand.hcp })
    end
  end

  def test_lenp
    hand = [BridgeHand.new]
    Cards.new.new_deck.deal(hand)
    assert_equal(4*9, hand[0].lenp) # 9 points from each suit for whole deck

    north_hand = [ [:ace,   :spades], [:king,  :spades],
                   [:queen, :spades], [:jack,  :spades],
                   [:ten,   :spades], [:nine,  :spades],
                   [:queen, :hearts], [:jack,  :hearts],
                   [:ten,   :hearts], [:nine,  :hearts],
                   [:eight, :hearts], [:seven, :diamonds],
                   [:two, :clubs] ]
    deal = BridgeDeal.new(:north => north_hand)
    assert_equal(3, deal.hands[BridgeDeal::INDEX[:north]].lenp)
  end
end

class TcBridgeDeal < Test::Unit::TestCase
  def test_instantiate
    deal = BridgeDeal.new
    assert_equal(4, deal.hands.length)
    deal.hands.each { |hand| assert_equal(13, hand.length) }
  end

  def test_instantiate_set_hands
    north_hand = [ [:ace, :spades], [:king, :spades], [:queen, :spades],
                  [:jack, :spades], [:ten, :spades], [:nine, :spades] ]
    deal = BridgeDeal.new(:north => north_hand)
    assert_equal(4, deal.hands.length)
    deal.hands.each { |hand| assert_equal(13, hand.length) }
    assert_match(/^#{Suit::SPADE}  A K Q J 10 9/,
                 deal.hands[BridgeDeal::INDEX[:north]].to_s)

    north_hand = [ [:ace, :spades]  , [:king, :spades]   ]
    east_hand  = [ [:ace, :hearts]  , [:king, :hearts]   ]
    south_hand = [ [:ace, :clubs]   , [:king, :clubs]    ]
    west_hand  = [ [:ace, :diamonds], [:king, :diamonds] ]
    deal = BridgeDeal.new(:north => north_hand, :south => south_hand,
                          :west  => west_hand , :east  => east_hand)
    assert_equal(4, deal.hands.length)
    deal.hands.each { |hand| assert_equal(13, hand.length) }
    assert_match(/^#{Suit::SPADE}  A K/,
                 deal.hands[BridgeDeal::INDEX[:north]].to_s)
    assert_match(/^#{Suit::HEART}  A K/,
                 deal.hands[BridgeDeal::INDEX[:east]].to_s)
    assert_match(/^#{Suit::CLUB}  A K/,
                 deal.hands[BridgeDeal::INDEX[:south]].to_s)
    assert_match(/^#{Suit::DIAMOND}  A K/,
                 deal.hands[BridgeDeal::INDEX[:west]].to_s)
  end

  def test_to_s
    deal_regex = []
    (BridgeDeal::NORTH..BridgeDeal::WEST).each_with_index do |n,i|
      deal_regex <<= ".*#{BridgeDeal::NAME[n]}.*\n" +
                     ".*#{Suit::SPADE}.*\n" +
                     ".*#{Suit::HEART}.*\n" +
                     ".*#{Suit::DIAMOND}.*\n" +
                     ".*#{Suit::CLUB}.*\n" +
                     ".*points.*"
    end
    10.times do
      deal = BridgeDeal.new.to_s
      deal_regex.each { |regex| assert_match(/#{regex}/, deal) }
    end
  end
end

class TcBid < Test::Unit::TestCase
  def test_validate
    assert_raise(ArgumentError) { Bid.validate(:sevencuckoos) }
    assert_equal(:fiveclub, Bid.validate(:fiveclub))
    assert_equal(:pass, Bid.validate(:pass))
  end

  def test_to_s
    assert_equal("1#{Bid::HEART}", Bid.to_s(:oneheart))
    assert_equal("Double", Bid.to_s(:double))
  end
end
