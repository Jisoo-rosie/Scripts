-- =======================================================
-- ULTIMATE WASH THE HOUSE SCRIPT (VIRTUAL ENGINE V3)
-- =======================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local playerGui = player:WaitForChild("PlayerGui")

-- Destroy previous GUI instance if open
if playerGui:FindFirstChild("WashHouseMasterV3") then
	playerGui.WashHouseMasterV3:Destroy()
end

-- 1. Main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WashHouseMasterV3"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- 2. Resizable & Draggable Window Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 350, 0, 390)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -195)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.ZIndex = 1
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- 3. Top Drag Header
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 42)
topBar.BackgroundColor3 = Color3.fromRGB(30, 36, 50)
topBar.BorderSizePixel = 0
topBar.ZIndex = 2
topBar.Parent = mainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 12)
topCorner.Parent = topBar

local title = Instance.new("TextLabel")
title.Text = "🧹 WASH THE HOUSE - Engine V3"
title.Size = UDim2.new(1, -15, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.BackgroundTransparency = 1
title.ZIndex = 3
title.Parent = topBar

-- Draggable Logic
local dragging, dragInput, dragStart, startPos
topBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

topBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- 4. Resize Corner Grip
local resizeGrip = Instance.new("TextLabel")
resizeGrip.Name = "ResizeGrip"
resizeGrip.Text = "◢"
resizeGrip.Size = UDim2.new(0, 24, 0, 24)
resizeGrip.Position = UDim2.new(1, -24, 1, -24)
resizeGrip.TextColor3 = Color3.fromRGB(180, 180, 180)
resizeGrip.BackgroundTransparency = 1
resizeGrip.TextSize = 16
resizeGrip.ZIndex = 15
resizeGrip.Parent = mainFrame

local resizing, resizeStart, startSize
resizeGrip.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		resizing = true
		resizeStart = input.Position
		startSize = mainFrame.Size
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		resizing = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - resizeStart
		local newX = math.max(260, startSize.X.Offset + delta.X)
		local newY = math.max(220, startSize.Y.Offset + delta.Y)
		mainFrame.Size = UDim2.new(0, newX, 0, newY)
	end
end)

-- 5. Scrollable Frame
local scroll = Instance.new("ScrollingFrame")
scroll.Name = "FeatureScroll"
scroll.Size = UDim2.new(1, -16, 1, -56)
scroll.Position = UDim2.new(0, 8, 0, 48)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6
scroll.CanvasSize = UDim2.new(0, 0, 0, 420)
scroll.ZIndex = 4
scroll.Active = true
scroll.Parent = mainFrame

local uiList = Instance.new("UIListLayout")
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Padding = UDim.new(0, 8)
uiList.Parent = scroll

-- Helper to Create Clickable Buttons
local function createButton(text, callback)
	local btnContainer = Instance.new("Frame")
	btnContainer.Size = UDim2.new(1, -8, 0, 42)
	btnContainer.BackgroundTransparency = 1
	btnContainer.ZIndex = 5
	btnContainer.Parent = scroll

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(38, 46, 62)
	btn.TextColor3 = Color3.fromRGB(245, 245, 245)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 15
	btn.Text = text
	btn.ZIndex = 6
	btn.Active = true
	btn.Selectable = true
	btn.Parent = btnContainer

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		callback(btn)
	end)

	return btn
end

-- =======================================================
-- ADVANCED FEATURES IMPLEMENTATION
-- =======================================================

-- Feature 1: Real Virtual Mouse Auto Spray
local autoSpray = false
createButton("💦 Auto Spray (Virtual Clicker): OFF", function(btn)
	autoSpray = not autoSpray
	btn.Text = autoSpray and "💦 Auto Spray (Virtual Clicker): ON" or "💦 Auto Spray (Virtual Clicker): OFF"
	btn.BackgroundColor3 = autoSpray and Color3.fromRGB(36, 140, 75) or Color3.fromRGB(38, 46, 62)
end)

task.spawn(function()
	while true do
		task.wait(0.05)
		if autoSpray then
			local char = player.Character
			if char and char:FindFirstChildOfClass("Tool") then
				-- Simulate Hardware Mouse Click
				VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 0)
				task.wait(0.02)
				VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 0)
			end
		end
	end
end)

-- Feature 2: Smart Remote Auto Clean
local autoClean = false
createButton("⚡ Smart Auto Clean Dirt: OFF", function(btn)
	autoClean = not autoClean
	btn.Text = autoClean and "⚡ Smart Auto Clean Dirt: ON" or "⚡ Smart Auto Clean Dirt: OFF"
	btn.BackgroundColor3 = autoClean and Color3.fromRGB(36, 140, 75) or Color3.fromRGB(38, 46, 62)
end)

