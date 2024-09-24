module systems::particles::behaviour;

import components::particles;
import entities::core;

fn void update_position_over_lifetime(ParticleContext* context, Particle* p, usz id, double dt){
    ParticlePositionOverLifetime* c = &context.particle_position_over_lifetime_pool.entity_pool[id];
    float value = (float)p.lifetime / ((float)p.max_lifetime);
    float x = c.curve.handler(value);
    p.rigidbody.position = (1-x)*c.start_position + (x*c.end_position);
}