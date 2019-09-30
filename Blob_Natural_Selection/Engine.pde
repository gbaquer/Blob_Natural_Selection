class Engine {
  int day;
  int active_blobs;
  boolean end_of_round,counting;
  float t_now,t_end_of_round;
  int next_id;
  
  FloatDict datalog[] = new FloatDict[1000];

  Engine() {
    day=0;
    end_of_round=false;
    counting=false;
    next_id=0;
  }
  void initialize_blobs()
  {
    //BLOBS
    float total_speed=0, total_size=0, total_sight=0, total_age=0;
    for (int i = 0; i < blob.size(); i++) {
      boolean roll_1 = random(0,1)<0.5;
      boolean roll_2 = random(0,1)<0.5;
      float roll_3 = random(0,DIM);
      float x;
      float y;
      if(roll_1)
      {
        x=roll_3;
        if(roll_2)
          y=0;
        else
          y=DIM;
      }
      else
      {
        y=roll_3;
        if(roll_2)
          x=0;
        else
          x=DIM;
      }
      b=blob.get(i);
      b.update(x,y);
      total_speed= total_speed+b.properties.get("speed");
      total_size= total_size+b.properties.get("size");
      total_sight= total_sight+b.properties.get("sight");
      total_age= total_age+b.properties.get("age");
    }
    datalog[day]=new FloatDict();
    datalog[day].set("speed",total_speed/blob.size());
    datalog[day].set("size",total_size/blob.size());
    datalog[day].set("sight",total_sight/blob.size());
    datalog[day].set("age",total_age/blob.size());
    datalog[day].set("pop",blob.size());
  }
  void add_newborns(int newborn_count)
  {
    //BLOBS
    for (int i = 0; i < newborn_count; i++) {
      blob.add(new Blob(INITIAL_SPEED,INITIAL_SIZE,INITIAL_SIGHT,next_id));
      next_id++;
    }
  }
  void initialize_round()
  {
    //BLOBS
    initialize_blobs();
    //FOOD
    for (int i = 0; i < INITIAL_FOOD; i++) {
      food[i] = new Food(random(DIM*0.1,DIM*0.9), random(DIM*0.1,DIM*0.9));
    } //<>//
    end_of_round=false;
  }
  void run_round()
  {
    background(0,0,25);
    pushMatrix(); 
    translate(DIM/2, DIM/2, 0);
    fill(0,0,100);
    lights();
    box(DIM, DIM, 0);
    popMatrix();
    if(!end_of_round){
      active_blobs=blob.size();
      for (int i = 0; i < blob.size(); i++) {
        b=blob.get(i);
        if(b.energy<=0||b.full)
            active_blobs--;
        if(counting||PAUSED)
          b.show();
        else
          b.move();              
      }
      for (int i = 0; i < INITIAL_FOOD; i++) {
        food[i].show();
      } 
      if(active_blobs<=0)
      {  
        if(!counting){
          counting=true;
          t_end_of_round=millis();
        }
        t_now=millis();
        if(FAST_SIM||(t_now-t_end_of_round)>6){
          end_of_round=true;
          counting=false;
        }
      }
    }
    else{              
        int i=0,dead=0,reproduce=0,initial=0,last=0;
        boolean ok;
        ArrayList<Blob> blob_newborns = new ArrayList<Blob>();
        initial=blob.size();
        while(i<blob.size())
        {
          
          b=blob.get(i);
          if(b.hungry)
          {
            dead++;
            //DIE
            blob.remove(i);
          }
          else
          {
            if(b.full)
            {
              reproduce++;
              //REPRODUCE
              blob_newborns.add(new Blob(b.properties.get("speed"),b.properties.get("size"),b.properties.get("sight"),next_id));
              next_id++;
            }
            i++;
          }
        }
        for(i = 0; i<blob_newborns.size();i++)
        {
          blob.add(blob_newborns.get(i));
        }
        last=blob.size();
        ok=((initial-dead+reproduce) == last);
        print(ok+"\t"+((initial-dead+reproduce)-last)+"\tDAY "+day + ": " +initial+" - " + dead + " + " + reproduce + " = " + last + "\n");
        day++; //<>//
        initialize_round();
        end_of_round=false;
      
    }
  }
}
