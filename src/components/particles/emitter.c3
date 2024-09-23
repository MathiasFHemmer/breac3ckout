module components::particles;

import raylib5;
import std::collections;
import commands::particles::defaults_spawners;
import componens::particles::properties;

def EmitterComponents = HashMap(<typeid, usz>);

union EmiterAmountData{
     int fixed;
     int[<2>] range;
}

union EmiterPositionData{
     float[<2>] fixed;
     struct random_inside_circle{
        float radius;  
     }
}

struct Emitter{
    bool active;
    float[<2>] position;
    double lifetime;
    double max_lifetime;
    EmitterComponents components;
    
    ParticleAmountType amount_type;
    EmiterAmountData amount_data;
    ParticlePositionType position_type;
    EmiterPositionData position_data;
}