Loopable, ButtonName = false, "Loop To"
function awake()
	mSongLength = map.TrackLength
	iPushCol = imgui.PushStyleColor
	icol = imgui_col
	iPushCol(icol.Button, {0.1, 0.1, 0.1, .7})
	iPushCol(icol.ButtonHovered, {0.1, 0.1, 0.1, 1})
end
function draw()
	imgui.Begin("##LesserLooper", 2 + 43 + 64 + 128)
		imgui.Button(ButtonName, {66,21})
		if imgui.IsItemClicked() then
			if not map.HitObjects[1] then error("Needs Hit Object to perform Loop") end
			local mLast = map.HitObjects[#map.HitObjects].StartTime
			Loop = state.SongTime
			Loop = (Loop > mLast and mLast or (Loop < 1 and 1 or Loop))
			ButtonName = utils.MillisecondsToTime(Loop == 1 and 0 or Loop)
			if imgui.IsMouseDoubleClicked(0) then
				if Holder then
					ButtonName, Loop = "Loop To", false
				Holder = false
				else
					ButtonName, Loop =  utils.MillisecondsToTime(0), 1
				Holder = true
				end
			end
		elseif (imgui.IsItemHovered() or Held) and imgui.IsMouseDown("Right") then
			Held = true
			local X, Y = table.unpack(imgui.GetMouseDragDelta("Right"))
			if X ~= 0 or Y ~= 0 then
				local x, y = table.unpack(imgui.GetWindowPos())
				imgui.SetWindowPos({x + X, y + Y})
				imgui.ResetMouseDragDelta("Right")
			end
		else
			Held = false
		end
	imgui.End()
SongTimeCheck()
end
function SongTimeCheck()
	if state.SongTime >= mSongLength-100 then
		if Loop then
			local Looper = string.format("%.0f", Loop)--round
			actions.GoToObjects(Looper)
		end
	end
end