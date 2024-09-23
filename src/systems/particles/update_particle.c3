module systems::particles;

import std::io;
import components::particles;
import entities::core;
import std::collections;

fn void update_particle(ParticleContext* context,  double dt)
{    
    for(int i = 0; i < context.particle_pool.active_len; i++){
        Particle* p = &context.particle_pool.entity_pool[context.particle_pool.active_pool[i]];
        p.rigidbody.position += (float[<2>])dt * p.rigidbody.velocity;
        p.lifetime += dt; 
        p.rigidbody.velocity.x *= 0.98;
        p.rigidbody.velocity.y += 350*(float)dt;

        p.components.@each(;typeid type, usz id)
        {
            systems::particles::particle_lut[type](context, p, id, dt)!!;
        };

        if(p.lifetime >= p.max_lifetime) to_delete.push(i);
    }

    for(int i = 0; i < to_delete.len(); i++){
        usz entity_id = context.particle_pool.active_pool_map[context.particle_pool.active_pool[to_delete[i]]];
        context.particle_pool.entity_pool[to_delete[i]].components.@each(;typeid type, usz id)
        {
            switch{
                case(type == ParticleScaleOverLifetime.typeid):
                    context.particle_scale_over_lifetime_pool.delete(id);
                case(type == ParticleColorOverLifetime.typeid):
                    context.particle_color_over_lifetime_pool.delete(id);
            }
        };
        context.particle_pool.delete(to_delete[i]);
    }
    to_delete.clear();
}