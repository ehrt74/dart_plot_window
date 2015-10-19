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

// TODO: Export any libraries intended for clients of this package.


class _PlotRectangle {
  Rectangle xy;
  Rectangle xy2;
  
}

class Color {
  int red;
  int green;
  int blue;

  static Color BLACK = new Color(0,0,0);
  
  String toString()=>"#${red.toRadixString(16).padLeft(2, '0')}${green.toRadixString(16).padLeft(2, '0')}${blue.toRadixString(16).padLeft(2,'0')}";
  
  Color(int red, int green, int blue) {
    if (red <0 || red >255) red = 0;
    if (green <0 || green >255) green = 0;
    if (blue <0 || blue >255) blue = 0;
    this.red = red; this.green = green; this.blue = blue;
  }
}

class PlotWindow {

  CanvasElement canvas;
  CanvasRenderingContext2D context;
  bool multiPlot = false;

  Map<AxisType, Axis> axes = {AxisType.Y:new Axis(), AxisType.X:new Axis(), AxisType.Y2:new Axis()};

  bool forceSquare = false;
  bool grid = false;

  Rectangle _rectangle;
  Rectangle get rectangle => _rectangle;

  Rectangle set rectangle(Rectangle r) {
    _rectangle=r;
    axes.values.forEach((Axis axis)=>axis.sizeFluid = false);
  }

  static Rectangle _zoom(Rectangle r, num factor, [Point center]) {
    if (center==null)
      center = new Point(r.left + r.width/2, r.top + r.height/2);

    var r2 =  new Rectangle.fromPoints( ((r.topLeft - center) * factor) + center,
        ((r.bottomRight - center) * factor)+ center);
    return r2;
  }

  Map<String, Line> lines = new Map<String, Line>();
  
  PlotWindow(this.canvas) {
    this.context = canvas.context2D;
    this.canvas.onMouseWheel.listen((WheelEvent e) {
      axes.values.forEach((Axis axis)=>axis.sizeFluid = false);
      this.clear();
      print("delta: (${e.deltaX}, ${e.deltaY}), offset: ${e.offset}");
      this.rectangle = _zoom(this.rectangle, (e.deltaY/500 +1), toRectangle(e.offset));
      this.plot();
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
    if (line.points == null || line.points.length == 0) return;
    lines[name] = line;
  }
  
  void plot() {
    if(axes.values.map((Axis a)=>a.sizeFluid).contains(true))
      rectangle = _zoom(lines.values.map((Line l)=>l.rectangle).reduce((value, element)=>value.boundingBox(element)), 1.1);
    setXTics();
    setYTics();
    drawGrid();
    drawLines();
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
    num xOffset;
    num yOffset;
    if (xTics.first<0 && xTics.last>0) xOnAxis = true;
    if ( toCanvas(new Point(xTics.first,0) - new Point(rectangle.left,0)).x<50)
      xOffset = xTics[1];
    else
      xOffset = xTics[0];
    if (yTics.first<0 && yTics.last>0) yOnAxis = true;
    if ( toCanvas(new Point(0,rectangle.bottom) - new Point(0,yTics.last) ).y<50)
      yOffset = yTics[yTics.length - 2];
    else
      yOffset = yTics.last;
    num skew = (toCanvas(new Point(xTics[1],0)) - toCanvas(new Point(xTics[0],0))).x/3;
    context.font = "10px sans-serif";
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
  
  void drawLines() {
    this.lines.values.forEach((Line line) {
      if (line.lineType.hasLines) {
        context.setStrokeColorRgb(line.color.red, line.color.green, line.color.blue);
        Point first = toCanvas(line.points.first);
        context..beginPath()
          ..moveTo(first.x, first.y);
        
        line.points.skip(1).forEach((Point p) {
          Point point = toCanvas(p);
          context.lineTo(point.x, point.y);
        });
        context.stroke();
      }
      if (line.lineType.hasPoints) {
        context.fillStyle = "${line.fillColor}";
        line.points.map((Point p)=>toCanvas(p)).forEach((Point p) {
          context..moveTo(p.x, p.y)
            ..beginPath()
            ..arc(p.x, p.y, line.pointRadius, 0, 2*math.PI)
            ..fill();
        });
      }
    });
    
  }
  
}