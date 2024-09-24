module componens::particles::properties;

import components::particles;
import std::collections::map;
import std::math;
import std::io;
import std::math::random;

def GetParticlePositionHandler = fn float[<2>](Emitter* e);

enum ParticlePositionType : (GetParticlePositionHandler handler){
    FIXED = &get_position_fixed,
    RANDOM_INSIDE_CIRCLE = &get_position_random_inside_circle,
    RANDOM_IN_CIRCLE_RADIUS = &get_position_random_circle_raidus,
}


fn float[<2>] get_position_fixed(Emitter* e) @inline{
    return e.position + e.position_data.fixed;
}

fn float[<2>] get_position_random_inside_circle(Emitter* e) @inline{
    DefaultRandom rand;
    random::seed_entropy(&rand);

    float r = e.position_data.random_inside_circle * (float)math::sqrt(random::next_float(&rand));
    float theta = (float)random::next_float(&rand) * 2 * (float)math::PI;

    float[<2>] position = e.position + {r*math::cos(theta), r*math::sin(theta)};
    return position;
}

fn float[<2>] get_position_random_circle_raidus(Emitter* e) @inline{
    DefaultRandom rand;
    random::seed_entropy(&rand);
    float r = e.position_data.random_in_circle_radius;
    float theta = (float)random::next_float(&rand) * 2 * (float)math::PI;

    float[<2>] position = e.position + {r*math::cos(theta), r*math::sin(theta)};
    return position;
}