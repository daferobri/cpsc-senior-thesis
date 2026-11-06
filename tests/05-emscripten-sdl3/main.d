
alias SDL_Window = void;
alias SDL_Renderer = void;

extern(C) {
    bool SDL_Init(uint flags);

    bool SDL_CreateWindowAndRenderer(
        const(char)* title,
        int width,
        int height,
        ulong flags,
        SDL_Window** window,
        SDL_Renderer** renderer
    );

    bool SDL_SetRenderDrawColor(
        SDL_Renderer* renderer,
        ubyte r, ubyte g, ubyte b, ubyte a
    );

    bool SDL_RenderClear(SDL_Renderer* renderer);
    bool SDL_RenderPresent(SDL_Renderer* renderer);
}

enum SDL_INIT_VIDEO = 0x00000020;

pragma(mangle, "main")
extern(C) int main() {
    if (!SDL_Init(SDL_INIT_VIDEO))
        return 1;

    SDL_Window* window;
    SDL_Renderer* renderer;

    if (!SDL_CreateWindowAndRenderer(
        "D + WebAssembly",
        640, 480, 0,
        &window, &renderer
    )) return 1;

    SDL_SetRenderDrawColor(
        renderer, 40, 100, 180, 255
    );
    SDL_RenderClear(renderer);
    SDL_RenderPresent(renderer);

    return 0;
}
