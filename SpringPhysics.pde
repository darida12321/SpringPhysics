

void createRope(PVector pos, int amount){
  PhysicsObject[] balls = new PhysicsObject[amount];

  for(int i = 0; i < amount; i++){
    balls[i] = manager.addObject(new Ball(pos.x+50*i, pos.y, 5, 30));
  }
  for(int i = 0; i < amount-1; i++){
    manager.addSpring(new Spring(balls[i], balls[i+1], 500));
  }
}

void createEinsteinianSolid(PVector pos, int w, int h){
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

void setup() {
  size(800, 800);
  frameRate(60);

  createRope(new PVector(50, 600), 2);
  createRope(new PVector(50, 600), 8);
  createEinsteinianSolid(new PVector(100, 500), 5, 5);
}

void draw(){
  manager.applyGravity(new PVector(0, 600));
  manager.update();

  background(0);
  manager.display();
}

void mousePressed(){
  manager.selectObject(new PVector(mouseX, mouseY));
}
void mouseReleased(){
  manager.deselectObject();
}
