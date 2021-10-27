# Module provides some Triangle generation and manipulation methods to DragonRuby Game Toolkit.
# By D Schaedler. Released under MIT License.
# https://github.com/DSchaedler/dinraal
module Dinraal
  def center(options = {})
    x = options[:x]
    y = options[:y]
    x2 = options[:x2]
    y2 = options[:y2]
    x3 = options[:x3]
    y3 = options[:y3]

    { x: ((x + x2 + x3) / 3).to_i, y: ((y + y2 + y3) / 3).to_i }
  end

  def inside?(options = {})
    args = $gtk.args

    point_x = options[:point_x]
    point_y = options[:point_y]
    x = options[:x]
    y = options[:y]
    x2 = options[:x2]
    y2 = options[:y2]
    x3 = options[:x3]
    y3 = options[:y3]

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

  def outline(options = {})
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

  def raster(options = {})
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
end

Dinraal.extend Dinraal
