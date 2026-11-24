extends RefCounted
## Shared six primary axes; D7 data is never changed by presentation.
const NAMES := ["Tư Chất","Căn Cốt","Cơ Duyên","Thông Tuệ","Mị Lực","Tiềm Lực"]
const D7_INDICES := [0,1,5,4,6,3]

static func primary_values(values: Array) -> Array[float]:
    var result: Array[float] = []
    if values.size() == 6:
        for value in values:
            result.append(float(value))
    elif values.size() == 7:
        for index in D7_INDICES:
            result.append(float(values[index]))
    return result

static func draw_chart(view: Control, canonical: Array, mind_available: bool, ink: Color, accent: Color, grid: Color, decimals: bool = false) -> void:
    var values := primary_values(canonical)
    if values.size() != 6 or view.size.x < 160.0 or view.size.y < 140.0:
        return
    var font := view.get_theme_default_font()
    if font == null:
        return
    var center := Vector2(view.size.x * 0.5, view.size.y * 0.43)
    var radius := minf(view.size.x * 0.235, view.size.y * 0.245)
    var maximum := 0.0
    for value in values:
        maximum = maxf(maximum,value)
    var ceiling := 1.0
    if maximum > 0.0:
        var step := pow(10.0,floor(log(maximum)/log(10.0)))
        ceiling = maxf(1.0,ceil(maximum/step)*step)
    var label_size := 11 if view.size.x >= 300.0 else 10
    var label_width := 80.0
    for ring in [0.25,0.5,0.75,1.0]:
        var outline := PackedVector2Array()
        for index in range(7):
            var angle := -PI*0.5+TAU*float(index%6)/6.0
            outline.append(center+Vector2(cos(angle),sin(angle))*radius*float(ring))
        view.draw_polyline(outline,grid,1.0,true)
    var polygon := PackedVector2Array()
    for index in range(6):
        var angle := -PI*0.5+TAU*float(index)/6.0
        var direction := Vector2(cos(angle),sin(angle))
        view.draw_line(center,center+direction*radius,grid,1.0,true)
        polygon.append(center+direction*radius*clampf(values[index]/ceiling,0.0,1.0))
        var point := center+direction*(radius+18.0)
        view.draw_string(font,point+Vector2(-label_width*0.5,0),NAMES[index],HORIZONTAL_ALIGNMENT_CENTER,label_width,label_size,ink)
        var readout := "%.2f" % values[index] if decimals else "%.0f" % values[index]
        view.draw_string(font,point+Vector2(-label_width*0.5,13),readout,HORIZONTAL_ALIGNMENT_CENTER,label_width,label_size,accent)
    var fill := accent
    fill.a = 0.19
    view.draw_colored_polygon(polygon,fill)
    var closed := polygon.duplicate()
    closed.append(polygon[0])
    view.draw_polyline(closed,accent,2.0,true)
    for point in polygon:
        view.draw_circle(point,3.0,accent)
    var scale_text := "%.2f" % ceiling if decimals else "%.0f" % ceiling
    view.draw_string(font,Vector2(0,view.size.y-26),"LỤC DUY · Thang "+scale_text,HORIZONTAL_ALIGNMENT_CENTER,view.size.x,label_size,ink)
    var mind_text := "Tâm Tính: chưa có dữ liệu"
    if mind_available and canonical.size() == 7:
        mind_text = "Tâm Tính: %.0f · phẩm chất D7" % float(canonical[2])
    view.draw_string(font,Vector2(0,view.size.y-9),mind_text,HORIZONTAL_ALIGNMENT_CENTER,view.size.x,label_size,ink)
