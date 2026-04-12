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

