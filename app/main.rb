require 'app/lib/dinraal.rb'

def tick(args)
  tri1 = { x: 100, y: 100, x2: 250, y2: 600, x3: 900, y3: 500, r: 255 }
  args.outputs.primitives << Dinraal.raster(tri1)

  tri2 = { x: 100, y: 100, x2: 700, y2: 100, x3: 900, y3: 500, g: 255 }
  args.outputs.primitives << Dinraal.outline(tri2)

  args.outputs.primitives << Dinraal.center(tri1).merge(w: 5, h: 5, g: 255, primitive_marker: :solid)

  args.outputs.primitives << Dinraal.center(tri2).merge(w: 5, h: 5, g: 255, primitive_marker: :solid)
end
