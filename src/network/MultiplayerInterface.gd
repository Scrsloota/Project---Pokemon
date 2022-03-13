extends Node

var rtc_mp: WebRTCMultiplayer = WebRTCMultiplayer.new()
var ws_client: WebSocketClient = WebSocketClient.new()
var rtc_available: bool = false
var pinp_peer_connected: bool = false
var peer_disconnect_unexpectedly: bool = false
var unique_id: int
var buffer: Array = []
signal match_server_connected()
signal pinp_peer_connected()
signal new_var_recv()

func _ready():
	pass

func _init():
	ws_client.connect("data_received", self, "_ws_on_data_received")
	ws_client.connect("connection_established", self, "_ws_on_connected")
	ws_client.connect("connection_closed", self, "_ws_on_closed")
	ws_client.connect("connection_error", self, "_ws_on_closed")
	ws_client.connect("server_close_request", self, "_ws_close_request")
	
	rtc_mp.connect("peer_disconnected", self, "_on_peer_disconnected")
	rtc_mp.connect("peer_connected", self, "_on_peer_connected")
	
func _process(delta):
	var status: int = ws_client.get_connection_status()
	if status == WebSocketClient.CONNECTION_CONNECTING or status == WebSocketClient.CONNECTION_CONNECTED:
		ws_client.poll()
	
	status = rtc_mp.get_connection_status()
	if status == WebRTCMultiplayer.CONNECTION_CONNECTING or status == WebRTCMultiplayer.CONNECTION_CONNECTED:
		rtc_mp.poll()
		if rtc_mp.get_available_packet_count() > 0:
			var deserialized = parse_json(rtc_mp.get_packet().get_string_from_utf8())
			print("new var recv")
			buffer.append(deserialized)
			emit_signal("new_var_recv")
	
	if peer_disconnect_unexpectedly:
		if len(buffer) == 0:
			buffer.append(Utils.save_action(SurrenderAction.new()))
		emit_signal("new_var_recv")
		
# websocket part
func _ws_close():
	ws_client.disconnect_from_host()

func _ws_connect_to_url(url):
	_ws_close()
	print("connecting")
	ws_client.connect_to_url(url)
	
func _ws_close_request(code, reason):
	_ws_close()

func _ws_on_closed(was_clean = false):
	print("ws is now closed")

func _ws_on_connected(protocol = ""):
	emit_signal("match_server_connected")
	ws_client.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)

func _ws_on_data_received():
	var pkt_str: String = ws_client.get_peer(1).get_packet().get_string_from_utf8()
	if pinp_peer_connected:
		buffer.append(parse_json(pkt_str))
		emit_signal("new_var_recv")
		return
		
	var msg: PoolStringArray = pkt_str.split("\n", true, 1)
	var command_part: PoolStringArray = msg[0].split(" ")
	var command_type = command_part[0]
	if not command_part[1].is_valid_integer():
		return
	var id = int(command_part[1])
	match command_type:
		'init':
			rtc_mp.initialize(id, true)
			unique_id = id
		'peer':
			_webrtc_create_peer(id)
		'offer':
			var offer = msg[1]
			if rtc_mp.has_peer(id):
				rtc_mp.get_peer(id).connection.set_remote_description("offer", offer)
		'answer':
			var answer = msg[1]
			if rtc_mp.has_peer(id):
				rtc_mp.get_peer(id).connection.set_remote_description("answer", answer)
		'candidate':
			var args = msg[1].split("\n", false)
			if not args[1].is_valid_integer():
				return 
			var mid = args[0]
			var index = int(args[1])
			var sdp = args[2]
			if rtc_mp.has_peer(id):
				rtc_mp.get_peer(id).connection.add_ice_candidate(mid, index, sdp)
		'fallback':
			print("Fallback use ws instead")
			rtc_mp.close()
			rtc_available = false
			pinp_peer_connected = true
			emit_signal("pinp_peer_connected")
			

func _ws_send_args_command(type: String, id: int, args: Array) -> int:
	var res = ws_client.get_peer(1).put_packet(
		(("%s %d" % [type, id]) + "\n" + PoolStringArray(args).join('\n')).to_utf8()
	)
	return res

func _ws_send_command(type: String, id: int) -> int:
	var res = ws_client.get_peer(1).put_packet(
		("%s %d" % [type, id]).to_utf8()
	)
	return res

func start(url = "127.0.0.1:8000/pinp"):
	stop()
	_ws_connect_to_url(url)


func stop():
	rtc_mp.close()


func _webrtc_create_peer(id):
	var peer: WebRTCPeerConnection = WebRTCPeerConnection.new()
	peer.initialize({
		"iceServers": [ { "urls": ["stun:stun.l.google.com:19302"] } ]
	})
	peer.connect("session_description_created", self, "_offer_created", [id])
	peer.connect("ice_candidate_created", self, "_new_ice_candidate")
	rtc_mp.add_peer(peer, id)
	if id > rtc_mp.get_unique_id():
		$Timer.start(1)
		print("Timer start")
		peer.create_offer()
	return peer


func _new_ice_candidate(mid_name, index_name, sdp_name):
	_ws_send_args_command("candidate", rtc_mp.get_unique_id(), [mid_name, index_name, sdp_name])


func _offer_created(type, data, id):
	if not rtc_mp.has_peer(id):
		return
	rtc_mp.get_peer(id).connection.set_local_description(type, data)
	if type == "offer":
		_ws_send_args_command('offer', rtc_mp.get_unique_id(), [data])
	else:
		_ws_send_args_command('answer', rtc_mp.get_unique_id(), [data])

func put_var(v):
	var serialized = to_json(v).to_utf8()
	if rtc_available:
		rtc_mp.put_packet(serialized)
	else:
		ws_client.get_peer(1).put_packet(serialized)

func get_var():
	if len(buffer) > 0:
		yield(get_tree().create_timer(0), "timeout")
		return buffer.pop_front()
	else:
		yield(self, "new_var_recv")
		return buffer.pop_front()

func is_main_node():
	return unique_id == 1

func disconnected():
	stop() # Unexpected disconnect

func _on_peer_connected(id):
	_ws_close()
	rtc_available = true
	pinp_peer_connected = true
	emit_signal("pinp_peer_connected")

func _on_peer_disconnected(id):
	print("Peer disconnected")
	rtc_mp.close()
	peer_disconnect_unexpectedly = true
	buffer = [Utils.save_action(SurrenderAction.new())]
	emit_signal("new_var_recv")

func _on_Timer_timeout():
	print("Timeout")
	if not rtc_available:
		print("Fallback use ws instead")
		rtc_mp.close()
		_ws_send_command("fallback", 0)
		rtc_available = false
		pinp_peer_connected = true
		emit_signal("pinp_peer_connected")
