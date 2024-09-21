module systems::particles::emitter;

import components::shapes;
import components::particles;
import raylib5::rl;
import std::io;
import std::math;
import std::collections::list;
import entities::core;
import std::collections;

fn void update_emitter(ParticleContext* context, double dt)
{    
    for(int i = 0; i < context.emiter_pool.active_len; i++){
        Emitter* current = &context.emiter_pool.entity_pool[context.emiter_pool.active_pool[i]];
        current.lifetime += dt;

        current.components.@each(;typeid type, usz id)
        {
            systems::particles::emitter_lut[type](context, current, id, dt)!!;
        };

        if(current.lifetime >= current.max_lifetime) systems::particles::to_delete.push(context.emiter_pool.active_pool[i]);
    }

    for(int i = 0; i < systems::particles::to_delete.len(); i++){
        context.emiter_pool.delete(systems::particles::to_delete[i]);
    }
    systems::particles::to_delete.clear();
}

fn void update_emitter_single_trigger(ParticleContext *context, usz id, double dt){
    
}