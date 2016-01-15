part of plot_window;

typedef num Reducer(List<num> nums);

class AverageMethod {
  String name;
  Reducer reduce;

  static Map<String, AverageMethod> CACHE = new Map<String, AverageMethod>();
  
  static AverageMethod ARITHMETIC = new AverageMethod._intern("Arithmetic",
      (List<num> nums)=>nums.fold(0, (num prev, num elem)=>prev+elem) / nums.length);
    
  static AverageMethod GEOMETRIC = new AverageMethod._intern("Geometric",
      (List<num> nums)=>math.exp(nums.fold(0, (num prev, num elem)=>prev + math.log(elem))/nums.length));


  AverageMethod._intern(this.name, this.reduce) {
    CACHE[this.name] = this;
  }
  
  static init() {
    ARITHMETIC; GEOMETRIC;
  }

}


class PointSmoother {
  AverageMethod average;
  int width;

  String toString()=>"${this.average.name} (${this.width})";
  
  bool operator ==(PointSmoother other) {
    return this.average==other.average && this.width==other.width;
  }

  PointSmoother(this.average, this.width);

  List<Point>smooth(List<Point> points) {
    List<Point> ret = new List<Point>();
    for(int i=0; i<points.length - width; i++) {
      var sublist = points.skip(i).take(width).toList();
      ret.add(new Point(sublist[width~/2].x, average.reduce(sublist.map((Point p)=>p.y).toList())));
    }
    return ret;
  }
  
}