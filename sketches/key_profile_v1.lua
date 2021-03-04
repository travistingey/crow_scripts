---- Key Profile Quantizer V1
--[[
    Quantizer Based on Krumhansl-Schmuckler Key Profile

    Using windows just works ok.
    
    Using windows with small boundaries leads to some issues getting stuck between intervals at small windows. One success is that this does a better job centering the key and the occasional blue note adds some spice.
    ]]

profile = {
    0.223,
    0.006,
    0.12,
    0.003,
    0.154,
    0.109,
    0.019,
    0.189,
    0.007,
    0.076,
    0.005,
    0.089
}

profile_thresholds = {
    0.223,
    0.229,
    0.349,
    0.352,
    0.506,
    0.615,
    0.624,
    0.813,
    0.820,
    0.896,
    0.901,
    1
}

window = {}
lookup = {}


function init() 
    for i = 1, 61 do
        local octave = math.floor((i-1)/12)
        local note = (i-1) % 12 + 1
        window[i] = profile_thresholds[note] + octave
        lookup[i] = ( (note-1) / 12 ) + octave
    end

    input[1].mode('window', window)
    input[2].mode('scale', {0,2,4,5,7,9,11})
end

input[1].window = function(i,d)
    
    local note = i % 12

    
    output[1].slew = 0.02
    input[1].query()
    
    output[1].volts = lookup[i]
end

input[2].scale = function(s)
 output[2].volts = s.volts
end