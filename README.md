# plot_window

A very simple, very buggy library to plot graphs on a canvas. I'll gradually add to it, so you probably shouldn't use this in any projects yet.

## Usage

A simple usage example:

    import 'package:plot_window/plot_window.dart';
    import 'dart.html';
    
    main() {
      var plotWindow = new PlotWindow(querySelector('#mycanvas');
      var line1 = new plot_window.Line([new Point(1,2), new Point(2,5), new Point(3,-3)], color:new plot_window.Color(255,0,0));

      var line2 = new plot_window.Line([new Point(-3,5), new Point(-2,4), new Point(-1,-2)], color:new plot_window.Color(0,0,255));

      plotWindow..addLine("line1", line1)
         ..addLine("line2", line2);
  
      plotWindow.plot();
    }

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme
