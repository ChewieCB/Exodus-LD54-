extends Button
class_name SelectResearchGraphButton

@export var required_officer: EnumAutoload.Officer = EnumAutoload.Officer.NONE
@export var research_graph_node_name: String
@export var original_button_text: String

var research_tab: ResearchTab = null

func _ready() -> void:
	research_tab = get_parent().get_parent().get_parent()
	original_button_text = text

func _on_pressed() -> void:
	research_tab.open_research_graph(research_graph_node_name)
