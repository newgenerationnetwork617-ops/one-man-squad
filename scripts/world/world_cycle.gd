class_name SquadWorldCycle
extends Node
## Lightweight world time and weather controller for the mobile compatibility renderer.

enum Weather { SUNNY, CLOUDY, FOG, RAIN, STORM }

@export var cycle_enabled := true
@export_range(60.0, 3600.0, 30.0) var seconds_per_day := 900.0
@export_range(0.0, 24.0, 0.25) var time_of_day := 9.0

var world_environment: WorldEnvironment
var sunlight: DirectionalLight3D
var current_weather: Weather = Weather.SUNNY

func configure(environment_node: WorldEnvironment, sun_node: DirectionalLight3D) -> void:
	world_environment = environment_node
	sunlight = sun_node
	_apply_world_state()

func _process(delta: float) -> void:
	if cycle_enabled:
		time_of_day = fposmod(time_of_day + (24.0 / seconds_per_day) * delta, 24.0)
		_apply_lighting()

func set_time_of_day(hour: float) -> void:
	time_of_day = fposmod(hour, 24.0)
	_apply_lighting()

func set_weather(weather_name: String) -> bool:
	var normalized := weather_name.to_lower()
	match normalized:
		"sunny":
			current_weather = Weather.SUNNY
		"cloudy":
			current_weather = Weather.CLOUDY
		"fog":
			current_weather = Weather.FOG
		"rain":
			current_weather = Weather.RAIN
		"storm":
			current_weather = Weather.STORM
		_:
			return false
	_apply_world_state()
	return true

func weather_name() -> String:
	return ["sunny", "cloudy", "fog", "rain", "storm"][int(current_weather)]

func _apply_world_state() -> void:
	_apply_lighting()
	if not is_instance_valid(world_environment) or world_environment.environment == null:
		return
	var environment := world_environment.environment
	environment.fog_enabled = current_weather == Weather.FOG or current_weather == Weather.STORM
	environment.fog_density = 0.0025 if current_weather == Weather.FOG else (0.0018 if current_weather == Weather.STORM else 0.0012)
	match current_weather:
		Weather.SUNNY:
			environment.ambient_light_energy = 0.82
			if is_instance_valid(sunlight): sunlight.light_energy = _daylight_energy() * 1.15
		Weather.CLOUDY, Weather.RAIN:
			environment.ambient_light_energy = 0.62
			if is_instance_valid(sunlight): sunlight.light_energy = _daylight_energy() * 0.72
		Weather.FOG:
			environment.ambient_light_energy = 0.7
			environment.fog_light_color = Color(0.68, 0.72, 0.74)
			if is_instance_valid(sunlight): sunlight.light_energy = _daylight_energy() * 0.6
		Weather.STORM:
			environment.ambient_light_energy = 0.38
			environment.fog_light_color = Color(0.35, 0.4, 0.45)
			if is_instance_valid(sunlight): sunlight.light_energy = _daylight_energy() * 0.35

func _apply_lighting() -> void:
	if not is_instance_valid(sunlight):
		return
	var daylight := _daylight_energy()
	sunlight.rotation_degrees = Vector3(-90.0 + time_of_day * 15.0, -28.0, 0.0)
	sunlight.light_energy = daylight

func _daylight_energy() -> float:
	var solar_angle := (time_of_day - 6.0) / 12.0 * PI
	return clampf(sin(solar_angle), 0.08, 1.0)
