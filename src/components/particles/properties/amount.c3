module componens::particles::properties;

import components::particles;
import std::collections::map;
import std::math;
import std::io;
import std::math::random;

def GetParticleAmountHandler = fn int(Emitter* e);

enum ParticleAmountType : (GetParticleAmountHandler handler){
    FIXED = &get_fixed,
    RANDOM_RANGE = &get_range,
}


fn int get_fixed(Emitter* e) @inline{
    return e.amount_data.fixed;
}

fn int get_range(Emitter* e) @inline{
    DefaultRandom rand;
    random::seed_entropy(&rand);
    float f = random::next_float(&rand);
    return (int)(e.amount_data.range.x + (float)(e.amount_data.range.y-e.amount_data.range.x)*f);
}