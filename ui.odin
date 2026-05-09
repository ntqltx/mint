package voxel

import "core:math/linalg"

import ui "./ui"
import rl "vendor:raylib"

@(private="file") c: ^Camera

ui_draw :: proc(cam: ^Camera) {
	c = cam
	info_panel()
}

info_panel :: proc() {
	pos := c.cam.position
	fwd := linalg.normalize(c.cam.target - c.cam.position)

	ui.begin(ui.Frame{
		x=10, y=20, w=200, h=100,
		bg=ui.COLOR_BG,
		border=ui.COLOR_BORDER, border_px = 1,
		padding=10, gap=6, 

		// temporary idea
		text_size=16, 
		text_color=ui.COLOR_TEXT
	})
		ui.labelf("fps %d", rl.GetFPS())
		ui.labelf("pos %.1f  %.1f  %.1f", pos.x, pos.y, pos.z)
		ui.labelf("look %.2f  %.2f  %.2f", fwd.x, fwd.y, fwd.z)
		
		mouse := ui.label(c.mouse_locked ? "mouse locked [Tab]" : "mouse free [Tab]")
		mouse.size, mouse.color = 14, ui.COLOR_DIM
	ui.end()
}