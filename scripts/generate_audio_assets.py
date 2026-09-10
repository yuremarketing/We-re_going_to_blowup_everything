#!/usr/bin/env python3
import math
import struct
import wave
import random
import os

SAMPLE_RATE = 44100

def write_wav(filename, samples):
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with wave.open(filename, 'w') as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(SAMPLE_RATE)
        packed = bytearray()
        for s in samples:
            s_clamped = max(-1.0, min(1.0, s))
            val = int(s_clamped * 32767.0)
            packed.extend(struct.pack('<h', val))
        wav.writeframes(packed)
    print(f"Generated {filename} ({len(samples)/SAMPLE_RATE:.2f}s)")

def gen_attack():
    # Whoosh / Swing
    duration = 0.12
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (t / duration)) ** 2
        freq = 350.0 - 200.0 * (t / duration)
        noise = (random.random() * 2.0 - 1.0) * 0.4
        tone = math.sin(2.0 * math.pi * freq * t) * 0.6
        samples.append((tone + noise) * env * 0.8)
    return samples

def gen_hit():
    # Punchy impact
    duration = 0.16
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 22.0)
        freq = 160.0 * math.exp(-t * 15.0) + 40.0
        tone = math.sin(2.0 * math.pi * freq * t)
        noise = (random.random() * 2.0 - 1.0) * math.exp(-t * 35.0)
        samples.append((tone * 0.7 + noise * 0.5) * env)
    return samples

def gen_player_hurt():
    # High descending hurt alarm
    duration = 0.22
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 12.0)
        freq = 520.0 - 260.0 * (t / duration)
        tone = math.sin(2.0 * math.pi * freq * t)
        samples.append(tone * env * 0.8)
    return samples

def gen_enemy_death():
    # Low explosion / puff
    duration = 0.32
    n = int(SAMPLE_RATE * duration)
    samples = []
    lp = 0.0
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 9.0)
        white = random.random() * 2.0 - 1.0
        lp = lp + 0.15 * (white - lp)  # simple low pass
        sub = math.sin(2.0 * math.pi * (90.0 - 60.0 * (t / duration)) * t) * 0.5
        samples.append((lp * 0.7 + sub) * env * 0.9)
    return samples

def gen_boss_spawn():
    # Deep dramatic horn / alert
    duration = 0.9
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = min(1.0, t * 15.0) * math.exp(-t * 2.0)
        freq1 = 95.0 + 15.0 * math.sin(math.pi * (t / duration))
        freq2 = 142.5  # perfect fifth
        tone = 0.6 * math.sin(2.0 * math.pi * freq1 * t) + 0.4 * math.sin(2.0 * math.pi * freq2 * t)
        samples.append(tone * env * 0.85)
    return samples

def gen_victory():
    # Upward arpeggio: C4, E4, G4, C5
    notes = [261.63, 329.63, 392.00, 523.25]
    duration = 0.6
    n = int(SAMPLE_RATE * duration)
    note_dur = duration / len(notes)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        idx = min(len(notes) - 1, int(t / note_dur))
        freq = notes[idx]
        note_t = t - (idx * note_dur)
        env = math.exp(-note_t * 6.0)
        tone = math.sin(2.0 * math.pi * freq * t) + 0.25 * math.sin(4.0 * math.pi * freq * t)
        samples.append(tone * env * 0.7)
    return samples

def gen_game_over():
    # Downward sad notes: E4, D4, C4, A3
    notes = [329.63, 293.66, 261.63, 220.00]
    duration = 0.8
    n = int(SAMPLE_RATE * duration)
    note_dur = duration / len(notes)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        idx = min(len(notes) - 1, int(t / note_dur))
        freq = notes[idx]
        note_t = t - (idx * note_dur)
        env = math.exp(-note_t * 4.5)
        tone = math.sin(2.0 * math.pi * freq * t) + 0.15 * math.sin(3.0 * math.pi * freq * t)
        samples.append(tone * env * 0.7)
    return samples

