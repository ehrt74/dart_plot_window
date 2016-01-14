// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library plot_window.test;

import 'package:plot_window/plot_window.dart';
import 'package:test/test.dart';

Line line1;

void main() {
  List<Point> points = new List<Point>();
  for (int i=0; i<10; i++) {
    points.add(new Point(i, i*i - i + 2));
  }
  line1 = new Line(points);
  
  test('Line lenggth', () {
    expect(line1.points.length, equals(10));
  });
}
