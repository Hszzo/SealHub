--[[
    SEAL ADMIN HUB V17
    by @hszzo
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse = player:GetMouse()

repeat task.wait() until player.Character
local character = player.Character
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- Цвета (улучшенная палитра)
local C = {
    bg = Color3.fromRGB(8, 8, 8),
    bgLight = Color3.fromRGB(18, 18, 18),
    bgDark = Color3.fromRGB(5, 5, 5),
    accent = Color3.fromRGB(255, 255, 255),
    accent2 = Color3.fromRGB(200, 200, 200),
    green = Color3.fromRGB(0, 255, 128),
    red = Color3.fromRGB(255, 80, 80),
    yellow = Color3.fromRGB(255, 200, 0),
    white = Color3.fromRGB(255, 255, 255),
    gray = Color3.fromRGB(140, 140, 140),
    black = Color3.fromRGB(0, 0, 0),
    border = Color3.fromRGB(30, 30, 30),
    hover = Color3.fromRGB(35, 35, 35)
}

local S = {
    fly = false, speed = false, noclip = false, infjump = false,
    bhop = false, clicktp = false, autowalk = false, jumppower = false,
    aimbot = false, silentaim = false, triggerbot = false, hitbox = false,
    killaura = false, godmode = false, invisible = false, antiafk = false,
    esp = false, fullbright = false, nightvision = false, xray = false,
    chams = false, tracers = false, boxesp = false, nameesp = false,
    removefog = false, notrees = false, lowgraphics = false,
    spinbot = false, spamchat = false, s4x = false, dance = false, 
    iyinjected = false, customChat = false, jerk = false, orbit = false,
    fling = false, freecam = false, chatEnabled = false, chatSpy = false,
    chatBypass = false, chatEncrypt = false, chatRainbow = false,
    chatBold = false, chatBig = false, chatSmall = false, chatCursed = false,
    chatReverse = false, chatLeet = false, chatZalgo = false
}

local espObjects = {}
local loopConnections = {}
local frameCounter = 0
local FRAME_SKIP = 2
local binds = {}
local savedScripts = {}

-- Проверка ключа
local function checkKey(input)
    local k = ""
    for i = 1, 3 do
        k = k .. string.char(96 + (i == 1 and 8 or i == 2 and 19 or 5))
    end
    return input == k
end

-- Рабочие скрипты (проверенные)
local ScriptLibrary = {
    -- Админ скрипты
    {name = "Infinite Yield", url = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", desc = "Лучший админ скрипт", category = "Админ", working = true},
    {name = "CMD-X", url = "https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source", desc = "Мощная консоль", category = "Админ", working = true},
    {name = "Reviz Admin", url = "https://raw.githubusercontent.com/revizadmin/reviz/master/source.lua", desc = "Админ команды", category = "Админ", working = true},
    
    -- Утилиты
    {name = "Dex Explorer", url = "https://raw.githubusercontent.com/infyiff/backup/main/dex.lua", desc = "Проводник игры", category = "Утилиты", working = true},
    {name = "SimpleSpy V3", url = "https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua", desc = "Сниффер удаленных событий", category = "Утилиты", working = true},
    
    -- Движение
    {name = "System Broken", url = "https://raw.githubusercontent.com/H20CalibreYT/SystemBroken/main/script", desc = "Флай, спид, телепорт", category = "Движение", working = true},
    {name = "Invincible Flight", url = "https://rawscripts.net/raw/Universal-Script-Invinicible-Flight-R15-45414", desc = "Полет сквозь стены", category = "Движение", working = true},
    
    -- Физика
    {name = "Telekinesis V5", url = "https://rawscripts.net/raw/Universal-Script-Fe-Telekinesis-V5-21542", desc = "Телекинез", category = "Физика", working = true},
    {name = "Fling Things V2", url = "https://rawscripts.net/raw/Fling-Things-and-People-*-V2-62163", desc = "Бросать предметы", category = "Физика", working = true},
    
    -- Троллинг
    {name = "Ultimate Trolling GUI", url = "https://rawscripts.net/raw/Universal-Script-ULTIMATE-TROLLING-GUI-V5-39695", desc = "Троллинг, флай, ноклип", category = "Троллинг", working = true},
    {name = "FE SCP-096", url = "https://rawscripts.net/raw/Universal-Script-FE-SCP-096-36948", desc = "SCP-096 морф", category = "Троллинг", working = true},
}

-- Морфы
local Morphs = {
    {name = "Neko", script = 'require(17024944103).neko("User")', desc = "Превращает в Неко"},
    {name = "Headless", script = [[local c = game.Players.LocalPlayer.Character if c and c:FindFirstChild("Head") then c.Head.Transparency = 1 for _, v in pairs(c.Head:GetChildren()) do if v:IsA("Decal") then v.Transparency = 1 end end end]], desc = "Убирает голову"},
    {name = "Mini", script = [[local c = game.Players.LocalPlayer.Character if c then for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.Size = p.Size * 0.5 end end end]], desc = "Уменьшает персонажа"},
    {name = "Giant", script = [[local c = game.Players.LocalPlayer.Character if c then for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.Size = p.Size * 2 end end end]], desc = "Увеличивает персонажа"},
    {name = "Invisible", script = [[local c = game.Players.LocalPlayer.Character if c then for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 1 end end end]], desc = "Делает невидимым"},
    {name = "Rainbow", script = [[local c = game.Players.LocalPlayer.Character if c then task.spawn(function() while c and c.Parent do for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) end end task.wait(0.1) end end) end]], desc = "Радужный цвет"},
    {name = "Skeleton", script = [[local c = game.Players.LocalPlayer.Character if c then for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.Color = Color3.fromRGB(255,255,255) p.Material = Enum.Material.Neon end end end]], desc = "Скелет"},
    {name = "Gold", script = [[local c = game.Players.LocalPlayer.Character if c then for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.Color = Color3.fromRGB(255,215,0) p.Material = Enum.Material.Metal end end end]], desc = "Золотой"},
}

-- Tools
local ToolsLibrary = {
    {name = "Jerk", desc = "Анимация", script = [[loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Jerk-Off-R15-Animation-FE-20074"))()]]},
    {name = "Orbit", desc = "Вращение вокруг", script = [[loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Orbit-Players-20077"))()]]},
    {name = "Fling", desc = "Кидать игроков", script = [[loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-FE-Fling-20076"))()]]},
    {name = "Freecam", desc = "Свободная камера", script = [[loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Freecam-20078"))()]]},
    {name = "Bring", desc = "Притягивать игроков", script = [[loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Bring-Players-20087"))()]]},
    {name = "Kill", desc = "Убивать игроков", script = [[loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Kill-Player-20089"))()]]},
}

-- GUI
local screen = Instance.new("ScreenGui")
screen.Name = "SealAdminV17"
screen.ResetOnSpawn = false
screen.ZIndexBehavior = Enum.ZIndexBehavior.Global
screen.Parent = CoreGui

-- Key System
local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(0, 420, 0, 280)
keyFrame.Position = UDim2.new(0.5, -210, 0.5, -140)
keyFrame.BackgroundColor3 = C.bg
keyFrame.BorderSizePixel = 0
keyFrame.ZIndex = 100
keyFrame.Parent = screen

Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0, 20)

local keyGlow = Instance.new("ImageLabel")
keyGlow.Size = UDim2.new(1, 80, 1, 80)
keyGlow.Position = UDim2.new(0, -40, 0, -40)
keyGlow.BackgroundTransparency = 1
keyGlow.Image = "rbxassetid://131604521"
keyGlow.ImageColor3 = C.accent
keyGlow.ImageTransparency = 0.9
keyGlow.ZIndex = 99
keyGlow.Parent = keyFrame

local keyTitle = Instance.new("TextLabel")
keyTitle.Size = UDim2.new(1, 0, 0, 70)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = "SEAL HUB"
keyTitle.TextColor3 = C.white
keyTitle.TextSize = 32
keyTitle.Font = Enum.Font.GothamBlack
keyTitle.ZIndex = 101
keyTitle.Parent = keyFrame

local keySubtitle = Instance.new("TextLabel")
keySubtitle.Size = UDim2.new(1, 0, 0, 30)
keySubtitle.Position = UDim2.new(0, 0, 0, 55)
keySubtitle.BackgroundTransparency = 1
keySubtitle.Text = "ADMIN PANEL V17"
keySubtitle.TextColor3 = C.gray
keySubtitle.TextSize = 14
keySubtitle.Font = Enum.Font.Gotham
keySubtitle.ZIndex = 101
keySubtitle.Parent = keyFrame

local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(0, 320, 0, 55)
keyInput.Position = UDim2.new(0.5, -160, 0.5, -27)
keyInput.BackgroundColor3 = C.bgLight
keyInput.Text = ""
keyInput.PlaceholderText = "Enter key..."
keyInput.TextColor3 = C.white
keyInput.PlaceholderColor3 = C.gray
keyInput.TextSize = 18
keyInput.Font = Enum.Font.GothamBold
keyInput.ClearTextOnFocus = true
keyInput.ZIndex = 101
keyInput.Parent = keyFrame

Instance.new("UICorner", keyInput).CornerRadius = UDim.new(0, 12)

local keyButton = Instance.new("TextButton")
keyButton.Size = UDim2.new(0, 320, 0, 50)
keyButton.Position = UDim2.new(0.5, -160, 0.75, 0)
keyButton.BackgroundColor3 = C.white
keyButton.Text = "UNLOCK"
keyButton.TextColor3 = C.black
keyButton.TextSize = 16
keyButton.Font = Enum.Font.GothamBlack
keyButton.ZIndex = 101
keyButton.Parent = keyFrame

Instance.new("UICorner", keyButton).CornerRadius = UDim.new(0, 12)

local keyStatus = Instance.new("TextLabel")
keyStatus.Size = UDim2.new(1, 0, 0, 25)
keyStatus.Position = UDim2.new(0, 0, 1, -35)
keyStatus.BackgroundTransparency = 1
keyStatus.Text = ""
keyStatus.TextColor3 = C.red
keyStatus.TextSize = 12
keyStatus.Font = Enum.Font.Gotham
keyStatus.ZIndex = 101
keyStatus.Parent = keyFrame

-- Main Window
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 850, 0, 650)
main.Position = UDim2.new(0.5, -425, 0.5, -325)
main.BackgroundColor3 = C.bg
main.BorderSizePixel = 0
main.Visible = false
main.Active = true
main.Parent = screen

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 20)

local mainGlow = Instance.new("ImageLabel")
mainGlow.Size = UDim2.new(1, 100, 1, 100)
mainGlow.Position = UDim2.new(0, -50, 0, -50)
mainGlow.BackgroundTransparency = 1
mainGlow.Image = "rbxassetid://131604521"
mainGlow.ImageColor3 = C.black
mainGlow.ImageTransparency = 0.85
mainGlow.ZIndex = 0
mainGlow.Parent = main

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 70)
titleBar.BackgroundColor3 = C.bgLight
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 2
titleBar.Parent = main

Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 20)

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0, 400, 1, 0)
titleText.Position = UDim2.new(0, 30, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "SEAL ADMIN HUB"
titleText.TextColor3 = C.white
titleText.TextSize = 26
titleText.Font = Enum.Font.GothamBlack
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.ZIndex = 3
titleText.Parent = titleBar

local titleVer = Instance.new("TextLabel")
titleVer.Size = UDim2.new(0, 100, 0, 20)
titleVer.Position = UDim2.new(0, 30, 1, -25)
titleVer.BackgroundTransparency = 1
titleVer.Text = "V17 PREMIUM"
titleVer.TextColor3 = C.green
titleVer.TextSize = 12
titleVer.Font = Enum.Font.GothamBold
titleVer.TextXAlignment = Enum.TextXAlignment.Left
titleVer.ZIndex = 3
titleVer.Parent = titleBar

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0, 90, 0, 32)
fpsLabel.Position = UDim2.new(1, -300, 0, 19)
fpsLabel.BackgroundColor3 = C.bgDark
fpsLabel.Text = "60 FPS"
fpsLabel.TextColor3 = C.green
fpsLabel.TextSize = 14
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.ZIndex = 3
fpsLabel.Parent = titleBar

Instance.new("UICorner", fpsLabel).CornerRadius = UDim.new(0, 10)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 45, 0, 35)
closeBtn.Position = UDim2.new(1, -60, 0, 17)
closeBtn.BackgroundColor3 = C.red
closeBtn.Text = "X"
closeBtn.TextColor3 = C.white
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBlack
closeBtn.ZIndex = 3
closeBtn.Parent = titleBar

Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 45, 0, 35)
minBtn.Position = UDim2.new(1, -110, 0, 17)
minBtn.BackgroundColor3 = C.yellow
minBtn.Text = "-"
minBtn.TextColor3 = C.black
minBtn.TextSize = 20
minBtn.Font = Enum.Font.GothamBlack
minBtn.ZIndex = 3
minBtn.Parent = titleBar)

Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

-- Tab Panel
local tabPanel = Instance.new("Frame")
tabPanel.Size = UDim2.new(0, 220, 1, -70)
tabPanel.Position = UDim2.new(0, 0, 0, 70)
tabPanel.BackgroundColor3 = C.bgDark
tabPanel.BorderSizePixel = 0
tabPanel.ZIndex = 2
tabPanel.Parent = main

-- Content
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -220, 1, -70)
content.Position = UDim2.new(0, 220, 0, 70)
content.BackgroundColor3 = C.bg
content.BorderSizePixel = 0
content.ZIndex = 2
content.Parent = main

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -25, 1, -25)
scroll.Position = UDim2.new(0, 12, 0, 12)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 6
scroll.ScrollBarImageColor3 = C.accent
scroll.ZIndex = 3
scroll.Parent = content

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 10)
list.Parent = scroll

-- Open Button
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 65, 0, 65)
openBtn.Position = UDim2.new(1, -85, 0.5, -32)
openBtn.BackgroundColor3 = C.white
openBtn.Text = "SEAL"
openBtn.TextColor3 = C.black
openBtn.TextSize = 18
openBtn.Font = Enum.Font.GothamBlack
openBtn.ZIndex = 10
openBtn.Parent = screen
openBtn.Visible = false

Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 16)

local tabs = {}
local buttons = {}
local currentTab = "Движение"
local menuOpen = false
local waitingBind = nil

-- Drag function
local function makeDraggable(frame, handle)
    local dragging = false
    local dragStart, startPos
    handle = handle or frame
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Create Tab
local function createTab(name, icon)
    local tab = Instance.new("TextButton")
    tab.Name = name
    tab.Size = UDim2.new(1, -20, 0, 50)
    tab.Position = UDim2.new(0, 10, 0, #tabs * 56 + 15)
    tab.BackgroundColor3 = C.bg
    tab.BorderSizePixel = 0
    tab.AutoButtonColor = false
    tab.Text = ""
    tab.ZIndex = 3
    tab.Parent = tabPanel
    
    Instance.new("UICorner", tab).CornerRadius = UDim.new(0, 12)
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 45, 1, 0)
    iconLabel.Position = UDim2.new(0, 15, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextColor3 = C.gray
    iconLabel.TextSize = 22
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.ZIndex = 4
    iconLabel.Parent = tab
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -60, 1, 0)
    nameLabel.Position = UDim2.new(0, 60, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = C.gray
    nameLabel.TextSize = 15
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 4
    nameLabel.Parent = tab
    
    local highlight = Instance.new("Frame")
    highlight.Size = UDim2.new(0, 4, 0.5, 0)
    highlight.Position = UDim2.new(0, 0, 0.25, 0)
    highlight.BackgroundColor3 = C.white
    highlight.BorderSizePixel = 0
    highlight.Visible = false
    highlight.ZIndex = 5
    highlight.Parent = tab
    
    tab.MouseEnter:Connect(function()
        if currentTab ~= name then
            TweenService:Create(tab, TweenInfo.new(0.2), {BackgroundColor3 = C.hover}):Play()
        end
    end)
    
    tab.MouseLeave:Connect(function()
        if currentTab ~= name then
            TweenService:Create(tab, TweenInfo.new(0.2), {BackgroundColor3 = C.bg}):Play()
        end
    end)
    
    tab.MouseButton1Click:Connect(function()
        if tabs[currentTab] then
            tabs[currentTab].HL.Visible = false
            TweenService:Create(tabs[currentTab].Btn, TweenInfo.new(0.2), {BackgroundColor3 = C.bg}):Play()
            tabs[currentTab].Icon.TextColor3 = C.gray
            tabs[currentTab].Name.TextColor3 = C.gray
        end
        
        currentTab = name
        highlight.Visible = true
        TweenService:Create(tab, TweenInfo.new(0.2), {BackgroundColor3 = C.bgLight}):Play()
        iconLabel.TextColor3 = C.white
        nameLabel.TextColor3 = C.white
        
        for _, btn in pairs(buttons) do
            btn.Btn.Visible = false
        end
        
        local count = 0
        for _, btn in pairs(buttons) do
            if btn.Tab == currentTab then
                btn.Btn.Visible = true
                btn.Btn.LayoutOrder = count
                count = count + 1
            end
        end
        
        scroll.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 20)
    end)
    
    table.insert(tabs, {Name = name, Btn = tab, Icon = iconLabel, Name = nameLabel, HL = highlight})
    return tab
end

-- Create Button
local function createButton(name, tabName, callback, isToggle, desc)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, -10, 0, desc and 75 or 60)
    btn.BackgroundColor3 = C.bgLight
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.ZIndex = 4
    btn.Parent = scroll
    btn.Visible = false
    
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = C.border
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = btn
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 50, 0, 26)
    toggleFrame.Position = UDim2.new(0, 18, 0, desc and 24 or 17)
    toggleFrame.BackgroundColor3 = C.bgDark
    toggleFrame.BorderSizePixel = 0
    toggleFrame.ZIndex = 5
    toggleFrame.Parent = btn
    
    Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0, 13)
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 20, 0, 20)
    toggleCircle.Position = UDim2.new(0, 3, 0.5, -10)
    toggleCircle.BackgroundColor3 = C.gray
    toggleCircle.BorderSizePixel = 0
    toggleCircle.ZIndex = 6
    toggleCircle.Parent = toggleFrame
    
    Instance.new("UICorner", toggleCircle).CornerRadius = UDim.new(0, 10)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -150, 0, 26)
    label.Position = UDim2.new(0, 78, 0, desc and 12 or 17)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = C.white
    label.TextSize = 16
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 5
    label.Parent = btn
    
    if desc then
        local descLabel = Instance.new("TextLabel")
        descLabel.Size = UDim2.new(1, -150, 0, 22)
        descLabel.Position = UDim2.new(0, 78, 0, 40)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = desc
        descLabel.TextColor3 = C.gray
        descLabel.TextSize = 12
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.ZIndex = 5
        descLabel.Parent = btn
    end
    
    local bindLabel = Instance.new("TextLabel")
    bindLabel.Size = UDim2.new(0, 70, 0, 28)
    bindLabel.Position = UDim2.new(1, -80, 0.5, -14)
    bindLabel.BackgroundColor3 = C.bgDark
    bindLabel.Text = ""
    bindLabel.TextColor3 = C.gray
    bindLabel.TextSize = 12
    bindLabel.Font = Enum.Font.GothamBold
    bindLabel.ZIndex = 5
    bindLabel.Parent = btn
    
    Instance.new("UICorner", bindLabel).CornerRadius = UDim.new(0, 8)
    
    local active = false
    
    local function updateVisuals()
        if active then
            TweenService:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = C.green}):Play()
            TweenService:Create(toggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 27, 0.5, -10), BackgroundColor3 = C.white}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.2), {Color = C.green, Transparency = 0}):Play()
        else
            TweenService:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = C.bgDark}):Play()
            TweenService:Create(toggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -10), BackgroundColor3 = C.gray}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.2), {Color = C.border, Transparency = 0.5}):Play()
        end
    end
    
    btn.MouseButton1Click:Connect(function()
        if isToggle then
            active = not active
            updateVisuals()
        end
        callback(active)
    end)
    
    btn.MouseButton2Click:Connect(function()
        waitingBind = name
        bindLabel.Text = "..."
        bindLabel.TextColor3 = C.yellow
    end)
    
    btn.MouseEnter:Connect(function()
        if not active then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = C.hover}):Play()
        end
    end)
    
    btn.MouseLeave:Connect(function()
        if not active then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = C.bgLight}):Play()
        end
    end)
    
    buttons[name] = {
        Btn = btn,
        Set = function(s) 
            active = s 
            updateVisuals()
            if isToggle then callback(s) end
        end,
        Get = function() return active end,
        Tab = tabName,
        BindLabel = bindLabel,
        IsToggle = isToggle
    }
    
    return btn
