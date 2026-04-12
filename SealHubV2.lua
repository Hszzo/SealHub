--[[
    SEAL ADMIN HUB V18 - FIXED & ENHANCED
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

-- Цветовая схема 
local C = {
    bg = Color3.fromRGB(10, 10, 15),
    bgLight = Color3.fromRGB(20, 20, 30),
    bgDark = Color3.fromRGB(5, 5, 8),
    accent = Color3.fromRGB(88, 101, 242), -- Discord-like purple
    accent2 = Color3.fromRGB(114, 137, 218),
    green = Color3.fromRGB(59, 165, 93),
    red = Color3.fromRGB(237, 66, 69),
    yellow = Color3.fromRGB(250, 168, 26),
    white = Color3.fromRGB(255, 255, 255),
    gray = Color3.fromRGB(150, 150, 150),
    black = Color3.fromRGB(0, 0, 0),
    border = Color3.fromRGB(40, 40, 60),
    hover = Color3.fromRGB(35, 35, 50),
    gradientStart = Color3.fromRGB(88, 101, 242),
    gradientEnd = Color3.fromRGB(114, 137, 218)
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
local currentTab = "Движение"
local menuOpen = false
local waitingBind = nil

-- Логика меню
local function checkKey(input)
    return input == "hsz"
end

-- Рабочие скрипты
local ScriptLibrary = {
    {name = "Infinite Yield", url = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", desc = "Лучший админ скрипт", category = "Админ"},
    {name = "CMD-X", url = "https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source", desc = "Мощная консоль", category = "Админ"},
    {name = "Reviz Admin", url = "https://raw.githubusercontent.com/revizadmin/reviz/master/source.lua", desc = "Админ команды", category = "Админ"},
    {name = "Dex Explorer", url = "https://raw.githubusercontent.com/infyiff/backup/main/dex.lua", desc = "Проводник игры", category = "Утилиты"},
    {name = "SimpleSpy V3", url = "https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua", desc = "Сниффер", category = "Утилиты"},
    {name = "System Broken", url = "https://raw.githubusercontent.com/H20CalibreYT/SystemBroken/main/script", desc = "Флай, спид, телепорт", category = "Движение"},
    {name = "Telekinesis V5", url = "https://rawscripts.net/raw/Universal-Script-Fe-Telekinesis-V5-21542", desc = "Телекинез", category = "Физика"},
    {name = "Ultimate Trolling GUI", url = "https://rawscripts.net/raw/Universal-Script-ULTIMATE-TROLLING-GUI-V5-39695", desc = "Троллинг", category = "Троллинг"},
    
    -- НОВЫЕ СКРИПТЫ:
    {name = "MNA Hub", url = "https://rawscripts.net/raw/Universal-Script-MNAHub-CMD-The-best-Commands-hub-for-Xeno-242412", desc = "Лучший CMD хаб для Xeno", category = "Админ"},
    {name = "Build A Boat Ultimate", url = "https://rawscripts.net/raw/Build-A-Boat-For-Treasure-Ultimte-B3BFT-Script-28601", desc = "Для Build A Boat", category = "Игры"},
    {name = "Super Ring V4", url = "https://rawscripts.net/raw/Natural-Disaster-Survival-Super-ring-V4-24296", desc = "Летающие блоки в Disaster", category = "Игры"},
    {name = "God Mode Script", url = "https://raw.githubusercontent.com/miglels33/God-Mode-Script/refs/heads/main/GodModeScript.md", desc = "Бессмертие", category = "Игрок"},
    {name = "Invincible Flight", url = "https://rawscripts.net/raw/Universal-Script-Invinicible-Flight-R15-45414", desc = "Летать как супергерой", category = "Движение"},
    {name = "Fling Things V2", url = "https://rawscripts.net/raw/Fling-Things-and-People-*-V2-62163", desc = "Бросать вещи и людей", category = "Физика"},
    {name = "Lalol Hub", url = "https://rawscripts.net/raw/Universal-Script-Lalol-hub-30354", desc = "Бэкдор скрипт", category = "Админ"},
    {name = "Project Ham", url = "https://pastebin.com/raw/KSvbtcPE", desc = "Крутой универсальный скрипт", category = "Универсал"},
    {name = "FE SCP-096", url = "https://rawscripts.net/raw/Universal-Script-FE-SCP-096-36948", desc = "Скромник SCP", category = "Морфы"},
    {name = "Murder Mystery", url = "https://globalexp.xyz/", desc = "Мурдер Мистери скрипт", category = "Игры"},
    {name = "Murder Mystery Aimbot", url = "https://globalexp.xyz/aimbotkey", desc = "Аимбот для MM2", category = "Игры"},
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
    {name = "Orbit", desc = "Вращение", script = [[loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Orbit-Players-20077"))()]]},
    {name = "Fling", desc = "Кидать игроков", script = [[loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-FE-Fling-20076"))()]]},
    {name = "Freecam", desc = "Свободная камера", script = [[loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Freecam-20078"))()]]},
    {name = "Bring", desc = "Притягивать", script = [[loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Bring-Players-20087"))()]]},
}

-- GUI
local screen = Instance.new("ScreenGui")
screen.Name = "SealAdminV18"
screen.ResetOnSpawn = false
screen.ZIndexBehavior = Enum.ZIndexBehavior.Global
screen.Parent = CoreGui

-- Логика меню
local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(0, 400, 0, 320)
keyFrame.Position = UDim2.new(0.5, -200, 0.5, -160)
keyFrame.BackgroundColor3 = C.bg
keyFrame.BorderSizePixel = 0
keyFrame.ZIndex = 100
keyFrame.Parent = screen

local keyCorner = Instance.new("UICorner")
keyCorner.CornerRadius = UDim.new(0, 24)
keyCorner.Parent = keyFrame

local keyGradient = Instance.new("UIGradient")
keyGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.bg),
    ColorSequenceKeypoint.new(1, C.bgLight)
})
keyGradient.Rotation = 45
keyGradient.Parent = keyFrame

local keyTitle = Instance.new("TextLabel")
keyTitle.Size = UDim2.new(1, 0, 0, 80)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = "🔒 SEAL HUB | By hszzo"
keyTitle.TextColor3 = C.white
keyTitle.TextSize = 36
keyTitle.Font = Enum.Font.GothamBlack
keyTitle.ZIndex = 101
keyTitle.Parent = keyFrame

local keySubtitle = Instance.new("TextLabel")
keySubtitle.Size = UDim2.new(1, 0, 0, 30)
keySubtitle.Position = UDim2.new(0, 0, 0, 65)
keySubtitle.BackgroundTransparency = 1
keySubtitle.Text = "Скрипт от тюленя Хсе!"
keySubtitle.TextColor3 = C.accent
keySubtitle.TextSize = 16
keySubtitle.Font = Enum.Font.GothamBold
keySubtitle.ZIndex = 101
keySubtitle.Parent = keyFrame

local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(0, 320, 0, 55)
keyInput.Position = UDim2.new(0.5, -160, 0.5, -27)
keyInput.BackgroundColor3 = C.bgLight
keyInput.Text = ""
keyInput.PlaceholderText = "Введите ключ..."
keyInput.TextColor3 = C.white
keyInput.PlaceholderColor3 = C.gray
keyInput.TextSize = 18
keyInput.Font = Enum.Font.GothamBold
keyInput.ClearTextOnFocus = true
keyInput.ZIndex = 101
keyInput.Parent = keyFrame

local keyInputCorner = Instance.new("UICorner")
keyInputCorner.CornerRadius = UDim.new(0, 16)
keyInputCorner.Parent = keyInput

local keyInputStroke = Instance.new("UIStroke")
keyInputStroke.Color = C.border
keyInputStroke.Thickness = 2
keyInputStroke.Parent = keyInput

local keyButton = Instance.new("TextButton")
keyButton.Size = UDim2.new(0, 320, 0, 55)
keyButton.Position = UDim2.new(0.5, -160, 0.75, 0)
keyButton.BackgroundColor3 = C.accent
keyButton.Text = "UNLOCK"
keyButton.TextColor3 = C.white
keyButton.TextSize = 18
keyButton.Font = Enum.Font.GothamBlack
keyButton.ZIndex = 101
keyButton.Parent = keyFrame

local keyButtonCorner = Instance.new("UICorner")
keyButtonCorner.CornerRadius = UDim.new(0, 16)
keyButtonCorner.Parent = keyButton

local keyStatus = Instance.new("TextLabel")
keyStatus.Size = UDim2.new(1, 0, 0, 25)
keyStatus.Position = UDim2.new(0, 0, 1, -40)
keyStatus.BackgroundTransparency = 1
keyStatus.Text = ""
keyStatus.TextColor3 = C.red
keyStatus.TextSize = 14
keyStatus.Font = Enum.Font.GothamBold
keyStatus.ZIndex = 101
keyStatus.Parent = keyFrame

-- Main Window 
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 900, 0, 600)
main.Position = UDim2.new(0.5, -450, 0.5, -300)
main.BackgroundColor3 = C.bg
main.BorderSizePixel = 0
main.Visible = false
main.Active = true
main.ClipsDescendants = true
main.Parent = screen

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 20)
corner.Parent = main

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 60)
titleBar.BackgroundColor3 = C.bgLight
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 2
titleBar.Parent = main

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 20)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0, 300, 1, 0)
titleText.Position = UDim2.new(0, 20, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "SealHub | От тюленя хсе"
titleText.TextColor3 = C.white
titleText.TextSize = 24
titleText.Font = Enum.Font.GothamBlack
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.ZIndex = 3
titleText.Parent = titleBar

local titleVer = Instance.new("TextLabel")
titleVer.Size = UDim2.new(0, 100, 0, 20)
titleVer.Position = UDim2.new(0, 20, 1, -22)
titleVer.BackgroundTransparency = 1
titleVer.Text = "V3"
titleVer.TextColor3 = C.green
titleVer.TextSize = 12
titleVer.Font = Enum.Font.GothamBold
titleVer.TextXAlignment = Enum.TextXAlignment.Left
titleVer.ZIndex = 3
titleVer.Parent = titleBar

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0, 80, 0, 28)
fpsLabel.Position = UDim2.new(1, -280, 0, 16)
fpsLabel.BackgroundColor3 = C.bgDark
fpsLabel.Text = "60 FPS"
fpsLabel.TextColor3 = C.green
fpsLabel.TextSize = 13
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.ZIndex = 3
fpsLabel.Parent = titleBar

local fpsCorner = Instance.new("UICorner")
fpsCorner.CornerRadius = UDim.new(0, 8)
fpsCorner.Parent = fpsLabel

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 40, 0, 32)
minBtn.Position = UDim2.new(1, -130, 0, 14)
minBtn.BackgroundColor3 = C.yellow
minBtn.Text = "−"
minBtn.TextColor3 = C.black
minBtn.TextSize = 18
minBtn.Font = Enum.Font.GothamBlack
minBtn.ZIndex = 3
minBtn.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = minBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 32)
closeBtn.Position = UDim2.new(1, -80, 0, 14)
closeBtn.BackgroundColor3 = C.red
closeBtn.Text = "×"
closeBtn.TextColor3 = C.white
closeBtn.TextSize = 20
closeBtn.Font = Enum.Font.GothamBlack
closeBtn.ZIndex = 3
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

-- Tab Panel 
local tabPanel = Instance.new("ScrollingFrame")
tabPanel.Size = UDim2.new(0, 200, 1, -60)
tabPanel.Position = UDim2.new(0, 0, 0, 60)
tabPanel.BackgroundColor3 = C.bgDark
tabPanel.BorderSizePixel = 0
tabPanel.ZIndex = 2
tabPanel.ScrollBarThickness = 4
tabPanel.ScrollBarImageColor3 = C.accent
tabPanel.CanvasSize = UDim2.new(0, 0, 0, 700)
tabPanel.Parent = main

-- Content Area 
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -200, 1, -60)
content.Position = UDim2.new(0, 200, 0, 60)
content.BackgroundColor3 = C.bg
content.BorderSizePixel = 0
content.ZIndex = 2
content.Parent = main

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -20)
scroll.Position = UDim2.new(0, 10, 0, 10)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 6
scroll.ScrollBarImageColor3 = C.accent
scroll.ZIndex = 3
scroll.Parent = content

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 12)
list.Parent = scroll

-- Open Button
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 60, 0, 60)
openBtn.Position = UDim2.new(1, -80, 0.5, -30)
openBtn.BackgroundColor3 = C.accent
openBtn.Text = "Seal"
openBtn.TextColor3 = C.white
openBtn.TextSize = 28
openBtn.Font = Enum.Font.GothamBlack
openBtn.ZIndex = 10
openBtn.Parent = screen
openBtn.Visible = false

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 16)
openCorner.Parent = openBtn

local openStroke = Instance.new("UIStroke")
openStroke.Color = C.white
openStroke.Thickness = 2
openStroke.Transparency = 0.5
openStroke.Parent = openBtn

local tabs = {}
local buttons = {}

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
    tab.Size = UDim2.new(1, -20, 0, 48)
    tab.Position = UDim2.new(0, 10, 0, #tabs * 54)
    tab.BackgroundColor3 = C.bg
    tab.BorderSizePixel = 0
    tab.AutoButtonColor = false
    tab.Text = ""
    tab.ZIndex = 3
    tab.Parent = tabPanel
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 12)
    tabCorner.Parent = tab
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 40, 1, 0)
    iconLabel.Position = UDim2.new(0, 12, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextColor3 = C.gray
    iconLabel.TextSize = 20
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.ZIndex = 4
    iconLabel.Parent = tab
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -60, 1, 0)
    nameLabel.Position = UDim2.new(0, 55, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = C.gray
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 4
    nameLabel.Parent = tab
    
    local highlight = Instance.new("Frame")
    highlight.Size = UDim2.new(0, 3, 0.6, 0)
    highlight.Position = UDim2.new(0, 0, 0.2, 0)
    highlight.BackgroundColor3 = C.accent
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
        iconLabel.TextColor3 = C.accent
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

-- Create Toggle Button 
local function createButton(name, tabName, callback, isToggle, desc)
    local btn = Instance.new("Frame")
    btn.Name = name
    btn.Size = UDim2.new(1, -10, 0, desc and 85 or 70)
    btn.BackgroundColor3 = C.bgLight
    btn.BorderSizePixel = 0
    btn.ZIndex = 4
    btn.Parent = scroll
    btn.Visible = false
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 12)
    btnCorner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = C.border
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = btn
    
    -- Кликабельная область 
    local clickArea = Instance.new("TextButton")
    clickArea.Size = UDim2.new(1, -120, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.ZIndex = 5
    clickArea.Parent = btn
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 52, 0, 28)
    toggleFrame.Position = UDim2.new(0, 15, 0, desc and 28 or 21)
    toggleFrame.BackgroundColor3 = C.bgDark
    toggleFrame.BorderSizePixel = 0
    toggleFrame.ZIndex = 5
    toggleFrame.Parent = btn
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 14)
    toggleCorner.Parent = toggleFrame
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 22, 0, 22)
    toggleCircle.Position = UDim2.new(0, 3, 0.5, -11)
    toggleCircle.BackgroundColor3 = C.gray
    toggleCircle.BorderSizePixel = 0
    toggleCircle.ZIndex = 6
    toggleCircle.Parent = toggleFrame
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(0, 11)
    circleCorner.Parent = toggleCircle
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -180, 0, 26)
    label.Position = UDim2.new(0, 75, 0, desc and 15 or 22)
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
        descLabel.Size = UDim2.new(1, -180, 0, 22)
        descLabel.Position = UDim2.new(0, 75, 0, 45)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = desc
        descLabel.TextColor3 = C.gray
        descLabel.TextSize = 12
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.ZIndex = 5
        descLabel.Parent = btn
    end
    
    local bindBtn = Instance.new("TextButton")
    bindBtn.Size = UDim2.new(0, 70, 0, 32)
    bindBtn.Position = UDim2.new(1, -85, 0.5, -16)
    bindBtn.BackgroundColor3 = C.bgDark
    bindBtn.Text = "BIND"
    bindBtn.TextColor3 = C.gray
    bindBtn.TextSize = 12
    bindBtn.Font = Enum.Font.GothamBold
    bindBtn.ZIndex = 5
    bindBtn.Parent = btn
    
    local bindCorner = Instance.new("UICorner")
    bindCorner.CornerRadius = UDim.new(0, 8)
    bindCorner.Parent = bindBtn
    
    local active = false
    
    local function updateVisuals()
        if active then
            TweenService:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = C.accent}):Play()
            TweenService:Create(toggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 27, 0.5, -11), BackgroundColor3 = C.white}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.2), {Color = C.accent, Transparency = 0}):Play()
        else
            TweenService:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = C.bgDark}):Play()
            TweenService:Create(toggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -11), BackgroundColor3 = C.gray}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.2), {Color = C.border, Transparency = 0.5}):Play()
        end
    end
    
    clickArea.MouseButton1Click:Connect(function()
        if isToggle then
            active = not active
            updateVisuals()
        end
        callback(active)
    end)
    
    bindBtn.MouseButton1Click:Connect(function()
        waitingBind = name
        bindBtn.Text = "..."
        bindBtn.TextColor3 = C.yellow
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
        BindLabel = bindBtn,
        IsToggle = isToggle
    }
    
    return btn
