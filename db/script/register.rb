TOTAL = 86848395;

file1 = File.open('db/script/allBitsSorted.dat')
file2 = File.open('db/script/winLoss.dat')

Rails.logger.level = 3

Position.transaction do
  for i in 1..TOTAL do
    bit = file1.readline
    num = file2.readline
    bit = bit.to_i
    num = num == "*" ? nil : num.to_i

    if num == nil
      ActiveRecord::Base.connection.execute("insert into positions (id, bit_id) values (#{i}, #{bit})")
    else
      ActiveRecord::Base.connection.execute("insert into positions (id, bit_id, num_end) values (#{i}, #{bit}, #{num})")
    end
    puts(i.to_s) if (i % 1000 == 0)
  end
end

file1.close
file2.close

