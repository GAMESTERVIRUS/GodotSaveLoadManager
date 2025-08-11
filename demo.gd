extends Node2D

var save_dir := OS.get_executable_path().get_base_dir().path_join("Saves")
@export var file_name := "demo"
@export var ext := "save"

const passkey := "TemporaryKey"

@onready var gui = %GUI
@onready var save_dir_in = %SaveDir
@onready var save_dir_text = %SaveDirText
@onready var data_in = %Data
@onready var key_in = %Key
@onready var save_btn = %SaveBtn
@onready var load_btn = %LoadBtn
@onready var loaded_data_out = %LoadedDataOut

var data_dict := {}
var data_key := ""
var data_val := ""

func _ready():
	SaveHandler.set_file_path(save_dir, file_name, ext)

func flash_invalid_field(field: LineEdit):
	field.add_theme_color_override("font_color", Color.RED)
	field.add_theme_color_override("bg_color", Color(1, 0, 0, 0.2))
	await get_tree().create_timer(1).timeout
	field.remove_theme_color_override("font_color")
	field.remove_theme_color_override("bg_color")

#UI Calls
func _on_save_dir_text_submitted(new_text : String):
	if new_text.strip_edges() == "":
		return
	var regex := RegEx.new()
	regex.compile(r"^[A-Za-z]:[/\\][/\\]?")
	if not regex.search(new_text):
		new_text = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).path_join(new_text)
	if DirAccess.dir_exists_absolute(new_text):
		SaveHandler.set_file_dir(new_text)
		return
	
	if DirAccess.make_dir_recursive_absolute(new_text) == OK:
		SaveHandler.set_file_dir(new_text)
		return
	
	flash_invalid_field(save_dir_in)


func _on_data_text_submitted(new_text):
	data_key = new_text

func _on_key_text_submitted(new_text):
	data_val = new_text

func _on_save_btn_pressed():
	data_dict.set(data_key, data_val)
	SaveHandler.save_data(data_dict, passkey)

func _on_load_btn_pressed():
	loaded_data_out.text = str(SaveHandler.get_data(data_key, null, passkey)[1])
