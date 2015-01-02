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

class SortRawPositions{
  static final int TOTAL = 86848395;

  public static void main(String[] args){
    long[] bits;
    bits = new long[TOTAL];

    try {

      BufferedReader br = new BufferedReader(new FileReader(new File("rawdata.csv")));

      String line;
      int i = 0;

      System.out.println("+ = 2%");
      while((line = br.readLine()) != null) {
        i += 1;
        long bit = Long.parseLong((line.split(",",-1))[1]);
        bits[i-1] = bit;
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

    Arrays.sort(bits);
    
    try {
      PrintWriter pw = new PrintWriter(new OutputStreamWriter(new FileOutputStream(new File("allBitsSorted.dat"))));
      for (int i=0;i<TOTAL;i++) {
        pw.println(bits[i]);
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
