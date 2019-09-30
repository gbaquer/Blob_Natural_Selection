class Screen { 
  int bins;
  float values[];
  int property_id;
  String property;
  String keys[] = new String[5];
  int plot_type;
  boolean on;
  float t_last, t_now;
  
  Screen(int _bins){
    bins=_bins;
    property_id=0;
    keys[0]="speed";
    keys[1]="size";
    keys[2]="sight";
    keys[3]="age";
    keys[4]="pop";
    plot_type=0;
    on=true;
    t_last=millis();
  }
  void show(){
    // KEYBOARD
    //Change plot type and property based on key presses
    t_now=millis();
    if(keyPressed&&((t_now-t_last)>200)){
      t_last=t_now;
      if(key == 'O' || key == 'o')
        on=!on;
      if(key == 'P' || key == 'p')
        PAUSED=!PAUSED;
      if(SIM_SPEED<100&(key == 'F' || key == 'f'))
        SIM_SPEED=SIM_SPEED+5;
       if(SIM_SPEED>5&(key == 'S' || key == 's'))
        SIM_SPEED=SIM_SPEED-5;
      if (key == CODED) {
        if (keyCode == RIGHT) {
          property_id ++;
        } else if (keyCode == LEFT) {
          property_id --;
        } else if(keyCode == UP) {
          plot_type++;
        } else if(keyCode == DOWN){
          plot_type--;
        }
      } 
      if(property_id>4)
        property_id=0;
      if(property_id<0)
          property_id=4;
      if(plot_type>2)
        plot_type=0;
      if(plot_type<0)
          plot_type=2;
    }
    property=keys[property_id];
    
    //MENU
    textSize(DIM/15);
    textAlign(LEFT);
    fill(100,80,65);
    text("day:"+engine.day, DIM+DIM/20, 8 * DIM/10,0);
    textAlign(LEFT);
    for(int i=0; i<keys.length; i++){
      if(i!=property_id)
        fill(0,0,65);
      else
        fill(100,80,65);
      text(keys[i]+":"+int(engine.datalog[engine.day].get(keys[i])), DIM+DIM/20, (i+2)*DIM/10,0);
    }

    
    noStroke();
    //PLOT
    if(on){
      //BOX
      pushMatrix();
      translate(DIM/2, -DIM/5, DIM/16);
      fill(0,0,80);
      lights();
      box(1.3*DIM, DIM/3, DIM/8);
      popMatrix();
      
      // DISTRIBUTION PLOT
      if(plot_type==0){
        if(property=="pop"){
          values=new float[4];
          // Initialize values to 0
          for(int i=0;i<4;i++){
            values[i]=0;
          }
          // Count blobs for each bin
          for(int i=0; i<blob.size();i++){
            b=blob.get(i);
            if(b.energy<=0&&b.hungry)
              values[0]=values[0]+1;
            if(b.hungry&&b.energy>0)
              values[1]=values[1]+1;
            if(!b.hungry&&!b.full)
              values[2]=values[2]+1;
            if(b.full)
              values[3]=values[3]+1;
          }
          // Normalize counts
          for(int i=0;i<4;i++){
            values[i]=(DIM/2)*values[i]/blob.size();
          }
          // Display
          for(int i=0;i<4;i++){
            pushMatrix();
            translate((i+0.5)*DIM/4, -DIM/5, values[i]/2+DIM/8+0.1);
            fill(map(i,0,3,0,300),80,95);
            lights();
            box(DIM/4, DIM/10, values[i]);
            popMatrix(); 
          }
          pushMatrix();
          textSize(DIM/17);
          textAlign(CENTER);
          fill(0,80,65);
          text("DEAD", DIM/4/2, -DIM/20,DIM/8+0.1);
          fill(100,80,65);
          text("HUNGRY", DIM/4+DIM/4/2, -DIM/20,DIM/8+0.1);
          fill(200,80,65);
          text("1 FOOD", DIM*2/4+DIM/4/2, -DIM/20,DIM/8+0.1);
          fill(300,80,65);
          text("2 FOOD", DIM-DIM/4/2, -DIM/20,DIM/8+0.1);
          popMatrix();
        }
        else{
          values=new float[bins];
          // Initialize values to 0
          for(int i=0;i<bins;i++){
            values[i]=0;
          }
          // Count blobs for each bin
          int j;    
          for(int i=0; i<blob.size();i++){
            b=blob.get(i);
            j=int(bins*b.properties.get(property)/max_values.get(property)); //<>//
            if(j>bins-1)
              j=bins-1;
            if(j<0)
              j=0;
            values[j]=values[j]+1;
          }
          // Normalize counts
          int max_value = max(int(values));
          for(int i=0;i<bins;i++){
            values[i]=(DIM/2)*values[i]/max_value;
          }
          // Display
          for(int i=0;i<bins;i++){
            pushMatrix();
            translate((i+0.5)*DIM/bins, -DIM/5, values[i]/2+DIM/8+0.1);
            fill(map(i,0,bins-1,0,300),80,95);
            lights();
            box(DIM/bins+1, DIM/10, values[i]);
            popMatrix(); 
          }
          pushMatrix();
          textSize(DIM/10);
          textAlign(CENTER);
          fill(0,80,65);
          text(0, DIM/bins/2, -DIM/20,DIM/8+0.1);
          fill(150,80,65);
          text(int(max_values.get(property)/2), DIM/2, -DIM/20,DIM/8+0.1);
          fill(300,80,65);
          text(int(max_values.get(property)), DIM-DIM/bins/2, -DIM/20,DIM/8+0.1);
          popMatrix();
        }
      }
      if(plot_type==1){
        // HISTORY PLOT
        values=new float[engine.day+1];
        // Initialize values to 0
        for(int i=0;i<engine.day;i++){
          values[i]=0;
        }
        // Count blobs for each bin
        for(int i=0; i<engine.day;i++){
          values[i]=engine.datalog[i].get(property);
        }
        // Normalize counts
        float max_value = max(values);
        for(int i=0;i<engine.day;i++){
          values[i]=(DIM/2)*values[i]/max_value;
        }
        // Display
        colorMode(RGB); 
        for(int i=0;i<engine.day;i++){
          pushMatrix();
          translate((i+0.5)*DIM/engine.day, -DIM/5, values[i]/2+DIM/8+0.1);
          fill(172,map(i,0,engine.day,0,255),191);
          lights();
          box(DIM/engine.day+1, DIM/10, values[i]);
          popMatrix(); 
        }         
        pushMatrix();
        textSize(DIM/10);
        textAlign(CENTER);
        fill(125);
        text(0, DIM/(engine.day+1)/2, -DIM/20,DIM/8+0.1);
        text(engine.day/2, DIM/2, -DIM/20,DIM/8+0.1);
        text(engine.day, DIM-DIM/(engine.day+1)/2, -DIM/20,DIM/8+0.1);
        popMatrix();
        colorMode(HSB, 360, 100, 100);
      }  
      if(plot_type==2){
        values=new float[blob.size()];
          // Initialize values to 0
          for(int i=0;i<values.length;i++){
            values[i]=0;
          }
          // Count blobs for each bin 
          pushMatrix();
          translate(DIM/2, -DIM/5, DIM/4+DIM/8+0.1);
          fill(0,0,100);
          noLights();
          box(DIM,DIM/20,DIM/2);
          String property1="speed";
          String property2="size";
          if(property_id==0){
            property1="speed";
            property2="size";
          }
          if(property_id==1){
            property1="speed";
            property2="sight";
          }
          if(property_id==2){
            property1="sight";
            property2="size";
          }
            
            
          popMatrix(); 
          for(int i=0; i<blob.size();i++){
            b=blob.get(i);
            pushMatrix();
            translate(map(b.properties.get(property1),0,max_values.get(property1),0,DIM), -DIM/5+DIM/20, map(b.properties.get(property2),0,max_values.get(property2),0,DIM/2)+DIM/8+0.1);
            fill(map(b.properties.get("speed"),0,max_values.get("speed"),0,300),80,95);
            lights();
            sphere(DIM/75);
            popMatrix(); 
          }
          colorMode(RGB);
          pushMatrix();
          textSize(DIM/10);
          textAlign(CENTER);
          fill(125);
          text(property2+" vs. "+property1, DIM/2, -DIM/20,DIM/8+0.1);
          popMatrix();
          colorMode(HSB, 360, 100, 100);
      }
    }
  }
}
