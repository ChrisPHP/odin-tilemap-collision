package main

import rl "vendor:raylib"

player_move :: proc() {
    deltaTime := rl.GetFrameTime()

    moveDirection := [2]f32{}

    //Move player in certain direction
    if rl.IsKeyDown(.RIGHT) {
        moveDirection.x += 1
    }
    if rl.IsKeyDown(.LEFT) {
        moveDirection.x -= 1
    }
    if rl.IsKeyDown(.DOWN) {
        moveDirection.y += 1
    }
    if rl.IsKeyDown(.UP) {
       moveDirection.y -= 1
    }

    new_x := player.position.x + moveDirection.x * player.speed * deltaTime
    new_y := player.position.y + moveDirection.y * player.speed * deltaTime

    pixel_perfect_collision_steps(new_x, new_y, moveDirection)
    //pixel_perfect_collision(new_x, new_y, moveDirection)
    //next_to_wall(new_x, new_y, moveDirection)
    //naive_collision(new_x, new_y, moveDirection)
}

naive_collision :: proc(x, y: f32, moveDirection: [2]f32) {
    new_x := x
    new_y := y

    player_rect := rl.Rectangle{
        x = new_x,
        y = new_y,
        width = CELL_SIZE,
        height = CELL_SIZE
    }

    //check neighbouring tiles
    directions := [][2]int{
        {-1, 0}, {0, -1}, {1, 0}, {0, 1},
        {-1, -1}, {-1, 1}, {1, -1}, {1, 1},
    }

    collided := false

    half_size: f32 = CELL_SIZE/2

    for pos in directions {
        //get tilemap coordinates
        pos_x := pos[0]+int((new_x+half_size)/CELL_SIZE)
        pos_y := pos[1]+int((new_y+half_size)/CELL_SIZE)
        if pos_x != -1 && pos_y != -1 && pos_x < GRID_SIZE && pos_y < GRID_SIZE && grid[pos_x][pos_y] == .Wall {
            wall := rl.Rectangle{
                x = f32(pos_x)*CELL_SIZE,
                y = f32(pos_y)*CELL_SIZE,
                width = CELL_SIZE,
                height = CELL_SIZE,
            }
            //Check rectangle collision
            if rl.CheckCollisionRecs(player_rect, wall) {
                collided = true
                break
            }     
        }
    }

    //If no collision set new position
    if !collided {
        player.position.x = new_x
        player.position.y = new_y
    }
}

next_to_wall :: proc(x, y: f32, moveDirection: [2]f32) {
    new_x := x
    new_y := y

    player_rect := rl.Rectangle{
        x = new_x,
        y = new_y,
        width = CELL_SIZE,
        height = CELL_SIZE
    }

    //check neighbouring tiles
    directions := [][2]int{
        {-1, 0}, {0, -1}, {1, 0}, {0, 1},
        {-1, -1}, {-1, 1}, {1, -1}, {1, 1},
    }

    half_size: f32 = CELL_SIZE/2

    for pos in directions {
        //get tilemap coordinates
        pos_x := pos[0]+int((new_x+half_size)/CELL_SIZE)
        pos_y := pos[1]+int((new_y+half_size)/CELL_SIZE)
        if pos_x != -1 && pos_y != -1 && pos_x < GRID_SIZE && pos_y < GRID_SIZE && grid[pos_x][pos_y] == .Wall {
            wall := rl.Rectangle{
                x = f32(pos_x)*CELL_SIZE,
                y = f32(pos_y)*CELL_SIZE,
                width = CELL_SIZE,
                height = CELL_SIZE,
            }

            //Check rectangle collision
            if rl.CheckCollisionRecs(player_rect, wall) {
                //Check which direction player was moving and set them at the edge of the tile
                if moveDirection.x > 0 {
                    new_x = wall.x - player_rect.width
                } else if moveDirection.x < 0 {
                    new_x = wall.x + wall.width
                } 

                if moveDirection.y > 0 {
                    new_y = wall.y - player_rect.height
                } else if moveDirection.y > 0 {
                     new_y = wall.y + wall.height
                }
                break
            }     
        }
    }

    player.position.x = new_x
    player.position.y = new_y
}

