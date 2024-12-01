local mat4 = mtul.math.mat4
local matrix_tolerance = .00001
local function check_matrix_equality(m1,m2)
    for i = 1,16 do
        if math.abs(m1[i]-m2[i]) > 0.001 then
            return false
        end
    end
    return true
end

local tau = math.pi*2
local function santitize_angle(a)
    if a > tau then
        local co = math.floor(math.abs(a/tau))
        a = a-(co*tau)
    end
    if a < 0 then
        local co = math.ceil(math.abs(a/tau))
        a = a+(co*tau)
    end
    return a
end
local function equals(a,b)
    if math.abs(a-b) < .0001 then
        return true
    else
        return false
    end
end
local function santitize_angles_unpack(x,y,z)
    return santitize_angle(x), santitize_angle(y), santitize_angle(z)
end
--[[for i=1,10 do
    find_irr_order()
end]]
print("================== BEGINNING MATRIX UNIT TESTs =======================")
local find_rot_order = mtul.math.find_matrix_rotation_order
print("\n checking sanity of tests:")
local _tempeuler = {(math.random()-.5)*math.pi*4, (math.random()-.5)*math.pi*4, (math.random()-.5)*math.pi*4}
local _testmatrix = mtul.math.mat4.set_rot_zxy(mat4.new(), _tempeuler[1],_tempeuler[2],_tempeuler[3])
print("matrix equality check func is sane:", check_matrix_equality(_testmatrix,_testmatrix))
print("matrix equality check func tolerance:", matrix_tolerance)
local ran_ang = math.random()*math.pi*2
print("santitize_angle is sane:", equals(1.60947655802, santitize_angle(7.8926618652)), equals(ran_ang, santitize_angle(ran_ang-tau)))
--print("checking irrlicht setRotationRadians")
--print(find_rot_order(irrlicht_matrix_setRotationRadians).." iterations")

print("\n checking MTUL's luanti and irrlicht matrix rotation orders. Rotation application order is in reverse, these are the literal matrix multiplication order. ")
print("checking rotation matrix `set_rot_luanti_entity`")
find_rot_order(mtul.math.mat4.set_rot_luanti_entity)
print("checking `set_rot_irrlicht_bone`")
find_rot_order(mtul.math.mat4.set_rot_irrlicht_bone)

--[[print("check in euler out euler for minetest entitiy matrix rotations")
local x,y,z =(math.random()-.5)*math.pi*4,(math.random()-.5)*math.pi*4,(math.random()-.5)*math.pi*4
local new_mat = mat4.set_rot_luanti_entity(mat4.new(), x,y,z)
print(santitize_angles_unpack(x,y,z))
print(santitize_angles_unpack(new_mat:get_rot_luanti_entity()))]]


--============================ ENTITY MATRICES =======================================

--random check to see if angles output correctly
print("\n Checking to euler and out euler. Verifying that `matrix1` and `matrix2` matches in `euler->matrix1->euler?->matrix2` for the following euler conversions")

local x,y,z = math.random()*math.pi*2,  math.random()*math.pi*2,  math.random()*math.pi*2
local new_mat = mat4.set_rot_luanti_entity(mat4.new(), x,y,z)
local x2,y2,z2 = new_mat:get_rot_luanti_entity()
print("luanti_entity (random angle) matrices are equivelant: ", check_matrix_equality(new_mat, mat4.set_rot_luanti_entity(mat4.new(), x2,y2,z2)))

--repeat for irrlicht bones
x,y,z = math.random()*math.pi*2,  math.random()*math.pi*2,  math.random()*math.pi*2
new_mat = mat4.set_rot_irrlicht_bone(mat4.identity(), x,y,z)
x2,y2,z2 = new_mat:get_rot_irrlicht_bone()
print("irrlicht_bone (random angle) matrices are equivelant: ", check_matrix_equality(new_mat, mat4.set_rot_irrlicht_bone(mat4.new(), x2,y2,z2)))

print("\n Checking edge cases for euler (where gimbal lock occours)")
--check if edge cases work properly
x,y,z = math.pi/2,  math.random()*math.pi*2,  math.random()*math.pi*2
new_mat = mat4.set_rot_luanti_entity(mat4.identity(), x,y,z)
x2,y2,z2 = new_mat:get_rot_luanti_entity()
print("luanti_entity matrices are equivelant at `x=math.pi/2 or -math.pi/2:` ", check_matrix_equality(new_mat, mat4.set_rot_luanti_entity(mat4.new(), x2,y2,z2)))

--check if edge cases work properly
x,y,z = math.random()*math.pi*2,  math.pi/2,  math.random()*math.pi*2
new_mat = mat4.set_rot_irrlicht_bone(mat4.new(), x,y,z)
x2,y2,z2 = new_mat:get_rot_irrlicht_bone()
-- euler1->matrix->euler2; check euler1==euler2
print("irrlicht_bone matrices are equivelant at `y=math.pi/2 or -math.pi/2`: ", check_matrix_equality(new_mat, mat4.set_rot_irrlicht_bone(mat4.new(), x2,y2,z2)))

print("\n==================== END OF MATRIX UNIT TESTs =============================")


--[[local m00 = new_mat[1]
local m12 = new_mat[7]
local m22 =
local m02 = , , new_mat[11]
x = math.atan2(m12, m22);
y = math.atan2(-m02, math.sqrt(1.0 - m02 * m02));
z = math.atan2(m01, m00);
print()]]



--[[local quat = mtul.math.quat
print("\n comparing `euler to matrix` & `euler to quaternion` matrix outputs")
x,y,z = math.random()*math.pi*2,  math.random()*math.pi*2,  math.random()*math.pi*2
local mat1 = mat4.set_rot_zxy(mat4.new(), x,y,z)
local new_quat = quat.new():from_euler_zxy(x,y,z)
local mat2 = mat4.set_rot_from_quaternion(mat4.new(), new_quat)
--local new_quat = mtul.quat.from_euler_
print(mat1)
print(mat2)
print(check_matrix_equality(mat1,mat2))]]