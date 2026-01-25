-- ================= XUAN HUB GUI (WindUI Version) =================
if game.PlaceId ~= 131623223084840 then
	game:GetService("Players").LocalPlayer:Kick("Xuan Hub not supported this game!")
	return
end

print("--===== XUAN HUB LOADED (WindUI) =====--")

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

-- ================= LOAD WINDUI =================
local WindUI = loadstring(game:HttpGet(
	"https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

-- ================= SET FONT (IMPORTANT) =================
-- WindUI text font
WindUI:SetFont("rbxasset://fonts/families/GothamSSm.json")

-- ================= SETTINGS PERSISTENCE =================
local settingsFileName = "XuanHubSettings.json"
local defaultSettings = {
	autoCollectMoney = false,
	autoCollectRadioactive = false,
	autoSpin = false,
	spinDelay = 0.5,
	antiAfk = false,
	autoReconnect = false,
	autoUpgradeBase = false,
	autoUpgradeCarry = false,
	autoUpgradeSpeed = false,
	upgradeSpeedAmount = 1,
	autoRebirth = false,
	autoObby = false,
	-- UFO Event
	autoCollectUFO = false,
	-- UFO Spin
	autoSpinUFO = false,
	-- Unlock Zoom
	unlockZoom = false,
	-- God Mode
	godMode = false,
	-- Tsunami tracker
	autoTsunamiTracker = false
}

local function loadSettings()
	if not isfolder("XuanHub") then
		makefolder("XuanHub")
	end
	
	if isfile("XuanHub/" .. settingsFileName) then
		local success, data = pcall(function()
			return HttpService:JSONDecode(readfile("XuanHub/" .. settingsFileName))
		end)
		if success and data then
			return data
		end
	end
	return defaultSettings
end

local function saveSettings(settings)
	pcall(function()
		if not isfolder("XuanHub") then
			makefolder("XuanHub")
		end
		writefile("XuanHub/" .. settingsFileName, HttpService:JSONEncode(settings))
	end)
end

local savedSettings = loadSettings()

-- ================= CREATE WINDUI WINDOW =================
local Window = WindUI:CreateWindow({
	Folder = "XuanHub",
	Title = "XUAN HUB",
	Author = "by discord.gg/kaydensdens",
	Icon = "rbxassetid://103326199885496",
	Theme = "Midnight",
	Size = UDim2.fromOffset(640, 480),
	Draggable = true,
	HasOutline = true,
	OutlineThickness = 3,
    Resizable = true,
})

Window:EditOpenButton({
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

-- Add version tag
Window:Tag({
	Title = "Server: " .. tostring(game.PlaceVersion),
	Icon = "solar:server-bold",
	Color = Color3.fromRGB(255, 105, 180),
	Border = true,
})

-- ================= TABS =================


local BaseTab = Window:Tab({
	Title = "Main",
	Icon = "layers-2",
	Locked = false,
})

local EventTab = Window:Tab({
	Title = "Event",
	Icon = "star",
	Locked = false,
})

local AutoTab = Window:Tab({
	Title = "Auto",
	Icon = "refresh-cw",
	Locked = false,
})

local TsunamiTab = Window:Tab({
	Title = "Tsunami",
	Icon = "cloud-lightning",
	Locked = false,
})

local MiscTab = Window:Tab({
	Title = "Misc",
	Icon = "settings",
	Locked = false,
})

-- Set Base tab as default
BaseTab:Select()

-- ================= FUNCTIONALITY LOGIC =================

-- Script running flag (to stop all loops when GUI is closed)
local scriptRunning = true

local character, humanoidRootPart
local EventFolder = nil

local PullDelay = 0.1
local HeightOffset = 3
local active = false
local spinning = false
local autoObby = false
local collectingMoney = false
local autoCollectUFO = false
local autoSpinUFO = false
local autoUpgradeBase = false
local autoUpgradeCarry = false
local autoUpgradeSpeed = false
local upgradeSpeedAmount = 1
local autoRebirth = false

-- Unlock Zoom state
local unlockZoomEnabled = false
local prevCameraMin = nil
local prevCameraMax = nil

-- God Mode state
local godModeEnabled = false
local godModeCharConn = nil
local godModeConns = {} -- map character -> {conns = {...}, modified = {...} }

-- Sell All confirmation
local lastSellAllClick = 0

-- Character handler (safe)
local function setupCharacter(char)
	character = char
	humanoidRootPart = char:WaitForChild("HumanoidRootPart", 10)
end

if player.Character then
	setupCharacter(player.Character)
end
player.CharacterAdded:Connect(setupCharacter)

-- Global Auto Obby logic (runs whenever obby activates and toggle is on)
task.spawn(function()
	local mapVariants = workspace:WaitForChild("MapVariants")
	
	local function runOnce(radioactive)
		if not autoObby or not humanoidRootPart then return end
		local obbyEnd = radioactive:WaitForChild("ObbyEnd", 5)
		if obbyEnd then
			firetouchinterest(humanoidRootPart, obbyEnd, 0)
			task.wait()
			firetouchinterest(humanoidRootPart, obbyEnd, 1)
		end
	end
	
	-- Check for existing on script start
	local existing = mapVariants:FindFirstChild("Radioactive")
	if existing and autoObby then
		runOnce(existing)
	end
	
	-- Listen for new activations
	mapVariants.ChildAdded:Connect(function(child)
		if child.Name == "Radioactive" and autoObby then
			runOnce(child)
		end
	end)
end)

-- Find EventParts WITHOUT BLOCKING GUI
task.spawn(function()
	while not EventFolder and scriptRunning do
		EventFolder = workspace:FindFirstChild("EventParts")
		task.wait(1)
	end
end)

-- Model part
local function getModelPart(model)
	if model.PrimaryPart then return model.PrimaryPart end
	for _, v in ipairs(model:GetDescendants()) do
		if v:IsA("BasePart") then
			model.PrimaryPart = v
			return v
		end
	end
end

-- Loop to pull models
task.spawn(function()
	while scriptRunning do
		if active and humanoidRootPart and EventFolder then
			for _, model in ipairs(EventFolder:GetChildren()) do
				if model:IsA("Model") then
					local part = getModelPart(model)
					if part then
						model:SetPrimaryPartCFrame(
							CFrame.new(humanoidRootPart.Position + Vector3.new(0, HeightOffset, 0))
						)
					end
				end
			end
		end
		task.wait(PullDelay)
	end
end)

-- Auto Spin logic
task.spawn(function()
	while scriptRunning do
		if spinning then
			pcall(function()
				game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RF/WheelSpin.Roll"):InvokeServer()
			end)
			-- Get delay from input box with validation
			local delayValue = tonumber(savedSettings.spinDelay) or 0.5
			if delayValue <= 0 then delayValue = 0.5 end
			task.wait(delayValue)
		else
			task.wait(0.5)
		end
	end
end)

-- Auto Collect Money logic
local function findMyBase()
	for _, base in ipairs(workspace:WaitForChild("Bases"):GetChildren()) do
		if base:IsA("Model") then
			local holder = base:GetAttribute("Holder")
			if holder and holder == player.UserId then
				return base
			end
		end
	end
	return nil
end

-- Improved teleport helpers
local lastTeleportTime = 0
local TELEPORT_COOLDOWN = 1 -- seconds

local function getHomePart(base)
	if not base then return nil end
	local home = base:FindFirstChild("Home")
	if home and home:IsA("BasePart") then return home end
	return nil
end

local function findSafeCFrame(targetCFrame, upOffset)
	upOffset = upOffset or 6
	local origin = targetCFrame.Position + Vector3.new(0, 20, 0)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {player.Character}
	params.FilterType = Enum.RaycastFilterType.Blacklist
	local result = workspace:Raycast(origin, Vector3.new(0, -80, 0), params)
	if result and result.Position then
		return CFrame.new(result.Position + Vector3.new(0, upOffset, 0))
	end
	return targetCFrame + Vector3.new(0, upOffset, 0)
end

local function teleportToBaseSmooth()
	if tick() - lastTeleportTime < TELEPORT_COOLDOWN then
		WindUI:Notify({Title = "Teleport", Content = "Teleport cooldown", Icon = "alert-triangle", Duration = 2})
		return
	end
	lastTeleportTime = tick()

	local base = findMyBase()
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then WindUI:Notify({Title = "Teleport", Content = "Character not ready", Icon = "alert-triangle", Duration = 3}); return end
	if not base then WindUI:Notify({Title = "Teleport", Content = "No base found", Icon = "alert-triangle", Duration = 3}); return end
	local home = getHomePart(base)
	if not home then WindUI:Notify({Title = "Teleport", Content = "Base Home not found", Icon = "alert-triangle", Duration = 3}); return end

	local targetCFrame = findSafeCFrame(home.CFrame, 6)
	local prevCanCollide = hrp.CanCollide
	pcall(function() hrp.CanCollide = false end)

	local ok, err = pcall(function()
		local tween = TweenService:Create(hrp, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = targetCFrame})
		tween:Play()
		tween.Completed:Wait()
	end)

	pcall(function() hrp.CanCollide = prevCanCollide end)

	if ok then
		WindUI:Notify({Title = "Teleport", Content = "Teleported to base", Icon = "check", Duration = 3})
	else
		WindUI:Notify({Title = "Teleport", Content = "Teleport failed: " .. tostring(err), Icon = "alert-triangle", Duration = 3})
	end
end

task.spawn(function()
	while scriptRunning do
		if collectingMoney then
			local myBase = findMyBase()
			if myBase then
				for i = 1, 30 do
					pcall(function()
						local args = {
							"Collect Money",
							myBase.Name,
							tostring(i)
						}
						local PlotAction = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RF/Plot.PlotAction")
						PlotAction:InvokeServer(unpack(args))
					end)
					task.wait(0.01)
				end
			end
			task.wait(0.1)
		else
			task.wait(0.5)
		end
	end
end)

-- Auto Collect UFO Coins Loop
task.spawn(function()
	while scriptRunning do
		if autoCollectUFO then
			pcall(function()
				local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				local folder = workspace:FindFirstChild("UFOEventParts") or workspace:FindFirstChild("UFQEventParts")
				if not root or not folder then return end
				for _, coin in ipairs(folder:GetChildren()) do
					local name = coin.Name and coin.Name:lower() or ""
					if name:find("ufo coin") or name:find("ufo") then
						local hitbox = coin:FindFirstChild("Hitbox") or coin:FindFirstChildWhichIsA("BasePart")
						if hitbox and hitbox:IsA("BasePart") then
							firetouchinterest(root, hitbox, 0)
							task.wait()
							firetouchinterest(root, hitbox, 1)
							task.wait(0.05)
						end
					end
				end
			end)
			task.wait(0.2)
		else
			task.wait(0.5)
		end
	end
end)

-- Auto Spin UFO Wheel Loop
task.spawn(function()
	while scriptRunning do
		if autoSpinUFO then
			pcall(function()
				local success, args = pcall(function()
					return {"UFO", false}
				end)
				if success and args then
					pcall(function()
						game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RF/WheelSpin.Roll"):InvokeServer(unpack(args))
					end)
				end
			end)
			local delayValue = tonumber(savedSettings.spinDelay) or 0.5
			if delayValue <= 0 then delayValue = 0.5 end
			task.wait(delayValue)
		else
			task.wait(0.5)
		end
	end
end)

-- Auto Upgrade Base Loop
task.spawn(function()
	while scriptRunning do
		if autoUpgradeBase then
			pcall(function()
				game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RE/Plot.UpgradeBase"):FireServer()
			end)
			task.wait(0.5)
		else
			task.wait(1)
		end
	end
end)

-- Auto Upgrade Carry Loop
task.spawn(function()
	while scriptRunning do
		if autoUpgradeCarry then
			pcall(function()
				game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("UpgradeCarry"):InvokeServer()
			end)
			task.wait(0.5)
		else
			task.wait(1)
		end
	end
end)

-- Auto Upgrade Speed Loop
task.spawn(function()
	while scriptRunning do
		if autoUpgradeSpeed then
			pcall(function()
				local args = { upgradeSpeedAmount }
				game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("UpgradeSpeed"):InvokeServer(unpack(args))
			end)
			task.wait(0.5)
		else
			task.wait(1)
		end
	end
end)

-- Auto Rebirth Loop
task.spawn(function()
	while scriptRunning do
		if autoRebirth then
			pcall(function()
				game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("Rebirth"):InvokeServer()
			end)
			task.wait(1)
		else
			task.wait(1)
		end
	end
end)

-- Anti-AFK (toggleable)
local antiAfkEnabled = savedSettings.antiAfk or false
local antiAfkConn = nil
local vu = game:GetService("VirtualUser")
local function enableAntiAfk()
	if antiAfkConn then return end
	antiAfkConn = player.Idled:Connect(function()
		vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
		task.wait(1)
		vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
	end)
end
local function disableAntiAfk()
	if antiAfkConn then
		antiAfkConn:Disconnect()
		antiAfkConn = nil
	end
end
if antiAfkEnabled then
	enableAntiAfk()
end

-- Auto Reconnect (toggleable)
local autoReconnectEnabled = savedSettings.autoReconnect or false
local autoReconnectConn = nil
local function enableAutoReconnect()
	if autoReconnectConn then return end
	local success, conn = pcall(function()
		return game.CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
			if child.Name == 'ErrorPrompt' and child:FindFirstChild('MessageArea') and child.MessageArea:FindFirstChild("ErrorFrame") then
				game:GetService("TeleportService"):Teleport(game.PlaceId, player)
			end
		end)
	end)
	if success and conn then
		autoReconnectConn = conn
	end
end
local function disableAutoReconnect()
	if autoReconnectConn then
		autoReconnectConn:Disconnect()
		autoReconnectConn = nil
	end
end
if autoReconnectEnabled then
	enableAutoReconnect()
end

-- Unlock Zoom handlers
local function enableUnlockZoom()
	if unlockZoomEnabled then return end
	unlockZoomEnabled = true
	-- store previous values if present
	pcall(function()
		prevCameraMin = player.CameraMinZoomDistance
		prevCameraMax = player.CameraMaxZoomDistance
	end)

	local applied = false
	-- Try to set on Player
	pcall(function()
		player.CameraMinZoomDistance = 0.5
		player.CameraMaxZoomDistance = 500
		applied = true
	end)

	-- Also try CurrentCamera in case of alternate API
	pcall(function()
		local cam = workspace and workspace.CurrentCamera
		if cam then
			pcall(function()
				cam.CameraMinZoomDistance = 0.5
				cam.CameraMaxZoomDistance = 500
				applied = true
			end)
		end
	end)

	if applied then
		WindUI:Notify({Title = "Main", Content = "Zoom limits unlocked", Icon = "check", Duration = 3})
	else
		WindUI:Notify({Title = "Main", Content = "Failed to change zoom limits", Icon = "alert-triangle", Duration = 4})
	end
end

local function disableUnlockZoom()
	if not unlockZoomEnabled then return end
	unlockZoomEnabled = false
	local restored = false
	pcall(function()
		if prevCameraMin then player.CameraMinZoomDistance = prevCameraMin; restored = true end
		if prevCameraMax then player.CameraMaxZoomDistance = prevCameraMax; restored = true end
	end)
	pcall(function()
		local cam = workspace and workspace.CurrentCamera
		if cam then
			pcall(function()
				if prevCameraMin then cam.CameraMinZoomDistance = prevCameraMin end
				if prevCameraMax then cam.CameraMaxZoomDistance = prevCameraMax end
				restored = true
			end)
		end
	end)

	if restored then
		WindUI:Notify({Title = "Main", Content = "Zoom limits restored", Icon = "check", Duration = 3})
	else
		WindUI:Notify({Title = "Main", Content = "Zoom restore attempted", Icon = "check", Duration = 3})
	end
end

-- ================= GOD MODE HELPERS =================
local function applyGodModeToCharacter(char)
	if not char then return end
	-- run async to wait for the character to be ready
	task.spawn(function()
		task.wait(0.25)
		local humanoid = char:FindFirstChild("Humanoid")
		local root = char:FindFirstChild("HumanoidRootPart")
		local conns = {}
		local modified = {}

		if humanoid then
			pcall(function()
				humanoid.MaxHealth = 1e9
				humanoid.Health = 1e9
			end)
			local c = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
				if humanoid.Health < 1000000 then
					humanoid.Health = 1000000
				end
			end)
			table.insert(conns, c)
		end

		for _, part in ipairs(char:GetChildren()) do
			if part:IsA("BasePart") then
				local ok, prevTrans = pcall(function() return part.Transparency end)
				local ok2, prevCanTouch = pcall(function() return part.CanTouch end)
				table.insert(modified, {part = part, transp = (ok and prevTrans) or nil, canTouch = (ok2 and prevCanTouch) or nil})
				pcall(function() part.Transparency = 0.3 end)
				pcall(function() part.CanTouch = false end)
			end
		end

		if root then
			local hb = RunService.Heartbeat:Connect(function()
				pcall(function()
					root.Velocity = Vector3.new(0,0,0)
					root.AssemblyLinearVelocity = Vector3.new(0,0,0)
				end)
			end)
			table.insert(conns, hb)
		end

		godModeConns[char] = {conns = conns, modified = modified}
	end)
end

local function enableGodMode()
	if godModeEnabled then return end
	godModeEnabled = true
	if player.Character then
		applyGodModeToCharacter(player.Character)
	end
	godModeCharConn = player.CharacterAdded:Connect(function(char)
		applyGodModeToCharacter(char)
	end)
	WindUI:Notify({Title = "Main", Content = "God Mode enabled", Icon = "check", Duration = 3})
end

local function disableGodMode()
	if not godModeEnabled then return end
	godModeEnabled = false
	if godModeCharConn then godModeCharConn:Disconnect(); godModeCharConn = nil end
	for char, data in pairs(godModeConns) do
		if data and data.conns then
			for _, c in ipairs(data.conns) do pcall(function() c:Disconnect() end) end
		end
		if data and data.modified then
			for _, m in ipairs(data.modified) do
				pcall(function()
					if m.part and m.transp ~= nil then m.part.Transparency = m.transp end
					if m.part and m.canTouch ~= nil then m.part.CanTouch = m.canTouch end
				end)
			end
		end
		godModeConns[char] = nil
	end
	WindUI:Notify({Title = "Main", Content = "God Mode disabled", Icon = "check", Duration = 3})
end

-- ================= TSUNAMI TRACKER =================
-- Creates a small ScreenGui that shows distance & color-coded status for nearby tsunamis
local RunService = game:GetService("RunService")
local tsunamiGui = nil
local tsunamiBox = nil
local tsunamiText = nil
local tsunamiHeartbeatConn = nil
local tsunamiEnabled = false

local function getTsunamiDistance()
    local character = player.Character
    if not character then return math.huge end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return math.huge end

    local closest = math.huge
    local activeTsunamis = workspace:FindFirstChild("ActiveTsunamis")
    if activeTsunamis then
        for i = 1, 6 do
            local wave = activeTsunamis:FindFirstChild("Wave" .. i)
            if wave then
                local hitbox = wave:FindFirstChild("Hitbox")
                if hitbox and hitbox:IsA("BasePart") then
                    local dist = (hitbox.Position - root.Position).Magnitude
                    if dist < closest then
                        closest = dist
                    end
                end
            end
        end
    end

    if closest == math.huge then
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:IsA("Model") then
                if obj.Name:lower():find("tsunami") or obj.Name:lower():find("wave") then
                    for _, part in pairs(obj:GetDescendants()) do
                        if part:IsA("BasePart") then
                            local dist = (part.Position - root.Position).Magnitude
                            if dist < closest then
                                closest = dist
                            end
                        end
                    end
                end
            end
        end
    end

    return closest
end

local function createTsunamiGui()
    if tsunamiGui then return end
    tsunamiGui = Instance.new("ScreenGui")
    tsunamiGui.Name = "XuanTsunamiTracker"
    tsunamiGui.ResetOnSpawn = false
    tsunamiGui.Parent = player:WaitForChild("PlayerGui")

    tsunamiBox = Instance.new("Frame")
    tsunamiBox.Name = "TsunamiBox"
    tsunamiBox.Size = UDim2.fromOffset(220, 26)
    tsunamiBox.Position = UDim2.fromOffset(12, 12)
    tsunamiBox.BackgroundColor3 = Color3.fromRGB(30, 34, 45)
    tsunamiBox.BorderSizePixel = 0
    tsunamiBox.Parent = tsunamiGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = tsunamiBox

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 100)
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Parent = tsunamiBox

    tsunamiText = Instance.new("TextLabel")
    tsunamiText.Name = "TsunamiText"
    tsunamiText.Size = UDim2.new(1, -10, 1, -4)
    tsunamiText.Position = UDim2.fromOffset(8, 1)
    tsunamiText.BackgroundTransparency = 1
    tsunamiText.TextColor3 = Color3.fromRGB(255, 255, 255)
    tsunamiText.Text = "Tsunami: Safe (>1500m)"
    tsunamiText.Font = Enum.Font.Gotham
    tsunamiText.TextSize = 13
    tsunamiText.TextXAlignment = Enum.TextXAlignment.Left
    tsunamiText.TextYAlignment = Enum.TextYAlignment.Center
    tsunamiText.Parent = tsunamiBox

    tsunamiHeartbeatConn = RunService.Heartbeat:Connect(function()
        local dist = getTsunamiDistance()
        if dist < 1500 then
            if dist <= 500 then
                tsunamiBox.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                tsunamiText.TextColor3 = Color3.new(1, 1, 1)
                tsunamiText.Text = "⚠️ Tsunami: " .. math.floor(dist) .. "m (DANGER)"
            elseif dist <= 1000 then
                tsunamiBox.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
                tsunamiText.TextColor3 = Color3.new(0, 0, 0)
                tsunamiText.Text = "Tsunami: " .. math.floor(dist) .. "m (WARNING)"
            else
                tsunamiBox.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
                tsunamiText.TextColor3 = Color3.new(0, 0, 0)
                tsunamiText.Text = "Tsunami: " .. math.floor(dist) .. "m (SAFE)"
            end
        else
            tsunamiBox.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            tsunamiText.TextColor3 = Color3.new(1, 1, 1)
            tsunamiText.Text = "Tsunami: Safe (>1500m)"
        end
    end)
