module systems::tween;

import components::tween;
import std::math;


fn float evaluate(TweenType type, double t){
    switch(type){
        case(TweenType.SINEEASYINOUT):
            return std::math::easing::sine_inout((float)t, 0, 1, 1);
        default:
            return std::math::easing::sine_inout((float)t, 0, 1, 1);
    }
}