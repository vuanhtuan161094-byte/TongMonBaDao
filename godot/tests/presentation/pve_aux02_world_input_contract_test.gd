extends SceneTree

# Tests the real Source A world view by injecting pointer events into its
# production handler. This is automated input evidence, not physical mouse QA.
const PARTY_ID := "aux02_source_a_six"
const ENCOUNTER_ID := "aux02_world_input_contract"
const MAP_SIZE := Vector2(800.0, 520.0)
const EPSILON := 0.002

var checks := 0
var map: PveSectWorldViewV1
var battle: MapBattleV2
var actor_ids: Array[String] = []
var move_count := 0
var last_move: Dictionary = {}
var findings: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> bool:
	checks += 1
	if condition:
		return true
	push_error("PVE AUX-02 WORLD INPUT FAIL: " + message)
	quit(1)
	return false

func _run() -> void:
	map = PveSectWorldViewV1.new()
	map.size = MAP_SIZE
	root.add_child(map)
	await process_frame
	if not _check(map.world != null and map.world.camera != null,
		"production Source A camera did not initialize"):
		return
	var prepared := map.prepare_world()
	if not _check(bool(prepared.get("ok", false)),
		"Source A navigation/topology preparation failed: " + str(prepared)):
		return
	var navigation: Dictionary = map.world.pve_navigation
	var topology: Dictionary = map.topology
	var camps: Array = topology.get("camp_positions", [])
	var spawns: Array = topology.get("party_spawn_points", [])
	var source_sha := str(navigation.get("source_blob_sha", ""))
	if not _check(source_sha.length() == 40
		and str(navigation.get("source_map", "")) == "sect_isometric_source_a_pve_v1"
		and int(navigation.get("width", 0)) == 192
		and int(navigation.get("height", 0)) == 192
		and camps.size() == 20 and spawns.size() >= 6
		and map.world.pve_minimap_texture() != null,
		"real Source A 192x192 map identity, 20 zones, six spawns or minimap is missing"):
		return
	var options := map.get_open_world_options()
	if not _check(bool(options.get("ok", false)),
		"Source A view did not provide Combat V2 open-world options"):
		return
	battle = MapBattleV2.new(20261027)
	var setup := battle.setup_open_world(ENCOUNTER_ID, _make_party(spawns), [], options)
	if not _check(bool(setup.get("ok", false)) and battle.actors.size() == 6
		and battle.world_mode,
		"six valid actors could not enter the real Source A navigation grid: " + str(setup)):
		return
	for id in battle.actors.keys():
		actor_ids.append(str(id))
	actor_ids.sort()
	# This fixture creates a Combat V2 distributed open world above; pass the
	# same canonical mode bit used by P3.2 so the legacy six-member default
	# selection cannot turn a minimap camera-focus click into a move order.
	map.show_authority_snapshot(battle, {"p0_distributed_world": true}, 0, {}, {})
	map.move_ordered.connect(_on_move_ordered)
	if not _check(_actors_walkable(battle),
		"one of the six fixture actors starts outside walkable bounds"):
		return

	# Screen->world and renderer->world round trips across camera/zoom locations.
	for camp_index in [0, 4, 9, 14, 19]:
		map.camera_center = camps[camp_index]
		for zoom in [0.28, 0.55, 0.92, 1.35]:
			map.camera_zoom = zoom
			var center: Vector2 = camps[camp_index]
			for world_point in [
				center, center + Vector2(0.5, 0.5), Vector2(0.5, 0.5),
				Vector2(191.5, 191.5),
				Vector2(clampf(center.x + 6.5, 0.5, 191.5),
					clampf(center.y - 4.5, 0.5, 191.5))
			]:
				var screen := map.world_to_screen(world_point)
				var input_world := map._screen_to_cell(screen)
				var rendered_world := SectIsometricWorldV1.inverse(
					map.world.screen_to_world(screen))
				if not _check(input_world.distance_to(world_point) <= EPSILON
					and rendered_world.distance_to(world_point) <= EPSILON,
					"camera transform drift camp=%d zoom=%.2f world=%s input=%s render=%s" % [
						camp_index, zoom, str(world_point), str(input_world), str(rendered_world)]):
					return

	# Verify every one of the 20 zone positions on the same world/minimap grid
	# and that each adjacent zone pair has an all-walkable route.
	var inner := map.minimap_inner_rect()
	var bounds: Rect2 = topology.get("bounds", Rect2(Vector2.ZERO, Vector2(192, 192)))
	for camp_index in range(20):
		var camp: Vector2 = camps[camp_index]
		var cell := Vector2i(floori(camp.x), floori(camp.y))
		if not _nav_cell_allowed(navigation, cell):
			if not _check(false, "spawn zone C%02d is blocked" % [camp_index + 1]):
				return
		var marker := map.minimap_world_to_screen(camp)
		var uv := (marker - inner.position) / inner.size
		var recovered := Vector2(uv.x * bounds.size.x, uv.y * bounds.size.y)
		if not _check(recovered.distance_to(camp) <= EPSILON,
			"minimap/world coordinates diverge at C%02d" % [camp_index + 1]):
			return
		map._focus_minimap(marker)
		if not _check(map.camera_center.distance_to(camp) <= EPSILON,
			"minimap focus targets a different world position at C%02d" % [camp_index + 1]):
			return
		var next: Vector2 = camps[(camp_index + 1) % 20]
		var route: Array[Vector2i] = battle._world_path(camp, next)
		if not _check(route.size() > 1 and _path_walkable(navigation, route),
			"zone transition %d -> %d has no walkable route" % [
				camp_index + 1, (camp_index + 1) % 20 + 1]):
			return

	# Injected zoom must preserve the world point under the pointer; drag pans.
	map.camera_center = camps[0]
	map.camera_zoom = 0.55
	var anchor := Vector2(361.0, 227.0)
	var world_anchor := map._screen_to_cell(anchor)
	var zoom_event := InputEventMouseButton.new()
	zoom_event.button_index = MOUSE_BUTTON_WHEEL_UP
	zoom_event.pressed = true
	zoom_event.position = anchor
	# Wheel routing moved to _input in 42e80e8; exercise that actual
	# entrypoint instead of the legacy click/drag handler.
	map._input(zoom_event)
	if not _check(map.camera_zoom > 0.55
		and map._screen_to_cell(anchor).distance_to(world_anchor) <= EPSILON,
		"zoom changed the world point under the pointer"):
		return
	if not _check(is_equal_approx(PveSectWorldViewV1.MAX_ZOOM,1.35),
		"PvE maximum zoom is not the requested close-inspection range"):
		return
	for _step in range(20):
		var zoom_max_event := InputEventMouseButton.new()
		zoom_max_event.button_index = MOUSE_BUTTON_WHEEL_UP
		zoom_max_event.pressed = true
		zoom_max_event.position = anchor
		map._input(zoom_max_event)
	if not _check(is_equal_approx(map.camera_zoom,PveSectWorldViewV1.MAX_ZOOM),
		"wheel input did not reach the PvE zoom clamp"):
		return
	var zoom_down_event := InputEventMouseButton.new()
	zoom_down_event.button_index = MOUSE_BUTTON_WHEEL_DOWN
	zoom_down_event.pressed = true
	zoom_down_event.position = anchor
	map._input(zoom_down_event)
	if not _check(map.camera_zoom < PveSectWorldViewV1.MAX_ZOOM,
		"wheel-down did not zoom back out from the maximum"):
		return
	var camera_before := map.world.camera.position
	var right_down := InputEventMouseButton.new()
	right_down.button_index = MOUSE_BUTTON_RIGHT
	right_down.pressed = true
	right_down.position = Vector2(100, 110)
	map._handle_pointer_event(right_down)
	var drag := InputEventMouseMotion.new()
	drag.position = Vector2(117, 98)
	drag.relative = Vector2(17, -12)
	map._handle_pointer_event(drag)
	var right_up := InputEventMouseButton.new()
	right_up.button_index = MOUSE_BUTTON_RIGHT
	right_up.pressed = false
	right_up.position = drag.position
	map._handle_pointer_event(right_up)
	if not _check(not map.world.camera.position.is_equal_approx(camera_before)
		and map.camera_zoom >= PveSectWorldViewV1.MIN_ZOOM
		and map.camera_zoom <= PveSectWorldViewV1.MAX_ZOOM,
		"pan did not move the camera within declared zoom limits"):
		return
	var pan_sample: Vector2 = camps[0] + Vector2(3.5, 2.5)
	if not _check(map._screen_to_cell(map.world_to_screen(pan_sample)).distance_to(pan_sample) <= EPSILON,
		"camera pan/zoom broke world/screen coordinate agreement"):
		return

	# Left drag pans the map instead of ordering the six actors. A short
	# left click still selects/orders through the existing click contract.
	var left_pan_before := map.world.camera.position
	var left_move_count_before := move_count
	var left_down := InputEventMouseButton.new()
	left_down.button_index = MOUSE_BUTTON_LEFT
	left_down.pressed = true
	left_down.position = Vector2(240, 180)
	map._handle_pointer_event(left_down)
	var left_drag := InputEventMouseMotion.new()
	left_drag.relative = Vector2(28, -17)
	left_drag.position = left_down.position + left_drag.relative
	map._handle_pointer_event(left_drag)
	var left_up := InputEventMouseButton.new()
	left_up.button_index = MOUSE_BUTTON_LEFT
	left_up.pressed = false
	left_up.position = left_drag.position
	map._handle_pointer_event(left_up)
	if not _check(not map.world.camera.position.is_equal_approx(left_pan_before)
		and move_count == left_move_count_before,
		"left drag did not pan or accidentally issued a move order"):
		return

	# A minimap click pans; outside clicks are rejected as movement commands.
	map.camera_center = camps[0]
	var before_minimap_orders := move_count
	var before_minimap_center := map.camera_center
	_inject_click(map.minimap_world_to_screen(camps[19]))
	if not _check(move_count == before_minimap_orders
		and before_minimap_center.distance_to(map.camera_center) > 1.0,
		"minimap click issued a move command or did not pan"):
		return
	var before_invalid_orders := move_count
	_inject_click(Vector2(-4, -4))
	_inject_click(map.size + Vector2(4, 4))
	if not _check(move_count == before_invalid_orders,
		"outside-map pointer events were not rejected"):
		return

	# Walkable and blocked click targets are actual cells visible in the map,
	# outside the minimap and outside all six actor pick radii.
	map.camera_center = camps[0]
	map.camera_zoom = 0.72
	var open_cell := _find_click_cell(true, camps[0], false)
	var safe_open_cell := _find_click_cell(true, camps[0], true)
	var blocked_cell := _find_click_cell(false, camps[0], false)
	if not _check(open_cell.x >= 0 and safe_open_cell.x >= 0 and blocked_cell.x >= 0,
		"could not find visible walkable and blocked Source A click targets"):
		return
	# P0 starts with no implicit selection. Build the six-member selection via
	# the production map click path before expecting a group movement order.
	for raw_id in actor_ids:
		var actor: Dictionary = battle.actors[raw_id]
		map._select_or_move_map(map.world_to_screen(actor.get("position", Vector2.ZERO)), true)
	if not _check(map.selected_actor_ids.size() == 6,
		"P0 click-selection path did not select all six intended hunters"):
		return
	var before_open := move_count
	_inject_click(map.world_to_screen(Vector2(open_cell) + Vector2(0.5, 0.5)))
	if not _check(move_count == before_open + 1
		and bool(last_move.get("ok", false))
		and last_move.get("actor_ids", []).size() == 6,
		"walkable ground click did not issue a six-actor movement order"):
		return
	if not _six_orders_valid(battle):
		var collision := "walkable click %s produced only %d distinct destinations for six disciples" % [
			str(open_cell), _unique_order_destinations(battle)]
		findings.append(collision)
		print("PVE AUX-02 WORLD INPUT FINDING: " + collision)
	# Keep the movement/save gates deterministic by reissuing into open ground
	# whose six formation offsets are all walkable. The prior click remains a
	# recorded production behavior finding, not a physical-input claim.
	var before_safe_open := move_count
	_inject_click(map.world_to_screen(Vector2(safe_open_cell) + Vector2(0.5, 0.5)))
	if not _check(move_count == before_safe_open + 1
		and bool(last_move.get("ok", false))
		and _six_orders_valid(battle),
		"six-member move order failed on clear Source A formation ground"):
		return

	# Exercise a walkable path across each of the 20 zone transitions.
	for camp_index in range(20):
		var target: Vector2 = camps[(camp_index + 1) % 20]
		var route: Array[Vector2i] = battle._world_path(camps[camp_index], target)
		if not _check(route.size() > 1 and _path_walkable(navigation, route),
			"walkable path failed for zone transition %d -> %d" % [
				camp_index + 1, (camp_index + 1) % 20 + 1]):
			return

	# Save/Restore preserves all six active movement destinations and resumes
	# the deterministic movement loop after the durable JSON envelope round trip.
	var expected_orders := _orders(battle)
	var saved := MapBattleSnapshotV2.save(battle)
	if not _check(bool(saved.get("ok", false)),
		"active open-world orders could not be saved"):
		return
	var json_saved = JSON.parse_string(JSON.stringify(saved))
	if not _check(json_saved is Dictionary,
		"snapshot failed JSON save-envelope round trip"):
		return
	var restored_result := MapBattleSnapshotV2.load(json_saved)
	if not _check(bool(restored_result.get("ok", false)),
		"active movement orders failed to restore: " + str(restored_result)):
		return
	var restored: MapBattleV2 = restored_result["battle"]
	if not _check(_orders_equal(expected_orders, restored)
		and str(restored.world_navigation.get("source_blob_sha", "")) == source_sha,
		"Save/Restore changed active flags, destinations or map identity"):
		return
	var movement_resumed := false
	for _tick in range(8):
		var before := _positions(restored)
		var tick_result := restored.step()
		if not _check(bool(tick_result.get("ok", false)) and _actors_walkable(restored),
			"restored actor position crossed a blocked cell or world bound"):
			return
		movement_resumed = movement_resumed or _positions_changed(before, restored)
	if not _check(movement_resumed,
		"restored movement orders did not resume"):
		return

	# Blocked clicks deterministically snap to the nearest walkable cell.
	map.camera_center = camps[0]
	var nearest := PveOpenWorldTopologyV1._nearest_walkable(navigation, blocked_cell)
	if not _check(nearest.x >= 0,
		"blocked click fixture has no reachable walkable neighbor"):
		return
	var before_blocked := move_count
	_inject_click(map.world_to_screen(Vector2(blocked_cell) + Vector2(0.5, 0.5)))
	if not _check(move_count == before_blocked + 1
		and bool(last_move.get("ok", false))
		and Vector2(last_move.get("destination", Vector2(-1, -1))).distance_to(
			Vector2(nearest) + Vector2(0.5, 0.5)) <= EPSILON,
		"blocked click did not snap to the nearest walkable location"):
		return
	if not _check(_order_destinations_walkable(battle),
		"blocked click issued an order into a collision cell"):
		return

	# Simulate all 20 zone arrivals with the production Combat V2 movement step.
	var travel := MapBattleV2.new(20261028)
	var travel_setup := travel.setup_open_world(
		"aux02_twenty_zone_transitions", _make_party(spawns), [], options)
	if not _check(bool(travel_setup.get("ok", false)),
		"20-zone traveler could not enter the Source A world"):
		return
	travel.auto_hunt = false
	var traveler_id := "aux02_disciple_00"
	for camp_index in range(20):
		var target: Vector2 = camps[(camp_index + 1) % 20]
		var traveler: Dictionary = travel.actors[traveler_id]
		var route: Array[Vector2i] = travel._world_path(traveler["position"], target)
		if not _check(route.size() > 1 and _path_walkable(navigation, route),
			"traveler path to zone %d is blocked" % [(camp_index + 1) % 20 + 1]):
			return
		var move_result := travel.order_group_move([traveler_id], target)
		if not _check(bool(move_result.get("ok", false)),
			"traveler command to zone %d was rejected" % [(camp_index + 1) % 20 + 1]):
			return
		var target_cell := PveOpenWorldTopologyV1._nearest_walkable(
			navigation, Vector2i(floori(target.x), floori(target.y)))
		var destination := Vector2(target_cell) + Vector2(0.5, 0.5)
		var arrived := false
		for _step in range(maxi(route.size() * 4 + 12, 20)):
			var current: Dictionary = travel.actors[traveler_id]
			if not bool(current.get("move_order_active", false)):
				arrived = true
				break
			var result := travel.step()
			var moving: Dictionary = travel.actors[traveler_id]
			if not _check(bool(result.get("ok", false))
				and travel.is_world_position_allowed(moving["position"])
				and _nav_position_allowed(navigation, moving["position"]),
				"traveler crossed a blocked cell during zone %d" % [camp_index + 1]):
				return
		var final_actor: Dictionary = travel.actors[traveler_id]
		arrived = arrived or (not bool(final_actor.get("move_order_active", false))
			and Vector2(final_actor["position"]).distance_to(destination) <= 0.45)
		if not arrived:
			var message := "traveler stalled entering C%02d pos=%s target=%s route=%d order_active=%s" % [
				(camp_index + 1) % 20 + 1, str(final_actor["position"]),
				str(destination), route.size(), str(final_actor.get("move_order_active", false))]
			findings.append(message)
			print("PVE AUX-02 WORLD INPUT FINDING: " + message)
			break

	# A Source A monster across the stream advances toward the six-member party
	# along a walkable detour, not through collision cells.
	var detour := _find_river_detour(battle)
	if not _check(not detour.is_empty(),
		"no deterministic cross-stream monster pursuit route was found"):
		return
	var party_positions := _nearby_walkable_positions(
		navigation, detour["right_cell"], float(detour["stream_x"]) + 2.0, 6)
	if not _check(party_positions.size() == 6,
		"could not place the six-member pursuit party on the far bank"):
		return
	var monster := {
		"id": "aux02_source_a_monster",
		"species_id": "thanh_lang",
		"race_id": "yeu_thu",
		"tier": "normal",
		"spawn_slot_id": "aux02/C01/monster/0",
		"slot_generation": 1,
		"position": detour["left"],
		"stats": {"max_hp": 100.0, "attack": 4.0}
	}
	var pursuit := MapBattleV2.new(20261029)
	var pursuit_setup := pursuit.setup_open_world(
		"aux02_monster_pursuit", _make_party_from_positions(party_positions),
		[monster], options)
	if not _check(bool(pursuit_setup.get("ok", false)),
		"monster pursuit fixture setup failed: " + str(pursuit_setup)):
		return
	pursuit.auto_hunt = false
	var monster_before: Dictionary = pursuit.actors["aux02_source_a_monster"]
	var target_before := _nearest_disciple(pursuit, monster_before["position"])
	var initial_path: Array[Vector2i] = pursuit._world_path(
		monster_before["position"], target_before)
	var initial_route := pursuit._world_route_distance(
		monster_before["position"], initial_path)
	var direct_distance: float = Vector2(monster_before["position"]).distance_to(target_before)
	if not _check(initial_path.size() > 1 and initial_route > direct_distance + 2.0,
		"pursuit fixture does not force a route around a real Source A obstacle"):
		return
	var pursuit_step := pursuit.step()
	var monster_after: Dictionary = pursuit.actors["aux02_source_a_monster"]
	var target_after := _nearest_disciple(pursuit, monster_after["position"])
	var remaining_path: Array[Vector2i] = pursuit._world_path(
		monster_after["position"], target_after)
	var remaining_route := pursuit._world_route_distance(
		monster_after["position"], remaining_path)
	if not _check(bool(pursuit_step.get("ok", false))
		and pursuit.is_world_position_allowed(monster_after["position"])
		and _nav_position_allowed(navigation, monster_after["position"])
		and remaining_route < initial_route,
		"monster did not advance along valid Source A navigation toward the party"):
		return

	if findings.is_empty():
		print("PVE AUX-02 WORLD INPUT CONTRACT PASS checks=%d source_sha=%s map=%s zones=20 group=6 transitions=20 minimap=20/20 camera=roundtrip_zoom_pan injected_pointer=true blocked_snap=true movement_save_restore=6/6 pursuit=true physical_mouse=NOT_TESTED" % [
			checks, source_sha, str(navigation.get("source_map", ""))])
	else:
		print("PVE AUX-02 WORLD INPUT CONTRACT FAIL checks=%d findings=%d source_sha=%s physical_mouse=NOT_TESTED" % [
			checks, findings.size(), source_sha])
	map.queue_free()
	quit(0 if findings.is_empty() else 1)

