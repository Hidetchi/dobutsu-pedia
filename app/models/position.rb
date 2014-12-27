class Position < ActiveRecord::Base
  validates_uniqueness_of :bit_id

  def self.register(bit, num_front, num_end = nil)
    position = Position.create(bit_id: bit, num_front: num_front, num_end: num_end)
    position.id
  end
end
