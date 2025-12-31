
-- Xuan Hub - Modern Sidebar UI (Remastered)
-- Services
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- File System Setup
local ROOT = "XuanHub"
local SCRIPTS_DIR = ROOT .. "/Scripts"
local AUTOEXEC_DIR = ROOT .. "/Autoexecute"
local FAVORITES_FILE = ROOT .. "/favorites.txt"

if not isfolder(ROOT) then makefolder(ROOT) end
if not isfolder(SCRIPTS_DIR) then makefolder(SCRIPTS_DIR) end
if not isfolder(AUTOEXEC_DIR) then makefolder(AUTOEXEC_DIR) end

local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local GameEvents = ReplicatedStorage:WaitForChild("GameEvents", 5)
local FarmFolder = workspace:FindFirstChild("Farm") or workspace:WaitForChild("Farm", 5)
local SellEvent = GameEvents and GameEvents:FindFirstChild("Sell_Inventory")
local BuySeedEvent = GameEvents and GameEvents:FindFirstChild("BuySeedStock")

-- Singleton Protection: Prevent multiple instances
if game.CoreGui:FindFirstChild("XuanHubUI") then
    warn("XuanHub is already running!")
    return
end

-- Internal Auto Execution
pcall(function()
    local autoFiles = listfiles(AUTOEXEC_DIR)
    if #autoFiles == 0 then
        writefile(AUTOEXEC_DIR .. "/default.txt", "-- Put code here to run when XuanHub loads")
    end
    
    for _, file in pairs(autoFiles) do
        if file:match("%.txt$") or file:match("%.lua$") then
            pcall(function()
                spawn(function()
                    local success, err = pcall(function()
                        loadstring(readfile(file))()
                    end)
                    if not success then
                        warn("AutoExec error in " .. file .. ": " .. tostring(err))
                    end
                end)
            end)
        end
    end
end)

-- UI Constants
local THEME = {
    Background = Color3.fromRGB(15, 15, 20),
    Sidebar = Color3.fromRGB(25, 25, 30),
    Item = Color3.fromRGB(35, 35, 40),
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(150, 150, 150),
    Accent = Color3.fromRGB(236, 72, 153), -- Pink
    Hover = Color3.fromRGB(255, 100, 180),
    Red = Color3.fromRGB(220, 60, 60),
    Green = Color3.fromRGB(60, 200, 110),
    Stroke = Color3.fromRGB(50, 50, 60)
}

-- Main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XuanHubUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 10000 -- Ensure it's on top

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 350) -- Wider
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -175)
MainFrame.BackgroundColor3 = THEME.Background
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = THEME.Stroke
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

-- Notification System
local Notification = Instance.new("TextLabel")
Notification.Name = "Notification"
Notification.Size = UDim2.new(0, 200, 0, 30)
Notification.Position = UDim2.new(0.5, -100, 0.85, 0)
Notification.BackgroundColor3 = THEME.Sidebar
Notification.TextColor3 = THEME.Text
Notification.Font = Enum.Font.GothamBold
Notification.TextSize = 12
Notification.Text = "Notification"
Notification.TextWrapped = true -- Allow multi-line errors
Notification.Visible = false
Notification.ZIndex = 100
Notification.Parent = MainFrame

local NotifCorner = Instance.new("UICorner")
NotifCorner.CornerRadius = UDim.new(0, 6)
NotifCorner.Parent = Notification

local function notify(text, color)
    spawn(function()
        Notification.Text = text
        Notification.TextColor3 = color
        Notification.Visible = true
        wait(2)
        Notification.Visible = false
    end)
end

-- Header (Draggable)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = THEME.Sidebar
Header.BorderSizePixel = 0
Header.Active = true -- Important for Delta
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local HeaderCover = Instance.new("Frame") -- Square off bottom
HeaderCover.Size = UDim2.new(1, 0, 0, 10)
HeaderCover.Position = UDim2.new(0, 0, 1, -10)
HeaderCover.BackgroundColor3 = THEME.Sidebar
HeaderCover.BorderSizePixel = 0
HeaderCover.Parent = Header

local Title = Instance.new("TextLabel")
Title.Text = "XuanHub"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextColor3 = THEME.Accent
Title.Size = UDim2.new(0, 100, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Global Search Bar (in Header)
local GlobalSearchBar = Instance.new("TextBox")
GlobalSearchBar.Size = UDim2.new(0, 200, 0, 30)
GlobalSearchBar.Position = UDim2.new(0, 130, 0.5, -15)
GlobalSearchBar.BackgroundColor3 = THEME.Item
GlobalSearchBar.TextColor3 = THEME.Text
GlobalSearchBar.Text = ""
GlobalSearchBar.PlaceholderText = "🔍 Search all scripts..."
GlobalSearchBar.Font = Enum.Font.Gotham
GlobalSearchBar.TextSize = 12
GlobalSearchBar.ClearTextOnFocus = false
GlobalSearchBar.Parent = Header

local GlobalSearchCorner = Instance.new("UICorner")
GlobalSearchCorner.CornerRadius = UDim.new(0, 6)
GlobalSearchCorner.Parent = GlobalSearchBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "-"
CloseBtn.Size = UDim2.new(0, 45, 1, 0)
CloseBtn.Position = UDim2.new(1, -90, 0, 0) -- Moved left
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = THEME.SubText
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 24
CloseBtn.Parent = Header

local ExitBtn = Instance.new("TextButton")
ExitBtn.Text = "X"
ExitBtn.Size = UDim2.new(0, 45, 1, 0)
ExitBtn.Position = UDim2.new(1, -45, 0, 0)
ExitBtn.BackgroundTransparency = 1
ExitBtn.TextColor3 = THEME.Red
ExitBtn.Font = Enum.Font.GothamBold
ExitBtn.TextSize = 20
ExitBtn.Parent = Header

-- Sidebar
local Sidebar = Instance.new("ScrollingFrame") -- Scrollable
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 130, 1, -45) -- Narrower
Sidebar.Position = UDim2.new(0, 0, 0, 45)
Sidebar.BackgroundColor3 = THEME.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.ScrollBarThickness = 2
Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 10)
SidebarCorner.Parent = Sidebar

local SidebarCover = Instance.new("Frame") -- Square off right
SidebarCover.Size = UDim2.new(0, 10, 1, 0)
SidebarCover.Position = UDim2.new(1, -10, 0, 0)
SidebarCover.BackgroundColor3 = THEME.Sidebar
SidebarCover.BorderSizePixel = 0
SidebarCover.Parent = Sidebar

-- Content Area
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -140, 1, -55) -- Adjusted
Content.Position = UDim2.new(0, 135, 0, 50) -- Adjusted
Content.BackgroundColor3 = THEME.Background
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Floating Button (Minimized)
local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Name = "FloatingBtn"
FloatingBtn.Size = UDim2.new(0, 50, 0, 50)
FloatingBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
FloatingBtn.BackgroundColor3 = THEME.Sidebar
FloatingBtn.Text = "XH"
FloatingBtn.TextColor3 = THEME.Accent
FloatingBtn.Font = Enum.Font.GothamBold
FloatingBtn.TextSize = 20
FloatingBtn.Visible = false
FloatingBtn.Active = true -- Important for Delta
FloatingBtn.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0) -- Circle
FloatCorner.Parent = FloatingBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = THEME.Accent
FloatStroke.Thickness = 2
FloatStroke.Parent = FloatingBtn

-- Dragging Logic (Robust for Delta)
local function makeDraggable(topbarobject, object)
	local Dragging = nil
	local DragInput = nil
	local DragStart = nil
	local StartPosition = nil

	local function Update(input)
		local Delta = input.Position - DragStart
		local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
		object.Position = pos
	end

	topbarobject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = input.Position
			StartPosition = object.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)

	topbarobject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			DragInput = input
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			Update(input)
		end
	end)
end

makeDraggable(Header, MainFrame)
makeDraggable(FloatingBtn, FloatingBtn)

-- Minimize/Maximize/Close
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    FloatingBtn.Visible = true
end)

ExitBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

FloatingBtn.MouseButton1Click:Connect(function()
    -- Check if it was a click or a drag (simple check: if mouse didn't move much)
    MainFrame.Visible = true
    FloatingBtn.Visible = false
end)

-- Navigation System
local currentTab = nil
local tabs = {}

local function createTabButton(name, order)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, 10 + (order * 45))
    btn.BackgroundColor3 = THEME.Sidebar
    btn.BackgroundTransparency = 1
    btn.Text = "  " .. name
    btn.TextColor3 = THEME.SubText
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = Sidebar
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    return btn
end

local function switchTab(name)
    if currentTab then
        TweenService:Create(currentTab.Button, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = THEME.SubText}):Play()
        currentTab.Page.Visible = false
    end
    
    local newTab = tabs[name]
    if newTab then
        TweenService:Create(newTab.Button, TweenInfo.new(0.2), {BackgroundTransparency = 0, BackgroundColor3 = THEME.Item, TextColor3 = THEME.Accent}):Play()
        newTab.Page.Visible = true
        currentTab = newTab
    end
end

-- PAGE: Auto Execute
local AutoExecPage = Instance.new("Frame")
AutoExecPage.Size = UDim2.new(1, 0, 1, 0)
AutoExecPage.BackgroundTransparency = 1
AutoExecPage.Visible = false
AutoExecPage.Parent = Content

