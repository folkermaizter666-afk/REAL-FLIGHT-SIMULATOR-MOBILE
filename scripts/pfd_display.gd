extends Control

# PFD gráfico ligero: dibujado por código, sin texturas ni nodos 3D adicionales.
var airspeed := 0.0
var altitude := 0.0
var pitch_deg := 0.0
var roll_deg := 0.0
var vertical_speed_fpm := 0.0

func _ready() -> void:
    clip_contents = true

func set_flight_data(speed: float, height: float, pitch_value: float, roll_value: float, vs_fpm: float) -> void:
    airspeed = speed
    altitude = height
    pitch_deg = pitch_value
    roll_deg = roll_value
    vertical_speed_fpm = vs_fpm
    queue_redraw()

func _draw() -> void:
    var w := size.x
    var h := size.y
    draw_rect(Rect2(Vector2.ZERO, size), Color(0.025, 0.045, 0.065), true)

    # Horizonte artificial simplificado.
    var center := Vector2(w * 0.5, h * 0.52)
    var roll_rad := deg_to_rad(roll_deg)
    var axis := Vector2(cos(roll_rad), sin(roll_rad))
    var normal := Vector2(-axis.y, axis.x)
    var central_rect := Rect2(Vector2(52, 20), Vector2(w - 104, h - 40))
    var horizon_y := clampf(center.y + pitch_deg * 0.72, central_rect.position.y + 2.0, central_rect.end.y - 2.0)
    draw_rect(Rect2(central_rect.position, Vector2(central_rect.size.x, horizon_y - central_rect.position.y)), Color(0.12, 0.34, 0.58), true)
    draw_rect(Rect2(Vector2(central_rect.position.x, horizon_y), Vector2(central_rect.size.x, central_rect.end.y - horizon_y)), Color(0.42, 0.25, 0.12), true)
    var half_x := central_rect.size.x * 0.5
    var half_y := central_rect.size.y * 0.5
    var span_x := half_x / maxf(absf(axis.x), 0.001)
    var span_y := half_y / maxf(absf(axis.y), 0.001)
    var span := minf(span_x, span_y)
    var horizon := Vector2(center.x, horizon_y)
    var point_a := horizon - axis * span
    var point_b := horizon + axis * span
    draw_line(point_a, point_b, Color(0.95, 0.95, 0.9), 2.0)

    # Marcas de cabeceo.
    for mark in [-20, -10, 10, 20]:
        var mark_center := horizon + normal * float(mark) * 0.72
        var mark_start := mark_center - axis * 13.0
        var mark_end := mark_center + axis * 13.0
        if central_rect.has_point(mark_start) and central_rect.has_point(mark_end):
            draw_line(mark_start, mark_end, Color.WHITE, 1.2)

    # Cintas de velocidad y altitud encima del horizonte.
    draw_rect(Rect2(3, 8, 46, h - 16), Color(0.025, 0.055, 0.075), true)
    draw_rect(Rect2(w - 49, 8, 46, h - 16), Color(0.025, 0.055, 0.075), true)
    draw_rect(Rect2(3, h * 0.5 - 11, 46, 22), Color(0.04, 0.17, 0.12), true)
    draw_rect(Rect2(w - 49, h * 0.5 - 11, 46, 22), Color(0.04, 0.17, 0.12), true)
    draw_rect(Rect2(3, 8, 46, h - 16), Color(0.45, 0.58, 0.68), false, 1.0)
    draw_rect(Rect2(w - 49, 8, 46, h - 16), Color(0.45, 0.58, 0.68), false, 1.0)

    var font := get_theme_default_font()
    draw_string(font, Vector2(54, 13), "PFD  |  DEMO", HORIZONTAL_ALIGNMENT_LEFT, 100, 10, Color(0.55, 0.9, 1.0))
    draw_string(font, Vector2(5, 20), "IAS", HORIZONTAL_ALIGNMENT_LEFT, 40, 10, Color(0.55, 0.9, 1.0))
    draw_string(font, Vector2(w - 47, 20), "ALT", HORIZONTAL_ALIGNMENT_LEFT, 40, 10, Color(0.55, 0.9, 1.0))
    draw_string(font, Vector2(5, h * 0.5 + 4), "%03d" % int(airspeed), HORIZONTAL_ALIGNMENT_LEFT, 43, 11, Color(0.55, 1.0, 0.65))
    draw_string(font, Vector2(w - 47, h * 0.5 + 4), "%05d" % int(altitude), HORIZONTAL_ALIGNMENT_LEFT, 44, 10, Color(0.55, 1.0, 0.65))

    # Símbolo fijo del avión y lectura de velocidad vertical.
    draw_line(center + Vector2(-21, 0), center + Vector2(-7, 0), Color(1.0, 0.85, 0.2), 2.5)
    draw_line(center + Vector2(7, 0), center + Vector2(21, 0), Color(1.0, 0.85, 0.2), 2.5)
    draw_line(center + Vector2(0, -5), center + Vector2(0, 5), Color(1.0, 0.85, 0.2), 2.0)
    var vs_sign := "+" if vertical_speed_fpm >= 0.0 else ""
    var vs_text := "VS " + vs_sign + str(roundi(vertical_speed_fpm)) + " ft/min"
    draw_string(font, Vector2(w * 0.5 - 48, h - 4), vs_text, HORIZONTAL_ALIGNMENT_LEFT, 100, 10, Color.WHITE)
