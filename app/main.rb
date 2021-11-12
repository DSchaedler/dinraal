def tick args
  create_rt args if args.state.tick_count.zero?
  draw_fast_triangle args, [300, 100], [900, 200], [500, 400]
  draw_fast_triangle args, [700, 700], [args.mouse.x, args.mouse.y], [500, 500]

  args.outputs.debug << args.gtk.framerate_diagnostics_primitives
end

def point_distance p1, p2
  dx = p2.x - p1.x
  dy = p2.y - p1.y
  Math::sqrt(dx * dx + dy * dy)
end

def point_distance_squared p1, p2
  dx = p2.x - p1.x
  dy = p2.y - p1.y
  dx * dx + dy * dy
end

def point_difference p1, p2
  [p1.x - p2.x, p1.y - p2.y]
end

def vertex_angle v1, v2
  Math::acos(dot(v1, v2) / (norm(v1) * norm(v2))) * sign(cross(v1, v2))
end

def vector_normal vec
  Math::sqrt(vec.x * vec.x + vec.y * vec.y)
end

def vertex_dot_product v1, v2
  v1.x * v2.x + v1.y * v2.y
end

def vertex_cross_product v1, v2
  v1.x * v2.y - v2.x * v1.y
end

def numeric_sign v
  v <=> 0
end

def draw_fast_triangle args, p1, p2, p3
  args.outputs.borders << [p1, p2, p3].map do |p|
    {
      x: p.x - 4, y: p.y - 4, w: 8, h: 8, r: 255
    }
  end

  # we want the points to be clockwise
  th1 = vertex_angle point_difference(p2, p1), point_difference(p3, p1)
  if th1 < 0
    tmp_p = p2
    p2 = p3
    p3 = tmp_p
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

  th1 = vertex_angle point_difference(p2, p1), point_difference(p3, p1)
  th2 = vertex_angle point_difference(p1, p2), point_difference(p3, p2)

  h = l1 * Math::sin(th1.abs)
  w1 = l1 * Math::cos(th1.abs)
  w2 = l2 * Math::cos(th2.abs)

  th = Math::atan2(p2.y - p1.y, p2.x - p1.x)

  args.outputs.sprites << {
    x: p1.x, y: p1.y,
    w: w1, h: h,
    angle_anchor_x: 0, angle_anchor_y: 0,
    flip_horizontally: true,
    path: :triangle_part,
    angle: th * 180 / Math::PI
  }
  args.outputs.sprites << {
    x: p1.x + w1 * Math::cos(th), y: p1.y + w1 * Math::sin(th),
    angle_anchor_x: 0, angle_anchor_y: 0,
    w: w2, h: h,
    path: :triangle_part,
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

def create_rt args
  w = 720
  rt2 = Math::sqrt(2)
  sq_w = w * rt2
  args.outputs[:solid].w = sq_w
  args.outputs[:solid].h = sq_w
  args.outputs[:solid].solids << {
    w: sq_w, h: sq_w
  }
  args.outputs[:triangle_part].w = w
  args.outputs[:triangle_part].h = w
  args.outputs[:triangle_part].sprites << {
    x: -w / rt2, y: -w / rt2,
    w: sq_w, h: sq_w,
    angle: 45,
    path: :solid
  }
end