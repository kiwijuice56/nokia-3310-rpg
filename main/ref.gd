extends Node

@onready var ui = get_tree().get_root().get_node("Main/Screen/UI")
@onready var textbox: TextBox = get_tree().get_root().get_node("Main/Screen/UI/TextBox")
@onready var statbox: StatBox = get_tree().get_root().get_node("Main/Screen/UI/StatBox")
@onready var itembox: ItemBox = get_tree().get_root().get_node("Main/Screen/UI/ItemBox")
@onready var shop_menu: ShopMenu = get_tree().get_root().get_node("Main/Screen/UI/ShopMenu")
@onready var dungeon: Dungeon = get_tree().get_root().get_node("Main/Screen/Dungeon")
@onready var camera: Camera2D = get_tree().get_root().get_node("Main/Screen/Camera2D")
@onready var fight_manager: FightManager = get_tree().get_root().get_node("Main/Screen/FightManager")
@onready var player: Player = get_tree().get_root().get_node("Main/Screen/Player")
