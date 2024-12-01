

local mat4 = mtul.math.mat4
local quat = mtul.math.quat
local vec3 = mtul.math.vec3
local function check_matrix_equality(m1,m2)
    for i = 1,16 do
        if math.abs(m1[i]-m2[i]) > 0.001 then
            return false
        end
    end
    return true
end

print("================== BEGINNING QUATERNION UNIT TESTs =======================")

--print("\n comparing mul_vec3 and rotate_vec3 with random quat on forward facing unit dir")
--[[local new_quat = mtul.math.quat.from_angle_axis((math.random()-.5)*math.pi*4, mtul.math.vec3.new(math.random(), math.random(), math.random())):normalize()
local forward = vec3.new(0,0,1)
print(new_quat:mul_vec3(forward))
print(new_quat:rotate_vec3(forward))
print("identity quat:")
new_quat = quat.new(0,0,0,1)
print(new_quat:mul_vec3(forward))
print(new_quat:rotate_vec3(forward))]]



local new_quat = mtul.math.quat.from_angle_axis((math.random()-.5)*math.pi*4, mtul.math.vec3.new(math.random(), math.random(), math.random())):normalize()
local to_mat_from_quat = mtul.math.mat4.from_quaternion(new_quat)
local to_mat_from_axis_from_quat = mat4.from_angle_axis(new_quat:to_angle_axis())
--should tell us that quat to matrix is working fine... trusting the original creators anyway...
print("\n comparing `quat->matrix` to old `quat->angle_axis->matrix`. Matches:",
    check_matrix_equality(
        to_mat_from_quat,  --new mthod which generates a matrix
        to_mat_from_axis_from_quat --old CPML method of from quaternion that just hooks through angle axis
    )
)
if not check_matrix_equality(to_mat_from_quat, to_mat_from_axis_from_quat) then
    print(to_mat_from_quat)
    print(to_mat_from_axis_from_quat)
end

--double check (I dont trust the old method of converting to axis angle.)
local x = vec3.new(1,0,0); x=new_quat:mul_vec3(x)
local y = vec3.new(0,1,0); y=new_quat:mul_vec3(y)
local z = vec3.new(0,0,1); z=new_quat:mul_vec3(z)
local rotated_mat = mat4.new({ --this probably is confusing, each row her is a column.
    x.x, x.y, x.z, 0,
    y.x, y.y, y.z, 0,
    z.x, z.y, z.z, 0,
    0, 0, 0, 1
})
local equal = check_matrix_equality(rotated_mat, to_mat_from_quat)
print("comparing matrix generated from rotating basis vectors to `quat->matrix`. Matches:", equal)
if not equal then
    print(to_mat_from_quat)
    print(rotated_mat)
end

x,y,z = math.random()*math.pi*2,  math.random()*math.pi*2,  math.random()*math.pi*2
local matrix1 = mat4.set_rot_irrlicht_bone(mat4.identity(), x,y,z) --sample random matrix, what it is shouldn't matter as long as its special orthogonal (aka a rotation matrix)

new_quat = mat4.to_quaternion(matrix1) --this is the independent variable in which we are testing- wether this code works.
local matrix2 = mat4.from_quaternion(new_quat)
print("checking `matrix1=matrix2` in `matrix1->quaternion->matrix2`. Matches:", check_matrix_equality(matrix1, matrix2))
if not check_matrix_equality(matrix1, matrix2) then
    print(matrix1)
    print(matrix2)
end

print("\n checking euler functions")
x,y,z = math.random()*math.pi*2,  math.random()*math.pi*2,  math.random()*math.pi*2
matrix1 = mat4.set_rot_luanti_entity(mat4.identity(), x,y,z)
new_quat = quat.from_matrix(matrix1)
local x2,y2,z2 = new_quat:get_euler_luanti_entity()
matrix2 = mat4.set_rot_luanti_entity(mat4.identity(), x2,y2,z2)

print("(quat->euler) checking `matrix1=matrix2` in `euler->matrix1->quat->euler->matrix2 (ZXY/luanti entity)`. Matrices match:", check_matrix_equality(matrix1, matrix2))
if not check_matrix_equality(matrix1, matrix2) then
    print(matrix1)
    print(matrix2)
    print(x,y,z)
    print(x2,y2,z2)
end

x,y,z = math.random()*math.pi*2,  math.random()*math.pi*2,  math.random()*math.pi*2
matrix1 = mat4.set_rot_irrlicht_bone(mat4.identity(), x,y,z)
new_quat = quat.from_matrix(matrix1)
x2,y2,z2 = new_quat:get_euler_irrlicht_bone()
matrix2 = mat4.set_rot_irrlicht_bone(mat4.identity(), x2,y2,z2)

print("(quat->euler) checking `matrix1=matrix2` in `euler->matrix1->quat->euler->matrix2 (XYZ/irrlicht bone)`. Matrices match:", check_matrix_equality(matrix1, matrix2))
if not check_matrix_equality(matrix1, matrix2) then
    print(matrix1)
    print(matrix2)
    print(x,y,z)
    print(x2,y2,z2)
end

x,y,z = math.random()*math.pi*2,  math.random()*math.pi*2,  math.random()*math.pi*2
matrix2 = mat4.set_rot_luanti_entity(mat4.identity(), x,y,z)
new_quat = quat.from_euler_luanti_entity(x,y,z)
matrix1 = mat4.from_quaternion(new_quat)
print("(euler->quat) checking `matrix1=matrix2` in `euler->quat->matrix1, euler->matrix2 (ZXY/luanti entity)`, Matches:", check_matrix_equality(matrix1, matrix2))
if not check_matrix_equality(matrix1, matrix2) then
    print(x,y,z)
    print(matrix1)
    print(matrix2)
end

x,y,z = math.random()*math.pi*2,  math.random()*math.pi*2,  math.random()*math.pi*2
matrix2 = mat4.set_rot_irrlicht_bone(mat4.identity(), x,y,z)
new_quat = quat.from_euler_irrlicht_bone(x,y,z)
matrix1 = mat4.from_quaternion(new_quat)
print("(euler->quat) checking `matrix1=matrix2` in `euler->quat->matrix1, euler->matrix2 (XYZ/irrlicht bone)`, Matches:", check_matrix_equality(matrix1, matrix2))
if not check_matrix_equality(matrix1, matrix2) then
    print(x,y,z)
    print(matrix1)
    print(matrix2)
end

print("(eulur->quat->euler)")
print("\n==================== END OF QUATERNION UNIT TESTs =============================")
