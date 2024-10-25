package main

import rl "vendor:raylib"
import "core:fmt"

Player :: struct {
    position: [2]f32,
    speed:    f32,
}

player := Player{
    position = {1, 1},
    speed = 200,
}

GRID_SIZE :: 10
CELL_SIZE :: 64

TILE_ENUMS :: enum {
    Floor,
    Wall
}

grid := [GRID_SIZE][GRID_SIZE]TILE_ENUMS{
    {.Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor},
    {.Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor},
    {.Floor, .Floor, .Floor, .Wall,  .Floor, .Floor, .Floor, .Floor, .Floor, .Floor},
    {.Floor, .Floor, .Wall,  .Wall,  .Wall,  .Floor, .Wall, .Floor, .Floor, .Floor},
    {.Floor, .Floor, .Wall, .Wall,  .Wall,  .Floor, .Wall, .Floor, .Floor, .Floor},
    {.Floor, .Floor, .Floor, .Wall,  .Wall,  .Floor, .Wall, .Floor, .Floor, .Floor},
    {.Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Wall,  .Floor, .Floor, .Floor},
    {.Floor, .Floor, .Wall,  .Wall,  .Wall,  .Wall,  .Floor, .Floor, .Floor, .Floor},
    {.Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor},
    {.Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor, .Floor},
}

is_valid_coordinate :: proc(x, y: int) -> bool {
    return x >= 0 && x < GRID_SIZE && y >= 0 && y < GRID_SIZE
}

main :: proc() {
    rl.InitWindow(3840, 2160, "2D Grid")
    rl.SetTargetFPS(60)

    load_texture()
    create_4bit_map()
    cam := rl.Camera2D{{f32(3840/2),f32(800)}, {250,250}, 0, 3}  

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        rl.BeginMode2D(cam)
        rl.ClearBackground(rl.RAYWHITE)

        player_move()

        load_background()

        rl.DrawRectangleV(player.position, {CELL_SIZE,CELL_SIZE}, rl.MAROON)
        rl.EndMode2D()
        rl.EndDrawing()
    }

    clear_memory()
    unload_texture()
    rl.CloseWindow()
}