--- Programming the 4ms Ensemble Oscillator
function init()
    output[1].slew = 0.001
end

Intervals = {
    {name = "major ", notes = {0,4,7}},     -- 1
    {name = "minor", notes = {0,3,7}},      -- 2
    {name = "°", notes = {0,3,6}},          -- 3
    {name = "+", notes = {0,4,8}},          -- 4
    {name = "sus4", notes = {0,5,7}},       -- 5
    {name = "maj7", notes = {0,4,7,11}},    -- 6
    {name = "7", notes = {0,4,7,10}},       -- 7
    {name = "m7", notes = {0,3,7,10}},      -- 8
    {name = "m6", notes = {0,3,7,9}},       -- 9
    {name= "ø", notes = {0,3,6,10}},        -- 10
}

    
function Program(interval)
    interval = Intervals[interval]
    step = 0
    
    print(interval.name)
    metro[1].event = function(c)

        if step == #interval then 
            output[2].volts = 0
            metro[1]:stop()
            print('done') 
        end

        step = step + c%2

        if (c+1)%2 == 0 then
            print(step)
            output[1].volts = interval.notes[step] / 12
            print(interval.intervals[step] / 12)
            output[2].volts = 5
        else
            print('off')
            output[2].volts = 0
        end 

        
        
    end

    metro[1].time = 0.25
    metro[1]:start()
end