-- AutoExec List (Left Side)
local AutoListContainer = Instance.new("Frame")
AutoListContainer.Size = UDim2.new(0, 140, 1, 0)
AutoListContainer.BackgroundColor3 = THEME.Item
AutoListContainer.Parent = AutoExecPage

local AutoListCorner = Instance.new("UICorner")
AutoListCorner.CornerRadius = UDim.new(0, 8)
AutoListCorner.Parent = AutoListContainer

local AutoList = Instance.new("ScrollingFrame")
AutoList.Size = UDim2.new(1, -10, 1, -10)
AutoList.Position = UDim2.new(0, 5, 0, 5)
AutoList.BackgroundTransparency = 1
AutoList.ScrollBarThickness = 2
AutoList.AutomaticCanvasSize = Enum.AutomaticSize.Y
AutoList.CanvasSize = UDim2.new(0, 0, 0, 0)
AutoList.Parent = AutoListContainer

local AutoListLayout = Instance.new("UIListLayout")
AutoListLayout.Padding = UDim.new(0, 5)
AutoListLayout.Parent = AutoList

-- AutoExec Editor (Right Side)
local AutoEditorContainer = Instance.new("Frame")
AutoEditorContainer.Size = UDim2.new(1, -150, 1, 0)
AutoEditorContainer.Position = UDim2.new(0, 150, 0, 0)
AutoEditorContainer.BackgroundTransparency = 1
AutoEditorContainer.Parent = AutoExecPage

local AutoFileNameBox = Instance.new("TextBox")
AutoFileNameBox.Size = UDim2.new(1, 0, 0, 30)
AutoFileNameBox.Position = UDim2.new(0, 0, 0, 0)
AutoFileNameBox.BackgroundColor3 = THEME.Item
AutoFileNameBox.TextColor3 = THEME.Accent
AutoFileNameBox.Font = Enum.Font.GothamBold
AutoFileNameBox.TextSize = 14
AutoFileNameBox.Text = "AutoExec Name"
AutoFileNameBox.ClearTextOnFocus = false
AutoFileNameBox.Parent = AutoEditorContainer

local AutoFileCorner = Instance.new("UICorner")
AutoFileCorner.CornerRadius = UDim.new(0, 6)
AutoFileCorner.Parent = AutoFileNameBox

local AutoEditor = Instance.new("TextBox")
AutoEditor.Size = UDim2.new(1, 0, 1, -80)
AutoEditor.Position = UDim2.new(0, 0, 0, 35)
AutoEditor.BackgroundColor3 = THEME.Item
AutoEditor.TextColor3 = THEME.Text
AutoEditor.Font = Enum.Font.Code
AutoEditor.TextSize = 13
AutoEditor.TextXAlignment = Enum.TextXAlignment.Left
AutoEditor.TextYAlignment = Enum.TextYAlignment.Top
AutoEditor.ClearTextOnFocus = false
AutoEditor.MultiLine = true
AutoEditor.TextWrapped = true
AutoEditor.Text = "-- Select an auto-exec file"
AutoEditor.Parent = AutoEditorContainer

local AutoEditorPadding = Instance.new("UIPadding")
AutoEditorPadding.PaddingLeft = UDim.new(0, 8)
AutoEditorPadding.PaddingRight = UDim.new(0, 8)
AutoEditorPadding.PaddingTop = UDim.new(0, 8)
AutoEditorPadding.PaddingBottom = UDim.new(0, 8)
AutoEditorPadding.Parent = AutoEditor

local AutoEditorCorner = Instance.new("UICorner")
AutoEditorCorner.CornerRadius = UDim.new(0, 8)
AutoEditorCorner.Parent = AutoEditor

-- AutoExec Controls
local AutoControls = Instance.new("Frame")
AutoControls.Size = UDim2.new(1, 0, 0, 40)
AutoControls.Position = UDim2.new(0, 0, 1, -40)
AutoControls.BackgroundTransparency = 1
AutoControls.Parent = AutoEditorContainer

local CurrentAutoFile = nil

local function createAutoBtn(text, color, posScale, callback)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Size = UDim2.new(0.24, 0, 0, 30) -- 4 buttons
    btn.Position = UDim2.new(posScale, 0, 0.5, -15)
    btn.Parent = AutoControls
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

function refreshAutoExec()
    for _, v in pairs(AutoList:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    
    local files = listfiles(AUTOEXEC_DIR)
    for _, file in pairs(files) do
        local name = file:match("([^/]+)$")
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundColor3 = THEME.Sidebar
        btn.Text = name
        btn.TextColor3 = THEME.Text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.Parent = AutoList
        
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 4)
        c.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            CurrentAutoFile = name
            AutoFileNameBox.Text = name
            AutoEditor.Text = readfile(file)
            for _, b in pairs(AutoList:GetChildren()) do
                if b:IsA("TextButton") then b.BackgroundColor3 = THEME.Sidebar end
            end
            btn.BackgroundColor3 = THEME.Accent
        end)
    end
    AutoList.CanvasSize = UDim2.new(0, 0, 0, #files * 35)
end

-- Buttons: Save, New, Delete, Clear
createAutoBtn("💾", THEME.Accent, 0, function()
    if CurrentAutoFile then
        writefile(AUTOEXEC_DIR .. "/" .. CurrentAutoFile, AutoEditor.Text)
        notify("Saved AutoExec!", THEME.Accent)
    end
end)

createAutoBtn("📄", THEME.Sidebar, 0.25, function()
    CurrentAutoFile = nil
    AutoEditor.Text = ""
    local name = "Auto_" .. math.random(1000) .. ".txt"
    CurrentAutoFile = name
    AutoFileNameBox.Text = name
    writefile(AUTOEXEC_DIR .. "/" .. name, "")
    refreshAutoExec()
    notify("New AutoExec Created!", THEME.Sidebar)
end)

createAutoBtn("🗑", THEME.Red, 0.50, function()
    if CurrentAutoFile then
        delfile(AUTOEXEC_DIR .. "/" .. CurrentAutoFile)
        CurrentAutoFile = nil
        AutoEditor.Text = ""
        AutoFileNameBox.Text = "AutoExec Name"
        refreshAutoExec()
        notify("Deleted!", THEME.Red)
    end
end)

createAutoBtn("Clear", THEME.Sidebar, 0.75, function()
    AutoEditor.Text = ""
    notify("Cleared!", THEME.Sidebar)
end)

-- PAGE: Settings
local SettingsPage = Instance.new("Frame")
SettingsPage.Size = UDim2.new(1, 0, 1, 0)
SettingsPage.BackgroundTransparency = 1
SettingsPage.Visible = false
SettingsPage.Parent = Content

local SettingsList = Instance.new("UIListLayout")
SettingsList.Padding = UDim.new(0, 10)
SettingsList.Parent = SettingsPage

-- Discord Section
local DiscordBtn = Instance.new("TextButton")
DiscordBtn.Size = UDim2.new(1, 0, 0, 40)
DiscordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242) -- Discord Blurple
DiscordBtn.Text = "Join Discord Server"
DiscordBtn.TextColor3 = Color3.new(1,1,1)
DiscordBtn.Font = Enum.Font.GothamBold
DiscordBtn.TextSize = 14
DiscordBtn.Parent = SettingsPage

local DiscordCorner = Instance.new("UICorner")
DiscordCorner.CornerRadius = UDim.new(0, 8)
DiscordCorner.Parent = DiscordBtn

DiscordBtn.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/kaydensdens")
    notify("Link Copied to Clipboard!", Color3.fromRGB(88, 101, 242))
end)

-- Theme Section
local ThemeLabel = Instance.new("TextLabel")
ThemeLabel.Size = UDim2.new(1, 0, 0, 30)
ThemeLabel.BackgroundTransparency = 1
ThemeLabel.Text = "Theme Color"
ThemeLabel.TextColor3 = THEME.SubText
ThemeLabel.Font = Enum.Font.GothamBold
ThemeLabel.TextSize = 14
ThemeLabel.TextXAlignment = Enum.TextXAlignment.Left
ThemeLabel.Parent = SettingsPage

local ColorContainer = Instance.new("Frame")
ColorContainer.Size = UDim2.new(1, 0, 0, 40)
ColorContainer.BackgroundTransparency = 1
ColorContainer.Parent = SettingsPage

local ColorLayout = Instance.new("UIListLayout")
ColorLayout.FillDirection = Enum.FillDirection.Horizontal
ColorLayout.Padding = UDim.new(0, 10)
ColorLayout.Parent = ColorContainer

local colors = {
    {Color3.fromRGB(236, 72, 153), "Pink"},
    {Color3.fromRGB(60, 200, 110), "Green"},
    {Color3.fromRGB(88, 101, 242), "Blue"},
    {Color3.fromRGB(220, 60, 60), "Red"},
    {Color3.fromRGB(255, 170, 0), "Orange"},
    {Color3.fromRGB(170, 0, 255), "Purple"}
}

