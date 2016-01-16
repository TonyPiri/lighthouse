PImage backgroundMap;

// bounding box of England
float mapGeoLeft   = -9.37988;
float mapGeoRight  =  4;
float mapGeoTop    =   60.811741;
float mapGeoBottom =  49;

float mapScreenWidth, mapScreenHeight;  // Dimension of map in pixels.
var synth = new Tone.SimpleSynth().toMaster();
/*var ampEnv = new Tone.AmplitudeEnvelope({
  "attack": 0.1,
  "decay": 0.1,
  "sustain": 1.0,
  "release": 0.3
}).toMaster();
synth.envelope = ampEnv;*/

//create a distortion effect
var distortion = new Tone.Distortion(0.4).toMaster();

PImage lhon = loadImage("johnny-automatic-lighthouse WHITE.png");
PImage lhoff = loadImage("johnny-automatic-lighthouse BLACK.png");

ArrayList<Lighthouse> lighthouses = new ArrayList<Lighthouse>();

void setup()
{
  size(600,800);
  smooth();

  mapScreenWidth  = width;
  mapScreenHeight = height;
/*
  PVector p1 = geoToPixel(new PVector(0.8,51.5));  // London
  Lighthouse lh1 = new Lighthouse(p1, "0.2+(2)+0.2+(2)+0.2+(5.4)", false);
  lighthouses.add(lh1);
  PVector p2 = geoToPixel(new PVector(0.9759301,50.913452));       // Dungeness
  Lighthouse lh2 = new Lighthouse(p2, "8+(2)", false);
  lighthouses.add(lh2);
*/
}

void draw()
{
  background(32,32,96);
  //image(backgroundMap,0,0,mapScreenWidth,mapScreenHeight);
  //  ellipse(10,10,5,10);
  noStroke();

/*  
  for (int i = 0; i < lighthouses.size(); ++i) {
    Lighthouse lighthouse = lighthouses.get(i);
    PVector p = geoToPixel(new PVector(lighthouse.x,lighthouse.y));
    fill(255,0,0);
    ellipse(p.x,p.y,10,10);
  }
*/

  for(int i=0; i < lighthouses.size(); i++) {
    lighthouses.get(i).update(millis(), mouseX, mouseY);
  }
}

void addLighthouse(int x, int y, string sequence) {
  PVector p1 = geoToPixel(new PVector(x,y));  // London

  Lighthouse lighthouse = new Lighthouse(p1.x,p1.y,sequence,false);
  lighthouse.freq = random(110, 1200);
    lighthouses.add(lighthouse);
}

// Converts screen coordinates into geographical coordinates. 
// Useful for interpreting mouse position.
public PVector pixelToGeo(PVector screenLocation)
{
  return new PVector(mapGeoLeft + (mapGeoRight-mapGeoLeft)*(screenLocation.x)/mapScreenWidth,
                     mapGeoTop - (mapGeoTop-mapGeoBottom)*(screenLocation.y)/mapScreenHeight);
}

// Converts geographical coordinates into screen coordinates.
// Useful for drawing geographically referenced items on screen.
public PVector geoToPixel(PVector geoLocation)
{
  return new PVector(mapScreenWidth*(geoLocation.x-mapGeoLeft)/(mapGeoRight-mapGeoLeft),
                     mapScreenHeight - mapScreenHeight*(geoLocation.y-mapGeoBottom)/(mapGeoTop-mapGeoBottom));
}

// Converts a pattern, e.g., "0.2+(2)+0.2+(2)+0.2+(5.4)" into an ArrayList of
// ArrayLists, e.g., [[true, 0.2], [false, 2], ...]
// the occulting parameter denotes if the lighthouse is an occulting one,
// where the pattern doesn't denote on-(off), but (on)-off
ArrayList[] parse_pattern(String pattern, Boolean occulting) {
  ArrayList[] seq = new ArrayList();
  String[] fields = splitTokens(pattern, "+,");
  for(int i=0; i<fields.length(); i++) {
    Event note;
    if(trim(fields[i])[0] == "(") {
      float pause = float(fields[i].substring(1,fields[i].length()-1));
      note = new Event(pause, occulting);
    }
    else {
      float blink = float(fields[i]);
      note = new Event(blink, !occulting);
    }
    seq.add(note);
  }
  return seq;
}


class Event {
  boolean on;
  float length;

  Event (float l, boolean o) {
    length = l;
    on = o;
  }
}


class Lighthouse { 
  ArrayList[] pattern;
  int next_time;
  int index;
  int x;
  int y;
  int freq;
  float amp;
  string sequence;

  Lighthouse (int in_x, int in_y, String raw_pattern, boolean occulting) {  
//    location = loc;
    pattern = parse_pattern(raw_pattern);
    next_time = 0;
    x = in_x;
    y = in_y;
    index = 0;
    freq = 440;
    amp = 0.1;
  }

  void update (int millis, int mx, int my) {
    if(millis > next_time) {
      index = (index + 1) % pattern.size();
      next_time = int(millis + (pattern.get(index).length * 1000));
      if(pattern.get(index).on) {
        synth.triggerAttackRelease(freq, pattern.get(index).length, amp);
      }
    }

    int d = dist(x,y,mx,my);
    if(d > 100) {
      amp = 0;
    }
    else {
      amp = 1.0 - (d/100) + 0.1;
    }

    
    if(pattern.get(index).on) { 
      image(lhon,x,y,10,10);
    }
    else {
      image(lhoff,x,y,10,10);
    }
  }
}

