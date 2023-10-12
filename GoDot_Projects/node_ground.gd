extends Node3D

const Player = preload("res://player.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()


func host():
	if Input.is_action_just_pressed("host"):
		enet_peer.create_server(PORT)
		multiplayer.multiplayer_peer = enet_peer
		multiplayer.peer_connected.connect(add_player)
		
		add_player(multiplayer.get_unique_id())
	
func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)
	
func join():
	if Input.is_action_just_pressed("join"):
		enet_peer.create_client("localhost", PORT)
		multiplayer.multiplayer_peer = enet_peer

func _process(delta):
	host()
	join()
