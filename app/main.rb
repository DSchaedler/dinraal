require 'app/lib/dinraal.rb'

def tick(args)
  # Define two triangles
  tri1 = { x: 100, y: 100, x2: 250, y2: 600, x3: 900, y3: 500, r: 255 }
  tri2 = { x: 100, y: 100, x2: 700, y2: 100, x3: 900, y3: 500, b: 255 }

  # Pre-Render the triangles and their center markers
  if args.state.tick_count.zero?
    args.render_target(:static).primitives << Dinraal.raster(tri1)
    args.render_target(:static).primitives << Dinraal.outline(tri2)
    args.render_target(:static).primitives << Dinraal.center(tri1).merge(w: 5, h: 5, g: 255, primitive_marker: :solid)
    args.render_target(:static).primitives << Dinraal.center(tri2).merge(w: 5, h: 5, g: 255, primitive_marker: :solid)
  end

  # Render the triangles and their center markers
  args.outputs.sprites << { x: 0, y: 0, w: 1280, h: 720, path: :static }

  # Get the mouse position
  mouse_x = args.inputs.mouse.x
  mouse_y = args.inputs.mouse.y

  # Determine if the mouse is inside of the red triangle
  mouse_inside = Dinraal.inside?({ point_x: mouse_x, point_y: mouse_y }.merge(tri1))

  # Draw a label to display if the mouse inside the red triangle
  args.outputs.labels << { x: args.grid.center_x, y: 720, text: "Mouse inside red: #{mouse_inside}", alignment_enum: 1 }

  args.outputs.borders << Dinraal.bounding_box(tri2)

  # Optional Debug Information. Uncomment to show
  # args.outputs.debug << args.gtk.framerate_diagnostics_primitives
end
