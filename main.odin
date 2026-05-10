package voxel

import "ui"
import "scene"

import rl "vendor:raylib"

main :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .MSAA_4X_HINT})
	rl.InitWindow(1280, 720, "voxel")
	defer rl.CloseWindow()
	
	rl.SetTargetFPS(
		rl.GetMonitorRefreshRate(rl.GetCurrentMonitor())
	)
	
	cam := scene.camera_init()
	world := scene.world_init()
	
	ui.init()
	defer ui.unload()

	for !rl.WindowShouldClose() {
		scene.camera_update(&cam)
		scene.world_update(&world, cam.camera)

		rl.BeginDrawing()
		rl.ClearBackground({40, 40, 40, 255})

		rl.BeginMode3D(cam.camera)
		scene.world_draw(&world)
		rl.DrawGrid(32, 1)
		rl.EndMode3D()

		ui_draw(&cam)
		rl.EndDrawing()
	}
}
