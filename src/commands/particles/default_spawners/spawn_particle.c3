module commands::particles::defaults_spawners;

import raylib5;
import entities::core;
import components::particles;
import std::io;
import std::math;
import std::math::random;

fn void spawn_particle(ParticleContext* context, Emitter* e)
{
    DefaultRandom rand;
    random::seed_entropy(&rand);

    int amount = e.amount_type.handler(e);
    // GetColor
    // GetScale
    // GetLifetime

    for(int x = 0; x < amount; x++){
        float[<2>] position = e.position_type.handler(e);

        float r = 20 * (float)math::sqrt(random::next_float(&rand));
        float theta = (float)random::next_float(&rand) * 2 * (float)math::PI;
        ParticleComponents components;
        components.set(ParticleScaleOverLifetime.typeid,
            context.particle_scale_over_lifetime_pool.new({
                1, 0
            })
        );
        components.set(ParticleColorOverLifetime.typeid,
            context.particle_color_over_lifetime_pool.new({
                rl::BLUE, rl::RED
            })
        );

        context.particle_pool.new({
            {position,{(random::next_float(&rand)-0.5)*2.0 * 50,(random::next_float(&rand)-0.5)*2.0 * 50},0},
            {random::next_float(&rand)*5 + 2},
            {255, 255, 255, 255},
            0,2,random::next_float(&rand)*4 + 2,components
        });
    }
}