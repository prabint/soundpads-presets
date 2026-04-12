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
