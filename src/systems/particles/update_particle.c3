module systems::particles;

import std::io;
import components::particles;

fn void update_particle(ParticlePool* particle_pool_handler, double dt)
{
    IdList to_delete;
    
    for(int i = 0; i < particle_pool_handler.active_pool.len(); i++){
        Particle* p = &particle_pool_handler.entity_pool[particle_pool_handler.active_pool[i]];
        p.rigidbody.position += (float[<2>])dt * p.rigidbody.velocity;
        p.lifetime += dt; 
        p.rigidbody.velocity.x *= 0.98;
        p.rigidbody.velocity.y += 350*(float)dt;
        p.shape.radius = p.start_radius + ((float)p.lifetime) / ((float)p.max_lifetime) * (p.end_radius - p.start_radius);

        if(p.lifetime >= p.max_lifetime) to_delete.push(particle_pool_handler.active_pool[i]);
    }

    for(int i = 0; i < to_delete.len(); i++){
        particle_pool_handler.delete(to_delete[i]);
    }
    to_delete.clear();
}