end

-- Create Script Button
local function createScriptButton(scriptData, tabName)
    local btn = Instance.new("Frame")
    btn.Size = UDim2.new(1, -10, 0, 100)
    btn.BackgroundColor3 = C.bgLight
    btn.BorderSizePixel = 0
    btn.ZIndex = 4
    btn.Parent = scroll
    btn.Visible = false
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 12)
    btnCorner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = C.border
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = btn
    
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(0, 12, 0, 12)
    statusFrame.Position = UDim2.new(0, 15, 0, 15)
    statusFrame.BackgroundColor3 = C.gray
    statusFrame.BorderSizePixel = 0
    statusFrame.ZIndex = 5
    statusFrame.Parent = btn
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 6)
    statusCorner.Parent = statusFrame
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -140, 0, 24)
    nameLabel.Position = UDim2.new(0, 35, 0, 10)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = scriptData.name
    nameLabel.TextColor3 = C.white
    nameLabel.TextSize = 16
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 5
    nameLabel.Parent = btn
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -140, 0, 20)
    descLabel.Position = UDim2.new(0, 35, 0, 35)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = scriptData.desc
    descLabel.TextColor3 = C.gray
    descLabel.TextSize = 12
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.ZIndex = 5
    descLabel.Parent = btn
    
    local catLabel = Instance.new("TextLabel")
    catLabel.Size = UDim2.new(0, 80, 0, 22)
    catLabel.Position = UDim2.new(0, 35, 1, -32)
    catLabel.BackgroundColor3 = C.bgDark
    catLabel.Text = scriptData.category
    catLabel.TextColor3 = C.accent2
    catLabel.TextSize = 11
    catLabel.Font = Enum.Font.GothamBold
    catLabel.ZIndex = 5
    catLabel.Parent = btn
    
    local catCorner = Instance.new("UICorner")
    catCorner.CornerRadius = UDim.new(0, 6)
    catCorner.Parent = catLabel
    
    local injectBtn = Instance.new("TextButton")
    injectBtn.Size = UDim2.new(0, 90, 0, 40)
    injectBtn.Position = UDim2.new(1, -105, 0.5, -20)
    injectBtn.BackgroundColor3 = C.accent
    injectBtn.Text = "RUN"
    injectBtn.TextColor3 = C.white
    injectBtn.TextSize = 14
    injectBtn.Font = Enum.Font.GothamBlack
    injectBtn.ZIndex = 5
    injectBtn.Parent = btn
    
    local injectCorner = Instance.new("UICorner")
    injectCorner.CornerRadius = UDim.new(0, 10)
    injectCorner.Parent = injectBtn
    
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
            else
                injectBtn.Text = "ERROR"
                injectBtn.BackgroundColor3 = C.red
                task.wait(2)
                injectBtn.Text = "RUN"
                injectBtn.BackgroundColor3 = C.accent
            end
        end)
    end)
    
    buttons[scriptData.name] = {Btn = btn, Tab = tabName, IsScript = true}
    return btn
