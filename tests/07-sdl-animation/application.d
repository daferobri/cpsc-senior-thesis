module application;

import bindbc.sdl;
import sprite : GameObject, Animation;
import core.stdc.stdio : printf;

extern(C) alias MainLoopCallback = void function();
extern(C) void emscripten_cancel_main_loop();
extern(C) void emscripten_set_main_loop(MainLoopCallback callback, int fps, int simulateInfiniteLoop);

struct Application {
    SDL_Window* mWindow;
    SDL_Renderer* mRenderer;
    SDL_Texture* mTexture;
    GameObject mySprite;
    ulong lastTick;
    bool running;

    bool initialize() {
        mWindow = SDL_CreateWindow("WASD: move | M: autowalk", 640, 480, 0);
        if (mWindow is null) return false;
        mRenderer = SDL_CreateRenderer(mWindow, null);
        if (mRenderer is null) {
            SDL_DestroyWindow(mWindow);
            mWindow = null;
            return false;
        }
        // Fixed 4x4 sprite sheet from the animation example.
        auto surface = SDL_LoadBMP("assets/walk.bmp");
        if (surface is null) {
            printf("Could not load sprite: %s\n", SDL_GetError());
            shutdown();
            return false;
        }
        mTexture = SDL_CreateTextureFromSurface(mRenderer, surface);
        SDL_DestroySurface(surface);
        if (mTexture is null) {
            printf("Could not create sprite texture: %s\n", SDL_GetError());
            shutdown();
            return false;
        }
        lastTick = SDL_GetTicks();
        running = true;
        return true;
    }

    void Input() {
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_EVENT_QUIT) running = false;
        }
    }
    void Update() {
        auto now = SDL_GetTicks();
        double seconds = (now - lastTick) / 1000.0;
        lastTick = now;
        // Avoid a large movement jump after a background tab resumes.
        if (seconds > 0.25) seconds = 0.25;
        auto keys = SDL_GetKeyboardState(null);
        mySprite.update(seconds, keys[SDL_SCANCODE_W], keys[SDL_SCANCODE_S],
                        keys[SDL_SCANCODE_A], keys[SDL_SCANCODE_D],
                        keys[SDL_SCANCODE_M]);
    }
    void Render() {
        SDL_SetRenderDrawColor(mRenderer, 100, 190, 255, SDL_ALPHA_OPAQUE);
        SDL_RenderClear(mRenderer);
        auto frame = mySprite.animation.frame();
        SDL_FRect source = SDL_FRect(
            cast(float)((frame % Animation.columns) * Animation.tileSize),
            cast(float)((frame / Animation.columns) * Animation.tileSize),
            Animation.tileSize, Animation.tileSize);
        SDL_FRect destination = SDL_FRect(mySprite.transform.x,
            mySprite.transform.y, mySprite.transform.width, mySprite.transform.height);
        SDL_RenderTexture(mRenderer, mTexture, &source, &destination);
        SDL_RenderPresent(mRenderer);
    }
    void AdvanceFrame() {
        Input();
        if (!running) {
            emscripten_cancel_main_loop();
            shutdown();
            SDL_Quit();
            return;
        }
        Update();
        Render();
    }
    void RunLoop() { emscripten_set_main_loop(&frameCallback, 0, 0); }
    void shutdown() {
        if (mTexture !is null) SDL_DestroyTexture(mTexture);
        mTexture = null;
        if (mRenderer !is null) SDL_DestroyRenderer(mRenderer);
        if (mWindow !is null) SDL_DestroyWindow(mWindow);
        mRenderer = null;
        mWindow = null;
    }
}

__gshared Application app;
extern(C) void frameCallback() { app.AdvanceFrame(); }
