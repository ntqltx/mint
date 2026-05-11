package scene

import rl "vendor:raylib"

draw_cube_outline :: proc(center: rl.Vector3, thickness: f32, color: rl.Color) {
    h : f32 = 0.5
    t := thickness

    Edge :: struct { offset: rl.Vector3, dims: rl.Vector3 }
    edges := [12]Edge{
        // X edges
        {{0,  h,  h}, {1, t, t}}, {{0,  h, -h}, {1, t, t}},
        {{0, -h,  h}, {1, t, t}}, {{0, -h, -h}, {1, t, t}},
        // Y edges
        {{ h, 0,  h}, {t, 1, t}}, {{ h, 0, -h}, {t, 1, t}},
        {{-h, 0,  h}, {t, 1, t}}, {{-h, 0, -h}, {t, 1, t}},
        // Z edges
        {{ h,  h, 0}, {t, t, 1}}, {{ h, -h, 0}, {t, t, 1}},
        {{-h,  h, 0}, {t, t, 1}}, {{-h, -h, 0}, {t, t, 1}},
    }

    for e in edges do rl.DrawCubeV(
		center + e.offset, 
		{e.dims.x, e.dims.y, e.dims.z}, 
		color
	)

	// outline cube corners
    signs := []f32{-h, h}
    for sx in signs do for sy in signs do for sz in signs {
        rl.DrawCubeV(
            center + {sx, sy, sz},
            {t, t, t}, color
        )
    }
}