module Circle
  def raster_outline(options = {})
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

      pixels << { x: new_pixel[:x], y: new_pixel[:y], w: 1, h: 1, r: r, g: g, b: b, a: a }.solid! unless pixels.include?({ x: new_pixel[:x], y: new_pixel[:y], w: 1, h: 1, r: r, g: g, b: b, a: a }.solid!)
      angle += 1
    end

    pixels
  end

  def raster(options = {})
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
        pixels[x_min][y_min] = { x: x_min, y: y_min, w: 1, h: 1, r: r, g: g, b: b, a: a }.solid! if args.geometry.point_inside_circle?({ x: x_min, y: y_min }, { x: x, y: y }, radius)
        y_min += 1
      end
      x_min += 1
    end
    pixels
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
end

Circle.extend Circle
