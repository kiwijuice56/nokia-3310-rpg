extends Node

@onready var textbox: TextBox = get_tree().get_root().get_node("Main/UI/TextBox")
@onready var statbox: StatBox = get_tree().get_root().get_node("Main/UI/StatBox")
@onready var itembox: ItemBox = get_tree().get_root().get_node("Main/UI/ItemBox")
@onready var shop_menu: ShopMenu = get_tree().get_root().get_node("Main/UI/ShopMenu")
@onready var dungeon: Dungeon = get_tree().get_root().get_node("Main/Dungeon")
@onready var camera: Camera2D = get_tree().get_root().get_node("Main/Camera2D")
@onready var fight_manager: FightManager = get_tree().get_root().get_node("Main/FightManager")
@onready var player: Player = get_tree().get_root().get_node("Main/Player")
