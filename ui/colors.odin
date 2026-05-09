package ui

import rl "vendor:raylib"

color :: proc(r, g, b: u8, alpha: Maybe(u8) = 255) -> rl.Color {
    fixed_alpha : u8 = 255
    if num, ok := alpha.?; ok {
        fixed_alpha = num
    }
    return rl.Color{r, g, b, fixed_alpha}
}

COLOR_BG       :: rl.Color{38, 38, 38, 235}
COLOR_BORDER   :: rl.Color{60, 60, 60, 255}
COLOR_TEXT     :: rl.Color{220, 220, 220, 255}
COLOR_DIM      :: rl.Color{150, 150, 150, 255}