local function updateAccent(newColor)
    THEME.Accent = newColor
    Title.TextColor3 = newColor
    FloatingBtn.TextColor3 = newColor
    FloatStroke.Color = newColor
    FileNameBox.TextColor3 = newColor
    
    -- Update active tab color if needed
    if currentTab then
        currentTab.Button.TextColor3 = newColor
    end
    
    -- Update Save Button (It's the 2nd button in Controls)
    -- We need to find it dynamically or store it. 
    -- Since we know the order, we can iterate.
    for _, btn in pairs(Controls:GetChildren()) do
        if btn:IsA("TextButton") and btn.Text == "💾" then
            btn.BackgroundColor3 = newColor
        end
    end
end

for _, colorData in ipairs(colors) do
    local colorBtn = Instance.new("TextButton")
    colorBtn.Size = UDim2.new(0, 30, 0, 30)
    colorBtn.BackgroundColor3 = colorData[1]
    colorBtn.Text = ""
    colorBtn.Parent = ColorContainer
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = colorBtn
    
    colorBtn.MouseButton1Click:Connect(function()
        updateAccent(colorData[1])
        notify("Theme Changed: " .. colorData[2], colorData[1])
    end)
end

-- Utilities Section
local UtilsLabel = Instance.new("TextLabel")
UtilsLabel.Size = UDim2.new(1, 0, 0, 30)
UtilsLabel.BackgroundTransparency = 1
UtilsLabel.Text = "Utilities"
UtilsLabel.TextColor3 = THEME.SubText
UtilsLabel.Font = Enum.Font.GothamBold
UtilsLabel.TextSize = 14
UtilsLabel.TextXAlignment = Enum.TextXAlignment.Left
UtilsLabel.Parent = SettingsPage

local UtilsContainer = Instance.new("Frame")
UtilsContainer.Size = UDim2.new(1, 0, 0, 170) -- Increased height for more buttons
UtilsContainer.BackgroundTransparency = 1
UtilsContainer.Parent = SettingsPage

local UtilsLayout = Instance.new("UIListLayout")
UtilsLayout.Padding = UDim.new(0, 10)
UtilsLayout.Parent = UtilsContainer

local function createUtilBtn(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = THEME.Item
    btn.Text = text
    btn.TextColor3 = THEME.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = UtilsContainer
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Rejoin Server
createUtilBtn("Rejoin Server", function()
    notify("Rejoining...", THEME.Accent)
    game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
end)

-- Server Hop (Public)
createUtilBtn("Server Hop (Public)", function()
    notify("Finding Server...", THEME.Accent)
    local Http = game:GetService("HttpService")
    local TPS = game:GetService("TeleportService")
    local Api = "https://games.roblox.com/v1/games/"
    
    local _place = game.PlaceId
    local _servers = Api.._place.."/servers/Public?sortOrder=Asc&limit=100"
    
    local function ListServers(cursor)
        local Raw = game:HttpGet(_servers .. ((cursor and "&cursor="..cursor) or ""))
        return Http:JSONDecode(Raw)
    end
    
    local Server, Next; repeat
        local Servers = ListServers(Next)
        Server = Servers.data[1]
        Next = Servers.nextPageCursor
    until Server
    
    TPS:TeleportToPlaceInstance(_place, Server.id, game.Players.LocalPlayer)
end)

-- Anti-AFK (Auto-enabled)
local antiAfkEnabled = true
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

createUtilBtn("Anti-AFK (Enabled)", function()
    notify("Anti-AFK is already enabled automatically!", THEME.Green)
end)

-- Auto Reconnect (Auto-enabled)
local autoRejoinEnabled = true
pcall(function()
    game.CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
        if child.Name == 'ErrorPrompt' and child:FindFirstChild('MessageArea') and child.MessageArea:FindFirstChild("ErrorFrame") then
            game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
        end
    end)
end)

createUtilBtn("Auto Reconnect (Enabled)", function()
    notify("Auto Reconnect is already enabled automatically!", THEME.Green)
end)

-- PAGE: Grow a Garden
local GrowGardenPage = Instance.new("Frame")
GrowGardenPage.Size = UDim2.new(1, 0, 1, 0)
GrowGardenPage.BackgroundTransparency = 1
GrowGardenPage.Visible = false
GrowGardenPage.Parent = Content

local GardenList = Instance.new("UIListLayout")
GardenList.Padding = UDim.new(0, 10)
GardenList.Parent = GrowGardenPage

-- Variables for Auto Collection
local EmptyTable3 = {}
local FalseValue5 = false
local HumanoidRootPart

-- Get character data
local function GetImportantDataFunc()
    local char = getCharacter()
    if char then
        HumanoidRootPart = char:FindFirstChild("HumanoidRootPart")
        return char
    end
    return nil
end



-- Panther Method Button
local PantherMethodBtn = Instance.new("TextButton")
PantherMethodBtn.Size = UDim2.new(1, 0, 0, 45)
PantherMethodBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226) -- Purple
PantherMethodBtn.Text = "🐆 Panther Method"
PantherMethodBtn.TextColor3 = Color3.new(1,1,1)
PantherMethodBtn.Font = Enum.Font.GothamBold
PantherMethodBtn.TextSize = 16
PantherMethodBtn.Parent = GrowGardenPage

local PantherCorner = Instance.new("UICorner")
PantherCorner.CornerRadius = UDim.new(0, 8)
PantherCorner.Parent = PantherMethodBtn

-- Mutation Selection Container (Initially Hidden)
local MutationContainer = Instance.new("Frame")
MutationContainer.Size = UDim2.new(1, 0, 0, 0) -- Will expand when shown
MutationContainer.BackgroundColor3 = THEME.Item
MutationContainer.Visible = false
MutationContainer.Parent = GrowGardenPage
MutationContainer.ClipsDescendants = true

local MutationCorner = Instance.new("UICorner")
MutationCorner.CornerRadius = UDim.new(0, 8)
MutationCorner.Parent = MutationContainer

local MutationLayout = Instance.new("UIListLayout")
MutationLayout.Padding = UDim.new(0, 10)
MutationLayout.Parent = MutationContainer
MutationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Panther Back Button
local PantherBackBtn = Instance.new("TextButton")
PantherBackBtn.Size = UDim2.new(1, -20, 0, 35)
PantherBackBtn.BackgroundColor3 = THEME.Sidebar
PantherBackBtn.Text = "← Back"
PantherBackBtn.TextColor3 = Color3.fromRGB(138, 43, 226)
PantherBackBtn.Font = Enum.Font.GothamBold
PantherBackBtn.TextSize = 14
PantherBackBtn.Parent = MutationContainer

local PantherBackCorner = Instance.new("UICorner")
PantherBackCorner.CornerRadius = UDim.new(0, 6)
PantherBackCorner.Parent = PantherBackBtn

-- Mutation Dropdown Label
local MutationLabel = Instance.new("TextLabel")
MutationLabel.Size = UDim2.new(1, -20, 0, 30)
MutationLabel.BackgroundTransparency = 1
MutationLabel.Text = "Mutations to Auto Collect:"
MutationLabel.TextColor3 = Color3.fromRGB(138, 43, 226) -- Purple
MutationLabel.Font = Enum.Font.GothamBold
MutationLabel.TextSize = 14
MutationLabel.TextXAlignment = Enum.TextXAlignment.Left
MutationLabel.Parent = MutationContainer

-- Scrollable Mutation List
local MutationScrollFrame = Instance.new("ScrollingFrame")
MutationScrollFrame.Size = UDim2.new(1, -20, 0, 300)
MutationScrollFrame.BackgroundColor3 = THEME.Background
MutationScrollFrame.BorderSizePixel = 0
MutationScrollFrame.ScrollBarThickness = 4
MutationScrollFrame.Parent = MutationContainer

local MutationScrollCorner = Instance.new("UICorner")
MutationScrollCorner.CornerRadius = UDim.new(0, 6)
MutationScrollCorner.Parent = MutationScrollFrame

local MutationListLayout = Instance.new("UIListLayout")
MutationListLayout.Padding = UDim.new(0, 5)
MutationListLayout.Parent = MutationScrollFrame

-- Dynamically get all mutations from MutationHandler
local AllMutations = {}
local AllVariants = {}
local MutationEnums = {}
local VariantsEnums = {}

pcall(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local MutationHandler = require(ReplicatedStorage.Modules.MutationHandler)
    MutationEnums = MutationHandler:GetMutationsToEnums()

    for Name, _ in pairs(MutationEnums) do
        table.insert(AllMutations, Name)
    end

    _G.MutationEnums = MutationEnums
    _G.MutationNames = AllMutations

    -- Dynamically get all variants from MutationHandler
    VariantsEnums = MutationHandler:GetVariantsToEnums()

    for Name, _ in pairs(VariantsEnums) do
        table.insert(AllVariants, Name)
    end

    _G.VariantsEnums = VariantsEnums
    _G.VariantNames = AllVariants
end)

-- Fallback if MutationHandler not found
if #AllMutations == 0 then
    AllMutations = {"Rainbow", "Gold", "Silver", "Diamond"}
    warn("MutationHandler not found, using fallback mutations")
end

if #AllVariants == 0 then
    AllVariants = {"Normal", "Rainbow", "Gold", "Silver"}
    warn("MutationHandler not found, using fallback variants")
end

-- Create mutation checkboxes
local MutationCheckboxes = {}
local ExcludedMutations = {} -- Track excluded mutations

