require 'app/lib/dinraal.rb'
require 'app/lib/circle.rb'

$gtk.reset

def tick(args)
  # Define two triangles
  tri1 = { x: 100, y: 100, x2: 250, y2: 600, x3: 900, y3: 500, r: 255 }
  tri2 = { x: 130, y: 130, x2: 200, y2: 300, x3: 400, y3: 400, b: 255 }

  # Pre-Render the triangles and their center markers
  if args.state.tick_count.zero?
    args.render_target(:static).primitives << Dinraal.raster(tri1)

    args.render_target(:static).primitives << Circle.raster_outline(x: 500, y: 500, radius: 20, g: 255)

    args.render_target(:static).primitives << Circle.raster(x: 700, y: 500, radius: 20, b: 255)
  end

  # Render the triangles and their center markers
  outputs = []
  outputs << { x: 0, y: 0, w: 1280, h: 720, path: :static }.sprite!

  outputs << Dinraal.outline(tri2)
  outputs << Dinraal.center(tri1).merge(w: 5, h: 5, g: 255).solid!
  outputs << Dinraal.center(tri2).merge(w: 5, h: 5, g: 255).solid!

  # Get the mouse position
  mouse_x = args.inputs.mouse.x
  mouse_y = args.inputs.mouse.y

  # Determine if the mouse is inside of the red triangle
  mouse_inside = Dinraal.inside?(point: { x: mouse_x, y: mouse_y }, tri: tri1)

  # Draw a label to display if the mouse inside the red triangle
  outputs << { x: args.grid.center_x, y: 720, text: "Mouse inside red: #{mouse_inside}", alignment_enum: 1 }.label!

  outputs << Dinraal.bounding_box(tri2)

  two_contains_one = Dinraal.tri_inside?(inner: tri2, outer: tri1)
  outputs << { x: args.grid.center_x, y: 700, text: "Red contains blue: #{two_contains_one}", alignment_enum: 1 }.label!

  args.outputs.primitives << outputs

  # Optional Debug Information. Uncomment to show
  # args.outputs.debug << args.gtk.framerate_diagnostics_primitives
end
