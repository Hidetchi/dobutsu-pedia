require '/usr/local/Dobutsupedia/app/models/concerns/board'

LOG_INTERVAL=200
MAX_CACHE=3000

hash = Hash.new 
sum = 0
n = 0
dup_cache = 0
dup_db = 0
mates = 0

board0 = Board.new
board0.initial
board0.normalize
#board0.test_position

hash[board0.to_bit] = true
Position.register(board0.to_bit, n)
sum += 1
bits = [board0.to_bit]

while (bits.length > 0)
  puts n.to_s + " " + bits.length.to_s + " " + sum.to_s
  n += 1
  bits_new = []
  i = 0
  bits.each do |bit|
    i += 1
    board = Board.new
    board.set_from_bit(bit)
    next_bits = board.next_boards
    if next_bits.length > 0
      next_bits.each do |next_bit|
        if hash[next_bit] == true
          dup_cache += 1
        else
          hash[next_bit] = true
          hash.shift if hash.length > MAX_CACHE
          if (Position.register(next_bit, n))
            bits_new.push(next_bit)
            sum += 1
            if (sum % LOG_INTERVAL == 0)
              puts sprintf("-> %d %d/%d duplicates:%d(cache)%d(db) %dmates", sum, i, bits.length, dup_cache, dup_db, mates)
              dup_cache = 0
              dup_db = 0
              mates = 0
            end
          else
            dup_db += 1
          end
        end
      end
    else
      mates += 1 
    # puts "MATE!"
    end
  end
  bits = bits_new.clone
end
