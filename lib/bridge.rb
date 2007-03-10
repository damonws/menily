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

class BridgeError < StandardError
end

class BridgeHand < Cards
  def sort!
    @cards.sort!
  end

  def to_s
    Rank.ordering = Rank::DESCEND
    Suit.ordering = Suit::DESCEND
    sort!
    Suit.to_a.inject('') do |str,suit|
      str + suit(suit).inject("#{suit} ") {|s,card| s + " #{card.rank}"}+"\n"
    end
  end

  def hcp
    @cards.inject(0) do |pts,card|
      pts + case card.rank
            when Rank.get(:ace):   4
            when Rank.get(:king):  3
            when Rank.get(:queen): 2
            when Rank.get(:jack):  1
            else 0
            end
    end
  end

  def lenp
    Suit.to_a.inject(0) { |pts,suit| pts + [0, suit(suit).length - 4].max } 
  end

  def points
    hcp + lenp
  end
end

class BridgeDeal
  attr_reader :hands

  NORTH = 0
  EAST = 1
  SOUTH = 2
  WEST = 3
  INDEX = { :north => NORTH, :east => EAST, :south => SOUTH, :west => WEST }
  NAME = %w{ North East South West }

  def initialize(initial_deal = nil)
    @hands = []
    4.times { @hands <<= BridgeHand.new }
    deck = Cards.new.new_deck

    if initial_deal
      raise BridgeError.new("too many hands") if initial_deal.length > 4
      initial_deal.each do |seat,cards|
        raise BridgeError.new("too many cards for #{seat}") if cards.length > 13
        cards.each do |card_arr|
          card = Card.get(card_arr[0], card_arr[1])
          @hands[INDEX[seat]].add(card)
          deck.remove(card)
        end
      end
    end

    deck.shuffle.deal_even(@hands)
  end

  def to_s
    #(NORTH..WEST).inject('') { |s,n| "#{s}#{NAME[n]}\n#{@hands[n]}\n" }.strip
    str = Suit.to_a.inject(' '*20 + "#{NAME[NORTH]}\n") do |s,suit|
      s + hands[NORTH].suit(suit).inject(' '*20 + "#{suit} ") do |ss,card|
        ss + " #{card.rank}"
      end + "\n"
    end
    str += ' '*20 + "#{hands[NORTH].points} points\n"

    str += NAME[WEST] + ' '*(40-NAME[WEST].length) + NAME[EAST] + "\n"
    str += Suit.to_a.inject('') do |s,suit|
      w = hands[WEST].suit(suit).inject("#{suit} ") do |ss,card|
        ss + " #{card.rank}"
      end
      e = hands[EAST].suit(suit).inject("#{suit} ") do |ss,card|
        ss + " #{card.rank}"
      end
      s + w + ' '*(40-w.length) + e + "\n"
    end
    w = "#{hands[WEST].points} points"
    e = "#{hands[EAST].points} points"
    str += w + ' '*(40-w.length) + e + "\n"

    str += Suit.to_a.inject(' '*20 + "#{NAME[SOUTH]}\n") do |s,suit|
      s + hands[SOUTH].suit(suit).inject(' '*20 + "#{suit} ") do |ss,card|
        ss + " #{card.rank}"
      end + "\n"
    end
    str += ' '*20 + "#{hands[SOUTH].points} points\n"
  end
end
