import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.FileReader;
import java.io.BufferedReader;

class MakeBestMove{
  static final int TOTAL = 86848395;

  public static void main(String[] args){
    long[] bits = new long[TOTAL];
    short[] results = new short[TOTAL];
    int[] best = new int[TOTAL];

    try {
      BufferedReader br = new BufferedReader(new FileReader(new File("allBitsSorted.dat")));
      String line;
      int i = 0;
      System.out.println("+ = 2%");
      while((line = br.readLine()) != null) {
        i += 1;
        long bit = Long.parseLong(line);
        bits[i-1] = bit;
        if (i % (TOTAL/50) == 0) {
           System.out.printf("+");
        }
      }
      System.out.println();
      System.out.println(i == TOTAL ? "Bits File read OK!" : "Bits File read failed!");
      br.close();

      br = new BufferedReader(new FileReader(new File("winLoss.dat")));
      i = 0;
      System.out.println("+ = 2%");
      while((line = br.readLine()) != null) {
        i += 1;
        if (line.equals("*")) {
          results[i-1] = 1000;
        } else {
          results[i-1] = Short.parseShort(line);
        }
        if (i % (TOTAL/50) == 0) {
           System.out.printf("+");
        }
      }
      System.out.println();
      System.out.println(i == TOTAL ? "WinLoss File read OK!" : "WinLoss File read failed!");
      br.close();
    } catch(Exception e) {
      e.printStackTrace();
    }

    for (int i=0; i<TOTAL; i++) {
      if (results[i] == 1000 || results[i] == 0) {
        best[i] = 0;
      } else {
        Board board = new Board(bits[i], true);
        Object[] nextBits = board.nextBitsNormalized();
        for (Object nextBit : nextBits) {
          int j = Arrays.binarySearch(bits, (long)nextBit);
          if (Math.abs(results[j]) == Math.abs(results[i]) - 1) {
            boolean isCheckMate = false;
            if (results[j]==0) {
              Board mated_board = new Board((long)nextBit, true);
              isCheckMate = mated_board.isCheck();
            }
            if (!(best[i]>0) || results[j]<0 || isCheckMate) best[i] = j + 1;
            if (results[j] < 0 || isCheckMate) break;
          }
        }
      }

      if (i % (TOTAL/50) == 0) {
         System.out.print("+");
      }
    }
    System.out.println();
    System.out.println("Analysis Done. Writing results...");

    try {
      PrintWriter pw = new PrintWriter(new OutputStreamWriter(new FileOutputStream(new File("bestMove.dat"))));
      for (int i=0;i<TOTAL;i++) {
        pw.println(best[i]);
        if (i % (TOTAL/50) == 0) {
           System.out.print("+");
        }
      }
      pw.close();
      
    } catch(Exception e) {
      e.printStackTrace();
    }
  }
}
