class Tracer{
  ArrayList<PVector> list;

  Tracer(PVector start, int size){
    list = new ArrayList<PVector>();
    for(int i = 0; i < size; i++){
      list.add(start.copy());
    }
  }

  void addPoint(PVector p){
    for(int i = list.size()-1; i > 0; i--){
      list.set(i, list.get(i-1));
    }
    list.set(0, p.copy());
  }

  void display(){

    strokeWeight(5);
    for(int i = 0; i < list.size()-1; i++){
      stroke(255, 255, 255, 255*(1-(float)i/(float)list.size()));
      PVector s = list.get(i);
      PVector e = list.get(i+1);
      line(s.x, s.y, e.x, e.y);
    }
    alpha(1);
  }
}
