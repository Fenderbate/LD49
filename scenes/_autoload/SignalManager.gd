extends Node


signal planet_interact(target_planet)
signal planet_focus_enter()
signal planet_focus_leave()
signal update_planet_UI(temp,air,population)
signal update_supply_display()
signal set_object_selection_focus(type)
signal show_tooltip(tooltip)
signal hide_tooltip()
signal reset_select_index()
signal add_person(planet_id)
signal remove_person(planet_id)
signal tutorial_open()
signal tutorial_close()

signal game_win()
signal game_lose()

