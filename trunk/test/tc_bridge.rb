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
    Cards.new.shuffle.deal(hand)
    hand[0].sort!
    Card.gen_all { |card| assert_equal(card, hand[0].top) }
  end

  def test_to_s
    all_card_hand =
      "#{Suit::SPADE}  A K Q J 10 9 8 7 6 5 4 3 2\n" +
      "#{Suit::HEART}  A K Q J 10 9 8 7 6 5 4 3 2\n" +
      "#{Suit::DIAMOND}  A K Q J 10 9 8 7 6 5 4 3 2\n" +
      "#{Suit::CLUB}  A K Q J 10 9 8 7 6 5 4 3 2\n"
    hand = [BridgeHand.new]
    Cards.new.deal(hand)
    assert_equal(all_card_hand, hand.to_s)
  end
end

class TcBridgeDeal < Test::Unit::TestCase
  def test_instantiate
    deal = BridgeDeal.new
    assert_equal(4, deal.hands.length)
    deal.hands.each { |hand| assert_equal(13, hand.length) }
  end

  def test_to_s
    deal_regex = (BridgeDeal::NORTH..BridgeDeal::WEST).inject('') do |s,n|
      "#{s}#{BridgeDeal::NAME[n]}\n" +
      "#{Suit::SPADE}.*\n" +
      "#{Suit::HEART}.*\n" +
      "#{Suit::DIAMOND}.*\n" +
      "#{Suit::CLUB}.*\n\n"
    end.strip
    10.times { assert_match(/#{deal_regex}/, BridgeDeal.new.to_s) }
  end
end
