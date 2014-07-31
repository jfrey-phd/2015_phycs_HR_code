// Misc stuff, mainly enum

import processing.core.*;

public class Body {

  public enum Type {
    HEAD, EYES, MOUTH, HEART
  };

  public enum Genre {
    FEMALE, MALE, BOTH
  };

  // return the corresponding id for that name
  static public String getTypeName(Type type) {
    String typeName = "";
    switch(type) {
    case HEAD:
      typeName+="head";
      break;
    case EYES:
      typeName+="eyes";
      break;
    case MOUTH:
      typeName+="mouth";
      break;
    case HEART:
      typeName+="heart";
      break;
    default:
      //println("Error, no name set for this body type: " + type);
      break;
    }
    return typeName;
  }

  // return the corresponding id for that genre
  static public String getGenreName(Genre genre) {
    String genreName = "";
    switch(genre) {
    case FEMALE:
      genreName+="F";
      break;
    case MALE:
      genreName+="M";
      break;
    case BOTH:
      genreName+="B";
      break;

    default:
      //println("Error, no name set for this body genre: " + genre);
      break;
    }
    return genreName;
  }
};

