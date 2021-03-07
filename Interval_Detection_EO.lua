------ Chord + Quantized Melody Machine using Crow and Ensemble Oscillator
-- Input 1: Random 0-5 Volts
-- Input 2: Trigger Analysis & Chord Change
-- Output 1: Quantized Melody 
-- Output 2: None
-- Output 3: Ensemble Oscillator 1v/oct / Root Note
-- Output 4: Ensemble Oscillator Scale / Chord Select CV

-- Definition Lists
note_def = {'C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B'}
scale_select= {0, 0.5, 0.9, 1.5, 2, 2.6, 3.2, 3.7, 4.4, 4.9} -- voltage threshold for changing chords in Ensemble Oscillator
Intervals = {
    {name = " oct", notes = {0}, scale = {0,0,0,0,0,0,2,4,5,7,9,11}, select = 1},                       -- 1
    {name = " 5", notes = {0,7}, scale = {0,0,0,2,4,5,7,7,7,9,10,11}, select = 2},                      -- 2
    {name= " major", notes = {0,4,7}, scale = {0,0,0,4,4,4,7,7,2,5,9,11}, select = 3},                  -- 3
    {name = " minor", notes = {0,3,7}, scale = {0,0,3,3,3,7,7,7,2,2,5,9}, select = 4},                  -- 4
    {name = " minor sus4", notes = {0,5,7}, scale = {0,5,5,5,5,7,7,10,10,10,14,9}, select = 5 },        -- 5
    {name = " m7", notes = {0,3,10}, scale = {0,0,3,3,3,7,7,10,10,2,5,9}, select = 6},                  -- 6
    {name= " maj7", notes = {0,4,11}, scale = {0,0,4,4,4,7,7,11,11,2,5,9}, select = 7},                 -- 7
    {name = " stacked fifths", notes = {0,7,2,9}, scale = {0,0,0,7,7,7,14,14,14,21,21,21}, select = 8}, -- 8
    {name = " minor b9/#9", notes = {0,3,5,10}, scale = {0,0,3,3,5,5,7,7,10,10,13,15}, select = 9},     -- 9
    {name = " semitones", notes = {0,1,2,3}, scale = {0,1,2,3,4,5,6,7,8,9,10,11}, select = 10}          -- 10
}

---- Variables
history_length = 16
note_history = {}
note_freq = {0,0,0,0,0,0,0,0,0,0,0,0}
quantize_scale = {0,0,0,4,4,4,7,7,2,5,9,11}
current_chord = {
    root = 0,
    select = 1,
    notes = Intervals[1].notes,
    intervals = Intervals[1].notes
}

---- Array Functions
table.reduce = function (t, fn, start)
    local acc
    for index, value in ipairs(t) do
        if start and index == 1 then
            acc = start
        elseif index == 1 then
            acc = value
        else
            acc = fn(acc, value)
        end
    end
    return acc
end

table.map = function(t,fn)
    local newTable = {}
    for index, value in ipairs(t) do
        newTable[index] = fn(value,index,t)
    end
    return newTable
end

table.concat = function(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end



-- Table to Bit Mask Integer
IntervalsToBitMask = function(scale)
    return table.reduce(scale, function(acc, cur)
        return (1 << cur) | acc
    end, 1 << scale[1])
end

BitMaskToIntervals = function(mask)
    local interval = {}
    for i = 1, 12, 1 do
        if mask >> (i - 1) & 1 == 1 then
            table.insert(interval,1,i - 1)
        end
    end
    return interval
end

-- Table of note frequency - Index is equal to note value
NoteFrequency = function(notes)
    note_freq = {0,0,0,0,0,0,0,0,0,0,0,0}
       
    for i = 1, #notes do
        note = notes[i]
        note_freq[note + 1] = note_freq[note + 1] + 1 
    end

    return note_freq
end

-- Takes note frequency table and sums the frequency of table of intervals
IntervalScore = function(freq, chord)
    local intervals =  chord.intervals
    local score = 0     
    for i = 1, #intervals do
        score = score + freq[intervals[i]+1]
    end

    if #current_chord > 1 then 
        score = (current_chord.mask & chord.mask > 1) and (score + 1) or score    
    end

    return score
end


-- Identify positions in which provided intervals are found
FindIntervals = function(notes, interval, freq)
    local note_mask = IntervalsToBitMask(notes)
    local found = {}
    local interval_mask = IntervalsToBitMask(interval.notes)

    for i = 1, 12, 1 do    
        if (note_mask & interval_mask) == interval_mask then
            local chord = {
                root = i-1,
                name = note_def[i] .. interval.name,
                select = interval.select,
                scale = interval.scale,
                notes = table.map(interval.notes,function(d) return (d + i - 1)%12 end),
                intervals = interval.notes
            }

            chord.mask = IntervalsToBitMask(chord.notes)
            chord.score = IntervalScore(freq,chord)

            table.insert(found,1,chord)
         end

    note_mask = (note_mask >> 1) | (note_mask << 11) & 4095
    end

    return found
end

-- Init
function init()
    start = time()
    input[1].mode('scale', {0,1,2,3,4,5,6,7,8,9,10,11})
    input[2].mode('change')
end


-- Runtime
input[2].change = function(c)
    if c and #note_history >= 12 then
        local freq = NoteFrequency(note_history)
        local found = {}
    
        for index, interval in ipairs(Intervals) do
            table.concat(found, FindIntervals(note_history, interval, freq) )
        end
       
        if(#found > 0) then
            table.sort(found, function (a,b)
                return a.score > b.score
            end)
            print(found[1].name)
            quantize_scale = found[1].scale
            output[3].volts = found[1].root / 12
            output[4].volts = scale_select[found[1].select]
        end
      
    end 
end

input[1].scale = function(s)
    if #note_history == history_length then
        table.remove(note_history,16)
    end

    table.insert(note_history,1,quantize_scale[s.index] % 12)
    output[1].volts = quantize_scale[s.index] * 1/12
end