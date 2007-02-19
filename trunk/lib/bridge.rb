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

require 'cards'

class BridgeHand < Hand
  def sort!
    @cards.sort!
  end

  def to_s
    Rank.ordering = Rank::DESCEND
    Suit.ordering = Suit::DESCEND
    sort!
    str = ''
    Suit.gen_all do |suit|
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

  NORTH = 0
  EAST = 1
  SOUTH = 2
  WEST = 3

  NAME = %w{ North East South West }

  def initialize
    @hands = []
    4.times { @hands <<= BridgeHand.new }
    Cards.new.shuffle.deal(@hands)
  end

  def to_s
    (NORTH..WEST).inject('') { |s,n| "#{s}#{NAME[n]}\n#{@hands[n]}\n" }.strip
  end
end
