extends Control

signal done

const VOICE_VOLUME_MULTIPLIER = 10
const CONFIG_NAME = "user://settings.cfg"
const DEFAULT_LANG = "en-US"
const AUDIO_BUS_NAME = "Master"

@export var voice_volume=5
@export var voice = 0
@export var rate=1
@export var pitch=1
@export var sound_volume = 5

var lang_id = 0
var default_lang_id = 0
var voices = []

#used to indicate vocie aren't loaded yet
var starting = true

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Sound settings ready")
	#set up UI
	setup_voice_options()
	
	#load user preferences
	load_user_preferences()	
	
	#set scroll locations
	update_settings(false)
	
	starting = false
	
	if self.is_visible():
		$Menu/Instructions.grab_focus()
		speak_text($Menu/Instructions.get_text())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
#func _input(event: InputEvent) -> void:
#	print("input")

func setup_voice_options() -> void:
		#fill in voice values
	voices = DisplayServer.tts_get_voices()
	
	#determine unique languages and fill in the option button with them
	if voices:
		#fill options with current language voices
		var languages = []
		for v in voices:
			if languages.count(v.language) == 0:
				languages.append(v.language)
				$Menu/GridContainer/VoiceLanguageOptions.add_item(v.language)
				if v.language == DEFAULT_LANG:
					lang_id = languages.size() - 1
					default_lang_id = lang_id
					
		$Menu/GridContainer/VoiceLanguageOptions.select(lang_id)		
		fill_voice_list()
	else: 
		#create an empty voice 
		var empty_voice = {}
		empty_voice.id = ""
		empty_voice.language = "None" 
		empty_voice.name = "None"
		voices = []
		voices.append(empty_voice)
		voice = 0

func fill_voice_list(reset = true) -> void:		
	$Menu/GridContainer/VoiceOptions.clear()
	#lang_id = $Menu/GridContainer/VoiceLanguageOptions.get_selected_id()
	var current_lang = $Menu/GridContainer/VoiceLanguageOptions.get_item_text(lang_id)

	for i in range(voices.size()):
		var v = voices[i]
		if v.language == current_lang:
			if reset:
				voice = i
				reset = false
			$Menu/GridContainer/VoiceOptions.add_item(v.name, i)
		#$Menu/GridContainer/VoiceOptions.add_item(v.name + " (" + v.language + ")", i)
		

func load_user_preferences() -> void:
	var config = ConfigFile.new()
	
	var err = config.load(CONFIG_NAME)
	if err == OK:
		voice = config.get_value("Voice", "voice_number")	
		lang_id = config.get_value("Voice", "lang_id")	
		if not voices or voice >= voices.size():
			voice = 0
			
		voice_volume = config.get_value("Voice", "voice_volume")	
		rate = config.get_value("Voice", "voice_rate")	
		pitch = config.get_value("Voice", "voice_pitch")	
		sound_volume = config.get_value("Sound", "sound_volume")	
		
		
	else:	
		print("Failed to load configuration: " + CONFIG_NAME)
		
	#print("voice: %s (%s) voice number: %d, Option index: %d"% [voices[voice].name, voices[voice].language,voice])
	store_settings_in_global_object()
	set_sound_volume(sound_volume)
	
func save_user_preferences() -> void:
	var config = ConfigFile.new()
	
	config.set_value("Voice", "voice_number", voice);
	config.set_value("Voice", "lang_id", lang_id);
	config.set_value("Voice", "voice_volume", voice_volume);
	config.set_value("Voice", "voice_rate", rate);
	config.set_value("Voice", "voice_pitch", pitch);
	config.set_value("Sound", "sound_volume", sound_volume);
	
	config.save(CONFIG_NAME)

func restore_default_settings() -> void:
	voice_volume=5
	voice = 0
	rate=1
	pitch=1
	sound_volume = 5
	lang_id = default_lang_id
	set_sound_volume(sound_volume)
	update_settings()

func update_settings(reset = true) -> void:
	
	#not so easy: 
	fill_voice_list(reset)
	var v_idx = $Menu/GridContainer/VoiceOptions.get_item_index(voice)
	$Menu/GridContainer/VoiceOptions.select(v_idx)
	$Menu/GridContainer/VoiceLanguageOptions.select(lang_id)
	$Menu/GridContainer/VoiceVolumeSlider.set_value(voice_volume)
	$Menu/GridContainer/RateSlider.set_value(rate)
	$Menu/GridContainer/PitchSlider.set_value(pitch)
	$Menu/GridContainer/SoundSlider.set_value(sound_volume)
	


