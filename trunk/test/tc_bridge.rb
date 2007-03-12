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

  def test_points
    hand = [BridgeHand.new]
    Cards.new.new_deck.deal(hand)
    assert_equal(4*9+40, hand[0].points)

    3.times do
      BridgeDeal.new.hands.each do |hand|
        assert_equal(hand.hcp + hand.lenp, hand.points)
      end
    end
  end
  
  def test_balanced
    north_hand = [ [:ace,   :spades],   [:king,  :spades],
                   [:queen, :spades],   [:jack,  :spades],
                   [:ten,   :spades],   [:nine,  :spades] ]
    south_hand = [ [:eight, :spades],   [:seven, :spades],
                   [:six,   :spades],   [:ace,   :hearts],
                   [:king,  :hearts],   [:queen, :hearts],
                   [:ace,   :diamonds], [:king,  :diamonds],
                   [:queen, :diamonds], [:ace,   :clubs],
                   [:king,  :clubs] ]
    3.times do
      deal = BridgeDeal.new(:north => north_hand, :south => south_hand)
      assert((not deal.hands[BridgeDeal::NORTH].balanced?))
      assert(deal.hands[BridgeDeal::SOUTH].balanced?)
    end
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

  def test_bad_set_hand
    north = :two
    assert_raise(ArgumentError) { BridgeDeal.new(:north => north) }

    north = [ :two, :spades ]
    assert_raise(ArgumentError) { BridgeDeal.new(:north => north) }

    north = [ [:two, :spades], [:two, :spades] ]
    assert_raise(ArgumentError) { BridgeDeal.new(:north => north) }

    north = [ [:twelve, :sticks] ]
    assert_raise(ArgumentError) { BridgeDeal.new(:north => north) }

    north = [ [:two, :spades] ]
    assert_raise(ArgumentError) { BridgeDeal.new(:north => north,
                                                 :south => north) }

    north = [ [:two, :spades] ]
    south = [ [:three, :spades] ]
    east  = [ [:four, :spades] ]
    west  = [ [:five, :spades] ]
    other = [ [:six, :spades] ]
    assert_raise(ArgumentError) { BridgeDeal.new(:north => north,
      :south => south, :east => east, :west => west, :other => other) }

    assert_raise(ArgumentError) { BridgeDeal.new(
      :south => south, :east => east, :west => west, :other => other) }

    north = [ [:two,   :spades],   [:six,   :spades],   [:seven, :spades],
              [:ten,   :spades],   [:nine,  :spades],   [:eight, :spades],
              [:seven, :hearts],   [:ace,   :hearts],   [:seven, :hearts],
              [:three, :hearts],   [:four,  :hearts],   [:five,  :clubs],
              [:two,   :clubs] ]
    assert_raise(ArgumentError) { BridgeDeal.new(:north => north) }

    north = [ [:two,   :spades],   [:three, :spades],   [:four,  :spades],
              [:five,  :spades],   [:six,   :spades],   [:seven, :spades],
              [:eight, :spades],   [:nine,  :spades],   [:ten,   :spades],
              [:jack,  :spades],   [:queen, :spades],   [:king,  :spades],
              [:ace,   :spades],   [:ace,   :hearts] ]
    assert_raise(ArgumentError) { BridgeDeal.new(:north => north) }
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

class TcBidder < Test::Unit::TestCase
  def test_bidding_opened
    assert((not Bidder.new(nil, []).bidding_opened?))
    assert((not Bidder.new(nil, [:pass]).bidding_opened?))
    assert((not Bidder.new(nil, [:pass]*3).bidding_opened?))
    assert(Bidder.new(nil, [:oneheart]).bidding_opened?)
    assert(Bidder.new(nil, [:oneheart,:pass,:pass]).bidding_opened?)
    assert(Bidder.new(nil, [:pass]*3+[:fiveclub]).bidding_opened?)
    assert(Bidder.new(nil, [:pass]*10+[:sevennotrump]).bidding_opened?)
  end

  def test_bid
    3.times { assert_nothing_raised(BiddingError, ArgumentError) do
      Bid.validate(Bidder.new(BridgeDeal.new.hands[0], []).bid)
    end }
  end
end