for _, mutationName in ipairs(AllMutations) do
    local checkboxFrame = Instance.new("Frame")
    checkboxFrame.Size = UDim2.new(1, -10, 0, 25)
    checkboxFrame.BackgroundColor3 = THEME.Sidebar
    checkboxFrame.Parent = MutationScrollFrame
    
    local cbCorner = Instance.new("UICorner")
    cbCorner.CornerRadius = UDim.new(0, 4)
    cbCorner.Parent = checkboxFrame
    
    local checkbox = Instance.new("TextButton")
    checkbox.Size = UDim2.new(0, 20, 0, 20)
    checkbox.Position = UDim2.new(0, 5, 0.5, -10)
    checkbox.BackgroundColor3 = THEME.Background
    checkbox.Text = ""
    checkbox.Parent = checkboxFrame
    
    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 4)
    checkCorner.Parent = checkbox
    
    local checkmark = Instance.new("TextLabel")
    checkmark.Size = UDim2.new(1, 0, 1, 0)
    checkmark.BackgroundTransparency = 1
    checkmark.Text = "✓"
    checkmark.TextColor3 = Color3.fromRGB(138, 43, 226) -- Purple
    checkmark.Font = Enum.Font.GothamBold
    checkmark.TextSize = 14
    checkmark.Visible = true -- Default selected
    checkmark.Parent = checkbox
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -35, 1, 0)
    label.Position = UDim2.new(0, 30, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = mutationName
    label.TextColor3 = THEME.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = checkboxFrame
    
    MutationCheckboxes[mutationName] = {Checkbox = checkbox, Checkmark = checkmark, Selected = true}
    table.insert(EmptyTable3, mutationName) -- Add to EmptyTable3 by default
    
    checkbox.MouseButton1Click:Connect(function()
        MutationCheckboxes[mutationName].Selected = not MutationCheckboxes[mutationName].Selected
        checkmark.Visible = MutationCheckboxes[mutationName].Selected
        
        -- Update EmptyTable3
        EmptyTable3 = {}
        for name, data in pairs(MutationCheckboxes) do
            if data.Selected then
                table.insert(EmptyTable3, name)
            end
        end
    end)
    
    -- Right-click to exclude mutation
    checkbox.MouseButton2Click:Connect(function()
        if table.find(ExcludedMutations, mutationName) then
            -- Remove from excluded
            for i, name in ipairs(ExcludedMutations) do
                if name == mutationName then
                    table.remove(ExcludedMutations, i)
                    checkboxFrame.BackgroundColor3 = THEME.Sidebar
                    notify(mutationName .. " no longer excluded", Color3.fromRGB(138, 43, 226))
                    break
                end
            end
        else
            -- Add to excluded
            table.insert(ExcludedMutations, mutationName)
            checkboxFrame.BackgroundColor3 = Color3.fromRGB(80, 20, 20) -- Dark red
            notify(mutationName .. " excluded from collection", Color3.fromRGB(220, 60, 60))
        end
    end)
end

MutationScrollFrame.CanvasSize = UDim2.new(0, 0, 0, #AllMutations * 30)

-- Toggle for Auto Collect
local ToggleContainer = Instance.new("Frame")
ToggleContainer.Size = UDim2.new(1, -20, 0, 40)
ToggleContainer.BackgroundColor3 = THEME.Sidebar
ToggleContainer.Parent = MutationContainer

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleContainer

local ToggleLabel = Instance.new("TextLabel")
ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
ToggleLabel.BackgroundTransparency = 1
ToggleLabel.Text = " Panther Method (12+ Mutations)"
ToggleLabel.TextColor3 = THEME.Text
ToggleLabel.Font = Enum.Font.GothamBold
ToggleLabel.TextSize = 12
ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
ToggleLabel.Parent = ToggleContainer

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 25)
ToggleButton.Position = UDim2.new(1, -55, 0.5, -12.5)
ToggleButton.BackgroundColor3 = THEME.Red
ToggleButton.Text = "OFF"
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 11
ToggleButton.Parent = ToggleContainer

local ToggleBtnCorner = Instance.new("UICorner")
ToggleBtnCorner.CornerRadius = UDim.new(0, 6)
ToggleBtnCorner.Parent = ToggleButton

-- Toggle functionality
ToggleButton.MouseButton1Click:Connect(function()
    FalseValue5 = not FalseValue5
    
    if FalseValue5 then
        ToggleButton.BackgroundColor3 = THEME.Green
        ToggleButton.Text = "ON"
        notify("Auto Collect Started!", Color3.fromRGB(138, 43, 226))
        
        task.spawn(function()
            while true do
                if not FalseValue5 then
                    return
                end
                local Result1 = GetImportantDataFunc()
                local Important1 = Result1 and Result1:FindFirstChild("Important") and Result1.Important:FindFirstChild("Plants_Physical")
                if Important1 then
                    local ImportantChild4, ImportantChild5, ImportantChild6 = ipairs(Important1:GetChildren())
                    while true do
                        local Plant1
                        ImportantChild6, Plant1 = ImportantChild4(ImportantChild5, ImportantChild6)
                        if ImportantChild6 == nil then
                            break
                        end
                        local Fruits1 = Plant1:FindFirstChild("Fruits")
                        if Fruits1 then
                            local Fruit4, Fruit5, Fruit6 = ipairs(Fruits1:GetChildren())
                            while true do
                                local Orb3
                                Fruit6, Orb3 = Fruit4(Fruit5, Fruit6)
                                if Fruit6 == nil then
                                    break
                                end
                                -- Count total mutations on the fruit
                                local mutationCount = 0
                                
                                -- Count mutations in main descendants
                                for _, descendant in ipairs(Orb3:GetDescendants()) do
                                    if descendant:IsA("Folder") or descendant:IsA("Model") then
                                        -- Check if this is a mutation marker
                                        for mutationName, _ in pairs(_G.MutationEnums) do
                                            if descendant.Name:find(mutationName) and not table.find(ExcludedMutations, mutationName) then
                                                mutationCount = mutationCount + 1
                                                break
                                            end
                                        end
                                    end
                                end
                                
                                -- Count mutations in Variant folder
                                local Variant1 = Orb3:FindFirstChild("Variant")
                                if Variant1 then
                                    for _, variantDesc in ipairs(Variant1:GetDescendants()) do
                                        if variantDesc:IsA("Folder") or variantDesc:IsA("Model") then
                                            for mutationName, _ in pairs(_G.MutationEnums) do
                                                if variantDesc.Name:find(mutationName) and not table.find(ExcludedMutations, mutationName) then
                                                    mutationCount = mutationCount + 1
                                                    break
                                                end
                                            end
                                        end
                                    end
                                end
                                
                                -- Check if fruit has 12 or more mutations
                                local Flag1 = mutationCount >= 12
                                
                                if Flag1 then
                                    -- Collect remotely without teleporting
                                    for _, UtilityObject in ipairs(Orb3:GetDescendants()) do
                                        if UtilityObject:IsA("ProximityPrompt") then
                                            local fruitPivot = Orb3.GetPivot and Orb3:GetPivot().Position or Orb3:GetModelCFrame().Position
                                            local charPivot = GetImportantDataFunc() and GetImportantDataFunc():GetPivot().Position
                                            if charPivot and (fruitPivot - charPivot).Magnitude < 150 then
                                                pcall(function()
                                                    fireproximityprompt(UtilityObject)
                                                    task.wait(0.01)
                                                end)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(0.25)
            end
        end)
    else
        ToggleButton.BackgroundColor3 = THEME.Red
        ToggleButton.Text = "OFF"
        notify("Auto Collect Stopped!", THEME.Red)
    end
end)

-- State variables for method toggles
local pantherExpanded = false
local magpieExpanded = false

-- Panther Back Button functionality
PantherBackBtn.MouseButton1Click:Connect(function()
    pantherExpanded = false
    TweenService:Create(MutationContainer, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0)}):Play()
    task.wait(0.3)
    MutationContainer.Visible = false
    notify("Panther Method Closed", Color3.fromRGB(138, 43, 226))
end)

-- Panther Method Button Toggle
PantherMethodBtn.MouseButton1Click:Connect(function()
    pantherExpanded = not pantherExpanded
    if pantherExpanded then
        MagpieContainer.Visible = false
        magpieExpanded = false
        MutationContainer.Visible = true
        TweenService:Create(MutationContainer, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 445)}):Play()
        notify("Panther Method Activated!", Color3.fromRGB(138, 43, 226))
    else
        TweenService:Create(MutationContainer, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0)}):Play()
        task.wait(0.3)
        MutationContainer.Visible = false
    end
end)

-- Magpie Method Button
local MagpieMethodBtn = Instance.new("TextButton")
MagpieMethodBtn.Size = UDim2.new(1, 0, 0, 45)
MagpieMethodBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0) -- Gold
MagpieMethodBtn.Text = "✨ Magpie Method"
MagpieMethodBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
MagpieMethodBtn.Font = Enum.Font.GothamBold
MagpieMethodBtn.TextSize = 16
MagpieMethodBtn.Parent = GrowGardenPage

local MagpieCorner = Instance.new("UICorner")
MagpieCorner.CornerRadius = UDim.new(0, 8)
MagpieCorner.Parent = MagpieMethodBtn

-- Magpie Container
local MagpieContainer = Instance.new("Frame")
MagpieContainer.Size = UDim2.new(1, 0, 0, 0)
MagpieContainer.BackgroundColor3 = THEME.Item
MagpieContainer.Visible = false
MagpieContainer.Parent = GrowGardenPage
MagpieContainer.ClipsDescendants = true

local MagpieContainerCorner = Instance.new("UICorner")
MagpieContainerCorner.CornerRadius = UDim.new(0, 8)
MagpieContainerCorner.Parent = MagpieContainer

local MagpieLayout = Instance.new("UIListLayout")
MagpieLayout.Padding = UDim.new(0, 10)
MagpieLayout.Parent = MagpieContainer
MagpieLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Magpie Back Button
local MagpieBackBtn = Instance.new("TextButton")
MagpieBackBtn.Size = UDim2.new(1, -20, 0, 35)
MagpieBackBtn.BackgroundColor3 = THEME.Sidebar
MagpieBackBtn.Text = "← Back"
MagpieBackBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
MagpieBackBtn.Font = Enum.Font.GothamBold
MagpieBackBtn.TextSize = 14
MagpieBackBtn.Parent = MagpieContainer

