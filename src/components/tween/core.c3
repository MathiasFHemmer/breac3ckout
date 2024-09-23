module components::tween::core;

import std::math;
import std::io;

def TweenHandler = fn float(double t);

enum TweenType : (TweenHandler handler){
    SINEEASYINOUT = &sine_easy_in_out,
    EASYOUTELASTIC = &easy_out_elastic
}

fn float sine_easy_in_out(double t){
    return std::math::easing::sine_inout((float)t, 0, 1, 1);
}

fn float easy_out_elastic(double t){
    return (float)(t == 0 ? 0 : t == 1 ? 1 : std::math::pow(2, -10 * t) * math::sin((t * 10 - 0.75) * ((2 * std::math::PI) / 3)) + 1);
}