def tick args
  draw_fast_triangle({x: 300, y: 100, x2: 900, y2: 200, x3: 500, y3: 400 })
  draw_fast_triangle( {x: 700, y: 700, x2: args.mouse.x, y2: args.mouse.y, x3: 500, y3:500} )

  args.outputs.debug << args.gtk.framerate_diagnostics_primitives
end

def point_distance(point1:, point2:)
  dx = point2.x - point1.x
  dy = point2.y - point1.y
  Math::sqrt(dx * dx + dy * dy)
end

def point_distance_squared(point1:, point2:)
  dx = point2.x - point1.x
  dy = point2.y - point1.y
  dx * dx + dy * dy
end

def point_difference(point1:, point2:)
  {x: point1.x - point2.x, y: point1.y - point2.y}
end

def vector_angle v1, v2
  Math::acos(vector_dot_product(v1, v2) / (vector_normal(v1) * vector_normal(v2))) * numeric_sign(vector_dot_product(v1, v2))
end

def vector_normal vec
  Math::sqrt(vec.x * vec.x + vec.y * vec.y)
end

def vector_dot_product v1, v2
  v1.x * v2.x + v1.y * v2.y
end

def vector_dot_product v1, v2
  v1.x * v2.y - v2.x * v1.y
end

def numeric_sign v
  v <=> 0
end

def draw_fast_triangle(options = {})
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

  color = { r: r, g: g, b: b, a: a }

  $dinraal_have_rt ||= false
  unless $dinraal_have_rt
    rt_width = 1280
    sqrt2 = Math::sqrt(2)
    square_width = rt_width * sqrt2
  
    args.outputs[:dinraal_solid].w = square_width
    args.outputs[:dinraal_solid].h = square_width
    args.outputs[:dinraal_solid].solids << {
      w: square_width, h: square_width
    }
    args.outputs[:dinraal_triangle_part].w = rt_width
    args.outputs[:dinraal_triangle_part].h = rt_width
    args.outputs[:dinraal_triangle_part].sprites << {
      x: -rt_width / sqrt2, y: -rt_width / sqrt2,
      w: square_width, h: square_width,
      angle: 45, path: :dinraal_solid
    }
    $dinraal_have_rt = true
  end

  p1 = [x, y]
  p2 = [x2, y2]
  p3 = [x3. y3]

  # we want the points to be clockwise
  th1 = vector_angle( vector1: point_difference(point1: p2, point2: p1), vector2: point_difference(point1: p3, point2: p1) )
  if th1 < 0
    temp_point = p2
    p2 = p3
    p3 = temp_point
  end
  points = [p1, p2, p3]

  # we want p1 -> p2 to be the longest dist
  lengths = (points + [points[0]]).each_cons(2).map do |a, b|
    point_distance_squared a, b
  end
  idx = lengths.index(lengths.max)
  p1, p2, p3 = points.rotate(lengths.index(lengths.max))[0..2]

  l1 = point_distance p1, p3
  l2 = point_distance p2, p3

  th1 = vector_angle point_difference(p2, p1), point_difference(p3, p1)
  th2 = vector_angle point_difference(p1, p2), point_difference(p3, p2)

  h = l1 * Math::sin(th1.abs)
  w1 = l1 * Math::cos(th1.abs)
  w2 = l2 * Math::cos(th2.abs)

  th = Math::atan2(p2.y - p1.y, p2.x - p1.x)

  args.outputs.sprites << {
    x: p1.x, y: p1.y,
    w: w1, h: h,
    angle_anchor_x: 0, angle_anchor_y: 0,
    flip_horizontally: true,
    path: :dinraal_triangle_part,
    angle: th * 180 / Math::PI
  }
  args.outputs.sprites << {
    x: p1.x + w1 * Math::cos(th), y: p1.y + w1 * Math::sin(th),
    angle_anchor_x: 0, angle_anchor_y: 0,
    w: w2, h: h,
    path: :dinraal_triangle_part,
    angle: th * 180 / Math::PI
  }

  args.outputs.lines << {
    x: p1.x + w1 * Math::cos(th) + 0.5, y: p1.y + w1 * Math::sin(th) + 0.5,
    x2: p3.x + 0.5, y2: p3.y + 0.5
  }
  args.outputs.lines << {
    x: p1.x + w1 * Math::cos(th) - 0.5, y: p1.y + w1 * Math::sin(th) - 0.5,
    x2: p3.x - 0.5, y2: p3.y - 0.5
  }
  args.outputs.lines << {
    x: p1.x + w1 * Math::cos(th) + 0.5, y: p1.y + w1 * Math::sin(th) - 0.5,
    x2: p3.x + 0.5, y2: p3.y - 0.5
  }
  args.outputs.lines << {
    x: p1.x + w1 * Math::cos(th) - 0.5, y: p1.y + w1 * Math::sin(th) + 0.5,
    x2: p3.x - 0.5, y2: p3.y + 0.5
  }
end