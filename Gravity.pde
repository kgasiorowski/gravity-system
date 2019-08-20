// Author: Kuba Gasiorowski

import controlP5.*;
import java.awt.event.KeyEvent;

color BACKGROUND_COLOR = color(0);
final ArrayList<Drawable> particles = new ArrayList();
final float CIRCLE_RADIUS = 3.5;
final float CIRCLE_DIAM = CIRCLE_RADIUS * 2;
final float G = 3;

final float MAX_VEL = 10;

boolean VEL_ARROWS = false;
final float VEL_ARROW_MULT = 7;

boolean ACCL_ARROWS = false;
final float ACCL_ARROW_MULT = 400;

void setup(){

    //size(920, 800);
    fullScreen();
    textSize(20);
    ControlP5 cp5 = new ControlP5(this);
    cp5.addFrameRate().setPosition(10, 10);
    noStroke();
    
    GravityWell grav = new GravityWell(width/2, height/2, 5);
    particles.add(grav);
    
}

int num_dynamic_parts;

void draw(){
    
    background(BACKGROUND_COLOR);
    num_dynamic_parts = 0;
    
    for(Drawable p : particles){
    
        p.step();
        p.draw();
        
        if(!(p instanceof StaticParticle)){
        
            num_dynamic_parts++;
            
            PVector pos = ((Particle)p).pos;
            int x = int(pos.x);
            int y = int(pos.y);
            
            double vel = ((Particle)p).vel.mag();
        
            if(x < 0 || y < 0 || x > width || y > height){
            
                fill(color(0, 255, 0));
                
                pushMatrix();
                
                if(x < 0 && y < 0){
                    rotate(PI/4);
                }else if(x < 0 && y > height){
                    translate(0, height);
                    rotate(7*PI/4);
                }else if(x > width && y < 0){
                    translate(width, 0);
                    rotate(3*PI/4);
                }else if(x > width && y > height){
                    translate(width, height);
                    rotate(5*PI/4);
                }else if(x < 0){
                    translate(0, y);
                }else if(x > width){
                    translate(width, y);
                    rotate(PI);
                }else if(y < 0){
                    translate(x, 0);
                    rotate(PI/2);
                }else if(y > height){
                    translate(x, height);
                    rotate(3*PI/2);
                }
                
                triangle(0, 0, 10, 5, 10, -5);
                popMatrix();
        
                fill(color(255, 0, 0));
        
            }else{
                
                fill(color(0, 255, 0));
                
            }
            
            text(String.format("{%d} (%.1f) [x:%d, y:%d]", num_dynamic_parts, vel, x, y), 15, 30+20*num_dynamic_parts);
        
        }
        
        if(VEL_ARROWS && p instanceof DynamicParticle){
        
            DynamicParticle dyn = (DynamicParticle)p;
            strokeWeight(3);
            stroke(dyn.clr);
            line(dyn.pos.x, dyn.pos.y, dyn.pos.x + (dyn.vel.x * VEL_ARROW_MULT), dyn.pos.y + (dyn.vel.y * VEL_ARROW_MULT));
        
        }
        
    }
    
    for(int i = particles.size()-1; i >= 0; i--)
        if(particles.get(i) instanceof Particle)
            if(((Particle)particles.get(i)).dead)
                particles.remove(i);
    
    
    
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

void keyPressed(){

    VEL_ARROWS = !VEL_ARROWS;
    ACCL_ARROWS = !ACCL_ARROWS;

}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
interface Drawable{
    
    void draw();
    void step();
    
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
abstract class Particle implements Drawable{

    public PVector pos;
    PVector vel;
    color clr;
    float mass;
    boolean dead;

    Particle(int x, int y, color _clr){
    
        pos = new PVector(x, y);
        vel = new PVector(0, 0);
        clr = _clr;
        mass = 1;
        dead = false;
    
    }

    Particle(int x, int y, color _clr, float m){
    
        this(x, y, _clr);
        mass = m;
    
    }

    void draw(){
    
        noStroke();
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
    
    StaticParticle(int x, int y, color _clr, float m){
    
        super(x, y, _clr, m);
    
    }
    
    // Empty method since static particles don't move, u feel?
    void step(){}

}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class DynamicParticle extends Particle{
    
    DynamicParticle(int x, int y){
    
        super(x, y, color(255));
        
        
    }

    DynamicParticle(int x, int y, float m){
    
        super(x, y, color(255), m);
        
    }

    void step(){
    
        //First calculate acceleration vector, then add forces to it
        PVector accel = new PVector(0, 0);
        ArrayList<PVector> forces = new ArrayList();
        
        for(Drawable d : particles){
        
            if(!(d instanceof Particle) || d == this)
                continue;
            
            Particle p = (Particle)d;
            
            float dist = pos.dist(p.pos);
            PVector t = new PVector(p.pos.x - pos.x, p.pos.y - pos.y);
            
            t.div(dist).div(dist);
            t.mult(p.mass);
            t.mult(G);
        
            forces.add(t);
            
        }
    
        for(PVector force : forces)
            accel.add(force);
    
        // All forces should be applied before this call
        vel.add(accel);
        
        // Limit the velocity of bodies so that they dont go flying at 100 or something
        vel.limit(MAX_VEL);
        
        pos.add(vel);
        
        // Recolor the particle as a function of it's velocity
        clr = color(int(map(vel.mag(), 0, MAX_VEL, 0, 255)), 0, int(map(vel.mag(), 0, MAX_VEL, 255, 0)));
        
        if(ACCL_ARROWS){
        
            for(PVector force : forces){
                
                stroke(int(map(force.mag(), 0, 0.25, 0, 255)), int(map(force.mag(), 0, 0.25, 255, 0)), 0);
                strokeWeight(3);
                line(pos.x, pos.y, pos.x + (force.x * ACCL_ARROW_MULT), pos.y + (force.y * ACCL_ARROW_MULT));
            
            }
        
        }
        
        if(dist(pos.x, pos.y, width/2, height/2) < CIRCLE_DIAM)
            dead = true;
        
    }

}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class GravityWell extends StaticParticle{

    float mass;
    
    GravityWell(int x, int y, float m){
    
        super(x, y, color(244, 209, 66), m);
    
    }

    GravityWell(int x, int y){
    
        this(x, y, 1);
    
    }

}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
