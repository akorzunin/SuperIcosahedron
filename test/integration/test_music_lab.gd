extends GutTest

const LAB := preload("res://dev/labs/music/MusicLab.tscn")
const SCRIPT := preload("res://dev/labs/music/MusicLab.gd")
var lab: Control


func before_each() -> void:
    lab = LAB.instantiate()
    add_child_autofree(lab)
    lab.set_process(false)


func after_each() -> void:
    lab.stop()
    # Audio mixing uses wall time even under the suite's --fixed-fps simulation.
    OS.delay_msec(80)
    await get_tree().process_frame
    await get_tree().process_frame


func test_stems_share_transport_and_loop_duration() -> void:
    assert_false(lab.player.playing)
    assert_eq(lab.mix.stream_count, 4)
    for index in 4:
        var stream: AudioStreamOggVorbis = lab.mix.get_sync_stream(index)
        assert_true(stream.loop)
        assert_almost_eq(stream.get_length(), lab.LENGTH, 0.001)


func test_audio_clock_advances_across_loop_and_freezes_on_pause() -> void:
    lab.set_process(true)
    lab.restart(lab.LENGTH - 0.1)
    OS.delay_msec(250)
    await get_tree().process_frame
    await get_tree().process_frame
    assert_gt(lab.seconds, lab.LENGTH)
    assert_eq(lab.loop_count, 1)
    lab.toggle_pause()
    var paused_at: float = lab.seconds
    await get_tree().process_frame
    await get_tree().process_frame
    assert_eq(lab.seconds, paused_at)


func test_mute_overrides_multi_solo() -> void:
    lab.soloed = [true, true, false, false]
    lab.muted = [true, false, false, false]
    assert_eq(lab.effective_gains(), [0.0, 0.7, 0.0, 0.0])


func test_quantized_mix_waits_for_boundary_and_ramps() -> void:
    lab.restart()
    lab.seconds = 0.6
    lab.set_arrangement([true, false, false, false])
    assert_eq(lab.pending_beat, 4.0)
    lab.advance_mix(0.1, 3.9)
    assert_eq(lab.applied[1], 0.7)
    lab.advance_mix(0.03, 4.0)
    assert_gt(lab.applied[1], 0.0)
    assert_lt(lab.applied[1], 0.7)
    lab.advance_mix(1.0, 5.0)
    assert_eq(lab.applied[1], 0.0)
    assert_eq(lab.pending_beat, -1.0)


func test_sequence_waits_eight_bars_and_latest_request_wins() -> void:
    lab.restart()
    lab.quantize = 32.0
    lab.seconds = 3.0
    lab.set_arrangement([true, false, false, false])
    assert_eq(lab.pending_beat, 32.0)
    lab.seconds = 12.0
    lab.set_arrangement([false, true, false, true])
    assert_eq(lab.pending_beat, 32.0)
    lab.advance_mix(1.0, 31.9)
    assert_eq(lab.applied, [0.7, 0.7, 0.7, 0.7])
    lab.advance_mix(1.0, 32.0)
    assert_eq(lab.applied, [0.0, 0.7, 0.0, 0.7])
    lab.seconds = 19.2
    lab.request_mix()
    assert_eq(lab.pending_beat, 64.0)


func test_stem_fades_are_independent_and_zero_is_instant() -> void:
    lab.fades = [0.0, 0.5, 1.0, 2.0]
    lab.set_arrangement([false, false, false, false])
    lab.advance_mix(0.1, 0.0)
    assert_eq(lab.applied[0], 0.0)
    assert_almost_eq(lab.applied[1], 0.5, 0.0001)
    assert_almost_eq(lab.applied[2], 0.6, 0.0001)
    assert_almost_eq(lab.applied[3], 0.65, 0.0001)


func test_boundaries_and_offbeats() -> void:
    assert_eq(SCRIPT.next_boundary(4.0, 4.0), 8.0)
    assert_eq(SCRIPT.next_boundary(2.2, 1.0), 3.0)
    assert_eq(SCRIPT.next_boundary(2.2, 0.0), 2.2)
    assert_eq(SCRIPT.nearest_target(2.45, [0.0, 2.5]), 2.5)
    assert_eq(SCRIPT.nearest_target(3.95, [0.0, 2.5]), 4.0)
    assert_eq(SCRIPT.upcoming_target(0.51, [0.5, 3.5]), 3.5)
    assert_eq(SCRIPT.upcoming_target(3.51, [0.5, 3.5]), 4.5)
    assert_eq(SCRIPT.upcoming_target(4.5, [0.5, 3.5]), 4.5)


func test_pass_awarded_once_only_near_node_and_not_while_paused() -> void:
    lab.restart()
    lab.seconds = 1.5
    lab.press_pass()
    assert_string_contains(lab.feedback.text, "Perfect")
    lab.press_pass()
    assert_string_contains(lab.feedback.text, "already judged")
    assert_eq(lab.judged.size(), 1)
    lab.seconds = 0.6
    lab.press_pass()
    assert_string_contains(lab.feedback.text, "Outside")
    lab.toggle_pause()
    lab.seconds = 2.4
    lab.press_pass()
    assert_eq(lab.judged.size(), 1)
    lab.restart()
    assert_true(lab.judged.is_empty())
    assert_false(lab.player.stream_paused)


func test_offset_and_mix_recall() -> void:
    lab.seconds = 0.1
    lab.offset_ms = 100.0
    assert_almost_eq(lab.beat_position(), 0.0, 0.0001)
    lab.fades[0] = 1.2
    lab.store_mix()
    lab.fades[0] = 0.0
    lab.gains[0] = 0.2
    lab.set_arrangement([true, false, false, false])
    lab.recall_mix()
    assert_eq(lab.effective_gains(), [0.7, 0.7, 0.7, 0.7])
    assert_eq(lab.sliders[0].value, 0.7)
    assert_eq(lab.fades[0], 1.2)
    assert_eq(lab.fade_inputs[0].value, 1.2)


func test_event_envelope_is_bounded_and_stop_clears_it() -> void:
    lab.restart()
    lab.trigger_event(0.45)
    lab.trigger_event(0.45)
    assert_eq(lab.event_remaining, 0.45)
    lab.advance_mix(0.1, 0.0)
    assert_lt(lab.filter.cutoff_hz, 20000.0)
    lab.stop()
    assert_eq(lab.event_remaining, 0.0)
    assert_eq(lab.filter.cutoff_hz, 20000.0)
