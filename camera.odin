package voxel

import "core:math"

import rl "vendor:raylib"

Camera :: struct {
    camera:                     rl.Camera,
    previous_mouse_position:    rl.Vector2,
    is_mouse_dragging:          bool,
    free_fly:                   bool,

    zoom:                       f32,
    zoom_speed:                 f32,
    move_speed:                 f32,
    move_speed_fast:            f32,
    move_speed_slow:            f32,
    pan_speed:                  f32,
    rotation_speed:             f32,
    free_fly_rotation_speed:    f32,

    // pitch limits to prevent gimbal lock
    min_pitch, max_pitch:       f32,
    current_pitch:              f32,
}

camera_init :: proc() -> Camera {
    return Camera{
        camera = rl.Camera{
            position = {10.0, 10.0, 10.0},
            target = {0.0, 0.0, 0.0},
            up = {0.0, 1.0, 0.0},
            fovy = 60.0,

            projection = rl.CameraProjection.PERSPECTIVE,
        },
        previous_mouse_position = {0, 0},
        is_mouse_dragging = false,
        move_speed = 0.2,
        move_speed_fast = 0.4,
        move_speed_slow = 0.1,

        free_fly_rotation_speed = 0.001,
        free_fly = false,
        rotation_speed = 0.005,
        pan_speed = 0.01,
        zoom_speed = 0.2,

        min_pitch = -89.5 * math.PI / 180.0,
        max_pitch = 89.5 * math.PI / 180.0,
        current_pitch = 0.0,
    }
}

camera_update :: proc(c: ^Camera) {
    mouse_position := rl.GetMousePosition()
    left_shift_down := rl.IsKeyDown(.LEFT_SHIFT)

    middle_mouse_down := rl.IsMouseButtonDown(.MIDDLE)
    right_mouse_down := rl.IsMouseButtonDown(.RIGHT)
    is_dragging := middle_mouse_down || right_mouse_down

    if rl.IsKeyPressed(.F) && left_shift_down {
        c.free_fly = !c.free_fly
        if c.free_fly do rl.DisableCursor()
        else do rl.EnableCursor()
    }

    if !c.free_fly {
        if is_dragging && !c.is_mouse_dragging do rl.DisableCursor()
        else if !is_dragging && c.is_mouse_dragging do rl.EnableCursor()
    }
    c.is_mouse_dragging = is_dragging

    if !c.free_fly {
        wheel_move := rl.GetMouseWheelMove()
        direction := rl.Vector3Normalize(c.camera.target - c.camera.position)

        if wheel_move != 0 {
            c.camera.position += direction * (wheel_move * c.zoom_speed)
        }

        if is_dragging {
            mouse_delta := -rl.GetMouseDelta()

            if left_shift_down {
                right := rl.Vector3Normalize(rl.Vector3CrossProduct(direction, c.camera.up))
                up := rl.Vector3Normalize(rl.Vector3CrossProduct(right, direction))
                pan := right * (mouse_delta.x * c.pan_speed) +
                       up * (-mouse_delta.y * c.pan_speed)

                c.camera.position += pan
                c.camera.target += pan
            } 
            else {
                new_pitch := c.current_pitch + mouse_delta.y * c.rotation_speed
                c.current_pitch = clamp(new_pitch, c.min_pitch, c.max_pitch)

                yaw := rl.QuaternionFromAxisAngle({0, 1, 0}, mouse_delta.x * c.rotation_speed)
                right := rl.Vector3Normalize(rl.Vector3CrossProduct(direction, c.camera.up))
                pitch := rl.QuaternionFromAxisAngle(right, mouse_delta.y * c.rotation_speed)
                rotation := pitch * yaw

                cam_to_target := c.camera.position - c.camera.target
                rotated := rl.Vector3Transform(cam_to_target, rl.QuaternionToMatrix(rotation))
                new_position := c.camera.target + rotated

                new_dir := rl.Vector3Normalize(c.camera.target - new_position)
                if abs(rl.Vector3DotProduct(new_dir, {0, 1, 0})) < 0.99 {
                    c.camera.position = new_position
                }
            }
        }
    } 
    else {
        delta := rl.GetMouseDelta()

        fly_speed := c.move_speed
        if left_shift_down do fly_speed = c.move_speed_fast
        if rl.IsKeyDown(.LEFT_CONTROL) do fly_speed = c.move_speed_slow

        movement: rl.Vector3
        if rl.IsKeyDown(.W) do movement.x += fly_speed
        if rl.IsKeyDown(.S) do movement.x -= fly_speed
        if rl.IsKeyDown(.D) do movement.y += fly_speed
        if rl.IsKeyDown(.A) do movement.y -= fly_speed
        if rl.IsKeyDown(.E) do movement.z -= fly_speed
        if rl.IsKeyDown(.Q) do movement.z += fly_speed

        rl.UpdateCameraPro(&c.camera, movement, {delta.x * 0.05, delta.y * 0.05, 0}, 0)
    }
}