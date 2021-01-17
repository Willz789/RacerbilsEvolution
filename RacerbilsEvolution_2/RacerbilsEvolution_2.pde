int PopulationSize = 150; // Antal biler
float varians = 2; // varians mellem vægtenes og biasernes værdier
PVector startPos = new PVector(240, 100); 
PVector startVel = new PVector(1, 0); // Bestemmer startretningen
float velMax = 5; // Hastigheden bilerne kører med

ArrayList<CarController> carControllers = new ArrayList<CarController>(); 
int sensorsPrCar = 4; // Man vælger selv, hvor sensorer bilerne skal have
float sensorReach = 100; // Sensorernes rækkevidde.

PImage track; // Billede af banen. Har selv tegnet en.

Timer timer = new Timer(); // Bruges til tiden mellem de genetiske algoritmer
int framesBetweenSimulation = 900; // tid mellem de genetiske algoritmer (Jeg tæller i frames og ikke millis, grundet lag med mange biler)

int mutationChance = 20; // procentchance for at mutere en vægts eller biases værdi

ArrayList<Integer> bestLapPrGeneration = new ArrayList<Integer>(); // Liste af beste runde pr. generation

boolean showSimulation = true; // Bestemmer om simulationen vises eller diagrammet over bedste runder.

void setup() {
  size(800, 800);
  track = loadImage("track.png");
  track.resize(width, height);
  for (int i = 0; i < PopulationSize; i++) {
    // Random vægte og bias i første generation
    float[] weights = new float[2*sensorsPrCar];
    for (int j = 0; j < weights.length; j++) {
      weights[j] = random(-varians, varians);
    }
    float[] bias = new float[2];
    for (int j = 0; j < bias.length; j++) {
      bias[j] = random(-varians, varians);
    }
    
    // Skaber nye biler
    carControllers.add(new CarController(weights, bias));
  }
  
  // Starter timer, som bestemmer intervaller mellem genetiske algoritmer
  timer.start(framesBetweenSimulation);
}


void draw() {
  image(track, 0, 0);
  // Jeg kører update() på alle biler før jeg kører display(), da update() afhænger af billedet
  for (CarController carController : carControllers) {
    if (carController.car.calcFitness() >= 0) { // Mindsker lag
      carController.update();
    }
  }
  if (showSimulation == true) { // displayer kun bilerne, hvis showSimulation er true
    for (CarController carController : carControllers) {
      if (carController.car.calcFitness() >= 0) { // Mindsker lag.
        carController.display();
      }
    }
    fill(0);
    textSize(20);
    textAlign(CENTER);
    text("Click to see generational laptimes", width/2, height/2+30);
  } else { // Hvis showSimulation er false, så vises grafen over bedste runde pr. generation.
    background(255);
    int generationsTotal = bestLapPrGeneration.size();
    float pillarWidth = 40;
    fill(0);
    strokeWeight(1);
    stroke(255);
    rectMode(CENTER);
    float scl = 1.5;
    for (int i = 0; i < generationsTotal; i++) {
      rect(pillarWidth/2+i*pillarWidth, height-bestLapPrGeneration.get(i)*scl/2, pillarWidth, bestLapPrGeneration.get(i)*scl);
      textSize(16);
      textAlign(CENTER);
      text(bestLapPrGeneration.get(i), pillarWidth/2+i*pillarWidth, height-bestLapPrGeneration.get(i)*scl-10);
    }
    fill(0);
    textSize(20);
    textAlign(CENTER);
    text("Click to see simulation", width/2, height/2+30);
  }

  // Efter timeren er færdig, så starter den genetiske algoritme
  if (timer.isFinished()) {
    geneticAlgorithm();
    timer.start(framesBetweenSimulation);
  }
  
  // Timer der viser frames til næste genetiske algoritme
  fill(0);
  textSize(20);
  textAlign(CENTER);
  int nextGenIn = timer.totalTime - (frameCount - timer.savedTime);
  String textNextGenIn = "Frames until next generation: " + nextGenIn;
  text(textNextGenIn, width/2, height/2);
}

void mouseClicked() {
  showSimulation = !showSimulation;
}

/*---------Genetiske algoritme-------------*/

void geneticAlgorithm() {
  bestLapPrGeneration.add(calcBestLap()); // Tilføjer den hurtigste runde pr. generation til en liste
  ArrayList<ArrayList<float[]>> matingPool = createMatingPool(); // Skaber matingpool til næste generation
  ArrayList<CarController> newCarControllers = new ArrayList<CarController>(); // Liste der indeholder biler til næste generation.
  for (int i = 0; i < PopulationSize; i++) {
    ArrayList<float[]> newCar = createNewCar(matingPool); // Skaber en ny bil
    ArrayList<float[]> newCarMutated = mutateNewCar(newCar); // Mutere hver bil
    // Skaber nye biler ud fra nye weights og bias
    float[] newWeights = newCarMutated.get(0);
    float[] newBias = newCarMutated.get(1);
    newCarControllers.add(new CarController(newWeights, newBias));
  }
  carControllers = newCarControllers; // Sætter nye generation af biler i brug.
}