local MagpieBackCorner = Instance.new("UICorner")
MagpieBackCorner.CornerRadius = UDim.new(0, 6)
MagpieBackCorner.Parent = MagpieBackBtn

-- Magpie Label
local MagpieLabel = Instance.new("TextLabel")
MagpieLabel.Size = UDim2.new(1, -20, 0, 30)
MagpieLabel.BackgroundTransparency = 1
MagpieLabel.Text = "Variants to Auto Collect:"
MagpieLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
MagpieLabel.Font = Enum.Font.GothamBold
MagpieLabel.TextSize = 14
MagpieLabel.TextXAlignment = Enum.TextXAlignment.Left
MagpieLabel.Parent = MagpieContainer

-- Magpie Checkboxes Container (Scrollable)
local MagpieCheckboxFrame = Instance.new("ScrollingFrame")
MagpieCheckboxFrame.Size = UDim2.new(1, -20, 0, 200)
MagpieCheckboxFrame.BackgroundColor3 = THEME.Background
MagpieCheckboxFrame.BorderSizePixel = 0
MagpieCheckboxFrame.ScrollBarThickness = 4
MagpieCheckboxFrame.Parent = MagpieContainer

local MagpieCheckboxCorner = Instance.new("UICorner")
MagpieCheckboxCorner.CornerRadius = UDim.new(0, 6)
MagpieCheckboxCorner.Parent = MagpieCheckboxFrame

local MagpieCheckboxLayout = Instance.new("UIListLayout")
MagpieCheckboxLayout.Padding = UDim.new(0, 5)
MagpieCheckboxLayout.Parent = MagpieCheckboxFrame

-- Dynamically create checkboxes for all variants
local MagpieCheckboxes = {}
local MagpieSelectedVariants = {}
local ExcludedVariants = {} -- Track excluded variants

