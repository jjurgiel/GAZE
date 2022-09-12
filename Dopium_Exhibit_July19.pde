import org.openkinect.freenect.*;
import org.openkinect.processing.*;
KinectTracker tracker;
Kinect kinect;

PImage pandaimg;
ArrayList<Panda> PandaList = new ArrayList<Panda>();
int[][] pandaArray = {{400,400},{800,400},{1200,400},{1600,400}, {300,800},{700,800},{1100,800},{1500,800}};
//Eyes
float Ldistx, Ldisty, Rdistx, Rdisty, newLx, newLy, newRx, newRy;
int centerLx = 800; int centerLy = 800; int centerRx = 1100; int centerRy = 800;
int eyediam = 200; int pupildiam = 100; int objdist = 400;
//Background
int counter = 1;

int vidwidth = 2400;
int vidheight = 1350;
float xvalfinal;

void setup(){
  fullScreen(2);
  surface.setSize(vidwidth,vidheight);
  //Set up Kinect
  kinect = new Kinect(this);
  tracker = new KinectTracker();
  kinect.initVideo();
  //Create Panda array
  for (int i=0;i<8;i++){
      pandaimg = loadImage("logo-01_pixle_small_4.png");
    //pandaimg = loadImage("4.png");
    PandaList.add(new Panda(pandaArray[i][0],pandaArray[i][1], pandaimg));
  }
}

void draw(){
  background(0); //<>//
//////////////////////////////Drawing Background Shape///////////////////////////////////
  PImage testimg = kinect.getVideoImage();
  int delx = 7;
  int dely = 7;
  float xscale = vidwidth/float(kinect.width);
  float yscale = vidheight/float(kinect.height);
  strokeWeight(2);
  for (int x = 0; x < kinect.width; x=x+delx) {
    for (int y = 0; y < kinect.height; y=y+dely) {
      color c = testimg.pixels[x + y * kinect.width];
      int grayline = int((0.3*red(c)) + (0.59*green(c)) + (0.11*blue(c)));
      stroke(grayline);
      // scale from kinect camera size
      if (x%2 == 1){line(xscale*x,yscale*y,xscale*x+xscale*delx,yscale*y+yscale*dely);}
      if ((x%2 == 0) && (y%2 == 0)){line(xscale*x,yscale*y,xscale*x+xscale*delx,yscale*y);}
      if (y%2 == 1){line(xscale*x,yscale*y,xscale*x-xscale*delx,yscale*y+yscale*dely);}
      
    }
  }
//////////////////////////DRAWING PANDAS////////////////////////////////////////////////
  for (int z=0;z<8;z++){
    Panda part = PandaList.get(z);
    tracker.track();
    PVector v1 = tracker.getPos();
    float pixelcount = tracker.getPixelCount();
    //If enough pixels within depth
    if (pixelcount < 12000){
      part.move();
      float tempvel;
      for(int i=0; i<8; i++){
          if(i!=z) {
            Panda part2 = PandaList.get(i);
            float distance = dist(part.xpos + (part.pandawidth/2),part.ypos + (part.pandaheight/2),part2.xpos+(part2.pandawidth/2),part2.ypos+(part2.pandaheight/2));
            if (distance < 200){//(part.pandaheight/2 + part2.pandaheight/2)){//250
              tempvel = part.velocity.x;
              part.velocity.x = part2.velocity.x;
              part2.velocity.x = tempvel;
              tempvel = part.velocity.y;
              part.velocity.y = part2.velocity.y;
              part2.velocity.y = tempvel;
              part.xpos += part.velocity.x;
              part.ypos += part.velocity.y;
              part2.xpos += part2.velocity.x;
              part2.ypos += part2.velocity.y;              
            }
          }
      }
    }

    part.draweyes(v1, pixelcount);
    part.display(); 
  }
//  tracker.track();
//  PVector v1 = tracker.getPos();
  //int pixelcount = tracker.getPixelCount();
//  ellipse(((v1.x/640)*vidwidth), ((v1.y/480)*vidheight), 20, 20);
 //<>//
}



