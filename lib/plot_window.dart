// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// The plot_window library.
///
/// This is an awesome library. More dartdocs go here.
library plot_window;

import "dart:html";
import "dart:math" as math;

part "line.dart";
part "axis.dart";
part "color.dart";

// TODO: Export any libraries intended for clients of this package.


/*class _PlotRectangle {
  Rectangle xy;
  Rectangle xy2;
  
  } */

class PlotWindow {

  CanvasElement canvas;
  CanvasRenderingContext2D context;
  bool multiPlot = false;

  Map<AxisType, Axis> axes = {AxisType.Y:new Axis(), AxisType.X:new Axis(), AxisType.Y2:new Axis()};

  bool forceSquare = false;
  bool grid = false;
  bool legend = true;
  num fontSize = 10;
  String fontFace = "sans-serif";
  String getFontString()=>"${fontSize}px ${fontFace}";

  Rectangle _rectangle;
  Rectangle get rectangle => _rectangle;

  void set rectangle(Rectangle r) {
    _rectangle=r;
    axes.values.forEach((Axis axis)=>axis.sizeFluid = false);
  }

  static Rectangle _shift(Rectangle r, Point offset) {
    return new Rectangle.fromPoints(r.topLeft-offset, r.bottomRight-offset);
  }

  static Rectangle _zoom(Rectangle r, num factor, [ List<AxisType> axisTypes, Point center]) {
    if (center==null)
      center = new Point(r.left + r.width/2, r.top + r.height/2);
    num left = r.left;
    num width = r.width;
    num top = r.top;
    num height = r.height;
    if (axisTypes==null || axisTypes.isEmpty || axisTypes.contains(AxisType.Y)) {
      top -= center.y;
      top *= factor;
      top += center.y;
      height *= factor;
    }
    if (axisTypes==null || axisTypes.isEmpty || axisTypes.contains(AxisType.X)) {
      left -= center.x;
      left *= factor;
      left += center.x;
      width *= factor;
    }
    return new Rectangle(left, top, width, height);
  }

  bool mouseDrag = false;
  Point oldOffset;
  
  Map<String, Line> lines = new Map<String, Line>();

  void removeLines() { this.lines = new Map<String, Line>(); }
  void removeLine(String s) { this.lines.remove(s); }
  
  PlotWindow(this.canvas) {
    this.context = canvas.context2D;
    this.canvas.onMouseWheel.listen((WheelEvent e) {
      axes.values.forEach((Axis axis)=>axis.sizeFluid = false);
      this.clear();
      List<AxisType> axisTypes = new List<AxisType>();
      num delta = e.deltaY;
      if (e.altKey)
        axisTypes.add(AxisType.Y);
      if (e.shiftKey) {
        axisTypes.add(AxisType.X);
        delta = e.deltaX;
      }
      this.rectangle = _zoom(this.rectangle, (delta/500 +1), axisTypes, toRectangle(e.offset));
      this.plot();
    });
    this.canvas.onMouseDown.listen((var e) {
      this.mouseDrag = true;
      this.oldOffset = e.offset;
    });
    this.canvas.onMouseUp.listen((_)=>this.mouseDrag = false);
    this.canvas.onMouseOut.listen((_)=>this.mouseDrag = false);
    this.canvas.onMouseMove.listen((var e) {
      if (this.mouseDrag) {
        var offset = toRectangle(e.offset) - toRectangle(this.oldOffset);
        this.rectangle = _shift(this.rectangle, offset);
        this.oldOffset = e.offset;
        clear();
        plot();
      }
    });
  }

  Point toCanvas(Point p) {
    num x = (p.x-rectangle.left)/(rectangle.width) * canvas.width;
    num y = (1 - (p.y-rectangle.top)/(rectangle.height)) * canvas.height; // canvas coordinates go from top to bottom
    return new Point(x, y);
  }

  Point toRectangle(Point p) {
    num x = p.x/canvas.width * rectangle.width + rectangle.left;
    num y = (1 - p.y/canvas.height) * rectangle.height + rectangle.top;
    return new Point(x, y);
  }
  
  void clear() {
    this.context.clearRect(0,0,canvas.width, canvas.height);
  }

  void addLine(String name, Line line) {
    if (line.points == null || line.validPoints.isEmpty) return;
    lines[name] = line;
  }
  
  void plot() {
    if(axes.values.map((Axis a)=>a.sizeFluid).contains(true) && !this.mouseDrag)
      rectangle = _zoom(lines.values.map((Line l)=>l.rectangle).reduce((value, element)=>value.boundingBox(element)), 1.1);
    setXTics();
    setYTics();
    drawGrid();
    drawLines();
    drawLegend();
  }

