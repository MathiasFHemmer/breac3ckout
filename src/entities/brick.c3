module components;

import raylib5::rl;

struct Brick{
    char    lives;
    Color   color;    
    usz     rigidbody_idx;
    usz     shapebox_idx;
    usz     animate_shape_rect_idx;
}