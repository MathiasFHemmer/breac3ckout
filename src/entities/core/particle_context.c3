module entities::core;

import allocator;
import components;
import components::particles;

struct ParticleContext{
    Pool(<Emitter>)   emiter_pool;
    Pool(<EmitterSingleTrigger>) single_trigger_pool;
    Pool(<EmitterTriggerOverLifetime>) emitter_trigger_over_lifetime;

    Pool(<Particle>)  particle_pool;
    Pool(<ParticleScaleOverLifetime>) scale_over_lifetime_pool;
}