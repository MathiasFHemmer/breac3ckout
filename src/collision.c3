module collision;

import raylib5::rl;
import std::math;

enum CollisionSide{
    TOP, BOTTOM, LEFT, RIGHT
}

fault CollisionFault{
    NOT_COLLIDED
}

fn CollisionSide! checkCircleOnRectCollision(float[<2>] ball_position, float ball_radius, float[<2>] rec_position, float[<2>] rec_dimension){
    Vector2 circle = Vector2{ball_position.x, ball_position.y};
    Rectangle rec = Rectangle{ rec_position.x - rec_dimension.x / 2, rec_position.y - rec_dimension.y / 2, rec_dimension.x, rec_dimension.y};

    // DEBUG COLL REC
    //rl::drawRectangle((int)(rec.x), (int)(rec.y), (int)rec.width, (int)rec.height, {200, 25, 25, 100});

    if (rl::checkCollisionCircleRec(circle, ball_radius, rec)){
        float[<2>] nearest_axis = {
            math::max(rec.x, math::min(circle.x, rec.x + rec.width)),
            math::max(rec.y, math::min(circle.y, rec.y + rec.height))
        };

        float left  = math::abs(nearest_axis.x - rec.x);
        float right = math::abs(nearest_axis.x - (rec.x + rec.width));
        float top   = math::abs(nearest_axis.y - rec.y);
        float bottom= math::abs(nearest_axis.y - (rec.y + rec.height));

        if(left     < ball_radius && left < top && left < bottom)   return CollisionSide.LEFT;
        if(right    < ball_radius && right < top && right < bottom) return CollisionSide.RIGHT;
        if(top      < ball_radius) return CollisionSide.TOP;
        if(bottom   < ball_radius) return CollisionSide.BOTTOM;

        return CollisionFault.NOT_COLLIDED?;
    };
    return CollisionFault.NOT_COLLIDED?;
}