end

-- Create Morph Button
local function createMorphButton(morphData, tabName)
    local btn = Instance.new("Frame")
    btn.Size = UDim2.new(1, -10, 0, 80)
    btn.BackgroundColor3 = C.bgLight
    btn.BorderSizePixel = 0
    btn.ZIndex = 4
    btn.Parent = scroll
    btn.Visible = false
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 12)
    btnCorner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = C.border
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = btn
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -130, 0, 24)
    nameLabel.Position = UDim2.new(0, 15, 0, 12)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = morphData.name
    nameLabel.TextColor3 = C.white
    nameLabel.TextSize = 16
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 5
    nameLabel.Parent = btn
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -130, 0, 20)
    descLabel.Position = UDim2.new(0, 15, 0, 38)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = morphData.desc
    descLabel.TextColor3 = C.gray
    descLabel.TextSize = 12
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.ZIndex = 5
    descLabel.Parent = btn
    
    local morphBtn = Instance.new("TextButton")
    morphBtn.Size = UDim2.new(0, 90, 0, 40)
    morphBtn.Position = UDim2.new(1, -105, 0.5, -20)
    morphBtn.BackgroundColor3 = C.accent2
    morphBtn.Text = "MORPH"
    morphBtn.TextColor3 = C.black
    morphBtn.TextSize = 14
    morphBtn.Font = Enum.Font.GothamBlack
    morphBtn.ZIndex = 5
    morphBtn.Parent = btn
    
    local morphCorner = Instance.new("UICorner")
    morphCorner.CornerRadius = UDim.new(0, 10)
    morphCorner.Parent = morphBtn
    
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
    local btn = Instance.new("Frame")
    btn.Size = UDim2.new(1, -10, 0, 80)
    btn.BackgroundColor3 = C.bgLight
    btn.BorderSizePixel = 0
    btn.ZIndex = 4
    btn.Parent = scroll
    btn.Visible = false
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 12)
    btnCorner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = C.border
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = btn
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -130, 0, 24)
    nameLabel.Position = UDim2.new(0, 15, 0, 12)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = toolData.name
    nameLabel.TextColor3 = C.white
    nameLabel.TextSize = 16
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 5
    nameLabel.Parent = btn
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -130, 0, 20)
    descLabel.Position = UDim2.new(0, 15, 0, 38)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = toolData.desc
    descLabel.TextColor3 = C.gray
    descLabel.TextSize = 12
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.ZIndex = 5
    descLabel.Parent = btn
    
    local toolBtn = Instance.new("TextButton")
    toolBtn.Size = UDim2.new(0, 90, 0, 40)
    toolBtn.Position = UDim2.new(1, -105, 0.5, -20)
    toolBtn.BackgroundColor3 = C.accent
    toolBtn.Text = "GET"
    toolBtn.TextColor3 = C.white
    toolBtn.TextSize = 14
    toolBtn.Font = Enum.Font.GothamBlack
    toolBtn.ZIndex = 5
    toolBtn.Parent = btn
    
    local toolCorner = Instance.new("UICorner")
    toolCorner.CornerRadius = UDim.new(0, 10)
    toolCorner.Parent = toolBtn
    
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
                task.wait(2)
                toolBtn.Text = "GET"
                toolBtn.BackgroundColor3 = C.accent
            else
                toolBtn.Text = "ERROR"
                toolBtn.BackgroundColor3 = C.red
                task.wait(2)
                toolBtn.Text = "GET"
                toolBtn.BackgroundColor3 = C.accent
            end
        end)
    end)
    
    buttons[toolData.name] = {Btn = btn, Tab = tabName, IsTool = true}
    return btn
