class_name Combine extends RefCounted


var _signals: Array[Signal]


signal done


var _count_done: int = 0


func _init(signals: Array[Signal]) -> void:
	for maybe_sig in signals:
		var sig := maybe_sig as Signal
		_signals.append(sig)
		sig.connect(_trigger.bind(sig))


func _trigger(sig: Signal) -> void:
	sig.disconnect(_trigger)
	_count_done += 1

	if _count_done >= len(_signals):
		done.emit()
