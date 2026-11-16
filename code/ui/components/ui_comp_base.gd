@abstract class_name UIComponentBase extends Node

@warning_ignore("unused_private_class_variable")
var _ui: Node = null

@abstract func setup(ui: Node) -> void
@abstract func update() -> void