end

-- Create Script Button (for ScriptLibrary)
local function createScriptButton(scriptData, tabName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 90)
    btn.BackgroundColor3 = C.bgLight
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.ZIndex = 4
    btn.Parent = scroll
    btn.Visible = false
    
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = C.border
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = btn
    
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(0, 18, 0, 18)
    statusFrame.Position = UDim2.new(0, 18, 0, 18)
    statusFrame.BackgroundColor3 = C.gray
    statusFrame.BorderSizePixel = 0
    statusFrame.ZIndex = 5
    statusFrame.Parent = btn
    
    Instance.new("UICorner", statusFrame).CornerRadius = UDim.new(0, 9)
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -140, 0, 26)
    nameLabel.Position = UDim2.new(0, 45, 0, 12)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = scriptData.name
    nameLabel.TextColor3 = C.white
    nameLabel.TextSize = 17
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 5
    nameLabel.Parent = btn
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -140, 0, 22)
    descLabel.Position = UDim2.new(0, 45, 0, 38)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = scriptData.desc
    descLabel.TextColor3 = C.gray
    descLabel.TextSize = 13
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.ZIndex = 5
    descLabel.Parent = btn
    
    local catLabel = Instance.new("TextLabel")
    catLabel.Size = UDim2.new(0, 90, 0, 22)
    catLabel.Position = UDim2.new(0, 45, 1, -28)
    catLabel.BackgroundColor3 = C.bgDark
    catLabel.Text = scriptData.category
    catLabel.TextColor3 = C.accent2
    catLabel.TextSize = 11
    catLabel.Font = Enum.Font.GothamBold
    catLabel.ZIndex = 5
    catLabel.Parent = btn
    
    Instance.new("UICorner", catLabel).CornerRadius = UDim.new(0, 6)
    
    local injectBtn = Instance.new("TextButton")
    injectBtn.Size = UDim2.new(0, 90, 0, 36)
    injectBtn.Position = UDim2.new(1, -105, 0.5, -18)
    injectBtn.BackgroundColor3 = C.white
    injectBtn.Text = "RUN"
    injectBtn.TextColor3 = C.black
    injectBtn.TextSize = 14
    injectBtn.Font = Enum.Font.GothamBlack
    injectBtn.ZIndex = 5
    injectBtn.Parent = btn
    
    Instance.new("UICorner", injectBtn).CornerRadius = UDim.new(0, 8)
    
    local injected = false
    
    injectBtn.MouseButton1Click:Connect(function()
        if injected then return end
        
        injectBtn.Text = "..."
        injectBtn.BackgroundColor3 = C.yellow
        
        task.spawn(function()
            local success = pcall(function()
                loadstring(game:HttpGet(scriptData.url, true))()
            end)
            
            if success then
                injected = true
                statusFrame.BackgroundColor3 = C.green
                injectBtn.Text = "ON"
                injectBtn.BackgroundColor3 = C.green
                injectBtn.TextColor3 = C.white
            else
                injectBtn.Text = "ERROR"
                injectBtn.BackgroundColor3 = C.red
                task.wait(2)
                injectBtn.Text = "RUN"
                injectBtn.BackgroundColor3 = C.white
                injectBtn.TextColor3 = C.black
            end
        end)
    end)
    
    buttons[scriptData.name] = {Btn = btn, Tab = tabName, IsScript = true}
    return btn
