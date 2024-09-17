module components;

struct Rigidbody{
    usz         entity_idx;
    typeid      entity_type;
    float[<2>]  position;
    float[<2>]  velocity;
    float       rotation;
}

//fn Rigidbody new(usz e_idx, typeid e_type, float[<2>] position, float[<2>] velocity, float rotation){
//    return { e_idx, e_type, position, velocity, rotation };
//} 