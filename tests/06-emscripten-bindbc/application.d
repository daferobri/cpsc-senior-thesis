module application;

import bindbc.sdl;

extern(C) alias MainLoopCallback = void function();
extern(C) void emscripten_set_main_loop(MainLoopCallback callback, int fps, int simulateInfiniteLoop);

struct Application {
    SDL_Window* mWindow;
    SDL_Renderer* mRenderer;

    bool initialize() {
        mWindow = SDL_CreateWindow("bindbc-test", 640, 480, 0);
        if (mWindow is null) return false;
        mRenderer = SDL_CreateRenderer(mWindow, null);
        if (mRenderer is null) {
            SDL_DestroyWindow(mWindow);
            mWindow = null;
            return false;
        }
        return true;
    }

    void Input() { }
    void Update() { }
    void Render() {
        SDL_SetRenderDrawColor(mRenderer, 100, 190, 255, SDL_ALPHA_OPAQUE);
        SDL_RenderClear(mRenderer);
        SDL_RenderPresent(mRenderer);
    }
    void AdvanceFrame() {
        Input();
        Update();
        Render();
    }
    void RunLoop() { emscripten_set_main_loop(&frameCallback, 0, 0); }
    void shutdown() {
        if (mRenderer !is null) SDL_DestroyRenderer(mRenderer);
        if (mWindow !is null) SDL_DestroyWindow(mWindow);
        mRenderer = null;
        mWindow = null;
    }
}

__gshared Application app;
extern(C) void frameCallback() { app.AdvanceFrame(); }
