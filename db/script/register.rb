TOTAL = 86848395;

file1 = File.open('allBitsSorted.dat')
file2 = File.open('winLoss.dat')
file3 = File.open('bestMove.dat')

Rails.logger.level = 3

positions = []
#ActiveRecord::Base.transaction do

  for i in 1..TOTAL do
    bit = file1.readline.chomp
    num = file2.readline.chomp
    best = file3.readline.chomp
    bit = bit.to_i
    num = num == "*" ? nil : num.to_i
    best = best == "0" ? nil : best.to_i

#   ActiveRecord::Base.connection.execute("insert into positions (id, bit_id, num_end, best_id) values (#{i}, #{bit}, #{num}, #{best})")
    positions << Position.new(id: i, bit_id: bit, num_end: num, best_id: best)

    if (i % 100000 == 0 || i == TOTAL)
      Position.import positions, :validate => false
      positions = []
      puts i
    end
  end

#end

file1.close
file2.close
file3.close

