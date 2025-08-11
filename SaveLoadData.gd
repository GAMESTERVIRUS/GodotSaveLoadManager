extends Node

#Default File Settings
const USER_DIR := "user://" # default data directory
const DEF_SAVE_DIR :=  USER_DIR + "Saves/"
const DEF_FILE_NAME := "game"
const DEF_EXTENSION := "save"

#Variable File Settings
var save_dir := DEF_SAVE_DIR
var file_name := DEF_FILE_NAME
var extension := DEF_EXTENSION

const max_tries := 3

func _ready():
	randomize()

#Initializing funcs
func set_file_path(dir : String, fname : String, ext : String) -> Array:
	save_dir = dir.rstrip("/")
	file_name = fname
	extension = ext
	return [OK, get_file_path()] # [error, text]

func set_file_dir(dir : String) -> String:
	save_dir = dir
	return save_dir

func set_file_name(fname : String) -> String:
	file_name = fname
	return file_name

func set_file_extension(ext : String) -> String:
	extension = ext
	return extension

#Getter funcs
func get_file_path() -> String:
	return save_dir.path_join(file_name + "." + extension)

func get_file_name() -> String:
	return file_name + "." + extension

#Creation funcs
func create_save_dir() -> Error:
	print("Creating save directory at ", save_dir)
	
	if DirAccess.dir_exists_absolute(save_dir):
		print("Directory already exists!...\nContinuing to create new save file!")
		return ERR_ALREADY_EXISTS
	
	for i in range(max_tries):
		var err := DirAccess.make_dir_recursive_absolute(save_dir)
		
		if err == OK:
			print("Save directory created at %s on %s" % [save_dir, Time.get_datetime_string_from_system(false, true)])
			return OK
		
		printerr("There was a problem creating save directory at %s: %s (%d)" % [save_dir, error_string(err), err])
		print("Retrying Directory Creation...")
	
	printerr("Couldn't create save directory : Directory creation tries exceeded!")
	return FileAccess.get_open_error()

func create_new_save(key : String = "") -> Error:
	var path := get_file_path()
	if FileAccess.file_exists(path):
		print("Save file %s already exists cannot create new!" % path)
		return ERR_ALREADY_EXISTS
	print("Creating save file in %s" % (save_dir))
	if not DirAccess.dir_exists_absolute(save_dir):
		print("Save directory doesn't exist!\nCreating one...")
		var err := create_save_dir()
		if err != OK and err != ERR_ALREADY_EXISTS:
			printerr("Couldn't create a save file as save directory doesn't exist!\nMake sure directory %s exist or create one!" % [save_dir])
			return err
	
	for i in range(max_tries):
		var save_file := open_save_file(FileAccess.WRITE, key)
		if save_file:
			print("Save file created at %s on %s" % [path, Time.get_datetime_string_from_system(false, true)])
			save_file.close()
			return OK
		
		var err_code := FileAccess.get_open_error()
		printerr("Can't create save file at %s: %s (%d)" % [save_dir, error_string(err_code), err_code])
		print("Retrying save file creation...")
	
	printerr("Save creation tries exceeded limit! Couldn't create save file anymore!")
	return FileAccess.get_open_error()

#Shared funcs
func open_save_file(mode : FileAccess.ModeFlags, key : String = "") -> FileAccess:
	var path := get_file_path()
	for i in range(max_tries):
		var file := FileAccess.open(path, mode) if key == "" else FileAccess.open_encrypted_with_pass(path, mode, key)
		if file:
			return file
		
		printerr("Error opening save file: %s (%d)" % [error_string(FileAccess.get_open_error()), FileAccess.get_open_error()])
		print("Retrying...")
	
	printerr("Error opening save file: File opening tries exceeded!")
	return null

#Save funcs
func save_data(data : Variant, key : String = "") -> Error:
	var save_file := open_save_file(FileAccess.WRITE, key)
	if not save_file:
		if FileAccess.get_open_error() == ERR_FILE_NOT_FOUND:
			create_new_save(key)
			save_file = open_save_file(FileAccess.WRITE, key)
		else : return FileAccess.get_open_error()
	save_file.store_var(data)
	save_file.close()
	print("Game saved at %s" % get_file_path())
	return OK

func update_val(data_key : String, value, key : String = "") -> Error:
	var save_file := open_save_file(FileAccess.READ_WRITE, key)
	if not save_file:
		var err := FileAccess.get_open_error()
		printerr("Can't update %s with value %s in %s: %s (%d)" % [data_key, str(value), get_file_name(), error_string(err), err])
		return err
	
	var file_data = save_file.get_var()
	var data = file_data.get(data_key)
	if data == null:
		printerr("Can't update %s with value %s in %s: Does not exist (33)" % [data_key, str(value), get_file_name()])
		return ERR_DOES_NOT_EXIST
	
	file_data[data_key] = value
	save_file.seek(0)
	save_file.store_var(file_data)
	save_file.flush()
	save_file.close()
	print("Changed ", data_key, " From ", data, " To ", file_data[data_key])
	return OK

#Load funcs
func load_data(key : String = "") -> Array: # [Error, Variant]
	var save_file := open_save_file(FileAccess.READ, key)
	if not save_file:
		return [FileAccess.get_open_error(), null]
	
	var data = save_file.get_var()
	save_file.close()
	return [OK, data]

func get_all(key : String = "") -> Array:
	var load_arr := load_data(key)
	var err = load_arr[0]
	var data = load_arr[1]
	
	if err != OK or not data:
		printerr("Can't load data: %s (%d)" % [error_string(err), err])
		return [err, {}]
	
	return [OK, data]

func get_data(key_name : String, default = null, key : String = "") -> Array:
	var load_arr = load_data(key)
	var err = load_arr[0]
	var loaded_data = load_arr[1]
	
	if err != OK:
		printerr("Can't load data: %s (%d)" % [error_string(err), err])
		return [err, {}]
	elif not loaded_data:
		printerr("Can't load data: couldn't find %s in %s or save file is corrupted!" % [key_name, get_file_path()])
		return[ERR_CANT_ACQUIRE_RESOURCE, {}]
	
	return [OK, loaded_data.get(key_name, default)]

#stock
func generate_random_string(length: int) -> String:
	var chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var result = []
	result.resize(length)
	var char_count = chars.length()
	for i in length:
		result[i] = chars[randi() % char_count]
	return "".join(result)
