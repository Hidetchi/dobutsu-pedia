import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;

class CreatePositions{
  static List<Long> positions = new ArrayList<Long>();
  static HashMap<Long, Boolean> map = new HashMap<Long, Boolean>();
  static int i;
  static int sum=0;

  private static boolean registerPosition(long bit) {
    if (map.containsKey(bit)) {
      return false;
    } else {
      positions.add(bit);
      map.put(bit, true);
      sum += 1;
      return true;
    }
  }


  public static void main(String[] args){
    try {

      File outputFile = new File("rawdata.csv");
      FileOutputStream fos = new FileOutputStream(outputFile);
      OutputStreamWriter osw = new OutputStreamWriter(fos);
      PrintWriter pw = new PrintWriter(osw);
      Runtime runtime = Runtime.getRuntime();

      Board board = new Board(4670862863189184L, true);
      registerPosition(board.toBit(true));    
      
      i = 0;
      int dup = 0;
      int mate = 0;
      long start = System.currentTimeMillis();
      byte n = 0
      
      while (i < sum) {
        Object[] bits = positions.toArray();
        positions = new ArrayList<Long>();
        System.out.printf("Starting analysis of positions for #%d: Total=%d\n", n, bits.length);
        for (Object bit0 : bits) {
          i += 1;
          board = new Board((long)bit0, true);
          Object[] nextBits = board.nextBitsNormalized();
          if (nextBits.length > 0) {
            for (Object bit : nextBits) {
              if (!registerPosition((long)bit)) dup += 1;
            }
          } else {
            mate += 1;
          }
          pw.printf("%d,%d\n", n, bit0);
          if (i % 10000 == 0) {
            long now = System.currentTimeMillis();
            long used = (runtime.maxMemory() - runtime.freeMemory())/1000;
            long max = runtime.maxMemory()/1000;
            System.out.printf("#%d,%d - %d/%d dup:%d,mate:%d T=%d, M=%d/%d\n", n, bits.length, i, sum, dup, mate, (now-start)/1000, used, max);
            mate = 0;
            dup = 0;
          }
        }
        n += 1;
      }
      
      pw.close();
    
    } catch(Exception e) {
      e.printStackTrace();
    }
    
  }
}
