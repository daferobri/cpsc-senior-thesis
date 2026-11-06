
module sdl_abstraction;

import core.stdc.stdio : printf;
import bindbc.sdl;

bool initializeSDL() {
    uint flags = SDL_INIT_VIDEO | SDL_INIT_EVENTS;

    if (!SDL_Init(flags)) {
        printf("SDL initialization failed: %s\n",
            SDL_GetError());
        return false;
    }

    printf("SDL initialized successfully\n");
    return true;
}

void shutdownSDL() {
    SDL_Quit();
    printf("SDL shut down\n");
}
