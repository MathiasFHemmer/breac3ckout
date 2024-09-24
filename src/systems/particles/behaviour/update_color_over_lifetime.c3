module systems::particles::behaviour;

import components::particles;
import entities::core;

fn void update_color_over_lifetime(ParticleContext* context, Particle* p, usz id, double dt){
    ParticleColorOverLifetime* c = &context.particle_color_over_lifetime_pool.entity_pool[id];
    float delta = ((float)p.lifetime) / ((float)p.max_lifetime);
    p.color =  
    {
        (char)(((float)c.start_color.r*(1-delta)) +  delta*(float)(c.end_color.r)),
        (char)(((float)c.start_color.g*(1-delta)) +  delta*(float)(c.end_color.g)),
        (char)(((float)c.start_color.b*(1-delta)) +  delta*(float)(c.end_color.b)),
        (char)(((float)c.start_color.a*(1-delta)) +  delta*(float)(c.end_color.a)),
    };
}