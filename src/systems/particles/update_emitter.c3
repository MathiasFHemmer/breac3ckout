module systems::particles;

import components::shapes;
import components::particles;
import raylib5::rl;
import std::io;
import std::math;
import std::collections::list;

fn void update_emitter(EmitterPool* entity_pool_handler, ParticlePool* particles)
{
    IdList to_delete;
	DefaultRandom rand;
	random::seed_entropy(&rand);
    for(int i = 0; i < entity_pool_handler.active_pool.len(); i++){
        Emitter current = entity_pool_handler.entity_pool[entity_pool_handler.active_pool[i]];
        if(current.trigger){
            for(int x = 0; x < 5; x++){
                float r = 20 * (float)math::sqrt(random::next_float(&rand));
                float theta = (float)random::next_float(&rand) * 2 * (float)math::PI;
                particles.new({
                    current.position,
                    i,
                    {particles.get_next_id(), Particle.typeid,{r*math::cos(theta), r*math::sin(theta)},{(random::next_float(&rand)-0.5)*2.0 * 50,(random::next_float(&rand)-0.5)*2.0 * 50},0},
                    {2},
                    current.color,
                    0,2,random::next_float(&rand)*4 + 2,1
                });
            }
      
            current.trigger = false;
            to_delete.push(entity_pool_handler.active_pool[i]);
        }
    }

    for(int i = 0; i < to_delete.len(); i++){
        entity_pool_handler.delete(to_delete[i]);
    }
    to_delete.clear();
}