module D_Point
  # Calculates a new `point` given a starting `point`, distance, and angle.
  #
  # @param options [Hash]
  # @option options point [Hash] `point` in DR hash notation.
  # @option options distance [Float] Distance between the given and generated point.
  # @option options angle [Float] Angle from given `point` to generated `point` in degrees.
  #
  # @return [Hash] `point` in DR hash notation.
  def point_at_distance_angle(options = {})
    point = options[:point]
    distance = options[:distance]
    angle = options[:angle]

    new_point = {}

    new_point[:x] = (distance * Math.cos(angle * Math::PI / 180)) + point[:x]
    new_point[:y] = (distance * Math.sin(angle * Math::PI / 180)) + point[:y]
    new_point
  end

  # Calculates the difference between two points
  #
  # @param point1: [Array] A `point` in array notation
  # @param point2: [Array] A `point` in array notation
  #
  # @return [Array] An array with the x difference as `[0]` and the y distance as `[1]`
  def point_difference(point1:, point2:)
    [point1.x - point2.x, point1.y - point2.y]
  end

  # Calculates the distance between two points
  #
  # @param point1: [Array] A `point` in array notation
  # @param point2: [Array] A `point` in array notation
  #
  # @return [Float]
  def point_distance(point1:, point2:)
    dx = point2.x - point1.x
    dy = point2.y - point1.y
    Math.sqrt((dx * dx) + (dy * dy))
  end

  # Calculates the distance squared between two points
  #
  # @param point1: [Array] A `point` in array notation
  # @param point2: [Array] A `point` in array notation
  #
  # @return [Float]
  def point_distance_squared(point1:, point2:)
    dx = point2.x - point1.x
    dy = point2.y - point1.y
    (dx * dx) + (dy * dy)
  end

  # Determines if the given `point` is in the given `triangle`.
  #
  # @param point [Hash]  `point` in DR hash notation.
  # @param triangle [Hash] `triangle` in Dinraal hash notation.
  #
  # @return [Boolean] `true` or `false`
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
    triangle = triangle.sort_by { |sort_point| sort_point[1] }
    triangle = triangle.reverse

    leg0 = [triangle[0], triangle[1]]
    leg0_slope = args.geometry.line_slope(leg0.flatten, replace_infinity: 1080)
    leg0_intercept = triangle[0][1] - (leg0_slope * triangle[0][0])

    return false unless point_y <= (leg0_slope * point_x) + leg0_intercept

    leg1 = [triangle[0], triangle[2]]
    leg1_slope = args.geometry.line_slope(leg1.flatten, replace_infinity: 1080)
    leg1_intercept = triangle[0][1] - (leg1_slope * triangle[0][0])

    return false unless point_y <= (leg1_slope * point_x) + leg1_intercept

    leg2 = [triangle[1], triangle[2]]
    leg2_slope = args.geometry.line_slope(leg2.flatten, replace_infinity: 1080)
    leg2_intercept = triangle[2][1] - (leg2_slope * triangle[2][0])

    return false unless point_y >= (leg2_slope * point_x) + leg2_intercept

    true
  end

  #
  #
  # @param p0 [Array] A `point` in array notation
  # @param p1 [Array] A `point` in array notation
  #
  # @return []
  def two_point_eq(p0, p1)
    ->(x) { ((p1.y - p0.y) / (p1.x - p0.x) * (x - p0.x)) + p0.y }
  end
end

D_Point.extend Dinraal
