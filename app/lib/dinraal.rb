# Module provides some Triangle generation and manipulation methods to DragonRuby Game Toolkit.
# By D Schaedler. Released under MIT License.
# https://github.com/DSchaedler/dinraal
module Dinraal
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

  def triangle_center(options = {})
    x = options[:x]
    y = options[:y]
    x2 = options[:x2]
    y2 = options[:y2]
    x3 = options[:x3]
    y3 = options[:y3]

    { x: ((x + x2 + x3) / 3).to_i, y: ((y + y2 + y3) / 3).to_i }
  end

  def circle_outline(options = {})
    x = options[:x]
    y = options[:y]
    radius = options[:radius]

    r = options[:r]
    g = options[:g]
    b = options[:b]
    a = options[:a]

    pixels = []

    angle = 0
    while angle < 360
      new_pixel = point_at_distance_angle(point: { x: x, y: y }, distance: radius, angle: angle)

      new_pixel[:x] = new_pixel[:x].floor
      new_pixel[:y] = new_pixel[:y].floor

      possible_pixel = { x: new_pixel[:x], y: new_pixel[:y], w: 1, h: 1, r: r, g: g, b: b, a: a }.solid!

      pixels << possible_pixel unless pixels.include?(possible_pixel)
      angle += 1
    end

    pixels
  end

  def circle_raster(options = {})
    args = $gtk.args

    x = options[:x].floor
    y = options[:y].floor
    radius = options[:radius]

    r = options[:r]
    g = options[:g]
    b = options[:b]
    a = options[:a]

    x_min = x - radius.floor
    x_max = x + radius.floor

    y_min = y - radius.floor
    y_max = y + radius.floor

    pixels = []

    while x_min <= x_max
      pixels[x_min] ||= []
      y_min = y - radius
      while y_min <= y_max
        possible_pixel = { x: x_min, y: y_min, w: 1, h: 1, r: r, g: g, b: b, a: a }.solid!
        pixels[x_min][y_min] = possible_pixel if args.geometry.point_inside_circle?({ x: x_min, y: y_min }, { x: x, y: y }, radius)
        y_min += 1
      end
      x_min += 1
    end
    pixels
  end

  def point_inside_triangle?(point:, triangle:)
    args = $gtk.args

    point_x = point[:x]
    point_y = point[:y]
    x = triangle[:x]
    y = triangle[:y]
    x2 = triangle[:x2]
    y2 = triangle[:y2]
    x3 = triangle[:x3]
    y3 = triangle[:y3]

    triangle = [[x, y], [x2, y2], [x3, y3]]
    triangle = triangle.sort_by { |point| point[1] }
    triangle = triangle.reverse

    leg0 = [triangle[0], triangle[1]]
    leg0_slope = args.geometry.line_slope(leg0.flatten)
    leg0_intercept = triangle[0][1] - (leg0_slope * triangle[0][0])

    return false unless point_y <= leg0_slope * point_x + leg0_intercept

    leg1 = [triangle[0], triangle[2]]
    leg1_slope = args.geometry.line_slope(leg1.flatten)
    leg1_intercept = triangle[0][1] - (leg1_slope * triangle[0][0])

    return false unless point_y <= leg1_slope * point_x + leg1_intercept

    leg2 = [triangle[1], triangle[2]]
    leg2_slope = args.geometry.line_slope(leg2.flatten)
    leg2_intercept = triangle[2][1] - (leg2_slope * triangle[2][0])

    return false unless point_y >= leg2_slope * point_x + leg2_intercept

    true
  end

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

  def point_at_distance_angle(options = {})
    point = options[:point]
    distance = options[:distance]
    angle = options[:angle]

    new_point = {}

    new_point[:x] = (distance * Math.cos(angle * Math::PI / 180)) + point[:x]
    new_point[:y] = (distance * Math.sin(angle * Math::PI / 180)) + point[:y]
    new_point
  end

  def triangle_raster(options = {})
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

    args = $gtk.args
    triangle = [[x, y], [x2, y2], [x3, y3]]
    triangle = triangle.sort_by { |point| point[1] }
    triangle = triangle.reverse

    line_slope = args.geometry.line_slope [triangle[0][0], triangle[0][1], triangle[2][0], triangle[2][1]]
    x_intercept = triangle[0][1] - (line_slope * triangle[0][0])

    vertex4 = [(triangle[1][1] - x_intercept) / line_slope, triangle[1][1]]

    leg0 = [triangle[0], triangle[1]]
    leg0_slope = args.geometry.line_slope(leg0.flatten)
    leg0_intercept = triangle[0][1] - (leg0_slope * triangle[0][0])

    leg1 = [triangle[0], vertex4]
    leg1_slope = args.geometry.line_slope(leg1.flatten)
    leg1_intercept = triangle[0][1] - (leg1_slope * triangle[0][0])

    leg2 = [triangle[2], triangle[1]]
    leg2_slope = args.geometry.line_slope(leg2.flatten)
    leg2_intercept = triangle[2][1] - (leg2_slope * triangle[2][0])

    leg3 = [triangle[2], vertex4]
    leg3_slope = args.geometry.line_slope(leg3.flatten)
    leg3_intercept = triangle[2][1] - (leg3_slope * triangle[2][0])

    raster_lines = []

    y_iter = triangle[0][1]
    while y_iter >= vertex4[1]
      raster_lines << {
        x: (y_iter - leg0_intercept) / leg0_slope,
        y: y_iter,
        x2: (y_iter - leg1_intercept) / leg1_slope,
        y2: y_iter,
        r: r, g: g, b: b, a: a
      }.line!
      y_iter -= 1
    end

    y_iter = triangle[2][1]
    while y_iter <= vertex4[1]
      raster_lines << {
        x: (y_iter - leg2_intercept) / leg2_slope,
        y: y_iter,
        x2: (y_iter - leg3_intercept) / leg3_slope,
        y2: y_iter,
        r: r, g: g, b: b, a: a
      }.line!
      y_iter += 1
    end
    raster_lines
  end

  def rectangle_inside_triangle?(rectangle:, triangle:)
    return false unless point_inside_triangle?(point: { x: rectangle[:x],                 y: rectangle[:y] }, triangle: triangle)
    return false unless point_inside_triangle?(point: { x: rectangle[:x] + rectangle[:w], y: rectangle[:y] }, triangle: triangle)
    return false unless point_inside_triangle?(point: { x: rectangle[:x],                 y: rectangle[:y] + rectangle[:h] }, triangle: triangle)
    return false unless point_inside_triangle?(point: { x: rectangle[:x] + rectangle[:w], y: rectangle[:y] + rectangle[:h] }, triangle: triangle)
    true
  end

  def triangle_inside_triangle?(inner:, outer:)
    # Return true if tri1 is contained by tri2
    return false unless point_inside_triangle?(point: { x: inner[:x], y: inner[:y] }, triangle: outer)
    return false unless point_inside_triangle?(point: { x: inner[:x2], y: inner[:y2] }, triangle: outer)
    return false unless point_inside_triangle?(point: { x: inner[:x3], y: inner[:y3] }, triangle: outer)
    true
  end
end

Dinraal.extend Dinraal
