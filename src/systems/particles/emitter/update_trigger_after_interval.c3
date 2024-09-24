module systems::particles::emitter::behaviour;

import components::particles::emitter;
import entities::core;
import commands::particles::defaults_spawners;


fn void update_trigger_after_interval(ParticleContext* context, Emitter* e, usz id, double dt){
    EmitterTriggerAfterInterval* t = &context.emitter_trigger_after_interval_pool.entity_pool[id];

    t.current += dt;
    if(t.current >= t.interval){
        commands::particles::defaults_spawners::spawn_particle(context, e);
        t.current = 0;
    }
}