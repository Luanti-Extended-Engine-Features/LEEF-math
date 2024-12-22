--- A quaternion and associated utilities.
-- this is apart of the [LEEF-math](https://github.com/Luanti-Extended-Engine-Features/LEEF-math) module
-- @module math.quat

local constants     = require(modules .. "constants")
local vec3          = require(modules .. "vec3")
local precond       = require(modules .. "_private_precond")
local private       = require(modules .. "_private_utils")
local utils 		= require(modules .. "utils")
local mat4    		= require(modules .. "mat4")
local DOT_THRESHOLD = constants.DOT_THRESHOLD
local DBL_EPSILON   = constants.DBL_EPSILON
local acos          = math.acos
local cos           = math.cos
local sin           = math.sin
local min           = math.min
local max           = math.max
local sqrt          = math.sqrt
local quat          = {}
local quat_mt       = {}

-- Private constructor.
local function new(x, y, z, w)
	return setmetatable({
		x = x or 0,
		y = y or 0,
		z = z or 0,
		w = w or 1
	}, quat_mt)
end

-- Do the check to see if JIT is enabled. If so use the optimized FFI structs.
local status, ffi
if type(jit) == "table" and jit.status() then
	status, ffi = pcall(require, "ffi")
	if status then
		ffi.cdef "typedef struct { double x, y, z, w;} cpml_quat;"
		new = ffi.typeof("cpml_quat")
	end
end

--- Constants
-- @table quat
-- @field unit Unit quaternion
-- @field zero Empty quaternion
quat.unit = new(0, 0, 0, 1)
quat.zero = new(0, 0, 0, 0)

--- The public constructor.
-- @param x Can be of two types: </br>
-- number x X component
-- table {x, y, z, w} or {x=x, y=y, z=z, w=w}
-- @tparam number y Y component
-- @tparam number z Z component
-- @tparam number w W component
-- @treturn quat out
function quat.new(x, y, z, w)
	-- number, number, number, number
	if x and y and z and w then
		precond.typeof(x, "number", "new: Wrong argument type for x")
		precond.typeof(y, "number", "new: Wrong argument type for y")
		precond.typeof(z, "number", "new: Wrong argument type for z")
		precond.typeof(w, "number", "new: Wrong argument type for w")

		return new(x, y, z, w)

	-- {x, y, z, w} or {x=x, y=y, z=z, w=w}
	elseif type(x) == "table" then
		local xx, yy, zz, ww = x.x or x[1], x.y or x[2], x.z or x[3], x.w or x[4]
		precond.typeof(xx, "number", "new: Wrong argument type for x")
		precond.typeof(yy, "number", "new: Wrong argument type for y")
		precond.typeof(zz, "number", "new: Wrong argument type for z")
		precond.typeof(ww, "number", "new: Wrong argument type for w")

		return new(xx, yy, zz, ww)
	end

	return new(0, 0, 0, 1)
end

--[[returns the required delta rotation to make a quaternion aim at a point
function quat.aim_at_point(quat)
end]]

--- Create a quaternion from an angle/axis pair.
-- @tparam number angle Angle (in radians)
-- @param axis/x -- Can be of two types, a vec3 axis, or the x component of that axis
-- @param y axis -- y component of axis (optional, only if x component param used)
-- @param z axis -- z component of axis (optional, only if x component param used)
-- @treturn quat out
function quat.from_angle_axis(angle, axis, a3, a4)
	if axis and a3 and a4 then
		local x, y, z = axis, a3, a4
		local s = sin(angle * 0.5)
		local c = cos(angle * 0.5)
		return new(x * s, y * s, z * s, c)
	else
		return quat.from_angle_axis(angle, axis.x, axis.y, axis.z)
	end
end

--- Create a quaternion from a normal/up vector pair. (accepts minetest vectors)
-- @tparam vec3 normal
-- @tparam vec3 up (optional)
-- @treturn quat out
function quat.from_direction(normal, up)
	local u = up or vec3.unit_z
	local n = normal:normalize()
	local a = u:cross(n)
	local d = u:dot(n)
	return new(a.x, a.y, a.z, d + 1)
end

--- Clone a quaternion.
-- @tparam quat a Quaternion to clone
-- @treturn quat out
function quat.clone(a)
	return new(a.x, a.y, a.z, a.w)
end

--- Add two quaternions.
-- @tparam quat a Left hand operand
-- @tparam quat b Right hand operand
-- @treturn quat out
function quat.add(a, b)
	return new(
		a.x + b.x,
		a.y + b.y,
		a.z + b.z,
		a.w + b.w
	)
end

--- Subtract a quaternion from another.
-- @tparam quat a Left hand operand
-- @tparam quat b Right hand operand
-- @treturn quat out
function quat.sub(a, b)
	return new(
		a.x - b.x,
		a.y - b.y,
		a.z - b.z,
		a.w - b.w
	)
end

--- Multiply two quaternions.
-- @tparam quat a Left hand operand
-- @tparam quat b Right hand operand
-- @treturn quat quaternion equivalent to "apply b, then a"
local out = {}
function quat.mul(a, b)
	return new(
		(a.x * b.w) + (a.w * b.x) + (a.y * b.z) - (a.z * b.y),
		(a.y * b.w) + (a.w * b.y) + (a.z * b.x) - (a.x * b.z),
		(b.w * a.z) + (b.z * a.w) + (b.y * a.x) - (b.x * a.y),
		(a.w * b.w) - (a.x * b.x) - (a.y * b.y) - (a.z * b.z)
	)
end

-- Statically allocate a temporary variable used in some of our functions.
local tmp = new()
local u, uv, uuv = vec3(), vec3(), vec3()

--- Multiply a quaternion and a vec3. Equivalent to rotating the vector (a) by the quaternion (v)
-- @tparam quat a Left hand operand
-- @tparam vec3 v Right hand operand
-- @treturn vec3 out
function quat.mul_vec3(a, v)
	u.x = a.x
	u.y = a.y
	u.z = a.z
	uv   = u:cross(v)
	uuv  = u:cross(uv)
	return v + ((uv * a.w) + uuv) * 2
end

--[[ does the same thing as above, which I did not know when i reimplemented it to check.
function quat.rotate_vec3(a, v)
	u.x = a.x
	u.y = a.y
	u.z = a.z
	local s = a.w
    return

	(u*u:dot(v)*2)  +

	(v*(s*s - u:dot(u)))  +

	(u:cross(v)*s*2)
end]]

--- Raise a normalized quaternion to a scalar power.
-- @tparam quat a Left hand operand (should be a unit quaternion)
-- @tparam number s Right hand operand
-- @treturn quat out
function quat.pow(a, s)
	-- Do it as a slerp between identity and a (code borrowed from slerp)
	if a.w < 0 then
		a   = -a
	end
	local dot = a.w

	dot = min(max(dot, -1), 1)

	local theta = acos(dot) * s
	local c = new(a.x, a.y, a.z, 0):normalize() * sin(theta)
	c.w = cos(theta)
	return c
end

--- Normalize a quaternion.
-- @tparam quat a Quaternion to normalize
-- @treturn quat out
function quat.normalize(a)
	if a:is_zero() then
		return new(0, 0, 0, 0)
	end
	return a:scale(1 / a:len())
end

--- Get the dot product of two quaternions.
-- @tparam quat a Left hand operand
-- @tparam quat b Right hand operand
-- @treturn number dot
function quat.dot(a, b)
	return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w
end

--- Return the length of a quaternion.
-- @tparam quat a Quaternion to get length of
-- @treturn number len
function quat.len(a)
	return sqrt(a.x * a.x + a.y * a.y + a.z * a.z + a.w * a.w)
end

--- Return the squared length of a quaternion.
-- @tparam quat a Quaternion to get length of
-- @treturn number len
function quat.len2(a)
	return a.x * a.x + a.y * a.y + a.z * a.z + a.w * a.w
end

--- Multiply a quaternion by a scalar.
-- @tparam quat a Left hand operand
-- @tparam number s Right hand operand
-- @treturn quat out
function quat.scale(a, s)
	return new(
		a.x * s,
		a.y * s,
		a.z * s,
		a.w * s
	)
end

--- Alias of `from_angle_axis.`
-- @tparam number angle Angle (in radians)
-- @param axis/x -- Can be of two types, a vec3 axis, or the x component of that axis
-- @param y axis -- y component of axis (optional, only if x component param used)
-- @param z axis -- z component of axis (optional, only if x component param used)
-- @treturn quat out
function quat.rotate(angle, axis, a3, a4)
	return quat.from_angle_axis(angle, axis, a3, a4)
end

--- Return the conjugate of a quaternion.
-- @tparam quat a Quaternion to conjugate
-- @treturn quat out
function quat.conjugate(a)
	return new(-a.x, -a.y, -a.z, a.w)
end

--- Return the inverse of a quaternion.
-- @tparam quat a Quaternion to invert
-- @treturn quat out
function quat.inverse(a)
	tmp.x = -a.x
	tmp.y = -a.y
	tmp.z = -a.z
	tmp.w =  a.w
	return tmp:normalize()
end

--- Return the reciprocal of a quaternion.
-- @tparam quat a Quaternion to reciprocate
-- @treturn quat out
function quat.reciprocal(a)
	if a:is_zero() then
		error("Cannot reciprocate a zero quaternion")
		return false
	end

	tmp.x = -a.x
	tmp.y = -a.y
	tmp.z = -a.z
	tmp.w =  a.w

	return tmp:scale(1 / a:len2())
end

--- Lerp between two quaternions.
-- @tparam quat a Left hand operand
-- @tparam quat b Right hand operand
-- @tparam number s Step value
-- @treturn quat out
function quat.lerp(a, b, s)
	return (a + (b - a) * s):normalize()
end

--- Slerp between two quaternions.
-- @tparam quat a Left hand operand
-- @tparam quat b Right hand operand
-- @tparam number s Step value
-- @treturn quat out
function quat.slerp(a, b, s)
	local dot = a:dot(b)

	if dot < 0 then
		a   = -a
		dot = -dot
	end

	if dot > DOT_THRESHOLD then
		return a:lerp(b, s)
	end

	dot = min(max(dot, -1), 1)

	local theta = acos(dot) * s
	local c = (b - a * dot):normalize()
	return a * cos(theta) + c * sin(theta)
end

--- Unpack a quaternion into individual components.
-- @tparam quat a Quaternion to unpack
-- @treturn number x
-- @treturn number y
-- @treturn number z
-- @treturn number w
function quat.unpack(a)
	return a.x, a.y, a.z, a.w
end

--- Return a boolean showing if a table is or is not a quat.
-- @tparam quat a Quaternion to be tested
-- @treturn boolean is_quat
function quat.is_quat(a)
	if type(a) == "cdata" then
		return ffi.istype("cpml_quat", a)
	end

	return
		type(a)   == "table"  and
		type(a.x) == "number" and
		type(a.y) == "number" and
		type(a.z) == "number" and
		type(a.w) == "number"
end

--- Return a boolean showing if a table is or is not a zero quat.
-- @tparam quat a Quaternion to be tested
-- @treturn boolean is_zero
function quat.is_zero(a)
	return
		a.x == 0 and
		a.y == 0 and
		a.z == 0 and
		a.w == 0
end

--- Return a boolean showing if a table is or is not a real quat.
-- @tparam quat a Quaternion to be tested
-- @treturn boolean is_real
function quat.is_real(a)
	return
		a.x == 0 and
		a.y == 0 and
		a.z == 0
end

--- Return a boolean showing if a table is or is not an imaginary quat.
-- @tparam quat a Quaternion to be tested
-- @treturn boolean is_imaginary
function quat.is_imaginary(a)
	return a.w == 0
end

--- Return whether any component is NaN
-- @tparam quat a Quaternion to be tested
-- @treturn boolean if x,y,z, or w is NaN
function quat.has_nan(a)
	return private.is_nan(a.x) or
		private.is_nan(a.y) or
		private.is_nan(a.z) or
		private.is_nan(a.w)
end

--- Convert a quaternion into an angle plus axis components.
-- @tparam quat a Quaternion to convert
-- @tparam identityAxis vec3 of axis to use on identity/degenerate quaternions (optional, default returns 0,0,0,1)
-- @treturn number angle
-- @treturn x axis-x
-- @treturn y axis-y
-- @treturn z axis-z
function quat.to_angle_axis_unpack(a, identityAxis)
	if a.w > 1 or a.w < -1 then
		a = a:normalize()
	end

	-- If length of xyz components is less than DBL_EPSILON, this is zero or close enough (an identity quaternion)
	-- Normally an identity quat would return a nonsense answer, so we return an arbitrary zero rotation early.
	-- FIXME: Is it safe to assume there are *no* valid quaternions with nonzero degenerate lengths?
	if a.x*a.x + a.y*a.y + a.z*a.z < constants.DBL_EPSILON*constants.DBL_EPSILON then
		if identityAxis then
			return 0,identityAxis:unpack()
		else
			return 0,0,0,1
		end
	end

	local x, y, z
	local angle = 2 * acos(a.w)
	local s     = sqrt(1 - a.w * a.w)

	if s < DBL_EPSILON then
		x = a.x
		y = a.y
		z = a.z
	else
		x = a.x / s
		y = a.y / s
		z = a.z / s
	end

	return angle, x, y, z
end

--- Convert a quaternion into an angle/axis pair.
-- @tparam quat a Quaternion to convert
-- @tparam identityAxis vec3 of axis to use on identity/degenerate quaternions (optional, default returns 0,vec3(0,0,1))
-- @treturn number angle
-- @treturn vec3 axis
function quat.to_angle_axis(a, identityAxis)
	local angle, x, y, z = a:to_angle_axis_unpack(identityAxis)
	return angle, vec3(x, y, z)
end

--- set a matrix's rotation fields from a quaternion. Uses mat4.set_rot_from_quaternion
-- @tparam quat quaternion to convert
-- @tparam mat4 the mat4 to apply to.
-- @treturn mat4
function quat.set_matrix_rot(q, m)
	m:set_rot_from_quaternion(q)
	return m
end

--- create a new quaternion from a matrix. Uses mat4.to_quaternion
-- @tparam mat4 the matrix to use
-- @treturn quat
function quat.from_matrix(m)
	return m:to_quaternion()
end



--- convert a quaternion to an ZXY euler angles. This is the rotation order used by Minetest/Luanti Entities.
-- @tparam quat quaternion to convert
-- @treturn float X
-- @treturn float Y
-- @treturn float Z
local atan2 = math.atan2
local abs = math.abs
local asin = math.asin
function quat.get_euler_zxy(q)
	local qx, qy, qz, qw = q.x, q.y, q.z, q.w
	local s = 1/sqrt(qx * qx + qz * qz + qy * qy + qw * qw)
	qx,qz,qy,qw = qx*s, qz*s, qy*s, qw*s
	--convert to matrix but only grab the matrix indices we need. Basically this violently smashes together the matrix to zxy and quat to matrix code.
	local m2 = 2*(qx*qy + qz*qw)
	local m5 = 2*(qx*qy - qz*qw)
	local m6 = 1-2*(qx^2 + qz^2)
	local m7 = 2*(qy*qz + qx*qw)
	local m9 = 2*(qx*qz + qy*qw)
	local m10 = 2*(qy*qz - qx*qw)
	local m11 = 1-2*(qx^2 + qy^2)

	local X,Y,Z
	if abs(m10)-1 < DBL_EPSILON then --check if x is 90 or -90. If it is yaw will experience gimbal lock and there will therefore be infinite solutions.
		Z = atan2(m2, m6) --(cz*cx / sz*cx) = cz/cx = tz.
		Y = atan2(m9, m11)
		X = atan2(-m10, m6/cos(Z))
	else
		Z = atan2(m7, m5)
		Y = 0 --pitch and roll are the same given x=90 or -90.
		X = asin(-m10)
	end
	return X,Y,Z
end

--- alias of `get_euler_zxy`
-- @function quat.get_rot_luanti_entity
quat.get_euler_luanti_entity = quat.get_euler_zxy



--- create a quaternion from euler angles in the ZXY rotation order. This is the rotation order Luanti Entities use
-- @tparam float X
-- @tparam float Y
-- @tparam float Z
-- @treturn quat q
function quat.from_euler_zxy(X,Y,Z)
	--I want to note that for no apparent reason at all the original matrix was transposed here
	local cr = cos(Z)
	local sr = sin(Z)
	local cp = cos(X)
	local sp = sin(X);
	local cy = cos(Y)
	local sy = sin(Y);

	local m1 = sr * sp * sy + cr * cy
	local m2 = sr * cp
	local m3 = sr * sp * cy - cr * sy

	local m5 = cr * sp * sy - sr * cy
	local m6 = cr * cp
	local m7 = cr * sp * cy + sr * sy

	local m9 = cp * sy
	local m10 = -sp
	local m11 = cp * cy
	local w = math.sqrt(1 + m1 + m6 + m11) / 2
	return new(
		(m7 - m10) /(4 * w),
		(m9 - m3)  /(4 * w),
		(m2 - m5)  /(4 * w),
		w
	)
end

--- alias of `from_euler_zxy`
-- @function quat.get_rot_luanti_entity
quat.from_euler_luanti_entity = quat.from_euler_zxy



--- convert a quaternion to an xyz euler angles. This is the rotation order used by irrlicht bones.
-- @tparam quat quaternion to convert
-- @treturn X
-- @treturn Y
-- @treturn Z
function quat.get_euler_xyz(q)
	local qx, qy, qz, qw = q.x, q.y, q.z, q.w
	local s = 1/sqrt(qx * qx + qz * qz + qy * qy + qw * qw)
	qx,qz,qy,qw = qx*s, qz*s, qy*s, qw*s
	--convert to matrix but only grab the matrix indices we need. Basically this violently smashes together the matrix to zxy and quat to matrix code.
	local m1 = 1-2*(qy^2 + qz^2)
	local m2 = 2*(qx*qy + qz*qw)
	local m3 = 2*(qx*qz - qy*qw)
	local m5 = 2*(qx*qy - qz*qw)
	local m7 = 2*(qy*qz + qx*qw)
	local m11 = 1-2*(qx^2 + qy^2)

	local X,Y,Z
	if abs(m3)-1 < DBL_EPSILON then --check if x is 90 or -90. If they are yaw will experience gimbal lock and there will therefore be infinite solutions.
		Z = atan2(m2, m1)
		Y = atan2(-m3, m1/cos(Z))
		X = atan2(m7, m11)
	else
		--Z = atan2(M[], M[])
		Y = asin[m3]
		X = atan2(m5, m7)
		Z = 0
	end
	return X,Y,Z
end

--- alias of `get_euler_xyz`
-- @function quat.get_rot_irrlicht_bone
quat.get_euler_irrlicht_bone = quat.get_euler_xyz



--- create a quaternion from euler angles in the xyz rotation order. This is the rotation order irrlicht bones use
-- @tparam float X
-- @tparam float Y
-- @tparam float Z
-- @treturn quat q
function quat.from_euler_xyz(X,Y,Z)
	local cp = cos(X)
	local sp = sin(X)
	local cy = cos(Y)
	local sy = sin(Y)
	local cr = cos(Z)
	local sr = sin(Z)

	local m1 = (cy * cr)
	local m2 = (cy * sr)
	local m3 = (-sy)

	local m5 = (sp * sy * cr - cp * sr)
	local m6 = (sp * sy * sr + cp * cr)
	local m7 = (sp * cy)

	local m9 = (cp * sy * cr + sp * sr)
	local m10 = (cp * sy * sr - sp * cr)
	local m11 = (cp * cy)
	local w = math.sqrt(1 + m1 + m6 + m11) / 2
	return new(
		(m7 - m10) /(4 * w),
		(m9 - m3)  /(4 * w),
		(m2 - m5)  /(4 * w),
		w
	)
end
--- alias of `quat.from_euler_zxy`
--@function quat.get_rot_irrlicht_bone
quat.from_euler_irrlicht_bone = quat.from_euler_xyz

--- Convert a quaternion into a vec3.
-- @tparam quat a Quaternion to convert
-- @treturn vec3 out
function quat.to_vec3(a)
	return vec3(a.x, a.y, a.z)
end

--- Return a formatted string.
-- @tparam quat a Quaternion to be turned into a string
-- @treturn string formatted
function quat.to_string(a)
	return string.format("(%+0.3f,%+0.3f,%+0.3f,%+0.3f)", a.x, a.y, a.z, a.w)
end

quat_mt.__index    = quat
quat_mt.__tostring = quat.to_string

function quat_mt.__call(_, x, y, z, w)
	return quat.new(x, y, z, w)
end

function quat_mt.__unm(a)
	return a:scale(-1)
end

function quat_mt.__eq(a,b)
	if not quat.is_quat(a) or not quat.is_quat(b) then
		return false
	end
	return a.x == b.x and a.y == b.y and a.z == b.z and a.w == b.w
end

function quat_mt.__add(a, b)
	precond.assert(quat.is_quat(a), "__add: Wrong argument type '%s' for left hand operand. (<cpml.quat> expected)", type(a))
	precond.assert(quat.is_quat(b), "__add: Wrong argument type '%s' for right hand operand. (<cpml.quat> expected)", type(b))
	return a:add(b)
end

function quat_mt.__sub(a, b)
	precond.assert(quat.is_quat(a), "__sub: Wrong argument type '%s' for left hand operand. (<cpml.quat> expected)", type(a))
	precond.assert(quat.is_quat(b), "__sub: Wrong argument type '%s' for right hand operand. (<cpml.quat> expected)", type(b))
	return a:sub(b)
end

function quat_mt.__mul(a, b)
	precond.assert(quat.is_quat(a), "__mul: Wrong argument type '%s' for left hand operand. (<cpml.quat> expected)", type(a))
	assert(quat.is_quat(b) or vec3.is_vec3(b) or type(b) == "number", "__mul: Wrong argument type for right hand operand. (<cpml.quat> or <cpml.vec3> or <number> expected)")

	if quat.is_quat(b) then
		return a:mul(b)
	end

	if type(b) == "number" then
		return a:scale(b)
	end

	return a:mul_vec3(b)
end

function quat_mt.__pow(a, n)
	precond.assert(quat.is_quat(a), "__pow: Wrong argument type '%s' for left hand operand. (<cpml.quat> expected)", type(a))
	precond.typeof(n, "number", "__pow: Wrong argument type for right hand operand.")
	return a:pow(n)
end

if status then
	xpcall(function() -- Allow this to silently fail; assume failure means someone messed with package.loaded
		ffi.metatype(new, quat_mt)
	end, function() end)
end

return setmetatable({}, quat_mt)
