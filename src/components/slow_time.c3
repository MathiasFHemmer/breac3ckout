module components;

import std::io;

struct SlowTime{
    bool is_active;
    double duration_max;
    double duration_current;
    double scale;
    double value;

    bool is_burnout;
    double burnout_current;
    double burnout_max;
}

fn void SlowTime.start(SlowTime* self){
    self.is_active = true;
}

fn void SlowTime.stop(SlowTime* self){
    self.value = 1;
    self.is_active = false;
}