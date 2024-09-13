module components::shapes;


enum ShapeType{
    CIRCLE,
    RECTANGLE
}

union Shapes
{
    CircleShape circle;
    RectangleShape rectangle;
}

struct ShapeBox{
    ShapeType type;
    usz rigidbody_idx;

    union
    {
        CircleShape circle;
        RectangleShape rectangle;
    }
}
