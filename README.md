Cirno's Perfect Math Library
====
### Adapated for Minetest
For best memory performance: have luaJIT & it's FFI library (this should be built into luaJIT), and add MTUL-CPML to your trusted list (so it can `require()` call the FFI library)
also works if you disable mod security (DANGEROUS, NOT RECCOMENDED).

Various useful bits of game math. 3D line intersections, ray casting, 2d/3d vectors, 4x4 matrices, quaternions, etc.

(originally) intended to be used with LuaJIT and LÖVE (this is the backbone of LÖVE3D).


### TODO:
* Vec3s and Vec2s are not currently adapted for functionality with MT vectors (seperate classes)