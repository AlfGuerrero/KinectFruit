
import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;
import kinect4WinSDK.Kinect;
import kinect4WinSDK.SkeletonData;
import ddf.minim.*; //used for music
import ddf.minim.spi.*;
import ddf.minim.ugens.*;
import org.jbox2d.dynamics.joints.*;

//For adding in mulitiple images
PImage[] fruit_images;
PImage[] tree_images;
PImage[] fruit_particle_images;
float img_scale;
ArrayList<PVector> svgVrts;

Tracking tracker;

Minim minim;
AudioPlayer backgroundMusic;
AudioPlayer[] fruit_hit_sounds;

PImage backgroundImg;
// A reference to our box2d world
Box2DProcessing box2d;

// An ArrayList of fruit related objects
ArrayList<Fruit> fruits;
ArrayList<Tree> trees;
ArrayList<FruitParticleSystem> explodingFruits;

PVector[] posRight = new PVector[2];
PVector[] posLeft = new PVector[2];
// An object to store information about the uneven surface
Bowl[] bowl = new Bowl[2];



void setup() {
  size(1920, 1080, P3D);
  background(175, 238, 238);
  smooth(4);
  colorMode(RGB, 255, 255, 255, 100);
  tracker = new Tracking(this);
  
  bowl[0] = null;
  bowl[1] = null;
  
  posRight[0] = null;
  posRight[1] = null;
  
  posLeft[0] = null;
  posLeft[1] = null;
  
  //Music initialization
  minim = new Minim(this);

  backgroundMusic = minim.loadFile("alpha_musicBg_original.mp3");
  backgroundMusic.loop();
  
  fruit_hit_sounds = new AudioPlayer[5];
  fruit_hit_sounds[0] = minim.loadFile("hitSounds/Banana_Hitting_Bowl_Normalized.mp3");
  fruit_hit_sounds[0].setGain(0.0);
  fruit_hit_sounds[1] = minim.loadFile("hitSounds/Coconut_Hitting_Bowl_Normalized.mp3");
  fruit_hit_sounds[1].setGain(0.0);
  fruit_hit_sounds[2] = minim.loadFile("hitSounds/Orange_Hitting_Bowl_Normalized.mp3");
  fruit_hit_sounds[2].setGain(0.0);
  fruit_hit_sounds[3] = minim.loadFile("hitSounds/Apple_Hitting_Bowl_Normalized.mp3");
  fruit_hit_sounds[3].setGain(0.0);
  fruit_hit_sounds[4] = minim.loadFile("hitSounds/Strawberry_Hitting_Bowl_Normalized.mp3");
  fruit_hit_sounds[4].setGain(0.0);

  
  backgroundImg = loadImage("backgroundImgBlue.png");
  fruit_images = new PImage[5];
  fruit_images[0] = loadImage("banana.png");
  fruit_images[1] = loadImage("coconut.png");
  fruit_images[2] = loadImage("orange.png");
  fruit_images[3] = loadImage("apple.png");
  fruit_images[4] = loadImage("strawberry.png");
  
  tree_images = new PImage[5];
  tree_images[0] = loadImage("Tree_Banana_Final_Small.png");
  tree_images[1] = loadImage("Tree_Coconut_Final_Small.png");
  tree_images[2] = loadImage("Tree_Orange_Final_Small.png");
  tree_images[3] = loadImage("Tree_Apple_Final_Small.png");
  tree_images[4] = loadImage("Tree_Strawberry_Final_Small.png");
  
  fruit_particle_images = new PImage[5];
  fruit_particle_images[0] = loadImage("Final_Banana_Particle.png");
  fruit_particle_images[1] = loadImage("Final_Coconut_Particle.png");
  fruit_particle_images[2] = loadImage("Final_Orange_Particle.png");
  fruit_particle_images[3] = loadImage("Final_Apple_Particle.png");
  fruit_particle_images[4] = loadImage("Final_Strawberry_Particle.png");

  // Initialize box2d physics and create the world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  // We are setting a custom gravity
  box2d.setGravity(0, -10);

  // Create the empty list
  fruits = new ArrayList<Fruit>();
  trees = new ArrayList<Tree>();
  explodingFruits = new ArrayList<FruitParticleSystem>();
  
  
  //Listen for collisions
  box2d.listenForCollisions();
  
}