end

-- ScriptBlox Integration ( Я пытался сделать норм но получилось что хуйня не рабочая с готовыми скриптами сразу заготовленными )
local function createScriptBloxBrowser(tabName)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 500)
    container.BackgroundColor3 = C.bgLight
    container.BorderSizePixel = 0
    container.ZIndex = 4
    container.Parent = scroll
    container.Visible = false
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 16)
    containerCorner.Parent = container
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = C.border
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = container
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "🔍 СкриптБлокс"
    title.TextColor3 = C.accent
    title.TextSize = 18
    title.Font = Enum.Font.GothamBlack
    title.ZIndex = 5
    title.Parent = container
    
    -- Search Bar
    local searchFrame = Instance.new("Frame")
    searchFrame.Size = UDim2.new(1, -20, 0, 45)
    searchFrame.Position = UDim2.new(0, 10, 0, 55)
    searchFrame.BackgroundColor3 = C.bgDark
    searchFrame.BorderSizePixel = 0
    searchFrame.ZIndex = 5
    searchFrame.Parent = container
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 12)
    searchCorner.Parent = searchFrame
    
    local searchInput = Instance.new("TextBox")
    searchInput.Size = UDim2.new(1, -100, 1, 0)
    searchInput.Position = UDim2.new(0, 15, 0, 0)
    searchInput.BackgroundTransparency = 1
    searchInput.Text = ""
    searchInput.PlaceholderText = "Поиск скриптов..."
    searchInput.TextColor3 = C.white
    searchInput.PlaceholderColor3 = C.gray
    searchInput.TextSize = 14
    searchInput.Font = Enum.Font.Gotham
    searchInput.ZIndex = 6
    searchInput.Parent = searchFrame
    
    local searchBtn = Instance.new("TextButton")
    searchBtn.Size = UDim2.new(0, 80, 0, 35)
    searchBtn.Position = UDim2.new(1, -90, 0.5, -17)
    searchBtn.BackgroundColor3 = C.accent
    searchBtn.Text = "SEARCH"
    searchBtn.TextColor3 = C.white
    searchBtn.TextSize = 13
    searchBtn.Font = Enum.Font.GothamBold
    searchBtn.ZIndex = 6
    searchBtn.Parent = searchFrame
    
    local searchBtnCorner = Instance.new("UICorner")
    searchBtnCorner.CornerRadius = UDim.new(0, 8)
    searchBtnCorner.Parent = searchBtn
    
    -- Results Area
    local resultsScroll = Instance.new("ScrollingFrame")
    resultsScroll.Size = UDim2.new(1, -20, 1, -115)
    resultsScroll.Position = UDim2.new(0, 10, 0, 105)
    resultsScroll.BackgroundColor3 = C.bgDark
    resultsScroll.BorderSizePixel = 0
    resultsScroll.ScrollBarThickness = 6
    resultsScroll.ScrollBarImageColor3 = C.accent
    resultsScroll.ZIndex = 5
    resultsScroll.Parent = container
    
    local resultsCorner = Instance.new("UICorner")
    resultsCorner.CornerRadius = UDim.new(0, 12)
    resultsCorner.Parent = resultsScroll
    
    local resultsList = Instance.new("UIListLayout")
    resultsList.Padding = UDim.new(0, 10)
    resultsList.Parent = resultsScroll
    
    -- Popular Scripts 
    local popularScripts = {
        {name = "Infinite Yield", game = "Universal", url = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"},
        {name = "Synapse X", game = "Universal", url = "https://raw.githubusercontent.com/infyiff/backup/main/synapse.lua"},
        {name = "KRNL", game = "Universal", url = "https://raw.githubusercontent.com/infyiff/backup/main/krnl.lua"},
        {name = "Owl Hub", game = "Arsenal", url = "https://raw.githubusercontent.com/CriShoux/OwlHub/master/OwlHub.txt"},
        {name = "Vape V4", game = "Bedwars", url = "https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/NewMainScript.lua"},
    }
    
    local function addScriptCard(scriptInfo)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -20, 0, 90)
        card.BackgroundColor3 = C.bgLight
        card.BorderSizePixel = 0
        card.ZIndex = 6
        card.Parent = resultsScroll
        
        local cardCorner = Instance.new("UICorner")
        cardCorner.CornerRadius = UDim.new(0, 10)
        cardCorner.Parent = card
        
        local cardStroke = Instance.new("UIStroke")
        cardStroke.Color = C.border
        cardStroke.Thickness = 1
        cardStroke.Parent = card
        
        local scriptName = Instance.new("TextLabel")
        scriptName.Size = UDim2.new(1, -130, 0, 24)
        scriptName.Position = UDim2.new(0, 15, 0, 12)
        scriptName.BackgroundTransparency = 1
        scriptName.Text = scriptInfo.name
        scriptName.TextColor3 = C.white
        scriptName.TextSize = 16
        scriptName.Font = Enum.Font.GothamBold
        scriptName.TextXAlignment = Enum.TextXAlignment.Left
        scriptName.ZIndex = 7
        scriptName.Parent = card
        
        local gameLabel = Instance.new("TextLabel")
        gameLabel.Size = UDim2.new(0, 100, 0, 22)
        gameLabel.Position = UDim2.new(0, 15, 0, 38)
        gameLabel.BackgroundColor3 = C.accent
        gameLabel.Text = scriptInfo.game
        gameLabel.TextColor3 = C.white
        gameLabel.TextSize = 11
        gameLabel.Font = Enum.Font.GothamBold
        gameLabel.ZIndex = 7
        gameLabel.Parent = card
        
        local gameCorner = Instance.new("UICorner")
        gameCorner.CornerRadius = UDim.new(0, 6)
        gameCorner.Parent = gameLabel
        
        local runBtn = Instance.new("TextButton")
        runBtn.Size = UDim2.new(0, 80, 0, 36)
        runBtn.Position = UDim2.new(1, -95, 0.5, -18)
        runBtn.BackgroundColor3 = C.green
        runBtn.Text = "RUN"
        runBtn.TextColor3 = C.white
        runBtn.TextSize = 13
        runBtn.Font = Enum.Font.GothamBlack
        runBtn.ZIndex = 7
        runBtn.Parent = card
        
        local runCorner = Instance.new("UICorner")
        runCorner.CornerRadius = UDim.new(0, 8)
        runCorner.Parent = runBtn
        
        runBtn.MouseButton1Click:Connect(function()
            runBtn.Text = "..."
            runBtn.BackgroundColor3 = C.yellow
            
            task.spawn(function()
                local success = pcall(function()
                    loadstring(game:HttpGet(scriptInfo.url, true))()
                end)
                
                if success then
                    runBtn.Text = "ON"
                    runBtn.BackgroundColor3 = C.accent
                else
                    runBtn.Text = "ERR"
                    runBtn.BackgroundColor3 = C.red
                    task.wait(2)
                    runBtn.Text = "RUN"
                    runBtn.BackgroundColor3 = C.green
                end
            end)
        end)
    end
    
    -- Load popular scripts
    for _, script in pairs(popularScripts) do
        addScriptCard(script)
    end
    
    resultsScroll.CanvasSize = UDim2.new(0, 0, 0, resultsList.AbsoluteContentSize.Y + 20)
    
    buttons["ScriptBloxBrowser"] = {Btn = container, Tab = tabName, IsBrowser = true}
    return container
