class Food {
  PVector pos;
  boolean eaten;

  Food(float x, float y) {
    float z = DIM/100;
    pos = new PVector(x, y, z);
    eaten=false;
  }
  void eat(){
    eaten=true;
  }
  void show() {
    if(!eaten)
    {
      fill(352,55,100);
      noStroke();
      lights();
      pushMatrix(); 
      translate(pos.x, pos.y, pos.z);
      sphere(DIM/100);
      popMatrix();
    }
  }
}