task.spawn(function()
	while true do
		task.wait(0.1)
		if autoClean then
			-- Scan for cleaning remotes dynamically
			local cleaningRemotes = {}
			for _, item in ipairs(ReplicatedStorage:GetDescendants()) do
				if item:IsA("RemoteEvent") then
					local name = string.lower(item.Name)
					if string.find(name, "clean") or string.find(name, "wash") or string.find(name, "spray") or string.find(name, "water") or string.find(name, "hit") then
						table.insert(cleaningRemotes, item)
					end
				end
			end

			-- Scan workspace for dirt parts
			for _, v in ipairs(Workspace:GetDescendants()) do
				if v:IsA("BasePart") and v.Transparency < 1 then
					local n = string.lower(v.Name)
					if string.find(n, "dirt") or string.find(n, "mud") or string.find(n, "stain") or string.find(n, "clean") or v:FindFirstChild("DirtHealth") then
						-- Fire found remotes or clean directly
						for _, remote in ipairs(cleaningRemotes) do
							remote:FireServer(v, 100)
						end
						if v:FindFirstChild("DirtHealth") then
							v.DirtHealth.Value = 0
							v.Transparency = 1
						end
					end
				end
			end
		end
	end
end)

-- Feature 3: Deep Tool Power & Range Boost
createButton("💥 Boost Tool Range & Power (Equipped Tool)", function(btn)
	local char = player.Character
	local tool = char and char:FindFirstChildOfClass("Tool") or player.Backpack:FindFirstChildOfClass("Tool")

	if tool then
		-- Modify internal values inside the tool
		for _, v in ipairs(tool:GetDescendants()) do
			if v:IsA("ValueBase") then
				local n = string.lower(v.Name)
				if string.find(n, "range") or string.find(n, "power") or string.find(n, "distance") or string.find(n, "damage") or string.find(n, "speed") or string.find(n, "size") then
					v.Value = 99999
				elseif string.find(n, "cooldown") or string.find(n, "delay") or string.find(n, "wait") then
					v.Value = 0
				end
			end
		end
		-- Modify Tool Attributes
		for attr, val in pairs(tool:GetAttributes()) do
			if type(val) == "number" then
				tool:SetAttribute(attr, 99999)
			end
		end
		btn.Text = "💥 Tool Range & Power Boosted! ✅"
		btn.BackgroundColor3 = Color3.fromRGB(36, 140, 75)
	else
		btn.Text = "⚠️ Please Equip Washer Tool First!"
		btn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
		task.wait(2)
		btn.Text = "💥 Boost Tool Range & Power (Equipped Tool)"
		btn.BackgroundColor3 = Color3.fromRGB(38, 46, 62)
	end
end)

-- Feature 4: WalkSpeed Boost
local fastSpeed = false
createButton("🚀 WalkSpeed Boost: OFF", function(btn)
	fastSpeed = not fastSpeed
	local char = player.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.WalkSpeed = fastSpeed and 50 or 16
		btn.Text = fastSpeed and "🚀 WalkSpeed Boost: ON (50)" or "🚀 WalkSpeed Boost: OFF"
		btn.BackgroundColor3 = fastSpeed and Color3.fromRGB(36, 140, 75) or Color3.fromRGB(38, 46, 62)
	end
end)

-- Feature 5: High Jump Boost
local highJump = false
createButton("🦘 High Jump Boost: OFF", function(btn)
	highJump = not highJump
	local char = player.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.JumpPower = highJump and 120 or 50
		char.Humanoid.UseJumpPower = true
		btn.Text = highJump and "🦘 High Jump Boost: ON (120)" or "🦘 High Jump Boost: OFF"
		btn.BackgroundColor3 = highJump and Color3.fromRGB(36, 140, 75) or Color3.fromRGB(38, 46, 62)
	end
end)

-- Feature 6: Add Cash
createButton("💰 Add +1,000 Cash", function(btn)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		for _, val in ipairs(leaderstats:GetChildren()) do
			if string.find(string.lower(val.Name), "cash") or string.find(string.lower(val.Name), "money") then
				val.Value = val.Value + 1000
			end
		end
	end
	btn.Text = "💰 Cash Added! ✅"
	btn.BackgroundColor3 = Color3.fromRGB(36, 140, 75)
end)
