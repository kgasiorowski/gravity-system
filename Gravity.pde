// Author: Kuba Gasiorowski

import controlP5.*;
import java.awt.event.KeyEvent;

color BACKGROUND_COLOR = color(0);
final ArrayList<Drawable> particles = new ArrayList();
final float CIRCLE_RADIUS = 3.5;
final float CIRCLE_DIAM = CIRCLE_RADIUS * 2;

void setup(){

    size(920, 800);
    ControlP5 cp5 = new ControlP5(this);
    cp5.addFrameRate().setPosition(10, 10);
    noStroke();
    
    GravityWell grav = new GravityWell(width/2, height/2, 10);
    particles.add(grav);
    
}

void draw(){
    
    background(BACKGROUND_COLOR);
    
    for(Drawable p : particles){
    
        p.step();
        p.draw();
        
    }
    
}

float startX, endX;
float startY, endY;

void mousePressed(){

    startX = mouseX;
    startY = mouseY;

}

void mouseReleased(){

    endX = mouseX;
    endY = mouseY;

    Particle newParticle = new DynamicParticle(int(startX), int(startY));
    newParticle.vel = new PVector(startX - endX, startY - endY).mult(0.05);
    particles.add(newParticle);

}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
interface Drawable{
    
    void draw();
    void step();
    
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
abstract class Particle implements Drawable{

    protected PVector pos;
    protected PVector vel;
    protected color clr;

    Particle(int x, int y, color _clr){
    
        pos = new PVector(x, y);
        vel = new PVector(0, 0);
        clr = _clr;
    
    }

    void draw(){
    
        fill(clr);
        ellipse(pos.x, pos.y, CIRCLE_DIAM, CIRCLE_DIAM);
    
    }

    // Leave the implementation of physics for subclasses
    abstract void step();

}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class StaticParticle extends Particle{

    StaticParticle(int x, int y, color _clr){
    
        super(x, y, _clr);
        
    }
    
    // Empty method since static particles don't move, u feel?
    void step(){}

}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class DynamicParticle extends Particle{
    
    final PVector airResistance;
    final PVector maxVelocity = new PVector(10, 10);
    
    DynamicParticle(int x, int y){
    
        super(x, y, color(255));
        
        airResistance = new PVector(0, 0);
    
    }

    void step(){
    
        //First calculate acceleration vector, then add it
        PVector accel = new PVector(0, 0);
        
        for(Drawable d : particles){
        
            if(!(d instanceof GravityWell))
                continue;
            
            GravityWell g = (GravityWell)d;
            
            float dist = pos.dist(g.pos);
            PVector t = new PVector(g.pos.x - pos.x, g.pos.y - pos.y);
            
            t.div(dist).div(dist);
            t.mult(g.mass);
            accel.add(t);
        
        }
        
        // Air resistance
        //accel.add(new PVector(vel.x * -0.01, vel.y * -0.01));
    
        vel.add(accel);
        vel.limit(10);
        
        pos.add(vel);
        
        int blue = int(map(vel.mag(), 0, 10, 255, 0));
        int red = int(map(vel.mag(), 0, 10, 0, 255));
        
        clr = color(red, 0, blue);
        
    }

}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class GravityWell extends StaticParticle{

    float mass;
    
    GravityWell(int x, int y, float m){
    
        super(x, y, color(244, 209, 66));
        mass = m;
    
    }

    GravityWell(int x, int y){
    
        this(x, y, 1);
    
    }

}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
