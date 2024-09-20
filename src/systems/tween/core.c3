module systems::tween;

import components::tween;
import std::math;


fn float evaluate(TweenType type, double t){
    switch(type){
        case(TweenType.SINEEASYINOUT):
            return std::math::easing::sine_inout((float)t, 0, 1, 1);
        case(TweenType.EASYOUTELASTIC):
                return (float)(t == 0 ? 0 : t == 1 ? 1 : std::math::pow(2, -10 * t) * math::sin((t * 10 - 0.75) * ((2 * std::math::PI) / 3)) + 1);
        default:
            return std::math::easing::sine_inout((float)t, 0, 1, 1);
    }
}