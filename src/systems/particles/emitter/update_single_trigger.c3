module systems::particles::emitter::behaviour;

import components::particles::emitter;
import entities::core;
import commands::particles::defaults_spawners;


fn void update_single_trigger(ParticleContext* context, Emitter* e, usz id, double dt){
    EmitterSingleTrigger* t = &context.single_trigger_pool.entity_pool[id];

    if(t.trigger == true){
        commands::particles::defaults_spawners::spawn_particle(context, e);
        t.trigger = false;      
        //to_delete.push(entity_pool_handler.active_pool[i]);
    }
}