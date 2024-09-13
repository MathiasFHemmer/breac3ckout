module systems::particles;

import std::io;
import components::particles;

fn void update_particle(ParticlePool* entities, double dt)
{
    Particle p;
    for(int i = 0; i < entities.len(); i++){
        p = (*entities)[i];
        (&(*entities)[i]).rigidbody.position += (float[<2>])dt * (&(*entities)[i]).rigidbody.velocity;
        (&(*entities)[i]).lifetime += dt;
        (&(*entities)[i]).rigidbody.velocity.x *= 0.98;
        (&(*entities)[i]).rigidbody.velocity.y += 350*(float)dt;
        (&(*entities)[i]).shape.circle.radius = p.start_radius + ((float)p.lifetime) / ((float)p.max_lifetime) * (p.end_radius - p.start_radius);
    }

    entities.remove_if(fn (e) => e.lifetime >= e.max_lifetime);
}