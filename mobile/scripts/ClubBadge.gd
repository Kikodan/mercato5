@tool
class_name ClubBadge
extends Control

enum ShieldShape { SHIELD, CIRCLE, DIAMOND, STRIPES }
enum SymbolType { NONE, STAR, CROSS, CHEVRON, ANCHOR }

@export var shape: ShieldShape = ShieldShape.SHIELD:
	set(val): shape = val; queue_redraw()
@export var symbol: SymbolType = SymbolType.STAR:
	set(val): symbol = val; queue_redraw()
@export var primary_color: Color = Color("1e293b"):
	set(val): primary_color = val; queue_redraw()
@export var secondary_color: Color = Color("facc15"):
	set(val): secondary_color = val; queue_redraw()

func _draw() -> void:
	var s = size
	var center = s * 0.5

	match shape:
		ShieldShape.CIRCLE:
			draw_circle(center, minf(s.x, s.y) * 0.46, primary_color)
			draw_arc(center, minf(s.x, s.y) * 0.46, 0, TAU, 32, secondary_color, 2.5)
		ShieldShape.DIAMOND:
			var pts = PackedVector2Array([Vector2(center.x, 2), Vector2(s.x - 2, center.y), Vector2(center.x, s.y - 2), Vector2(2, center.y)])
			draw_colored_polygon(pts, primary_color)
			draw_polyline(pts + PackedVector2Array([pts[0]]), secondary_color, 2.0)
		ShieldShape.STRIPES:
			draw_rect(Rect2(Vector2.ZERO, s), primary_color)
			draw_rect(Rect2(s.x / 4.0, 0, s.x / 4.0, s.y), secondary_color)
			draw_rect(Rect2(s.x * 0.75, 0, s.x / 4.0, s.y), secondary_color)
		ShieldShape.SHIELD:
			var pts = PackedVector2Array([Vector2(4, 4), Vector2(s.x - 4, 4), Vector2(s.x - 4, s.y * 0.6), Vector2(center.x, s.y - 4), Vector2(4, s.y * 0.6)])
			draw_colored_polygon(pts, primary_color)
			draw_polyline(pts + PackedVector2Array([pts[0]]), secondary_color, 2.5)

	var r = minf(s.x, s.y) * 0.25
	match symbol:
		SymbolType.STAR:
			var pts = PackedVector2Array()
			for i in 10:
				var a = -PI * 0.5 + i * (TAU / 10.0)
				pts.append(center + Vector2(cos(a), sin(a)) * (r if i % 2 == 0 else r * 0.45))
			draw_colored_polygon(pts, secondary_color)
		SymbolType.CROSS:
			var t = r * 0.35
			draw_rect(Rect2(center.x - t * 0.5, center.y - r, t, r * 2), secondary_color)
			draw_rect(Rect2(center.x - r, center.y - t * 0.5, r * 2, t), secondary_color)
		SymbolType.CHEVRON:
			var pts = PackedVector2Array([Vector2(center.x - r, center.y + r * 0.3), Vector2(center.x, center.y - r * 0.5), Vector2(center.x + r, center.y + r * 0.3)])
			draw_polyline(pts, secondary_color, 3.5)
		SymbolType.ANCHOR:
			draw_line(Vector2(center.x, center.y - r), Vector2(center.x, center.y + r), secondary_color, 3.0)
			draw_line(Vector2(center.x - r * 0.6, center.y - r * 0.3), Vector2(center.x + r * 0.6, center.y - r * 0.3), secondary_color, 2.5)
			draw_arc(Vector2(center.x, center.y + r * 0.3), r * 0.7, 0, PI, 16, secondary_color, 3.0)