  void drawLegend() {
    context.fillStyle="${Color.WHITE}";
    context.fillRect(canvas.width-80, 0, 80, lines.length * 12 + 5);
    context.strokeStyle = "${Color.BLACK}";
    context.lineWidth=1;
    context.font = getFontString();
    num maxLength = 0;
    lines.keys.forEach((String name) {
      num length = context.measureText(name).width;
      if (length>maxLength) maxLength=length;
    });
    num padding = 20;
    context.rect(canvas.width-maxLength-2*padding, 0, maxLength + 2*padding, lines.length * (fontSize+2) + 5);
    context.stroke();
    context.textAlign = "start";
    for(int i=0; i<lines.length; i++) {
      var color = lines.values.toList()[i].color;
      context.strokeStyle = "$color";
      context.fillStyle = "$color";
      context.fillText(lines.keys.toList()[i], canvas.width-maxLength-padding, 10 + i*(fontSize+2));
    }
  }
  
  void setXTics() { this.axes[AxisType.X].setTics(rectangle.left, rectangle.right, canvas.width); }

  void setYTics() { this.axes[AxisType.Y].setTics(rectangle.top, rectangle.bottom, canvas.height); }
  
  void drawGrid() {
    context.strokeStyle = "${Color.BLACK}";
    var yTics = this.axes[AxisType.Y].tics;
    var xTics = this.axes[AxisType.X].tics;
    yTics.forEach((num yTic) {
      if (yTic==0) context.lineWidth = 2;
      else context.lineWidth = 0.5;
      context..beginPath()
        ..moveTo(0,toCanvas(new Point(0,yTic)).y)
        ..lineTo(canvas.width-1, toCanvas(new Point(0,yTic)).y)
        ..stroke();
    });
    
    xTics.forEach((num xTic) {
      if (xTic==0) context.lineWidth = 2;
      else context.lineWidth = 0.5;
      context..beginPath()
        ..moveTo(toCanvas(new Point(xTic,0)).x, 0)
        ..lineTo(toCanvas(new Point(xTic,0)).x, canvas.height-1)
        ..stroke();
    });
    bool xOnAxis = false;
    bool yOnAxis = false;
    num xOffset = xTics.first;
    num yOffset = yTics.last;
    if (xTics.first<0 && xTics.last>0) xOnAxis = true;
    if (!validPointForText(new Point(xTics.first, yTics.first)))
      xOffset=xTics[1];
    
    if (yTics.first<0 && yTics.last>0) yOnAxis = true;
    if (!validPointForText(new Point(xTics[2], yTics.last)))
      yOffset=yTics[yTics.length -2];

    context.font = getFontString();
    context.fillStyle = "${Color.BLACK}";
    context.textAlign = "end";
    yTics.forEach((num yTic) {
      var xPoint = xOffset;
      if (xOnAxis) xPoint = 0;
      Point center = toCanvas(new Point(xPoint, yTic)) - new Point(5, 5);
      if (validPointForText(center))
        context.fillText(yTic.toStringAsFixed(axes[AxisType.Y].fixedPrecision), center.x, center.y);
    });
    context.textAlign = "start";
    xTics.forEach((num xTic) {
      var yPoint = yTics.first;
      if (yOnAxis) yPoint = 0;
      Point center = toCanvas(new Point(xTic, yPoint)) + new Point(5, 15);
      if (validPointForText(center))
        context.fillText(xTic.toStringAsFixed(axes[AxisType.X].fixedPrecision), center.x, center.y);
    });
  }

  bool validPointForText(Point p) {
    Point topLeft = toCanvas(rectangle.topLeft);
    Point bottomRight = toCanvas(rectangle.bottomRight);
    return p.x>topLeft.x+10 && p.x<bottomRight.x-10  &&
            p.y<topLeft.y-10 && p.y>bottomRight.y+10;
  }

  static bool ValidPointForCanvas(Point p)=>!(p.x.isNaN || p.x.isInfinite || p.y.isNaN || p.y.isInfinite);
  
  void drawLines() {
    this.lines.values.forEach((Line line) {
      var points = line.validPoints;
      if (points.isNotEmpty) {
        if (line.lineType.hasLines) {
          context.setStrokeColorRgb(line.color.red, line.color.green, line.color.blue);
          Point first = toCanvas(points.first);
          context..beginPath()
            ..moveTo(first.x, first.y);
          
          points.skip(1).forEach((Point p) {
            Point point = toCanvas(p);
            if(ValidPointForCanvas(p))
              context.lineTo(point.x, point.y);
          });
          context.stroke();
        }
        if (line.lineType.hasPoints) {
          context.fillStyle = "${line.fillColor}";
          points.map((Point p)=>toCanvas(p)).forEach((Point p) {
            context..moveTo(p.x, p.y)
              ..beginPath()
            ..arc(p.x, p.y, line.pointRadius, 0, 2*math.PI)
              ..fill();
          });
        }
      }
    });
    
  }
  
}