extends Node2D

export (PackedScene) var Card
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var dir = "res://cards/"

var ownId = 0
var ownName = "懒人"
var rightID = -1
var rightName = "error"
var leftID = -1
var leftName = "error"
var originCards = ["cj","bj","2s","2h","2c","2d","as","ah","ac","ad","ks","kh","kc","kd",
"qs","qh","qc","qd","js","jh","jc","jd","0s","0h","0c","0d","9s","9h","9c","9d",
"8s","8h","8c","8d","7s","7h","7c","7d","6s","6h","6c","6d","5s","5h","5c","5d",
"4s","4h","4c","4d","3s","3h","3c","3d"]
var ownCards = []
var dizuCards = []
var isDZ = false
var gameState = false
var currentID = -1
var firstID = -1
var dzID = -1
var lastWinner = -1
var lastPlayCards = []
# Called when the node enters the scene tree for the first time.
func _ready():
	var exes = OS.get_executable_path().split("\\")
	var size = exes.size()
	exes.remove(size-1)
	#dir = exes.join("/")+"/cards/"
	dir = "http://olmap.deadpoetspoon.xyz/cards/"
	print(dir)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
sync func set_last_winner(id):
	lastWinner = id
sync func set_head_image(id):
	var nm = ImageTexture.new()
	nm.load(dir+"nm.png")
	var dz = ImageTexture.new()
	dz.load(dir+"zbj.png")
	if id == ownId:
		$SelfHead.texture = dz
		$RightHead.texture = nm
		$LeftHead.texture = nm
	elif id == leftID:
		$SelfHead.texture = nm
		$RightHead.texture = nm
		$LeftHead.texture = dz
	elif id == rightID:
		$SelfHead.texture = nm
		$RightHead.texture = dz
		$LeftHead.texture = nm
sync func set_dz_ID(id):
	dzID = id
	if dzID == ownId:
		for card in dizuCards:
			ownCards.append(card)
		show_cards(ownCards)
		rpc("reflash_cardNum",ownId,ownCards.size())
sync func set_first_ID(id):
	firstID = id
sync func set_current_ID(id):
	currentID = id
	if id == ownId:
		$Button1.disabled = false
		$Button2.disabled = false
	else:
		$Button1.disabled = true
		$Button2.disabled = true
sync func set_game_state(state):
	gameState = state
	if not gameState:
		$Button1.text = "不叫"
		$Button2.text = "叫地主"
	else:
		$Button1.text = "撤回上家"
		$Button2.text = "过/出牌"
sync func show_other_player():
	print(leftName+"+"+rightName)
sync func _showName():
	print(str(ownId)+" : "+ownName)
sync func set_right_player(id,name):
	rightID = id
	rightName = name
sync func set_left_player(id,name):
	leftID = id
	leftName = name
sync func set_own_idname(id,name):
	ownId = id
	ownName = name
	rpc("flash_player_list")
sync func connect_to_server(name):
	var sender = get_tree().get_rpc_sender_id()
	rpc_id(sender,"set_own_idname", sender, name)
	if get_tree().is_network_server():
		if rightID != -1:
			rpc_id(1,"set_left_player",sender,name)
			rpc_id(sender,"set_right_player",1,ownName)
			rpc_id(sender,"set_left_player",rightID,rightName)
			rpc_id(rightID,"set_right_player",sender,name)
		else :
			rpc_id(1,"set_right_player",sender,name)
			rpc_id(sender,"set_left_player",1,ownName)
	rpc("flash_player_list")
sync func flash_player_list():
	$"../Players/List".clear()
	$"../Players/List".add_item(ownName + " (You)")
	if rightID != -1:
		$"../Players/List".add_item(rightName)
	if leftID != -1:
		$"../Players/List".add_item(leftName)
	$"../Players/Start".disabled = not get_tree().is_network_server()
# warning-ignore:unused_argument
func on_peer_add(id):
	rpc("flash_player_list")
sync func set_cards(cards):
	ownCards = cards
	show_cards(ownCards)
sync func set_dz_cards(cards):
	dizuCards = cards
	#show_dz_cards(dizuCards)
	hide_dz_cards()
sync func startGame():
	# 设置界面
	$"../Players".hide()
	$"../Game".show()
	$LeftName.text = leftName
	$RightName.text = rightName
	$OwnName.text = ownName
	if not get_tree().is_network_server():
		return
	split_cards()
	start_qdz()
#	for i in range(17):
#		var card = Card.instance()
#		$Cards.add_child(card)
#		card.position.x += i*35
#		card.set_texture("res://cards/4c.png")
sync func play_cards():
	var playCards = []
	for c in $Cards.get_children():
		if c.isSelect:
			playCards.append(c.name)
	if playCards.size() != 0:
		rpc("show_play_cards",playCards)
		lastPlayCards = playCards
		for cc in playCards:
			ownCards.erase(cc)
		if ownCards.size() != 0:
			rpc_id(currentID,"set_cards",ownCards)
		else:
			rpc("set_last_winner",currentID)
			rpc("restart_game")
	rpc("set_current_ID",rightID)
	rpc("reflash_cardNum",ownId,ownCards.size())
sync func reflash_cardNum(id,num):
	if id == leftID:
		$LeftCardNum.text = str(num)
	if id == rightID:
		$RightCardNum.text = str(num)
