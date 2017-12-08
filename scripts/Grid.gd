extends Node2D

export(int) var width = 20
export(int) var height = 18

var margin = 10

var screenWidth = ProjectSettings.get_setting("display/window/size/width")
var screenHeight = ProjectSettings.get_setting("display/window/size/height");

onready var tileTemplate = load("res://scenes/Tile.tscn")

var grid = []
var colorMap = []
func _ready():
	# This gives you an ImageTexture
	var image_texture_resource = preload("res://assets/Mario_8Bit.png")
	
	# This gives you an Image
	var image = image_texture_resource.get_data()
	#print(image)
	image.lock()
	# This gives you a pixel (check the doc)
	for y in range(0, image.get_size().y):
		for x in range(0, image.get_size().x):
			var c = image.get_pixel(x, y)
			#print("(%s,%s) %s" % [x, y, c])
			var t = tileTemplate.instance()
			var colorIndex
			if c.a == 1:
				colorIndex = find_color(c)
				if colorIndex == -1:
					colorMap.append(c)
					colorIndex = colorMap.size() - 1
					#print("adding color %s at index %s" % [c, colorIndex])
				if colorIndex == 1:
					pass
				c.a = 0
			else:
				colorIndex = -1
			t.init(colorIndex, c)
			var p = Vector2(x * 32 + 32 - x, y * 32 + 32 - y)
			t.position = p
			#print(t.toString())
			add_child(t)
	
	
func find_color(c):
	for i in range(0, colorMap.size()):
		if colorMap[i] == c:
			return i
	return -1

