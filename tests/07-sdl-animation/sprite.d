module sprite;

enum WalkMode { automatic, manual }
enum Direction { down, left, right, up }

struct Transform {
    float x = 50;
    float y = 50;
    float width = 100;
    float height = 100;
}

struct Animation {
    // Fixed metadata for the original example's 256x256 test.bmp sheet.
    enum tileSize = 64;
    enum columns = 4;
    enum frameSeconds = 0.1;
    static immutable uint[4][4] sequences = [
        [0, 1, 2, 3], [4, 5, 6, 7],
        [8, 9, 10, 11], [12, 13, 14, 15]
    ];
    Direction direction = Direction.down;
    size_t sequencePosition;
    double elapsed = 0;

    void face(Direction next) {
        if (direction == next) return;
        direction = next;
        sequencePosition = 0;
        elapsed = 0;
    }

    void update(double seconds) {
        elapsed += seconds;
        while (elapsed >= frameSeconds) {
            elapsed -= frameSeconds;
            sequencePosition = (sequencePosition + 1) % sequences[0].length;
        }
    }

    uint frame() const {
        return sequences[cast(size_t) direction][sequencePosition];
    }
}

struct GameObject {
    Transform transform;
    Animation animation;
    WalkMode mode = WalkMode.automatic;
    int xDirection = 1;
    int yDirection = 1;
    // The original moves 4 pixels per 100 ms update.
    enum speed = 80.0f;

    void update(double seconds, bool up, bool down, bool left, bool right,
                bool automatic) {
        if (up || down || left || right) mode = WalkMode.manual;
        else if (automatic) mode = WalkMode.automatic;

        float distance = speed * cast(float) seconds;
        final switch (mode) {
        case WalkMode.manual:
            if (!(up || down || left || right)) {
                animation.sequencePosition = 0;
                animation.elapsed = 0;
                return;
            }
            if (up) { 
                transform.y -= distance;
                animation.face(Direction.up);
            } else if (down) { 
                transform.y += distance; animation.face(Direction.down);
            } else if (left) {
                transform.x -= distance;
                animation.face(Direction.left);
            } else if (right) {
                transform.x += distance;
                animation.face(Direction.right);
            }
            break;
        case WalkMode.automatic:
            transform.x += xDirection * distance;
            transform.y += yDirection * distance;
            if (transform.x >= 640 - transform.width) {
                transform.x = 640 - transform.width;
                xDirection = -1;
                animation.face(Direction.left);
            } else if (transform.x <= 0) {
                transform.x = 0;
                xDirection = 1;
                animation.face(Direction.right);
            }
            if (transform.y >= 480 - transform.height) {
                transform.y = 480 - transform.height;
                yDirection = -1;
                animation.face(Direction.up);
            } else if (transform.y <= 0) {
                transform.y = 0;
                yDirection = 1;
                animation.face(Direction.down);
            }
            break;
        }
        animation.update(seconds);
    }
}
