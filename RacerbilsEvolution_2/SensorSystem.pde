class SensorSystem{
  
  ArrayList<Sensor> sensors = new ArrayList<Sensor>(); // Liste af sensorer
  
  float[] weights; // Bilens vægte til sensorer
  float[] bias; // Bilens bias
  
  SensorSystem(float[] weights_, float[] bias_){
    weights = weights_;
    bias = bias_;
    
    // Skaber bilens sensorer, hvor deres retning er mappet efter antallet af sensorer på bilen.
    for(int i = 0; i < sensorsPrCar; i++){
      float angle = map(i, 0, sensorsPrCar-1, -PI/4, PI/4);
      sensors.add(new Sensor(angle));
    }
  }
  
  // Beregner hver sensors position hver frame.
  void update(PVector carPos, PVector carVel){
    for(Sensor s : sensors){
      s.calcPos(carPos, carVel);
    }
  }
  
  // Displayer sensorerne.
  void display(PVector carPos){
    for(Sensor s : sensors){
      s.display(carPos);
    }
  }
  
  // Optager signaler fra hver sensor, hvor varians er fra -2 til 2. Hvis vægten + bias er positiv, så drejes der til højre og ellers til venstre.
  float getDirection(){
    float turnLeft = 0;
    float turnRight = 0;
    for(int i = 0; i < sensors.size(); i++){
      if(sensors.get(i).onTrack() != true){
        turnLeft+=weights[i];
        turnRight+=weights[i+sensorsPrCar];
      }
    }
    turnLeft+=bias[0];
    turnRight+=bias[1];
    return turnLeft+turnRight;
  }
}
