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

# Methods

## `center`

## `outline`

## `raster`
