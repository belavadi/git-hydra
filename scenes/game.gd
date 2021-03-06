extends Node

var tmp_prefix = OS.get_user_data_dir() + "/tmp/"
var global_shell
var fake_editor

var dragged_object
var energy = 2

var _file = "user://savegame.json"
var state = {}

func _ready():
	global_shell = Shell.new()
	
	create_file_in_game_env(".gitconfig", helpers.read_file("res://scripts/gitconfig"))
	
	create_file_in_game_env("fake-editor", helpers.read_file("res://scripts/fake-editor"))
	fake_editor = tmp_prefix + "fake-editor"
	global_shell.run("chmod u+x '%s'" % fake_editor)
	
	load_state()
	
func _initial_state():
	return {"history": []}
	
func save_state():
	var savegame = File.new()
	
	savegame.open(_file, File.WRITE)
	savegame.store_line(to_json(state))
	savegame.close()
	
func load_state():
	var savegame = File.new()
	if not savegame.file_exists(_file):
		save_state()
	
	savegame.open(_file, File.READ)
	
	state = _initial_state()
	var new_state = parse_json(savegame.get_line())
	for key in new_state:
		state[key] = new_state[key]
	savegame.close()
	
# filename is relative to the tmp directory!
func create_file_in_game_env(filename, content):
	global_shell.cd(tmp_prefix)
	# Quoted HERE doc doesn't do any substitutions inside.
	global_shell.run("cat > '%s' <<'HEREHEREHERE'\n%s\nHEREHEREHERE" % [filename, content])
