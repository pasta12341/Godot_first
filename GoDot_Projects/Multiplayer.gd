extends Node3D

var peer = 	ENetMultiplayerPeer.new()
@export var player_scene: PackedScene

var host_already_made = false
var join_already_made = false

var enet_peer = ENetMultiplayerPeer.new()

func host():
	if Input.is_action_just_pressed("host") and host_already_made == false:
		peer.create_server(135)
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_add_player)
		_add_player(multiplayer.get_unique_id())
		host_already_made = true
	
func _add_player(peer_id):
	var player = player_scene.instantiate()
	player.name = str(peer_id)
	add_child(player)
	print(player.name)
	
func join():
	if Input.is_action_just_pressed("join") and join_already_made == false:
		peer.create_client("localhost", 135)
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_add_player)
		_add_player(multiplayer.get_unique_id())
		join_already_made = true

func _process(delta):
	host()
	join()
