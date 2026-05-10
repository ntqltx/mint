package scene

import rl "vendor:raylib"

CHUNK_SIZE :: 16

Chunk :: struct {
    voxels: [CHUNK_SIZE][CHUNK_SIZE][CHUNK_SIZE]u8,
    mesh:   rl.Mesh,
    dirty:  bool,
}

World :: struct {
    chunk:        Chunk,
    active_color: u8,
    raycast:      Raycast_Result,
}

Raycast_Result :: struct {
    hit:    bool,
    pos:    [3]int,
    normal: [3]int,
}

world_init :: proc() -> World {
    w := World{active_color = 4}

    for x in 0..<CHUNK_SIZE do for z in 0..<CHUNK_SIZE {
        w.chunk.voxels[x][0][z] = 4
    }
	
    return w
}

world_raycast :: proc(world: ^World, ray: rl.Ray) -> Raycast_Result {
    best : f32 = 1000
    result := Raycast_Result{}

    for x in 0..<CHUNK_SIZE do for y in 0..<CHUNK_SIZE do for z in 0..<CHUNK_SIZE {
        if world.chunk.voxels[x][y][z] == 0 do continue

        box := rl.BoundingBox{
            min = float({x, y, z}),
            max = float({x, y, z}, 1),
        }
        col := rl.GetRayCollisionBox(ray, box)
		
        if (col.hit) && (col.distance < best) {
            best = col.distance
            result = {
				true, {x, y, z}, 
				{
					int(col.normal.x), 
					int(col.normal.y), 
					int(col.normal.z)
				}
			}
        }
    }

    return result
}

world_update :: proc(w: ^World, cam: rl.Camera) {
    // ignoring right mouse button because of orbit/pan camera
    if rl.IsMouseButtonDown(.RIGHT) {
        w.raycast = {}
        return
    }

    ray := rl.GetScreenToWorldRay(rl.GetMousePosition(), cam)
    w.raycast = world_raycast(w, ray)

    if !w.raycast.hit do return
    p, _ := w.raycast.pos, w.raycast.normal

    // TODO: make place/erase modes
    if rl.IsMouseButtonPressed(.LEFT) {
        w.chunk.voxels[p[0]][p[1]][p[2]] = 0
        w.chunk.dirty = true
    }

    // if rl.IsMouseButtonPressed(.RIGHT) {
	// 	np := p + n
	// 	if in_bounds(np) {
	// 		w.chunk.voxels[np.x][np.y][np.z] = w.active_color
	// 		w.chunk.dirty = true
	// 	}
	// }
}

world_draw :: proc(w: ^World) {
    for x in 0..<CHUNK_SIZE do for y in 0..<CHUNK_SIZE do for z in 0..<CHUNK_SIZE {
        id := w.chunk.voxels[x][y][z]
        if id == 0 do continue

		rl.DrawCubeV(
            float({x, y, z}, 0.5),
            {1, 1, 1}, PALETTE[id]
        )
    }

    if w.raycast.hit {
        p := w.raycast.pos
        outline := float({p[0], p[1], p[2]}, 0.5)
		draw_cube_outline(outline, 0.03, rl.WHITE)
    }
}

@(private="file")
in_bounds :: proc(v: [3]int) -> bool {
    return v.x >= 0 && v.x < CHUNK_SIZE &&
           v.y >= 0 && v.y < CHUNK_SIZE &&
           v.z >= 0 && v.z < CHUNK_SIZE
}

@(private="file")
float :: proc(v: [3]int, p: Maybe(f32) = 0) -> [3]f32 {
	fixed_p : f32 = 0
	if num, ok := p.?; ok {
        fixed_p = num
    }
	return {
		f32(v[0]) + fixed_p,
		f32(v[1]) + fixed_p,
		f32(v[2]) + fixed_p 
	}
}