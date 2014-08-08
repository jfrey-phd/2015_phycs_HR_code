
import processing.core.PApplet;
import java.io.PrintWriter;
import java.util.Date;
import java.text.SimpleDateFormat;

// Enable println() outside Processing, and print caller name if flag is set
// Write output to file if flag is set
// FIXME: do not get stderr
// TODO: check that it's flushed. flush in draw() to limit disasters?

// WARNING: may use a greedy method, avoid with lot's of output.
// TODO: examine SecurityManger solution, see http://stackoverflow.com/questions/421280/how-do-i-find-the-caller-of-a-method-using-stacktrace-or-reflection

public class Diary {
  // we init once
  private static boolean init = false;
  // Goes back to processing PApplet
  // TODO: use System.out.println()?
  private static PApplet applet = null;
  // add caller name to each "println"
  private static boolean printStack = true;
  // print to file or not
  private static boolean printToFile = false;
  // steam for output file
  private static PrintWriter output = null;

  // init variables, mostly create output file on disk if flag set (extention will be .txt)
  // NB: calling this method twice will have no effect
  public static void setup(PApplet applet, boolean printStack, boolean printToFile, String stdoutFileBasename) {
    // job already done
    if (init) {
      return;
    }
    Diary.applet = applet;
    Diary.printStack = printStack;
    Diary.printToFile = printToFile;
    if (printToFile) {
      // Format subjectID-2014_05_28-10_32_45.csv
      String stdoutFileName = stdoutFileBasename + "_" + getTimeStamp() + ".txt";
      output = applet.createWriter(stdoutFileName);
      // take care not to println something before the very last line of this method...
      println("Output file for stdout: " + stdoutFileName);
    }
  }

  // return a string corresponding to current date/time, used as timestamp for filename
  // ...not exactly right to put in here for public access
  // format: "yyyy-MM-dd_HH-mm-ss", eg "2014_05_28-10_32_45"
  public static String getTimeStamp() {
    // fetch date from java functions
    Date dNow = new Date();
    // format date for filename
    SimpleDateFormat ft = new SimpleDateFormat ("yyyy-MM-dd_HH-mm-ss");
    return  ft.format(dNow);
  }

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
      // concatenate string
      String mes = header + text;
      // ship it to stdout
      PApplet.println(mes);
      // and to file if set and dispose() not called yet
      if (printToFile && output != null) {
        output.println(mes);
      }
    }
  }

  // call it before exiting, ensure stdout is flushed to file
  public static void dispose() {
    if (output != null) {
      output.flush();
      output.close();
      // no return after this point -- just to be sure we don't try to write into closed tream later
      output = null;
    }
  }
}