end

local function destroyTsunamiGui()
    if tsunamiHeartbeatConn then
        tsunamiHeartbeatConn:Disconnect()
        tsunamiHeartbeatConn = nil
    end
    if tsunamiGui then
        tsunamiGui:Destroy()
        tsunamiGui = nil
        tsunamiBox = nil
        tsunamiText = nil
    end
end

local function enableTsunamiTracker()
    if tsunamiEnabled then return end
    tsunamiEnabled = true
    createTsunamiGui()
    WindUI:Notify({
        Title = "Tsunami",
        Content = "Tsunami tracker enabled",
        Icon = "check",
        Duration = 3,
    })
end

local function disableTsunamiTracker()
    if not tsunamiEnabled then return end
    tsunamiEnabled = false
    destroyTsunamiGui()
    WindUI:Notify({
        Title = "Tsunami",
        Content = "Tsunami tracker disabled",
        Icon = "check",
        Duration = 3,
    })
end

-- Add a section + toggle in the Tsunami tab
local TsunamiSection = TsunamiTab:Section({Title = "Tsunami Tracker", Opened = true,})
TsunamiSection:Toggle({
	Title = "Tsunami Tracker",
	Desc = "Toggle tsunami tracker display",
	Value = savedSettings.autoTsunamiTracker,
	Callback = function(state)
		if state then
			enableTsunamiTracker()
		else
			disableTsunamiTracker()
		end
		savedSettings.autoTsunamiTracker = state
		saveSettings(savedSettings)
	end
})