pixel_perfect_collision :: proc(x, y: f32, moveDirection: [2]f32) {
    new_x := x
    new_y := y

    player_rect := rl.Rectangle{
        x = new_x,
        y = player.position.y,
        width = CELL_SIZE,
        height = CELL_SIZE
    }

    //check neighbouring tiles depending on the direction player is moving
    direction := [3]int{0,1,-1}

    half_size: f32 = CELL_SIZE/2

    if moveDirection.x > 0 {
        for pos in direction {
            //get tilemap coordinates
            x := 1+int((new_x+half_size)/CELL_SIZE)
            y := pos+int((new_y+half_size)/CELL_SIZE)

            if x != -1 && y != -1 && x < GRID_SIZE && y < GRID_SIZE && grid[x][y] == .Wall {
                wall := rl.Rectangle{
                    x = f32(x)*CELL_SIZE,
                    y = f32(y)*CELL_SIZE,
                    width = CELL_SIZE,
                    height = CELL_SIZE,
                }  
                //Check rectangle collision
                if rl.CheckCollisionRecs(player_rect, wall) {
                    new_x = wall.x - player_rect.width
                    break
                }
            }
        } 
    } else if moveDirection.x < 0 {
        for pos in direction {
            //get tilemap coordinates
            x := int((new_x+half_size)/CELL_SIZE)-1
            y := pos+int((new_y+half_size)/CELL_SIZE)
            if x != -1 && y != -1 && x < GRID_SIZE && y < GRID_SIZE && grid[x][y] == .Wall {
                wall := rl.Rectangle{
                    x = f32(x)*CELL_SIZE,
                    y = f32(y)*CELL_SIZE,
                    width = CELL_SIZE,
                    height = CELL_SIZE,
                }  
                //Check rectangle collision
                if rl.CheckCollisionRecs(player_rect, wall) {
                    new_x = wall.x + wall.width
                    break
                }
            }
        } 
    }

     player_rect = rl.Rectangle{
        x = player.position.x,
        y = new_y,
        width = CELL_SIZE,
         height = CELL_SIZE
    }

    if moveDirection.y > 0 {
        for pos in direction {
            //get tilemap coordinates
            x := pos+int((new_x+half_size)/CELL_SIZE)
            y := 1+int((new_y+half_size)/CELL_SIZE)

            if x != -1 && y != -1 && x < GRID_SIZE && y < GRID_SIZE && grid[x][y] == .Wall {
                wall := rl.Rectangle{
                    x = f32(x)*CELL_SIZE,
                    y = f32(y)*CELL_SIZE,
                    width = CELL_SIZE,
                    height = CELL_SIZE,
                }  
                //Check rectangle collision
                if rl.CheckCollisionRecs(player_rect, wall) {
                    new_y = wall.y - player_rect.height
                    break
                }
            }
        } 
    } else if moveDirection.y < 0 {
        for pos in direction {
            //get tilemap coordinates
            x := pos+int((new_x+half_size)/CELL_SIZE)
            y := int((new_y+half_size)/CELL_SIZE)-1

            if x != -1 && y != -1 && x < GRID_SIZE && y < GRID_SIZE && grid[x][y] == .Wall {
                wall := rl.Rectangle{
                    x = f32(x)*CELL_SIZE,
                    y = f32(y)*CELL_SIZE,
                    width = CELL_SIZE,
                    height = CELL_SIZE,
                }  
                //Check rectangle collision
                if rl.CheckCollisionRecs(player_rect, wall) {
                    new_y = wall.y + wall.height
                    break
                }
            }
        } 
    } 


    player.position.x = new_x
    player.position.y = new_y
}

