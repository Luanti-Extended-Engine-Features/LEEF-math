Cirno's Perfect Math Library
====
### Adapted for Minetest
For best memory performance: have luaJIT & it's FFI library (this should be built into luaJIT), and add MTUL-CPML to your trusted list (so it can `require()` call the FFI library).

Various useful bits of game math. 3D line intersections, ray casting, 2d/3d vectors, 4x4 matrices, quaternions, etc.

This is a fork of CPML (for LÖVE/love3d), it's been ported over the minetest so it can be used in whatever you need it for.
Documentation can be found here: <https://minetest-unification-library.github.io/MTUL-CPML/>.

Documentation must be generated manually when a commit is made, because I haven't set up workflows (and have no idea how to).

### TODO:
* Vec3s and Vec2s are not currently adapted for functionality with MT vectors (seperate classes)
* Figure out how CPML (originally) automatically updated docs, and do it here.
