extends Node2D



enum STATES { INIT, VALID, INVALID }
 
var color_index = 0
var color = Color(222,0,0,0)
var state = INIT

func _ready():
	if color_index >= 0:
		$Label.text = String(color_index)
	else:
		$Label.text = ""
		$Outline.hide()
	$Fill.color = color

func init(colorIdx, c):
	state = INIT
	color_index = colorIdx
	color = c
	
func _input(event):
	if event is InputEventMouseButton && !event.pressed:
		var rect = Rect2(position - $Outline.texture.get_size() / 2, $Outline.texture.get_size())
		if rect.has_point(event.position) && color_index >= 0:
			toggle()

func toggle():
	match state:
		INIT:
			$Label.text = ""
			color.a = 1.0
			$Fill.color = color
			state = VALID
		VALID:
			$Label.text = String(color_index)
			color.a = 0
			$Fill.color.a = 0
			state = INIT

func toString():
	print("position=%s color_index=%s color=%s state=%s" % [position, color_index, color, state])

