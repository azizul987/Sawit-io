class_name skill
extends  Resource

@export var id:String
@export var skill_name:String
@export var max_level:int
@export var  tree_position:Vector2
@export var required_skill_ids: Array[String] = []
@export var  is_open:bool
@export var cost:Array[int]
@export var level:int
@export var Icon:Texture2D=preload("res://temp tekture/skill_icons_by_quintino_pixels/24x24/skill_icons7.png")
