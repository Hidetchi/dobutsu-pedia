TOTAL = 86848395;

file1 = File.open('db/script/allBitsSorted.dat')
file2 = File.open('db/script/winLoss.dat')
file3 = File.open('db/script/bestMove.dat')

Rails.logger.level = 3

ActiveRecord::Base.transaction do
  for i in 1..TOTAL do
    bit = file1.readline.chomp
    num = file2.readline.chomp
    best = file3.readline.chomp
    bit = bit.to_i
    num = num == "*" ? "NULL" : num.to_i
    best = best == "0" ? "NULL" : best.to_i

    ActiveRecord::Base.connection.execute("insert into positions (id, bit_id, num_end, best_id) values (#{i}, #{bit}, #{num}, #{best})")

    puts(i.to_s) if (i % 10000 == 0)
  end
end

file1.close
file2.close
file3.close

