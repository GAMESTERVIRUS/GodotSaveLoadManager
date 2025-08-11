# GodotSaveLoadManager

A lightweight, easy-to-use save and load manager plugin for Godot Engine.  
Simplifies saving game data securely with encryption support and flexible file handling.

## Features

- Save and load game data with a simple API  
- Supports custom save directories and filenames  
- Optional encryption to protect save files  
- Handles different file formats (JSON, binary, etc.)  
- Cross-platform compatible (Windows, Linux, macOS)  
- Easy integration with any Godot project   

## Installation

Just download SaveLoadData.gd
or download this repo and import as an godot project for demo for more usage clarification

## Usage

add SaveLoadData.gd as an autoload

## Functions

Below are the main API functions with usage details.

Setters:
```gdscript
func set_file_path(dir: String, fname: String, ext: String) -> Array:
	# Usage: Initialize or update save directory, filename, and extension all at once.
	# Params:
	#   dir (String) - directory path, e.g. "user://Saves"
	#   fname (String) - filename without extension, e.g. "save1"
	#   ext (String) - file extension, e.g. "save"
	# Returns: [error_code: int, full_file_path: String]
	#   OK on success, and the combined path "dir/fname.ext"

func set_file_dir(dir: String) -> String:
	# Usage: Initialize or update just the save directory path.
	# Params:
	#   dir (String) - directory path, e.g. "user://NewSaves"
	# Returns: Updated directory path string

func set_file_name(fname: String) -> String:
	# Usage: Initialize or update just the save file name (without extension).
	# Params:
	#   fname (String) - file name, e.g. "save2"
	# Returns: Updated file name string

func set_file_extension(ext: String) -> String:
	# Usage: Initialize or update just the save file extension.
	# Params:
	#   ext (String) - file extension, e.g. "dat"
	# Returns: Updated file extension string
```

Getters:
```gdscript
func get_file_path() -> String:
	# Usage: Get full save file path including directory, filename, and extension.
	# Returns: Full file path string, e.g. "user://Saves/game.save"

func get_file_name() -> String:
	# Usage: Get the save filename with extension only (no directory).
	# Returns: Filename string with extension, e.g. "game.save"
```

File and Directory creation:
```gdscript
func create_save_dir() -> Error:
	# Usage: Creates the save directory if it does not exist.
	# Returns:
	#   OK if directory created or already exists,
	#   ERR_ALREADY_EXISTS if directory already exists,
	#   Other error code if creation failed.

func create_new_save(key: String = "") -> Error:
	# Usage: Creates a new save file if one does not exist; creates save directory if necessary.
	# Params:
	#   key (String, optional) - encryption key for encrypted save files
	# Returns:
	#   OK if save file created,
	#   ERR_ALREADY_EXISTS if file exists,
	#   Other error code on failure.
```

Save Functions:
```gdscript
func save_data(data: Variant, key: String = "") -> Error:
	# Usage: Saves given data (any Variant) to the save file, optionally encrypted.
	# Params:
	#   data (Variant) - data to save (Dictionary, Array, etc.)
	#   key (String, optional) - encryption key
	# Returns:
	#   OK on success,
	#   error code on failure

func update_val(data_key: String, value, key: String = "") -> Error:
	# Usage: Updates a specific key-value pair in the saved data.
	# Params:
	#   data_key (String) - key in saved Dictionary to update
	#   value (Variant) - new value to assign
	#   key (String, optional) - encryption key
	# Returns:
	#   OK on success,
	#   error if key does not exist or operation failed
```

Load Functions:
```gdscript
func load_data(key: String = "") -> Array:
	# Usage: Loads saved data from file, optionally decrypting.
	# Params:
	#   key (String, optional) - encryption key
	# Returns:
	#   [error_code: int, data: Variant]
	#   OK and data on success; error and null on failure

func get_all(key: String = "") -> Array:
	# Usage: Returns all loaded data as Dictionary or empty Dictionary on failure.
	# Params:
	#   key (String, optional) - encryption key
	# Returns:
	#   [error_code: int, Dictionary]
	#   Loaded data or empty dictionary if failed.

func get_data(key_name: String, default = null, key: String = "") -> Array:
	# Usage: Gets a specific value from saved data by key name, or default if missing.
	# Params:
	#   key_name (String) - key to retrieve from saved data
	#   default (Variant) - value to return if key missing
	#   key (String, optional) - encryption key
	# Returns:
	#   [error_code: int, value]
	#   OK and value or error and empty dictionary
```

Helper Functions:
```gdscript
func open_save_file(mode: FileAccess.ModeFlags, key: String = "") -> FileAccess:
	# Usage: Opens the save file in the specified mode, optionally decrypting with key.
	# Params:
	#   mode (FileAccess.ModeFlags) - file access mode (READ, WRITE, etc.)
	#   key (String, optional) - encryption key for encrypted files
	# Returns: Opened FileAccess object on success, or null on failure
```
