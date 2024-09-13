module systems;

import components;
import std::math;
import std::io;
 
fn void update_slow_time(SlowTime* entity, double dt){
    if(entity.is_burnout){
        entity.burnout_current -= dt;
        entity.duration_current -= dt;
        if(entity.burnout_current <= 0) entity.is_burnout = false;
        return;
    }
    
    if(entity.is_active == false){
        entity.duration_current -= 2*dt;
        entity.duration_current = math::max(entity.duration_current, 0.0);
        entity.value = 1;
        return;
    }

    entity.value = entity.scale;
    entity.duration_current += dt;

    if(entity.duration_current >= entity.duration_max){
        entity.value = 1;
        entity.is_burnout = true;
        entity.burnout_current = entity.burnout_max;
    }
}