module systems::particles::behaviour;

import components::particles;
import entities::core;

fn void update_scale_over_lifetime(ParticleContext* context, Particle* p, usz id, double dt){
    ParticleScaleOverLifetime* c = &context.particle_scale_over_lifetime_pool.entity_pool[id];
    p.scale = c.start_scale + ((float)p.lifetime) / ((float)p.max_lifetime) * (c.end_scale - c.start_scale);
}