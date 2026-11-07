class_name Select extends RefCounted


var _signals: Array[Signal]


signal done


func _init(signals: Array[Signal]) -> void:
	for maybe_sig in signals:
		var sig := maybe_sig as Signal
		_signals.append(sig)
		sig.connect(_trigger)


func _trigger() -> void:
	for sig in _signals:
		sig.disconnect(_trigger)

	done.emit()