for _, variantName in ipairs(AllVariants) do
    local checkboxFrame = Instance.new("Frame")
    checkboxFrame.Size = UDim2.new(1, -10, 0, 25)
    checkboxFrame.BackgroundColor3 = THEME.Sidebar
    checkboxFrame.Parent = MagpieCheckboxFrame
    
    local cbCorner = Instance.new("UICorner")
    cbCorner.CornerRadius = UDim.new(0, 4)
    cbCorner.Parent = checkboxFrame
    
    local checkbox = Instance.new("TextButton")
    checkbox.Size = UDim2.new(0, 20, 0, 20)
    checkbox.Position = UDim2.new(0, 5, 0.5, -10)
    checkbox.BackgroundColor3 = THEME.Background
    checkbox.Text = ""
    checkbox.Parent = checkboxFrame
    
    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 4)
    checkCorner.Parent = checkbox
    
    local checkmark = Instance.new("TextLabel")
    checkmark.Size = UDim2.new(1, 0, 1, 0)
    checkmark.BackgroundTransparency = 1
    checkmark.Text = "✓"
    checkmark.TextColor3 = Color3.fromRGB(255, 215, 0)
    checkmark.Font = Enum.Font.GothamBold
    checkmark.TextSize = 14
    checkmark.Visible = true -- Default selected
    checkmark.Parent = checkbox
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -35, 1, 0)
    label.Position = UDim2.new(0, 30, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = variantName
    label.TextColor3 = THEME.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = checkboxFrame
    
    MagpieCheckboxes[variantName] = {Checkbox = checkbox, Checkmark = checkmark, Selected = true}
    table.insert(MagpieSelectedVariants, variantName)
    
    checkbox.MouseButton1Click:Connect(function()
        MagpieCheckboxes[variantName].Selected = not MagpieCheckboxes[variantName].Selected
        checkmark.Visible = MagpieCheckboxes[variantName].Selected
        
        -- Update selected variants
        MagpieSelectedVariants = {}
        for name, data in pairs(MagpieCheckboxes) do
            if data.Selected then
                table.insert(MagpieSelectedVariants, name)
            end
        end
    end)
    
    -- Right-click to exclude variant
    checkbox.MouseButton2Click:Connect(function()
        if table.find(ExcludedVariants, variantName) then
            -- Remove from excluded
            for i, name in ipairs(ExcludedVariants) do
                if name == variantName then
                    table.remove(ExcludedVariants, i)
                    checkboxFrame.BackgroundColor3 = THEME.Sidebar
                    notify(variantName .. " no longer excluded", Color3.fromRGB(255, 215, 0))
                    break
                end
            end
        else
            -- Add to excluded
            table.insert(ExcludedVariants, variantName)
            checkboxFrame.BackgroundColor3 = Color3.fromRGB(80, 40, 0) -- Dark orange
            notify(variantName .. " excluded from collection", Color3.fromRGB(220, 60, 60))
        end
    end)
end

-- Manual Variant Input (Fallback)
local ManualVariantLabel = Instance.new("TextLabel")
ManualVariantLabel.Size = UDim2.new(1, -20, 0, 25)
ManualVariantLabel.BackgroundTransparency = 1
ManualVariantLabel.Text = "Manual Variants (comma-separated):"
ManualVariantLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
ManualVariantLabel.Font = Enum.Font.GothamBold
ManualVariantLabel.TextSize = 12
ManualVariantLabel.TextXAlignment = Enum.TextXAlignment.Left
ManualVariantLabel.Parent = MagpieContainer

local ManualVariantInput = Instance.new("TextBox")
ManualVariantInput.Size = UDim2.new(1, -20, 0, 35)
ManualVariantInput.BackgroundColor3 = THEME.Background
ManualVariantInput.PlaceholderText = "e.g., Rainbow, Gold, Silver"
ManualVariantInput.Text = ""
ManualVariantInput.TextColor3 = THEME.Text
ManualVariantInput.Font = Enum.Font.Gotham
ManualVariantInput.TextSize = 12
ManualVariantInput.ClearTextOnFocus = false
ManualVariantInput.Parent = MagpieContainer

local ManualVariantCorner = Instance.new("UICorner")
ManualVariantCorner.CornerRadius = UDim.new(0, 6)
ManualVariantCorner.Parent = ManualVariantInput

-- Update selected variants when manual input changes
ManualVariantInput.FocusLost:Connect(function()
    if ManualVariantInput.Text ~= "" then
        local manualVariants = string.split(ManualVariantInput.Text, ",")
        for _, variantStr in ipairs(manualVariants) do
            local trimmed = variantStr:match("^%s*(.-)%s*$") -- Trim whitespace
            if trimmed and trimmed ~= "" and not table.find(MagpieSelectedVariants, trimmed) then
                table.insert(MagpieSelectedVariants, trimmed)
            end
        end
        notify("Manual variants added: " .. ManualVariantInput.Text, Color3.fromRGB(255, 215, 0))
    end
end)

-- Magpie Toggle
local MagpieToggleContainer = Instance.new("Frame")
MagpieToggleContainer.Size = UDim2.new(1, -20, 0, 40)
MagpieToggleContainer.BackgroundColor3 = THEME.Sidebar
MagpieToggleContainer.Parent = MagpieContainer

local MagpieToggleCorner = Instance.new("UICorner")
MagpieToggleCorner.CornerRadius = UDim.new(0, 6)
MagpieToggleCorner.Parent = MagpieToggleContainer

local MagpieToggleLabel = Instance.new("TextLabel")
MagpieToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
MagpieToggleLabel.BackgroundTransparency = 1
MagpieToggleLabel.Text = " Auto Collect Fruits"
MagpieToggleLabel.TextColor3 = THEME.Text
MagpieToggleLabel.Font = Enum.Font.GothamBold
MagpieToggleLabel.TextSize = 12
MagpieToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
MagpieToggleLabel.Parent = MagpieToggleContainer

local MagpieToggleButton = Instance.new("TextButton")
MagpieToggleButton.Size = UDim2.new(0, 50, 0, 25)
MagpieToggleButton.Position = UDim2.new(1, -55, 0.5, -12.5)
MagpieToggleButton.BackgroundColor3 = THEME.Red
MagpieToggleButton.Text = "OFF"
MagpieToggleButton.TextColor3 = Color3.new(1,1,1)
MagpieToggleButton.Font = Enum.Font.GothamBold
MagpieToggleButton.TextSize = 11
MagpieToggleButton.Parent = MagpieToggleContainer

local MagpieToggleBtnCorner = Instance.new("UICorner")
MagpieToggleBtnCorner.CornerRadius = UDim.new(0, 6)
MagpieToggleBtnCorner.Parent = MagpieToggleButton

-- Auto Sell Toggle
local MagpieSellToggleContainer = Instance.new("Frame")
MagpieSellToggleContainer.Size = UDim2.new(1, -20, 0, 40)
MagpieSellToggleContainer.BackgroundColor3 = THEME.Sidebar
MagpieSellToggleContainer.Parent = MagpieContainer

local MagpieSellToggleCorner = Instance.new("UICorner")
MagpieSellToggleCorner.CornerRadius = UDim.new(0, 6)
MagpieSellToggleCorner.Parent = MagpieSellToggleContainer

local MagpieSellToggleLabel = Instance.new("TextLabel")
MagpieSellToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
MagpieSellToggleLabel.BackgroundTransparency = 1
MagpieSellToggleLabel.Text = " Sell Inventory When Full"
MagpieSellToggleLabel.TextColor3 = THEME.Text
MagpieSellToggleLabel.Font = Enum.Font.GothamBold
MagpieSellToggleLabel.TextSize = 12
MagpieSellToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
MagpieSellToggleLabel.Parent = MagpieSellToggleContainer

local MagpieSellToggleButton = Instance.new("TextButton")
MagpieSellToggleButton.Size = UDim2.new(0, 50, 0, 25)
MagpieSellToggleButton.Position = UDim2.new(1, -55, 0.5, -12.5)
MagpieSellToggleButton.BackgroundColor3 = THEME.Red
MagpieSellToggleButton.Text = "OFF"
MagpieSellToggleButton.TextColor3 = Color3.new(1,1,1)
MagpieSellToggleButton.Font = Enum.Font.GothamBold
MagpieSellToggleButton.TextSize = 11
MagpieSellToggleButton.Parent = MagpieSellToggleContainer

local MagpieSellToggleBtnCorner = Instance.new("UICorner")
MagpieSellToggleBtnCorner.CornerRadius = UDim.new(0, 6)
MagpieSellToggleBtnCorner.Parent = MagpieSellToggleButton

local MagpieAutoSellEnabled = false
local autoSellConnection = nil

-- Auto Sell Toggle functionality
MagpieSellToggleButton.MouseButton1Click:Connect(function()
    MagpieAutoSellEnabled = not MagpieAutoSellEnabled
    
    if MagpieAutoSellEnabled then
        MagpieSellToggleButton.BackgroundColor3 = THEME.Green
        MagpieSellToggleButton.Text = "ON"
        notify("Auto Sell Enabled!", Color3.fromRGB(255, 215, 0))
        
        -- Auto Sell function
        local function autoSellInventory()
            pcall(function()
                game:GetService("ReplicatedStorage").GameEvents:WaitForChild("Sell_Inventory"):FireServer()
            end)
        end
        
        local function handleNotification(textLabel)
            if MagpieAutoSellEnabled and textLabel and textLabel:IsA("TextLabel") then
                local text = textLabel.Text
                if text:match("Max backpack space") then
                    autoSellInventory()
                end
            end
        end
        
        pcall(function()
            local notifUI = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Top_Notification"):WaitForChild("Frame"):WaitForChild("Notification_UI")
            
            autoSellConnection = notifUI.ChildAdded:Connect(function(child)
                if child:IsA("TextLabel") then
                    handleNotification(child)
                    child:GetPropertyChangedSignal("Text"):Connect(function()
                        handleNotification(child)
                    end)
                end
            end)
            
            for _, child in pairs(notifUI:GetChildren()) do
                if child:IsA("TextLabel") then
                    handleNotification(child)
                    child:GetPropertyChangedSignal("Text"):Connect(function()
                        handleNotification(child)
                    end)
                end
            end
        end)
    else
        MagpieSellToggleButton.BackgroundColor3 = THEME.Red
        MagpieSellToggleButton.Text = "OFF"
        notify("Auto Sell Disabled!", THEME.Red)
        
        if autoSellConnection then
            autoSellConnection:Disconnect()
            autoSellConnection = nil
        end
    end
end)

local MagpieAutoCollectEnabled = false

-- Magpie Toggle functionality
MagpieToggleButton.MouseButton1Click:Connect(function()
    MagpieAutoCollectEnabled = not MagpieAutoCollectEnabled
    
    if MagpieAutoCollectEnabled then
        MagpieToggleButton.BackgroundColor3 = THEME.Green
        MagpieToggleButton.Text = "ON"
        notify("Magpie Method Started!", Color3.fromRGB(255, 215, 0))
        
        task.spawn(function()
            while true do
                if not MagpieAutoCollectEnabled then
                    return
                end
                local Result1 = GetImportantDataFunc()
                local Important1 = Result1 and Result1:FindFirstChild("Important") and Result1.Important:FindFirstChild("Plants_Physical")
                if Important1 then
                    for _, Plant1 in ipairs(Important1:GetChildren()) do
                        local Fruits1 = Plant1:FindFirstChild("Fruits")
                        if Fruits1 then
                            for _, Orb3 in ipairs(Fruits1:GetChildren()) do
                                -- Check if fruit has any selected variant mutations or regular mutations
                                local hasSelectedVariant = false
                                
                                -- Check Variant folder for selected variants
                                local Variant1 = Orb3:FindFirstChild("Variant")
                                if Variant1 then
                                    -- Check if Variant folder itself has the variant name
                                    for _, targetVariant in ipairs(MagpieSelectedVariants) do
                                        if Variant1.Name:find(targetVariant) and not table.find(ExcludedVariants, targetVariant) then
                                            hasSelectedVariant = true
                                            break
                                        end
                                    end
                                    
                                    -- Also check descendants in Variant folder
                                    if not hasSelectedVariant then
                                        for _, variantDesc in ipairs(Variant1:GetDescendants()) do
                                            for _, targetVariant in ipairs(MagpieSelectedVariants) do
                                                if (variantDesc.Name:find(targetVariant) or variantDesc.Name == targetVariant) and not table.find(ExcludedVariants, targetVariant) then
                                                    hasSelectedVariant = true
                                                    break
                                                end
                                            end
                                            if hasSelectedVariant then break end
                                        end
                                    end
                                    
                                    -- Also check Variant folder children directly
                                    if not hasSelectedVariant then
                                        for _, variantChild in ipairs(Variant1:GetChildren()) do
                                            for _, targetVariant in ipairs(MagpieSelectedVariants) do
                                                if (variantChild.Name:find(targetVariant) or variantChild.Name == targetVariant) and not table.find(ExcludedVariants, targetVariant) then
                                                    hasSelectedVariant = true
                                                    break
                                                end
                                            end
                                            if hasSelectedVariant then break end
                                        end
                                    end
                                end
                                
                                -- If no variant found, check for regular mutations (Rainbow, Gold, Silver)
                                if not hasSelectedVariant then
                                    for _, descendant in ipairs(Orb3:GetDescendants()) do
                                        if descendant:IsA("Folder") or descendant:IsA("Model") then
                                            for _, targetVariant in ipairs(MagpieSelectedVariants) do
                                                if (descendant.Name:find(targetVariant) or descendant.Name == targetVariant) and not table.find(ExcludedVariants, targetVariant) then
                                                    hasSelectedVariant = true
                                                    break
                                                end
                                            end
                                            if hasSelectedVariant then break end
                                        end
                                    end
                                end
                                
                                -- Collect if has selected variant or mutation
                                if hasSelectedVariant then
                                    for _, UtilityObject in ipairs(Orb3:GetDescendants()) do
                                        if UtilityObject:IsA("ProximityPrompt") then
                                            local fruitPivot = Orb3.GetPivot and Orb3:GetPivot().Position or Orb3:GetModelCFrame().Position
                                            local charPivot = GetImportantDataFunc() and GetImportantDataFunc():GetPivot().Position
                                            if charPivot and (fruitPivot - charPivot).Magnitude < 150 then
                                                pcall(function()
                                                    fireproximityprompt(UtilityObject)
                                                    task.wait(0.01)
                                                end)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    else
        MagpieToggleButton.BackgroundColor3 = THEME.Red
        MagpieToggleButton.Text = "OFF"
        notify("Magpie Method Stopped!", THEME.Red)
    end
end)

-- Magpie Back Button functionality
MagpieBackBtn.MouseButton1Click:Connect(function()
    magpieExpanded = false
    TweenService:Create(MagpieContainer, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0)}):Play()
    task.wait(0.3)
    MagpieContainer.Visible = false
    notify("Magpie Method Closed", Color3.fromRGB(255, 215, 0))
end)

-- Magpie Method Button Toggle
MagpieMethodBtn.MouseButton1Click:Connect(function()
    magpieExpanded = not magpieExpanded
    if magpieExpanded then
        MutationContainer.Visible = false
        pantherExpanded = false
        MagpieContainer.Visible = true
        TweenService:Create(MagpieContainer, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 385)}):Play()
        notify("Magpie Method Activated!", Color3.fromRGB(255, 215, 0))
    else
        TweenService:Create(MagpieContainer, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0)}):Play()
        task.wait(0.3)
        MagpieContainer.Visible = false
    end
end)

-- PAGE: About
local AboutPage = Instance.new("Frame")
AboutPage.Size = UDim2.new(1, 0, 1, 0)
AboutPage.BackgroundTransparency = 1
AboutPage.Visible = false
AboutPage.Parent = Content

local AboutContainer = Instance.new("Frame")
AboutContainer.Size = UDim2.new(1, 0, 0, 150)
AboutContainer.BackgroundColor3 = THEME.Item
AboutContainer.Parent = AboutPage

local AboutCorner = Instance.new("UICorner")
AboutCorner.CornerRadius = UDim.new(0, 8)
AboutCorner.Parent = AboutContainer

