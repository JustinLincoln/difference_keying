/**
 * based on the "Background Subtraction" sample by Golan Levin. 
 *
 **/
import processing.video.*;

final String backgroundFilename = "landscape-02.jpg";

PImage backgroundImage, newBackgroundImage;
PImage maskImage, programmeVideoImage; 
Capture video;

final float THRESHOLD_DELTA = 0.01;
float currentThreshold = 0.5;

void setup() {
  size(1280, 720); 

  String camera640x360a30fps = findThisCameraMode("size=640x360,fps=30");
  video = new Capture(this, width / 2, height / 2, camera640x360a30fps);

  video.start();  
  backgroundImage = createImage(video.width, video.height, RGB);
  programmeVideoImage = createImage(video.width, video.height, RGB);
  maskImage = createImage(video.width, video.height, RGB);

  newBackgroundImage = loadImage(backgroundFilename);
}

String findThisCameraMode(String s) {
  String[] cameras = Capture.list();
  
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();  // game up - quit!
  }
  
  int index = 0;
  while ((index < cameras.length) && (cameras[index].indexOf(s) == -1)) {
    index += 1;
  }
  
  return (index == cameras.length) ? null : cameras[index];
}

void draw() {
  if (video.available()) {
    video.read(); 

    updateVideoMask();
    programmeVideoImage.mask(maskImage);

    image(newBackgroundImage, 0, 0, width/2, height/2);
    image(programmeVideoImage, 0, 0, width/2, height/2);  

    image(maskImage, width/2, 0, width/2, height/2);
    image(video, 0, height/2, width/2, height/2);
    image(backgroundImage, width/2, height/2, width/2, height/2);
  }
}

void updateVideoMask() {
  programmeVideoImage.set(0, 0, video);
  
  maskImage.set(0, 0, video);
  
  // blend two image together
    
  maskImage.blend(backgroundImage, 0, 0, video.width, video.height, 
                                   0, 0, video.width, video.height, 
                                   DIFFERENCE);
  maskImage.filter(GRAY);
  maskImage.filter(THRESHOLD, currentThreshold);
  maskImage.filter(DILATE);
  maskImage.filter(BLUR, 1);
}


void keyPressed() {
  switch (key) {
  case ' ':
    backgroundImage.set(0, 0, video);
    break;
  case CODED:
    if (keyCode == UP) {
      currentThreshold = min(currentThreshold + THRESHOLD_DELTA, 1.0);
    } else if (keyCode == DOWN) {
      currentThreshold = max(0.0, currentThreshold - THRESHOLD_DELTA);
    }
    break;
  }
}