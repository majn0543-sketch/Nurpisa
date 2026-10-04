local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CS = game:GetService("CollectionService")

local player = Players.LocalPlayer
local DEV_IDS = {} -- add your UserId here
if not (RunService:IsStudio() or table.find(DEV_IDS, player.UserId)) then return end

local CORRECT_KEY = "Nurgisa_gay333"

--------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------
local function getChar()
	local char = player.Character or player.CharacterAdded:Wait()
	return char, char:WaitForChild("Humanoid"), char:WaitForChild("HumanoidRootPart")
end

local function posOf(obj)
	if obj:IsA("Model") then return obj:GetPivot().Position end
	if obj:IsA("BasePart") then return obj.Position end
end

local function nearest(list)
	local _, _, root = getChar()
	local best, bestDist
	for _, obj in ipairs(list) do
		local p = posOf(obj)
		if p then
			local d = (p - root.Position).Magnitude
			if not bestDist or d < bestDist then best, bestDist = obj, d end
		end
	end
	return best
end

local function teleportTo(obj)
	if not obj then return end
	local _, _, root = getChar()
	local p = posOf(obj)
	if p then root.CFrame = CFrame.new(p + Vector3.new(0, 4, 0)) end
end

local function otherPlayers()
	local out = {}
	for _, pl in ipairs(Players:GetPlayers()) do
		if pl ~= player and pl.Character then table.insert(out, pl.Character) end
	end
	return out
end

--------------------------------------------------------------------
-- ESP
--------------------------------------------------------------------
local espOn = { Players = false, Monsters = false, Keys = false, Items = false }
local espColor = {
	Players = Color3.fromRGB(255, 255, 80),
	Monsters = Color3.fromRGB(255, 60, 60),
	Keys = Color3.fromRGB(255, 170, 40),
	Items = Color3.fromRGB(80, 255, 120),
}
local function targets(cat)
	if cat == "Players" then return otherPlayers() end
	if cat == "Monsters" then return CS:GetTagged("Monster") end
	if cat == "Keys" then return CS:GetTagged("Key") end
	return CS:GetTagged("Item")
end

local function refreshESP()
	for cat, color in pairs(espColor) do
		local name = "DevESP_" .. cat
		local current = {}
		if espOn[cat] then
			for _, obj in ipairs(targets(cat)) do
				current[obj] = true
				if not obj:FindFirstChild(name) then
					local h = Instance.new("Highlight")
					h.Name = name
					h.FillColor, h.OutlineColor = color, color
					h.FillTransparency = 0.6
					h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					h.Parent = obj
				end
			end
		end
		-- cleanup
		for _, tag in ipairs({ "Monster", "Key", "Item" }) do
			for _, obj in ipairs(CS:GetTagged(tag)) do
				local h = obj:FindFirstChild(name)
				if h and not current[obj] then h:Destroy() end
			end
		end
		for _, pl in ipairs(Players:GetPlayers()) do
			local h = pl.Character and pl.Character:FindFirstChild(name)
			if h and not current[pl.Character] then h:Destroy() end
		end
	end
end
task.spawn(function()
	while true do
		refreshESP()
		task.wait(1)
	end
end)

--------------------------------------------------------------------
-- Themes
--------------------------------------------------------------------
local themes = {
	Blue = { bg = Color3.fromRGB(14, 24, 48), btn = Color3.fromRGB(40, 90, 200), text = Color3.new(1, 1, 1) },
	Red = { bg = Color3.fromRGB(45, 14, 14), btn = Color3.fromRGB(190, 40, 40), text = Color3.new(1, 1, 1) },
	White = { bg = Color3.fromRGB(240, 240, 240), btn = Color3.fromRGB(200, 200, 205), text = Color3.new(0.1, 0.1, 0.1) },
	Black = { bg = Color3.fromRGB(12, 12, 12), btn = Color3.fromRGB(50, 50, 55), text = Color3.new(1, 1, 1) },
	Green = { bg = Color3.fromRGB(12, 40, 22), btn = Color3.fromRGB(35, 150, 80), text = Color3.new(1, 1, 1) },
}
local currentTheme = "Blue"
local themed = {} -- { obj, kind }
local mainFrame