func _make_party(spawns: Array) -> Array:
	var result: Array = []
	var roles := ["frontline", "ranged", "mage", "healer", "frontline", "ranged"]
	for index in range(6):
		result.append({
			"id": "aux02_disciple_%02d" % index,
			"party_id": PARTY_ID,
			"role": roles[index],
			"position": spawns[index],
			"stats": {"max_hp": 100.0 + index, "attack": 12.0 + index},
			"move_speed": 2.2
		})
	return result

func _make_party_from_positions(positions: Array[Vector2]) -> Array:
	var result: Array = []
	var roles := ["frontline", "ranged", "mage", "healer", "frontline", "ranged"]
	for index in range(6):
		result.append({
			"id": "aux02_pursuit_disciple_%02d" % index,
			"party_id": "aux02_pursuit_party",
			"role": roles[index],
			"position": positions[index],
			"stats": {"max_hp": 100.0 + index, "attack": 12.0 + index},
			"move_speed": 2.2
		})
	return result

func _on_move_ordered(ids: Array, destination: Vector2) -> void:
	move_count += 1
	last_move = battle.order_group_move(ids, destination)

func _inject_click(point: Vector2) -> void:
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = point
	map._handle_pointer_event(down)
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.position = point
	map._handle_pointer_event(up)

func _find_click_cell(want_walkable: bool, center: Vector2,
		require_clear_formation: bool) -> Vector2i:
	var nav: Dictionary = map.world.pve_navigation
	var width := int(nav.get("width", 0))
	var height := int(nav.get("height", 0))
	var origin := Vector2i(floori(center.x), floori(center.y))
	for radius in range(4, 17):
		for y in range(origin.y - radius, origin.y + radius + 1):
			for x in range(origin.x - radius, origin.x + radius + 1):
				if maxi(absi(x - origin.x), absi(y - origin.y)) != radius:
					continue
				var cell := Vector2i(x, y)
				if x < 0 or y < 0 or x >= width or y >= height:
					continue
				if PveOpenWorldTopologyV1._walkable(nav, cell) != want_walkable:
					continue
				var formation_base := cell if want_walkable else \
					PveOpenWorldTopologyV1._nearest_walkable(nav, cell)
				if require_clear_formation and not _formation_offsets_walkable(nav, formation_base):
					continue
				var point := Vector2(cell) + Vector2(0.5, 0.5)
				if point.distance_to(center) < 4.0 or point.distance_to(center) > 15.0:
					continue
				var screen := map.world_to_screen(point)
				if not map.map_rect().has_point(screen) or map.minimap_rect().has_point(screen):
					continue
				var near_actor := false
				for id in actor_ids:
					var actor: Dictionary = battle.actors[id]
					var rendered: Vector2 = map._render_positions.get(id, actor["position"])
					if map.world_to_screen(rendered).distance_to(screen) < 30.0:
						near_actor = true
						break
				if not near_actor:
					return cell
	return Vector2i(-1, -1)

