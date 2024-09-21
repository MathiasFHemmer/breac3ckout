module systems::tween;

import std::collections;
import std::math;
import components;
import allocator;

fn void update_animate_shape_rect(Pool(<AnimateShapeRect>)* pool, Pool(<Shape>)* target, double dt){
    for(usz i = 0; i < pool.active_len; i++){
        AnimateShapeRect* anim = &pool.entity_pool[pool.active_pool[i]];
        if(!anim.animation.is_playing) continue;

        float value = anim.animation.step(dt);
        (&target.entity_pool[anim.shape_idx]).dimensions = (1-value) * anim.initial_value + value * anim.target_value;
    }
}