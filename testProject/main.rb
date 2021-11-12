def tick(args)
  draw_triangle args, [100, 200], [120, 250], [300, 100], { g: 255, a: 50 }
  draw_triangle args, [100, 400], [140, 350], [args.mouse.x, args.mouse.y], { r: 255, a: 50 }
  draw_triangle args, [300, 400], [340, 350], [340, 400], { b: 255, a: 50 }

  args.outputs.debug << args.gtk.framerate_diagnostics_primitives
end

def draw_triangle(args, p0, p1, p2, color = {})
  args.outputs.borders << [p0, p1, p2].map do |p|
    {
      x: p.x - 4, y: p.y - 4, w: 8, h: 8
    }
  end

  all_xs = [p0.x, p1.x, p2.x]
  x_bounds = all_xs.minmax
  all_ys = [p0.y, p1.y, p2.y]
  y_bounds = all_ys.minmax
  lines = [[p0, p1], [p1, p2], [p2, p0]]

  pairs = [[p0, p1], [p1, p2], [p2, p0]]
  # we want to sweep along the "shorter" axis so that we don't have to compute as much
  # this code can definitely be simplified XD
  if (x_bounds[1] - x_bounds[0]) < (y_bounds[1] - y_bounds[0])
    # sweep along x axis
    eqns = pairs.map do |pair|
      two_point_eq(*pair)
    end

    ranges = pairs.map do |pair|
      [pair[0].x, pair[1].x].sort
    end

    args.outputs.lines << x_bounds[0].floor.upto(x_bounds[1].ceil).map do |x|
      ys = eqns.zip(ranges).map do |eqn, range|
        eqn.call(x) if x.between?(*range)
      end.compact

      y1, y2 = ys.minmax
      { x: x, y: y1, x2: x, y2: y2 }.merge(color)
    end
  else
    # sweep along y axis instead
    eqns = pairs.map do |pair|
      two_point_eq [pair[0].y, pair[0].x], [pair[1].y, pair[1].x]
    end

    ranges = pairs.map do |pair|
      [pair[0].y, pair[1].y].sort
    end

    args.outputs.lines << y_bounds[0].floor.upto(y_bounds[1].ceil).map do |y|
      xs = eqns.zip(ranges).map do |eqn, range|
        eqn.call(y) if y.between?(*range)
      end.compact

      x1, x2 = xs.minmax
      { x: x1, y: y, x2: x2, y2: y }.merge(color)
    end
  end
end

def two_point_eq(p0, p1)
  ->(x) { ((p1.y - p0.y) / (p1.x - p0.x) * (x - p0.x)) + p0.y }
end
