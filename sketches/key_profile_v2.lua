---- Key Profile Quantizer V2
--[[
    Using scale mode with lookup tables to introduce probability to note selection.

    This worked brilliantly! Unlike windows, the Scale mode provides an index that is more stable than establishing set windows. Another surprise is providing variaitons in 
]]
Profile_A = {
    0,0,0,4,4,7,7,10,10,2,5,9
}

Profile_B = {
    0,0,0,4,4,7,7,10,10,14,21,17
}

function init() 
    input[1].mode('scale', {0,1,2,3,4,5,6,7,8,9,10,11})
    input[2].mode('scale', {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19},20)
end

input[1].scale = function(s)
    -- index, note, volts, octave
    output[1].volts = Profile_A[s.index] * 1/12 + s.octave
    output[2].volts = Profile_B[s.index] * 1/12 + s.octave
end