-- Teleport to next gap (in front of player)
TsunamiSection:Button({
	Title = "TP Next Gap",
	Desc = "Teleport to the next gap ahead of you",
	Locked = false,
	Callback = function()
		local misc = workspace:FindFirstChild("Misc")
		local gapsFolder = misc and misc:FindFirstChild("Gaps")
		if not gapsFolder then
			WindUI:Notify({Title = "Tsunami", Content = "Gaps not found", Icon = "alert-triangle", Duration = 3})
			return
		end

		local gaps = gapsFolder:GetChildren()
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not root then
			WindUI:Notify({Title = "Tsunami", Content = "Character not ready", Icon = "alert-triangle", Duration = 3})
			return
		end

		local look = root.CFrame.LookVector
		local pos = root.Position
		local best, bestScore = nil, math.huge

		for _, g in ipairs(gaps) do
			local part = (g:IsA("BasePart") and g) or (g:IsA("Model") and (g.PrimaryPart or g:FindFirstChildWhichIsA("BasePart")))
			if part then
				local rel = part.Position - pos
				local proj = rel:Dot(look)
				if proj > 0 and proj < bestScore then
					bestScore = proj
					best = part
				end
			end
		end

		if best then
			root.CFrame = CFrame.new(best.Position + Vector3.new(0, 5, 0))
		else
			WindUI:Notify({Title = "Tsunami", Content = "No gap ahead", Icon = "alert-triangle", Duration = 3})
		end
	end
})

