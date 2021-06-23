extends Node

signal spider_left_screen
signal spider_destroyed


onready var spider_scene: PackedScene = preload("res://scenes/spider.tscn")
var Rng = RandomNumberGenerator.new()


func _ready() -> void:
	Rng.randomize()	
	
	
func spawn():
	var spider = spider_scene.instance()
	spider.connect('spider_left_screen', self, 'on_spider_left_screen')
	spider.connect('spider_destroyed', self, 'on_spider_destroyed')
	add_child(spider)
	
	
func on_spider_left_screen() -> void:
	emit_signal("spider_left_screen")


func on_spider_destroyed() -> void:
	emit_signal("spider_destroyed")
