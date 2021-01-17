// Timer der tæller efter frames og ikke millis.

class Timer{
  
  int savedTime;
  int totalTime;
  
  Timer(){
  }
  
  void start(int totalTimeTemp){
    savedTime = frameCount;
    totalTime = totalTimeTemp;
  }
  
  boolean isFinished(){
    int passedTime = frameCount - savedTime;
    if(passedTime >= totalTime){
      return true;
    }
    return false;
  }
}
