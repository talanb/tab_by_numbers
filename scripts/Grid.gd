extends Node2D

enum States { INIT, VALID, INVALID }

# Tile class
class Tile:
	var width = 32
	var height = width
	
	var rect setget ,get_rect
	var size = Vector2(width, height)
	var position = Vector2()
	var color_index = -1
	var color = Color(0, 0, 0, 0)
	var state = INIT
	
	func get_rect():
		if not rect:
			rect = Rect2(position, size)
		return rect
		
	func to_string():
		return "pos: %s color_index=%s state=%s color=%s" % [position, color_index, state, color]

const margin = Vector2(32, 32)

var screen_width = ProjectSettings.get_setting("display/window/size/width")
var screen_height = ProjectSettings.get_setting("display/window/size/height");

var variant = "overlap"

var grid = []
var color_map = []
var font
var image

# Initialize the node
func _ready():
	font = $Label.get_font("font")
	image = preload("res://assets/32x32.png").get_data()
	print(image)
	image.lock()
	_build_grid()
	
func _build_grid():
	grid.clear()
	for x in range(0, image.get_size().x):
		grid.append([])
		for y in range(0, image.get_size().y):
			var pixel_color = image.get_pixel(x, y)
			var tile = Tile.new()
			tile.color_index = _get_color_index(pixel_color)
			print(pixel_color)
			tile.color = pixel_color
			var x_additional = 0
			var y_additional = 0
			if variant == "side_by_side":
				x_additional = x 
				y_additional = y 
			tile.position = Vector2(x * tile.size.x + x_additional, y * tile.size.y + y_additional)
			grid[x].append(tile)

# Process an event
func _input(event):
	if event is InputEventMouseButton && !event.pressed:
		var tile = _find_tile_with_point(event.position)
		print(tile.to_string())	
#		event.position -= margin
#		var grid_position = Vector2(floor(event.position.x / 32), floor(event.position.y / 32))
#		#print(event.position, grid_position)
#		var tile = grid[grid_position.x][grid_position.y]
		tile.state = VALID
		update()

# Draw the grid
func _draw():
	if grid.size() == 0:
		return
	for x in range(0, grid.size()):
		for y in range(0, grid[0].size()):
			var tile = grid[x][y]
			var rect = Rect2(tile.position + margin, tile.size)
			match tile.state:
				INIT:
					draw_rect(rect, Color(0, 0, 0, 1.0), false)
					_draw_color_index(tile)
				VALID:
					draw_rect(rect, tile.color, true)

func _find_tile_with_point(pos):
	for x in range(0, grid.size()):
		for y in range(0, grid[x].size()):
			var tile = grid[x][y]
			if tile.rect.has_point(pos):
				return tile
	return null

# Draw the color index at the center of the tile
func _draw_color_index(tile):
	if (tile.color_index == -1):
		return
	var string_size = font.get_string_size(String(tile.color_index))
	draw_string(font, _get_centered_draw_pos(String(tile.color_index), Rect2(tile.position, Vector2(32, 32))), String(tile.color_index), Color(0, 0, 0, 1))

# Find the position for drawing so that _text_ is centered (horizontally and vertically) withing _bounds)
func _get_centered_draw_pos(text, bounds):
	var string_size = font.get_string_size(text)
	return Vector2(bounds.position.x + (bounds.size.x / 2 - string_size.x / 2) + margin.x, bounds.position.y + (bounds.size.y / 2 + string_size.y / 2) + margin.y)

# Given a color, if the color is already in the color_map, return the index where the color resides.
# Otherwise, add the color to color_map ahd return the index
func _get_color_index(pixel_color):
	var color_index
	if pixel_color.a == 1:
		color_index = _find_color(pixel_color)
		if color_index == -1:
			color_map.append(pixel_color)
			color_index = color_map.size() - 1
	else:
		color_index = -1
	return color_index

# Iterate through color_map looking for _color_. Return the index, if found, otherwise return -1
func _find_color(c):
	for i in range(0, color_map.size()):
		if color_map[i] == c:
			return i
	return -1

func _on_SideBySide_toggled(pressed):
	if pressed:
		variant = "side_by_side"
	else:
		variant = "overlap"
	_build_grid()
	update()
