// Blob Natural Selection Workshop
// Gerard Baquer
// baquer.gomez@gmail.com

final int DIM = 500;
final int MAX_SPEEDUP = 3; //3
boolean FAST_SIM = true;
boolean PAUSED =true;
float SIM_SPEED = 1*(100/MAX_SPEEDUP); //%

final int INITIAL_BLOBS=1; //5
final int INITIAL_FOOD=100; //100

final float INITIAL_SPEED = 15; //15
final float INITIAL_SIZE = 50; //50
final float INITIAL_SIGHT = 250; //250

final float SPEED_MUTATION_RATE = 0; //0.1
final float SPEED_MUTATION_MAGNITUDE = 5; //5
final float SIZE_MUTATION_RATE = 0; //0.1
final float SIZE_MUTATION_MAGNITUDE = 5; //5
final float SIGHT_MUTATION_RATE = 0; //0
final float SIGHT_MUTATION_MAGNITUDE = 10; //10

final float ENERGY_COST_FACTOR = 1; //1
final float SIZE_COST_FACTOR = 1; //1
final float SPEED_COST_FACTOR = 1; //1
final float SIGHT_COST_FACTOR = 1; //1

ArrayList<Blob> blob = new ArrayList<Blob>();
Blob b;
Food[] food = new Food[INITIAL_FOOD];

Engine engine = new Engine();
Screen screen = new Screen(30);


FloatDict max_values= new FloatDict();

void setup() {
  //Initialize colors
  colorMode(HSB, 360, 100, 100); 
  
  //Initialize camera
  size(1000, 750, P3D);
  camera(DIM/2, DIM*3/2, DIM*3/4, DIM/2, DIM/3, 0,0, 0, -1);
  
  
  //Initialize max values
  max_values.set("speed",50);
  max_values.set("size",100);
  max_values.set("sight",500);
  max_values.set("age",30);
  
  //Initialize Engine
  engine.add_newborns(INITIAL_BLOBS);
  engine.initialize_round();
}

void draw() {  
  camera(DIM/2, DIM*3/2, DIM*3/4, DIM/2, DIM/3, 0,0, 0, -1);
  //Simulation speed
  
  //Run round
  if(blob.size()>0){
    engine.run_round();
    //Show screen
    screen.show();
  }
}