void draw() {
  // If the mouse is pressed, we make new particles
  if ((int) random(0, 10) == 1) {
    float w = random(5,10);
    int fruitIdx = (int) random(0,5);
    if (fruitIdx == 1) 
    {
      int addedRand = (int) random(0, 5);
      if (addedRand != 1) 
      {
        fruitIdx = addedRand;
      }
    }
    fruits.add(new Fruit(random(0, width),-80,box2d,fruit_images[fruitIdx],fruitIdx));//So we can have a randome value the corisponds to the fruit image and the fruit being made
  }
  background(255);
  
  image(backgroundImg, 0, 0);
  if (trees != null) {
    for (Tree tree : trees) {
      tree.display();
    }
  }

  // Particles that leave the screen, we delete them
  // (note they have to be deleted from both the box2d world and our list
  for (int i = fruits.size()-1; i >= 0; i--) {
    Fruit p = fruits.get(i);
    if (p.isDead()) 
    {
      p.killBody();
      fruits.remove(i);
    }
    else if (p.isOffScreen()) 
    {
      p.killBody();
      fruits.remove(i);
    }
  }
  for (int i = 1; i >= 0; i--) {
    if(bowl[i] != null)
    {
      if(bowl[i].isDead()) 
      {
        bowl[i].destroyBowl();
        bowl[i] = null;
      }
    }
  }
  
  box2d.step();
  // Just drawing the framerate to see how many particles it can handle
  //fill(0);
  //text("framerate: " + (int)frameRate,12,16);
  
  for (int i=0; i<tracker.getBodySize(); i++)
  {
    //tracker.drawSkeleton(tracker.bodies.get(i));
    println(i);
    println(tracker.getRightHandPos(tracker.bodies.get(i)));
    if(tracker.getRightHandPos(tracker.bodies.get(i)) != null) 
    {
      for(int j = 0; j < posRight.length; j++)
      {
        if(posRight[j] == null)
        {
          posRight[j] = tracker.getRightHandPos(tracker.bodies.get(i));
          posLeft[j] = tracker.getLeftHandPos(tracker.bodies.get(i));
          break;
        }
      }
    }
         
  }
  
  for (int x = 0; x < posLeft.length; x++) 
  {
    if (posLeft[x] != null && posRight[x] != null) 
    {
      if (bowl[x] == null) 
      {
        bowl[x] = new Bowl(box2d,x);
      } 
      else 
      {
        ellipse(posRight[x].x,posRight[x].y,10,10);
        ellipse(posLeft[x].x,posLeft[x].y,10,10);
        bowl[x].update(posLeft[x], posRight[x]);
        // Draw the surface
        bowl[x].display();
      }
    } else if(posLeft[x] == null || posRight[x] == null) 
    {
     if (bowl[x] != null) 
     {
       bowl[x].kill();
       /* If above breaks try
       bowl[x].destroyBowl();
       bowl[x] = null;
       */
     }
    }
  }
  
  for (int y = 0; y < posLeft.length; y++) {
    if(posLeft[y] != null || posRight[y] != null && bowl[y] != null) {
      bowl[y].displayFront();
    }
  }
  // Draw all particles
  for (Fruit p: fruits) {
    if (p != null) {
      p.display();
    }
  }
  
  for (int w = 0; w < explodingFruits.size(); w++) {
    if (!explodingFruits.get(w).isDead()) {
      explodingFruits.get(w).update();
      explodingFruits.get(w).display();
    } else {
      explodingFruits.remove(w);
    }
  }
  
  posRight[0] = null;
  posLeft[0] = null;
  posRight[1] = null;
  posLeft[1] = null;
}