-- Teleport to previous gap (behind player)
TsunamiSection:Button({
	Title = "TP Previous Gap",
	Desc = "Teleport to the previous gap behind you",
	Locked = false,
	Callback = function()
		local misc = workspace:FindFirstChild("Misc")
		local gapsFolder = misc and misc:FindFirstChild("Gaps")
		if not gapsFolder then
			WindUI:Notify({Title = "Tsunami", Content = "Gaps not found", Icon = "alert-triangle", Duration = 3})
			return
		end

		local gaps = gapsFolder:GetChildren()
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not root then
			WindUI:Notify({Title = "Tsunami", Content = "Character not ready", Icon = "alert-triangle", Duration = 3})
			return
		end

		local look = root.CFrame.LookVector
		local pos = root.Position
		local best, bestScore = nil, -math.huge

		for _, g in ipairs(gaps) do
			local part = (g:IsA("BasePart") and g) or (g:IsA("Model") and (g.PrimaryPart or g:FindFirstChildWhichIsA("BasePart")))
			if part then
				local rel = part.Position - pos
				local proj = rel:Dot(look)
				if proj < 0 and proj > bestScore then
					bestScore = proj
					best = part
				end
			end
		end

		if best then
			root.CFrame = CFrame.new(best.Position + Vector3.new(0, 5, 0))
		else
			WindUI:Notify({Title = "Tsunami", Content = "No gap behind", Icon = "alert-triangle", Duration = 3})
		end
	end
})