local AboutText = Instance.new("TextLabel")
AboutText.Size = UDim2.new(1, -20, 1, -10)
AboutText.Position = UDim2.new(0, 10, 0, 5)
AboutText.BackgroundTransparency = 1
AboutText.Text = "XuanHub Remastered v1.2\n\nA modern Script Hub designed for Mobile & PC.\n• Internal Auto-Execute System\n• Advanced Script Editor with Search\n• Favorites & Recent Scripts (Double-Click)\n• Persistent Favorites Storage\n• Global & Local Script Search\n• Executor Info Display\n• Auto-Enabled Utilities (Anti-AFK, Auto Reconnect)\n• Custom Themes & Server Utilities\n\nI'm Xuan, Admin from Kaydens Server in Discord."
AboutText.TextColor3 = THEME.Text
AboutText.Font = Enum.Font.Gotham
AboutText.TextSize = 13
AboutText.TextWrapped = true
AboutText.TextXAlignment = Enum.TextXAlignment.Left
AboutText.TextYAlignment = Enum.TextYAlignment.Top
AboutText.Parent = AboutContainer







-- PAGE: Scripts
local ScriptsPage = Instance.new("Frame")
ScriptsPage.Size = UDim2.new(1, 0, 1, 0)
ScriptsPage.BackgroundTransparency = 1
ScriptsPage.Visible = false
ScriptsPage.Parent = Content

-- Script List (Left Side of Content)
local ListContainer = Instance.new("Frame")
ListContainer.Size = UDim2.new(0, 140, 1, 0) -- Narrower
ListContainer.BackgroundColor3 = THEME.Item
ListContainer.Parent = ScriptsPage

local ListCorner = Instance.new("UICorner")
ListCorner.CornerRadius = UDim.new(0, 8)
ListCorner.Parent = ListContainer

-- Refresh Button
local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(1, -10, 0, 25)
RefreshBtn.Position = UDim2.new(0, 5, 0, 5)
RefreshBtn.BackgroundColor3 = THEME.Sidebar
RefreshBtn.Text = "🔄 Refresh"
RefreshBtn.TextColor3 = THEME.Accent
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.TextSize = 11
RefreshBtn.Parent = ListContainer

local RefreshCorner = Instance.new("UICorner")
RefreshCorner.CornerRadius = UDim.new(0, 6)
RefreshCorner.Parent = RefreshBtn

-- Search Bar (in Scripts tab)
local SearchBar = Instance.new("TextBox")
SearchBar.Size = UDim2.new(1, -10, 0, 25)
SearchBar.Position = UDim2.new(0, 5, 0, 35)
SearchBar.BackgroundColor3 = THEME.Sidebar
SearchBar.TextColor3 = THEME.Text
SearchBar.Text = ""
SearchBar.PlaceholderText = "🔍 Search scripts..."
SearchBar.Font = Enum.Font.Gotham
SearchBar.TextSize = 11
SearchBar.ClearTextOnFocus = false
SearchBar.Parent = ListContainer

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 6)
SearchCorner.Parent = SearchBar

local ScriptList = Instance.new("ScrollingFrame")
ScriptList.Size = UDim2.new(1, -10, 1, -70)
ScriptList.Position = UDim2.new(0, 5, 0, 65)
ScriptList.BackgroundTransparency = 1
ScriptList.ScrollBarThickness = 2
ScriptList.AutomaticCanvasSize = Enum.AutomaticSize.Y -- Auto Scroll
ScriptList.CanvasSize = UDim2.new(0, 0, 0, 0)
ScriptList.Parent = ListContainer

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 5)
ListLayout.Parent = ScriptList

-- Editor Area (Right Side of Content)
local EditorContainer = Instance.new("Frame")
EditorContainer.Size = UDim2.new(1, -150, 1, 0) -- Adjusted
EditorContainer.Position = UDim2.new(0, 150, 0, 0) -- Adjusted
EditorContainer.BackgroundTransparency = 1
EditorContainer.Parent = ScriptsPage

local FileNameBox = Instance.new("TextBox")
FileNameBox.Size = UDim2.new(1, 0, 0, 30)
FileNameBox.Position = UDim2.new(0, 0, 0, 0)
FileNameBox.BackgroundColor3 = THEME.Item
FileNameBox.TextColor3 = THEME.Accent
FileNameBox.Font = Enum.Font.GothamBold
FileNameBox.TextSize = 14
FileNameBox.Text = "Script Name"
FileNameBox.ClearTextOnFocus = false
FileNameBox.Parent = EditorContainer

local FileCorner = Instance.new("UICorner")
FileCorner.CornerRadius = UDim.new(0, 6)
FileCorner.Parent = FileNameBox

local ScriptEditor = Instance.new("TextBox")
ScriptEditor.Size = UDim2.new(1, 0, 1, -80) -- Adjusted
ScriptEditor.Position = UDim2.new(0, 0, 0, 35)
ScriptEditor.BackgroundColor3 = THEME.Item
ScriptEditor.TextColor3 = THEME.Text
ScriptEditor.Font = Enum.Font.Code
ScriptEditor.TextSize = 13
ScriptEditor.TextXAlignment = Enum.TextXAlignment.Left
ScriptEditor.TextYAlignment = Enum.TextYAlignment.Top
ScriptEditor.ClearTextOnFocus = false
ScriptEditor.MultiLine = true
ScriptEditor.TextWrapped = true -- Fix overflow
ScriptEditor.Text = "-- Select a script to edit"
ScriptEditor.Parent = EditorContainer

local EditorPadding = Instance.new("UIPadding")
EditorPadding.PaddingLeft = UDim.new(0, 8)
EditorPadding.PaddingRight = UDim.new(0, 8)
EditorPadding.PaddingTop = UDim.new(0, 8)
EditorPadding.PaddingBottom = UDim.new(0, 8)
EditorPadding.Parent = ScriptEditor

local EditorCorner = Instance.new("UICorner")
EditorCorner.CornerRadius = UDim.new(0, 8)
EditorCorner.Parent = ScriptEditor

-- Controls (Bottom of Editor)
local Controls = Instance.new("Frame")
Controls.Size = UDim2.new(1, 0, 0, 40) -- Slightly taller
Controls.Position = UDim2.new(0, 0, 1, -40)
Controls.BackgroundTransparency = 1
Controls.Parent = EditorContainer

local CurrentScriptFile = nil

local function createControlBtn(text, color, posScale, callback)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Size = UDim2.new(0.19, 0, 0, 30) -- Smaller width for 5 buttons
    btn.Position = UDim2.new(posScale, 0, 0.5, -15)
    btn.Parent = Controls
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Buttons: Run, Save, Rename, New, Delete
createControlBtn("▶", THEME.Green, 0, function()
    if ScriptEditor.Text ~= "" then
        loadstring(ScriptEditor.Text)()
        notify("Run Successful!", THEME.Green)
    end
end)

createControlBtn("💾", THEME.Accent, 0.20, function()
    if CurrentScriptFile then
        local newName = FileNameBox.Text
        if newName ~= "Script Name" and newName ~= "" then
            -- Add file extension if missing
            if not newName:match("%.txt$") and not newName:match("%.lua$") then 
                newName = newName .. ".txt" 
            end
            
            -- If name changed, rename the file
            if newName ~= CurrentScriptFile then
                writefile(SCRIPTS_DIR .. "/" .. newName, ScriptEditor.Text)
                delfile(SCRIPTS_DIR .. "/" .. CurrentScriptFile)
                CurrentScriptFile = newName
                FileNameBox.Text = newName
                addToRecent(newName)
                refreshScripts("")
                notify("Saved & Renamed to: " .. newName, THEME.Accent)
            else
                -- Just save content
                writefile(SCRIPTS_DIR .. "/" .. CurrentScriptFile, ScriptEditor.Text)
                addToRecent(CurrentScriptFile)
                notify("Saved Successfully!", THEME.Accent)
            end
        else
            writefile(SCRIPTS_DIR .. "/" .. CurrentScriptFile, ScriptEditor.Text)
            addToRecent(CurrentScriptFile)
            notify("Saved Successfully!", THEME.Accent)
        end
    end
end)

createControlBtn("✏️", THEME.Sidebar, 0.40, function()
    if CurrentScriptFile and FileNameBox.Text ~= "" and FileNameBox.Text ~= "Script Name" then
        local newName = FileNameBox.Text
        if not newName:match("%.txt$") and not newName:match("%.lua$") then 
            newName = newName .. ".txt" 
        end
        
        if newName ~= CurrentScriptFile then
            writefile(SCRIPTS_DIR .. "/" .. newName, ScriptEditor.Text)
            delfile(SCRIPTS_DIR .. "/" .. CurrentScriptFile)
            CurrentScriptFile = newName
            FileNameBox.Text = newName
            refreshScripts()
            notify("Renamed to: " .. newName, THEME.Sidebar)
        end
    else
        notify("Enter a valid file name!", THEME.Red)
    end
end)

createControlBtn("📄", THEME.Sidebar, 0.60, function()
    CurrentScriptFile = nil
    ScriptEditor.Text = ""
    local name = "Script_" .. math.random(1000) .. ".txt"
    CurrentScriptFile = name
    FileNameBox.Text = name
    writefile(SCRIPTS_DIR .. "/" .. name, "")
    refreshScripts()
    notify("New File Created!", THEME.Sidebar)
end)

createControlBtn("🗑", THEME.Red, 0.80, function()
    if CurrentScriptFile then
        delfile(SCRIPTS_DIR .. "/" .. CurrentScriptFile)
        CurrentScriptFile = nil
        ScriptEditor.Text = ""
        FileNameBox.Text = "Script Name"
        refreshScripts()
        notify("Deleted Successfully!", THEME.Red)
    end
end)

-- Favorites Tracking
local FavoriteScripts = {}
local lastClickTime = {}
local DOUBLE_CLICK_TIME = 0.5 -- seconds

local function saveFavorites()
    local favString = table.concat(FavoriteScripts, "\n")
    writefile(FAVORITES_FILE, favString)