//Collision Detection
void beginContact(Contact cp)
{
  
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();
  
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();
  
  ///Hit sound trigger
  if(o1.getClass() == Fruit.class || o2.getClass() == Fruit.class)
  {
    if(o1.getClass() == CircleBody.class)
    {
      Fruit f = (Fruit)o2;
      if(f.body.getLinearVelocity().y < -2)
      {
        if(!f.hasCollided())
        {
          fruit_hit_sounds[f.getFruitIndex()].play(0);
          f.collision();
        }
      }
      
    }
    else if(o2.getClass() == CircleBody.class)
    {
      Fruit f = (Fruit)o1;
      if(f.body.getLinearVelocity().y < -2)
      {
        if(!f.hasCollided())
        {
          fruit_hit_sounds[f.getFruitIndex()].play(0);
          f.collision();
        }
      }
    }
  }
  
  //Sticking trigger
  if(o1.getClass() == Fruit.class && o2.getClass() == CircleBody.class)
  {
    Fruit fruit1 = (Fruit)o1;
    CircleBody c2 = (CircleBody)o2;
    fruit1.bowlCollision(c2.getPos());
    fruit1.setBowlCollidedIndex(c2.getBowlIndex());
  }
  
  if(o2.getClass() == Fruit.class && o1.getClass() == CircleBody.class)
  {
    Fruit fruit2 = (Fruit)o2;
    CircleBody c1 = (CircleBody)o1;
    fruit2.bowlCollision(c1.getPos());
    fruit2.setBowlCollidedIndex(c1.getBowlIndex());
  }
  
  if(o1.getClass() == Fruit.class && o2.getClass() == Fruit.class)
  {
    
    Fruit fruit1 = (Fruit)o1;
    Fruit fruit2 = (Fruit)o2;
    
    if(fruit2.hasCollidedWithBowl())
    {
      int coconutIndex = 1;
      int strawberryIndex = 4;
      if (fruit1.getFruitIndex() == coconutIndex && fruit2.getFruitIndex() != coconutIndex) {
        if (fruit2.getPos().y > fruit1.getPos().y) {
          fruit2.setDeath();
          explodingFruits.add(new FruitParticleSystem(fruit2.getPos().x, fruit2.getPos().y, fruit_particle_images[fruit2.getFruitIndex()]));
        } else {
          fruit1.bowlCollision(new Vec2(bowl[fruit2.getBowlCollidedIndex()].getPos().x,fruit2.getPos().y));
          fruit1.setBowlCollidedIndex(fruit2.getBowlCollidedIndex());
        }
      }
      else if (fruit2.getFruitIndex() == strawberryIndex && fruit1.getFruitIndex() != strawberryIndex) {
        if (fruit2.getPos().y > fruit1.getPos().y) {
          fruit2.setDeath();
          explodingFruits.add(new FruitParticleSystem(fruit2.getPos().x, fruit2.getPos().y, fruit_particle_images[fruit2.getFruitIndex()]));
        } else {
          fruit1.bowlCollision(new Vec2(bowl[fruit2.getBowlCollidedIndex()].getPos().x,fruit2.getPos().y));
          fruit1.setBowlCollidedIndex(fruit2.getBowlCollidedIndex());
        }
      }
      else {
        fruit1.bowlCollision(new Vec2(bowl[fruit2.getBowlCollidedIndex()].getPos().x,fruit2.getPos().y));
        fruit1.setBowlCollidedIndex(fruit2.getBowlCollidedIndex());
      }
    }
    
    if(fruit1.hasCollidedWithBowl())
    {
      int coconutIndex = 1;
      int strawberryIndex = 4;
      if (fruit2.getFruitIndex() == coconutIndex && fruit1.getFruitIndex() != coconutIndex) {
        if (fruit1.getPos().y > fruit2.getPos().y) {
          fruit1.setDeath();
          explodingFruits.add(new FruitParticleSystem(fruit1.getPos().x, fruit1.getPos().y, fruit_particle_images[fruit1.getFruitIndex()]));
        } else {
          fruit2.bowlCollision(new Vec2(bowl[fruit1.getBowlCollidedIndex()].getPos().x,fruit1.getPos().y));
          fruit2.setBowlCollidedIndex(fruit1.getBowlCollidedIndex()); 
        }
      } else if (fruit1.getFruitIndex() == strawberryIndex && fruit2.getFruitIndex() != strawberryIndex) {
        if (fruit1.getPos().y > fruit2.getPos().y) {
          fruit1.setDeath();
          explodingFruits.add(new FruitParticleSystem(fruit1.getPos().x, fruit1.getPos().y, fruit_particle_images[fruit1.getFruitIndex()]));
        } else {
          fruit2.bowlCollision(new Vec2(bowl[fruit1.getBowlCollidedIndex()].getPos().x,fruit1.getPos().y));
          fruit2.setBowlCollidedIndex(fruit1.getBowlCollidedIndex());
        }
      }
      else {
        fruit2.bowlCollision(new Vec2(bowl[fruit1.getBowlCollidedIndex()].getPos().x,fruit1.getPos().y));
        fruit2.setBowlCollidedIndex(fruit1.getBowlCollidedIndex()); 
      }
    }
    
    // tree code
    if (!fruit1.isDead() && fruit1.hasCollidedWithBowl()) {
      if (fruit1.getPos().y < 0) { 
        trees.add(new Tree(random(0, 1800), 900, tree_images[fruit1.getFruitIndex()], fruit1.getFruitIndex()));
        killAllBowlFruits();  
      }
    }
    if (!fruit2.isDead() && fruit2.hasCollidedWithBowl()) {
      if (fruit2.getPos().y < 0) { 
        trees.add(new Tree(random(0, 1800), 900, tree_images[fruit2.getFruitIndex()], fruit2.getFruitIndex()));
        killAllBowlFruits();  
      }
    }
  }
}

