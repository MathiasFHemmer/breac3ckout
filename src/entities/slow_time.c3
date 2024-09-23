module entities;

import components::particles;
import componens::particles::properties;
import entities::core;

struct SlowTime{
    bool is_active;
    double duration_max;
    double duration_current;
    double scale;
    double value;

    bool is_burnout;
    double burnout_current;
    double burnout_max;

    usz emitter_idx;
}

fn void SlowTime.init(&self, ParticleContext* particle_context){
    EmitterComponents components = *EmitterComponents{}.new_init_with_key_values(
    EmitterTriggerOverTime.typeid, particle_context.emitter_trigger_over_time_pool.new ({0.2, 5, 0})
    );

    self.emitter_idx = particle_context.emiter_pool.new({
        false,
        {0,0},
        0,-1,components,
        ParticleAmountType.FIXED, {.fixed = 3}, ParticlePositionType.RANDOM_INSIDE_CIRCLE, {.random_inside_circle={50}}
    });

}

fn void SlowTime.start(SlowTime* self){
    self.is_active = true;
}

fn void SlowTime.stop(SlowTime* self){
    self.value = 1;
    self.is_active = false;
}