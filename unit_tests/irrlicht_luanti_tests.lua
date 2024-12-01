local cos = math.cos
local sin = math.sin
local m = leef.math
local mat4 = leef.math.mat4

local pitch_ZY = function(a)
    local temp = mat4.new()
    temp[6] = cos(a)
    temp[7] = sin(a)
    temp[10] = -sin(a)
    temp[11] = cos(a)
    return temp
end
local pitch_ZY2 = function(a)
    local temp = mat4.new()
    temp[6] = cos(a)
    temp[7] = -sin(a)
    temp[10] = sin(a)
    temp[11] = cos(a)
    return temp
end

local roll_XY = function(a)
    local temp = mat4.new()
    temp[1] = cos(a)
    temp[2] = sin(a)
    temp[5] = -sin(a)
    temp[6] = cos(a)
    return temp
end
local roll_XY2 = function(a)
    local temp = mat4.new()
    temp[1] = cos(a)
    temp[2] = -sin(a)
    temp[5] = sin(a)
    temp[6] = cos(a)
    return temp
end
local yaw_ZX = function(a)
    local temp = mat4.new()
    temp[1] = cos(a)
    temp[3] = -sin(a)
    temp[9] = sin(a)
    temp[11] = cos(a)
    return temp
end
local yaw_ZX2 = function(a)
    local temp = mat4.new()
    temp[1] = cos(a)
    temp[3] = sin(a)
    temp[9] = -sin(a)
    temp[11] = cos(a)
    return temp
end
local pitch_transforms = {
    pitch = pitch_ZY,
    pitch_cw = pitch_ZY2,
}
local roll_transforms = {
    roll = roll_XY,
    roll_cw = roll_XY2
}
local yaw_transforms = {
    yaw = yaw_ZX,
    yaw_cw = yaw_ZX2
}
local possible_orders = {
    {1,2,3},
    {1,3,2},

    {2,3,1},
    {2,1,3},

    {3,2,1},
    {3,1,2}
}
local matrix_tolerance = .00001
local function check_matrix_equality(m1,m2)
    for i = 1,16 do
        if math.abs(m1[i]-m2[i]) > 0.001 then
            return false
        end
    end
    return true
end

local function make_funcs_human_readable(str)
    for i, v in pairs(pitch_transforms) do
        str=string.gsub(str, tostring(v), i)
    end
    for i, v in pairs(roll_transforms) do
        str=string.gsub(str, tostring(v), i )
    end
    for i, v in pairs(yaw_transforms) do
        str=string.gsub(str, tostring(v), i)
    end
    return str
end

function leef.math.find_matrix_rotation_order(check_func)
    --x,y,z
    local euler = {(math.random()-.5)*math.pi*4, (math.random()-.5)*math.pi*4, (math.random()-.5)*math.pi*4}
    local output = check_func(mat4.new(), euler[1],euler[2],euler[3])
    local iter = 0
    local running_order
    for _, p_tf in pairs(pitch_transforms)  do
        for _, y_tf in pairs(yaw_transforms)  do
            for _, r_tf in pairs(roll_transforms) do
                --now that we have every combination, get every order of every combination. this is disusting by the way.
                for _, order in pairs(possible_orders) do
                    iter = iter + 1
                    --intrinsic order is pitch yaw roll for this check, meaning that 1 is assigned to pitch and so fourth.
                    local matrices = {p_tf, y_tf, r_tf}
                    local active_mat = mat4.new()
                    running_order = nil
                    for i=1,3 do
                        local func = matrices[order[i]]
                        running_order = (running_order and running_order .." * "..tostring(func)) or tostring(func)
                        active_mat = active_mat*func(euler[order[i]])
                    end
                    --print("#"..iter, make_funcs_human_readable(running_order))
                    if check_matrix_equality(output, active_mat) then
                        print(make_funcs_human_readable(running_order))
                        --return true
                    end
                end
            end
        end
    end
    return running_order
end
print("================== BEGINNING LUANTI AND IRRLICHT UNIT TESTs =======================")

local find_rot_order = leef.math.find_matrix_rotation_order
print("\n checking sanity of tests:")
local _tempeuler = {(math.random()-.5)*math.pi*4, (math.random()-.5)*math.pi*4, (math.random()-.5)*math.pi*4}
local _testmatrix = leef.math.mat4.set_rot_zxy(mat4.new(), _tempeuler[1],_tempeuler[2],_tempeuler[3])
print("matrix equality check func is sane:", check_matrix_equality(_testmatrix,_testmatrix))
print("matrix equality check func tolerance:", matrix_tolerance)

print("\n Checking rotation orders. Rotation application order is in reverse, these are the literal matrix multiplication order. ")
print("checking rotation matrix `set_rot_luanti_entity`")
find_rot_order(leef.math.mat4.set_rot_luanti_entity)
print("checking `set_rot_irrlicht_bone`")
find_rot_order(leef.math.mat4.set_rot_irrlicht_bone)

print("================== ENDING LUANTI AND IRRLICHT UNIT TESTs =======================")
