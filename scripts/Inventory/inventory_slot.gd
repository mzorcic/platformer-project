extends Panel

@onready var item_icon: TextureRect = $ItemIcon


func set_item(texture: Texture2D):
	item_icon.texture = texture


func clear_slot():
	item_icon.texture = null
