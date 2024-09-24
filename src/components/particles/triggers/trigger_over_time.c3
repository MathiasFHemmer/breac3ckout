module components::particles::emitter;

struct EmitterTriggerOverTime{
    double interval;
    double amount;
    double current_time;
}