///////////////////////////////////////////////////////////////////////////////////////////
class Panda{
  float xpos;
  float ypos;
  float pandawidth;
  float pandaheight;
  float pupildiam;
  PVector velocity;
  float lefteyex; float lefteyey; float righteyex; float righteyey;
  PImage panda;
  //float pandawidth = 400;
  float widthval;
 // float pandaheight = 350;
  float heightval;
  float eyediam;//60
  
  Panda(float tempXpos, float tempYpos, PImage mypanda){
   xpos = tempXpos;
   ypos = tempYpos;
   panda = mypanda;
   this.velocity = new PVector(int(random(-35,35)),int(random(-35,35)));
   this.pandawidth = 350;
   this.pandaheight = this.pandawidth * 0.9;
   this.widthval = this.pandawidth / 1557;
   this.heightval = this.pandaheight / 1356;
   this.eyediam = 80;//*(this.pandawidth/400);
   this.pupildiam = 30;//*(this.pandawidth/400);
  }
  
  void display(){
    image(panda, xpos, ypos, pandawidth, pandaheight);
  }
  
  void move(){
    xpos += velocity.x;
    ypos += velocity.y;
    //top 100, left 240, right 300, bottom 160
    if ((xpos + pandawidth > 2400+widthval*300) && (velocity.x > 0)){ //2400
      velocity.x = -1*velocity.x;
      while ((xpos + pandawidth > 2400+widthval*300) && (velocity.x > 0)){
        xpos += velocity.x;
      }
    }
    if ((xpos < 0-widthval*240) && (velocity.x < 0)){
      velocity.x = -1*velocity.x;
      while ((xpos < 0-widthval*240) && (velocity.x < 0)){
        xpos += velocity.x;
      }
    }
    if ((ypos + pandaheight > 1350+heightval*160) && (velocity.y > 0)){ //1350
      velocity.y = -1*velocity.y;
      while ((ypos + pandaheight > 1350+heightval*160) && (velocity.y > 0)){
        ypos += velocity.y;
      }
    }    
    if ((ypos < 0-heightval*100) && (velocity.y < 0)){
      velocity.y = -1*velocity.y;
      while ((ypos < 0-heightval*100) && (velocity.y < 0)){
        ypos += velocity.y;
      }
    }      
  }

  void draweyes(PVector v1, float pixelcount){
    stroke(0,0,0);
    fill(255,255,255); ellipse(xpos+0.34*pandawidth,ypos+0.494*pandaheight,eyediam,eyediam);
    fill(255,255,255); ellipse(xpos+0.63*pandawidth,ypos+0.494*pandaheight,eyediam,eyediam);
  //  int pupildiam = 40; //30
    float objdist = tracker.getAvgDepth();
    //*(1+(objdist/800))*(1+(50000/(pixelcount+1)))
  //Left Eye  
  if (pixelcount > 10000){
    Ldistx = xpos+0.34*pandawidth-((v1.x/640)*vidwidth);
    Ldisty = (ypos+0.494*pandaheight-((v1.y/480)*vidheight))+((-objdist)+(pixelcount/80));;//(1+pixelcount/30000);
    newLx = Ldistx/((sqrt(sq(Ldistx)+sq(1.5*objdist))/((eyediam/2)-(pupildiam/2))));
    newLy = Ldisty/((sqrt(sq(2*objdist)+sq(Ldisty))/((eyediam/2)-(pupildiam/2))));
  }else{
    newLx = 0;
    newLy = 0;
    objdist=1000;
  }//(30*(log(ypos)*pixelcount/(1700*objdist))
    fill(0,0,0); ellipse(xpos+0.34*pandawidth-newLx,ypos+0.494*pandaheight-newLy,pupildiam,pupildiam);
    fill(255,255,255); ellipse(xpos+0.34*pandawidth-newLx,ypos+0.494*pandaheight-newLy,pupildiam/3,pupildiam/3);
    
  //Right Eye
    if (pixelcount > 10000){
    Rdistx = xpos+0.63*pandawidth-((v1.x/640)*vidwidth);
    Rdisty = ((ypos+0.494*pandaheight-((v1.y/480)*vidheight)))+((-objdist)+(pixelcount/80));//(1+pixelcount/50000);
    newRx = Rdistx/((sqrt(sq(Rdistx)+sq(1.5*objdist))/((eyediam/2)-(pupildiam/2))));
    newRy = Rdisty/((sqrt(sq(2*objdist)+sq(Rdisty))/((eyediam/2)-(pupildiam/2))));
      }else{
    newRx = 0;
    newRy = 0;
    objdist=1000;
  }
    fill(0,0,0); ellipse(xpos+0.63*pandawidth-newRx,ypos+0.494*pandaheight-newRy,pupildiam,pupildiam);
    fill(255,255,255); ellipse(xpos+0.63*pandawidth-newRx,ypos+0.494*pandaheight-newRy,pupildiam/3,pupildiam/3);
    
 //   fill(255,255,255);
//    text("xscale: "  + objdist + "    " + pixelcount + "    " +
//     "UP increase threshold, DOWN decrease threshold", 10, 500);
  } 
}


