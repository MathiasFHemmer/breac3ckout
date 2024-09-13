module systems::particles;

import components::shapes;
import components::particles;
import raylib5::rl;
import std::io;
import std::math;

fn void update_emitter(EmitterPool* entities, ParticlePool* particles)
{
	DefaultRandom rand;
	random::seed_entropy(&rand);

    for(int i = 0; i < entities.len(); i++){

        if((*entities)[i].is_alive == false) continue;

        if((*entities)[i].trigger){
            for(int x = 0; x < 20; x++){
                float r = 20 * (float)math::sqrt(random::next_float(&rand));
                float theta = (float)random::next_float(&rand) * 2 * (float)math::PI;
                (*particles).push({
                    i,
                    {{r*math::cos(theta), r*math::sin(theta)},{(random::next_float(&rand)-0.5)*2.0 * 50,(random::next_float(&rand)-0.5)*2.0 * 50},0},
                    {ShapeType.CIRCLE, 0, {2}},
                    (*entities)[i].color,
                    0,1,random::next_float(&rand)*4 + 2,1
                });
            }
            (*entities)[i].trigger = false;
            (*entities)[i].is_alive = false;
        }
    }
}