pixel_perfect_collision_steps :: proc(x, y: f32, moveDirection: [2]f32) {
    num_steps: f32 = 5

    new_x := x
    new_y := y

    //Divide new position into steps
    step_x := (new_x - player.position.x) / num_steps
    step_y := (new_y - player.position.y) / num_steps

    current_pos_x := player.position.x
    current_pos_y := player.position.y

    //check neighbouring tiles depending on the direction player is moving
    direction := [3]int{0,1,-1}

    half_size: f32 = CELL_SIZE/2

    //Loop through the steps updating each time
    for i in 0..<num_steps {
        current_pos_x +=  step_x

        player_rect := rl.Rectangle{
            x = current_pos_x,
            y = player.position.y,
            width = CELL_SIZE,
            height = CELL_SIZE
        }

        if moveDirection.x > 0 {
            for pos in direction {
                //get tilemap coordinates
                x := 1+int((new_x+half_size)/CELL_SIZE)
                y := pos+int((new_y+half_size)/CELL_SIZE)

                if x != -1 && y != -1 && x < GRID_SIZE && y < GRID_SIZE && grid[x][y] == .Wall {
                    wall := rl.Rectangle{
                        x = f32(x)*CELL_SIZE,
                        y = f32(y)*CELL_SIZE,
                        width = CELL_SIZE,
                        height = CELL_SIZE,
                    }  
                    //Check rectangle collision
                    if rl.CheckCollisionRecs(player_rect, wall) {
                        new_x = wall.x - player_rect.width
                        break
                    }
                }
            } 
        } else if moveDirection.x < 0 {
            for pos in direction {
                //get tilemap coordinates
                x := int((new_x+half_size)/CELL_SIZE)-1
                y := pos+int((new_y+half_size)/CELL_SIZE)
                if x != -1 && y != -1 && x < GRID_SIZE && y < GRID_SIZE && grid[x][y] == .Wall {
                    wall := rl.Rectangle{
                        x = f32(x)*CELL_SIZE,
                        y = f32(y)*CELL_SIZE,
                        width = CELL_SIZE,
                        height = CELL_SIZE,
                    }  
                    //Check rectangle collision
                    if rl.CheckCollisionRecs(player_rect, wall) {
                        new_x = wall.x + wall.width
                        break
                    }
                }
            } 
        }
    }

    //Loop through the steps updating each time
    for i in 0..<num_steps {
        current_pos_y += step_y

        player_rect := rl.Rectangle{
            x = player.position.x,
            y = current_pos_y,
            width = CELL_SIZE,
            height = CELL_SIZE
        }
        if moveDirection.y > 0 {
            for pos in direction {
                //get tilemap coordinates
                x := pos+int((new_x+half_size)/CELL_SIZE)
                y := 1+int((new_y+half_size)/CELL_SIZE)

                if x != -1 && y != -1 && x < GRID_SIZE && y < GRID_SIZE && grid[x][y] == .Wall {
                    wall := rl.Rectangle{
                        x = f32(x)*CELL_SIZE,
                        y = f32(y)*CELL_SIZE,
                        width = CELL_SIZE,
                        height = CELL_SIZE,
                    }  
                    //Check rectangle collision
                    if rl.CheckCollisionRecs(player_rect, wall) {
                        new_y = wall.y - player_rect.height
                        break
                    }
                }
            } 
        } else if moveDirection.y < 0 {
            for pos in direction {
                //get tilemap coordinates
                x := pos+int((new_x+half_size)/CELL_SIZE)
                y := int((new_y+half_size)/CELL_SIZE)-1

                if x != -1 && y != -1 && x < GRID_SIZE && y < GRID_SIZE && grid[x][y] == .Wall {
                    wall := rl.Rectangle{
                        x = f32(x)*CELL_SIZE,
                        y = f32(y)*CELL_SIZE,
                        width = CELL_SIZE,
                        height = CELL_SIZE,
                    }  
                    //Check rectangle collision
                    if rl.CheckCollisionRecs(player_rect, wall) {
                        new_y = wall.y + wall.height
                        break
                    }
                }
            } 
        } 
    }

    player.position.x = new_x
    player.position.y = new_y
}