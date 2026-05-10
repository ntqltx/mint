package voxel

import "ui"
import "scene"

import "core:math/linalg"
import rl "vendor:raylib"

@(private="file") c: ^scene.Camera

ui_draw :: proc(cam: ^scene.Camera) {
	c = cam
	info_panel()
}

info_panel :: proc() {
	pos := c.camera.position
	fwd := linalg.normalize(c.camera.target - c.camera.position)

	ui.begin(ui.Frame{
		x=10, y=10, w=175, h=80,
		bg=ui.COLOR_BG,
		border=ui.COLOR_BORDER, border_px = 1,
		corner_radius=6,
		padding=10, gap=6, 

		// temporary idea
		text_size=16, 
		text_color=ui.COLOR_TEXT
	})
		ui.labelf("fps %d", rl.GetFPS())
		ui.labelf("pos %.1f  %.1f  %.1f", pos.x, pos.y, pos.z)
		ui.labelf("look %.2f  %.2f  %.2f", fwd.x, fwd.y, fwd.z)
	ui.end()
}