///////////////////////////////////////////////////////////////////////////////////////////
class KinectTracker {

  // Depth threshold
  int threshold = 900;

  // Raw location
  PVector loc;

  // Interpolated location
  PVector lerpedLoc;
  float count;
  // Depth data
  int[] depth;
  float avgDepth;  
  // What we'll show the user
  PImage display;
   
  KinectTracker() {
    // This is an awkard use of a global variable here
    // But doing it this way for simplicity
    kinect.initDepth();
    kinect.enableMirror(true);
    // Make a blank image
    display = createImage(kinect.width, kinect.height, RGB);
    // Set up the vectors
    loc = new PVector(0, 0);
    lerpedLoc = new PVector(0, 0);
    count  = 0;
    
  }

  void track() {
    // Get the raw depth as array of integers
    depth = kinect.getRawDepth();
    
    // Being overly cautious here
    if (depth == null) return;

    float sumX = 0;
    float sumY = 0;
    count = 0;
    avgDepth = 0;
    
    for (int x = 0; x < kinect.width; x++) {
      for (int y = 0; y < kinect.height; y++) {
        
        int offset =  x + y*kinect.width;
        // Grabbing the raw depth
        int rawDepth = depth[offset];

        // Testing against threshold
        if (rawDepth < threshold) {
          sumX += x;
          sumY += y;
          count++;
          avgDepth += rawDepth;
        }
      }
    }
    // As long as we found something
    if (count != 0) {
      loc = new PVector(sumX/count, sumY/count);
      avgDepth = avgDepth / count;
    }

    // Interpolating the location, doing it arbitrarily for now
    lerpedLoc.x = PApplet.lerp(lerpedLoc.x, loc.x, 0.3f);
    lerpedLoc.y = PApplet.lerp(lerpedLoc.y, loc.y, 0.3f);
  }
  float getAvgDepth(){
    return avgDepth;
  }
  float getPixelCount() {
    return count;
  }
  
  PVector getLerpedPos() {
    return lerpedLoc;
  }

  PVector getPos() {
    return loc;
  }

  void display() {
    PImage img = kinect.getDepthImage();

    // Being overly cautious here
    if (depth == null || img == null) return;

    // Going to rewrite the depth image to show which pixels are in threshold
    // A lot of this is redundant, but this is just for demonstration purposes
    display.loadPixels();
    for (int x = 0; x < kinect.width; x++) {
      for (int y = 0; y < kinect.height; y++) {

        int offset = x + y * kinect.width;
        // Raw depth
        int rawDepth = depth[offset];
        int pix = x + y * display.width;
        if (rawDepth < threshold) {
          // A red color instead
          display.pixels[pix] = color(150, 50, 50);
        } else {
          display.pixels[pix] = img.pixels[offset];
        }
      }
    }
    display.updatePixels();

    // Draw the image

    image(display, 0, 0); //<>//
  }

  int getThreshold() {
    return threshold;
  }

  void setThreshold(int t) {
    threshold =  t;
  }
}
