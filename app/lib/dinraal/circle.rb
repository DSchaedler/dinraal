module Dinraal
  # Create a filled `circle`.
  #
  # @param options [Hash]
  # @option options x [Float] Center x position.
  # @option options y [Float] Center y position.
  # @option options radius [Float] Radius of the `circle``.
  # @option options r [Integer] Optional. Color red value. Defaults to `0`.
  # @option options g [Integer] Optional. Color blue value. Defaults to `0`.
  # @option options b [Integer] Optional. Color green value. Defaults to `0`.
  # @option options a [Integer] Optional. Color alpha value. Defaults to `255`.
  #
  # @return [Array] An array of `lines` in hash notation.
  def circle(options = {})
    x = options[:x]
    y = options[:y]
    radius = options[:radius]
    diameter = radius * 2

    r = options[:r].nil? ? 0 : options[:r]
    g = options[:g].nil? ? 0 : options[:g]
    b = options[:b].nil? ? 0 : options[:b]
    a = options[:a].nil? ? 255 : options[:a]

    lines = []
    diameter.times do |i|
      h = i - radius
      l = Math.sqrt((radius * radius) - (h * h))
      lines << { x: x + i, y: y + radius - l, x2: x + i, y2: y + radius + l }.line!(r: r, g: g, b: b, a: a)
    end
    lines
  end

  # Creates the outline of a `circle` .
  #
  # @param options [Hash]
  # @option options x [Float] Center x position.
  # @option options y [Float] Center y position.
  # @option options radius [Float] Radius of the `circle` .
  # @option options r [Integer] Optional. Color red value. Defaults to `0`.
  # @option options g [Integer] Optional. Color blue value. Defaults to `0`.
  # @option options b [Integer] Optional. Color green value. Defaults to `0`.
  # @option options a [Integer] Optional. Color alpha value. Defaults to `255`.
  #
  # @return [Array] An array of `solids` in hash notation.
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
      new_pixel = point_at_distance_angle(point: { x: x, y: y },
                                          distance: radius,
                                          angle: angle)

      new_pixel[:x] = new_pixel[:x].floor
      new_pixel[:y] = new_pixel[:y].floor

      possible_pixel = { x: new_pixel[:x], y: new_pixel[:y], w: 1, h: 1,
                         r: r, g: g, b: b, a: a }.solid!

      pixels << possible_pixel unless pixels.include?(possible_pixel)
      angle += 1
    end

    pixels
  end
end

Dinraal.extend Dinraal
