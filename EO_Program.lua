--- Programming the 4ms Ensemble Oscillator
-- Out 1: Pitch
-- Out 2: Learn Trigger
-- Direction: Patch EO, Select scale you want to program and enter Learn mode. Run > Program(#) to cycle through intervals. Hit Learn button again to exit.

function init()
    output[1].slew = 0.001
end

Intervals = {
--[[ 1 ]] {name = "major ", notes = {0,4,7}},
--[[ 2 ]] {name = "minor", notes = {0,3,7}},
--[[ 3 ]] {name = "°", notes = {0,3,6}},
--[[ 4 ]] {name = "+", notes = {0,4,8}},
   
--[[ 5 ]] {name = "sus4", notes = {0,5,7}},
--[[ 6 ]] {name = "sus2", notes = {0,2,7}},
--[[ 7 ]] {name = "9sus4", notes = {0,5,7,10,14}}, --5
--[[ 8 ]] {name = "13sus4", notes = {0,5,7,10,21}}, -- 2

--[[ 9 ]] {name = "maj7", notes = {0,4,7,11}},
--[[ 10 ]] {name = "maj9", notes = {0,4,7,11,14}}, -- 1
--[[ 11 ]] {name = "maj13", notes = {0,4,7,11,21}},
--[[ 12 ]] {name = "maj9+6", notes = {0,4,7,9,11,14}}, -- 3

--[[ 13 ]] {name = "7", notes = {0,4,7,10}}, -- 7
--[[ 14 ]] {name = "9", notes = {0,4,7,10,14}},
--[[ 15 ]] {name = "13", notes = {0,4,7,10,21}},
--[[ 16 ]] {name = "7#9", notes = {0,4,7,10,15}},
--[[ 17 ]] {name = "13b9", notes = {0,4,7,10,14,21}},
--[[ 18 ]] {name = "13#9", notes = {0,4,7,10,15,21}}, -- 6
--[[ 19 ]] {name = "7b9", notes = {0,4,7,10,14}},

--[[ 20 ]] {name = "m6", notes = {0,3,7,9}}, -- 9
--[[ 21 ]] {name = "m7", notes = {0,3,7,10}}, -- 8
--[[ 22 ]] {name = "m9", notes = {0,3,7,10,14}},
--[[ 23 ]] {name = "m11", notes = {0,3,7,17}},--4
--[[ 24 ]] {name = "m13", notes = {0,3,7,21}},

--[[ 21 ]] {name= "ø", notes = {0,3,6,10}}, -- 10
}

    
function Program(interval)
    interval = Intervals[interval]
    step = 0
    
    print(interval.name)
    metro[1].event = function(c)
        if step == #interval.notes then 
            output[2].volts = 0
            metro[1]:stop()
            print('done') 
        end

        step = step + c%2

        if (c+1)%2 == 0 then
            print(step)
            output[1].volts = interval.notes[step] / 12
            output[2].volts = 5
        else
            output[1].volts = 0
            output[2].volts = 0
        end 

        
        
    end

    metro[1].time = 0.25
    metro[1]:start()
end