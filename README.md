Cirno's Perfect Math Library
====
### Adapated for Minetest
For best memory performance: have luaJIT & it's FFI library (this should be built into luaJIT), and add MTUL-CPML to your trusted list (so it can `require()` call the FFI library)

Various useful bits of game math. 3D line intersections, ray casting, 2d/3d vectors, 4x4 matrices, quaternions, etc.

(originally) ntended to be used with LuaJIT and LÖVE (this is the backbone of LÖVE3D).

Online documentation can be found [here](http://excessive.github.io/cpml/) or you can generate them yourself using `ldoc -c doc/config.ld -o index .`

## Additionally adds to the API
`mat4:translate_local(out, a, t)`
does the same thing as `translate` only its far right column instead of bottom row (as that's what's needed for most local coordinate systems)
also: worth noting that "a" in both `translate` and `translate_local` can be an empty table, and it'll generate an identity matrix. Which is really
redundant code wise, not a fan of that. Probably will fix that at some point.

### TODO:
* Vec3s and Vec2s are not currently adapted for functionality with MT vectors (seperate classes)
