extends Node

var sfx_streams: Dictionary = {}
var music_stream: AudioStreamWAV
var sfx_players: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer
const MAX_SFX_PLAYERS: int = 8

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_audio_players()
	_generate_sound_effects()
	_generate_ambient_music()
	_apply_initial_volumes()

func _setup_audio_players() -> void:
	for i in range(MAX_SFX_PLAYERS):
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		sfx_players.append(p)
		
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master"
	add_child(music_player)

func _apply_initial_volumes() -> void:
	var sfx_vol: float = SaveManager.get_setting("sfx_volume", 0.9)
	var music_vol: float = SaveManager.get_setting("music_volume", 0.8)
	set_sfx_volume(sfx_vol)
	set_music_volume(music_vol)

func set_sfx_volume(val: float) -> void:
	for p in sfx_players:
		p.volume_db = linear_to_db(clamp(val, 0.0001, 1.0)) if val > 0.01 else -80.0

func set_music_volume(val: float) -> void:
	music_player.volume_db = linear_to_db(clamp(val, 0.0001, 1.0)) if val > 0.01 else -80.0

func play_sfx(sound_name: String, pitch: float = 1.0) -> void:
	if not SaveManager.get_setting("sfx_volume", 0.9) > 0.01:
		return
	if not sfx_streams.has(sound_name):
		return
	for p in sfx_players:
		if not p.playing:
			p.stream = sfx_streams[sound_name]
			p.pitch_scale = pitch
			p.play()
			return
	# All busy, steal first
	sfx_players[0].stream = sfx_streams[sound_name]
	sfx_players[0].pitch_scale = pitch
	sfx_players[0].play()

func play_music() -> void:
	if music_stream and not music_player.playing:
		music_player.stream = music_stream
		music_player.play()

func stop_music() -> void:
	music_player.stop()

func trigger_haptic(duration_ms: int = 40) -> void:
	if SaveManager.get_setting("haptics", true):
		Input.vibrate_handheld(duration_ms)

# --- Procedural Audio Synthesizer ---

func _generate_sound_effects() -> void:
	sfx_streams["switch_up"] = _synth_sweep(300.0, 700.0, 0.07, 0.6)
	sfx_streams["switch_down"] = _synth_sweep(650.0, 280.0, 0.07, 0.6)
	sfx_streams["orb"] = _synth_bell(880.0, 0.12, 0.7)
	sfx_streams["death"] = _synth_crunch(180.0, 0.25, 0.8)
	sfx_streams["win"] = _synth_arpeggio([523.25, 659.25, 783.99, 1046.50], 0.35, 0.7)
	sfx_streams["click"] = _synth_click(900.0, 0.03, 0.5)

func _synth_sweep(f_start: float, f_end: float, duration: float, volume: float) -> AudioStreamWAV:
	var rate := 22050
	var samples := int(rate * duration)
	var raw := PackedByteArray()
	raw.resize(samples * 2)
	var phase := 0.0
	for i in range(samples):
		var t := float(i) / samples
		var freq: float = lerp(f_start, f_end, t)
		phase += 2.0 * PI * freq / rate
		var env := sin(t * PI)
		var val := int(sin(phase) * env * volume * 32767.0)
		val = clamp(val, -32767, 32767)
		var uval: int = val if val >= 0 else 65536 + val
		raw[i * 2] = uval & 0xFF
		raw[i * 2 + 1] = (uval >> 8) & 0xFF
	
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.stereo = false
	wav.data = raw
	return wav

func _synth_bell(base_f: float, duration: float, volume: float) -> AudioStreamWAV:
	var rate := 22050
	var samples := int(rate * duration)
	var raw := PackedByteArray()
	raw.resize(samples * 2)
	for i in range(samples):
		var t := float(i) / rate
		var env := exp(-t * 18.0)
		var s1 := sin(2.0 * PI * base_f * t)
		var s2 := sin(2.0 * PI * (base_f * 1.5) * t) * 0.5
		var val := int((s1 + s2) * env * volume * 0.7 * 32767.0)
		val = clamp(val, -32767, 32767)
		var uval: int = val if val >= 0 else 65536 + val
		raw[i * 2] = uval & 0xFF
		raw[i * 2 + 1] = (uval >> 8) & 0xFF
		
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.stereo = false
	wav.data = raw
	return wav

