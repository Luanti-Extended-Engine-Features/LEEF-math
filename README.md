Cirno's Perfect Math Library
====

This is a Love (the game framework) library which has been ported and modified to work in the context of Luanti.

### Main features
* only Luanti Library which implements the ability to manipulate matrices and quaternions and convert them reliably to irrlicht bone rotations.
* bounding box modules
* mat4
* vec3
* quaternions
* octrees
* bvh lib
* more

### Adapted for Luanti
For best memory performance: have luaJIT & it's FFI library (this should be built into luaJIT), and add MTUL-CPML to your trusted list (so it can `require()` call the FFI library).

Various useful bits of game math. 3D line intersections, ray casting, 2d/3d vectors, 4x4 matrices, quaternions, etc.

This is a fork of CPML (for LÖVE/love3d), it's been ported over the minetest so it can be used in whatever you need it for.
Documentation can be found here: <https://minetest-unified-library.github.io/MTUL-CPML/>.

For possible future contributors: documentation must be generated manually when a commit is made, because I haven't set up workflows (and have no idea how to).

### TODO:
* Vec3s and Vec2s are not currently adapted for functionality with MT vectors, fix.
