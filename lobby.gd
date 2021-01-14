extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const DEF_PORT = 10567
const PROTO_NAME = "ludus"

var playerNames = []

# Called when the node enters the scene tree for the first time.
func _ready():
	# Called every time the node is added to the scene.
	get_tree().connect("network_peer_disconnected", self, "_peer_disconnected")
	get_tree().connect("network_peer_connected", self, "_peer_connected")
	# Set the player name according to the system username. Fallback to the path.
	if OS.has_environment("USERNAME"):
		$Connect/Name.text = OS.get_environment("USERNAME")
	else:
		var desktop_path = OS.get_system_dir(0).replace("\\", "/").split("/")
		$Connect/Name.text = desktop_path[desktop_path.size() - 2]


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func start_game():
	$Connect.hide()
	$Game.show()
	$Game.start()

func stop_game():
	pass

func _close_network():
	if get_tree().is_connected("server_disconnected", self, "_close_network"):
		get_tree().disconnect("server_disconnected", self, "_close_network")
	if get_tree().is_connected("connection_failed", self, "_close_network"):
		get_tree().disconnect("connection_failed", self, "_close_network")
	if get_tree().is_connected("connected_to_server", self, "_connected"):
		get_tree().disconnect("connected_to_server", self, "_connected")
	stop_game()
	get_tree().set_network_peer(null)


func _connected():
	$Game.rpc("connect_to_server",$Connect/Name.text)

func _peer_connected(id):
	$Game.on_peer_add(id)


func _peer_disconnected(id):
	pass

func _on_Start_pressed():
	$Game.rpc("show_other_player")
	$Game.rpc("startGame")

func _on_Host_pressed():
	if $Connect/Name.text == "":
		$Connect/ErrorLabel.text = "Invalid name!"
		return

	$Connect.hide()
	$Players.show()
	$Connect/ErrorLabel.text = ""
	
	var host = WebSocketServer.new()
	host.listen(DEF_PORT, PoolStringArray(["ludus"]), true)
	get_tree().connect("server_disconnected", self, "_close_network")
	get_tree().set_network_peer(host)
	
	$Game.rpc("set_own_idname",1,$Connect/Name.text)
	

func _on_Join_pressed():
	if $Connect/Name.text == "":
		$Connect/ErrorLabel.text = "Invalid name!"
		return
	var ip = $Connect/IPAddress.text
	if not ip.is_valid_ip_address():
		$Connect/ErrorLabel.text = "Invalid IP address!"
		return
	$Connect.hide()
	$Players.show()
	$Connect/ErrorLabel.text = ""
	$Connect/Host.disabled = true
	$Connect/Join.disabled = true
	
	var host = WebSocketClient.new()
	host.connect_to_url("ws://" + $Connect/IPAddress.text + ":" + str(DEF_PORT), PoolStringArray([PROTO_NAME]), true)
	get_tree().connect("connection_failed", self, "_close_network")
	get_tree().connect("connected_to_server", self, "_connected")
	get_tree().set_network_peer(host)
	
