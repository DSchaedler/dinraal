require 'app/lib/dinraal.rb'

$gtk.reset

def tick(args)
  tri1 = { x: 100, y: 100, x2: 250, y2: 600, x3: 900, y3: 500, r: 255 }
  tri2 = { x: 130, y: 130, x2: 200, y2: 300, x3: 400, y3: 400, b: 255 }

  if args.state.tick_count.zero?
    args.render_target(:static_rt).clear_before_render = true

    args.render_target(:static_rt).primitives << Dinraal.triangle_raster(tri1)

    args.render_target(:static_rt).primitives << Dinraal.circle_outline(x: 500, y: 500, radius: 20, g: 255)

    args.render_target(:static_rt).primitives << Dinraal.circle_raster(x: 700, y: 500, radius: 20, b: 255)
  end

  outputs = []
  outputs << { x: 0, y: 0, w: 1280, h: 720, path: :static_rt }.sprite!

  outputs << Dinraal.triangle_outline(tri2)
  outputs << Dinraal.triangle_center(tri1).merge(w: 5, h: 5, g: 255).solid!
  outputs << Dinraal.triangle_center(tri2).merge(w: 5, h: 5, g: 255).solid!

  mouse_x = args.inputs.mouse.x
  mouse_y = args.inputs.mouse.y

  mouse_inside = Dinraal.point_inside_triangle?(point: { x: mouse_x, y: mouse_y }, triangle: tri1)

  outputs << { x: args.grid.center_x, y: 720, text: "Mouse inside red: #{mouse_inside}", alignment_enum: 1 }.label!

  outputs << Dinraal.triangle_bounding_box(tri2)

  two_contains_one = Dinraal.triangle_inside_triangle?(inner: tri2, outer: tri1)
  outputs << { x: args.grid.center_x, y: 700, text: "Red triangle contains blue triangle: #{two_contains_one}", alignment_enum: 1 }.label!

  args.outputs.primitives << outputs

  # Optional Debug Information. Uncomment to show
  # args.outputs.debug << args.gtk.framerate_diagnostics_primitives
end
