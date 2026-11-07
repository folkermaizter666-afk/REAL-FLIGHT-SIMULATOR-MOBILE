extends Node3D

# Prototipo educativo: física simplificada, no apta para entrenamiento aeronáutico.
const GRAVITY := 9.81
var throttle := 0.0
var airspeed := 0.0
var altitude := 120.0
var vertical_speed := 0.0
var heading := 0.0
var pitch := 0.0
var bank := 0.0
var battery_on := false
var engines_on := false
var gear_down := true
var flaps := 0
var autopilot_on := false
var exterior_view := false
var plane: Node3D
var cockpit_camera: Camera3D
var exterior_camera: Camera3D
var hud: CanvasLayer
var status_label: Label
var speed_label: Label
var altitude_label: Label
var heading_label: Label
var throttle_slider: HSlider
var pitch_input := 0.0
var bank_input := 0.0

func _ready() -> void:
    _build_world()
    _build_aircraft()
    _build_cameras()
    _build_hud()
    _update_labels()

func _build_world() -> void:
    var world_env := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_SKY
    env.sky = Sky.new()
    env.sky.sky_material = ProceduralSkyMaterial.new()
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.72, 0.78, 0.86)
    env.ambient_light_energy = 0.65
    world_env.environment = env
    add_child(world_env)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -25, 0)
    sun.light_energy = 1.1
    add_child(sun)

    var ground := _make_box("Ground", Vector3(0, -1.2, -120), Vector3(700, 1, 700), Color(0.16, 0.34, 0.18))
    add_child(ground)
    var runway := _make_box("Runway", Vector3(0, -0.65, -120), Vector3(28, 0.15, 520), Color(0.12, 0.13, 0.14))
    add_child(runway)
    for i in range(12):
        var stripe := _make_box("Centerline", Vector3(0, -0.55, 110 - i * 38), Vector3(0.8, 0.08, 18), Color(0.92, 0.92, 0.88))
        add_child(stripe)
    for x in [-16.0, 16.0]:
        var edge := _make_box("RunwayEdge", Vector3(x, -0.54, -120), Vector3(0.35, 0.08, 520), Color.WHITE)
        add_child(edge)