-- Teleport to your base
TsunamiSection:Button({
	Title = "Teleport to Base",
	Desc = "Teleport to your base",
	Locked = false,
	Callback = function()
		teleportToBaseSmooth()
	end
})

-- ================= BASE TAB ================= 
local UpgBase = BaseTab:Section({Title = "Main", Opened = true,})

-- Utilities section (visible)
local UtilitiesSection = BaseTab:Section({Title = "Utilities", Opened = true,})

local UpgBaseOnce = UpgBase:Button({
	Title = "Upgrade Base",
	Desc = "Purchase one base upgrade",
	Locked = false,
	Callback = function()
		pcall(function()
			game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RE/Plot.UpgradeBase"):FireServer()
		end)
		WindUI:Notify({
			Title = "Upgraded",
			Content = "Base upgrade purchased!",
			Icon = "check",
			Duration = 3,
		})
	end
})

-- Upgrade Carry (manual)
local UpgCarryOnce = UpgBase:Button({
	Title = "Upgrade Carry",
	Desc = "Purchase one carry upgrade",
	Locked = false,
	Callback = function()
		pcall(function()
			game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("UpgradeCarry"):InvokeServer()
		end)
		WindUI:Notify({
			Title = "Upgraded",
			Content = "Carry upgrade purchased!",
			Icon = "check",
			Duration = 3,
		})
	end
})

