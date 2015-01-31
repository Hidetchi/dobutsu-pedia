class Board
  NAMES = [" * ", "+LI", "-LI", "+KI", "-KI", "+ZO", "-ZO", "+HI", "-HI", "+NI", "-NI"]
  REVERSE = [0, 2, 1, 4, 3, 6, 5, 8, 7, 10, 9]
  NAMES_JA = ["ライオン", "キリン", "ゾウ", "ひよこ", "ニワトリ"]
  #  1    2    3    4    5    6    7    8    9   10
  # +LI, -LI, +KI, -KI, +ZO, -ZO, +HI, -HI, +NI, -NI

  attr_reader :id, :num_end, :teban

  def initialize(bit=4670862863189184, teban=true, loadDB=true)
    @array = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]] 
    @my_hands = [0, 0, 0] #KI,ZO,HI
    @teban = teban

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

    loadPosition if loadDB
  end

  def loadPosition(position = nil)
    position = Position.find_by(bit_id: normalized_bit) if !position
    @id = position.id
    @num_end = position.num_end
    @best_id = position.best_id
  end

  def normalized_bit
    if @teban
      array = @array
      hands = @my_hands
    else
      array = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]] 
      for i in 0..3 do
        for j in 0..2 do
          array[i][j] = REVERSE[@array[3 - i][2 - j]]
        end
      end
      hands = his_hands
    end
    mirror = false
    for i in 0..3 do
      if (array[i][0] == array[i][2])
        next
      else
        mirror = true if (array[i][0] > array[i][2])
        break
      end
    end

    bit = 0
    for i in 0..3 do
      for j in 0..2 do
        bit = bit << 4
        bit += array[i][mirror ? 2 - j : j]
      end
    end
    for i in 0..2 do
      bit = bit << 2
      bit += hands[i]
    end
    bit
  end

  def deep_copy
    return Marshal.load(Marshal.dump(self))
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

  def to_str
    str = ""
    for i in 0..3 do
      for j in 0..2 do
        str += @array[i][j].to_s(16)
      end
    end
    for i in 0..2 do
      str += @my_hands[i].to_s(16)
    end
    str += @teban ? "0" : "1"
    str
  end

  def toHTML
    html = "<center><div style='height:50px;'>"
    hands = his_hands
    for i in 0..2 do
      hands[i].times {html += imageTag(4 + 2 * i)}
    end
    html += "</div><table class='board'>"
    for i in 0..3 do
      html += "<tr>"
      for j in 0..2 do
        html += "<td>" + imageTag(@array[i][j])
      end
    end
    html += "</table><div style='height:50px;'>"
    for i in 0..2 do
      @my_hands[i].times {html += imageTag(3 + 2 * i)}
    end
    html += "</div></center>"
  end
  
  def to_conclusion(teban = @teban)
    player = teban ? "先手" : "後手"
    if (@num_end == nil)
      return "引き分け"
    elsif (@num_end % 2 == 0)
      return player + (teban == @teban ? "負け" : "勝ち")
    else
      return player + (teban == @teban ? "勝ち" : "負け")
    end
  end

  def to_description
    @num_end
    if (@num_end == nil)
      return ""
    elsif (@num_end == 0)
      return "●詰み"
    elsif (@num_end % 2 == 0)
      return "即詰み (あと" + (-@num_end).to_s + "手)" if (@num_end < 0)
      return "あと" + @num_end.to_s + "手"
    else
      return "★" + (-@num_end).to_s + "手詰" if (@num_end < 0)
      return "あと" + @num_end.to_s + "手"
    end
  end

  def evaluation(teban = @teban)
    if (@num_end == nil)
      eval = 0
    elsif (@num_end % 2 == 0)
      eval = 1000 - 2 * @num_end.abs + (@num_end < 0 ? 1 : 0) + ((@num_end == 0 && check?) ? 1 : 0)
    else
      eval = -1000 + 2 * @num_end.abs + (@num_end > 0 ? 1 : 0)
    end
    teban == @teban ? -eval : eval
  end

  def eval_color(teban = @teban)
    eval = evaluation(teban)
    if (eval > 0)
      "win"
    elsif (eval < 0)
      "loss"
    else
      "draw"
    end
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

  def check?
    @teban = !@teban
    is_check = winning?
    @teban = !@teban
    is_check
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
          if ((@array[i][j] == 7 && i == 1) || (@array[i][j] == 8 && i == 2))
            next_board = deep_copy
            if (next_board.move(i, j, x, y, true))
              boards.push(next_board)
            end
          end
          next_board = deep_copy
          if (next_board.move(i, j, x, y))
            boards.push(next_board)
          end
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
            if (next_board.drop(i, x, y))
              boards.push(next_board)
            end
          end
        end
      end
    end
    positions = Position.where(bit_id: boards.map(&:normalized_bit))
    boards.each do |board|
      positions.each do |position|
        if position.bit_id == board.normalized_bit
          board.loadPosition(position)
          break
        end
      end
    end
    boards.sort_by{|board| board.evaluation}
  end

  def best_candidate
    return nil if (@num_end == nil || @num_end == 0)
    position = Position.find(@best_id)
    best_bit = position.bit_id
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
          if (next_board.move(i, j, x, y))
            if (next_board.normalized_bit == best_bit)
              next_board.loadPosition(position)
              return next_board
            end
          end
          if ((@array[i][j] == 7 && i == 1) || (@array[i][j] == 8 && i == 2))
            next_board = deep_copy
            if (next_board.move(i, j, x, y, true))
              if (next_board.normalized_bit == best_bit)
                next_board.loadPosition(position)
                return next_board
              end
            end
          end
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
            if (next_board.drop(i, x, y))
              if (next_board.normalized_bit == best_bit)
                next_board.loadPosition(position)
                return next_board
              end
            end
          end
        end
      end
    end
    return nil
  end

  def move(i, j, x, y, promote = false)
    if (@teban)
      if (@array[x][y] == 4)
        @my_hands[0] += 1
      elsif (@array[x][y] == 6)
        @my_hands[1] += 1
      elsif (@array[x][y] >= 8)
        @my_hands[2] += 1
      end
    end
    @array[x][y] = @array[i][j] + (promote ? 2 : 0)
    @array[i][j] = 0
    @teban = !@teban
    !winning?
  end

  def drop(i, x, y)
    @my_hands[i] -= 1 if @teban
    if @teban
      @array[x][y] = [3, 5, 7][i]
    else
      @array[x][y] = [4, 6, 8][i]
    end
    @teban = !@teban
    !winning?
  end

  def to_move(board)
    str = @teban ? "▲" : "△"
    for i in 0..3 do
      for j in 0..2 do
        type = board.getPiece(i,j)
        if (type != 0 && type != @array[i][j])
          str += ["A", "B", "C"][j] + (i+1).to_s + NAMES_JA[(type-1)/2]
          break
        end
      end
    end
    str
  end

  def getPiece(x,y)
    @array[x][y]
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

  private
  def imageTag(type)
    type == 0 ? "" : "<img src='/assets/" + type.to_s + ".png'>"
  end
  
end
