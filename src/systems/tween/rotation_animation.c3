module systems::tween;

import std::collections;
import std::math;
import components;

fn void update_animate_rotation(List(<AnimateRotation>) pool, List(<Rigidbody>) target, double dt){
    foreach(&anim : pool){
        if(!anim.animation.is_playing) continue;

        float value = anim.animation.step(dt);
        (&target[anim.rigidbody_idx]).rotation = (1-value) * anim.initial_value + value * anim.target_value;
    }
}