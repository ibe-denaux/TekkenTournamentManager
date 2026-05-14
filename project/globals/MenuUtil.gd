extends Node


func show_home_menu() -> void:
	var tab_container: TabContainer = get_tree().get_first_node_in_group("MenuTabContainer")
	if not tab_container:
		push_warning("No menu tab container.")
		return
	tab_container.current_tab = 0
