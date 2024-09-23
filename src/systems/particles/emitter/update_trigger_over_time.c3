module systems::particles::emitter::behaviour;

import components::particles::emitter;
import entities::core;
import commands::particles::defaults_spawners;
import std::io;

fn void update_trigger_over_time(ParticleContext* context, Emitter* e, usz id, double dt){
    if(e.active == false) return;
    EmitterTriggerOverTime* t = &context.emitter_trigger_over_time_pool.entity_pool[id];

    t.current_time += dt;
    if(t.current_time >= t.interval){
        commands::particles::defaults_spawners::spawn_particle(context, e);
        t.current_time = 0;
    }
}