module systems;

import std::collections;
import std::math;
import components;

fn void update_animation(List(<RotationAnimation>) pool, List(<Rigidbody>) target, double dt){
    foreach(&anim : pool){
        (&target[anim.rigidbody_idx]).rotation += anim.speed * (float)dt * anim.direction;
		if(std::math::abs((&target[anim.rigidbody_idx]).rotation) > anim.max_rotation) anim.direction *= -1;
    }
}