-- Unlock Zoom Limit
UtilitiesSection:Toggle({
	Title = "Unlock Zoom Limit",
	Desc = "Unlock camera zoom limits",
	Value = savedSettings.unlockZoom,
	Callback = function(state)
		if state then
			enableUnlockZoom()
		else
			disableUnlockZoom()
		end
		savedSettings.unlockZoom = state
		saveSettings(savedSettings)
	end
})

-- God Mode
UtilitiesSection:Toggle({
	Title = "God Mode",
	Desc = "Make your character invulnerable and immobile for safe teleporting",
	Value = savedSettings.godMode,
	Callback = function(state)
		if state then
			enableGodMode()
		else
			disableGodMode()
		end
		savedSettings.godMode = state
		saveSettings(savedSettings)
	end
})

-- Buttons moved from Main (simplified)
local SellAllBtn = UpgBase:Button({
	Title = "Sell All Inventory",
	Desc = "Double-click within 0.5s to confirm sell all",
	Locked = false,
	Callback = function()
		local currentTime = tick()
		if currentTime - lastSellAllClick < 0.5 then
			-- Double click: sell
			pcall(function()
				game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("SellAll"):InvokeServer()
			end)
			WindUI:Notify({
				Title = "Sold",
				Content = "All inventory items sold!",
				Icon = "check",
				Duration = 3,
			})
		else
			lastSellAllClick = currentTime
		end
	end
})

local SellHeldBtn = UpgBase:Button({
	Title = "Sell Held Tool",
	Desc = "Sells the brainrot you are currently holding",
	Locked = false,
	Callback = function()
		pcall(function()
			game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("SellTool"):InvokeServer()
		end)
		WindUI:Notify({
			Title = "Sold",
			Content = "Held tool sold!",
			Icon = "check",
			Duration = 3,
		})
	end
})



-- ================= EVENT TAB =================
EventTab:Section({
	Title = "Radioactive Event",
	Opened = false,
})