local function reg(obj, kind)
	table.insert(themed, { obj = obj, kind = kind })
	local t = themes[currentTheme]
	if kind == "bg" then obj.BackgroundColor3 = t.bg
	elseif kind == "btn" then obj.BackgroundColor3 = t.btn; obj.TextColor3 = t.text
	elseif kind == "text" then obj.TextColor3 = t.text end
end

local function applyTheme(name)
	currentTheme = name
	local t = themes[name]
	for _, e in ipairs(themed) do
		if e.kind == "bg" then e.obj.BackgroundColor3 = t.bg
		elseif e.kind == "btn" then e.obj.BackgroundColor3 = t.btn; e.obj.TextColor3 = t.text
		elseif e.kind == "text" then e.obj.TextColor3 = t.text end
	end
end

--------------------------------------------------------------------
-- UI building blocks
--------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "PiggyDevMenu"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function corner(o, r) Instance.new("UICorner", o).CornerRadius = UDim.new(0, r or 8) end

local function makeButton(parent, text, size, pos)
	local b = Instance.new("TextButton")
	b.Size = size or UDim2.new(1, 0, 0, 36)
	if pos then b.Position = pos end
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.BorderSizePixel = 0
	b.Parent = parent
	corner(b)
	reg(b, "btn")
	return b
end

local function makeLabel(parent, text, size)
	local l = Instance.new("TextLabel")
	l.Size = size or UDim2.new(1, 0, 0, 24)
	l.BackgroundTransparency = 1
	l.Text = text
	l.Font = Enum.Font.GothamBold
	l.TextSize = 14
	l.Parent = parent
	reg(l, "text")
	return l
end

local function listFrame(parent)
	local f = Instance.new("ScrollingFrame")
	f.Size = UDim2.new(1, -10, 1, -50)
	f.Position = UDim2.new(0, 5, 0, 45)
	f.BackgroundTransparency = 1
	f.BorderSizePixel = 0
	f.ScrollBarThickness = 4
	f.AutomaticCanvasSize = Enum.AutomaticSize.Y
	f.CanvasSize = UDim2.new()
	f.Visible = false
	f.Parent = parent
	local l = Instance.new("UIListLayout", f)
	l.Padding = UDim.new(0, 6)
	return f
end

