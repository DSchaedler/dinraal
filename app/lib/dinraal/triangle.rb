require 'app/lib/dinraal/numeric.rb'
require 'app/lib/dinraal/point.rb'
require 'app/lib/dinraal/vector.rb'

module D_Triangle
  # Determines if the given `rect` is inside of the given `triangle`.
  #
  # @param rectangle [Hash] `rect` in DR hash notation.
  # @param triangle [Hash] `triangle` in Dinraal hash notation.
  #
  # @return [Boolean] `true` or `false`
  def rectangle_inside_triangle?(rectangle:, triangle:)
    return false unless point_inside_triangle?(point: { x: rectangle[:x],                 y: rectangle[:y] }, triangle: triangle)

    return false unless point_inside_triangle?(point: { x: rectangle[:x] + rectangle[:w], y: rectangle[:y] }, triangle: triangle)

    return false unless point_inside_triangle?(point: { x: rectangle[:x],                 y: rectangle[:y] + rectangle[:h] }, triangle: triangle)

    return false unless point_inside_triangle?(point: { x: rectangle[:x] + rectangle[:w], y: rectangle[:y] + rectangle[:h] }, triangle: triangle)

    true
  end

  # Creates a filled `triangle`.
  #
  # @param options [Hash]
  # @option options x [Float]  Vertex 1 x position.
  # @option options y [Float]  Vertex 1 y position.
  # @option options x2 [Float] Vertex 2 x position.
  # @option options y2 [Float] Vertex 2 y position.
  # @option options x3 [Float] Vertex 3 x position.
  # @option options y3 [Float] Vertex 3 y position.
  # @option options r [Integer] Optional. Color red value. Defaults to `0`.
  # @option options g [Integer] Optional. Color blue value. Defaults to `0`.
  # @option options b [Integer] Optional. Color green value. Defaults to `0`.
  # @option options a [Integer] Optional. Color alpha value. Defaults to `255`.
  #
  # @return [Array] An array of `primitives` in hash notation.
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

    rt_color = { r: r, g: g, b: b, a: a }
    $rt_color_old ||= rt_color.clone

    $dinraal_have_rt ||= false
    unless rt_color == $rt_color_old && $dinraal_have_rt
      $rt_color_old = rt_color.clone

      rt_width = 1280 # Resolution of the rectangles used to generate the triangles. Higher is better, but going over 1280 is useless. Recommend 720 or 1280
      sqrt2 = Math.sqrt(2)
      square_width = rt_width * sqrt2

      args.render_target(:dinraal_solid).clear_before_render = true
      args.render_target(:dinraal_triangle_part).clear_before_render = true

      args.outputs[:dinraal_solid].w = square_width
      args.outputs[:dinraal_solid].h = square_width
      args.outputs[:dinraal_solid].solids << {
        w: square_width, h: square_width
      }.merge(rt_color)
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
    p3 = [x3, y3]

    # we want the points to be clockwise
    th1 = vector_angle(vector1: point_difference(point1: p2, point2: p1), vector2: point_difference(point1: p3, point2: p1))
    if th1 < 0
      temp_point = p2
      p2 = p3
      p3 = temp_point
    end
    points = [p1, p2, p3]

    # we want p1 -> p2 to be the longest dist
    lengths = (points + [points[0]]).each_cons(2).map do |a, b|
      point_distance_squared(point1: a, point2: b)
    end
    idx = lengths.index(lengths.max)
    p1, p2, p3 = points.rotate(lengths.index(lengths.max))[0..2]

    l1 = point_distance(point1: p1, point2: p3)
    l2 = point_distance(point1: p2, point2: p3)

    th1 = vector_angle(vector1: point_difference(point1: p2, point2: p1), vector2: point_difference(point1: p3, point2: p1))
    th2 = vector_angle(vector1: point_difference(point1: p1, point2: p2), vector2: point_difference(point1: p3, point2: p2))

    h = l1 * Math.sin(th1.abs)
    w1 = l1 * Math.cos(th1.abs)
    w2 = l2 * Math.cos(th2.abs)

    th = Math.atan2(p2.y - p1.y, p2.x - p1.x)

    primitives = []

    primitives << {
      x: p1.x, y: p1.y,
      w: w1, h: h,
      angle_anchor_x: 0, angle_anchor_y: 0,
      flip_horizontally: true,
      path: :dinraal_triangle_part,
      angle: th * 180 / Math::PI
    }.sprite!
    primitives << {
      x: p1.x + (w1 * Math.cos(th)), y: p1.y + (w1 * Math.sin(th)),
      angle_anchor_x: 0, angle_anchor_y: 0,
      w: w2, h: h,
      path: :dinraal_triangle_part,
      angle: th * 180 / Math::PI
    }.sprite!

    primitives << {
      x: p1.x + (w1 * Math.cos(th)) + 0.5, y: p1.y + (w1 * Math.sin(th)) + 0.5,
      x2: p3.x + 0.5, y2: p3.y + 0.5
    }.line!(rt_color)
    primitives << {
      x: p1.x + (w1 * Math.cos(th)) - 0.5, y: p1.y + (w1 * Math.sin(th)) - 0.5,
      x2: p3.x - 0.5, y2: p3.y - 0.5
    }.line!(rt_color)
    primitives << {
      x: p1.x + (w1 * Math.cos(th)) + 0.5, y: p1.y + (w1 * Math.sin(th)) - 0.5,
      x2: p3.x + 0.5, y2: p3.y - 0.5
    }.line!(rt_color)
    primitives << {
      x: p1.x + (w1 * Math.cos(th)) - 0.5, y: p1.y + (w1 * Math.sin(th)) + 0.5,
      x2: p3.x - 0.5, y2: p3.y + 0.5
    }.line!(rt_color)

    primitives
  end

  # Calculates a `border` for the bounding box of the given `triangle`.
  #
  # @param options [Hash]
  # @option options x [Float]  Vertex 1 x position.
  # @option options y [Float]  Vertex 1 y position.
  # @option options x2 [Float] Vertex 2 x position.
  # @option options y2 [Float] Vertex 2 y position.
  # @option options x3 [Float] Vertex 3 x position.
  # @option options y3 [Float] Vertex 3 y position.
  #
  # @return [Hash] A DR `border` hash.
  def triangle_bounding_box(options = {})
    x = options[:x]
    y = options[:y]
    x2 = options[:x2]
    y2 = options[:y2]
    x3 = options[:x3]
    y3 = options[:y3]

    x_min = [x, x2, x3].min
    x_max = [x, x2, x3].max

    y_min = [y, y2, y3].min
    y_max = [y, y2, y3].max

    { x: x_min, y: y_min, w: x_max - x_min, h: y_max - y_min }.border!
  end

  # Calculates the center `point` of the given `triangle`.
  #
  # @param options [Hash]
  # @option options x [Float]  Vertex 1 x position.
  # @option options y [Float]  Vertex 1 y position.
  # @option options x2 [Float] Vertex 2 x position.
  # @option options y2 [Float] Vertex 2 y position.
  # @option options x3 [Float] Vertex 3 x position.
  # @option options y3 [Float] Vertex 3 y position.
  #
  # @return [Hash] A DR `point` hash.
  def triangle_center(options = {})
    x = options[:x]
    y = options[:y]
    x2 = options[:x2]
    y2 = options[:y2]
    x3 = options[:x3]
    y3 = options[:y3]

    { x: ((x + x2 + x3) / 3).to_i, y: ((y + y2 + y3) / 3).to_i }
  end

  # Determines if the `inner` `triangle` is contained by the `outer` `triangle`.
  #
  # @param inner [Hash] `triangle` in Dinraal hash notation.
  # @param outer [Hash] `triangle` in Dinraal hash notation.
  #
  # @return [Boolean] `true` or `false`
  def triangle_inside_triangle?(inner:, outer:)
    # Return true if tri1 is contained by tri2
    return false unless point_inside_triangle?(point: { x: inner[:x], y: inner[:y] }, triangle: outer)

    return false unless point_inside_triangle?(point: { x: inner[:x2], y: inner[:y2] }, triangle: outer)

    return false unless point_inside_triangle?(point: { x: inner[:x3], y: inner[:y3] }, triangle: outer)

    true
  end

  # Creates the outline of a `triangle`.
  #
  # @param options [Hash]
  # @option options x [Float]  Vertex 1 x position.
  # @option options y [Float]  Vertex 1 y position.
  # @option options x2 [Float] Vertex 2 x position.
  # @option options y2 [Float] Vertex 2 y position.
  # @option options x3 [Float] Vertex 3 x position.
  # @option options y3 [Float] Vertex 3 y position.
  # @option options r [Integer] Color red value.
  # @option options g [Integer] Color blue value.
  # @option options b [Integer] Color green value.
  # @option options a [Integer] Color alpha value.
  #
  # @return [Array] An array of `solids` in hash notation.
  def triangle_outline(options = {})
    x = options[:x]
    y = options[:y]
    x2 = options[:x2]
    y2 = options[:y2]
    x3 = options[:x3]
    y3 = options[:y3]
    r = options[:r]
    g = options[:g]
    b = options[:b]
    a = options[:a]

    lines = []
    lines << { x: x, y: y, x2: x2, y2: y2, r: r, g: g, b: b, a: a }.line!
    lines << { x: x3, y: y3, x2: x2, y2: y2, r: r, g: g, b: b, a: a }.line!
    lines << { x: x, y: y, x2: x3, y2: y3, r: r, g: g, b: b, a: a }.line!
    lines
  end

  # Creates a filled `triangle` using the raster method.
  #
  # @param options [Hash]
  # @option options x [Float]  Vertex 1 x position.
  # @option options y [Float]  Vertex 1 y position.
  # @option options x2 [Float] Vertex 2 x position.
  # @option options y2 [Float] Vertex 2 y position.
  # @option options x3 [Float] Vertex 3 x position.
  # @option options y3 [Float] Vertex 3 y position.
  # @option options r [Integer] Optional. Color red value. Defaults to `0`.
  # @option options g [Integer] Optional. Color blue value. Defaults to `0`.
  # @option options b [Integer] Optional. Color green value. Defaults to `0`.
  # @option options a [Integer] Optional. Color alpha value. Defaults to `255`.
  # @option options path [String] Optional. Image path. Defaults to `'pixel'`.
  # @option options image_width [Float] Optional. Image width. Defaults to `triangle` width.
  #
  # @return [Array] An array of `solids` in hash notation.
  def triangle_raster(options = {})
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

    path = options[:path].nil? ? 'pixel' : options[:path]

    image_width = options[:image_width].nil? ? [x, x2, x3].max - [x, x2, x3].min : options[:image_width]

    args = $gtk.args
    triangle = [[x, y], [x2, y2], [x3, y3]]
    triangle = triangle.sort_by { |point| point[1] }
    triangle = triangle.reverse

    line_slope = args.geometry.line_slope([triangle[0][0], triangle[0][1], triangle[2][0], triangle[2][1]], replace_infinity: 1080)
    x_intercept = triangle[0][1] - (line_slope * triangle[0][0])

    vertex4 = [(triangle[1][1] - x_intercept) / line_slope, triangle[1][1]]

    leg0 = [triangle[0], triangle[1]]
    leg0_slope = args.geometry.line_slope(leg0.flatten, replace_infinity: 1080)
    leg0_intercept = triangle[0][1] - (leg0_slope * triangle[0][0])

    leg1 = [triangle[0], vertex4]
    leg1_slope = args.geometry.line_slope(leg1.flatten, replace_infinity: 1080)
    leg1_intercept = triangle[0][1] - (leg1_slope * triangle[0][0])

    leg2 = [triangle[1], triangle[2]]
    leg2_slope = args.geometry.line_slope(leg2.flatten, replace_infinity: 1080)
    leg2_intercept = triangle[2][1] - (leg2_slope * triangle[2][0])

    leg3 = [vertex4, triangle[2]]
    leg3_slope = args.geometry.line_slope(leg3.flatten, replace_infinity: 1080)
    leg3_intercept = triangle[2][1] - (leg3_slope * triangle[2][0])

    raster_lines = []

    x_offset = [x, x2, x3].min
    y_offset = [y, y2, y3].min

    y_iter = triangle[0][1]
    while y_iter >= vertex4[1]
      start_x = (y_iter - leg0_intercept) / leg0_slope
      end_x = (y_iter - leg1_intercept) / leg1_slope

      sort_list = [start_x, end_x].sort
      small_x = sort_list[0]
      big_x = sort_list[1]

      start_x = small_x
      end_x = big_x

      draw_width = end_x - x_offset > image_width ? image_width - start_x + x_offset : end_x - start_x

      grab = draw_width.abs
      raster_lines << {
        x: start_x,
        y: y_iter,
        w: draw_width,
        h: 1,
        r: r, g: g, b: b, a: a,
        path: path,
        source_x: start_x - x_offset, source_y: y_iter - y_offset,
        source_w: grab, source_h: 1
      }.sprite!
      y_iter -= 1
    end

    y_iter = vertex4[1]
    while y_iter >= triangle[2][1]
      start_x = (y_iter - leg2_intercept) / leg2_slope
      end_x = (y_iter - leg3_intercept) / leg3_slope

      sort_list = [start_x, end_x].sort
      small_x = sort_list[0]
      big_x = sort_list[1]

      start_x = small_x
      end_x = big_x

      draw_width = end_x - x_offset > image_width ? image_width - start_x + x_offset : end_x - start_x

      grab = draw_width.abs
      raster_lines << {
        x: start_x,
        y: y_iter,
        w: draw_width,
        h: 1,
        r: r, g: g, b: b, a: a,
        path: path,
        source_x: start_x - x_offset, source_y: y_iter - y_offset,
        source_w: grab, source_h: 1
      }.sprite
      y_iter -= 1
    end
    raster_lines
  end

  # A faster method for drawing raster triangles. Does not support images
  #
  # @param options [Hash]
  # @option options x [Float]  Vertex 1 x position.
  # @option options y [Float]  Vertex 1 y position.
  # @option options x2 [Float] Vertex 2 x position.
  # @option options y2 [Float] Vertex 2 y position.
  # @option options x3 [Float] Vertex 3 x position.
  # @option options y3 [Float] Vertex 3 y position.
  # @option options r [Integer] Optional. Color red value. Defaults to `0`.
  # @option options g [Integer] Optional. Color blue value. Defaults to `0`.
  # @option options b [Integer] Optional. Color green value. Defaults to `0`.
  # @option options a [Integer] Optional. Color alpha value. Defaults to `255`.
  #
  # @return [Array] An array of `lines` in hash notation.
  def triangle_raster_fast(options = {})
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

    all_xs = [x, x2, x3]
    x_bounds = all_xs.minmax
    all_ys = [y, y2, y3]
    y_bounds = all_ys.minmax

    pairs = [[{ x: x, y: y }, { x: x2, y: y2 }], [{ x: x2, y: y2 }, { x: x3, y: y3 }], [{ x: x3, y: y3 }, { x: x, y: y }]]

    lines = []

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

      lines << x_bounds[0].floor.upto(x_bounds[1].ceil).map do |x|
        ys = eqns.zip(ranges).map do |eqn, range|
          eqn.call(x) if x.between?(*range)
        end.compact

        y1, y2 = ys.minmax
        { x: x, y: y1, x2: x, y2: y2 }.merge(color).line!
      end
    else
      # sweep along y axis instead
      eqns = pairs.map do |pair|
        two_point_eq [pair[0].y, pair[0].x], [pair[1].y, pair[1].x]
      end

      ranges = pairs.map do |pair|
        [pair[0].y, pair[1].y].sort
      end

      lines << y_bounds[0].floor.upto(y_bounds[1].ceil).map do |y|
        xs = eqns.zip(ranges).map do |eqn, range|
          eqn.call(y) if y.between?(*range)
        end.compact

        x1, x2 = xs.minmax
        { x: x1, y: y, x2: x2, y2: y }.merge(color).line!
      end
    end
    lines
  end
end

Dinraal.extend D_Triangle
