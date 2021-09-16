
// Manage all physics objects
class PhysicsManager{
  ArrayList<PhysicsObject> objects = new ArrayList<PhysicsObject>();
  ArrayList<Spring> springs = new ArrayList<Spring>();
  long lastUpdateTime = millis();

  PhysicsObject addObject(PhysicsObject object){
    objects.add(object);
    return object;
  }
  Spring addSpring(Spring spring){
    springs.add(spring);
    return spring;
  }

  void selectObject(PVector point){
    for(PhysicsObject obj : objects){
      if(obj.pointInObject(point)){
        obj.selected = true;
        return;
      }
    }
  }
  void deselectObject(){
    for(PhysicsObject obj : objects){
      if(obj.selected){
        obj.selected = false;
        obj.vel = new PVector(mouseX - pmouseX, mouseY - pmouseY).mult(80);
      }
    }
  }

  void applyGravity(PVector force){
    for(PhysicsObject object : objects){
      object.applyForce(force.copy().mult(object.mass));
    }
  }
  void update(){
    float dt = (float)(millis() - lastUpdateTime) / 1000;

    for(Spring spring : springs){
      spring.update(dt);
    }
    for(PhysicsObject object : objects){
      object.update(dt);
    }

    lastUpdateTime = millis();
  }

  void display(){
    for(PhysicsObject object : objects){
      object.display();
    }
    for(Spring spring : springs){
      spring.display();
    }
  }
}
