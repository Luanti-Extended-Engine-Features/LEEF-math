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
	_VERSION = "1.2.9",
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

--initialize some variables
local modpath = minetest.get_modpath("mtul_cpml")
local loaded_modules = {}
local old_require = require --just in case require is present (aka it's an insecure environment)
local ie = minetest.request_insecure_environment()

--if require isn't present, allow us to load the modules through hackish means
--there's like 100s of require calls, it'd be insane to replace them. If you're farmiliar with require, the goal should be obvious.
modules = "" --this is just for Busted support, as it'll bitch about "attempt to concat a nil value" otherwise.
--modules is the path to modules
local old_package_path
if not ie then
  --if an insecure environment cannot be loaded, then we basically change how require works temporarily, so modules (which is referenced in all CPML files on require() has to be changed)
  modules = modpath.."/modules/"
else
  old_package_path = package.path
  --get the real modpath and add it to the package.path string so we can find our modules in require()
  ie.package.path =  ie.package.path .. ";"..string.gsub(modpath, "\\bin\\%.%.", "").."?.lua" --add our path
  modules = ".modules."
end


if not ie then
  function require(path)
      if loaded_modules[path] then return loaded_modules[path] end
      local ending = string.gsub(path:sub(#modules+1), "%.", "/")..".lua"
      --[[if ending[1] ~= "/" then
        ending = "/"..ending
      end]]
      path = modules..ending
      loaded_modules[path] = dofile(path)
      return loaded_modules[path]
  end
else
  require = ie.require
end
--print(require, ie.require)

if type(jit) == "table" and jit.status() then
  if ie then
    if pcall(require, "ffi") then
      minetest.log("verbose", "MTUL-CPML: loaded JIT FFI library. Memory efficiency with FFI enabled.")
      print("mtul-cpml: JIT FFI loaded successfully.")
    else
      minetest.log("error", "MTUL-CPML:  Failure to load JIT FFI library.")
    end
  else
    minetest.log("error", "MTUL-CPML:  insecure environment denied for MTUL-CPML. Add mtul-cpml to your trusted mods for JIT FFI support (memory efficiency & speed boost)")
  end
else
  minetest.log("verbose", "MTUL-CPML:  JIT not present, skipped attempt to load JIT FFI library for acceleration and memory efficiency")
end

--load the files

for _, file in ipairs(files) do
  mtul.math[file] = require(modules .. file)
end

--unset all the global shit we had to change for CPML to work properly.
if old_package_path then
  ie.package.path = old_package_path
end
modules = nil
require = old_require

--tell MTUL-CORE that it's loaded.
mtul.loaded_modules.cpml = true