--------------------------------------------------------------------
-- Main menu (hidden until key accepted)
--------------------------------------------------------------------
local function buildMenu()
	mainFrame = Instance.new("Frame")
	mainFrame.Size = UDim2.new(0, 340, 0, 270)
	mainFrame.Position = UDim2.new(0.5, -170, 0.5, -135)
	mainFrame.BorderSizePixel = 0
	mainFrame.Active = true
	mainFrame.Draggable = true
	mainFrame.Parent = gui
	corner(mainFrame, 12)
	reg(mainFrame, "bg")

	-- tabs bar
	local names = { "Visual", "Teleport", "Player", "Settings" }
	local pages, tabButtons = {}, {}
	for i, n in ipairs(names) do
		local tb = makeButton(mainFrame, n, UDim2.new(0.25, -6, 0, 34), UDim2.new((i - 1) * 0.25, 4, 0, 5))
		tb.TextSize = 12
		tabButtons[n] = tb
		pages[n] = listFrame(mainFrame)
		tb.Activated:Connect(function()
			for _, p in pairs(pages) do p.Visible = false end
			pages[n].Visible = true
		end)
	end
	pages.Visual.Visible = true

	-- Visual page: ESP toggles
	for _, cat in ipairs({ "Players", "Monsters", "Keys", "Items" }) do
		local b = makeButton(pages.Visual, "ESP " .. cat .. ": OFF")
		b.Activated:Connect(function()
			espOn[cat] = not espOn[cat]
			b.Text = "ESP " .. cat .. (espOn[cat] and ": ON" or ": OFF")
			refreshESP()
		end)
	end

	-- Teleport page
	local function tpButton(label, getList)
		local b = makeButton(pages.Teleport, label)
		b.Activated:Connect(function() teleportTo(nearest(getList())) end)
	end
	tpButton("TP to nearest Item", function() return CS:GetTagged("Item") end)
	tpButton("TP to nearest Key", function() return CS:GetTagged("Key") end)
	tpButton("TP to nearest Player", otherPlayers)
	tpButton("TP to nearest Monster", function() return CS:GetTagged("Monster") end)

	-- Player page
	local speed, jump = 16, 50
	local function stepper(label, get, set, step, min, max)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 40)
		row.BackgroundTransparency = 1
		row.Parent = pages.Player
		local minus = makeButton(row, "-", UDim2.new(0, 50, 1, 0), UDim2.new(0, 0, 0, 0))
		local plus = makeButton(row, "+", UDim2.new(0, 50, 1, 0), UDim2.new(1, -50, 0, 0))
		local lbl = makeLabel(row, label .. ": " .. get(), UDim2.new(1, -110, 1, 0))
		lbl.Position = UDim2.new(0, 55, 0, 0)
		local function change(d)
			set(math.clamp(get() + d, min, max))
			lbl.Text = label .. ": " .. get()
		end
		minus.Activated:Connect(function() change(-step) end)
		plus.Activated:Connect(function() change(step) end)
	end
	local function applyStats()
		local _, hum = getChar()
		hum.WalkSpeed = speed
		hum.UseJumpPower = true
		hum.JumpPower = jump
	end
	stepper("Speed", function() return speed end, function(v) speed = v; applyStats() end, 8, 8, 120)
	stepper("Jump", function() return jump end, function(v) jump = v; applyStats() end, 10, 10, 200)
	local reset = makeButton(pages.Player, "Reset to default")
	reset.Activated:Connect(function() speed, jump = 16, 50; applyStats() end)
	player.CharacterAdded:Connect(function() task.wait(0.5); applyStats() end)

	-- Settings page: themes + transparency
	makeLabel(pages.Settings, "Theme")
	for _, n in ipairs({ "Blue", "Red", "White", "Black", "Green" }) do
		local b = makeButton(pages.Settings, n)
		b.Activated:Connect(function() applyTheme(n) end)
	end
	local trans = 0
	local tlabel = makeLabel(pages.Settings, "Transparency: 0%")
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 40)
	row.BackgroundTransparency = 1
	row.Parent = pages.Settings
	local m = makeButton(row, "-", UDim2.new(0.5, -3, 1, 0), UDim2.new(0, 0, 0, 0))
	local p = makeButton(row, "+", UDim2.new(0.5, -3, 1, 0), UDim2.new(0.5, 3, 0, 0))
	local function setTrans(v)
		trans = math.clamp(v, 0, 0.9)
		mainFrame.BackgroundTransparency = trans
		tlabel.Text = "Transparency: " .. math.floor(trans * 100 + 0.5) .. "%"
	end
	m.Activated:Connect(function() setTrans(trans - 0.1) end)
	p.Activated:Connect(function() setTrans(trans + 0.1) end)

	-- close / reopen
	local close = makeButton(gui, "X", UDim2.new(0, 34, 0, 34), UDim2.new(0.5, 140, 0.5, -170))
	close.Activated:Connect(function()
		mainFrame.Visible = not mainFrame.Visible
		close.Text = mainFrame.Visible and "X" or "+"
	end)
end

--------------------------------------------------------------------
-- Key screen
--------------------------------------------------------------------
local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(0, 300, 0, 170)
keyFrame.Position = UDim2.new(0.5, -150, 0.5, -85)
keyFrame.BorderSizePixel = 0
keyFrame.Parent = gui
corner(keyFrame, 12)
reg(keyFrame, "bg")

local title = makeLabel(keyFrame, "Enter key", UDim2.new(1, 0, 0, 30))
title.Position = UDim2.new(0, 0, 0, 8)
title.TextSize = 18

local box = Instance.new("TextBox")
box.Size = UDim2.new(1, -30, 0, 38)
box.Position = UDim2.new(0, 15, 0, 48)
box.PlaceholderText = "Key..."
box.Text = ""
box.ClearTextOnFocus = false
box.Font = Enum.Font.Gotham
box.TextSize = 15
box.TextColor3 = Color3.new(1, 1, 1)
box.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
box.BorderSizePixel = 0
box.Parent = keyFrame
corner(box)

local status = makeLabel(keyFrame, "", UDim2.new(1, 0, 0, 20))
status.Position = UDim2.new(0, 0, 0, 92)
status.TextSize = 12

local submit = makeButton(keyFrame, "Submit", UDim2.new(1, -30, 0, 38), UDim2.new(0, 15, 0, 120))
submit.Activated:Connect(function()
	if box.Text == CORRECT_KEY then
		keyFrame:Destroy()
		buildMenu()
	else
		status.Text = "Wrong key"
		status.TextColor3 = Color3.fromRGB(255, 80, 80)
	end
end)
