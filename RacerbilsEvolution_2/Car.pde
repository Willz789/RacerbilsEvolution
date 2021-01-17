class Car {

  PVector location = new PVector(startPos.x, startPos.y);
  PVector velocity = new PVector(startVel.x, startVel.y);

  // Farveværdier der styres af bilens fitness, som styres af tid indenfor banen og tid mod den forkerte retning.
  int colorRed = 100; 
  int colorGreen = 100;
  int colorBlue = 50;

  int framesOnTrack = 0;
  int framesWrongDirection = 0;

  // Hvis begge disse værdier er false, så lyser bilen gult, så jeg kan se dem der køre en perfekt runde.
  boolean beenWrongDir = false;
  boolean beenOffTrack = false;

  
  int lastCrossFrameCount = 0; // Bruges til beregning af rundens tid.
  int bestLapFrameCount = 100000; // Bilens hurtigste runde.
  boolean lastGreenDetection = false; // Bruges til at beregne det præcise frameCount, hvor bilen krydser mållinjen.
  boolean crossedGreen = false; // Bruges til at identificere mellem at krydse linjen i starten og efter en runde.
  boolean completedLap = false; // Hvis bilen har kørt en runde, uden at køre den forkerte retning eller komme undenfor banen, så har bilen færdiggjort en runde.

  Car() {
    velocity.normalize().mult(velMax); // Sætter bilens hastighed.
  }

  void update(float turnAngle) {
    rotateCar(turnAngle);
    move();
    onTrack();
    goingCorrectDirection();
    checkFinishLine();
  }
  
  // Bilen roteres afhængigt af sensorerne
  void rotateCar(float turnAngle) {
    velocity.rotate(turnAngle/20);
  }

  // Bilen flytter sig.
  void move() {
    location.add(velocity);
  }

  void display() {

    int fitness = calcFitness(); // Beregner bilens fitness

    // Gør bilen grøn eller rød afhængigt af fitness.
    colorRed = -fitness+100; 
    colorGreen = fitness+100;

    color carColor = color(colorRed, colorGreen, colorBlue);

    // Hvis bilen har kørt perfekt indtil videre, så er den gul.
    if (beenOffTrack == true || beenWrongDir == true) {
      fill(carColor);
      stroke(carColor);
    } else {
      fill(255, 239, 0);
      stroke(255, 239, 0);
    }
    circle(location.x, location.y, 15);
  }
  
  // Tjekker om bilen er på banen.
  void onTrack() {
    color car_track_color = get(int(location.x), int(location.y));
    if (car_track_color != -1 && car_track_color != 0) {
      framesOnTrack++;
    } else {
      beenOffTrack = true;
      framesOnTrack--;
    }
  }

  float lastMiddleToCarHeading = -PI+0.000001; // Indeholder den tidligere position af bilen i forhold til centrum.

  void goingCorrectDirection() {
    // Beregner den nuværende vinkel fra centrum af banen til bilen.
    PVector middle = new PVector(width/2, height/2);
    PVector middleToCar = new PVector(location.x-middle.x, location.y-middle.y);
    float currentAngle = middleToCar.heading();
    
    /* Hvis bilens vinkel i forhold til centrum er faldet, så kører bilen den forkerte vej. (Medmindre bilens vinkel skifter fra -PI til PI,
       hvilket den gør midt på venstre side.*/
    if (currentAngle<lastMiddleToCarHeading && lastMiddleToCarHeading-PI<currentAngle) {
      framesWrongDirection++;
      beenWrongDir = true;
    }
    lastMiddleToCarHeading = currentAngle;
  }

  // Der tjekkes om bilen krydser mållinjen.
  void checkFinishLine() {
    color currentCarTrackColor = get(int(location.x), int(location.y)); // Indeholder farven på vejen, hvor bilen er.
    //println(currentCarTrackColor);
    // Tjekker om farven er grøn som mållinjen er.
    boolean currentGreenDetection = false;
    if (red(currentCarTrackColor)==0 && blue(currentCarTrackColor)==0 && green(currentCarTrackColor)!=0) {
      currentGreenDetection = true;
    }
    // Hvis farven var grøn i sidste frame og ikke i dette frame, så har bilen lige krydset mållinjen.
    if (lastGreenDetection && !currentGreenDetection) {
      // Gælder ikke som en runde, hvis det er første gang den krydser, da det betyder at det er helt i starten af løbet.
      if (crossedGreen == false) {
        lastCrossFrameCount=frameCount;
        crossedGreen = true;
      } else if (frameCount-lastCrossFrameCount<bestLapFrameCount && !beenWrongDir && !beenOffTrack) {
        bestLapFrameCount = frameCount-lastCrossFrameCount;
        completedLap = true;
      }
    }
    lastGreenDetection = currentGreenDetection;
  }

  // beregner bilens fitness.
  int calcFitness() {
    return framesOnTrack-3*framesWrongDirection;
  }
}