end

local function loadFavorites()
    if isfile(FAVORITES_FILE) then
        local content = readfile(FAVORITES_FILE)
        FavoriteScripts = {}
        for line in content:gmatch("[^\n]+") do
            if line ~= "" then
                table.insert(FavoriteScripts, line)
            end
        end
    end
end

local function toggleFavorite(fileName)
    -- Check if already favorited
    for i, name in ipairs(FavoriteScripts) do
        if name == fileName then
            table.remove(FavoriteScripts, i)
            saveFavorites()
            notify("Removed from Favorites", THEME.Red)
            return
        end
    end
    
    -- Add to favorites
    table.insert(FavoriteScripts, 1, fileName)
    saveFavorites()
    notify("Added to Favorites! ⭐", THEME.Accent)
end

-- Recent Scripts Tracking
local RecentScripts = {}
local MAX_RECENT = 5

local function addToRecent(fileName)
    -- Remove if already exists
    for i, name in ipairs(RecentScripts) do
        if name == fileName then
            table.remove(RecentScripts, i)
            break
        end
    end
    
    -- Add to front
    table.insert(RecentScripts, 1, fileName)
    
    -- Keep only max items
    while #RecentScripts > MAX_RECENT do
        table.remove(RecentScripts)
    end
end

function refreshScripts(searchQuery)
    for _, v in pairs(ScriptList:GetChildren()) do
        if v:IsA("TextButton") or v:IsA("TextLabel") then v:Destroy() end
    end
    
    searchQuery = searchQuery or ""
    local lowerQuery = searchQuery:lower()
    
    local files = listfiles(SCRIPTS_DIR)
    local displayCount = 0
    
    -- Show Favorites section if no search
    if searchQuery == "" and #FavoriteScripts > 0 then
        local favLabel = Instance.new("TextLabel")
        favLabel.Size = UDim2.new(1, 0, 0, 20)
        favLabel.BackgroundTransparency = 1
        favLabel.Text = "⭐ Favorites"
        favLabel.TextColor3 = THEME.Accent
        favLabel.Font = Enum.Font.GothamBold
        favLabel.TextSize = 10
        favLabel.TextXAlignment = Enum.TextXAlignment.Left
        favLabel.Parent = ScriptList
        displayCount = displayCount + 1
        
        for _, favName in ipairs(FavoriteScripts) do
            local fullPath = SCRIPTS_DIR .. "/" .. favName
            if isfile(fullPath) then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 0, 30)
                btn.BackgroundColor3 = THEME.Accent
                btn.Text = "⭐ " .. favName
                btn.TextColor3 = THEME.Text
                btn.Font = Enum.Font.GothamBold
                btn.TextSize = 11
                btn.Parent = ScriptList
                
                local c = Instance.new("UICorner")
                c.CornerRadius = UDim.new(0, 4)
                c.Parent = btn
                
                btn.MouseButton1Click:Connect(function()
                    local currentTime = tick()
                    local lastClick = lastClickTime[favName] or 0
                    
                    if currentTime - lastClick < DOUBLE_CLICK_TIME then
                        -- Double click - remove from favorites
                        toggleFavorite(favName)
                        refreshScripts(searchQuery)
                    else
                        -- Single click - open file
                        CurrentScriptFile = favName
                        FileNameBox.Text = favName
                        ScriptEditor.Text = readfile(fullPath)
                        addToRecent(favName)
                        for _, b in pairs(ScriptList:GetChildren()) do
                            if b:IsA("TextButton") then 
                                b.BackgroundColor3 = THEME.Sidebar 
                            end
                        end
                        btn.BackgroundColor3 = THEME.Accent
                    end
                    
                    lastClickTime[favName] = currentTime
                end)
                displayCount = displayCount + 1
            end
        end
    end
    
    -- Show Recent Scripts section if no search
    if searchQuery == "" and #RecentScripts > 0 then
        local recentLabel = Instance.new("TextLabel")
        recentLabel.Size = UDim2.new(1, 0, 0, 20)
        recentLabel.BackgroundTransparency = 1
        recentLabel.Text = "Recent"
        recentLabel.TextColor3 = THEME.SubText
        recentLabel.Font = Enum.Font.GothamBold
        recentLabel.TextSize = 10
        recentLabel.TextXAlignment = Enum.TextXAlignment.Left
        recentLabel.Parent = ScriptList
        displayCount = displayCount + 1
        
        for _, recentName in ipairs(RecentScripts) do
            local fullPath = SCRIPTS_DIR .. "/" .. recentName
            if isfile(fullPath) then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 0, 30)
                btn.BackgroundColor3 = THEME.Sidebar
                btn.Text = "⭐ " .. recentName
                btn.TextColor3 = THEME.Accent
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 11
                btn.Parent = ScriptList
                
                local c = Instance.new("UICorner")
                c.CornerRadius = UDim.new(0, 4)
                c.Parent = btn
                
                btn.MouseButton1Click:Connect(function()
                    local currentTime = tick()
                    local lastClick = lastClickTime[recentName] or 0
                    
                    if currentTime - lastClick < DOUBLE_CLICK_TIME then
                        -- Double click - add to favorites
                        toggleFavorite(recentName)
                        refreshScripts(searchQuery)
                    else
                        -- Single click - open file
                        CurrentScriptFile = recentName
                        FileNameBox.Text = recentName
                        ScriptEditor.Text = readfile(fullPath)
                        addToRecent(recentName)
                        for _, b in pairs(ScriptList:GetChildren()) do
                            if b:IsA("TextButton") then b.BackgroundColor3 = THEME.Sidebar end
                        end
                        btn.BackgroundColor3 = THEME.Accent
                    end
                    
                    lastClickTime[recentName] = currentTime
                end)
                displayCount = displayCount + 1
            end
        end
        
        -- All Scripts section
        local allLabel = Instance.new("TextLabel")
        allLabel.Size = UDim2.new(1, 0, 0, 20)
        allLabel.BackgroundTransparency = 1
        allLabel.Text = "All Scripts"
        allLabel.TextColor3 = THEME.SubText
        allLabel.Font = Enum.Font.GothamBold
        allLabel.TextSize = 10
        allLabel.TextXAlignment = Enum.TextXAlignment.Left
        allLabel.Parent = ScriptList
        displayCount = displayCount + 1
    end
    
    for _, file in pairs(files) do
        local name = file:match("([^/]+)$")
        
        -- Filter by search query
        if searchQuery == "" or name:lower():find(lowerQuery, 1, true) then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.BackgroundColor3 = THEME.Sidebar
            btn.Text = name
            btn.TextColor3 = THEME.Text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 12
            btn.Parent = ScriptList
            
            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 4)
            c.Parent = btn
            
            btn.MouseButton1Click:Connect(function()
                local currentTime = tick()
                local lastClick = lastClickTime[name] or 0
                
                if currentTime - lastClick < DOUBLE_CLICK_TIME then
                    -- Double click - add to favorites
                    toggleFavorite(name)
                    refreshScripts(searchQuery)
                else
                    -- Single click - open file
                    CurrentScriptFile = name
                    FileNameBox.Text = name
                    ScriptEditor.Text = readfile(file)
                    addToRecent(name)
                    -- Highlight selection
                    for _, b in pairs(ScriptList:GetChildren()) do
                        if b:IsA("TextButton") then b.BackgroundColor3 = THEME.Sidebar end
                    end
                    btn.BackgroundColor3 = THEME.Accent
                end
                
                lastClickTime[name] = currentTime
            end)
            displayCount = displayCount + 1
        end
    end
    ScriptList.CanvasSize = UDim2.new(0, 0, 0, displayCount * 35)
end

-- Register Tabs
tabs["AutoExec"] = { Button = createTabButton("AutoExec", 0), Page = AutoExecPage }
tabs["Scripts"] = { Button = createTabButton("Scripts", 1), Page = ScriptsPage }
tabs["GrowGarden"] = { Button = createTabButton("Grow Garden", 2), Page = GrowGardenPage }
tabs["Settings"] = { Button = createTabButton("Settings", 3), Page = SettingsPage }
tabs["About"] = { Button = createTabButton("About", 4), Page = AboutPage }

-- Button Events
tabs["AutoExec"].Button.MouseButton1Click:Connect(function() 
    switchTab("AutoExec") 
    refreshAutoExec()
end)
tabs["Scripts"].Button.MouseButton1Click:Connect(function() 
    switchTab("Scripts") 
    refreshScripts()
end)
tabs["GrowGarden"].Button.MouseButton1Click:Connect(function() switchTab("GrowGarden") end)
tabs["Settings"].Button.MouseButton1Click:Connect(function() switchTab("Settings") end)
tabs["About"].Button.MouseButton1Click:Connect(function() switchTab("About") end)

-- Refresh Button Event
RefreshBtn.MouseButton1Click:Connect(function()
    SearchBar.Text = ""
    refreshScripts("")
    notify("Scripts Refreshed!", THEME.Accent)
end)

-- Search Bar Event (Scripts tab)
SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
    refreshScripts(SearchBar.Text)
end)

-- Global Search Bar Event (Header)
GlobalSearchBar:GetPropertyChangedSignal("Text"):Connect(function()
    local query = GlobalSearchBar.Text
    if query ~= "" then
        switchTab("Scripts")
        SearchBar.Text = query
        refreshScripts(query)
    end
end)

-- Init
task.wait()
loadFavorites()
refreshAutoExec()
switchTab("AutoExec")
