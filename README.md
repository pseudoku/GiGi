# GiGi
Parametric 2x6 + 3 steno keyboard with optional trackballs.
![](https://raw.githubusercontent.com/pseudoku/GiGi/master/Photos/GigiStd.jpg)
## TODOs
* PCB
* BOM?
* Clean up trackball mount.

## Extra
### GiGi Mini
Disregard standards to attain minimum thumb travels and absolute compactness.
![](https://raw.githubusercontent.com/pseudoku/GiGi/master/Photos/GigiMinima.jpg)

### Custom  Keycap
Deeper spherical dish with optional hatch or home dimples.
Dish offset to Smoothen transition and chord press.
![](https://raw.githubusercontent.com/pseudoku/GiGi/master/Photos/Keycaps.png)

## Hacking GiGi

1. Add [scad-utils](https://github.com/openscad/scad-utils) and
   [list-comprehension-demos](https://github.com/openscad/list-comprehension-demos)
   libraries into [user resources](https://github.com/openscad/openscad/wiki/Path-locations#user-resources).
   1. `.scad` files from `scad-utils` should be put in `libraries/scad-utils`.
   2. `.scad` files from `list-comprehension-demos` should be put in the `libraries`.
2. Open `.scad` files in `Things` directory.
3. Edit some vars to your likings.
4. `File` > `Export` > `Export as STL`.

