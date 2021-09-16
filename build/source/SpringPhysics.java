import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class SpringPhysics extends PApplet {



public void createRope(PVector pos, int amount){
  PhysicsObject[] balls = new PhysicsObject[amount];

  for(int i = 0; i < amount; i++){
    balls[i] = manager.addObject(new Ball(pos.x+50*i, pos.y, 5, 30));
  }
  for(int i = 0; i < amount-1; i++){
    manager.addSpring(new Spring(balls[i], balls[i+1], 500));
  }
}

public void createEinsteinianSolid(PVector pos, int w, int h){
  PhysicsObject[][] balls = new PhysicsObject[w][h];

  for(int i = 0; i < w; i++){
    for(int j = 0; j < h; j++){
      balls[i][j] = manager.addObject(new Ball(pos.x+50*i, pos.y+50*j, 2, 30));
    }
  }

  float d = 1300;
  for(int i = 0; i < w-1; i++){
    for(int j = 0; j < h-1; j++){
      manager.addSpring(new Spring(balls[i][j], balls[i+1][j], d));
      manager.addSpring(new Spring(balls[i][j], balls[i][j+1], d));
      manager.addSpring(new Spring(balls[i][j], balls[i+1][j+1], d));
      manager.addSpring(new Spring(balls[i+1][j], balls[i][j+1], d));
    }
  }
  for(int i = 0; i < w-1; i++){
    manager.addSpring(new Spring(balls[i][h-1], balls[i+1][h-1], d));
  }
  for(int j = 0; j < h-1; j++){
    manager.addSpring(new Spring(balls[w-1][j], balls[w-1][j+1], d));
  }
}

// Main loop
PhysicsManager manager = new PhysicsManager();

public void setup() {
  
  frameRate(60);

  createRope(new PVector(50, 600), 2);
  createRope(new PVector(50, 600), 8);
  createEinsteinianSolid(new PVector(100, 500), 5, 5);
}

public void draw(){
  manager.applyGravity(new PVector(0, 600));
  manager.update();

  background(0);
  manager.display();
}

public void mousePressed(){
  manager.selectObject(new PVector(mouseX, mouseY));
}
public void mouseReleased(){
  manager.deselectObject();
}

// A ball bouncing off of the edges
class Ball extends PhysicsObject{
  float r;

  Ball(PVector pos, PVector vel, float mass, float r){
    super(pos, vel, mass);
    this.r = r;
  }
  Ball(PVector pos, float mass, float r){
    super(pos, mass);
    this.r = r;
  }
  Ball(float x, float y, float mass, float r){
    super(x, y, mass);
    this.r = r;
  }

  public boolean pointInObject(PVector point){
    return point.copy().sub(pos).mag() < r;
  }
  public void update(float dt){
    if(pos.x - r < 0){ pos.x = r; vel.x = abs(vel.x); }
    if(pos.y - r < 0){ pos.y = r; vel.y = abs(vel.y); }
    if(pos.x + r > width ){ pos.x = width-r;  vel.x = -abs(vel.x); }
    if(pos.y + r > height){ pos.y = height-r; vel.y = -abs(vel.y); }
    super.update(dt);
  }

  public void display(){
    stroke(0);
    fill(255);
    if(selected){
      fill(255, 0, 0);
    }
    ellipse(pos.x, pos.y, 2*r, 2*r);
  }
}

// Manage all physics objects
class PhysicsManager{
  ArrayList<PhysicsObject> objects = new ArrayList<PhysicsObject>();
  ArrayList<Spring> springs = new ArrayList<Spring>();
  long lastUpdateTime = millis();

  public PhysicsObject addObject(PhysicsObject object){
    objects.add(object);
    return object;
  }
  public Spring addSpring(Spring spring){
    springs.add(spring);
    return spring;
  }

  public void selectObject(PVector point){
    for(PhysicsObject obj : objects){
      if(obj.pointInObject(point)){
        obj.selected = true;
        return;
      }
    }
  }
  public void deselectObject(){
    for(PhysicsObject obj : objects){
      if(obj.selected){
        obj.selected = false;
        obj.vel = new PVector(mouseX - pmouseX, mouseY - pmouseY).mult(80);
      }
    }
  }

  public void applyGravity(PVector force){
    for(PhysicsObject object : objects){
      object.applyForce(force.copy().mult(object.mass));
    }
  }
  public void update(){
    float dt = (float)(millis() - lastUpdateTime) / 1000;

    for(Spring spring : springs){
      spring.update(dt);
    }
    for(PhysicsObject object : objects){
      object.update(dt);
    }

    lastUpdateTime = millis();
  }

  public void display(){
    for(PhysicsObject object : objects){
      object.display();
    }
    for(Spring spring : springs){
      spring.display();
    }
  }
}

// Simulate a generic physics object
abstract class PhysicsObject{
  PVector pos = new PVector(0, 0);
  PVector vel = new PVector(0, 0);
  PVector acc = new PVector(0, 0);
  float mass;
  float friction = 0.99f;
  boolean selected = false;

  PhysicsObject(PVector pos, PVector vel, float mass){
    this.pos = pos;
    this.vel = vel;
    this.mass = mass;
  }
  PhysicsObject(PVector pos, float mass){
    this.pos = pos;
    this.mass = mass;
  }
  PhysicsObject(float x, float y, float mass){
    this.pos = new PVector(x, y);
    this.mass = mass;
  }

  public void applyForce(PVector force){
    if(mass == 0){ return; }
    acc.add(force.copy().div(mass));
  }
  public boolean pointInObject(PVector point){
    return false;
  }

  public void update(float dt){
    if(selected){
      pos.x += mouseX - pmouseX;
      pos.y += mouseY - pmouseY;
      acc.mult(0);
      return;
    }
    vel.add(acc.copy().mult(dt));
    pos.add(vel.copy().mult(dt));
    acc.mult(0);
    vel.mult(friction);
  }

  public void display(){
    fill(255, 0, 0); noStroke();
    ellipse(pos.x, pos.y, 10, 10);
  }
}

// A spring between two physics objects
class Spring{
  PhysicsObject obj1;
  PhysicsObject obj2;
  float s;
  float l;
  float d = 10;

  Spring(PhysicsObject obj1, PhysicsObject obj2, float s){
    this.obj1 = obj1;
    this.obj2 = obj2;
    this.s = s;
    this.l = obj1.pos.dist(obj2.pos);
  }
  Spring(PhysicsObject obj1, PhysicsObject obj2, float s, float l){
    this.obj1 = obj1;
    this.obj2 = obj2;
    this.s = s;
    this.l = l;
  }

  public void update(float dt){
    float distance = obj2.pos.dist(obj1.pos);
    PVector direction = obj2.pos.copy().sub(obj1.pos).normalize();
    PVector deltaVel = obj2.vel.copy().sub(obj1.vel);

    float dampening = deltaVel.dot(direction) * d;
    float totalForce = (distance-l)*s + dampening;
    PVector springForce = direction.mult(totalForce);


    obj1.applyForce(springForce);
    obj2.applyForce(springForce.mult(-1));
  }

  public void display(){
    stroke(0, 0, 255);
    strokeWeight(10);
    line(obj1.pos.x, obj1.pos.y, obj2.pos.x, obj2.pos.y);
  }
}
  public void settings() {  size(800, 800); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "SpringPhysics" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
