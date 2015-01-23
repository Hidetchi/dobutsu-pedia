import java.util.List;
import java.util.ArrayList;

class Board {
  private static final String[] NAMES = {" * ", "+LI", "-LI", "+KI", "-KI", "+ZO", "-ZO", "+HI", "-HI", "+NI", "-NI"};
  private static final byte[] REVERSE = {0, 2, 1, 4, 3, 6, 5, 8, 7, 10, 9};
  private byte[][] _ban;
  private byte[] _my_hands;
  private boolean _teban = true;

  public Board(long bit, boolean teban) {
    _ban = new byte[4][3];
    _my_hands = new byte[3];
    for (byte i=0; i<=2; i++) {
      _my_hands[2 - i] = (byte)(bit & 3);
      bit = bit >> 2;
    }
    for (byte i=0; i<=3; i++) {
      for (byte j=0; j<=2; j++) {
        _ban[3 - i][2 - j] = (byte)(bit & 15);
        bit = bit >> 4;
      }
    }
    _teban = teban;
  }

  public String toString() {
    String str = _teban ? "         " : "=        ";
    byte[] hands = _his_hands();
    for (byte i=0; i<=2; i++) {
      for (byte j=1; j<=hands[i]; j++) {
        str += NAMES[4 + 2 * i];
      }
    }
    str += "\n";
    for (byte i=0; i<=3; i++) {
      for (byte j=0; j<=2; j++) {
        str += NAMES[_ban[i][j]];
      }
      str += "\n";
    }
    str += _teban ? "=        " : "         ";
    for (byte i=0; i<=2; i++) {
      for (byte j=1; j<=_my_hands[i]; j++) {
        str += NAMES[3 + 2 * i];
      }
    }
    return str;
  }

  public long toBit(boolean normalize) {
    byte[][] ban;
    byte[] hands;
    if (_teban || !normalize) {
      ban = _ban;
      hands = _my_hands;
    } else {
      ban = new byte[4][3];
      hands = new byte[3];
      for (byte i=0; i<=3; i++) {
        for (byte j=0; j<=2; j++) {
          ban[i][j] = REVERSE[_ban[3 - i][2 - j]];
        }
      }
      hands = _his_hands();
    }
    boolean mirror = false;
    if (normalize) {
      for (byte i=0; i<=3; i++) {
        if (ban[i][0] == ban[i][2]) {
          continue;
        } else {
          if (ban[i][0] > ban[i][2]) mirror = true;
          break;
        }
      }
    }
    long bit = 0;
    for (byte i=0; i<=3; i++) {
      for (byte j=0; j<=2; j++) {
        bit = bit << 4;
        bit += ban[i][mirror ? (2-j) : j];
      }
    }
    for (byte i=0; i<=2; i++) {
      bit = bit << 2;
      bit += hands[i];
    }
    return bit;
  }

  public Board deepCopy() {
    return new Board(toBit(false), _teban);
  }

  private byte[] _his_hands() {
    byte[] hands = {2, 2, 2};
    for (byte i=0; i<=3; i++) {
      for (byte j=0; j<=2; j++) {
        if (_ban[i][j] == 3 || _ban[i][j] == 4) {
          hands[0] -= 1;
        } else if (_ban[i][j] == 5 || _ban[i][j] == 6) {
          hands[1] -= 1;
        } else if (_ban[i][j] >= 7) {
          hands[2] -= 1;
        }
      }
    }
    for (byte i=0; i<=2; i++) {
      hands[i] -= _my_hands[i];
    }
    return hands;
  }

  private boolean _is_own_piece(int i, int j, boolean teban) {
    return NAMES[_ban[i][j]].substring(0,1).equals(teban ? "+" : "-");
  }
  
  private boolean _can_move(byte piece, int vx, int vy) {
    if (piece == 1 || piece == 2) {
      return true;
    } else if (piece == 3 || piece == 4) {
      if (vx == 0 || vy == 0) return true;
      else return false;
    } else if (piece == 5 || piece == 6) {
      if (vx != 0 && vy != 0) return true;
      else return false;
    } else if (piece == 7) {
      if (vx == -1 && vy == 0) return true;
      else return false;
    } else if (piece == 8) {
      if (vx == 1 && vy == 0) return true;
      else return false;
    } else if (piece == 9) {
      if (vx == 1 && vy != 0) return false;
      else return true;
    } else if (piece == 10) {
      if (vx == -1 && vy != 0) return false;
      else return true;
    } else {
      return false;
    }
  }

