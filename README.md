# dinraal

[![Ruby - Rubocop](https://github.com/DSchaedler/dinraal/actions/workflows/rubocop.yml/badge.svg?branch=main)](https://github.com/DSchaedler/dinraal/actions/workflows/rubocop.yml)

Dinraal is a library for working with shapes in DragonRuby Game Toolkit. By default, DRGTK does not support rendering or working with any shapes outside of rectangles. Until now, other shapes have been provided by sprites.

Full Documentation can be found at https://dschaedler.github.io/dinraal/

---

Our killer feature is the `triangle_raster` method. This returns an array of primitives ready to be drawn.

```ruby
require 'app/lib/dinraal.rb'

def tick args
  if args.state.tick_count.zero?
    triangle = { x: 100, y: 100, x2: 250, y2: 400, x3: 600, y3: 200 }
    args.outputs.static_primitives << Dinraal.triangle_raster( triangle )
  end
end
```

The library source file can be found at [app/lib/dinraal.rb](https://github.com/DSchaedler/dinraal/blob/main/app/lib/dinraal.rb).

A more detailed sample app is at [app/main.rb](https://github.com/DSchaedler/dinraal/blob/main/app/main.rb).

Triangles are defined as a hash of points, with any additional information.

```ruby
{ x: point1_x, y: point1_y, x2: point2_x, y2: point2_y, x3: point3_x, y3: point3_y, r: red, g: green, b: blue, a: alpha }
```

# TODO
- Document new circle methods
- Alphabetize methods in `dinrall.rb`
- Create `triangle_intersects_triangle?` method
- Create `rectangle_intersects_triangle?` method
- Create `triangle_inradius` method - [Incircle Math Breakdown](https://artofproblemsolving.com/wiki/index.php/Incircle)
- Create `triangle_area` method - [Heron's Formula](https://artofproblemsolving.com/wiki/index.php/Heron%27s_Formula)
  - Vector based calculations will be faster, but less straightforward to impliment
- Create `triangle_perimiter` method

# How to contribute
- Submit a Pull Request with any code improvements
- Impliment any item from the TODO list.
- Write a sample app that more clearly shows all methods
- Write a tutorial
- Submit improved calculation methods
  - Speed improvements to the `triangle_raster` and `circle_raster` methods
  - Vector calculations for area over Heron's Formula

# About Dinraal
Dinraal is created by Dee Schaedler. Many thanks to the DragonRuby Discord server for inspiration and feedback. https://discord.dragonruby.org

Specific thanks to:
- leviondiscord#5978    - Optimization contribution
- theanxietybuster#8491 - Catching a project-ending typo

Most DragonRuby packages and libraries are named after various dragons. Dinraal is a [Japanese Dragon](https://en.wikipedia.org/wiki/Japanese_dragon) from [The Legend of Zelda: Breath of the Wild](https://en.wikipedia.org/wiki/The_Legend_of_Zelda:_Breath_of_the_Wild). Dinraal is the dragon of fire, and the gatekeeper of the Shrine at the [Spring of Power](https://zelda.fandom.com/wiki/Spring_of_Power).