ArrayList<ArrayList<float[]>> createMatingPool() {
  // Jeg skaber en matingpool for både weights og bias
  ArrayList<float[]> matingPoolWeights = new ArrayList<float[]>(); 
  ArrayList<float[]> matingPoolBiases = new ArrayList<float[]>();
  for (CarController carController : carControllers) {
    if (carController.car.completedLap) { // De tilføjes hvis de har kørt en runde uden af køre uden for banen eller den forkerte vej.
      for (int i = 0; i < int(map(carController.car.bestLapFrameCount, 0, 500, 5000, 0))/10; i++) {
        matingPoolWeights.add(carController.sensorSystem.weights);
        matingPoolBiases.add(carController.sensorSystem.bias);
      }
    } else {
      if (carController.car.calcFitness() > 0) { // Hvis deres fitness er større end 0, så bliver de også føjet til matingpool, bare ikke lige så mange gange.
        for (int i = 0; i < carController.car.calcFitness(); i++) {
          matingPoolWeights.add(carController.sensorSystem.weights);
          matingPoolBiases.add(carController.sensorSystem.bias);
        }
      }
    }
  }
  ArrayList<ArrayList<float[]>> matingPool = new ArrayList<ArrayList<float[]>>();
  matingPool.add(matingPoolWeights);
  matingPool.add(matingPoolBiases);
  return matingPool;
}

ArrayList<float[]> createNewCar(ArrayList<ArrayList<float[]>> matingPool) {
  // Vælger to tilfældige biler fra matingpool.
  ArrayList<float[]> weightsList = matingPool.get(0);
  ArrayList<float[]> biasesList = matingPool.get(1);
  int a = int(random(0, weightsList.size()));
  int b = int(random(0, biasesList.size()));
  float[] weightParentA = weightsList.get(a);
  float[] weightParentB = weightsList.get(b);
  float[] biasParentA = biasesList.get(a);
  float[] biasParentB = biasesList.get(b);
  
  // Tilføjer hver anden vægtværdi fra hver parentBil til ny liste
  ArrayList<Float> newWeightsList = new ArrayList<Float>();
  for (int i = 0; i < weightParentA.length; i++) {
    if (i%2==0) {
      newWeightsList.add(weightParentA[i]);
    } else {
      newWeightsList.add(weightParentB[i]);
    }
  }
  float[] newWeights = new float[newWeightsList.size()];
  for (int i = 0; i < newWeights.length; i++) {
    newWeights[i] = newWeightsList.get(i);
  }
  
  // Tilføjer hver anden biasværdi fra hver parentBil til ny liste
  ArrayList<Float> newBiasList = new ArrayList<Float>();
  for (int i = 0; i < biasParentA.length; i++) {
    if (i%2==0) {
      newBiasList.add(biasParentA[i]);
    } else {
      newBiasList.add(biasParentB[i]);
    }
  }
  float[] newBias = new float[newBiasList.size()];
  for (int i = 0; i < newBias.length; i++) {
    newBias[i] = newBiasList.get(i);
  }
  // Returnere en arrayliste der indeholder to liste (en med vægt og en med bias) 
  ArrayList<float[]> newCar = new ArrayList<float[]>();
  newCar.add(newWeights);
  newCar.add(newBias);
  return newCar;
}

// Her muteres vægt og bias, hvis et tilfældigt int fra 0 til og med 99 er indenfor mutationschancens interval.
ArrayList<float[]> mutateNewCar(ArrayList<float[]> newCarNotMutated) {
  float[] weights = new float[newCarNotMutated.get(0).length];
  for (int i = 0; i < weights.length; i++) {
    if (int(random(0, 100)) < mutationChance) {
      int randomInt = int(random(0, 2));
      if (randomInt == 0) {
        weights[i]-=1;
      } else {
        weights[i]+=1;
      }
    }
  }
  float[] bias = new float[newCarNotMutated.get(1).length];
  for (int i = 0; i < bias.length; i++) {
    if (int(random(0, 100)) < mutationChance) {
      int randomInt = int(random(0, 2));
      if (randomInt == 0) {
        bias[i]-=1;
      } else {
        bias[i]+=1;
      }
    }
  }
  ArrayList<float[]> newCar = new ArrayList<float[]>();
  newCar.add(weights);
  newCar.add(bias);
  return newCar;
}

// Her udregnes den bedste kørte runde pr. generation.
int calcBestLap() {
  int bestLap = framesBetweenSimulation;
  for (CarController carController : carControllers) {
    Car car = carController.car;
    if (car.completedLap) {
      if (car.bestLapFrameCount < bestLap && car.bestLapFrameCount > 100) {
        bestLap = car.bestLapFrameCount;
      }
    }
  }
  return bestLap;
}