class TcBidding < Test::Unit::TestCase
  def test_3NT
    north = [ [:ace,   :spades],   [:king,  :spades],   [:queen, :spades],
              [:jack,  :spades],   [:ace,   :hearts],   [:king,  :hearts],
              [:queen, :hearts],   [:jack,  :hearts],   [:ace,   :diamonds],
              [:king,  :diamonds], [:eight, :diamonds], [:seven, :clubs],
              [:two,   :clubs] ]
    assert_equal("3NT", Bidding.new(BridgeDeal.new(:north => north),
                                    BridgeDeal::NORTH).next_bid)
  end

  def test_2NT
    north = [ [:ace,   :spades],   [:king,  :spades],   [:queen, :spades],
              [:jack,  :spades],   [:ace,   :hearts],   [:king,  :hearts],
              [:queen, :hearts],   [:jack,  :hearts],   [:two,   :diamonds],
              [:four,  :diamonds], [:eight, :diamonds], [:seven, :clubs],
              [:two,   :clubs] ]
    assert_equal("2NT", Bidding.new(BridgeDeal.new(:north => north),
                                    BridgeDeal::NORTH).next_bid)
  end

  def test_1NT
    north = [ [:ace,   :spades],   [:king,  :spades],   [:queen, :spades],
              [:jack,  :spades],   [:ace,   :hearts],   [:five,  :hearts],
              [:eight, :hearts],   [:jack,  :hearts],   [:two,   :diamonds],
              [:four,  :diamonds], [:eight, :diamonds], [:seven, :clubs],
              [:two,   :clubs] ]
    assert_equal("1NT", Bidding.new(BridgeDeal.new(:north => north),
                                    BridgeDeal::NORTH).next_bid)
  end

  def test_2C
    north = [ [:ace,   :spades],   [:king,  :spades],   [:queen, :spades],
              [:jack,  :spades],   [:ace,   :hearts],   [:king,  :hearts],
              [:queen, :hearts],   [:jack,  :hearts],   [:ace,   :diamonds],
              [:king,  :diamonds], [:eight, :diamonds], [:seven, :diamonds],
              [:two,   :diamonds] ]
    assert_equal("2#{Bid::CLUB}", Bidding.new(BridgeDeal.new(:north => north),
                                              BridgeDeal::NORTH).next_bid)
  end

  def test_5_5_major
    north = [ [:two,   :spades],   [:king,  :spades],   [:queen, :spades],
              [:jack,  :spades],   [:ten,   :spades],   [:king,  :hearts],
              [:queen, :hearts],   [:jack,  :hearts],   [:ten,   :hearts],
              [:two,   :hearts],   [:eight, :diamonds], [:seven, :diamonds],
              [:two,   :diamonds] ]
    assert_equal("1#{Bid::SPADE}", Bidding.new(BridgeDeal.new(:north => north),
                                               BridgeDeal::NORTH).next_bid)
  end

  def test_extreme_5_card_major
    north = [ [:ace,   :diamonds], [:king,  :diamonds], [:queen, :diamonds],
              [:ten,   :diamonds], [:ace,   :clubs],    [:king,  :clubs],
              [:queen, :clubs],    [:ten,  :clubs],     [:two,   :spades],
              [:three, :spades],   [:four, :spades],    [:five,  :spades],
              [:six,   :spades] ]
    assert_equal("1#{Bid::SPADE}", Bidding.new(
      BridgeDeal.new(:north => north), BridgeDeal::NORTH).next_bid)
  end

  def test_4_4_card_minor
    north = [ [:ace,   :diamonds], [:king,  :diamonds], [:queen, :diamonds],
              [:ten,   :diamonds], [:ace,   :clubs],    [:king,  :clubs],
              [:queen, :clubs],    [:ten,  :clubs],     [:two,   :spades],
              [:three, :spades],   [:four, :spades],    [:five,  :spades],
              [:two,   :hearts] ]
    assert_equal("1#{Bid::DIAMOND}", Bidding.new(
      BridgeDeal.new(:north => north), BridgeDeal::NORTH).next_bid)
  end

  def test_3_3_card_minor
    north = [ [:ace,   :diamonds], [:king,  :diamonds], [:queen, :diamonds],
              [:ten,   :spades],   [:ace,   :clubs],    [:king,  :clubs],
              [:queen, :clubs],    [:ten,  :hearts],    [:seven, :hearts],
              [:three, :spades],   [:four, :spades],    [:five,  :spades],
              [:two,   :hearts] ]
    assert_equal("1#{Bid::CLUB}", Bidding.new(
      BridgeDeal.new(:north => north), BridgeDeal::NORTH).next_bid)
  end

  def test_preempt
    north = [ [:two,   :spades],   [:king,  :spades],   [:queen, :spades],
              [:ten,   :spades],   [:nine,  :spades],   [:eight, :spades],
              [:seven, :spades],   [:ten,   :hearts],   [:seven, :hearts],
              [:three, :hearts],   [:four,  :hearts],   [:five,  :hearts],
              [:two,   :hearts] ]
    assert_equal("3#{Bid::SPADE}", Bidding.new(
      BridgeDeal.new(:north => north), BridgeDeal::NORTH).next_bid)
  end

  def test_weak_2
    north = [ [:two,   :spades],   [:six,   :spades],   [:seven, :spades],
              [:ten,   :spades],   [:nine,  :spades],   [:eight, :spades],
              [:seven, :hearts],   [:ace,   :hearts],   [:six,   :hearts],
              [:three, :hearts],   [:four,  :hearts],   [:five,  :clubs],
              [:two,   :clubs] ]
    assert_equal("2#{Bid::SPADE}", Bidding.new(
      BridgeDeal.new(:north => north), BridgeDeal::NORTH).next_bid)
  end

  def test_two_weak_2s
    north = [ [:two,   :spades],   [:six,   :spades],   [:seven, :spades],
              [:ten,   :spades],   [:nine,  :spades],   [:eight, :spades],
              [:seven, :hearts],   [:ace,   :hearts],   [:six,   :hearts],
              [:three, :hearts],   [:four,  :hearts],   [:five,  :hearts],
              [:two,   :clubs] ]
    assert_equal("2#{Bid::HEART}", Bidding.new(
      BridgeDeal.new(:north => north), BridgeDeal::NORTH).next_bid)
  end

  def test_weak_2_not_clubs
    north = [ [:two,   :clubs],   [:six,   :clubs],   [:seven, :clubs],
              [:ten,   :clubs],   [:nine,  :clubs],   [:eight, :clubs],
              [:seven, :hearts],   [:ace,   :hearts],   [:six,   :hearts],
              [:three, :hearts],   [:four,  :hearts],   [:five,  :spades],
              [:two,   :spades] ]
    assert_equal("Pass", Bidding.new(
      BridgeDeal.new(:north => north), BridgeDeal::NORTH).next_bid)
  end
end
