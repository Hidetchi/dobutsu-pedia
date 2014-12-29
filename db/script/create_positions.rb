require 'board'

LOG_INTERVAL=100
MAX_CACHE=10000000

t = Time.now

hash = Hash.new 
dup_cache = 0
dup_db = 0
mates = 0
sum = Position.count

if sum == 0
  board = Board.new
  board.initial
  board.normalize
  #board0.test_position

  bit = board.to_bit
#  hash[bit] = true
  Position.register(bit, 0)
  sum += 1
end

i = 1
while (i <= sum)
  positions = Position.where("id >= ? AND id <= ?", i, i+99999)

  Position.transaction do
    positions.each do |position|

      if position.flag
        puts sprintf("Passed id=%d as it is already evaluated.", i) if i % 1000 == 0
#        hash[position.bit_id] = true
        i += 1
        next
      end

      mate = false
      board = Board.new
      board.set_from_bit(position.bit_id)
      next_bits = board.next_bits_normalized
      if next_bits.length > 0
        next_bits.each do |next_bit|
          if hash[next_bit] == true
            dup_cache += 1
          else
#            hash[next_bit] = true
#            hash.shift if hash.length > MAX_CACHE
            if (Position.register(next_bit, position.num_front + 1))
              sum += 1
            else
              dup_db += 1
            end
          end
        end
      else
        mate = true
        mates += 1 
      end #if

      if mate
        ActiveRecord::Base.connection.execute("update positions set flag=1, num_end=0 where id=#{i}")
      else
        ActiveRecord::Base.connection.execute("update positions set flag=1 where id=#{i}")
      end
      i += 1
      if (i % LOG_INTERVAL == 0)
        puts sprintf("#%d, %d/%d, dups:%d/%d, mat:%d, %ds", position.num_front, i, sum, dup_cache, dup_db, mates, Time.now-t)
        dup_cache = 0
        dup_db = 0
        mates = 0
      end
    end #positions.each
  end #Position.transaction
end #while