end

-- Create Custom Script Input 
local function createCustomScriptInput(tabName)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 450)
    container.BackgroundColor3 = C.bgLight
    container.BorderSizePixel = 0
    container.ZIndex = 4
    container.Parent = scroll
    container.Visible = false
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 16)
    containerCorner.Parent = container
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = C.border
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = container
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "⚡ Кастом скрипты"
    title.TextColor3 = C.accent
    title.TextSize = 18
    title.Font = Enum.Font.GothamBlack
    title.ZIndex = 5
    title.Parent = container
    
    -- Name Input
    local nameFrame = Instance.new("Frame")
    nameFrame.Size = UDim2.new(1, -20, 0, 40)
    nameFrame.Position = UDim2.new(0, 10, 0, 55)
    nameFrame.BackgroundColor3 = C.bgDark
    nameFrame.BorderSizePixel = 0
    nameFrame.ZIndex = 5
    nameFrame.Parent = container
    
    local nameFrameCorner = Instance.new("UICorner")
    nameFrameCorner.CornerRadius = UDim.new(0, 10)
    nameFrameCorner.Parent = nameFrame
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0, 100, 1, 0)
    nameLabel.Position = UDim2.new(0, 15, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "Name:"
    nameLabel.TextColor3 = C.gray
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.ZIndex = 6
    nameLabel.Parent = nameFrame
    
    local nameInput = Instance.new("TextBox")
    nameInput.Size = UDim2.new(1, -130, 1, 0)
    nameInput.Position = UDim2.new(0, 115, 0, 0)
    nameInput.BackgroundTransparency = 1
    nameInput.Text = "MyScript"
    nameInput.TextColor3 = C.white
    nameInput.TextSize = 14
    nameInput.Font = Enum.Font.Gotham
    nameInput.ZIndex = 6
    nameInput.Parent = nameFrame
    
    -- Code Box 
    local codeFrame = Instance.new("Frame")
    codeFrame.Size = UDim2.new(1, -20, 0, 220)
    codeFrame.Position = UDim2.new(0, 10, 0, 100)
    codeFrame.BackgroundColor3 = C.bgDark
    codeFrame.BorderSizePixel = 0
    codeFrame.ZIndex = 5
    codeFrame.Parent = container
    
    local codeFrameCorner = Instance.new("UICorner")
    codeFrameCorner.CornerRadius = UDim.new(0, 12)
    codeFrameCorner.Parent = codeFrame
    
    local codeBox = Instance.new("TextBox")
    codeBox.Size = UDim2.new(1, -20, 1, -20)
    codeBox.Position = UDim2.new(0, 10, 0, 10)
    codeBox.BackgroundTransparency = 1
    codeBox.Text = "-- Введите Lua код здесь\nprint('Hello World!')\n\n-- Пример:\n-- loadstring(game:HttpGet('URL'))()"
    codeBox.TextColor3 = C.white
    codeBox.TextSize = 13
    codeBox.Font = Enum.Font.Code
    codeBox.MultiLine = true
    codeBox.ClearTextOnFocus = false
    codeBox.TextXAlignment = Enum.TextXAlignment.Left
    codeBox.TextYAlignment = Enum.TextYAlignment.Top
    codeBox.ZIndex = 6
    codeBox.Parent = codeFrame
    
    -- Buttons Row
    local buttonsRow = Instance.new("Frame")
    buttonsRow.Size = UDim2.new(1, -20, 0, 45)
    buttonsRow.Position = UDim2.new(0, 10, 0, 330)
    buttonsRow.BackgroundTransparency = 1
    buttonsRow.ZIndex = 5
    buttonsRow.Parent = container
    
    local runBtn = Instance.new("TextButton")
    runBtn.Size = UDim2.new(0, 100, 1, 0)
    runBtn.Position = UDim2.new(0, 0, 0, 0)
    runBtn.BackgroundColor3 = C.green
    runBtn.Text = "▶ Запуск"
    runBtn.TextColor3 = C.white
    runBtn.TextSize = 14
    runBtn.Font = Enum.Font.GothamBlack
    runBtn.ZIndex = 6
    runBtn.Parent = buttonsRow
    
    local runBtnCorner = Instance.new("UICorner")
    runBtnCorner.CornerRadius = UDim.new(0, 10)
    runBtnCorner.Parent = runBtn
    
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0, 100, 1, 0)
    saveBtn.Position = UDim2.new(0, 110, 0, 0)
    saveBtn.BackgroundColor3 = C.accent
    saveBtn.Text = "💾 Сохранение"
    saveBtn.TextColor3 = C.white
    saveBtn.TextSize = 14
    saveBtn.Font = Enum.Font.GothamBlack
    saveBtn.ZIndex = 6
    saveBtn.Parent = buttonsRow
    
    local saveBtnCorner = Instance.new("UICorner")
    saveBtnCorner.CornerRadius = UDim.new(0, 10)
    saveBtnCorner.Parent = saveBtn
    
    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0, 100, 1, 0)
    clearBtn.Position = UDim2.new(0, 220, 0, 0)
    clearBtn.BackgroundColor3 = C.red
    clearBtn.Text = "🗑 Очистить"
    clearBtn.TextColor3 = C.white
    clearBtn.TextSize = 14
    clearBtn.Font = Enum.Font.GothamBlack
    clearBtn.ZIndex = 6
    clearBtn.Parent = buttonsRow
    
    local clearBtnCorner = Instance.new("UICorner")
    clearBtnCorner.CornerRadius = UDim.new(0, 10)
    clearBtnCorner.Parent = clearBtn
    
    -- Saved Scripts Section
    local savedTitle = Instance.new("TextLabel")
    savedTitle.Size = UDim2.new(1, -20, 0, 25)
    savedTitle.Position = UDim2.new(0, 10, 0, 385)
    savedTitle.BackgroundTransparency = 1
    savedTitle.Text = "📁 Сохраненные скрипты:"
    savedTitle.TextColor3 = C.gray
    savedTitle.TextSize = 13
    savedTitle.Font = Enum.Font.GothamBold
    savedTitle.ZIndex = 5
    savedTitle.Parent = container
    
    local savedList = Instance.new("ScrollingFrame")
    savedList.Size = UDim2.new(1, -20, 0, 70)
    savedList.Position = UDim2.new(0, 10, 0, 410)
    savedList.BackgroundColor3 = C.bgDark
    savedList.BorderSizePixel = 0
    savedList.ScrollBarThickness = 4
    savedList.ZIndex = 5
    savedList.Parent = container
    
    local savedListCorner = Instance.new("UICorner")
    savedListCorner.CornerRadius = UDim.new(0, 10)
    savedListCorner.Parent = savedList
    
    local savedListLayout = Instance.new("UIListLayout")
    savedListLayout.Padding = UDim.new(0, 8)
    savedListLayout.Parent = savedList
    
    local function updateSavedList()
        for _, child in pairs(savedList:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        for name, code in pairs(savedScripts) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 35)
            btn.BackgroundColor3 = C.bgLight
            btn.Text = "📄 " .. name
            btn.TextColor3 = C.white
            btn.TextSize = 13
            btn.Font = Enum.Font.Gotham
            btn.ZIndex = 6
            btn.Parent = savedList
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 8)
            btnCorner.Parent = btn
            
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
                    Title = "✅ Успешно",
                    Text = "Script executed successfully!",
                    Duration = 3
                })
            else
                StarterGui:SetCore("SendNotification", {
                    Title = "❌ Ошибка",
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
                Title = "💾 Сохранено",
                Text = "Script '" .. name .. "' saved!",
                Duration = 2
            })
        end
    end)
    
    clearBtn.MouseButton1Click:Connect(function()
        codeBox.Text = "-- Введите Lua код здесь\n"
        nameInput.Text = "MyScript"
    end)
    
    buttons["CustomScriptExecutor"] = {Btn = container, Tab = tabName, IsInput = true}
    return container
