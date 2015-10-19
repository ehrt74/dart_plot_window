// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:plot_window/plot_window.dart' as plot_window;
import 'dart:html';


main() {
  var plotWindow = new plot_window.PlotWindow(querySelector('#mycanvas'));
  var line1 = new plot_window.Line([new Point(1,2), new Point(2,5), new Point(3,-3)], color:new plot_window.Color(255,0,0));

  var line2 = new plot_window.Line([new Point(-3,5), new Point(-2,4), new Point(-1,-2)], color:new plot_window.Color(0,0,255));

  plotWindow..addLine("line1", line1)
    ..addLine("line2", line2);
  
  plotWindow.plot();
}
