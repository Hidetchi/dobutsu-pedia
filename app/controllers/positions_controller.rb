class PositionsController < ApplicationController
  def show
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
    @board = Board.new(bit, teban)
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
end
