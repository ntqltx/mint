package voxel

import rl "vendor:raylib"

main :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .MSAA_4X_HINT})
	rl.InitWindow(1280, 720, "voxel")
	defer rl.CloseWindow()

	rl.SetTargetFPS(
		rl.GetMonitorRefreshRate(rl.GetCurrentMonitor())
	)

	cam := camera_init()
	world := world_init()

	for !rl.WindowShouldClose() {
		camera_update(&cam)

		rl.BeginDrawing()
		rl.ClearBackground({40, 40, 40, 255})

		rl.BeginMode3D(cam.camera)
		rl.DrawGrid(32, 1)
		rl.EndMode3D()

		ui_draw(&cam)
		rl.EndDrawing()
	}
}
