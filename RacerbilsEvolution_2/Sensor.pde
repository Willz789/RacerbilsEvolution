class Sensor{
  
  float angle; // Vinklen som sensoren skal pege i forhold til bilens retning.
  PVector pos = new PVector(); // Sensorens position.
  
  Sensor(float angle_){
    angle = angle_;
  }
  
  // Beregner sensorens position ud fra bilens retning, bilens position og sensorens retning i forhold til bilen.
  void calcPos(PVector carPos, PVector carVel_){
    PVector carVel = new PVector(carVel_.x, carVel_.y);
    PVector direction = carVel.normalize().mult(sensorReach).rotate(angle);
    pos.set(carPos.x, carPos.y).add(direction);
  }
  
  // Displayer sensoren. (Rød hvis udenfor banen og ellers grøn.
  void display(PVector carPos){
    stroke(0);
    line(carPos.x, carPos.y, pos.x, pos.y);
    if(onTrack()){
      fill(0,255,0);
    } else {
      fill(255,0,0);
    }
    circle(pos.x, pos.y, 5);
  }
  
  // Beregner om sensoren er på banen eller ej.
  boolean onTrack(){
    color color_track_pos = get(int(pos.x), int(pos.y));
    //println(color_track_pos);
    if(color_track_pos != -1 && color_track_pos != 0){
      return true;
    }
    return false;
  }
  
}
