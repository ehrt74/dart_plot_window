part of plot_window;

class LineType {
  String name;
  bool hasLines;
  bool hasPoints;
  
  static LineType LINEPOINTS = new LineType._intern("linepoints", true, true);

  LineType._intern(this.name, this.hasLines, this.hasPoints);

}


class Line {
  List<Point> points;
  Iterable<Point> _validPoints;
  Iterable<Point> get validPoints => _validPoints;
  
  Color _color;
  Color get color=>_color!=null? _color: Color.BLACK;
  void set color(Color c) {
    if (_fillColor==null) fillColor = c;
    _color = c;
  }
  
  Color _fillColor;
  Color get fillColor=>_fillColor!=null? _fillColor: Color.BLACK;
  void set fillColor(Color c) { this._fillColor = c; }
  
  num thickness;
  LineType lineType = LineType.LINEPOINTS;
  num pointRadius = 2;
  AxisType axisType;

  num get minX=>_validPoints.map((Point p)=>p.x).reduce((value, element)=>element>value?value:element);
  num get maxX=>_validPoints.map((Point p)=>p.x).reduce((value, element)=>element>value?element:value);
  num get minY=>_validPoints.map((Point p)=>p.y).reduce((value, element)=>element>value?value:element);
  num get maxY=>_validPoints.map((Point p)=>p.y).reduce((value, element)=>element>value?element:value);

  Rectangle get rectangle=>new Rectangle.fromPoints(new Point(minX, minY), new Point(maxX, maxY));
  

  Line(this.points, {LineType lineType:null, Color color:null, num thickness:1, AxisType axisType:null}) {
    if(this.points==null) this.points = new List<Point>();
    this._validPoints=this.points.where(PlotWindow.ValidPointForCanvas);
    if (lineType != null) this.lineType = lineType;
    this.color = color;
                         
    this.thickness = thickness;
    if (axisType==null || axisType==AxisType.X) axisType=AxisType.Y;
    this.axisType = axisType;
  }
}