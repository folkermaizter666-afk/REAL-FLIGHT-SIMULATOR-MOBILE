extends Control

# ND esquemático: rosa de rumbo móvil y bug de rumbo seleccionado.
var heading_deg := 0.0
var selected_heading_deg := 0.0

func _ready() -> void:
    clip_contents = true

func set_navigation_data(current_heading: float, selected_heading: float) -> void:
    heading_deg = current_heading
    selected_heading_deg = selected_heading
    queue_redraw()

func _draw() -> void:
    var w := size.x
    var h := size.y
    draw_rect(Rect2(Vector2.ZERO, size), Color(0.018, 0.055, 0.07), true)
    var center := Vector2(w * 0.5, h * 0.56)
    var radius := minf(w * 0.34, h * 0.39)
    draw_circle(center, radius, Color(0.015, 0.025, 0.035))
    draw_arc(center, radius, 0.0, TAU, 72, Color(0.25, 0.8, 0.72), 1.5, true)

    for degree in range(0, 360, 10):
        var angle := deg_to_rad(float(degree) - heading_deg - 90.0)
        var direction := Vector2(cos(angle), sin(angle))
        var tick_length := 10.0 if degree % 30 == 0 else 5.0
        var outer := center + direction * radius
        var inner := center + direction * (radius - tick_length)
        draw_line(inner, outer, Color(0.75, 0.9, 0.85), 1.2)
        if degree % 30 == 0:
            var label_pos := center + direction * (radius - 22.0) + Vector2(-9.0, 4.0)
            draw_string(get_theme_default_font(), label_pos, "%03d" % degree, HORIZONTAL_ALIGNMENT_CENTER, 22, 9, Color(0.75, 0.9, 0.85))

    # Marca de rumbo seleccionado.
    var selected_angle := deg_to_rad(selected_heading_deg - heading_deg - 90.0)
    var selected_direction := Vector2(cos(selected_angle), sin(selected_angle))
    var bug_tip := center + selected_direction * (radius + 3.0)
    var bug_side := Vector2(-selected_direction.y, selected_direction.x) * 5.0
    draw_colored_polygon(PackedVector2Array([bug_tip, bug_tip - selected_direction * 10.0 + bug_side, bug_tip - selected_direction * 10.0 - bug_side]), Color(1.0, 0.75, 0.15))

    # Símbolo de avión fijo en el centro.
    draw_line(center + Vector2(-15, 0), center + Vector2(-5, 0), Color(1.0, 0.85, 0.25), 2.0)
    draw_line(center + Vector2(5, 0), center + Vector2(15, 0), Color(1.0, 0.85, 0.25), 2.0)
    draw_line(center + Vector2(0, -10), center + Vector2(0, 5), Color(1.0, 0.85, 0.25), 2.0)

    draw_string(get_theme_default_font(), Vector2(7, 15), "ND  |  DEMO", HORIZONTAL_ALIGNMENT_LEFT, 100, 10, Color(0.55, 0.9, 1.0))
    draw_string(get_theme_default_font(), Vector2(w - 92, 15), "HDG %03d" % int(heading_deg), HORIZONTAL_ALIGNMENT_RIGHT, 85, 10, Color.WHITE)
    draw_string(get_theme_default_font(), Vector2(w * 0.5 - 42, h - 4), "SEL %03d" % int(selected_heading_deg), HORIZONTAL_ALIGNMENT_CENTER, 84, 10, Color(1.0, 0.8, 0.25))
