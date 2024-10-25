
package main

import rl "vendor:raylib"
import "core:fmt"

WORLD_TEXTURE_STRUCT :: struct {
    rock: rl.Texture
}

layerStruct :: struct {
    tile: TILE_ENUMS,
    bit: int
}

WORLD_TEXTURE: WORLD_TEXTURE_STRUCT
TILE_LAYERS := make(map[int][]layerStruct, GRID_SIZE*GRID_SIZE)

TILE_BITMASK := map[TILE_ENUMS][2]int {
    .Floor={5,3},
    .Wall={0,3}
}

load_texture :: proc() {
    WORLD_TEXTURE = {rl.LoadTexture("tilemap.png")}
}

unload_texture :: proc() {
    rl.UnloadTexture(WORLD_TEXTURE.rock)
}

Combinations :: struct {
    topLeft: [2]int,
    top: [2]int,
    topRight: [2]int,
    centerLeft: [2]int,
    center: [2]int,
    centerRight: [2]int,
    bottomleft: [2]int,
    bottom: [2]int,
    bottomRight: [2]int,
    bottomLeftRight: [2]int,
    bottomRightLeft: [2]int,
    topRightLeft: [2]int,
    topLeftRight: [2]int,
    crossLeftRight: [2]int,
    crossRightLeft: [2]int
}

tilePositions := Combinations {
    topLeft={0,0},
    top={1,0},
    topRight={2,0},
    centerLeft={0,1},
    center={1,1},
    centerRight={2,1},
    bottomleft={0,2},
    bottom={1,2},
    bottomRight={2,2},
    bottomLeftRight={3,1},
    bottomRightLeft={4,1},
    topRightLeft={3,0},
    topLeftRight={4,0},
    crossLeftRight={4,2},
    crossRightLeft={3,2}
}

get_tile :: proc(x: int, y: int) -> TILE_ENUMS {
    if x == 0 || y == 0 || x < 0 || x >= GRID_SIZE || y < 0 || y >= GRID_SIZE {
        return .Floor
    }

    return grid[x][y]
}

get_autotile_bit :: proc(x: int, y: int, tile_num: TILE_ENUMS) -> int {
    dot_1 := 0
    dot_2 := 0
    dot_3 := 0
    dot_4 := 0
    if get_tile(x, y) == tile_num {
        dot_1 = 1
    }
    if get_tile(x+1, y) == tile_num {
        dot_2 = 1
    }
    if get_tile(x+1, y+1) == tile_num {
        dot_3 = 1
    }
    if get_tile(x, y+1) == tile_num {
        dot_4 = 1
    }
    

    total_bitmask := dot_1 + (dot_2*2) + (dot_3*4) + (dot_4*8)

    return total_bitmask
}

create_4bit_map :: proc() {
    for key in TILE_ENUMS{
        for x in 0..<GRID_SIZE {
            for y in 0..<GRID_SIZE {
                size := y * GRID_SIZE + x
                autotile := get_autotile_bit(x, y, key)

                elem, ok := TILE_LAYERS[size]
                if ok == false || autotile != 0 {
                    new_layer := make([]layerStruct, len(elem) + 1)
                    copy(new_layer, elem)
                    new_layer[len(elem)] = layerStruct{key, autotile}
                    if ok {
                        delete(elem)
                    }
                    TILE_LAYERS[size] = new_layer
                }
            }
        }
    }
}



render_texture :: proc(x: int, y: int, tileType: [2]int, tile: [2]int) {
    tile_x := tileType[0] + tile[0]
    tile_y := tileType[1] + tile[1]
    rect := rl.Rectangle{f32(tile_x)*64, f32(tile_y)*64, 64, 64}
    tileDest := rl.Rectangle{f32(x)*64, f32(y)*64, 64, 64}
    rl.DrawTexturePro(WORLD_TEXTURE.rock, rect, tileDest, rl.Vector2{-32, -32}, 0, rl.WHITE)
}

select_tile_type :: proc(x, y, bitmask: int, val: TILE_ENUMS) {
    switch bitmask {
        case 1:
            render_texture(x, y, tilePositions.bottomRight, TILE_BITMASK[val])
        case 2:
            render_texture(x, y, tilePositions.bottomleft, TILE_BITMASK[val])
        case 3:
            render_texture(x, y, tilePositions.bottom, TILE_BITMASK[val])
        case 4:
            render_texture(x, y, tilePositions.topLeft, TILE_BITMASK[val])
        case 5:
            render_texture(x, y, tilePositions.crossRightLeft, TILE_BITMASK[val])
        case 6:
            render_texture(x, y, tilePositions.centerLeft,TILE_BITMASK[val])
        case 7:
            render_texture(x, y, tilePositions.topLeftRight, TILE_BITMASK[val])
        case 8:
            render_texture(x, y, tilePositions.topRight, TILE_BITMASK[val])
        case 9:
            render_texture(x, y, tilePositions.centerRight, TILE_BITMASK[val])
        case 10:
            render_texture(x, y, tilePositions.crossLeftRight, TILE_BITMASK[val])
        case 11:
            render_texture(x, y, tilePositions.topRightLeft, TILE_BITMASK[val])
        case 12:
            render_texture(x, y, tilePositions.top, TILE_BITMASK[val])
        case 13:
            render_texture(x, y, tilePositions.bottomLeftRight, TILE_BITMASK[val])
        case 14:
            render_texture(x, y, tilePositions.bottomRightLeft, TILE_BITMASK[val])
        case 15:
            render_texture(x, y, tilePositions.center, TILE_BITMASK[val])
    }
}

load_background :: proc() {
    for i in 0..<GRID_SIZE {
        for j in 0..<GRID_SIZE {
            size := j * GRID_SIZE + i
            for key in TILE_LAYERS[size] {
                val := key.tile
                autotile := key.bit
                select_tile_type(i,j,autotile, val)
            }

            x := i32(i * CELL_SIZE)
            y := i32(j * CELL_SIZE)

            rl.DrawRectangleLines(x, y, CELL_SIZE, CELL_SIZE, rl.DARKGRAY)
        }
    }
}


clear_memory :: proc() {
    for size, array in TILE_LAYERS {
        delete(array)
    }
    clear(&TILE_LAYERS)
}