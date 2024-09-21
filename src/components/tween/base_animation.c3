module components::tween;

import systems::tween;
import std::math::easing;
import std::io;

enum TweenType{
    SINEEASYINOUT,
    EASYOUTELASTIC
}

struct Animation{
    bool is_playing;
    bool loop;
    float length;
    float current_time;
    TweenType curve;
    float current_value;
}

fn float Animation.step(Animation* self, double dt){
    self.current_time += (float)dt;
    float ratio = self.current_time/self.length; //Y = (X-A)/(B-A) * (D-C) + C
    self.current_value = tween::evaluate(self.curve, ratio);
    
    if(self.current_time >= self.length){
        if(self.loop == false){
            self.is_playing = false;
        } else{
          self.current_time = -self.current_time;   
        } 
    } 
    return self.current_value;
}
fn void Animation.start(Animation* self){
    self.is_playing = true;
}
fn void Animation.pause(Animation* self){
    self.is_playing = false;
}
fn void Animation.stop(Animation* self){
    self.is_playing = false;
    self.current_time = 0;
    self.current_value = 0;
}



