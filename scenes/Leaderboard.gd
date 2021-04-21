extends Node2D


onready var game_manager = get_node("..")
var press_any_key: bool = false
var pb_rewritten: bool = false
var dec_nb: int = 1000


func _ready():
	$Panel.visible = false
	$Scores.visible = false
	$Panel/Label.text = ""
	if int(Global.latest_score_position) == 1:
		$Panel/Label.text = "New World record!"
		Global.personal_best = Global.latest_arcade_score
		Global.save_game()
		display_scores(Global.latest_score_position)
		$Panel.visible = true
		$Panel/LineEdit.grab_focus()
	elif Global.latest_arcade_score > Global.personal_best:
		$Panel/Label.text = "New personal record!"
		Global.personal_best = Global.latest_arcade_score
		Global.save_game()
		display_scores(Global.latest_score_position)
		$Panel.visible = true
		$Panel/LineEdit.grab_focus()
	else:
		display_scores(Global.latest_score_position)
		press_any_key = true


func _input(event):
	if Input.is_key_pressed(KEY_ENTER) and $Panel.visible and $Panel/LineEdit.text.length() > 0:
		save_score_with_pseudo()
	if (event is InputEventKey or event is InputEventMouseButton) and press_any_key:
		Global.player_in_game = true
		game_manager.load_scene(game_manager.level)


func _on_Button_pressed():
	if $Panel/LineEdit.text.length() > 0:
		save_score_with_pseudo()


func save_score_with_pseudo():
	$Panel.visible = false
	var score_id = yield(SilentWolf.Scores.persist_score($Panel/LineEdit.text, Global.latest_arcade_score), "sw_score_posted")
	print("Score persisted successfully: " + str(score_id))
	press_any_key = true