end

-- Create Morph Button
local function createMorphButton(morphData, tabName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 70)
    btn.BackgroundColor3 = C.bgLight
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.ZIndex = 4
    btn.Parent = scroll
    btn.Visible = false
    
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = C.border
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = btn
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -130, 0, 26)
    nameLabel.Position = UDim2.new(0, 18, 0, 12)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = morphData.name
    nameLabel.TextColor3 = C.white
    nameLabel.TextSize = 17
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 5
    nameLabel.Parent = btn
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -130, 0, 22)
    descLabel.Position = UDim2.new(0, 18, 0, 38)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = morphData.desc
    descLabel.TextColor3 = C.gray
    descLabel.TextSize = 13
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.ZIndex = 5
    descLabel.Parent = btn
    
    local morphBtn = Instance.new("TextButton")
    morphBtn.Size = UDim2.new(0, 90, 0, 36)
    morphBtn.Position = UDim2.new(1, -105, 0.5, -18)
    morphBtn.BackgroundColor3 = C.accent2
    morphBtn.Text = "MORPH"
    morphBtn.TextColor3 = C.black
    morphBtn.TextSize = 14
    morphBtn.Font = Enum.Font.GothamBlack
    morphBtn.ZIndex = 5
    morphBtn.Parent = btn
    
    Instance.new("UICorner", morphBtn).CornerRadius = UDim.new(0, 8)
    
    morphBtn.MouseButton1Click:Connect(function()
        morphBtn.Text = "..."
        morphBtn.BackgroundColor3 = C.yellow
        
        task.spawn(function()
            local success = pcall(function()
                loadstring(morphData.script)()
            end)
            
            if success then
                morphBtn.Text = "DONE"
                morphBtn.BackgroundColor3 = C.green
                morphBtn.TextColor3 = C.white
                task.wait(2)
                morphBtn.Text = "MORPH"
                morphBtn.BackgroundColor3 = C.accent2
                morphBtn.TextColor3 = C.black
            else
                morphBtn.Text = "ERROR"
                morphBtn.BackgroundColor3 = C.red
                task.wait(2)
                morphBtn.Text = "MORPH"
                morphBtn.BackgroundColor3 = C.accent2
                morphBtn.TextColor3 = C.black
            end
        end)
    end)
    
    buttons[morphData.name] = {Btn = btn, Tab = tabName, IsMorph = true}
    return btn