-- Auto Collect Radioactive
EventTab:Toggle({
	Title = "Auto Collect Radioactive Coins",
	Desc = "(Patched, it will still collect but not many)",
	Value = savedSettings.autoCollectRadioactive,
	Callback = function(state)
		active = state
		savedSettings.autoCollectRadioactive = state
		saveSettings(savedSettings)
	end
})

EventTab:Space()

-- Auto Spin
EventTab:Toggle({
	Title = "Auto Spin Radioactive Wheel",
	Desc = "Automatically spins the radioactive wheel",
	Value = savedSettings.autoSpin,
	Callback = function(state)
		spinning = state
		savedSettings.autoSpin = state
		saveSettings(savedSettings)
	end
})

EventTab:Input({
	Title = "Spin Delay",
	Value = tostring(savedSettings.spinDelay),
	Placeholder = "0.5",
	Callback = function(value)
		local delay = tonumber(value)
		if delay and delay >= 0.1 then
			savedSettings.spinDelay = delay
			saveSettings(savedSettings)
		end
	end
})

EventTab:Space()

-- Auto Obby
EventTab:Toggle({
	Title = "Auto Obby",
	Desc = "Automatically completes the obby",
	Value = savedSettings.autoObby,
	Callback = function(state)
		autoObby = state
		savedSettings.autoObby = state
		saveSettings(savedSettings)
	end
})

-- UFO Event
EventTab:Section({
	Title = "UFO Event",
	Opened = false,
})

EventTab:Toggle({
	Title = "Auto Collect UFO Coins",
	Desc = "Automatically collects UFO coins",
	Value = savedSettings.autoCollectUFO,
	Callback = function(state)
		autoCollectUFO = state
		savedSettings.autoCollectUFO = state
		saveSettings(savedSettings)
	end
})

EventTab:Toggle({
	Title = "Auto Spin UFO Wheel",
	Desc = "Automatically spins the UFO wheel",
	Value = savedSettings.autoSpinUFO,
	Callback = function(state)
		autoSpinUFO = state
		savedSettings.autoSpinUFO = state
		saveSettings(savedSettings)
	end
})

-- ================= AUTO TAB =================
local AutoSection = AutoTab:Section({Title = "Auto Features", Opened = true,})

-- Auto Upgrade Base
local AutoUpgradeBaseToggle = AutoSection:Toggle({
	Title = "Auto Upgrade Base",
	Desc = "Automatically upgrades your base",
	Value = savedSettings.autoUpgradeBase,
	Callback = function(state)
		autoUpgradeBase = state
		savedSettings.autoUpgradeBase = state
		saveSettings(savedSettings)
	end
})

-- Auto Collect Money
local AutoCollectMoneyToggle = AutoSection:Toggle({
	Title = "Auto Collect Money",
	Desc = "Automatically collects money from your base",
	Value = savedSettings.autoCollectMoney,
	Callback = function(state)
		collectingMoney = state
		savedSettings.autoCollectMoney = state
		saveSettings(savedSettings)
	end
})

-- Auto Upgrade Carry
local AutoUpgradeCarryToggle = AutoSection:Toggle({
	Title = "Auto Upgrade Carry",
	Desc = "Automatically upgrades carry capacity",
	Value = savedSettings.autoUpgradeCarry,
	Callback = function(state)
		autoUpgradeCarry = state
		savedSettings.autoUpgradeCarry = state
		saveSettings(savedSettings)
	end
})

-- Auto Upgrade Speed
local AutoUpgradeSpeedToggle = AutoSection:Toggle({
	Title = "Auto Upgrade Speed",
	Desc = "Automatically upgrades movement speed",
	Value = savedSettings.autoUpgradeSpeed,
	Callback = function(state)
		autoUpgradeSpeed = state
		savedSettings.autoUpgradeSpeed = state
		saveSettings(savedSettings)
	end
})

local SpeedAmountDropdown = AutoSection:Dropdown({
	Title = "Speed Amount",
	Desc = "Select upgrade speed amount",
	Values = { "1", "5", "10" },
	Value = tostring(savedSettings.upgradeSpeedAmount),
	Multi = false,
	AllowNone = false,
	Callback = function(option)
		upgradeSpeedAmount = tonumber(option)
		savedSettings.upgradeSpeedAmount = upgradeSpeedAmount
		saveSettings(savedSettings)
		print("Speed amount set to: " .. tostring(option))
	end
})

-- Auto Rebirth
local AutoRebirthToggle = AutoSection:Toggle({
	Title = "Auto Rebirth",
	Desc = "Automatically rebirths when possible",
	Value = savedSettings.autoRebirth,
	Callback = function(state)
		autoRebirth = state
		savedSettings.autoRebirth = state
		saveSettings(savedSettings)
	end
})

-- ================= MISC TAB =================
local MiscSettings = MiscTab:Section({
	Title = "Game Settings",
	Opened = true,
})

-- Anti-AFK
MiscSettings:Toggle({
	Title = "Anti-AFK",
	Desc = "Prevents Roblox from kicking you after 20 minutes of inactivity",
	Value = savedSettings.antiAfk,
	Callback = function(state)
		antiAfkEnabled = state
		savedSettings.antiAfk = state
		saveSettings(savedSettings)
		if state then
			enableAntiAfk()
		else
			disableAntiAfk()
		end
	end
})

