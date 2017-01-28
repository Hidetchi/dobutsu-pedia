class PositionsController < ApplicationController
  def show
    @board = Board.fromString(params[:str])
    render 'not_found' if !@board.id
  end

  def best
    bit = 0
    for i in 0..11 do
      bit = bit << 4
      bit += params[:str][i].hex
    end
    for i in 12..14 do
      bit = bit << 2
      bit += params[:str][i].hex
    end
    teban = params[:str][15] == "0"
    board = Board.new(bit, teban)
    @best_boards = []
    @best_boards.push(board)
    while (board = @best_boards.last.best_candidate)
      @best_boards.push(board)
    end
  end

  def search
    pars = params[:search]
    str = ""
    for i in 0..3 do
      for j in 0..2 do
        str += pars["cell_" + i.to_s + j.to_s]
      end
    end
    str += [pars[:hand_KI], pars[:hand_ZO], pars[:hand_HI], pars[:turn]].join
    redirect_to position_path(str)
  end
end