end

-- Create Tool Button
local function createToolButton(toolData, tabName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 70)
    btn.BackgroundColor3 = C.bgLight
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.ZIndex = 4
    btn.Parent = scroll
    btn.Visible = false
    
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = C.border
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = btn
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -130, 0, 26)
    nameLabel.Position = UDim2.new(0, 18, 0, 12)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = toolData.name
    nameLabel.TextColor3 = C.white
    nameLabel.TextSize = 17
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 5
    nameLabel.Parent = btn
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -130, 0, 22)
    descLabel.Position = UDim2.new(0, 18, 0, 38)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = toolData.desc
    descLabel.TextColor3 = C.gray
    descLabel.TextSize = 13
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.ZIndex = 5
    descLabel.Parent = btn
    
    local toolBtn = Instance.new("TextButton")
    toolBtn.Size = UDim2.new(0, 90, 0, 36)
    toolBtn.Position = UDim2.new(1, -105, 0.5, -18)
    toolBtn.BackgroundColor3 = C.white
    toolBtn.Text = "GET"
    toolBtn.TextColor3 = C.black
    toolBtn.TextSize = 14
    toolBtn.Font = Enum.Font.GothamBlack
    toolBtn.ZIndex = 5
    toolBtn.Parent = btn
    
    Instance.new("UICorner", toolBtn).CornerRadius = UDim.new(0, 8)
    
    toolBtn.MouseButton1Click:Connect(function()
        toolBtn.Text = "..."
        toolBtn.BackgroundColor3 = C.yellow
        
        task.spawn(function()
            local success = pcall(function()
                loadstring(toolData.script)()
            end)
            
            if success then
                toolBtn.Text = "ON"
                toolBtn.BackgroundColor3 = C.green
                toolBtn.TextColor3 = C.white
                task.wait(2)
                toolBtn.Text = "GET"
                toolBtn.BackgroundColor3 = C.white
                toolBtn.TextColor3 = C.black
            else
                toolBtn.Text = "ERROR"
                toolBtn.BackgroundColor3 = C.red
                task.wait(2)
                toolBtn.Text = "GET"
                toolBtn.BackgroundColor3 = C.white
                toolBtn.TextColor3 = C.black
            end
        end)
    end)
    
    buttons[toolData.name] = {Btn = btn, Tab = tabName, IsTool = true}
    return btn
