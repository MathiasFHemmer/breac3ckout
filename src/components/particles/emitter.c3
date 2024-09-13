module components::particles;

import raylib5;

struct Emitter{
    bool is_alive;
    float[<2>] position;
    bool trigger;
    Color color;
}