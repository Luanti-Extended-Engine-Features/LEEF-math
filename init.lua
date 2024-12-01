--[[
-------------------------------------------------------------------------------
-- @author Colby Klein
-- @author Landon Manning
-- @copyright 2016
-- @license MIT/X11
-------------------------------------------------------------------------------
                  .'@@@@@@@@@@@@@@#:
              ,@@@@#;            .'@@@@+
           ,@@@'                      .@@@#
         +@@+            ....            .@@@
       ;@@;         '@@@@@@@@@@@@.          @@@
      @@#         @@@@@@@@++@@@@@@@;         `@@;
    .@@`         @@@@@#        #@@@@@          @@@
   `@@          @@@@@` Cirno's  `@@@@#          +@@
   @@          `@@@@@  Perfect   @@@@@           @@+
  @@+          ;@@@@+   Math     +@@@@+           @@
  @@           `@@@@@  Library   @@@@@@           #@'
 `@@            @@@@@@          @@@@@@@           `@@
 :@@             #@@@@@@.    .@@@@@@@@@            @@
 .@@               #@@@@@@@@@@@@;;@@@@@            @@
  @@                  .;+@@#'.   ;@@@@@           :@@
  @@`                            +@@@@+           @@.
  ,@@                            @@@@@           .@@
   @@#          ;;;;;.          `@@@@@           @@
    @@+         .@@@@@          @@@@@           @@`
     #@@         '@@@@@#`    ;@@@@@@          ;@@
      .@@'         @@@@@@@@@@@@@@@           @@#
        +@@'          '@@@@@@@;            @@@
          '@@@`                         '@@@
             #@@@;                  .@@@@:
                :@@@@@@@++;;;+#@@@@@@+`
                      .;'+++++;.
--]]
local cpml = {
	_LICENSE = "CPML is distributed under the terms of the MIT license. See LICENSE.md.",
	_URL = "https://github.com/excessive/cpml",
	_DESCRIPTION = "Cirno's Perfect Math Library: Just about everything you need for 3D games. Hopefully."
}

local files = {
	"bvh",
	"color",
	"constants",
	"intersect",
	"mat4",
	"mesh",
	"octree",
	"quat",
	"simplex",
	"utils",
	"vec2",
	"vec3",
	"bound2",
	"bound3",
}

--you will now witness the lua equivelant of a schizo rant. Have fun with this bullshit.

--initialize some variables
leef = leef or {
  loaded_modules = {}
}
leef.math = leef.math or {}
leef.loaded_modules.math = true

local old_require = require --just in case require is present (aka it's an insecure environment)
local old_package_path
local modpath
--check that it's minetest and not a lua script running it. If it's not minetest we dont have to do all of this, but otherwise we dont know if
if minetest or (core and core.register_globalstep) then
    modpath = minetest.get_modpath("leef_math")
    local ie = minetest.request_insecure_environment()

    --since we can't use require, what we do instead is override require by some utterly offensive means.
    modules = "" --path to modules.
    if not ie then
      --if an insecure environment cannot be loaded, then we basically change how require works temporarily, so modules (which is referenced in all CPML files on require() has to be changed)
      modules = modpath.."/modules/"
      function require(path)
        local ending = string.gsub(path:sub(#modules+1), "%.", "/")..".lua"
        path = modules..ending
        return dofile(path)
      end
    else
      old_package_path = package.path
      --get the real modpath and add it to the package.path string so we can find our modules in require()
      ie.package.path =  ie.package.path .. ";"..string.gsub(modpath, "\\bin\\%.%.", "").."?.lua" --add our path
      modules = ".modules."
      require = ie.require
    end

    if type(jit) == "table" and jit.status() then
      if ie then
        if pcall(require, "ffi") then
          minetest.log("verbose", "LEEF-Math: loaded JIT FFI library. Memory efficiency with FFI enabled.")
          print("LEEF-Math: JIT FFI loaded successfully.")
        else
          minetest.log("error", "LEEF-Math:  Failure to load JIT FFI library.")
        end
      else
        minetest.log("error", "LEEF-Math:  insecure environment denied for LEEF-Math. Add leef_math to your trusted mods for better performance")
      end
    else
      minetest.log("verbose", "LEEF-Math:  JIT not present, skipped attempt to load JIT FFI library for acceleration and memory efficiency")
    end
end
  --load the files

for _, file in ipairs(files) do
  leef.math[file] = require(modules .. file)
end

--unset all the global shit we had to change for CPML to work properly.
if modpath then
  if ie then
    ie.package.path = old_package_path
  end
  modules = nil
  require = old_require
end

--dofile(modpath.."/unit_tests/quat_unit_test.lua")
if modpath then
  print("LEEF Math: BEGINNING UNIT TESTING FOR COMPLEX TYPES")
  dofile(modpath.."/unit_tests/irrlicht_luanti_tests.lua")
  dofile(modpath.."/unit_tests/matrix_unit_test.lua")
  dofile(modpath.."/unit_tests/quat_unit_test.lua")
else
  print("LEEF Math: BEGINNING UNIT TESTING FOR COMPLEX TYPES")
  require("/unit_tests/irrlicht_luanti_tests.lua")
  require("/unit_tests/matrix_unit_test.lua")
  require("/unit_tests/quat_unit_test.lua")
end