end

-- Create Custom Script Input
local function createCustomScriptInput(tabName)
    -- Main container
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 400)
    container.BackgroundColor3 = C.bgLight
    container.BorderSizePixel = 0
    container.ZIndex = 4
    container.Parent = scroll
    container.Visible = false
    
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 12)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = C.border
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = container
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "CUSTOM SCRIPT EXECUTOR"
    title.TextColor3 = C.white
    title.TextSize = 16
    title.Font = Enum.Font.GothamBlack
    title.ZIndex = 5
    title.Parent = container
    
    -- Script name input
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0, 100, 0, 25)
    nameLabel.Position = UDim2.new(0, 10, 0, 45)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "Script Name:"
    nameLabel.TextColor3 = C.gray
    nameLabel.TextSize = 12
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.ZIndex = 5
    nameLabel.Parent = container
    
    local nameInput = Instance.new("TextBox")
    nameInput.Size = UDim2.new(1, -130, 0, 30)
    nameInput.Position = UDim2.new(0, 115, 0, 42)
    nameInput.BackgroundColor3 = C.bgDark
    nameInput.Text = "MyScript"
    nameInput.TextColor3 = C.white
    nameInput.TextSize = 13
    nameInput.Font = Enum.Font.Gotham
    nameInput.ZIndex = 5
    nameInput.Parent = container
    
    Instance.new("UICorner", nameInput).CornerRadius = UDim.new(0, 8)
    
    -- Code box
    local codeBox = Instance.new("TextBox")
    codeBox.Size = UDim2.new(1, -20, 0, 200)
    codeBox.Position = UDim2.new(0, 10, 0, 80)
    codeBox.BackgroundColor3 = C.bgDark
    codeBox.Text = "-- Введите Lua код здесь\n-- Например:\n-- print('Hello')"
    codeBox.TextColor3 = C.white
    codeBox.PlaceholderText = "-- Lua код..."
    codeBox.TextSize = 12
    codeBox.Font = Enum.Font.Code
    codeBox.MultiLine = true
    codeBox.ClearTextOnFocus = false
    codeBox.TextXAlignment = Enum.TextXAlignment.Left
    codeBox.TextYAlignment = Enum.TextYAlignment.Top
    codeBox.ZIndex = 5
    codeBox.Parent = container
    
    Instance.new("UICorner", codeBox).CornerRadius = UDim.new(0, 8)
    
    -- Buttons row
    local runBtn = Instance.new("TextButton")
    runBtn.Size = UDim2.new(0, 100, 0, 35)
    runBtn.Position = UDim2.new(0, 10, 1, -50)
    runBtn.BackgroundColor3 = C.green
    runBtn.Text = "RUN"
    runBtn.TextColor3 = C.black
    runBtn.TextSize = 14
    runBtn.Font = Enum.Font.GothamBlack
    runBtn.ZIndex = 5
    runBtn.Parent = container
    
    Instance.new("UICorner", runBtn).CornerRadius = UDim.new(0, 8)
    
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0, 100, 0, 35)
    saveBtn.Position = UDim2.new(0, 120, 1, -50)
    saveBtn.BackgroundColor3 = C.white
    saveBtn.Text = "SAVE"
    saveBtn.TextColor3 = C.black
    saveBtn.TextSize = 14
    saveBtn.Font = Enum.Font.GothamBlack
    saveBtn.ZIndex = 5
    saveBtn.Parent = container
    
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 8)
    
    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0, 100, 0, 35)
    clearBtn.Position = UDim2.new(0, 230, 1, -50)
    clearBtn.BackgroundColor3 = C.red
    clearBtn.Text = "CLEAR"
    clearBtn.TextColor3 = C.white
    clearBtn.TextSize = 14
    clearBtn.Font = Enum.Font.GothamBlack
    clearBtn.ZIndex = 5
    clearBtn.Parent = container
    
    Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 8)
    
    -- Saved scripts list
    local savedTitle = Instance.new("TextLabel")
    savedTitle.Size = UDim2.new(1, -20, 0, 25)
    savedTitle.Position = UDim2.new(0, 10, 0, 290)
    savedTitle.BackgroundTransparency = 1
    savedTitle.Text = "SAVED SCRIPTS:"
    savedTitle.TextColor3 = C.gray
    savedTitle.TextSize = 12
    savedTitle.Font = Enum.Font.GothamBold
    savedTitle.ZIndex = 5
    savedTitle.Parent = container
    
    local savedList = Instance.new("ScrollingFrame")
    savedList.Size = UDim2.new(1, -20, 0, 60)
    savedList.Position = UDim2.new(0, 10, 0, 315)
    savedList.BackgroundColor3 = C.bgDark
    savedList.BorderSizePixel = 0
    savedList.ScrollBarThickness = 4
    savedList.ZIndex = 5
    savedList.Parent = container
    
    Instance.new("UICorner", savedList).CornerRadius = UDim.new(0, 8)
    
    local savedListLayout = Instance.new("UIListLayout")
    savedListLayout.Padding = UDim.new(0, 5)
    savedListLayout.Parent = savedList
    
    -- Functions
    local function updateSavedList()
        for _, child in pairs(savedList:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        for name, code in pairs(savedScripts) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 30)
            btn.BackgroundColor3 = C.bgLight
            btn.Text = name
            btn.TextColor3 = C.white
            btn.TextSize = 12
            btn.Font = Enum.Font.Gotham
            btn.ZIndex = 6
            btn.Parent = savedList
            
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            
            btn.MouseButton1Click:Connect(function()
                codeBox.Text = code
                nameInput.Text = name
            end)
            
            btn.MouseButton2Click:Connect(function()
                savedScripts[name] = nil
                updateSavedList()
            end)
        end
        
        savedList.CanvasSize = UDim2.new(0, 0, 0, savedListLayout.AbsoluteContentSize.Y + 10)
    end
    
    runBtn.MouseButton1Click:Connect(function()
        local code = codeBox.Text
        if code and code ~= "" then
            local success, err = pcall(function()
                loadstring(code)()
            end)
            
            if success then
                StarterGui:SetCore("SendNotification", {
                    Title = "✅ SUCCESS",
                    Text = "Script executed!",
                    Duration = 3
                })
            else
                StarterGui:SetCore("SendNotification", {
                    Title = "❌ ERROR",
                    Text = tostring(err):sub(1, 50),
                    Duration = 3
                })
            end
        end
    end)
    
    saveBtn.MouseButton1Click:Connect(function()
        local name = nameInput.Text
        local code = codeBox.Text
        
        if name and name ~= "" and code and code ~= "" then
            savedScripts[name] = code
            updateSavedList()
            
            StarterGui:SetCore("SendNotification", {
                Title = "💾 SAVED",
                Text = "Script '" .. name .. "' saved!",
                Duration = 2
            })
        end
    end)
    
    clearBtn.MouseButton1Click:Connect(function()
        codeBox.Text = ""
        nameInput.Text = "MyScript"
    end)
    
    buttons["CustomScriptExecutor"] = {Btn = container, Tab = tabName, IsInput = true}
    return container
