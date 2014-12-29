class Position < ActiveRecord::Base
  validates_uniqueness_of :bit_id

  def self.register(bit, num_front, num_end = nil)
    positions = Position.find_by_sql(['select id from positions where bit_id = ? limit 1', bit])
    if positions.length > 0
      return false
    else
      ActiveRecord::Base.connection.execute("insert into positions (bit_id, num_front) values (#{bit}, #{num_front})")
      return true
    end
  end
end
