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

require 'cards'
require 'bridge'

deal = BridgeDeal.new
turn = rand(4)
passes = -1

puts deal.to_s + "\n"
puts((0..3).inject('') { |s,i| s + BridgeDeal::NAME[(turn+i)%4].ljust(8) })

bidding = Bidding.new(deal, turn)

while passes < 3
  4.times do
    bid = bidding.next_bid
    print bid.ljust(8)
    if bid == "Pass"
      passes += 1
      break if passes > 2
    else
      passes = 0
    end
  end
  puts
end

__END__
while passes < 3
  passes += 1
  turn = (turn+1)%4
end