func _formation_offsets_walkable(nav: Dictionary, base_cell: Vector2i) -> bool:
	var offsets := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1),
		Vector2i(-1, 0), Vector2i(0, -1), Vector2i(1, 1)]
	for offset in offsets:
		if not PveOpenWorldTopologyV1._walkable(nav, base_cell + offset):
			return false
	return true

func _unique_order_destinations(snapshot: MapBattleV2) -> int:
	var destinations: Dictionary = {}
	for id in actor_ids:
		var actor: Dictionary = snapshot.actors.get(id, {})
		var point: Vector2 = actor.get("move_order_position", Vector2(-1, -1))
		destinations["%d:%d" % [floori(point.x), floori(point.y)]] = true
	return destinations.size()

func _order_destinations_walkable(snapshot: MapBattleV2) -> bool:
	for id in actor_ids:
		var actor: Dictionary = snapshot.actors.get(id, {})
		var point: Vector2 = actor.get("move_order_position", Vector2(-1, -1))
		if not bool(actor.get("move_order_active", false)) \
			or not snapshot.is_world_position_allowed(point):
			return false
	return true

func _six_orders_valid(snapshot: MapBattleV2) -> bool:
	if snapshot == null or actor_ids.size() != 6:
		return false
	var slots: Dictionary = {}
	var targets: Array[Vector2] = []
	for id in actor_ids:
		if not snapshot.actors.has(id):
			return false
		var actor: Dictionary = snapshot.actors[id]
		if not bool(actor.get("move_order_active", false)):
			return false
		var destination: Vector2 = actor.get("move_order_position", Vector2(-1, -1))
		if not snapshot.is_world_position_allowed(destination):
			return false
		var cell := Vector2i(floori(destination.x), floori(destination.y))
		slots["%d:%d" % [cell.x, cell.y]] = true
		targets.append(destination)
		var route: Array[Vector2i] = snapshot._world_path(actor["position"], destination)
		if route.size() < 2 or not _path_walkable(snapshot.world_navigation, route):
			return false
	if slots.size() != 6:
		return false
	for first in range(targets.size()):
		for second in range(first + 1, targets.size()):
			if targets[first].distance_to(targets[second]) < 0.25:
				return false
	return true

