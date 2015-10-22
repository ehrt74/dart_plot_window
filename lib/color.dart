part of plot_window;

class Color {
  int red;
  int green;
  int blue;

  static Color BLACK = new Color(0,0,0);
  static Color WHITE = new Color(255,255,255);
  
  String toString()=>"#${red.toRadixString(16).padLeft(2, '0')}${green.toRadixString(16).padLeft(2, '0')}${blue.toRadixString(16).padLeft(2,'0')}";
  
  Color(int red, int green, int blue) {
    if (red <0 || red >255) red = 0;
    if (green <0 || green >255) green = 0;
    if (blue <0 || blue >255) blue = 0;
    this.red = red; this.green = green; this.blue = blue;
  }
}

