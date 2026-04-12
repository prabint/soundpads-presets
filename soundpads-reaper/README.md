### Starting

1. Use Reaper
2. Use GP5 mapping for drums for Addictive Drums
3. Preferred output is 48kHz, Stereo, 16-bit

### How to update with new sound effect

1. Open `soundpads_notes.rpp` or `soundpads_drums.rpp`. It has a track with all the notes and all Items are named by
   note scale.
2. Note: The first track has Item Lock + Control Lock, Frozen, as it is the original track other tracks should be based
   off
3. Duplicate Track 1 to create Track 2. Now we will work on Track 2.
4. Deselect "Lock Track Contorls" and then update to your preferred vst FX.
5. If all notes are of length say 5 sec, select all items of Track 2, press F2, set length to 5. Then run
   `extend_note.lua` and `arrange.lua`.
6. Note: To change fade out or edit any items, just unlock items using "Item properties". Fade won't work on midi but
   will work once we convert it to wav. See next steps.
7. Select all the items in Track 2 and select "Apply track/take FX to items as new take". This will glue wav of each
   midi. We need to unglue them.
8. With all items in Track 2 selected, now click Item -> Take -> Explode all takes to new tracks. Now there are 2 new
   tracks (4
   total). We are only interested in the wav track.
9. Trim tracks if needed, especially Snare, Kick and Close HiHat
10. The name of each wav item has "render 004" appended to it in the process. So, we need to rename each item from "C4
    render 004.wav" back to "C4.wav". We can run custom script `rename.lua`. Run it.
11. Render to File (ctrl + cmd + R). Source: "Selected media items via master", File name: "$item - Piano", 48000Hz, 16
    bit PCM, Uncheck Tail, Click Render files.
12. Optional: Delete those 3 tracks, do not delete the locked track.
13. To zip all the sound files, use cmd so that non-sense folders like .DS etc are ignored
   ```
   cd "Rock Drumkit"
   zip -r -X "Rock Drumkit.zip" .
   ```

### rename.lua

```
-- Reaper Script to Rename Selected Items with Corrected Pattern Matching
-- Removes " render [number]" from item names

-- Show ReaScript console for logging
reaper.ShowConsoleMsg("Starting renaming script...\n")

-- Loop through selected items
local num_items = reaper.CountSelectedMediaItems(0)
reaper.ShowConsoleMsg("Number of selected items: " .. num_items .. "\n")

for i = 0, num_items - 1 do
    local item = reaper.GetSelectedMediaItem(0, i)
    local take = reaper.GetActiveTake(item)
    if take then
        -- Get the current name of the take
        local retval, take_name = reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", "", false)
        
        reaper.ShowConsoleMsg("Original name: " .. take_name .. "\n")
        
        -- Perform the renaming using Lua string patterns
        local new_name = take_name:gsub(" render %d+", "")
        
        reaper.ShowConsoleMsg("New name: " .. new_name .. "\n")
        
        -- Set the new name for the take
        reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", new_name, true)
    else
        reaper.ShowConsoleMsg("No active take found for item " .. i + 1 .. "\n")
    end
end

-- Update the Reaper UI to reflect the changes
reaper.UpdateArrange()

reaper.ShowConsoleMsg("Renaming script completed.\n")

```

### arrange.lua

```
-- ReaScript: Place selected items one after another (no overlap)
reaper.Undo_BeginBlock()

local num_items = reaper.CountSelectedMediaItems(0)
if num_items == 0 then return end

-- Collect items with positions
local items = {}
for i = 0, num_items - 1 do
    local item = reaper.GetSelectedMediaItem(0, i)
    local pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    table.insert(items, { item = item, pos = pos })
end

-- Sort items by original position
table.sort(items, function(a, b) return a.pos < b.pos end)

-- Place each item right after the previous one
local current_position = items[1].pos
for i = 1, #items do
    local item = items[i].item
    reaper.SetMediaItemInfo_Value(item, "D_POSITION", current_position)

    local length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    current_position = current_position + length
end

reaper.UpdateArrange()
reaper.Undo_EndBlock("Place selected items end-to-end", -1)
```

### extend_note.lua

```
-- ReaScript: Extend the single note in each selected MIDI item to fill the item length
reaper.Undo_BeginBlock()

local num_items = reaper.CountSelectedMediaItems(0)
for i = 0, num_items - 1 do
    local item = reaper.GetSelectedMediaItem(0, i)
    local take = reaper.GetActiveTake(item)
    if take and reaper.TakeIsMIDI(take) then
        local _, note_count, _, _ = reaper.MIDI_CountEvts(take)
        if note_count > 0 then
            local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
            local item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
            local item_end = item_pos + item_len

            -- Get first note (you can enhance this to find longest or lowest, etc.)
            local retval, sel, muted, startppq, endppq, chan, pitch, vel = reaper.MIDI_GetNote(take, 0)
            if retval then
                local new_end_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, item_end)
                reaper.MIDI_SetNote(take, 0, sel, muted, startppq, new_end_ppq, chan, pitch, vel, true)
                reaper.MIDI_Sort(take)
            end
        end
    end
end

reaper.UpdateArrange()
reaper.Undo_EndBlock("Extend note to match item length", -1)
```