func _orders(snapshot: MapBattleV2) -> Dictionary:
	var result: Dictionary = {}
	for id in actor_ids:
		var actor: Dictionary = snapshot.actors.get(id, {})
		result[id] = {
			"active": bool(actor.get("move_order_active", false)),
			"position": actor.get("move_order_position", actor.get("position", Vector2.ZERO))
		}
	return result

func _orders_equal(expected: Dictionary, snapshot: MapBattleV2) -> bool:
	for id in actor_ids:
		var expected_row: Dictionary = expected.get(id, {})
		var actor: Dictionary = snapshot.actors.get(id, {})
		if expected_row.is_empty() or actor.is_empty():
			return false
		if bool(expected_row.get("active", false)) != bool(actor.get("move_order_active", false)):
			return false
		var a: Vector2 = expected_row.get("position", Vector2.ZERO)
		var b: Vector2 = actor.get("move_order_position", actor.get("position", Vector2.ZERO))
		if a.distance_to(b) > EPSILON:
			return false
	return true

func _actors_walkable(snapshot: MapBattleV2) -> bool:
	for raw_actor in snapshot.actors.values():
		var actor: Dictionary = raw_actor
		if (not snapshot.is_world_position_allowed(actor["position"])
			or not _nav_position_allowed(snapshot.world_navigation, actor["position"])):
			return false
	return true