def gen_heal():
    # Soft rising chime: G4 -> C5, curto e suave (pickup de cura)
    notes = [392.00, 523.25]
    duration = 0.35
    n = int(SAMPLE_RATE * duration)
    note_dur = duration / len(notes)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        idx = min(len(notes) - 1, int(t / note_dur))
        freq = notes[idx]
        note_t = t - (idx * note_dur)
        env = math.exp(-note_t * 5.0) * math.sin(math.pi * min(1.0, note_t / 0.02))
        tone = math.sin(2.0 * math.pi * freq * t) + 0.3 * math.sin(4.0 * math.pi * freq * t)
        samples.append(tone * env * 0.55)
    return samples

def gen_bgm():
    # 4 bars at 120 BPM = 8.0s seamless loop
    bpm = 120.0
    bar_dur = 4.0 * (60.0 / bpm)  # 2.0s per bar
    duration = bar_dur * 4.0      # 8.0s
    n = int(SAMPLE_RATE * duration)
    samples = [0.0] * n
    
    # Bass progression in D minor: D2 (73.42Hz), F2 (87.31Hz), G2 (98.0Hz), A2 (110.0Hz)
    bar_notes = [73.42, 73.42, 87.31, 98.00]
    
    beat_dur = 60.0 / bpm # 0.5s
    sixteenth = beat_dur / 4.0 # 0.125s
    
    # Add bassline
    for i in range(n):
        t = i / SAMPLE_RATE
        bar_idx = min(3, int(t / bar_dur))
        base_f = bar_notes[bar_idx]
        
        # 16th note pulse
        pulse_t = t % sixteenth
        pulse_env = math.exp(-pulse_t * 24.0)
        
        # Synth bass (fundamental + sub + 2nd harmonic)
        bass = (0.5 * math.sin(2.0 * math.pi * base_f * t) + 
                0.3 * math.sin(math.pi * base_f * t) + 
                0.2 * math.sin(4.0 * math.pi * base_f * t)) * pulse_env
        
        # Electronic 4-on-the-floor kick on each beat
        beat_t = t % beat_dur
        kick_env = math.exp(-beat_t * 18.0)
        kick_f = 110.0 * math.exp(-beat_t * 28.0) + 38.0
        kick = math.sin(2.0 * math.pi * kick_f * beat_t) * kick_env * 0.7
        
        # Snare / clap on beats 2 and 4 (beat index 1 and 3 in each bar)
        curr_beat_in_bar = int((t % bar_dur) / beat_dur)
        snare = 0.0
        if curr_beat_in_bar in (1, 3):
            snare_t = beat_t
            snare_env = math.exp(-snare_t * 14.0)
            snare = (random.random() * 2.0 - 1.0) * snare_env * 0.35
            
        samples[i] = (bass * 0.45 + kick * 0.4 + snare * 0.3) * 0.65
        
    return samples

if __name__ == "__main__":
    out_dir = "assets/audio"
    write_wav(os.path.join(out_dir, "sfx_attack.wav"), gen_attack())
    write_wav(os.path.join(out_dir, "sfx_hit.wav"), gen_hit())
    write_wav(os.path.join(out_dir, "sfx_player_hurt.wav"), gen_player_hurt())
    write_wav(os.path.join(out_dir, "sfx_enemy_death.wav"), gen_enemy_death())
    write_wav(os.path.join(out_dir, "sfx_boss_spawn.wav"), gen_boss_spawn())
    write_wav(os.path.join(out_dir, "sfx_victory.wav"), gen_victory())
    write_wav(os.path.join(out_dir, "sfx_game_over.wav"), gen_game_over())
    write_wav(os.path.join(out_dir, "sfx_heal.wav"), gen_heal())
    write_wav(os.path.join(out_dir, "bgm_combat.wav"), gen_bgm())
    print("All audio assets generated successfully!")