func _make_box(label: String, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
    var mesh_instance := MeshInstance3D.new()
    mesh_instance.name = label
    var box := BoxMesh.new()
    box.size = size
    mesh_instance.mesh = box
    mesh_instance.position = pos
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.9
    mesh_instance.material_override = mat
    return mesh_instance

func _build_aircraft() -> void:
    plane = Node3D.new()
    plane.name = "B737_800_Prototype"
    plane.position = Vector3(0, 1.0, 30)
    add_child(plane)

    var fuselage := _make_box("Fuselage", Vector3(0, 0, 0), Vector3(2.2, 2.0, 17.0), Color(0.82, 0.84, 0.87))
    plane.add_child(fuselage)
    var wing := _make_box("Wings", Vector3(0, -0.1, -0.5), Vector3(34, 0.45, 4.0), Color(0.76, 0.79, 0.83))
    plane.add_child(wing)
    var tail := _make_box("Tailplane", Vector3(0, 2.0, 6.5), Vector3(12, 0.35, 2.0), Color(0.78, 0.8, 0.84))
    plane.add_child(tail)
    var fin := _make_box("VerticalTail", Vector3(0, 2.8, 7.2), Vector3(0.45, 5.0, 2.0), Color(0.12, 0.22, 0.48))
    plane.add_child(fin)
    for x in [-6.5, 6.5]:
        var engine := _make_box("Engine", Vector3(x, -0.8, 0.0), Vector3(2.5, 2.0, 4.0), Color(0.32, 0.35, 0.39))
        plane.add_child(engine)

func _build_cameras() -> void:
    cockpit_camera = Camera3D.new()
    cockpit_camera.name = "CockpitCamera"
    cockpit_camera.position = Vector3(0, 1.55, -5.7)
    cockpit_camera.rotation_degrees = Vector3(-3, 0, 0)
    plane.add_child(cockpit_camera)
    cockpit_camera.current = true

    exterior_camera = Camera3D.new()
    exterior_camera.name = "ExteriorCamera"
    exterior_camera.position = Vector3(0, 8, 23)
    exterior_camera.rotation_degrees = Vector3(-12, 180, 0)
    plane.add_child(exterior_camera)

func _build_hud() -> void:
    hud = CanvasLayer.new()
    add_child(hud)
    var root := Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    hud.add_child(root)

    var top := PanelContainer.new()
    top.position = Vector2(12, 10)
    top.size = Vector2(300, 108)
    root.add_child(top)
    var info := VBoxContainer.new()
    top.add_child(info)
    var title := Label.new()
    title.text = "REAL FLIGHT SIMULATOR  |  B737-800"
    title.add_theme_font_size_override("font_size", 15)
    info.add_child(title)
    speed_label = _new_label("IAS  000 kt")
    altitude_label = _new_label("ALT  00120 ft")
    heading_label = _new_label("HDG  000°")
    info.add_child(speed_label)
    info.add_child(altitude_label)
    info.add_child(heading_label)

    status_label = Label.new()
    status_label.position = Vector2(330, 14)
    status_label.size = Vector2(330, 32)
    status_label.text = "BATTERY OFF  |  ENGINES OFF"
    status_label.add_theme_color_override("font_color", Color.WHITE)
    status_label.add_theme_font_size_override("font_size", 16)
    root.add_child(status_label)

    var controls := HBoxContainer.new()
    controls.position = Vector2(12, 332)
    controls.size = Vector2(936, 88)
    controls.add_theme_constant_override("separation", 8)
    root.add_child(controls)

    var left := VBoxContainer.new()
    left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    controls.add_child(left)
    left.add_child(_new_label("POTENCIA"))
    throttle_slider = HSlider.new()
    throttle_slider.min_value = 0
    throttle_slider.max_value = 100
    throttle_slider.value = 0
    throttle_slider.custom_minimum_size = Vector2(180, 28)
    throttle_slider.value_changed.connect(_on_throttle_changed)
    left.add_child(throttle_slider)

    var buttons := [
        ["BATERÍA", _toggle_battery],
        ["MOTORES", _toggle_engines],
        ["TREN", _toggle_gear],
        ["FLAPS", _cycle_flaps],
        ["CÁMARA", _toggle_camera],
        ["AP", _toggle_autopilot]
    ]
    for item in buttons:
        var b := Button.new()
        b.text = item[0]
        b.custom_minimum_size = Vector2(92, 52)
        b.pressed.connect(item[1])
        controls.add_child(b)

    var attitude := HBoxContainer.new()
    attitude.position = Vector2(690, 12)
    attitude.size = Vector2(258, 62)
    root.add_child(attitude)
    for item in [["↑", Vector2(0, -1)], ["↓", Vector2(0, 1)], ["←", Vector2(-1, 0)], ["→", Vector2(1, 0)]]:
        var b := Button.new()
        b.text = item[0]
        b.custom_minimum_size = Vector2(58, 52)
        b.pressed.connect(_set_attitude.bind(item[1]))
        attitude.add_child(b)

    var note := Label.new()
    note.position = Vector2(12, 125)
    note.text = "PROTOTIPO: física simplificada. Controles y sistemas en desarrollo."
    note.add_theme_color_override("font_color", Color.WHITE)
    root.add_child(note)

func _new_label(text_value: String) -> Label:
    var l := Label.new()
    l.text = text_value
    l.add_theme_font_size_override("font_size", 14)
    return l

func _on_throttle_changed(value: float) -> void:
    throttle = value / 100.0

func _toggle_battery() -> void:
    battery_on = not battery_on
    if not battery_on:
        engines_on = false
    _update_labels()

func _toggle_engines() -> void:
    if battery_on:
        engines_on = not engines_on
    _update_labels()

func _toggle_gear() -> void:
    gear_down = not gear_down
    _update_labels()

func _cycle_flaps() -> void:
    flaps = (flaps + 1) % 5
    _update_labels()

func _toggle_camera() -> void:
    exterior_view = not exterior_view
    cockpit_camera.current = not exterior_view
    exterior_camera.current = exterior_view

func _toggle_autopilot() -> void:
    if battery_on:
        autopilot_on = not autopilot_on
    _update_labels()

func _set_attitude(axis: Vector2) -> void:
    pitch_input = clampf(axis.y, -1.0, 1.0)
    bank_input = clampf(axis.x, -1.0, 1.0)

func _process(delta: float) -> void:
    # Resetea entradas de actitud para que los botones funcionen como impulsos.
    pitch_input = move_toward(pitch_input, 0.0, delta * 1.8)
    bank_input = move_toward(bank_input, 0.0, delta * 1.8)

func _physics_process(delta: float) -> void:
    if engines_on:
        var target_speed := 285.0 * throttle
        airspeed = move_toward(airspeed, target_speed, delta * (12.0 if throttle > 0.1 else 22.0))
    else:
        airspeed = move_toward(airspeed, 0.0, delta * 18.0)

    if autopilot_on:
        pitch = move_toward(pitch, 0.0, delta * 0.25)
        bank = move_toward(bank, 0.0, delta * 0.25)
    else:
        pitch = clampf(pitch + pitch_input * delta * 0.5, -0.35, 0.35)
        bank = clampf(bank + bank_input * delta * 0.65, -0.65, 0.65)

    heading = fposmod(heading + sin(bank) * airspeed * delta * 0.018, 360.0)
    var lift_factor := clampf((airspeed - 80.0) / 100.0, 0.0, 1.3)
    vertical_speed = (pitch * airspeed * 0.10) + (lift_factor * 1.8) - (0.7 if airspeed < 100.0 else 0.0)
    altitude = maxf(0.0, altitude + vertical_speed * delta * 60.0)

    if plane:
        plane.rotation.z = -bank
        plane.rotation.x = pitch
        plane.rotation.y = deg_to_rad(heading)
        plane.position.y = 1.0 + (altitude - 120.0) * 0.025
        plane.position.z -= airspeed * delta * 0.045

    _update_labels()

func _update_labels() -> void:
    if not is_instance_valid(status_label):
        return
    speed_label.text = "IAS  %03d kt" % int(airspeed)
    altitude_label.text = "ALT  %05d ft" % int(altitude)
    heading_label.text = "HDG  %03d°" % int(heading)
    status_label.text = "BATTERY %s  |  ENGINES %s  |  GEAR %s  |  FLAPS %d" % [
        "ON" if battery_on else "OFF",
        "ON" if engines_on else "OFF",
        "DOWN" if gear_down else "UP",
        flaps * 5
    ]