end

-- TABS 
createTab("Движение", "🏃")
createTab("Бой", "⚔️")
createTab("Игрок", "👤")
createTab("Визуал", "👁️")
createTab("Мир", "🌍")
createTab("Морфы", "🎭")
createTab("Развлечения", "🎮")
createTab("Скрипты", "📜")
createTab("ScriptBlox", "🌐")
createTab("Custom Chat", "💬")
createTab("Tools", "🛠️")
createTab("Executor", "⚡")
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
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel - Vector3.new(0, 1, 0) end
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
                    ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("SEAL HUB V18 🦭", "All")
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

-- СКРИПТЫ
for _, script in pairs(ScriptLibrary) do createScriptButton(script, "Скрипты") end

-- SCRIPTBLOX BROWSER 
createScriptBloxBrowser("ScriptBlox")

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

local chatCorner = Instance.new("UICorner")
chatCorner.CornerRadius = UDim.new(0, 16)
chatCorner.Parent = chatFrame

local chatTitle = Instance.new("TextLabel")
chatTitle.Size = UDim2.new(1, 0, 0, 45)
chatTitle.BackgroundColor3 = C.bgLight
chatTitle.Text = "💬 CUSTOM CHAT"
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

local chatScrollCorner = Instance.new("UICorner")
chatScrollCorner.CornerRadius = UDim.new(0, 10)
chatScrollCorner.Parent = chatScroll

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