func display_scores(score_position):
	if Global.personal_best_position == 1:
		$Scores/VBoxContainer/padding1.queue_free()
		$Scores/VBoxContainer/WRBox.queue_free()
	else:
		$Scores/VBoxContainer/WRBox/Label.text = "     1. " + str(Global.wr_score[0].player_name)
		$Scores/VBoxContainer/WRBox/WR.text = str("%.3f" % (Global.wr_score[0].score / dec_nb)) + " km"
	
	if Global.personal_best_position == 2:
		$Scores/VBoxContainer/padding1.queue_free()
	
	$Scores.visible = true
	$Scores/VBoxContainer/CurrentBox/Label.text = str("%6d" % score_position) + ". (current score)"
	$Scores/VBoxContainer/CurrentBox/Current.text = str("%.3f" % (Global.latest_arcade_score / dec_nb)) + " km"
	
	$Scores/VBoxContainer/PBBox/Label.text = str("%6d" % Global.personal_best_position) + ". (personal best)"
	$Scores/VBoxContainer/PBBox/PB.text = str("%.3f" % (Global.personal_best / dec_nb)) + " km"
	if Global.personal_best == Global.latest_arcade_score:
		$Scores/VBoxContainer/PBBox.queue_free()
		$Scores/VBoxContainer/padding2.queue_free()
	
	if SilentWolf.Scores.scores_above.size() > 0:
		$Scores/VBoxContainer/P2Box/Label.text = str("%6d" % Global.latest_score_above_and_below.scores_above[0].position) + ". " + str(Global.latest_score_above_and_below.scores_above[0].player_name)
		$Scores/VBoxContainer/P2Box/P2.text = str("%.3f" % (Global.latest_score_above_and_below.scores_above[0].score / dec_nb)) + " km"
		if Global.latest_score_above_and_below.scores_above[0].position == 1:
			$Scores/VBoxContainer/padding1.queue_free()
			$Scores/VBoxContainer/WRBox.queue_free()
		if SilentWolf.Scores.scores_above.size() > 1:
			$Scores/VBoxContainer/P1Box/Label.text = str("%6d" % Global.latest_score_above_and_below.scores_above[1].position) + ". " + str(Global.latest_score_above_and_below.scores_above[1].player_name)
			$Scores/VBoxContainer/P1Box/P1.text = str("%.3f" % (Global.latest_score_above_and_below.scores_above[1].score / dec_nb)) + " km"
			if Global.latest_score_above_and_below.scores_above[1].position == 1:
				$Scores/VBoxContainer/padding1.queue_free()
				$Scores/VBoxContainer/WRBox.queue_free()
		else:
			$Scores/VBoxContainer/P1Box.queue_free()
		print_pb_if_equal($Scores/VBoxContainer/P2Box/P2)
		print_pb_if_equal($Scores/VBoxContainer/P1Box/P1)
	else: # New World Record
		$Scores/VBoxContainer/P2Box.queue_free()
		$Scores/VBoxContainer/P1Box.queue_free()
		$Scores/VBoxContainer/M2Box.queue_free()
		$Scores/VBoxContainer/M1Box.queue_free()
		$Scores/VBoxContainer/WRBox.queue_free()
		$Scores/VBoxContainer/PBBox.queue_free()
		$Scores/VBoxContainer/padding1.queue_free()
		$Scores/VBoxContainer/padding2.queue_free()
		
	
	if SilentWolf.Scores.scores_below.size() > 0:
		$Scores/VBoxContainer/M1Box/Label.text = str("%6d" % SilentWolf.Scores.scores_below[0].position) + ". " + str(Global.latest_score_above_and_below.scores_below[0].player_name)
		$Scores/VBoxContainer/M1Box/M1.text = str("%.3f" % (Global.latest_score_above_and_below.scores_below[0].score / dec_nb)) + " km"
		if SilentWolf.Scores.scores_below.size() > 1:
			$Scores/VBoxContainer/M2Box/Label.text = str("%6d" % Global.latest_score_above_and_below.scores_below[1].position) + ". " + str(Global.latest_score_above_and_below.scores_below[1].player_name)
			$Scores/VBoxContainer/M2Box/M2.text = str("%.3f" % (Global.latest_score_above_and_below.scores_below[1].score / dec_nb)) + " km"
		else:
			print_pb_if_equal($Scores/VBoxContainer/M1Box/M1)
			print_pb_if_equal($Scores/VBoxContainer/M2Box/M2)
			$Scores/VBoxContainer/M2Box.queue_free()
	else:
		$Scores/VBoxContainer/M2Box.queue_free()
		$Scores/VBoxContainer/M1Box.queue_free()
	
	if $Scores/VBoxContainer.has_node("P2Box"):
		if int($Scores/VBoxContainer/P2Box/Label.text.left(6)) == 2:
			if $Scores/VBoxContainer.has_node("padding1"):
				$Scores/VBoxContainer/padding1.queue_free()
			if $Scores/VBoxContainer.has_node("padding2"):
				$Scores/VBoxContainer/padding2.queue_free()
	if $Scores/VBoxContainer.has_node("P1Box"):
		if int($Scores/VBoxContainer/P1Box/Label.text.left(6)) == 2:
			if $Scores/VBoxContainer.has_node("padding1"):
				$Scores/VBoxContainer/padding1.queue_free()
			if $Scores/VBoxContainer.has_node("padding2"):
				$Scores/VBoxContainer/padding2.queue_free()

func print_pb_if_equal(box_to_compare):
	if $Scores/VBoxContainer/PBBox/PB.text == box_to_compare.text and not pb_rewritten:
		pb_rewritten = true
		box_to_compare.get_node("../Label").text = box_to_compare.get_node("../Label").text.left(8) + "(personal best)"
		box_to_compare.text = $Scores/VBoxContainer/PBBox/PB.text
		box_to_compare.get_node("..").modulate = Color(0, 0.87, 1, 1)
		$Scores/VBoxContainer/PBBox.queue_free()
		$Scores/VBoxContainer/padding2.queue_free()
