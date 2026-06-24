local chart, cycle, gui, mouse
local SButton =--Size(of)Button
	{66,23}
local NWindow, NButton =--Name(of)Window, Name(of)Button
	"LesserLooper", "Loop To"
local FWindow =-- Flags(of)Window
	0--void
	+ 2--no move
	+ 43--no decoration
	+ 64--auto resize
	+ 128--no background
	+ 256--no saved settings
local DCTimer = 0--Double-Click Timer
local MHeld = false--Mouse Held
local MPos--MousePos
local floor, min, split = math.floor, math.min, math.modf --faster by ~1.5x
local function main()
	gui.Begin(NWindow, FWindow)
	if chart.refresh then
		chart.refresh = false
		local Count = #chart.notes
		if Count == 0 then
			gui.Off()
			print("e", "", "Needs Hit Object to perform Loop")
			return
		end
		cycle.Cap = chart.notes[Count].StartTime
	end
	if gui.Button(NButton, SButton) then
		local X2Click = (os.clock() - DCTimer) < 0.2
		DCTimer = os.clock()
		if X2Click then
			if cycle.Running then
				cycle.Running = false
				cycle.Start = nil
				NButton = "Loop To"
			else
				cycle.Running = true
				cycle.Start = 0
				NButton = "00:00.000"
			end
		else
			local Time, Cap = state.SongTime, cycle.Cap
			cycle.Start = floor(Cap > Time and Time or Cap)
			local Min, Sec = split(cycle.Start/60/1000)
			NButton = ("%02i:%06.3f"):format(Min, 60*Sec)
		end
	end
	if Held or (mouse.Click(1) and mouse.ItemHover()) then
		if (not Held)--[[click]] then
			local WPos = gui.Pos()--WindowPos
			MPos = mouse.Pos()
			for i = 1, 2 do
				MPos[i] = MPos[i] - WPos[i]
		end end
		Held = mouse.Down(1)
		local Pos = mouse.Pos()
		Pos[1], Pos[2] =--'tis could be for-looped
			Pos[1] - MPos[1], Pos[2] - MPos[2]
		gui.MoveTo(Pos)
		if (not Held)--[[release]] then
			write(Pos)
	end end
	gui.Close()
	if (cycle.Start) and (state.SongTime >= cycle.End) then
		local CycleTo = cycle.Start
		CycleTo = 0 == CycleTo and 1 or CycleTo--if 0 -> 1
		chart.moveto(tostring(floor(CycleTo)))
end end
local function debug()
	gui.Begin(NWindow, FWindow)
	if gui.Button("Loop To", SButton) then
		print("e", "", "Needs Hit Object to perform Loop")
	end
	gui.Close()
end

function awake()
	gui =
		{
		Begin = imgui.Begin,
		Close = imgui.End,
		Button = imgui.Button,
		LineSame = imgui.SameLine,
		MoveTo = imgui.SetWindowPos,
		Pos = imgui.GetWindowPos,
		}--faster by ~2x
	local iPushC, iPushV =
		imgui.PushStyleColor, imgui.PushStyleVar
	local Color = {.1, .1, .1}
	Color[4] = .7;
	iPushC(21, Color)--Button
	iPushC(23, Color)--ButtonActive
	Color[4] = 1;
	iPushC(22, Color)--ButtonHovered
	iPushV(2, {0, 0})--WindowPadding
	iPushV(4, 0)--WindowBorderSize
	local PPos = read()--Prior Position
	if PPos then--[[Collocts stored Position; sets it. The window is set not to do this itself]]
		imgui.SetNextWindowPos(PPos) end
	chart =
		{
		length = map.TrackLength,--faster by ~2
		notes = map.HitObjects,--faster by ~300x (wow so big~)
		moveto = actions.GoToObjects
		}
	cycle =
		{
		End = chart.length - 100,
		-- Running = false,
		-- Start = nil,
		}
	mouse =
		{
		Click = imgui.IsMouseClicked,
		Down = imgui.IsMouseDown,
		ItemClick = imgui.IsItemClicked,
		ItemHover = imgui.IsItemHovered,
		Pos = imgui.GetMousePos,
		}
	local guiRunning = false
	gui.On, gui.Off =
		function()
			guiRunning = true
			draw = main
		end,
		function()
			guiRunning = false
			gui.Close()
			draw = debug
		end
	listen(function()
		chart.refresh = true
		if (not guiRunning) and #chart.notes ~= 0 then
			gui.On()
	end end)
	local Count = #chart.notes
	if Count == 0 then
		gui.Off()
	else
		cycle.Cap = chart.notes[Count].StartTime
		gui.On()
end end
