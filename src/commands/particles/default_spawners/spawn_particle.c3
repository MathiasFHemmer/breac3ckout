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
        float[<2>] velocity = {
           0,0
        };
        usz particle_idx = context.particle_pool.new({
            {position,velocity,0},
            {random::next_float(&rand)*5 + 2},
            {255, 255, 255, 255},
            0,2,random::next_float(&rand)*4 + 2,{}
        });
        e.particle_components_handler(context, e, &context.particle_pool.entity_pool[particle_idx]);
    }
}