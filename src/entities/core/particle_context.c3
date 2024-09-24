module entities::core;

import allocator;
import components;
import components::particles;

struct ParticleContext{
    Pool(<Emitter>)                     emiter_pool;
    Pool(<EmitterSingleTrigger>)        single_trigger_pool;
    Pool(<EmitterTriggerAfterInterval>) emitter_trigger_after_interval_pool;
    Pool(<EmitterTriggerOverTime>)      emitter_trigger_over_time_pool;

    Pool(<Particle>)                    particle_pool;
    Pool(<ParticleScaleOverLifetime>)   particle_scale_over_lifetime_pool;
    Pool(<ParticleColorOverLifetime>)   particle_color_over_lifetime_pool;
    Pool(<ParticleGravity>)             particle_gravity_pool;
    Pool(<ParticlePositionOverLifetime>)particle_position_over_lifetime_pool;
}