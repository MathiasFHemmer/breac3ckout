module systems::particles::emitter::behaviour;

import components::particles::emitter;
import entities::core;
import commands::particles::defaults_spawners;


fn void update_trigger_over_lifetime(ParticleContext* context, Emitter* e, usz id, double dt){
    EmitterTriggerOverLifetime* t = &context.emitter_trigger_over_lifetime.entity_pool[id];

    t.current += dt;
    if(t.current >= t.interval){
        commands::particles::defaults_spawners::emitter_trigger_lut[e.trigger_type.key](context, e)!!;
        t.current = 0;
    }
}