  private boolean _can_move_any(int x, int y, boolean teban) {
    for (int i=x-1; i<=x+1; i++) {
      if (i<0) continue;
      if (i>3) continue;
      for (int j=y-1; j<=y+1; j++) {
        if (j<0) continue;
        if (j>2) continue;
        if (i ==x && j == y) continue;
        if (!_is_own_piece(i, j, teban)) continue;
        if (_can_move(_ban[i][j], x-i, y-j)) return true;
      }
    }
    return false;
  }

  public void move(int i, int j, int x, int y, boolean promote) {
    if (_teban) {
      if (_ban[x][y] == 4) {
        _my_hands[0] += 1;
      } else if (_ban[x][y] == 6) {
        _my_hands[1] += 1;
      } else if (_ban[x][y] >= 8) {
        _my_hands[2] += 1;
      }
    }
    _ban[x][y] = (byte)(_ban[i][j] + (promote ? 2 : 0));
    _ban[i][j] = 0;
    _teban = !_teban;
  }

  public void drop(int i, int x, int y) {
    if (_teban) {
      _my_hands[i] -= 1;
      _ban[x][y] = (byte)(2*i+3);
    } else {
      _ban[x][y] = (byte)(2*i+4);
    }
    _teban = !_teban;
  }

  protected boolean winning() {
    // Whether the opponent's Lion can be captured in the next move
    for (byte i=0; i<=3; i++) {
      for (byte j=0; j<=2; j++) {
        // searching for opponent's Lion
        if (_ban[i][j] == (_teban ? 2 : 1)) {
          if (_can_move_any(i, j, _teban)) return true;
          break;
        }
      }
    }
    // Whether the Lion can try in the next move
    int i = _teban ? 1 : 2;
    int x = _teban ? 0 : 3;
    for (int j=0; j<=2; j++) {
      // searching for own Lion if he is in the 2nd row
      if (_ban[i][j] == (_teban ? 1 : 2)) {
        for (int y = j-1; y <= j+1; y++) {
          if (y<0) continue;
          if (y>2) continue;
          if (!_is_own_piece(x, y, _teban)) {
            if (!_can_move_any(x, y, !_teban)) return true;
          }
        }
        break;
      }
    }
    return false;
  }

  public boolean isCheck() {
    _teban = !_teban;
    boolean check = winning();
    _teban = !_teban;
    return check;
  }

  public Object[] nextBitsNormalized() {
    List<Long> bits = new ArrayList<Long>();
    Board next_board;
    for (byte i=0; i<=3; i++) {
      for (byte j=0; j<=2; j++) {
        if (!_is_own_piece(i, j, _teban)) continue;
        for (int x=i-1; x<=i+1; x++) {
          for (int y=j-1; y<=j+1; y++) {
            if (x<0) continue;
            if (x>3) continue;
            if (y<0) continue;
            if (y>2) continue;
            if (_is_own_piece(x, y, _teban)) continue;
            if (_can_move(_ban[i][j], x-i, y-j)) {
              if ((_ban[i][j] == 7 && i == 1) || (_ban[i][j] == 8 && i == 2)) {
                next_board = deepCopy();
                next_board.move(i, j, x, y, true);
                if (!next_board.winning()) bits.add(next_board.toBit(true));
              }
              next_board = deepCopy();
              next_board.move(i, j, x, y, false);
              if (!next_board.winning()) bits.add(next_board.toBit(true));
            }
          }
        }
      }
    }
    byte[] hands;
    hands = _teban ? _my_hands : _his_hands();
    for (byte i=0; i<=2; i++) {
      if (hands[i] < 1) continue;
      for (byte x=0; x<=3; x++) {
        for (byte y=0; y<=2; y++) {
          if (_ban[x][y] == 0) {
            next_board = deepCopy();
            next_board.drop(i, x, y);
            if (!next_board.winning()) bits.add(next_board.toBit(true));
          }
        }
      }
    }
    return bits.toArray();
  }

  public void test() {
    _ban[3][0] = 0;
    _ban[3][2] = 0;
    _my_hands[0]=1;
  }
}
