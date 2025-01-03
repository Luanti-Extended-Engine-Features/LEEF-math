--- A 2 component bounding box.
-- this is apart of the [LEEF-math](https://github.com/Luanti-Extended-Engine-Features/LEEF-math) module
-- @module math.bound2

local vec2    = require(modules .. "vec2")

local bound2    = {}
local bound2_mt = {}

-- Private constructor.
local function new(min, max)
	return setmetatable({
		min=min, -- min: vec2, minimum value for each component
		max=max, -- max: vec2, maximum value for each component
	}, bound2_mt)
end

-- Do the check to see if JIT is enabled. If so use the optimized FFI structs.
local status, ffi
if type(jit) == "table" and jit.status() then
	status, ffi = pcall(require, "ffi")
	if status then
		ffi.cdef "typedef struct { cpml_vec2 min, max; } cpml_bound2;"
		new = ffi.typeof("cpml_bound2")
	end
end

bound2.zero = new(vec2.zero, vec2.zero)

--- The public constructor.
-- @param min (**_vec2_** | **_nil_**) minimum value for each component. `nil` sets to zero.
-- @tparam vec2 max maximum value for each component
-- @treturn bound2 out
function bound2.new(min, max)
	if min and max then
		return new(min:clone(), max:clone())
	elseif min or max then
		error("Unexpected nil argument to bound2.new")
	else
		return new(vec2.zero, vec2.zero)
	end
end

--- Clone a bound.
-- @tparam bound2 a bound to be cloned
-- @treturn bound2 out
function bound2.clone(a)
	return new(a.min, a.max)
end

--- Construct a bound covering one or two points
-- @tparam vec2 a Any vector
-- @tparam vec2 b Any second vector (optional)
-- @treturn vec2 Minimum bound containing the given points
function bound2.at(a, b) -- "bounded by". b may be nil
	if b then
		return bound2.new(a,b):check()
	else
		return bound2.zero:with_center(a)
	end
end

--- Extend bound to include point
-- @tparam bound2 a a bound
-- @tparam vec2 center point to include
-- @treturn bound2 Bound covering current min, current max and new point
function bound2.extend(a, center)
	return bound2.new(a.min:component_min(center), a.max:component_max(center))
end

--- Extend bound to entirety of other bound
-- @tparam bound2 a a bound
-- @tparam bound2 b bound to cover
-- @treturn bound2 Bound covering current min and max of each bound in the pair
function bound2.extend_bound(a, b)
	return a:extend(b.min):extend(b.max)
end

--- Get size of bounding box as a vector
-- @tparam bound2 a a bound
-- @treturn vec2 Vector spanning min to max points
function bound2.size(a)
	return a.max - a.min
end

--- Resize bounding box from minimum corner
-- @tparam bound2 a a bound
-- @tparam vec2 size new size
-- @treturn bound2 resized bound
function bound2.with_size(a, size)
	return bound2.new(a.min, a.min + size)
end

--- Get half-size of bounding box as a vector. A more correct term for this is probably "apothem"
-- @tparam bound2 a a bound
-- @treturn vec2 Vector spanning center to max point
function bound2.radius(a)
	return a:size()/2
end

--- Get center of bounding box
-- @tparam bound2 a a bound
-- @treturn bound2 Point in center of bound
function bound2.center(a)
	return (a.min + a.max)/2
end

--- Move bounding box to new center
-- @tparam bound2 a a bound
-- @tparam vec2 center new center
-- @treturn bound2 Bound with same size as input but different center
function bound2.with_center(a, center)
	return bound2.offset(a, center - a:center())
end

--- Resize bounding box from center
-- @tparam bound2 a bound
-- @tparam vec2 size new size
-- @treturn bound2 resized bound
function bound2.with_size_centered(a, size)
	local center = a:center()
	local rad = size/2
	return bound2.new(center - rad, center + rad)
end

--- Convert possibly-invalid bounding box to valid one
-- @tparam bound2 a bound
-- @treturn bound2 bound with all components corrected for min-max property
function bound2.check(a)
	if a.min.x > a.max.x or a.min.y > a.max.y then
		return bound2.new(vec2.component_min(a.min, a.max), vec2.component_max(a.min, a.max))
	end
	return a
end

--- Shrink bounding box with fixed margin
-- @tparam bound2 a bound
-- @tparam vec2 v margin
-- @treturn bound2 bound with margin subtracted from all edges. May not be valid, consider calling check()
function bound2.inset(a, v)
	return bound2.new(a.min + v, a.max - v)
end

--- Expand bounding box with fixed margin
-- @tparam bound2 a bound
-- @tparam vec2 v margin
-- @treturn bound2 bound with margin added to all edges. May not be valid, consider calling check()
function bound2.outset(a, v)
	return bound2.new(a.min - v, a.max + v)
end

--- Offset bounding box
-- @tparam bound2 a bound
-- @tparam vec2 v offset
-- @treturn bound2 bound with same size, but position moved by offset
function bound2.offset(a, v)
	return bound2.new(a.min + v, a.max + v)
end

--- Test if point in bound
-- @tparam bound2 a bound
-- @tparam vec2 v point to test
-- @treturn boolean true if point in bounding box
function bound2.contains(a, v)
	return a.min.x <= v.x and a.min.y <= v.y
	   and a.max.x >= v.x and a.max.y >= v.y
end

-- Round all components of all vectors to nearest int (or other precision).
-- @tparam vec3 a bound to round.
-- @tparam precision Digits after the decimal (round number if unspecified)
-- @treturn vec3 Rounded bound
function bound2.round(a, precision)
	return bound2.new(a.min:round(precision), a.max:round(precision))
end

--- Return a formatted string.
-- @tparam bound2 a bound to be turned into a string
-- @treturn string formatted
function bound2.to_string(a)
	return string.format("(%s-%s)", a.min, a.max)
end

bound2_mt.__index    = bound2
bound2_mt.__tostring = bound2.to_string

function bound2_mt.__call(_, a, b)
	return bound2.new(a, b)
end

if status then
	xpcall(function() -- Allow this to silently fail; assume failure means someone messed with package.loaded
		ffi.metatype(new, bound2_mt)
	end, function() end)
end

return setmetatable({}, bound2_mt)