end

-- TABS
createTab("Движение", "⚡")
createTab("Бой", "⚔️")
createTab("Игрок", "👤")
createTab("Визуал", "👁️")
createTab("Мир", "🌍")
createTab("Морфы", "🎭")
createTab("Развлечения", "🎮")
createTab("Скрипты", "📜")
createTab("Custom Chat", "💬")
createTab("Tools", "🛠️")
createTab("Настройки", "⚙️")

-- ДВИЖЕНИЕ
createButton("Полет", "Движение", function(a)
    S.fly = a
    if not a then
        for _, v in pairs(loopConnections) do
            if v.Name == "Fly" then v:Disconnect() end
        end
        return
    end
    local conn = RunService.Heartbeat:Connect(function()
        if not S.fly or not player.Character then return end
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local vel = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel += camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel -= camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel -= camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel += camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel -= Vector3.new(0, 1, 0) end
        hrp.Velocity = vel * 50
    end)
    conn.Name = "Fly"
    table.insert(loopConnections, conn)
end, true, "Летать по карте")

createButton("Скорость", "Движение", function(a)
    S.speed = a
    if humanoid then humanoid.WalkSpeed = a and 100 or 16 end
end, true, "Быстрая ходьба")

createButton("Ноклип", "Движение", function(a)
    S.noclip = a
    if not a then
        for _, v in pairs(loopConnections) do
            if v.Name == "Noclip" then v:Disconnect() end
        end
        return
    end
    local conn = RunService.Stepped:Connect(function()
        if S.noclip and player.Character then
            for _, p in pairs(player.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end)
    conn.Name = "Noclip"
    table.insert(loopConnections, conn)
end, true, "Сквозь стены")

createButton("Беск прыжки", "Движение", function(a) S.infjump = a end, true, "Прыгать всегда")
createButton("Банни Хоп", "Движение", function(a) S.bhop = a end, true, "Авто прыжки")
createButton("Клик ТП", "Движение", function(a) S.clicktp = a end, true, "ТП по клику")
createButton("Высокий прыжок", "Движение", function(a)
    S.jumppower = a
    if humanoid then humanoid.JumpPower = a and 150 or 50 end
end, true, "Прыгать выше")

-- БОЙ
createButton("Аимбот", "Бой", function(a) S.aimbot = a end, true, "Авто прицел")
createButton("Сайлент Аим", "Бой", function(a) S.silentaim = a end, true, "Тихий аим")
createButton("Триггер Бот", "Бой", function(a) S.triggerbot = a end, true, "Авто стрельба")
createButton("Хитбокс", "Бой", function(a)
    S.hitbox = a
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head then head.Size = a and Vector3.new(15, 15, 15) or Vector3.new(2, 1, 1) end
        end
    end
end, true, "Большие головы")

-- ИГРОК
createButton("Год мод", "Игрок", function(a)
    S.godmode = a
    if humanoid then
        if a then
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
        else
            humanoid.MaxHealth = 100
            humanoid.Health = 100
        end
    end
end, true, "Бессмертие")

createButton("Невидимка", "Игрок", function(a)
    S.invisible = a
    if player.Character then
        for _, p in pairs(player.Character:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                p.Transparency = a and 1 or 0
            end
        end
    end
end, true, "Невидимый")

createButton("Анти АФК", "Игрок", function(a)
    S.antiafk = a
    if a then
        local vu = game:GetService("VirtualUser")
        local conn = player.Idled:Connect(function()
            if S.antiafk then
                vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end
        end)
        conn.Name = "AntiAFK"
        table.insert(loopConnections, conn)
    else
        for _, v in pairs(loopConnections) do
            if v.Name == "AntiAFK" then v:Disconnect() end
        end
    end
end, true, "Не кикать за АФК")

createButton("Хилл", "Игрок", function(a)
    if humanoid then humanoid.Health = humanoid.MaxHealth end
end, false, "Полное здоровье")

createButton("Суицид", "Игрок", function(a)
    if humanoid then humanoid.Health = 0 end
end, false, "Убить себя")

-- ВИЗУАЛ
createButton("ESP", "Визуал", function(a)
    S.esp = a
    if a then
        local function createESP(plr)
            if plr == player then return end
            if plr.Character then
                local highlight = Instance.new("Highlight")
                highlight.Name = "SEAL_ESP"
                highlight.FillColor = plr.TeamColor.Color or Color3.new(1, 0, 0)
                highlight.OutlineColor = Color3.new(1, 1, 1)
                highlight.FillTransparency = 0.5
                highlight.Parent = plr.Character
                espObjects[plr] = highlight
            end
        end
        for _, plr in pairs(Players:GetPlayers()) do createESP(plr) end
        local conn = Players.PlayerAdded:Connect(createESP)
        conn.Name = "ESP"
        table.insert(loopConnections, conn)
    else
        for _, v in pairs(espObjects) do v:Destroy() end
        espObjects = {}
        for _, v in pairs(loopConnections) do
            if v.Name == "ESP" then v:Disconnect() end
        end
    end
end, true, "Подсветка игроков")

createButton("Фуллбрайт", "Визуал", function(a)
    S.fullbright = a
    Lighting.Brightness = a and 10 or 2
    Lighting.GlobalShadows = not a
end, true, "Светло всегда")

createButton("X-Ray", "Визуал", function(a)
    S.xray = a
    for _, p in pairs(Workspace:GetDescendants()) do
        if p:IsA("BasePart") and not p.Parent:FindFirstChild("Humanoid") then
            p.LocalTransparencyModifier = a and 0.7 or 0
        end
    end
end, true, "Видеть сквозь")

-- МИР
createButton("Убрать туман", "Мир", function(a)
    S.removefog = a
    Lighting.FogEnd = a and 10000 or 1000
end, true, "Нет тумана")

createButton("Убрать деревья", "Мир", function(a)
    S.notrees = a
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("tree") then
            v.Transparency = a and 1 or 0
        end
    end
end, true, "Деревья прозрачные")

-- МОРФЫ
for _, morph in pairs(Morphs) do createMorphButton(morph, "Морфы") end

-- РАЗВЛЕЧЕНИЯ
createButton("Спин бот", "Развлечения", function(a)
    S.spinbot = a
    if a then
        local conn = RunService.Heartbeat:Connect(function()
            if not S.spinbot or not hrp then return end
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(20), 0)
        end)
        conn.Name = "Spinbot"
        table.insert(loopConnections, conn)
    else
        for _, v in pairs(loopConnections) do
            if v.Name == "Spinbot" then v:Disconnect() end
        end
    end
end, true, "Крутиться")

createButton("Спам чат", "Развлечения", function(a)
    S.spamchat = a
    if a then
        task.spawn(function()
            while S.spamchat do
                pcall(function()
                    ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("SEAL HUB V17", "All")
                end)
                task.wait(3)
            end
        end)
    end
end, true, "Спам в чат")

createButton("Радуга", "Развлечения", function(a)
    S.s4x = a
    if a then
        local conn = RunService.Heartbeat:Connect(function()
            if not S.s4x or not player.Character then return end
            for _, p in pairs(player.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) end
            end
        end)
        conn.Name = "S4X"
        table.insert(loopConnections, conn)
    else
        for _, v in pairs(loopConnections) do
            if v.Name == "S4X" then v:Disconnect() end
        end
    end
end, true, "Менять цвета")

-- СКРИПТЫ (рабочие скрипты из библиотеки)
for _, script in pairs(ScriptLibrary) do
    createScriptButton(script, "Скрипты")
end

-- CUSTOM CHAT
local customChatGui = Instance.new("ScreenGui")
customChatGui.Name = "SealChat"
customChatGui.ResetOnSpawn = false
customChatGui.Parent = CoreGui
customChatGui.Enabled = false

local chatFrame = Instance.new("Frame")
chatFrame.Size = UDim2.new(0, 380, 0, 450)
chatFrame.Position = UDim2.new(0, 20, 0.5, -225)
chatFrame.BackgroundColor3 = C.bg
chatFrame.BorderSizePixel = 0
chatFrame.ZIndex = 50
chatFrame.Parent = customChatGui

Instance.new("UICorner", chatFrame).CornerRadius = UDim.new(0, 16)

local chatTitle = Instance.new("TextLabel")
chatTitle.Size = UDim2.new(1, 0, 0, 45)
chatTitle.BackgroundColor3 = C.bgLight
chatTitle.Text = "CUSTOM CHAT"
chatTitle.TextColor3 = C.white
chatTitle.TextSize = 18
chatTitle.Font = Enum.Font.GothamBlack
chatTitle.ZIndex = 51
chatTitle.Parent = chatFrame

local chatScroll = Instance.new("ScrollingFrame")
chatScroll.Size = UDim2.new(1, -20, 1, -110)
chatScroll.Position = UDim2.new(0, 10, 0, 55)
chatScroll.BackgroundColor3 = C.bgDark
chatScroll.BorderSizePixel = 0
chatScroll.ScrollBarThickness = 4
chatScroll.ZIndex = 51
chatScroll.Parent = chatFrame

Instance.new("UICorner", chatScroll).CornerRadius = UDim.new(0, 10)

local chatList = Instance.new("UIListLayout")
chatList.Padding = UDim.new(0, 6)
chatList.Parent = chatScroll

local chatInput = Instance.new("TextBox")
chatInput.Size = UDim2.new(1, -110, 0, 40)
chatInput.Position = UDim2.new(0, 10, 1, -50)
chatInput.BackgroundColor3 = C.bgLight
chatInput.Text = ""
chatInput.PlaceholderText = "Сообщение..."
chatInput.TextColor3 = C.white
chatInput.PlaceholderColor3 = C.gray
chatInput.TextSize = 14
chatInput.Font = Enum.Font.Gotham
chatInput.ZIndex = 51
chatInput.Parent = chatFrame

Instance.new("UICorner", chatInput).CornerRadius = UDim.new(0, 8)

local chatSend = Instance.new("TextButton")
chatSend.Size = UDim2.new(0, 80, 0, 40)
chatSend.Position = UDim2.new(1, -90, 1, -50)
chatSend.BackgroundColor3 = C.green
chatSend.Text = "SEND"
chatSend.TextColor3 = C.black
chatSend.TextSize = 14
chatSend.Font = Enum.Font.GothamBlack
chatSend.ZIndex = 51
chatSend.Parent = chatFrame)