func _positions(snapshot: MapBattleV2) -> Dictionary:
	var result: Dictionary = {}
	for id in snapshot.actors:
		result[str(id)] = snapshot.actors[id]["position"]
	return result

func _positions_changed(before: Dictionary, snapshot: MapBattleV2) -> bool:
	for id in snapshot.actors:
		if before.has(str(id)) and not Vector2(before[str(id)]).is_equal_approx(
			Vector2(snapshot.actors[id]["position"])):
			return true
	return false

func _path_walkable(nav: Dictionary, path: Array[Vector2i]) -> bool:
	if path.is_empty():
		return false
	for cell in path:
		if not _nav_cell_allowed(nav, cell):
			return false
	return true

func _nav_cell_allowed(nav: Dictionary, cell: Vector2i) -> bool:
	var width := int(nav.get("width", 0))
	var height := int(nav.get("height", 0))
	if cell.x < 0 or cell.y < 0 or cell.x >= width or cell.y >= height:
		return false
	var blocked = nav.get("blocked", null)
	return (blocked is Array or blocked is PackedByteArray) \
		and int(blocked[cell.y * width + cell.x]) == 0

func _nav_position_allowed(nav: Dictionary, position: Vector2) -> bool:
	if not position.is_finite():
		return false
	return _nav_cell_allowed(
		nav, Vector2i(floori(position.x), floori(position.y)))

