# dinraal

Dinraal is a library for working with triangles in DragonRuby Game Toolkit. By default, DRGTK does not support rendering or working with triangles.

Our killer feature is the `raster` method. This returns an array of primitives ready to be drawn.

```ruby
require 'app/lib/dinraal.rb'

def tick args
  if args.state.tick_count.zero?
    triangle = { x: 100, y: 100, x2: 250, y2: 400, x3: 600, y3: 200 }
    args.outputs.static_primitives << Dinraal.raster( triangle )
  end
end
```

The library source file can be found at [app/lib/dinraal.rb](https://github.com/DSchaedler/dinraal/blob/main/app/lib/dinraal.rb).

A more detailed sample app is at [app/main.rb](https://github.com/DSchaedler/dinraal/blob/main/app/main.rb).

Triangles are defined as a hash of points, with any additional information.

```ruby
{ x: point1_x, y: point1_y, x2: point2_x, y2: point2_y, x3: point3_x, y3: point3_y, r: red, g: green, b: blue, a: alpha }
```

# Common Parameters

All methods in Dinraal accept their options in hash notation. This allows for extra or missing options to be ignored or inferred.

## Usually Required
```
x =  (int, float) x position of point 1 on the triangle.
y =  (int, float) y position of point 1 on the triangle.
x2 = (int, float) x position of point 2 on the triangle.
y2 = (int, float) y position of point 2 on the triangle.
x3 = (int, float) x position of point 3 on the triangle.
y3 = (int, float) y position of point 3 on the triangle.
```

## Usually Optional
```
r =  (int, float) red portion of the triangle's color.
g =  (int, float) green portion of the triangle's color.
b =  (int, float) blue portion of the triangle's color.
a =  (int, float) alpha portion of the triangle's color.
```

# Methods

## `bounding_box`
```ruby
Dinraal.bounding_box( { x: point1_x, y: point1_y, x2: point2_x, y2: point2_y, x3: point3_x, y3: point3_y } )
```

Returns a rectangle that contains the given triangle.

```ruby
{ x: x, y: y, w: width, h: height }
```

## `center`
```ruby
Dinraal.center( { x: point1_x, y: point1_y, x2: point2_x, y2: point2_y, x3: point3_x, y3: point3_y } )
```

Returns the center point ( centroid, incenter ) of the given triangle as a hash.

```ruby
{ x: center_x, y: center_y }
```

## `inside?`

```ruby
Dinraal.inside?( point: { x: point_x, y: point_y }, tri: { x: point1_x, y: point1_y, x2: point2_x, y2: point2_y, x3: point3_x, y3: point3_y } )
```

Returns `true` if the given point `{ x: point_x, y: point_y }` is inside or touching the given triangle. Otherwise, returns `false`.

## `outline`

```ruby
Dinraal.outline( { x: point1_x, y: point1_y, x2: point2_x, y2: point2_y, x3: point3_x, y3: point3_y, r: red, g: green, b: blue, a: alpha } )
```

Returns an array of lines represented as hashes. The lines form the outline of the given triangle.

```ruby
[ { x: start_x, y: start_y, x2: end_x, y2: end_x, r: red, g: green, b: blue, a: alpha }.line!,
  { x: start_x, y: start_y, x2: end_x, y2: end_x, r: red, g: green, b: blue, a: alpha }.line!,
  { x: start_x, y: start_y, x2: end_x, y2: end_x, r: red, g: green, b: blue, a: alpha }.line! ]
```

This array is formatted to be sent directly to `args.outputs.primitives` or a `render_target`.

## `raster`

```ruby
Dinraal.raster( { x: point1_x, y: point1_y, x2: point2_x, y2: point2_y, x3: point3_x, y3: point3_y, r: red, g: green, b: blue, a: alpha } )
```

Returns an array of lines represented as hashes. The lines form the solid body of the given triangle.

```ruby
[ { x: start_x, y: start_y, x2: end_x, y2: end_x, r: red, g: green, b: blue, a: alpha }.line!,
  { x: start_x, y: start_y, x2: end_x, y2: end_x, r: red, g: green, b: blue, a: alpha }.line!,
  { x: start_x, y: start_y, x2: end_x, y2: end_x, r: red, g: green, b: blue, a: alpha }.line! ]
```

This array is formatted to be sent directly to `args.outputs.primitives` or a `render_target`.

It is recommended to call this method and cache it's result, as it will lag with larger triangles.

## `rect_inside?`

```ruby
Dinraal.rect_inside?(rect: { x: x, y: y, w: width, h: height }, tri: { x: point1_x, y: point1_y, x2: point2_x, y2: point2_y, x3: point3_x, y3: point3_y })
```

Returns `true` if the rectangle provided in `rect` is contained inside of the triganle `tri`. Otherwise, returns `false`.

## `tri_inside?`

```ruby
Dinraal.tri_inside?(inner: { x: point1_x, y: point1_y, x2: point2_x, y2: point2_y, x3: point3_x, y3: point3_y }, outer: { x: point1_x, y: point1_y, x2: point2_x, y2: point2_y, x3: point3_x, y3: point3_y })
```

Returns `true` if the triangle provided in `inner` is contained inside of the triganle `outer`. Otherwise, returns `false`.

# TODO

- Create `tri_intersects?` method
- Create `rect_intersects?` method
- Create `inradius` method - [Incircle Math Breakdown](https://artofproblemsolving.com/wiki/index.php/Incircle)
- Create `area` method - [Heron's Formula](https://artofproblemsolving.com/wiki/index.php/Heron%27s_Formula)
  - Vector based calculations will be faster, but less straightforward to impliment
- Create `perimiter` method

# How to contribute
- Submit a Pull Request with any code improvements
- Impliment any item from the TODO list.
- Write a sample app that more clearly shows all methods
- Write a tutorial
- Submit improved calculation methods
  - Speed improvements to the `raster` method
  - Vector calculations for area over Heron's Formula

# About Dinraal
Dinraal is created by Dee Schaedler. Many thanks to the DragonRuby Discord server for inspiration and feedback. https://discord.dragonruby.org

Specific thanks to:
- leviondiscord#5978    - Optimization contribution
- theanxietybuster#8491 - Catching a project-ending typo

Most DragonRuby packages and libraries are named after various dragons. Dinraal is a [Japanese Dragon](https://en.wikipedia.org/wiki/Japanese_dragon) from [The Legend of Zelda: Breath of the Wild](https://en.wikipedia.org/wiki/The_Legend_of_Zelda:_Breath_of_the_Wild). Dinraal is the dragon of fire, and the gatekeeper of the Shrine at the [Spring of Power](https://zelda.fandom.com/wiki/Spring_of_Power).
