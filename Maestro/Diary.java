
import processing.core.PApplet;

// at the moment only a (bad) wrapper for PApplet println() for regural java code
// use "Maestro" to get to its override method...

public class Diary {
  public static Maestro applet = null;

  public static void println(String text) {
    if (applet != null) {
      applet.println(text);
    }
  }
  
}
