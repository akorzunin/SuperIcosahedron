extends GutTest

var controller: FigureController
var target: MeshIcosahedron

func before_each() -> void:
    controller = autofree(FigureController.new())
    target = autofree(MeshIcosahedron.new())
    controller.target = target

func test_free_spin_changes_orientation_and_keeps_it_normalized() -> void:
    controller.rotate_continuous(Vector2.RIGHT, 0.1)
    assert_false(target.quaternion.is_equal_approx(Quaternion.IDENTITY))
    assert_almost_eq(target.quaternion.length(), 1.0, 0.00001)

func test_inversion_reverses_horizontal_rotation() -> void:
    controller.rotate_continuous(Vector2.RIGHT, 0.1)
    var normal := target.quaternion
    target.quaternion = Quaternion.IDENTITY
    controller.inverted = true
    controller.rotate_continuous(Vector2.RIGHT, 0.1)
    assert_true(target.quaternion.is_equal_approx(normal.inverse()))

func test_no_input_does_not_rotate_even_when_inverted() -> void:
    controller.inverted = true
    controller.rotate_continuous(Vector2.ZERO, 0.1)
    assert_true(target.quaternion.is_equal_approx(Quaternion.IDENTITY))

func test_disabled_controller_ignores_commands() -> void:
    controller.enabled = false
    controller.rotate_continuous(Vector2.RIGHT, 0.1)
    controller.step_face(Vector2.LEFT)
    assert_true(target.quaternion.is_equal_approx(Quaternion.IDENTITY))

func test_face_lock_left_and_right_are_inverse_rotations() -> void:
    for alternate in [false, true]:
        var combined := FaceLock.handle_rot_left(alternate) * FaceLock.handle_rot_right(alternate)
        assert_true(combined.is_equal_approx(Quaternion.IDENTITY))