local chatInputCorner = Instance.new("UICorner")
chatInputCorner.CornerRadius = UDim.new(0, 8)
chatInputCorner.Parent = chatInput

local chatSend = Instance.new("TextButton")
chatSend.Size = UDim2.new(0, 80, 0, 40)
chatSend.Position = UDim2.new(1, -90, 1, -50)
chatSend.BackgroundColor3 = C.accent
chatSend.Text = "SEND"
chatSend.TextColor3 = C.white
chatSend.TextSize = 14
chatSend.Font = Enum.Font.GothamBlack
chatSend.ZIndex = 51
chatSend.Parent = chatFrame

local chatSendCorner = Instance.new("UICorner")
chatSendCorner.CornerRadius = UDim.new(0, 8)
chatSendCorner.Parent = chatSend

local function addMsg(user, msg)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -10, 0, 55)
    f.BackgroundColor3 = C.bgLight
    f.BorderSizePixel = 0
    f.ZIndex = 52
    f.Parent = chatScroll
    
    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(0, 8)
    fCorner.Parent = f
    
    local u = Instance.new("TextLabel")
    u.Size = UDim2.new(0, 120, 0, 20)
    u.Position = UDim2.new(0, 10, 0, 5)
    u.BackgroundTransparency = 1
    u.Text = user
    u.TextColor3 = C.accent
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

