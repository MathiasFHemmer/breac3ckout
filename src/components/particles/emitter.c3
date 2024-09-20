module components::particles;

import raylib5;
import std::collections;
import commands::particles::defaults_spawners;

def EmitterComponents = HashMap(<typeid, usz>);

enum TriggerType : int(typeid key){
    BURST = BurstTriggerData.typeid
}

struct BurstTriggerData{
    int ammount;
}

union EmitterTriggerData{
    BurstTriggerData burst;
}

struct Emitter{
    float[<2>] position;
    double lifetime;
    double max_lifetime;
    EmitterComponents components;
    TriggerType trigger_type;
    EmitterTriggerData trigger_data;
}