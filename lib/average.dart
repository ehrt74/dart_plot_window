part of plot_window;

typedef num Reducer(List<num> nums);

class Average {
  String name;
  Reducer reduce;

  static Map<String, Average> CACHE = new Map<String, Average>();
  
  static Average ARITHMETIC = new Average._intern("Arithmetic",
      (List<num> nums)=>nums.fold(0, (num prev, num elem)=>prev+elem) / nums.length);
    
  static Average GEOMETRIC = new Average._intern("Geometric",
      (List<num> nums)=>math.exp(nums.fold(0, (num prev, num elem)=>prev + math.log(elem))/nums.length));


  Average._intern(this.name, this.reduce) {
    CACHE[this.name] = this;
  }
  
  static init() {
    ARITHMETIC; GEOMETRIC;
  }

}