module application;

import bindbc.sdl;
import core.stdc.stdio : printf;

extern(C) alias MainLoopCallback = void function();
extern(C) void emscripten_set_main_loop(MainLoopCallback callback, int fps, int simulateInfiniteLoop);

struct Application {
    SDL_Window* mWindow;
    SDL_Renderer* mRenderer;
    SDL_Texture* mBackground;

    bool initialize() {
        mWindow = SDL_CreateWindow("bindbc-test", 640, 480, 0);
        if (mWindow is null) return false;
        mRenderer = SDL_CreateRenderer(mWindow, null);
        if (mRenderer is null) {
            SDL_DestroyWindow(mWindow);
            mWindow = null;
            return false;
        }
        // Emscripten preloads this file into its virtual filesystem.
        auto surface = SDL_LoadPNG("assets/samus.png");
        // PNGs are now supported in standard SDL as of 3.4.0
        // auto surface = SDL_LoadBMP("assets/background.bmp");
        if (surface is null) {
            printf("Could not load background: %s\n", SDL_GetError());
            shutdown();
            return false;
        }
        mBackground = SDL_CreateTextureFromSurface(mRenderer, surface);
        SDL_DestroySurface(surface);
        if (mBackground is null) {
            printf("Could not create background texture: %s\n", SDL_GetError());
            shutdown();
            return false;
        }
        return true;
    }

    void Input() { }
    void Update() { }
    void Render() {
        SDL_SetRenderDrawColor(mRenderer, 100, 190, 255, SDL_ALPHA_OPAQUE);
        SDL_RenderClear(mRenderer);
        SDL_RenderTexture(mRenderer, mBackground, null, null);
        SDL_RenderPresent(mRenderer);
    }
    void AdvanceFrame() {
        Input();
        Update();
        Render();
    }
    void RunLoop() { emscripten_set_main_loop(&frameCallback, 0, 0); }
    void shutdown() {
        if (mBackground !is null) SDL_DestroyTexture(mBackground);
        mBackground = null;
        if (mRenderer !is null) SDL_DestroyRenderer(mRenderer);
        if (mWindow !is null) SDL_DestroyWindow(mWindow);
        mRenderer = null;
        mWindow = null;
    }
}

__gshared Application app;
extern(C) void frameCallback() { app.AdvanceFrame(); }
