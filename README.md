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

The library source file can be found at [https://github.com/DSchaedler/dinraal/blob/main/app/lib/dinraal.rb](https://github.com/DSchaedler/dinraal/blob/main/app/lib/dinraal.rb)  
(app/lib/dinraal.rb)

# Common Parameters
    x =  (int, float) x position of point 1 on the triangle.  
    y =  (int, float) y position of point 1 on the triangle.  
    x2 = (int, float) x position of point 2 on the triangle.  
    y2 = (int, float) y position of point 2 on the triangle.  
    x3 = (int, float) x position of point 3 on the triangle.  
    y3 = (int, float) y position of point 3 on the triangle.  
    r =  (int, float) red portion of the triangle's color.  
    g =  (int, float) green portion of the triangle's color.  
    b =  (int, float) blue portion of the triangle's color.  
    a =  (int, float) alpha portion of the triangle's color.  

# Methods

## `center`
```ruby
Dinraal.center( { x, y, x2, y2, x3, y3 } )
```

Returns the center point ( centroid ) of the given triangle.

## `outline`

## `raster`

# TODO

- Create `inside` method.
