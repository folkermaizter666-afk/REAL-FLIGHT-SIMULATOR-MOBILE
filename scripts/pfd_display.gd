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
    var horizon := center + Vector2(0.0, pitch_deg * 0.72)
    var span := w * 0.72
    var point_a := horizon - axis * span
    var point_b := horizon + axis * span
    var far := normal * h * 1.6
    draw_colored_polygon(PackedVector2Array([point_a - far, point_b - far, point_b, point_a]), Color(0.12, 0.34, 0.58))
    draw_colored_polygon(PackedVector2Array([point_a, point_b, point_b + far, point_a + far]), Color(0.42, 0.25, 0.12))
    draw_line(point_a, point_b, Color(0.95, 0.95, 0.9), 2.0)

    # Marcas de cabeceo.
    for mark in [-20, -10, 10, 20]:
        var mark_center := horizon + normal * float(mark) * 0.72
        draw_line(mark_center - axis * 13.0, mark_center + axis * 13.0, Color.WHITE, 1.2)

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
