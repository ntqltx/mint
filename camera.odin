package voxel

import rl "vendor:raylib"

Camera :: struct {
	cam: rl.Camera3D,
	mouse_locked: bool,
}

camera_init :: proc() -> Camera {
	return Camera{
		cam = rl.Camera3D{
			position = {-10, 10, -10},
			target = {8, 0, 8},
			up = {0, 1, 0},
			fovy = 70,

			projection = .PERSPECTIVE,
		},
		mouse_locked = true,
	}
}

camera_update :: proc(c: ^Camera) {
	if rl.IsKeyPressed(.TAB) {
		c.mouse_locked = !c.mouse_locked
		if c.mouse_locked do rl.DisableCursor()
		else do rl.EnableCursor()
	}

	speed: f32 = 0.15
	movement := rl.Vector3{0, 0, 0}
	if rl.IsKeyDown(.LEFT_SHIFT) do speed *= 1.5

	if rl.IsKeyDown(.W) do movement.x += speed
	if rl.IsKeyDown(.S) do movement.x -= speed
	if rl.IsKeyDown(.D) do movement.y += speed
	if rl.IsKeyDown(.A) do movement.y -= speed
	if rl.IsKeyDown(.E) do movement.z += speed
	if rl.IsKeyDown(.Q) do movement.z -= speed

	rotation := rl.Vector3{0, 0, 0}
	if c.mouse_locked {
		delta := rl.GetMouseDelta()
		sens: f32 = 0.05

		rotation.x = delta.x * sens
		rotation.y = delta.y * sens
	}

	rl.UpdateCameraPro(
		&c.cam, movement, 
		rotation, 0
	)
}