sync func fallback_play():
	for c in lastPlayCards:
		ownCards.append(c)
	rpc_id(ownId,"set_cards",ownCards)
sync func restart_game():
	var oldCards =  $PlayCards.get_children()
	for c in oldCards:
		$PlayCards.remove_child(c)
		c.queue_free()
	if not get_tree().is_network_server():
		return
	split_cards()
	start_qdz()
sync func show_play_cards(cards):
	#先清除
	var oldCards =  $PlayCards.get_children()
	for c in oldCards:
		$PlayCards.remove_child(c)
		c.queue_free()
	cards.sort_custom(cardSorter, "sort")
	var size = cards.size()
	var delt = - int(size / 2)*35
	for id in cards:
		var card = Card.instance()
		$PlayCards.add_child(card)
		card.position.x += delt
		card.position.y = 230
		delt += 35
		card.set_texture(dir+id+".png")
		card.name = id
sync func show_comment(fromname,msg):
	$CommentLabel.append_bbcode("[b]"+fromname+"[/b]: "+msg+"\n")
func start_qdz():
	rpc("set_game_state",false)
	#确定谁先
	if lastWinner != -1:
		rpc("set_current_ID",lastWinner)
		rpc("set_first_ID",lastWinner)
	else:
		var datetime = OS.get_datetime()
		var randNum = int(datetime["hour"])+int(datetime["minute"])+int(datetime["second"])
		var num = randNum % 3
		if num == 0:
			rpc("set_current_ID",ownId)
			rpc("set_first_ID",ownId)
		elif num == 1:
			rpc("set_current_ID",rightID)
			rpc("set_first_ID",rightID)
		elif num == 2:
			rpc("set_current_ID",leftID)
			rpc("set_first_ID",leftID)
func split_cards():
	var datetime = OS.get_datetime()
	var randNum = int(datetime["hour"])+int(datetime["minute"])+int(datetime["second"])
	for j in range(randNum):
		for i in range(originCards.size()):
			var currentRandom = randi() % 54
			var current = originCards[i]
			originCards[i] = originCards[currentRandom]
			originCards[currentRandom] = current
	rpc_id(1,"set_cards",originCards.slice(0,16))
	rpc_id(rightID,"set_cards",originCards.slice(17,33))
	rpc_id(leftID,"set_cards",originCards.slice(34,50))
	rpc("set_dz_cards",originCards.slice(51,53))
sync func show_dz_cards(cards):
	#先清除
	var oldCards =  $DZCards.get_children()
	for c in oldCards:
		$DZCards.remove_child(c)
		c.queue_free()
	var card = Card.instance()
	$DZCards.add_child(card)
	card.position.x = 451
	card.position.y = 80
	card.set_texture(dir+cards[0]+".png")
	card = Card.instance()
	$DZCards.add_child(card)
	card.position.x = 521
	card.position.y = 80
	card.set_texture(dir+cards[1]+".png")
	card = Card.instance()
	$DZCards.add_child(card)
	card.position.x = 591
	card.position.y = 80
	card.set_texture(dir+cards[2]+".png")
func hide_dz_cards():
	#先清除
	var oldCards =  $DZCards.get_children()
	for c in oldCards:
		$DZCards.remove_child(c)
		c.queue_free()
	var card = Card.instance()
	$DZCards.add_child(card)
	card.position.x = 451
	card.position.y = 80
	card.set_texture(dir+"cb.png")
	card = Card.instance()
	$DZCards.add_child(card)
	card.position.x = 521
	card.position.y = 80
	card.set_texture(dir+"cb.png")
	card = Card.instance()
	$DZCards.add_child(card)
	card.position.x = 591
	card.position.y = 80
	card.set_texture(dir+"cb.png")
func show_cards(cards):
	#先清除
	var oldCards =  $Cards.get_children()
	for c in oldCards:
		$Cards.remove_child(c)
		c.queue_free()
	cards.sort_custom(cardSorter, "sort")
	var size = cards.size()
	var delt = - int(size / 2)*35
	for id in cards:
		var card = Card.instance()
		$Cards.add_child(card)
		card.position.x += delt
		delt += 35
		card.set_texture(dir+id+".png")
		card.name = id
class cardSorter:
	static func sort(a, b):#返回true时吧在后,返回false吧b在前
		var originCards = ["cj","bj","2s","2h","2c","2d","as","ah","ac","ad","ks","kh","kc","kd",
"qs","qh","qc","qd","js","jh","jc","jd","0s","0h","0c","0d","9s","9h","9c","9d",
"8s","8h","8c","8d","7s","7h","7c","7d","6s","6h","6c","6d","5s","5h","5c","5d",
"4s","4h","4c","4d","3s","3h","3c","3d"]
		var aint = originCards.find(a)
		var bint = originCards.find(b)
		if aint < bint:
			return true
		else:
			return false


func _on_Button1_pressed():
	if not gameState:
		if rightID == firstID:
			rpc("restart_game")
		else :
			rpc("set_current_ID",rightID)
	else:
		rpc("set_current_ID",leftID)
		rpc_id(leftID,"fallback_play")
func _on_Button2_pressed():
	if not gameState:
		rpc("set_dz_ID",ownId)
		rpc("show_dz_cards",dizuCards)
		rpc("set_game_state",true)
	else:
		rpc_id(currentID,"play_cards")


func _on_SendButton_pressed():
	rpc("show_comment",ownName,$Message.text)