func _find_river_detour(snapshot: MapBattleV2) -> Dictionary:
	var nav: Dictionary = snapshot.world_navigation
	for y in range(40, 90, 2):
		if y in [31, 32, 33, 91, 92, 93]:
			continue
		var stream_x := SectIsometricWorldV1.pve_stream_center_x(float(y))
		for offset in range(3, 8):
			var left_cell := PveOpenWorldTopologyV1._nearest_walkable(
				nav, Vector2i(floori(stream_x) - offset, y))
			var right_cell := PveOpenWorldTopologyV1._nearest_walkable(
				nav, Vector2i(ceili(stream_x) + offset, y))
			if left_cell.x < 0 or right_cell.x < 0:
				continue
			if float(left_cell.x) >= stream_x - 2.0 or float(right_cell.x) <= stream_x + 2.0:
				continue
			var left := Vector2(left_cell) + Vector2(0.5, 0.5)
			var right := Vector2(right_cell) + Vector2(0.5, 0.5)
			if left.distance_to(right) > 8.0:
				continue
			var route: Array[Vector2i] = snapshot._world_path(left, right)
			if route.size() > 1 and snapshot._world_route_distance(left, route) > left.distance_to(right) + 2.0:
				return {"left": left, "right_cell": right_cell, "stream_x": stream_x}
	return {}

