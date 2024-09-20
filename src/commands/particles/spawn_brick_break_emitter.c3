module commands::particles;

import raylib5;
import entities::core;
import components::particles;
import std::io;

fn void spawn_brick_break_emitter(ParticleContext* context, float[<2>] position){
    EmitterComponents components = *EmitterComponents{}.new_init_with_key_values(
        EmitterTriggerOverLifetime.typeid, context.emitter_trigger_over_lifetime.new ({0.2, 0})
    );

    EmitterTriggerData emd;
    emd.burst.ammount = 10;

    context.emiter_pool.new({
        position,
        0,1,components,
        TriggerType.BURST, emd
    });
}