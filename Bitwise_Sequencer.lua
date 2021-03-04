--- Bitwise Trigger Sequencer
-- Input 1 Clock
-- Output 1-4 

-- Global Variables
track = {}
current = {}
track_divisions = {2,2,4,1}
divisions = {257,4369,21845,65535}
divisions[0] = 1
count = 0
step = 0

-- Functions
function cycle(pattern)
    return (pattern >> 1) | (pattern << 15) & 65535
end

function seed(t)
    if t then
        return math.random(1,65535) & divisions[t]
    else
        return math.random(1,65535)
    end    
end

function reset()
    for i = 1,4 do
        track[i] = seed(track_divisions[i])
    end
end

-- Runtime!
function init ()
    input[1].mode('change')
    input[2].mode('change')
    reset()
end

input[1].change = function (c)
    if c then
        step = count % 16

        -- Any changes to the track are applied on the first beat
        if(step == 0) then
            for i = 1,4 do
                current[i] = track[i]
            end
        end

        -- Lets spice it up every 4 measures
        if count % 64 == 48 then
            print('Here it comes boi.')
            for i = 1,4 do
                current[i] = (track[i] & 255) | (seed() & 65280)
            end
        end

        -- Play triggers and cycle the pattern 1 step
        for i = 1, 4 do
            output[i].volts = (current[i] & 1 == 1) and 5 or 0
            current[i] = cycle(current[i])
        end
        
        count = count + 1
    else
        -- Turn off outputs
        for i = 1, 4 do
            output[i].volts = 0
        end
    end
end
