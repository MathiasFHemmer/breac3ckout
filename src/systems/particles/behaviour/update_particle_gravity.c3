module systems::particles::behaviour;

import components::particles;
import entities::core;

fn void update_gravity(ParticleContext* context, Particle* p, usz id, double dt){
    ParticleGravity* c = &context.particle_gravity_pool.entity_pool[id];
    p.rigidbody.velocity.y += c.amount*(float)dt;
}