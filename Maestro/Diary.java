
import processing.core.PApplet;

// Enable println() outside Processing, and print caller name if flag is set

// WARNING: may use a greedy method, avoid with lot's of output.
// TODO: examine SecurityManger solution, see http://stackoverflow.com/questions/421280/how-do-i-find-the-caller-of-a-method-using-stacktrace-or-reflection



public class Diary {
  // Goes back to processing PApplet
  // TODO: use System.out.println()?
  public static PApplet applet = null;
  // add caller name to each "println"
  public static boolean printStack = true;



  // discard output as long as applet is not set...
  public static void println(String text) {
    // 0: getStack
    // 1: Diary.println(String text, int stackDepth)
    // 2: this function
    // 3: what we want to know
    println(text, 3);
  }

  // for external use if another indirection is set (for ex. Maestro wrapper adds one layer)
  public static void println(String text, int stackDepth) {

    if (applet != null) {
      // empty header by default, will add caller name if printStack is set
      String header = "";
      if (printStack) {
        // 0: getStack
        // 1: Maersto.println
        // 2: what we want to know
        StackTraceElement caller = Thread.currentThread().getStackTrace()[stackDepth];
        header = caller.getClassName() + "." + caller.getMethodName() + ": ";
      }
      PApplet.println(header + text);
    }
  }
}