-- EXECUTOR
createCustomScriptInput("Executor")

-- НАСТРОЙКИ
createButton("Сохранить конфиг", "Настройки", function(a)
    local cfg = {binds = binds, settings = S, savedScripts = savedScripts}
    local s = pcall(function()
        local j = HttpService:JSONEncode(cfg)
        print("CFG:", j)
    end)
    if s then
        StarterGui:SetCore("SendNotification", {Title = "CFG", Text = "Сохранено", Duration = 2})
    end
end, false, "Сохранить настройки")

createButton("Загрузить конфиг", "Настройки", function(a)
    StarterGui:SetCore("SendNotification", {Title = "CFG", Text = "Загружено", Duration = 2})
end, false, "Загрузить настройки")

createButton("Сбросить все", "Настройки", function(a)
    for k, v in pairs(S) do if type(v) == "boolean" then S[k] = false end end
    for _, btn in pairs(buttons) do if btn.Set and btn.IsToggle then btn.Set(false) end end
    for _, conn in pairs(loopConnections) do conn:Disconnect() end
    loopConnections = {}
    StarterGui:SetCore("SendNotification", {Title = "CFG", Text = "Все сброшено", Duration = 2})
end, false, "Отключить все")

createButton("Убить скрипт", "Настройки", function(a)
    screen:Destroy()
    customChatGui:Destroy()
    StarterGui:SetCore("SendNotification", {Title = "BYE", Text = "Выключено", Duration = 2})
end, false, "Выключить хаб")

createButton("Скрыть UI", "Настройки", function(a)
    main.Visible = false
    menuOpen = false
    openBtn.Visible = true
end, false, "Свернуть")

-- Functions
local function toggleMenu()
    menuOpen = not menuOpen
    main.Visible = menuOpen
    if menuOpen then
        main.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 900, 0, 600)}):Play()
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
        TweenService:Create(keyFrame, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -200, -1, -160)}):Play()
        task.wait(0.5)
        keyFrame:Destroy()
        main.Visible = true
        openBtn.Visible = true
        StarterGui:SetCore("SendNotification", {Title = "🦭 SEAL HUB", Text = "Добро пожаловать в SealHub | от хсе!", Duration = 3})
    else
        keyStatus.Text = "❌ Тюлень говорит что ключ неверный"
        keyInput.Text = ""
        TweenService:Create(keyInput, TweenInfo.new(0.1), {Position = UDim2.new(0.5, -165, 0.5, -27)}):Play()
        task.wait(0.05)
        TweenService:Create(keyInput, TweenInfo.new(0.1), {Position = UDim2.new(0.5, -155, 0.5, -27)}):Play()
        task.wait(0.05)
        TweenService:Create(keyInput, TweenInfo.new(0.1), {Position = UDim2.new(0.5, -160, 0.5, -27)}):Play()
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

-- Инициализация первой вкладки
local firstTab = tabs[1]
if firstTab then
    firstTab.HL.Visible = true
    TweenService:Create(firstTab.Btn, TweenInfo.new(0.2), {BackgroundColor3 = C.bgLight}):Play()
    firstTab.Icon.TextColor3 = C.accent
    firstTab.Name.TextColor3 = C.white
end

for _, btn in pairs(buttons) do
    if btn.Tab == currentTab then
        btn.Btn.Visible = true
    end
end
scroll.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 20)
