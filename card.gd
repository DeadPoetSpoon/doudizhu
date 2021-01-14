extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var upDis = 20
var isSelect = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func set_texture(texturePath):
	var stream = ImageTexture.new()
	stream.load(texturePath)
	$png.texture = stream
func _on_Card_mouse_entered():
	#print("in")
	if !isSelect:
		position.y -= upDis


func _on_Card_mouse_exited():
	if !isSelect:
		position.y += upDis


func _on_Card_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("mouse_pressed"):
		isSelect = !isSelect
