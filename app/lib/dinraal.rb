# frozen_string_literal: true

require 'app/lib/dinraal/circle'
require 'app/lib/dinraal/numeric'
require 'app/lib/dinraal/point'
require 'app/lib/dinraal/triangle'
require 'app/lib/dinraal/vector'

# Module provides methods for manipulating shapes to DragonRuby Game Toolkit.
# By D Schaedler. Released under MIT License.
# https://github.com/DSchaedler/dinraal
module Dinraal
  def hsv_to_rgb(h, s, v)
    # based on conversion listed here: https://www.rapidtables.com/convert/color/hsv-to-rgb.html
    h = h % 360

    c = v * s
    x = c * (1 - (((h / 60) % 2) - 1).abs)
    m = v - c

    rp, gp, bp = [
      [c, x, 0], #   0 < h <  60
      [x, c, 0], #  60 < h < 120
      [0, c, x], # 120 < h < 180
      [0, x, c], # 180 < h < 240
      [x, 0, c], # 240 < h < 300
      [c, 0, x]  # 300 < h < 360
    ][h / 60]

    {
      r: (rp + m) * 255,
      g: (gp + m) * 255,
      b: (bp + m) * 255
    }
  end
end

Dinraal.extend Dinraal
