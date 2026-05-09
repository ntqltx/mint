package voxel

import "core:math/linalg"
import rl "vendor:raylib"

UI_BG :: rl.Color{38, 38, 38, 235}
UI_BORDER :: rl.Color{60, 60, 60, 255}
UI_TEXT :: rl.Color{220, 220, 220, 255}
UI_DIM :: rl.Color{150, 150, 150, 255}

ui_draw :: proc(c: ^Camera) {
	ui_draw_info_panel(c)
}

ui_draw_info_panel :: proc(c: ^Camera) {
	x, y: i32 = 10, 10
	w, h: i32 = 240, 96
	rl.DrawRectangle(x, y, w, h, UI_BG)
	rl.DrawRectangleLines(x, y, w, h, UI_BORDER)

	pos := c.cam.position
	fwd := linalg.normalize(c.cam.target - c.cam.position)

	rl.DrawText(rl.TextFormat("fps   %d", rl.GetFPS()), x + 10, y + 8, 16, UI_TEXT)
	rl.DrawText(rl.TextFormat("pos   %.1f  %.1f  %.1f", pos.x, pos.y, pos.z), x + 10, y + 28, 16, UI_TEXT)
	rl.DrawText(rl.TextFormat("look  %.2f  %.2f  %.2f", fwd.x, fwd.y, fwd.z), x + 10, y + 48, 16, UI_TEXT)

	mode_text: cstring = c.mouse_locked ? "mouse locked  [Tab]" : "mouse free    [Tab]"
	rl.DrawText(mode_text, x + 10, y + 72, 14, UI_DIM)
}