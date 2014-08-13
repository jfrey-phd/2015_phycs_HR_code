
import processing.core.PApplet;
import java.io.PrintWriter;
import java.util.Date;
import java.text.SimpleDateFormat;

/* Handles stdout */

// Enable println() outside Processing, and print caller name if flag is set
// Write output to file if flag is set
// FIXME: do not get stderr
// TODO: check that it's flushed. flush in draw() to limit disasters?
// TODO: do not handle comma separated strings as argument 

// WARNING: may use a greedy method, avoid with lot's of output.
// TODO: examine SecurityManger solution, see http://stackoverflow.com/questions/421280/how-do-i-find-the-caller-of-a-method-using-stacktrace-or-reflection

/* Enables CSV records */

// CSV will be flushed with each write

// Format: a CSV file, a tabulation separating each field. Elapsed time since start (miliseconds), stage (integer), HR type (string), question type (string, sentence/agent), question coded (float), valence (integer, last sentence spoke for agent), answer (integer)

// TODO: one separate class for CSV if not frightened anymore by crowded folder

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

  // print to CSV or fot
  private static boolean exportCSV = false;
  // steam for CSV file
  private static PrintWriter outputCSV = null;
  // We'll measure elapsed time since XP started
  private static long initTime;

  // init variables, create output files on disk if flags set (extention will be .txt/.csv), write headers for CSV
  // NB: calling this method twice will have no effect
  public static void setup(PApplet applet, boolean printStack, boolean printToFile, String stdoutFileBasename, boolean exportCSV, String CSVFileBasename ) {
    // job already done
    if (init) {
      return;
    }
    Diary.applet = applet;
    // init println
    Diary.printStack = printStack;
    Diary.printToFile = printToFile;
    // we want both timestamp to be equals
    String timestamp = getTimeStamp(); 
    if (printToFile) {
      // Format 2014_05_28-10_32_45.txt
      String stdoutFileName = stdoutFileBasename + "_" + timestamp + ".txt";
      output = applet.createWriter(stdoutFileName);
      // take care not to println something before the very last line of this method...
      println("Output file for stdout: " + stdoutFileName);
    }
    // init CSV
    Diary.exportCSV = exportCSV;
    if (exportCSV) {
      String CSVFileName = CSVFileBasename + "_" + timestamp + ".csv";
      outputCSV = applet.createWriter(CSVFileName);
      println("Output file for CSV: " + CSVFileName);
      // write headers
      String headers = "elapsedTime" + "\t" + "stage" + "\t" + "HR_type" + "\t" + "question_type" + "\t" + "question_code" + "\t" + "valence" + "\t" + "answer";
      outputCSV.println(headers);
      // extra care
      outputCSV.flush();
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
    return ft.format(dNow);
  }

  // discard output as long as applet is not set...
  public static void println(String text) {
    // 0: getStack
    // 1: Diary.println(String text, int stackDepth)
    // 2: this function
    // 3: what we want to know
    println(text, 3);
  }

  // for external use if another indirection is set (for ex. Maestro wrapper adds one layer), will pick the right depth in stack
  public static void println(String text, int stackDepth) {
    if (applet != null) {
      // empty header by default, will add timestamp and caller name if printStack is set
      String header = "";
      if (printStack) {
        // more human readable to have timestamp in seconds
        float timestamp = (float)applet.millis()/1000;
        StackTraceElement caller = Thread.currentThread().getStackTrace()[stackDepth];
        header = timestamp + ":" + caller.getClassName() + "." + caller.getMethodName() + " -- ";
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

  // record subject's answers and current experimental conditions into CSV file
  public static void logCSV(int stage, Body.HR condition, String question_type, int question_code, int valence, int answer) {
    // could be more detailed, but luckily such a problem will be quickly tracked down
    if (outputCSV == null) {
      System.out.println("CSV logs: error, logs not initialized or option not set.");
      return;
    }

    // Compute elapsed time since XP start
    long elapsedTime = new Date().getTime() -  initTime;

    String record = Long.toString(elapsedTime) + "\t" + Integer.toString(stage)
      + "\t" + condition + "\t" + question_type + "\t" + Integer.toString(question_code)
        + "\t" + Integer.toString(valence) + "\t" + Integer.toString(answer);

    // Let's write it!
    System.out.println("CSV record: " + record);
    outputCSV.println(record);
    // extra care
    outputCSV.flush();
  }


  // call it before exiting, ensure stdout is flushed to file
  public static void dispose() {
    if (output != null) {
      output.flush();
      output.close();
      // no return after this point -- just to be sure we don't try to write into closed stream later
      output = null;
    }
    if (outputCSV != null) {
      outputCSV.flush();
      outputCSV.close();
      outputCSV = null;
    }
  }
}

