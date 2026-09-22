# Music lab

Run `go-task lab-music`. Normal gameplay and its audio buses are unchanged.

- Press Play to start all four stems on one `AudioStreamSynchronized` player.
- Gain, mute, and multi-solo changes apply immediately, next beat, or next bar, with gain ramps. Mute overrides solo. All stems keep playing, including silent ones.
- Sparse/Full/Random select combinations. Store/Recall A keeps one comparison mix in memory, not on disk.
- Jump to middle starts at 57.6 seconds; flute/melody are not present throughout the original arrangement.
- Pickup and combo-break buttons simulate a bounded low-pass envelope; combo break also requests the sparse arrangement.
- Space (or Pass) judges only the nearest scheduled node: Perfect ±60 ms, Good ±130 ms, one award per node. The approach indicator fills toward a target. Pattern positions use `&` for eighth-note offbeats.
- BPM changes only the grid, not playback speed. Positive beat offset moves targets later relative to audio. Pause freezes both audio and timing. Restart clears timing awards and pending effects.

## Assets and license

**Glitch Stairs**, by **Fupi**, published on OpenGameArt under **CC0 1.0**.

- Source: https://opengameart.org/content/glitch-stairs
- Original archive: https://opengameart.org/sites/default/files/glitchstairs_2.zip
- License: https://creativecommons.org/publicdomain/zero/1.0/
- License legal text: https://creativecommons.org/publicdomain/zero/1.0/legalcode

The four included OGG files derive from `Stems/StemDrums.wav`, `StemBass.wav`, `StemFlute.wav`, and `StemMelody.wav` in that archive. No AI separation or frequency splitting. Source WAVs are stereo, 44.1 kHz, 5,186,048 frames each (117.597460 seconds). They were padded with ~2.54 ms silence to 117.6 seconds and encoded using:

```sh
ffmpeg -i StemDrums.wav -af apad -t 117.6 -c:a libvorbis -q:a 5 drums.ogg
```

Repeat for bass, flute, and melody. The large original ZIP/WAVs are not vendored.

**100 BPM is inferred**, not author-provided: short loops are ~9.6 seconds (16 beats at 100 BPM); the full stems are ~196 beats / 49 bars. The lab exposes BPM and offset for audition/calibration. Padding aligns duration to that inferred grid; it does not prove a musically seamless end-to-start transition. Audition the seam before using it in production.

## Deliberate limits

This is an implementation/arrangement lab, not final rhythm gameplay. Timing is audio-derived with mix/output latency correction; mix changes and gain envelopes are dispatched on rendered frames, not sample-accurate callbacks. Upgrade scheduling if frame-resolution transitions are audibly insufficient. Input timestamps are handled on receipt, not hardware-calibrated. There is no alignment/collision eligibility, scoring integration, metronome, tempo stretching, or cross-composition variant browser yet.

Continuous decoding of four stems simplifies synchronization; profile web/mobile before expanding the pack. Master headroom is -9 dB and a peak readout warns about clipping, but this is not a loudness-normalization or mastering tool. The visual replay validates UI/state only, not audible synchronization, loop seams, or musical quality; those require listening.
