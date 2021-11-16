$gtk.reset

require 'app/lib/dinraal.rb'

def circle(x:, y:, radius:, r: 0, g: 0, b: 0, a: 255)
  200.times do |i|
    h = i - radius
    l = Math::sqrt(radius * radius - h * h)
    lines = []
    lines << [i, radius - l, i, radius + l]
  end
  lines
end

def make_rt(args)
  args.render_target(:static_rt).clear_before_render = true

  args.render_target(:static_rt).primitives << Dinraal.circle_outline(x: 20, y: 580, radius: 20, g: 255)
  #args.render_target(:static_rt).primitives << Dinraal.circle_raster(x: 70, y: 580, radius: 20, b: 255)
  #args.render_target(:static_rt).primitives << circle(x: 70, y: 580, radius: 20, b: 255)

  args.render_target(:static_rt).primitives << Dinraal.triangle_outline(args.state.tri2)

  args.render_target(:static_rt).primitives << Dinraal.triangle_center(args.state.tri2).merge(w: 5, h: 5, g: 255).solid!

  args.render_target(:static_rt).primitives << Dinraal.triangle_bounding_box(args.state.tri2)
end

def tick(args)
  # args.state.tri1 ||= { x: 800, y: 500, x2: 450, y2: 650, x3: 400, y3: 300, path: 'sprites/rick.png', image_width: 300 }
  tri1 = { x: 800, y: 500, x2: 450, y2: 650, x3: 400, y3: 300, g: 255 }.merge(x: args.inputs.mouse.x, y: args.inputs.mouse.y)
  args.state.tri2 ||= { x: 200, y: 600, x2: 400, y2: 600, x3: 275, y3: 500, r: 255 }

  if args.state.tick_count.zero?
    make_rt(args)
  end

  outputs = []
  
  outputs << circle(x: args.grid.center_x, y: args.grid.center_y, radius: 100, b: 255)
  outputs << { x: 0, y: 0, w: 1280, h: 720, path: :static_rt }.sprite!
  
  outputs << Dinraal.triangle(tri1)

  mouse_x = args.inputs.mouse.x
  mouse_y = args.inputs.mouse.y

  mouse_inside = Dinraal.point_inside_triangle?(point: { x: mouse_x, y: mouse_y }, triangle: tri1)

  outputs << { x: args.grid.center_x, y: 720, text: "Mouse inside image: #{mouse_inside}", alignment_enum: 1 }.label!

  two_contains_one = Dinraal.triangle_inside_triangle?(inner: args.state.tri2, outer: tri1)
  outputs << { x: args.grid.center_x, y: 700, text: "Image contains red triangle: #{two_contains_one}", alignment_enum: 1 }.label!

  args.outputs.primitives << outputs

  # Optional Debug Information. Uncomment to show
  # args.outputs.debug << args.gtk.framerate_diagnostics_primitives
end