func _nearby_walkable_positions(nav: Dictionary, origin: Vector2i,
		minimum_x: float, limit: int) -> Array[Vector2]:
	var result: Array[Vector2] = []
	for radius in range(0, 7):
		for y in range(origin.y - radius, origin.y + radius + 1):
			for x in range(origin.x - radius, origin.x + radius + 1):
				if maxi(absi(x - origin.x), absi(y - origin.y)) != radius:
					continue
				var cell := Vector2i(x, y)
				if float(cell.x) <= minimum_x or not _nav_cell_allowed(nav, cell):
					continue
				var point := Vector2(cell) + Vector2(0.5, 0.5)
				var duplicate := false
				for existing in result:
					if existing.distance_to(point) < 0.9:
						duplicate = true
						break
				if duplicate:
					continue
				result.append(point)
				if result.size() == limit:
					return result
	return result

func _nearest_disciple(snapshot: MapBattleV2, from: Vector2) -> Vector2:
	var result := Vector2.ZERO
	var best := INF
	for raw_actor in snapshot.actors.values():
		var actor: Dictionary = raw_actor
		if str(actor.get("side", "")) != "disciple":
			continue
		var position: Vector2 = actor["position"]
		var distance := from.distance_to(position)
		if distance < best:
			best = distance
			result = position
	return result
