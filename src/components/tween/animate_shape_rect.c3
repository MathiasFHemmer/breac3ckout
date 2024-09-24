module components::tween;

struct AnimateShapeRect{
    inline Animation animation;
    usz shape_idx;
    float[<2>] initial_value;
    float[<2>] target_value;
}