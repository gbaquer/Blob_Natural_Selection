class Blob {
  PVector pos;
  
  float energy_cost;
  PVector direction;
  boolean hungry;
  boolean full;
  int target;
  color col;
  float energy;
  float current_speed;
  boolean active;
  int id;

  //DIM = 500
  FloatDict properties = new FloatDict();
    
  Blob(float _speed,float _size,float _sight,int _id){
    //MUTATION & UPDATE TRAITS
    if(random(0,1)<SPEED_MUTATION_RATE){
      _speed=_speed+randomGaussian()*SPEED_MUTATION_MAGNITUDE;
    }
    if(_speed<1)
      _speed=1;
    properties.set("speed",_speed);
    if(random(0,1)<SIZE_MUTATION_RATE){
      _size=_size+randomGaussian()*SIZE_MUTATION_MAGNITUDE;
    }
    if(_size<1)
      _size=1;
    properties.set("size",_size);
    if(random(0,1)<SIGHT_MUTATION_RATE){
      _sight=_sight+randomGaussian()*SIGHT_MUTATION_MAGNITUDE;
    }
    if(_sight<1)
      _sight=1;
    properties.set("sight",_sight);
    
    properties.set("age",0.0);
    
    col = color(map(properties.get("speed"),0,max_values.get("speed"),0,300),75,100);
    id=_id;
    
    
  }
  void update(float x, float y){
    float z = properties.get("size")/2;
    pos = new PVector(x, y, z);
    current_speed=properties.get("speed")*MAX_SPEEDUP*SIM_SPEED/100;
    energy_cost=ENERGY_COST_FACTOR*(pow(SIZE_COST_FACTOR*properties.get("size")/4,3)*pow(SPEED_COST_FACTOR*properties.get("speed")/12,2)+ SIGHT_COST_FACTOR*properties.get("sight"))/4*MAX_SPEEDUP*SIM_SPEED/100;
    float next_x =-1;
    float next_y =-1;
    while(next_x>DIM||next_x<0||next_y>DIM||next_y<0){
      float angle = random(0,2*PI);
      direction = new PVector(cos(angle), sin(angle), 0);
      next_x = x + current_speed*direction.x;
      next_y = y + current_speed*direction.y;
    }    
    hungry = true;
    full=false;
    active=true;
    target=-1;
    energy=5000;
    properties.add("age",1.0);
    
  }
  
  void move() {
    // DEAD or FULL
    active=!(energy<=0 || (full && (pos.x>DIM||pos.x<0||pos.y>DIM||pos.y<0)));
    if(energy<=0 || (full && (pos.x>DIM||pos.x<0||pos.y>DIM||pos.y<0)))
      current_speed=0;
    if(current_speed!=0&(pos.x>DIM||pos.x<0))
      direction.x=-direction.x;
    if(current_speed!=0&(pos.y>DIM||pos.y<0))
      direction.y=-direction.y;
    if(pos.x>DIM)
      pos.x=DIM;
    if(pos.x<0)
      pos.x=0;
    if(pos.y>DIM)
      pos.y=DIM;
    if(pos.y<0)
      pos.y=0;
    
    float x = pos.x + current_speed*direction.x;
    float y = pos.y + current_speed*direction.y;
    pos = new PVector(x, y, pos.z);
    show();
    
    //LOOKING FOR FOOD    
    //Eat nearby food
    if(!full)
    {
      for (int i = 0; i < INITIAL_FOOD; i++) {
        if(!food[i].eaten)
        {
          float distance = dist(food[i].pos.x,food[i].pos.y,pos.x,pos.y);
          if(distance<(properties.get("size")/2+DIM/100))
          {
            food[i].eat();
            if(hungry)
              hungry=false;
            else
              full=true;
          }
          if(distance<properties.get("sight"))
          {
            target=i;
            x = food[target].pos.x-pos.x;
            y = food[target].pos.y-pos.y;      
            direction = new PVector(x/mag(x,y),y/mag(x,y), 0);
          }
        }
      }
      for (int i = 0; i < blob.size(); i++) {
        b=blob.get(i);
        if(id!=b.id&&b.energy>0){   
          float distance = dist(b.pos.x,b.pos.y,pos.x,pos.y);
          //Prey spotted
          if(properties.get("size")>b.properties.get("size")*1.7){          
            if(distance<properties.get("size")/2&&!b.full)
            {
              b.energy=0; //<>//
              b.hungry=true;
              hungry=false;
              full=true;
            }
            if(distance<properties.get("sight"))
            {
              target=i;
              x = b.pos.x-pos.x;
              y = b.pos.y-pos.y;      
              direction = new PVector(x/mag(x,y),y/mag(x,y), 0);
            }
          }
          //Predator spotted
          if(properties.get("size")*1.7<b.properties.get("size")){          
            if(distance<properties.get("sight")&&b.current_speed>0)
            {
              target=i;
              x = b.pos.x-pos.x;
              y = b.pos.y-pos.y;    
              float angle = acos(x*direction.x + y*direction.y);
              float new_x;
              if(angle<PI/2){
                new_x=(cos(PI/2)-y)/x;
                direction = new PVector(-new_x/mag(new_x,1),-1/mag(new_x,1), 0);
              }
              if(angle>2*PI-PI/2){             
                new_x=(cos(PI-PI/2)-y)/x;
                direction = new PVector(-new_x/mag(new_x,1),-1/mag(new_x,1), 0);
              }
              
            }
          }
          
        }
      }
      energy=energy-energy_cost;
    }
    
  }

  void show() {
    if(energy<=0&&hungry){
      //Dead
      fill(0,0,85);
      pushMatrix(); 
      translate(pos.x, pos.y, pos.z+properties.get("size")/2);
      box(properties.get("size")/4,properties.get("size")/4,2*properties.get("size"));
      popMatrix();
      pushMatrix(); 
      translate(pos.x, pos.y, pos.z+properties.get("size")*3/4+properties.get("size")/8);
      box(properties.get("size"),properties.get("size")/4,properties.get("size")/4);
      popMatrix();
    }
    else
    {
      fill(col);
      noStroke();
      lights();
      //Body
      pushMatrix(); 
      translate(pos.x, pos.y, pos.z);
      sphere(properties.get("size")/2);
      popMatrix();
      //Head
      pushMatrix();
      translate(pos.x, pos.y, pos.z+properties.get("size")/2);
      sphere(0.8*properties.get("size")/2);
      popMatrix();
      //Eyes
      fill(0);    
      pushMatrix(); 
      translate(pos.x+0.65*(direction.x+0.35*direction.y)*properties.get("size")/2, pos.y+0.65*(direction.y-0.35*direction.x)*properties.get("size")/2, pos.z+properties.get("size")/2);
      sphere(properties.get("size")/10);
      popMatrix();
      pushMatrix();
      translate(pos.x+0.65*(direction.x-0.35*direction.y)*properties.get("size")/2, pos.y+0.65*(direction.y+0.35*direction.x)*properties.get("size")/2, pos.z+properties.get("size")/2);
      sphere(properties.get("size")/10);
      popMatrix();
    }
  }
}