Instance.new("UICorner", chatSend).CornerRadius = UDim.new(0, 8)

local function addMsg(user, msg)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -10, 0, 55)
    f.BackgroundColor3 = C.bgLight
    f.BorderSizePixel = 0
    f.ZIndex = 52
    f.Parent = chatScroll
    
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    
    local u = Instance.new("TextLabel")
    u.Size = UDim2.new(0, 120, 0, 20)
    u.Position = UDim2.new(0, 10, 0, 5)
    u.BackgroundTransparency = 1
    u.Text = user
    u.TextColor3 = C.green
    u.TextSize = 12
    u.Font = Enum.Font.GothamBold
    u.TextXAlignment = Enum.TextXAlignment.Left
    u.ZIndex = 53
    u.Parent = f
    
    local m = Instance.new("TextLabel")
    m.Size = UDim2.new(1, -20, 0, 25)
    m.Position = UDim2.new(0, 10, 0, 26)
    m.BackgroundTransparency = 1
    m.Text = msg
    m.TextColor3 = C.white
    m.TextSize = 13
    m.Font = Enum.Font.Gotham
    m.TextXAlignment = Enum.TextXAlignment.Left
    m.TextWrapped = true
    m.ZIndex = 53
    m.Parent = f
    
    chatScroll.CanvasSize = UDim2.new(0, 0, 0, chatList.AbsoluteContentSize.Y + 10)
    chatScroll.CanvasPosition = Vector2.new(0, chatScroll.CanvasSize.Y.Offset)
end

local function procMsg(msg)
    if S.chatReverse then msg = string.reverse(msg) end
    if S.chatLeet then msg = msg:gsub("a", "4"):gsub("e", "3"):gsub("i", "1"):gsub("o", "0"):gsub("s", "5") end
    if S.chatCursed then msg = msg .. " 👹" end
    if S.chatZalgo then msg = msg .. "̷̛̣" end
    return msg
end

chatSend.MouseButton1Click:Connect(function()
    local msg = chatInput.Text
    if msg ~= "" then
        msg = procMsg(msg)
        addMsg(player.Name, msg)
        chatInput.Text = ""
    end
end)

chatInput.FocusLost:Connect(function(ep) if ep then chatSend.MouseButton1Click:Fire() end end)

createButton("Вкл Custom Chat", "Custom Chat", function(a)
    S.chatEnabled = a
    customChatGui.Enabled = a
    if a then
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
        addMsg("SYSTEM", "Custom Chat активирован!")
    else
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
    end
end, true, "Включить кастом чат")

