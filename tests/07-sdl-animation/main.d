import application;
import sdl_abstraction;

pragma(mangle, "main")
extern(C) int main() {
    if (!initializeSDL()) return 1;
    if (!app.initialize()) {
        shutdownSDL();
        return 1;
    }
    app.RunLoop();
    return 0;
}
