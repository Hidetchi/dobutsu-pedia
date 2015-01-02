class ShowPosition{

  public static void main(String[] args){
    Board board = new Board(Long.parseLong(args[0]), true);
    System.out.println(board.toString());
  }
}