MiscSettings:Space()

-- Auto Reconnect
MiscSettings:Toggle({
	Title = "Auto Reconnect",
	Desc = "Automatically rejoins the game when you get disconnected",
	Value = savedSettings.autoReconnect,
	Callback = function(state)
		autoReconnectEnabled = state
		savedSettings.autoReconnect = state
		saveSettings(savedSettings)
		if state then
			enableAutoReconnect()
		else
			disableAutoReconnect()
		end
	end
})

MiscTab:Space()
MiscTab:Space()

MiscTab:Section({
	Title = "Server Actions",
	Opened = true,
})

local ServerGroup = MiscTab:Group()

ServerGroup:Button({
	Title = "Server Hop",
	Icon = "solar:refresh-bold",
	Color = Color3.fromRGB(255, 105, 180),
	Justify = "Center",
	Callback = function()
		local servers = {}
		local req = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")
		local body = HttpService:JSONDecode(req)
		
		if body and body.data then
			for _, v in pairs(body.data) do
				if v.id ~= game.JobId and v.playing < v.maxPlayers then
					table.insert(servers, v)
				end
			end
			
			if #servers > 0 then
				local randomServer = servers[math.random(1, #servers)]
				game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, randomServer.id, player)
			end
		end
	end
})

ServerGroup:Space()

ServerGroup:Button({
	Title = "Rejoin",
	Icon = "solar:restart-bold",
	Color = Color3.fromRGB(255, 105, 180),
	Justify = "Center",
	Callback = function()
		game:GetService("TeleportService"):Teleport(game.PlaceId, player)
	end
})

-- ================= SETTINGS APPLY =================
task.spawn(function()
	task.wait(0.5) -- Wait for GUI to fully load
	
	-- Apply Auto Collect Money
	if savedSettings.autoCollectMoney then
		collectingMoney = true
	end
	
	-- Apply Auto Collect Radioactive
	if savedSettings.autoCollectRadioactive then
		active = true
	end
	
	-- Apply Auto Spin
	if savedSettings.autoSpin then
		spinning = true
	end
	
	-- Apply Auto Upgrade Base
	if savedSettings.autoUpgradeBase then
		autoUpgradeBase = true
	end
	
	-- Apply Auto Upgrade Carry
	if savedSettings.autoUpgradeCarry then
		autoUpgradeCarry = true
	end
	
	-- Apply Auto Upgrade Speed
	if savedSettings.autoUpgradeSpeed then
		autoUpgradeSpeed = true
	end
	
	-- Apply Upgrade Speed Amount
	if savedSettings.upgradeSpeedAmount then
		upgradeSpeedAmount = savedSettings.upgradeSpeedAmount
	end
	
	-- Apply Auto Rebirth
	if savedSettings.autoRebirth then
		autoRebirth = true
	end
	
	-- Apply Auto Obby
	if savedSettings.autoObby then
		autoObby = true
		
		-- Check for existing obby on script load
		task.spawn(function()
			local mapVariants = workspace:FindFirstChild("MapVariants")
			if mapVariants then
				local existing = mapVariants:FindFirstChild("Radioactive")
				if existing then
					local obbyEnd = existing:WaitForChild("ObbyEnd", 5)
					if obbyEnd and humanoidRootPart then
						firetouchinterest(humanoidRootPart, obbyEnd, 0)
						task.wait()
						firetouchinterest(humanoidRootPart, obbyEnd, 1)
					end
				end
			end
		end)
	end

	-- Apply Auto Collect UFO
	if savedSettings.autoCollectUFO then
		autoCollectUFO = true
	end

	-- Apply Auto Spin UFO Wheel
	if savedSettings.autoSpinUFO then
		autoSpinUFO = true
	end

	-- Apply God Mode
	if savedSettings.godMode then
		godModeEnabled = true
		enableGodMode()
	end

	-- Apply Unlock Zoom
	if savedSettings.unlockZoom then
		unlockZoomEnabled = true
		enableUnlockZoom()
	else
		unlockZoomEnabled = false
		disableUnlockZoom()
	end
	
	-- Apply Anti-AFK
	if savedSettings.antiAfk then
		antiAfkEnabled = true
		enableAntiAfk()
	else
		antiAfkEnabled = false
		disableAntiAfk()
	end

	-- Apply Auto Reconnect
	if savedSettings.autoReconnect then
		autoReconnectEnabled = true
		enableAutoReconnect()
	else
		autoReconnectEnabled = false
		disableAutoReconnect()
	end

	-- Apply Tsunami Tracker
	if savedSettings.autoTsunamiTracker then
		enableTsunamiTracker()
	else
		disableTsunamiTracker()
	end
end)

-- ================= FINALIZE =================
WindUI:Notify({
	Title = "Xuan Hub Loaded",
	Content = "Welcome " .. player.DisplayName .. "!",
	Icon = "check",
	Duration = 5,
})

print("--===== XUAN HUB READY =====--")
