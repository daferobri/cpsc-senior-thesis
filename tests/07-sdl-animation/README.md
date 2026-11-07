# BetterC sprite animation

From this directory, build and serve the browser application:

```bash
bash scripts/build.sh
python3 -m http.server 8000 -d build/web
```

Open http://localhost:8000 and click the canvas to give it keyboard focus.
The sprite starts in autowalk mode and bounces at the window edges. WASD
switches to manual movement; M returns to autowalk. Escape stops the demo
and releases SDL resources. Reload the page to restart.

`sprite.d` contains struct-based transform and animation data, an enum-based
movement state, and fixed sequences for down, left, right, and up. Frames
advance every 100 ms using elapsed time, independently of browser rendering
frequency. Sequence positions index explicit frame numbers, allowing repeated
or noncontiguous frames. In manual mode, releasing WASD holds the first frame
of the current direction. Autowalk continues animating without keyboard input.

`assets/walk.bmp` is copied from the original assignment's
`PSET/part1/project/assets/images/test.bmp` in
`game-engines-psets/monorepo-daferobri/05_PSet_animation_and_invaders_deux`.
It is a 256x256 sheet with sixteen 64x64 frames; no JSON is loaded.
The existing Samus and background assets are retained but are not used.

The application explicitly owns the texture, renderer, and window. It uses
static BindBC-SDL bindings, BetterC, and Emscripten's browser main-loop callback.
`scripts/clean.sh` removes generated build output and the local DUB cache.
