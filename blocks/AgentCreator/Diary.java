
import processing.core.PApplet;

// at the moment only a (bad) wrapper for PApplet println() for regural java code

public class Diary {
  public static PApplet applet = null;

  public static void println(String text) {
    if (applet != null) {
      applet.println(text);
    }
  }
  
}
