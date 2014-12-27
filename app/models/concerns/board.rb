class Board
  NAMES = [" * ", "+LI", "-LI", "+KI", "-KI", "+ZO", "-ZO", "+HI", "-HI", "+NI", "-NI"]
  REVERSE = [0, 2, 1, 4, 3, 6, 5, 8, 7, 10, 9]
  #  1    2    3    4    5    6    7    8    9   10
  # +LI, -LI, +KI, -KI, +ZO, -ZO, +HI, -HI, +NI, -NI
  def initialize
    @my_hands = [0, 0, 0] #KI,ZO,HI
    @array = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]] 
    @teban = nil # black => true, white => false
  end

  def initial
    @array = [[4, 2, 6], [0, 8, 0], [0, 7, 0], [5, 1, 3]]
    @teban = true
  end
  
  def test_position
    @array = [[2, 0, 0], [0, 0, 0], [0, 1, 0], [3, 3, 0]]
    @my_hands = [0, 1, 1]
    @teban = true
  end
  
  def deep_copy
    return Marshal.load(Marshal.dump(self))
  end

  def normalize
    if (@teban == false)
      arr = Marshal.load(Marshal.dump(@array))
      for i in 0..3 do
        for j in 0..2 do
          @array[i][j] = REVERSE[arr[3 - i][2 - j]]
        end
      end
      @my_hands = his_hands
      @teban = true
    end
    mirror = false
    for i in 0..3 do
      if (@array[i][0] == @array[i][2])
        next
      else
        mirror = true if (@array[i][0] > @array[i][2])
        break
      end
    end
    if mirror
      for i in 0..3 do
        tmp = @array[i][0]
        @array[i][0] = @array[i][2]
        @array[i][2] = tmp
      end
    end
  end

  def to_s
    str = @teban ? "         " : "=        "
    hands = his_hands
    for i in 0..2 do
      hands[i].times do
        str += NAMES[4 + 2 * i]
      end
    end
    str += "\n"
    for i in 0..3 do
      for j in 0..2 do
        str += NAMES[@array[i][j]]
      end
      str += "\n"
    end
    str += @teban ? "=        " : "         "
    hands = @my_hands
    for i in 0..2 do
      hands[i].times do
        str += NAMES[3 + 2 * i]
      end
    end
    str
  end

  def to_bit
    bit = 0
    for i in 0..3 do
      for j in 0..2 do
        bit = bit << 4
        bit += @array[i][j]
      end
    end
    for i in 0..2 do
      bit = bit << 2
      bit += @my_hands[i]
    end
    bit
  end

  def set_from_bit(bit)
    for i in 0..2 do
      @my_hands[2 - i] = bit & 3
      bit = bit >> 2
    end
    for i in 0..3 do
      for j in 0..2 do
        @array[3 - i][2 - j] = bit & 15
        bit = bit >> 4
      end
    end
    @teban = true
  end
  
  def his_hands
    hands = [2, 2, 2]
    for i in 0..3 do
      for j in 0..2 do
        if (@array[i][j] == 3 || @array[i][j] ==4)
          hands[0] -= 1
        elsif (@array[i][j] == 5 || @array[i][j] ==6)
          hands[1] -= 1
        elsif (@array[i][j] >= 7)
          hands[2] -= 1
        end
      end
    end
    for i in 0..2 do
      hands[i] -= @my_hands[i]
    end
    hands
  end
  
  def moveable_grids(n)
    grids = []
    if [1, 2, 5, 6, 9].include?(n)
      grids.push([-1, -1])
      grids.push([-1,  1])
    end
    grids.push([-1,  0]) if [1, 2, 3, 4, 7, 9, 10].include?(n)
    if [1, 2, 3, 4, 9, 10].include?(n)
      grids.push([ 0, -1]) 
      grids.push([ 0,  1])
    end
    if [1, 2, 5, 6, 10].include?(n)
      grids.push([ 1, -1]) 
      grids.push([ 1,  1])
    end
    grids.push([ 1,  0]) if [1, 2, 3, 4, 8, 9, 10].include?(n)
    grids
  end

  def own_piece?(i, j, teban)
    NAMES[@array[i][j]][0] == (teban ? "+" : "-")
  end
  
  def can_move_any?(x, y, teban)
    for i in (x-1)..(x+1) do
      next if i < 0
      next if i > 3
      for j in (y-1)..(y+1) do
        next if j < 0
        next if j > 2
        next if (i == x && j == y)
        next if !own_piece?(i, j, teban)
        move_vector = [x - i, y - j]
        return true if moveable_grids(@array[i][j]).include?(move_vector)
      end
    end
    false
  end

  def winning?
    # Whether the opponent's Lion can be captured in the next move
    for i in 0..3 do
      for j in 0..2 do
        # searching for opponent's Lion
        if @array[i][j] == (@teban ? 2 : 1)
          return true if can_move_any?(i, j, @teban)
          break
        end
      end
    end
    # Whether the Lion can try in the next move
    i = @teban ? 1 : 2
    x = @teban ? 0 : 3
    for j in 0..2 do
      # searching for own Lion if he is in the 2nd row
      if @array[i][j] == (@teban ? 1 : 2)
        for y in (j-1)..(j+1)
          next if y < 0
          next if y > 2
          if !own_piece?(x, y, @teban)
            return true if !can_move_any?(x, y, !@teban)
          end
        end
        break
      end
    end
    false
  end

  def next_boards
    boards = []
    for i in 0..3 do
      for j in 0..2 do
        next unless own_piece?(i, j, @teban)
        moveable_grids(@array[i][j]).each do |move_vector|
          x = i + move_vector[0]
          next if x < 0
          next if x > 3
          y = j + move_vector[1]
          next if y < 0
          next if y > 2
          next if own_piece?(x, y, @teban)
          next_board = deep_copy
          next_board.move(i, j, x, y)
          next_board.normalize
          boards.push(next_board.to_bit) unless next_board.winning?
        end
      end
    end
    hands = @teban ? @my_hands : his_hands
    for i in 0..2 do
      next if hands[i] < 1
      for x in 0..3 do
        for y in 0..2 do
          if (@array[x][y] == 0)
            next_board = deep_copy
            next_board.drop(i, x, y)
            next_board.normalize
            boards.push(next_board.to_bit) unless next_board.winning?
          end
        end
      end
    end
    boards
  end

  def move(i, j, x, y)
    if (@teban)
      if (@array[x][y] == 4)
        @my_hands[0] += 1
      elsif (@array[x][y] == 6)
        @my_hands[1] += 1
      elsif (@array[x][y] >= 8)
        @my_hands[2] += 1
      end
    end
    @array[x][y] = @array[i][j]
    @array[i][j] = 0
    @teban = !@teban
  end

  def drop(i, x, y)
    @my_hands[i] -= 1 if @teban
    if @teban
      @array[x][y] = [3, 5, 7][i]
    else
      @array[x][y] = [4, 6, 8][i]
    end
    @teban = !@teban
  end

  def position_valid?
    return nil unless (handicap_id)
    for x in 1..9 do
      for y in 1..9 do
        next unless (@array[x][y])
        return nil unless (@array[x][y].room_of_head?(x, y, @array[x][y].to_s[1..2]))
      end
    end
    return nil if (checkmated?(!@teban))
    true
  end
  
  def num_candidates(x1, y1, name)
    num = 0
    for x in 1..9 do
      for y in 1..9 do
        num += 1 if (@array[x][y] && @array[x][y].to_s == name && @array[x][y].movable_grids.include?([x1, y1]))
      end
    end
    return num
  end

  def do_moves_str(csa)
    new_board = deep_copy
    ret = []
    rs = csa.gsub %r{[\+\-]\d{4}\w{2}} do |s|
           ret << s
           ""
         end
    ret.each do |move|
      new_board.handle_one_move(move)
    end
    return new_board
  end

end
