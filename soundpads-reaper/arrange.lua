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
