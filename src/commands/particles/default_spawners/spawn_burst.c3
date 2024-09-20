module commands::particles::defaults_spawners;

import raylib5;
import entities::core;
import components::particles;
import std::io;
import std::math;
import std::math::random;

fn void spawn_burst(ParticleContext* context, Emitter* e)
{
    DefaultRandom rand;
    random::seed_entropy(&rand);

    for(int x = 0; x < e.trigger_data.burst.ammount; x++){
        float r = 20 * (float)math::sqrt(random::next_float(&rand));
        float theta = (float)random::next_float(&rand) * 2 * (float)math::PI;
        ParticleComponents components;
        components.set(ParticleScaleOverLifetime.typeid,
            context.scale_over_lifetime_pool.new({
                1, 0
            })
        );
        context.particle_pool.new({
            {0, Particle.typeid,e.position+{r*math::cos(theta), r*math::sin(theta)},{(random::next_float(&rand)-0.5)*2.0 * 50,(random::next_float(&rand)-0.5)*2.0 * 50},0},
            {random::next_float(&rand)*5 + 2},
            {255, 255, 255, 255},
            0,2,random::next_float(&rand)*4 + 2,components
        });
    }
}