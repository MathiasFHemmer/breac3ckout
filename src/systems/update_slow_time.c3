module systems;

import entities;
import components;
import std::math;
import std::io;
 
fn void update_slow_time(SlowTime* entity, Context* ctx, ParticleContext* particle_ctx, double dt){
    (&particle_ctx.emiter_pool.entity_pool[entity.emitter_idx]).position = ctx.rigidbody_pool.entity_pool[ctx.player.rigidbody_idx].position + {0, -50};

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