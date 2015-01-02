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

class MakeWinLoss{
  static final int TOTAL = 86848395;

  public static void main(String[] args){
    long[] bits = new long[TOTAL];
    short[] results = new short[TOTAL];

    try {

      BufferedReader br = new BufferedReader(new FileReader(new File("allBitsSorted.dat")));

      String line;
      int i = 0;

      System.out.println("+ = 2%");
      while((line = br.readLine()) != null) {
        i += 1;
        long bit = Long.parseLong(line);
        bits[i-1] = bit;
        results[i-1] = 1000;
        if (i % (TOTAL/50) == 0) {
           System.out.printf("+");
        }
      }
      System.out.println();
      System.out.println(i == TOTAL ? "File read OK!" : "File read failed!");
      br.close();
    } catch(Exception e) {
      e.printStackTrace();
    }

    short n = -1;
    int sum = 0;
    int remain = 0;
    do {
      n += 1;
      sum = 0;
      remain = 0;
      System.out.printf("Generating results for #%d\n", n);
      for (int i=0; i<TOTAL; i++) {
        if (results[i] == 1000) {
          Board board = new Board(bits[i], true);
          Object[] nextBits = board.nextBitsNormalized();
          if (n > 0) {
            if (n % 2 != 0) {
              boolean concluded = false;
              for (Object nextBit : nextBits) {
                short result = results[Arrays.binarySearch(bits, (long)nextBit)];
                if (result != 1000 && result % 2 == 0) {
                  results[i] = (short)(result <= 0 ? -n : n);
                  concluded = true;
                  sum += 1;
                  break;
                }
              }
              if (!concluded) remain += 1;
            } else {
              boolean allLost = true;
              boolean allLostByMate = true;
              for (Object nextBit : nextBits) {
                short result = results[Arrays.binarySearch(bits, (long)nextBit)];
                if (result % 2 == 0) {
                  allLost = false;
                  remain += 1;
                  break;
                } else {
                  if (result < 0) allLostByMate = false;
                }
              }
              if (allLost) {
                results[i] = (short)((allLostByMate && board.isCheck()) ? -n : n);
                sum += 1;
              }
            }
          } else {
            if (nextBits.length < 1) {
              results[i]=0;
              sum += 1;
            } else remain += 1;
          }
        }
        if (i % (TOTAL/50) == 0) {
           System.out.print("+");
        }
      }
      System.out.printf("\n%d positions concluded. %d positions remaining.\n", sum, remain);
      System.out.printf("Initial position's result: %d\n", results[Arrays.binarySearch(bits, 4670862863189184L)]);
    } while(sum > 0);

    try {
      PrintWriter pw = new PrintWriter(new OutputStreamWriter(new FileOutputStream(new File("winloss.dat"))));
      for (int i=0;i<TOTAL;i++) {
        pw.println(results[i] == 1000 ? "*" : results[i]);
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
