module application;

import bindbc.sdl;

import sdl_abstraction;

extern (C) struct Application {
    SDL_Window* mWindow = null;
    SDL_Renderer* mRenderer = null;

    this() {
        mWindow = SDL_CreateWindow("bindbc-test", 640, 480, SDL_WINDOW_ALWAYS_ON_TOP);

        mRenderer = SDL_CreateRenderer(mWindow, null);
    }

    ~this() {
        SDL_DestroyRenderer(mRenderer);
        SDL_DestroyWindow(mWindow);
        shutdownSDL();
    }

    void Input() {

    }

    void Update() {

    }

    void Render() {
        SDL_SetRenderDrawColor(mRenderer,100,190,255,SDL_ALPHA_OPAQUE);
        SDL_RenderClear(mRenderer);
        SDL_RenderPresent(mRenderer);
    }

    void AdvanceFrame() {
        Input();
        Update();
        Render();
    }

    void RunLoop() {
        while(true) {
            AdvanceFrame();
        }
    }
}
