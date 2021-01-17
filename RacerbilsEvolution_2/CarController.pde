class CarController{
  
  SensorSystem sensorSystem; // Sensorsystem med indbygget neuralt netværk.
  Car car; // Bilen selv.
  
  CarController(float[] weights, float[] bias){
    car = new Car();
    sensorSystem = new SensorSystem(weights, bias); // Skaber sensorsystem med vægte og bias.
    //println(weights);
  }
  
  void update(){
    sensorSystem.update(car.location, car.velocity); // Opdatere sensorsystemet
    car.update(sensorSystem.getDirection()); // Opdatere bilen
  }
  
  void display(){
    sensorSystem.display(car.location); // Hvis sensorsystem
    car.display(); // Viser bilen.
  }
  
}