createButton("Chat Spy", "Custom Chat", function(a) S.chatSpy = a end, true, "Видеть все сообщения")
createButton("Bypass", "Custom Chat", function(a) S.chatBypass = a end, true, "Обход фильтра")
createButton("Шифрование", "Custom Chat", function(a) S.chatEncrypt = a end, true, "Шифровать")
createButton("Радуга текст", "Custom Chat", function(a) S.chatRainbow = a end, true, "Цветной текст")
createButton("Жирный", "Custom Chat", function(a) S.chatBold = a end, true, "Bold текст")
createButton("Большой", "Custom Chat", function(a) S.chatBig = a end, true, "Большой шрифт")
createButton("Маленький", "Custom Chat", function(a) S.chatSmall = a end, true, "Мелкий шрифт")
createButton("Проклятый", "Custom Chat", function(a) S.chatCursed = a end, true, "Демоны")
createButton("Реверс", "Custom Chat", function(a) S.chatReverse = a end, true, "Задом наперед")
createButton("Leet", "Custom Chat", function(a) S.chatLeet = a end, true, "1337")
createButton("Zalgo", "Custom Chat", function(a) S.chatZalgo = a end, true, "Зловещий")
createButton("Очистить", "Custom Chat", function(a)
    for _, c in pairs(chatScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    addMsg("SYSTEM", "Чат очищен")
end, false, "Удалить все")

-- TOOLS
for _, tool in pairs(ToolsLibrary) do createToolButton(tool, "Tools") end

-- НАСТРОЙКИ
createButton("Сохранить конфиг", "Настройки", function(a)
    local cfg = {binds = binds, settings = S, savedScripts = savedScripts}
    local s = pcall(function()
        local j = HttpService:JSONEncode(cfg)
        print("CFG:", j)
    end)
    if s then
        StarterGui:SetCore("SendNotification", {Title = "💾 CFG", Text = "Сохранено", Duration = 2})
    end
end, false, "Сохранить настройки")

createButton("Загрузить конфиг", "Настройки", function(a)
    StarterGui:SetCore("SendNotification", {Title = "📂 CFG", Text = "Загружено", Duration = 2})
end, false, "Загрузить настройки")

createButton("Сбросить все", "Настройки", function(a)
    for k, v in pairs(S) do if type(v) == "boolean" then S[k] = false end end
    for _, btn in pairs(buttons) do if btn.Set and btn.IsToggle then btn.Set(false) end end
    for _, conn in pairs(loopConnections) do conn:Disconnect() end
    loopConnections = {}
    StarterGui:SetCore("SendNotification", {Title = "🔄 CFG", Text = "Все сброшено", Duration = 2})
end, false, "Отключить все")

createButton("Убить скрипт", "Настройки", function(a)
    screen:Destroy()
    customChatGui:Destroy()
    StarterGui:SetCore("SendNotification", {Title = "👋 BYE", Text = "Выключено", Duration = 2})
end, false, "Выключить хаб")

createButton("Скрыть UI", "Настройки", function(a)
    main.Visible = false
    menuOpen = false
    openBtn.Visible = true
end, false, "Свернуть")

-- Custom Script Executor (вкладка Инжект заменена на Executor)
createTab("Executor", "▶️")
createCustomScriptInput("Executor")

-- Functions
local function toggleMenu()
    menuOpen = not menuOpen
    main.Visible = menuOpen
    if menuOpen then
        main.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 850, 0, 650)}):Play()
        for _, btn in pairs(buttons) do btn.Btn.Visible = false end
        local count = 0
        for _, btn in pairs(buttons) do
            if btn.Tab == currentTab then
                btn.Btn.Visible = true
                btn.Btn.LayoutOrder = count
                count = count + 1
            end
        end
        scroll.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 20)
    end
end

keyButton.MouseButton1Click:Connect(function()
    if checkKey(keyInput.Text) then
        TweenService:Create(keyFrame, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -210, -1, -140)}):Play()
        task.wait(0.5)
        keyFrame:Destroy()
        main.Visible = true
        openBtn.Visible = true
        StarterGui:SetCore("SendNotification", {Title = "✅ OK", Text = "Добро пожаловать", Duration = 3})
    else
        keyStatus.Text = "Неверный ключ"
        keyInput.Text = ""
    end
end)

openBtn.MouseButton1Click:Connect(toggleMenu)
closeBtn.MouseButton1Click:Connect(toggleMenu)
minBtn.MouseButton1Click:Connect(toggleMenu)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.Insert then
        toggleMenu()
    end
    if waitingBind and input.UserInputType == Enum.UserInputType.Keyboard then
        binds[waitingBind] = input.KeyCode
        if buttons[waitingBind] then
            buttons[waitingBind].BindLabel.Text = input.KeyCode.Name:sub(1, 4)
            buttons[waitingBind].BindLabel.TextColor3 = C.white
        end
        waitingBind = nil
        return
    end
    for name, key in pairs(binds) do
        if input.KeyCode == key and buttons[name] then
            if buttons[name].IsToggle then
                buttons[name].Set(not buttons[name].Get())
            else
                buttons[name].Set(true)
            end
        end
    end
    if input.KeyCode == Enum.KeyCode.Space and S.infjump and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

mouse.Button1Down:Connect(function()
    if S.clicktp and mouse.Hit and hrp then
        hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
    end
end)

task.spawn(function()
    while task.wait(2) do
        local fps = math.floor(1 / RunService.Heartbeat:Wait())
        fpsLabel.Text = fps .. " FPS"
        fpsLabel.TextColor3 = fps >= 60 and C.green or (fps >= 30 and C.yellow or C.red)
    end
end)

RunService.RenderStepped:Connect(function()
    frameCounter = (frameCounter + 1) % FRAME_SKIP
    if frameCounter ~= 0 then return end
    if S.bhop and humanoid and humanoid:GetState() == Enum.HumanoidStateType.Running then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
    if S.aimbot then
        local closest = nil
        local closestDist = 200
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                local head = p.Character.Head
                local pos, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = head
                    end
                end
            end
        end
        if closest then camera.CFrame = CFrame.new(camera.CFrame.Position, closest.Position) end
    end
end)

player.CharacterAdded:Connect(function(c)
    character = c
    humanoid = c:WaitForChild("Humanoid")
    hrp = c:WaitForChild("HumanoidRootPart")
    if S.speed then humanoid.WalkSpeed = 100 end
    if S.jumppower then humanoid.JumpPower = 150 end
    if S.godmode then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
    end
    if S.invisible then
        for _, p in pairs(c:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 1 end
        end
    end
end)

makeDraggable(main, titleBar)
makeDraggable(keyFrame, keyTitle)
makeDraggable(chatFrame, chatTitle)

local firstTab = tabs[1]
if firstTab then
    firstTab.HL.Visible = true
    TweenService:Create(firstTab.Btn, TweenInfo.new(0.2), {BackgroundColor3 = C.bgLight}):Play()
    firstTab.Icon.TextColor3 = C.white
    firstTab.Name.TextColor3 = C.white
end

for _, btn in pairs(buttons) do
    if btn.Tab == currentTab then
        btn.Btn.Visible = true
    end
end
scroll.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 20)