func speak_text(text="Hello there."):
	if !starting : # and !DisplayServer.tts_is_speaking():
		DisplayServer.tts_stop()
		var voice_str = ""
		if voices:
			voice_str = voices[voice].id
			
		DisplayServer.tts_speak(text, voice_str, 
			VOICE_VOLUME_MULTIPLIER*voice_volume, pitch, rate)

func set_sound_volume(vol):
	#non-linear range of values
	var volume_value = 4.5*(sound_volume) - 140
	#print(volume_value)
	$SoundTest.set_volume_db(volume_value)
	
	#overall audio? - this would be nice
	#var bus = AudioServer.get_bus_index(AUDIO_BUS_NAME)
	#AudioServer.set_bus_volume_db(bus, linear2db(vol))
	

func _on_voice_options_item_selected(index):
	voice = $Menu/GridContainer/VoiceOptions.get_item_id(index);
	print("voice: %s (%s) voice number: %d, Option index: %d"% [voices[voice].name, voices[voice].language,voice,index])
	speak_text(voices[voice].name);
	

func _on_voice_options_focus_entered():
	if !starting:
		speak_text("Voice %s"%voices[voice].name)


func _on_voice_language_options_item_selected(index: int) -> void:
	#new language selected, refill voices
	lang_id = index
	fill_voice_list()
	var current_lang = $Menu/GridContainer/VoiceLanguageOptions.get_item_text(lang_id)
	speak_text(current_lang);


func _on_voice_language_options_focus_entered() -> void:
	if !starting:
		speak_text("Language %s"%voices[voice].language)


func _on_volume_bar_value_changed(value):
	voice_volume = value #$Menu/GridContainer/VoiceVolumeSlider.get_value()
	speak_text(str(voice_volume));
	$Menu/GridContainer/VoiceVolumeLabel.set_text(str(voice_volume))


func _on_volume_bar_focus_entered():
	speak_text("Voice Volume %d"%voice_volume)


func _on_rate_slider_focus_entered():
	speak_text("Rate %.1f"%rate)
	print_voice_properties()


func _on_rate_slider_value_changed(value):
	rate = value
	speak_text(str(rate))
	$Menu/GridContainer/RateLabel.set_text(str(rate))


func _on_pitch_slider_value_changed(value):
	pitch = value
	speak_text(str(pitch))
	$Menu/GridContainer/PitchLabel.set_text(str(pitch))


func _on_pitch_slider_focus_entered():
	speak_text("Pitch %.1f"%pitch)
	
	
func _on_sound_slider_value_changed(value):
	sound_volume = value
	#speak_text(str(sound_volume))
	$Menu/GridContainer/SoundLabel.set_text(str(sound_volume))
	set_sound_volume(sound_volume)
	if self.is_visible():
		$SoundTest.play()

func _on_sound_slider_focus_entered():
	speak_text("Sound Volume%d"%sound_volume)


func _on_save_settings_button_focus_entered() -> void:
	speak_text("Save Settings. Space to Select")


func _on_save_settings_button_pressed() -> void:
	save_user_preferences()
	store_settings_in_global_object()
	speak_text("Settings Saved")


func _on_restore_default_button_focus_entered() -> void:
	speak_text("Restore Default Setttings. Space to Select")


func _on_restore_default_button_pressed() -> void:
	restore_default_settings()
	speak_text("Defaults Settings Restored")


func _on_instructions_focus_entered() -> void:
	speak_text($Menu/Instructions.get_text())


func _on_done_button_focus_entered() -> void:
	speak_text("Done. Space to select.")


func _on_done_button_pressed() -> void:
	#set up global TTS object
	store_settings_in_global_object()
	done.emit()


func _on_visibility_changed() -> void:
	if self.is_visible():
		#print("Settings visible")
		$Menu/Instructions.grab_focus()
		speak_text($Menu/Instructions.get_text())
		update_settings(false)
	
func store_settings_in_global_object() -> void:
	TTS_Speaker.voice_volume = VOICE_VOLUME_MULTIPLIER * voice_volume
	TTS_Speaker.voice_str = voices[voice].id
	TTS_Speaker.rate = rate
	TTS_Speaker.pitch = pitch
	TTS_Speaker.sound_volume = sound_volume

func print_voice_properties():
	print("Volume = " + str(voice_volume))
	print("Rate = " + str(rate))
	print("Pitch = " + str(pitch))
	print("Sound = " + str(sound_volume))
