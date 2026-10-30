extends Polygon2D

func _ready(): 
	#js for specific points purposes
	polygon = PackedVector2Array([
		Vector2(-45, -45),
		Vector2(45, -45),
		Vector2(45, 45),
		Vector2(-45, 45)
	])
