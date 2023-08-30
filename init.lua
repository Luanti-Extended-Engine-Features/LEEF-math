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

modules = minetest.get_modpath("mtul_math_cpml").."/modules/"
local old_require = require

local len = #modules

local loaded_modules = {}
function require(path)
  if loaded_modules[path] then return loaded_modules[path] end
  print("             TEST                \n\n\n")
  local ending = string.gsub(path:sub(len+1), "%.", "/")..".lua"
  --[[if ending[1] ~= "/" then
    ending = "/"..ending
  end]]
  path = modules..ending
  print(path)
  loaded_modules[path] = dofile(path)
  return loaded_modules[path]
end
for _, file in ipairs(files) do
	mtul.math[file] = require(modules .. file)
end

modules = nil
require = old_require
