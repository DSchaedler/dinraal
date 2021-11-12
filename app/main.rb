def tick args
  #draw_triangle args, [100, 400], [140, 350], [args.mouse.x, args.mouse.y], { r: 255, a: 50 }
  triangle({x: 100, y: 400, x2: 140, y2: 350, x3: args.mouse.x, y3: args.mouse.y})

  args.outputs.debug << args.gtk.framerate_diagnostics_primitives
end

def triangle(options = {})
  args = $gtk.args

  x = options[:x]
  y = options[:y]
  x2 = options[:x2]
  y2 = options[:y2]
  x3 = options[:x3]
  y3 = options[:y3]

  r = options[:r].nil? ? 0 : options[:r]
  g = options[:g].nil? ? 0 : options[:g]
  b = options[:b].nil? ? 0 : options[:b]
  a = options[:a].nil? ? 255 : options[:a]

  color = {r: r, g: g, b: b, a: a}

  path = options[:path].nil? ? 'pixel' : options[:path]
  image_width = options[:image_width].nil? ? [x, x2, x3].max - [x, x2, x3].min : options[:image_width]

  all_xs = [x, x2, x3]
  x_bounds = all_xs.minmax
  all_ys = [y, y2, y3]
  y_bounds = all_ys.minmax
  lines = [[{x: x, y: y}, {x: x2, y: y2}], [{x: x2, y: y2}, {x: x3, y: y3}], [{x: x3, y: y3}, {x: x2, y: y2}]]
  
  pairs = [[{x: x, y: y}, {x: x2, y: y2}], [{x: x2, y: y2}, {x: x3, y: y3}], [{x: x3, y: y3}, {x: x2, y: y2}]]

  # we want to sweep along the "shorter" axis so that we don't have to compute as much
  # this code can definitely be simplified XD
  if (x_bounds[1] - x_bounds[0]) < (y_bounds[1] - y_bounds[0])
    # sweep along x axis
    eqns = pairs.map do |pair|
      two_point_eq *pair
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

def draw_triangle args, p0, p1, p2, color = {}

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
      two_point_eq *pair
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

def two_point_eq p0, p1
  -> (x) { (p1.y - p0.y) / (p1.x - p0.x) * (x - p0.x) + p0.y }
end