void killAllBowlFruits(){
  for(Fruit fruit : fruits) {
    if (fruit.hasCollidedWithBowl()) {
      fruit.setDeath();
      explodingFruits.add(new FruitParticleSystem(fruit.getPos().x, fruit.getPos().y, fruit_particle_images[fruit.getFruitIndex()]));
    }   
  }  
}

void endContact(Contact cp)
{
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();
  
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();
  
  if(o1.getClass() == Fruit.class)
  {
    Fruit fruit1 = (Fruit)o1;
    fruit1.bowlCollisionEnd();
  }
  
  if(o2.getClass() == Fruit.class)
  {
    Fruit fruit2 = (Fruit)o1;
    fruit2.bowlCollisionEnd();
  }
}


//Kinect Events Similar to MousePressed, must be kept
void appearEvent(SkeletonData _s) 
{
  if (_s.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) 
  {
    return;
  }
  synchronized(tracker.getBodies()) {
    tracker.addJoint(_s);
  }
}

void disappearEvent(SkeletonData _s) 
{
  synchronized(tracker.getBodies()) {
    for (int i=tracker.getBodySize()-1; i>=0; i--) 
    {
      if (_s.dwTrackingID == tracker.getBodyData(i).dwTrackingID) 
      {
        tracker.removeJoint(i);
      }
    }
  }
}

void moveEvent(SkeletonData _b, SkeletonData _a) 
{
  if (_a.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) 
  {
    return;
  }
  synchronized(tracker.getBodies()) {
    for (int i=tracker.getBodySize()-1; i>=0; i--) 
    {
      if (_b.dwTrackingID == tracker.getBodyData(i).dwTrackingID) 
      {
        tracker.updateJoint(i,_a);
        break;
      }
    }
  }
}