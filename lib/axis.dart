part of plot_window;

class AxisType {
  String name;
  static AxisType Y = new AxisType._intern("y");
  static AxisType X = new AxisType._intern("x");
  static AxisType Y2 = new AxisType._intern("y2");

  String toString()=>this.name;
  
  AxisType._intern(this.name);

}

class Axis {
  List<num> tics = new List<num>();
  int _numberPower;
  int get fixedPrecision=>_numberPower>=0? 0: -_numberPower;
  
  bool sizeFluid = true;

  static List<num>_possibleTics=[1,2,5];
  static int _targetTicDistance = 100;
  
  void setTics(num from, num to, num pixels) {
    this.tics.clear();
    num unitdensity = (to - from)/pixels*_targetTicDistance;
    this._numberPower = (math.log(unitdensity) / math.LN10).floor();
    num units = unitdensity / math.pow(10, _numberPower);
    num chiffre;
    _possibleTics.forEach((num pt) {
      if (units > pt) chiffre = pt;
    });
    num distanceBetweenTics = chiffre * math.pow(10, _numberPower);
    var tic = ((from/distanceBetweenTics).floor()+1) * distanceBetweenTics;
    tics.add(tic);
    while(true) {
      tic += distanceBetweenTics;
      if (tic>to) break;
      tics.add(tic);
    }
  }

  
}