func _synth_crunch(base_f: float, duration: float, volume: float) -> AudioStreamWAV:
	var rate := 22050
	var samples := int(rate * duration)
	var raw := PackedByteArray()
	raw.resize(samples * 2)
	var phase := 0.0
	for i in range(samples):
		var t := float(i) / samples
		var freq: float = lerp(base_f, 50.0, t)
		phase += 2.0 * PI * freq / rate
		var noise := (randf() * 2.0 - 1.0) * 0.5
		var env := (1.0 - t) * (1.0 - t)
		var val := int((sin(phase) * 0.6 + noise) * env * volume * 32767.0)
		val = clamp(val, -32767, 32767)
		var uval: int = val if val >= 0 else 65536 + val
		raw[i * 2] = uval & 0xFF
		raw[i * 2 + 1] = (uval >> 8) & 0xFF
		
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.stereo = false
	wav.data = raw
	return wav

func _synth_arpeggio(freqs: Array, duration: float, volume: float) -> AudioStreamWAV:
	var rate := 22050
	var samples := int(rate * duration)
	var note_duration := duration / freqs.size()
	var raw := PackedByteArray()
	raw.resize(samples * 2)
	for i in range(samples):
		var current_time := float(i) / rate
		var note_idx := clampi(int(current_time / note_duration), 0, freqs.size() - 1)
		var freq: float = freqs[note_idx]
		var note_time := fmod(current_time, note_duration)
		var env := sin(clamp(note_time / note_duration, 0.0, 1.0) * PI)
		var val := int(sin(2.0 * PI * freq * current_time) * env * volume * 32767.0)
		val = clamp(val, -32767, 32767)
		var uval: int = val if val >= 0 else 65536 + val
		raw[i * 2] = uval & 0xFF
		raw[i * 2 + 1] = (uval >> 8) & 0xFF
		
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.stereo = false
	wav.data = raw
	return wav

func _synth_click(freq: float, duration: float, volume: float) -> AudioStreamWAV:
	var rate := 22050
	var samples := int(rate * duration)
	var raw := PackedByteArray()
	raw.resize(samples * 2)
	for i in range(samples):
		var t := float(i) / samples
		var env := exp(-t * 25.0)
		var val := int(sin(2.0 * PI * freq * (float(i) / rate)) * env * volume * 32767.0)
		val = clamp(val, -32767, 32767)
		var uval: int = val if val >= 0 else 65536 + val
		raw[i * 2] = uval & 0xFF
		raw[i * 2 + 1] = (uval >> 8) & 0xFF
		
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.stereo = false
	wav.data = raw
	return wav

func _generate_ambient_music() -> void:
	# 4-measure ambient cyber pulse
	var rate := 22050
	var duration := 6.0
	var samples := int(rate * duration)
	var raw := PackedByteArray()
	raw.resize(samples * 2)
	var base_notes := [130.81, 164.81, 196.00, 246.94] # C3, E3, G3, B3
	
	for i in range(samples):
		var t := float(i) / rate
		var beat := fmod(t, 0.75) / 0.75
		var note_idx := int(t / 1.5) % base_notes.size()
		var chord_freq: float = base_notes[note_idx]
		
		var bass := sin(2.0 * PI * (chord_freq * 0.5) * t) * 0.25
		var pad := sin(2.0 * PI * chord_freq * t) * 0.15
		var arp := sin(2.0 * PI * (chord_freq * 2.0) * t) * (1.0 - beat) * 0.15
		var wave := bass + pad + arp
		var val := int(clamp(wave, -1.0, 1.0) * 0.5 * 32767.0)
		var uval: int = val if val >= 0 else 65536 + val
		raw[i * 2] = uval & 0xFF
		raw[i * 2 + 1] = (uval >> 8) & 0xFF
		
	music_stream = AudioStreamWAV.new()
	music_stream.format = AudioStreamWAV.FORMAT_16_BITS
	music_stream.mix_rate = rate
	music_stream.stereo = false
	music_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	music_stream.loop_end = samples
	music_stream.data = raw
