--[[
    SEAL HUB V4 | by @hszzo
    Тюлень хсе всегда на высоте
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
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse = player:GetMouse()

repeat task.wait() until player.Character
local character = player.Character
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

local SEAL_FOLDER = "seal_hub_v4"
local CONFIG_FILE = SEAL_FOLDER .. "/config.json"
local SCRIPTS_FOLDER = SEAL_FOLDER .. "/saved_scripts"

local function ensureFolder(path)
    if not isfolder(path) then makefolder(path) end
end

local function saveConfig(data)
    ensureFolder(SEAL_FOLDER)
    writefile(CONFIG_FILE, HttpService:JSONEncode(data))
end

local function loadConfig()
    if isfile(CONFIG_FILE) then
        local s, r = pcall(function()
            return HttpService:JSONDecode(readfile(CONFIG_FILE))
        end)
        if s then return r end
    end
    return nil
end

local savedConfig = loadConfig() or {}

local C = {
    bg = savedConfig.bg or Color3.fromRGB(13, 13, 18),
    bgLight = savedConfig.bgLight or Color3.fromRGB(22, 22, 30),
    bgDark = savedConfig.bgDark or Color3.fromRGB(8, 8, 12),
    accent = savedConfig.accent or Color3.fromRGB(124, 58, 237),
    accent2 = savedConfig.accent2 or Color3.fromRGB(167, 139, 250),
    green = Color3.fromRGB(34, 197, 94),
    red = Color3.fromRGB(239, 68, 68),
    yellow = Color3.fromRGB(234, 179, 8),
    white = Color3.fromRGB(248, 248, 248),
    gray = Color3.fromRGB(148, 163, 184),
    black = Color3.fromRGB(2, 2, 4),
    border = savedConfig.border or Color3.fromRGB(30, 30, 45),
    hover = savedConfig.hover or Color3.fromRGB(30, 30, 42),
    text = savedConfig.text or Color3.fromRGB(226, 232, 240)
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

for k, v in pairs(savedConfig.settings or {}) do
    if S[k] ~= nil then S[k] = v end
end

local espObjects = {}
local loopConnections = {}
local frameCounter = 0
local FRAME_SKIP = 2
local binds = savedConfig.binds or {}
local savedScripts = savedConfig.savedScripts or {}
local currentTab = "Движение"
local menuOpen = false
local waitingBind = nil
local injectCount = savedConfig.injectCount or 0
local sealUsers = {}

local function checkKey(input)
    return input == "hsz"
end

local ScriptLibrary = {
    {name = "Infinite Yield", url = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", desc = "Лучший админ скрипт", category = "Админ"},
    {name = "CMD-X", url = "https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source", desc = "Мощная консоль", category = "Админ"},
    {name = "Reviz Admin", url = "https://raw.githubusercontent.com/revizadmin/reviz/master/source.lua", desc = "Админ команды", category = "Админ"},
    {name = "Dex Explorer", url = "https://raw.githubusercontent.com/infyiff/backup/main/dex.lua", desc = "Проводник игры", category = "Утилиты"},
    {name = "SimpleSpy V3", url = "https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua", desc = "Сниффер", category = "Утилиты"},
    {name = "System Broken", url = "https://raw.githubusercontent.com/H20CalibreYT/SystemBroken/main/script", desc = "Флай, спид, телепорт", category = "Движение"},
    {name = "Telekinesis V5", url = "https://rawscripts.net/raw/Universal-Script-Fe-Telekinesis-V5-21542", desc = "Телекинез", category = "Физика"},
    {name = "Ultimate Trolling GUI", url = "https://rawscripts.net/raw/Universal-Script-ULTIMATE-TROLLING-GUI-V5-39695", desc = "Троллинг", category = "Троллинг"},
    {name = "MNA Hub", url = "https://rawscripts.net/raw/Universal-Script-MNAHub-CMD-The-best-Commands-hub-for-Xeno-242412", desc = "Лучший CMD хаб для Xeno", category = "Админ"},
    {name = "Build A Boat Ultimate", url = "https://rawscripts.net/raw/Build-A-Boat-For-Treasure-Ultimte-B3BFT-Script-28601", desc = "Для Build A Boat", category = "Игры"},
    {name = "Super Ring V4", url = "https://rawscripts.net/raw/Natural-Disaster-Survival-Super-ring-V4-24296", desc = "Летающие блоки в Disaster", category = "Игры"},
    {name = "God Mode Script", url = "https://raw.githubusercontent.com/miglels33/God-Mode-Script/refs/heads/main/GodModeScript.md", desc = "Бессмертие", category = "Игрок"},
    {name = "Invincible Flight", url = "https://rawscripts.net/raw/Universal-Script-Invinicible-Flight-R15-45414", desc = "Летать как супергерой", category = "Движение"},
    {name = "Fling Things V2", url = "https://rawscripts.net/raw/Fling-Things-and-People-V2-62163", desc = "Бросать вещи и людей", category = "Физика"},
    {name = "Lalol Hub", url = "https://rawscripts.net/raw/Universal-Script-Lalol-hub-30354", desc = "Бэкдор скрипт", category = "Админ"},
    {name = "Project Ham", url = "https://pastebin.com/raw/KSvbtcPE", desc = "Крутой универсальный скрипт", category = "Универсал"},
    {name = "FE SCP-096", url = "https://rawscripts.net/raw/Universal-Script-FE-SCP-096-36948", desc = "Скромник SCP", category = "Морфы"},
    {name = "Murder Mystery", url = "https://globalexp.xyz/", desc = "Мурдер Мистери скрипт", category = "Игры"},
    {name = "Murder Mystery Aimbot", url = "https://globalexp.xyz/aimbotkey", desc = "Аимбот для MM2", category = "Игры"}
}

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

local ToolsLibrary = {
    {name = "Jerk", desc = "Анимация", script = [[loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Jerk-Off-R15-Animation-FE-20074"))()]]},
    {name = "Orbit", desc = "Вращение", script = [[loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Orbit-Players-20077"))()]]},
    {name = "Fling", desc = "Кидать игроков", script = [[loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-FE-Fling-20076"))()]]},
    {name = "Freecam", desc = "Свободная камера", script = [[loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Freecam-20078"))()]]},
    {name = "Bring", desc = "Притягивать", script = [[loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Bring-Players-20087"))()]]},
}

local screen = Instance.new("ScreenGui")
screen.Name = "SealHubV4"
screen.ResetOnSpawn = false
screen.ZIndexBehavior = Enum.ZIndexBehavior.Global
screen.Parent = CoreGui

local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting

local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(0, 420, 0, 340)
keyFrame.Position = UDim2.new(0.5, -210, 0.5, -170)
keyFrame.BackgroundColor3 = C.bg
keyFrame.BorderSizePixel = 0
keyFrame.ZIndex = 100
keyFrame.Parent = screen

local keyCorner = Instance.new("UICorner")
keyCorner.CornerRadius = UDim.new(0, 20)
keyCorner.Parent = keyFrame

local keyStroke = Instance.new("UIStroke")
keyStroke.Color = C.border
keyStroke.Thickness = 1.5
keyStroke.Parent = keyFrame

local keyGlow = Instance.new("Frame")
keyGlow.Size = UDim2.new(1, 0, 0, 2)
keyGlow.Position = UDim2.new(0, 0, 0, 0)
keyGlow.BackgroundColor3 = C.accent
keyGlow.BorderSizePixel = 0
keyGlow.ZIndex = 101
keyGlow.Parent = keyFrame

local keyGlowCorner = Instance.new("UICorner")
keyGlowCorner.CornerRadius = UDim.new(0, 20)
keyGlowCorner.Parent = keyGlow

local keyTitle = Instance.new("TextLabel")
keyTitle.Size = UDim2.new(1, 0, 0, 50)
keyTitle.Position = UDim2.new(0, 0, 0, 30)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = "SEAL HUB"
keyTitle.TextColor3 = C.white
keyTitle.TextSize = 42
keyTitle.Font = Enum.Font.GothamBlack
keyTitle.ZIndex = 101
keyTitle.Parent = keyFrame

local keySub = Instance.new("TextLabel")
keySub.Size = UDim2.new(1, 0, 0, 22)
keySub.Position = UDim2.new(0, 0, 0, 78)
keySub.BackgroundTransparency = 1
keySub.Text = "by hszzo | тюлень хсе"
keySub.TextColor3 = C.accent2
keySub.TextSize = 14
keySub.Font = Enum.Font.GothamBold
keySub.ZIndex = 101
keySub.Parent = keyFrame

local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(0, 340, 0, 52)
keyInput.Position = UDim2.new(0.5, -170, 0.5, -26)
keyInput.BackgroundColor3 = C.bgDark
keyInput.Text = ""
keyInput.PlaceholderText = "введи ключ..."
keyInput.TextColor3 = C.white
keyInput.PlaceholderColor3 = C.gray
keyInput.TextSize = 16
keyInput.Font = Enum.Font.GothamBold
keyInput.ClearTextOnFocus = true
keyInput.ZIndex = 101
keyInput.Parent = keyFrame

local keyInputCorner = Instance.new("UICorner")
keyInputCorner.CornerRadius = UDim.new(0, 12)
keyInputCorner.Parent = keyInput

local keyInputStroke = Instance.new("UIStroke")
keyInputStroke.Color = C.border
keyInputStroke.Thickness = 2
keyInputStroke.Parent = keyInput

local keyButton = Instance.new("TextButton")
keyButton.Size = UDim2.new(0, 340, 0, 50)
keyButton.Position = UDim2.new(0.5, -170, 0.75, 0)
keyButton.BackgroundColor3 = C.accent
keyButton.Text = "ВОЙТИ"
keyButton.TextColor3 = C.white
keyButton.TextSize = 16
keyButton.Font = Enum.Font.GothamBlack
keyButton.ZIndex = 101
keyButton.Parent = keyFrame

local keyButtonCorner = Instance.new("UICorner")
keyButtonCorner.CornerRadius = UDim.new(0, 12)
keyButtonCorner.Parent = keyButton

local keyStatus = Instance.new("TextLabel")
keyStatus.Size = UDim2.new(1, 0, 0, 22)
keyStatus.Position = UDim2.new(0, 0, 1, -35)
keyStatus.BackgroundTransparency = 1
keyStatus.Text = ""
keyStatus.TextColor3 = C.red
keyStatus.TextSize = 13
keyStatus.Font = Enum.Font.GothamBold
keyStatus.ZIndex = 101
keyStatus.Parent = keyFrame

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 950, 0, 620)
main.Position = UDim2.new(0.5, -475, 0.5, -310)
main.BackgroundColor3 = C.bg
main.BorderSizePixel = 0
main.Visible = false
main.Active = true
main.ClipsDescendants = true
main.Parent = screen

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = C.border
mainStroke.Thickness = 1
mainStroke.Parent = main

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 65)
titleBar.BackgroundColor3 = C.bgLight
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 2
titleBar.Parent = main

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 16)
titleCorner.Parent = titleBar

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 20)
titleFix.Position = UDim2.new(0, 0, 1, -20)
titleFix.BackgroundColor3 = C.bgLight
titleFix.BorderSizePixel = 0
titleFix.ZIndex = 2
titleFix.Parent = titleBar

local avatarFrame = Instance.new("Frame")
avatarFrame.Size = UDim2.new(0, 44, 0, 44)
avatarFrame.Position = UDim2.new(0, 16, 0, 10)
avatarFrame.BackgroundColor3 = C.bgDark
avatarFrame.BorderSizePixel = 0
avatarFrame.ZIndex = 3
avatarFrame.Parent = titleBar

local avatarCorner = Instance.new("UICorner")
avatarCorner.CornerRadius = UDim.new(1, 0)
avatarCorner.Parent = avatarFrame

local avatarImg = Instance.new("ImageLabel")
avatarImg.Size = UDim2.new(1, -4, 1, -4)
avatarImg.Position = UDim2.new(0, 2, 0, 2)
avatarImg.BackgroundTransparency = 1
avatarImg.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png"
avatarImg.ZIndex = 4
avatarImg.Parent = avatarFrame

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0, 250, 0, 26)
titleText.Position = UDim2.new(0, 72, 0, 10)
titleText.BackgroundTransparency = 1
titleText.Text = "SealHub"
titleText.TextColor3 = C.white
titleText.TextSize = 22
titleText.Font = Enum.Font.GothamBlack
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.ZIndex = 3
titleText.Parent = titleBar

local titleUser = Instance.new("TextLabel")
titleUser.Size = UDim2.new(0, 250, 0, 18)
titleUser.Position = UDim2.new(0, 72, 0, 36)
titleUser.BackgroundTransparency = 1
titleUser.Text = "@" .. player.Name
titleUser.TextColor3 = C.gray
titleUser.TextSize = 12
titleUser.Font = Enum.Font.GothamBold
titleUser.TextXAlignment = Enum.TextXAlignment.Left
titleUser.ZIndex = 3
titleUser.Parent = titleBar

local titleVer = Instance.new("TextLabel")
titleVer.Size = UDim2.new(0, 40, 0, 20)
titleVer.Position = UDim2.new(0, 72, 0, 52)
titleVer.BackgroundTransparency = 1
titleVer.Text = "v4.0"
titleVer.TextColor3 = C.accent
titleVer.TextSize = 11
titleVer.Font = Enum.Font.GothamBold
titleVer.TextXAlignment = Enum.TextXAlignment.Left
titleVer.ZIndex = 3
titleVer.Parent = titleBar

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0, 75, 0, 28)
fpsLabel.Position = UDim2.new(1, -300, 0, 18)
fpsLabel.BackgroundColor3 = C.bgDark
fpsLabel.Text = "60 FPS"
fpsLabel.TextColor3 = C.green
fpsLabel.TextSize = 12
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.ZIndex = 3
fpsLabel.Parent = titleBar

local fpsCorner = Instance.new("UICorner")
fpsCorner.CornerRadius = UDim.new(0, 8)
fpsCorner.Parent = fpsLabel

local pingLabel = Instance.new("TextLabel")
pingLabel.Size = UDim2.new(0, 75, 0, 28)
pingLabel.Position = UDim2.new(1, -220, 0, 18)
pingLabel.BackgroundColor3 = C.bgDark
pingLabel.Text = "0 ms"
pingLabel.TextColor3 = C.accent2
pingLabel.TextSize = 12
pingLabel.Font = Enum.Font.GothamBold
pingLabel.ZIndex = 3
pingLabel.Parent = titleBar

local pingCorner = Instance.new("UICorner")
pingCorner.CornerRadius = UDim.new(0, 8)
pingCorner.Parent = pingLabel

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 36, 0, 32)
minBtn.Position = UDim2.new(1, -130, 0, 16)
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
closeBtn.Size = UDim2.new(0, 36, 0, 32)
closeBtn.Position = UDim2.new(1, -85, 0, 16)
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

local tabPanel = Instance.new("ScrollingFrame")
tabPanel.Size = UDim2.new(0, 210, 1, -65)
tabPanel.Position = UDim2.new(0, 0, 0, 65)
tabPanel.BackgroundColor3 = C.bgDark
tabPanel.BorderSizePixel = 0
tabPanel.ZIndex = 2
tabPanel.ScrollBarThickness = 3
tabPanel.ScrollBarImageColor3 = C.accent
tabPanel.CanvasSize = UDim2.new(0, 0, 0, 800)
tabPanel.Parent = main

local tabPanelCorner = Instance.new("UICorner")
tabPanelCorner.CornerRadius = UDim.new(0, 0)
tabPanelCorner.Parent = tabPanel

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -210, 1, -65)
content.Position = UDim2.new(0, 210, 0, 65)
content.BackgroundColor3 = C.bg
content.BorderSizePixel = 0
content.ZIndex = 2
content.Parent = main

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -24, 1, -20)
scroll.Position = UDim2.new(0, 12, 0, 10)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 5
scroll.ScrollBarImageColor3 = C.accent
scroll.ZIndex = 3
scroll.Parent = content

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 10)
list.Parent = scroll

local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 55, 0, 55)
openBtn.Position = savedConfig.openBtnPos or UDim2.new(1, -75, 0.5, -27)
openBtn.BackgroundColor3 = C.accent
openBtn.Text = ""
openBtn.ZIndex = 10
openBtn.Parent = screen
openBtn.Visible = false

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 14)
openCorner.Parent = openBtn

local openStroke = Instance.new("UIStroke")
openStroke.Color = C.white
openStroke.Thickness = 2
openStroke.Transparency = 0.4
openStroke.Parent = openBtn

local openIcon = Instance.new("ImageLabel")
openIcon.Size = UDim2.new(0, 28, 0, 28)
openIcon.Position = UDim2.new(0.5, -14, 0.5, -14)
openIcon.BackgroundTransparency = 1
openIcon.Image = "rbxassetid://6034684937"
openIcon.ImageColor3 = C.white
openIcon.ZIndex = 11
openIcon.Parent = openBtn

local tabs = {}
local buttons = {}

local function makeDraggable(frame, handle)
    local dragging = false
    local dragStart, startPos
    handle = handle or frame
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            if frame == openBtn then
                saveConfig({
                    settings = S,
                    binds = binds,
                    savedScripts = savedScripts,
                    injectCount = injectCount,
                    openBtnPos = frame.Position,
                    bg = C.bg,
                    bgLight = C.bgLight,
                    bgDark = C.bgDark,
                    accent = C.accent,
                    accent2 = C.accent2,
                    border = C.border,
                    hover = C.hover,
                    text = C.text
                })
            end
        end
    end)
end

local function createTab(name, icon)
    local tab = Instance.new("TextButton")
    tab.Name = name
    tab.Size = UDim2.new(1, -16, 0, 46)
    tab.Position = UDim2.new(0, 8, 0, #tabs * 52)
    tab.BackgroundColor3 = C.bg
    tab.BorderSizePixel = 0
    tab.AutoButtonColor = false
    tab.Text = ""
    tab.ZIndex = 3
    tab.Parent = tabPanel
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 10)
    tabCorner.Parent = tab
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 36, 1, 0)
    iconLabel.Position = UDim2.new(0, 12, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextColor3 = C.gray
    iconLabel.TextSize = 18
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.ZIndex = 4
    iconLabel.Parent = tab
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -60, 1, 0)
    nameLabel.Position = UDim2.new(0, 50, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = C.gray
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 4
    nameLabel.Parent = tab
    
    local highlight = Instance.new("Frame")
    highlight.Size = UDim2.new(0, 3, 0.5, 0)
    highlight.Position = UDim2.new(0, 0, 0.25, 0)
    highlight.BackgroundColor3 = C.accent
    highlight.BorderSizePixel = 0
    highlight.Visible = false
    highlight.ZIndex = 5
    highlight.Parent = tab
    
    tab.MouseEnter:Connect(function()
        if currentTab ~= name then
            TweenService:Create(tab, TweenInfo.new(0.15), {BackgroundColor3 = C.hover}):Play()
        end
    end)
    
    tab.MouseLeave:Connect(function()
        if currentTab ~= name then
            TweenService:Create(tab, TweenInfo.new(0.15), {BackgroundColor3 = C.bg}):Play()
        end
    end)
    
    tab.MouseButton1Click:Connect(function()
        if tabs[currentTab] then
            tabs[currentTab].HL.Visible = false
            TweenService:Create(tabs[currentTab].Btn, TweenInfo.new(0.15), {BackgroundColor3 = C.bg}):Play()
            tabs[currentTab].Icon.TextColor3 = C.gray
            tabs[currentTab].Name.TextColor3 = C.gray
        end
        
        currentTab = name
        highlight.Visible = true
        TweenService:Create(tab, TweenInfo.new(0.15), {BackgroundColor3 = C.bgLight}):Play()
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

local function createButton(name, tabName, callback, isToggle, desc)
    local btn = Instance.new("Frame")
    btn.Name = name
    btn.Size = UDim2.new(1, -10, 0, desc and 80 or 68)
    btn.BackgroundColor3 = C.bgLight
    btn.BorderSizePixel = 0
    btn.ZIndex = 4
    btn.Parent = scroll
    btn.Visible = false
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = C.border
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    stroke.Parent = btn
    
    local clickArea = Instance.new("TextButton")
    clickArea.Size = UDim2.new(1, -130, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.ZIndex = 5
    clickArea.Parent = btn
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 48, 0, 26)
    toggleFrame.Position = UDim2.new(0, 14, 0, desc and 24 or 21)
    toggleFrame.BackgroundColor3 = C.bgDark
    toggleFrame.BorderSizePixel = 0
    toggleFrame.ZIndex = 5
    toggleFrame.Parent = btn
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 13)
    toggleCorner.Parent = toggleFrame
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 20, 0, 20)
    toggleCircle.Position = UDim2.new(0, 3, 0.5, -10)
    toggleCircle.BackgroundColor3 = C.gray
    toggleCircle.BorderSizePixel = 0
    toggleCircle.ZIndex = 6
    toggleCircle.Parent = toggleFrame
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(0, 10)
    circleCorner.Parent = toggleCircle
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -170, 0, 22)
    label.Position = UDim2.new(0, 70, 0, desc and 12 or 23)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = C.white
    label.TextSize = 15
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 5
    label.Parent = btn
    
    if desc then
        local descLabel = Instance.new("TextLabel")
        descLabel.Size = UDim2.new(1, -170, 0, 20)
        descLabel.Position = UDim2.new(0, 70, 0, 38)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = desc
        descLabel.TextColor3 = C.gray
        descLabel.TextSize = 11
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.ZIndex = 5
        descLabel.Parent = btn
    end
    
    local bindBtn = Instance.new("TextButton")
    bindBtn.Size = UDim2.new(0, 65, 0, 30)
    bindBtn.Position = UDim2.new(1, -78, 0.5, -15)
    bindBtn.BackgroundColor3 = C.bgDark
    bindBtn.Text = "BIND"
    bindBtn.TextColor3 = C.gray
    bindBtn.TextSize = 11
    bindBtn.Font = Enum.Font.GothamBold
    bindBtn.ZIndex = 5
    bindBtn.Parent = btn
    
    local bindCorner = Instance.new("UICorner")
    bindCorner.CornerRadius = UDim.new(0, 6)
    bindCorner.Parent = bindBtn
    
    local active = false
    
    local function updateVisuals()
        if active then
            TweenService:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = C.accent}):Play()
            TweenService:Create(toggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 25, 0.5, -10), BackgroundColor3 = C.white}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.2), {Color = C.accent, Transparency = 0}):Play()
        else
            TweenService:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = C.bgDark}):Play()
            TweenService:Create(toggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -10), BackgroundColor3 = C.gray}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.2), {Color = C.border, Transparency = 0.6}):Play()
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
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = C.hover}):Play()
        end
    end)
    
    btn.MouseLeave:Connect(function()
        if not active then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = C.bgLight}):Play()
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

local function createScriptButton(scriptData, tabName)
    local btn = Instance.new("Frame")
    btn.Size = UDim2.new(1, -10, 0, 95)
    btn.BackgroundColor3 = C.bgLight
    btn.BorderSizePixel = 0
    btn.ZIndex = 4
    btn.Parent = scroll
    btn.Visible = false
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = C.border
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    stroke.Parent = btn
    
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(0, 10, 0, 10)
    statusFrame.Position = UDim2.new(0, 14, 0, 14)
    statusFrame.BackgroundColor3 = C.gray
    statusFrame.BorderSizePixel = 0
    statusFrame.ZIndex = 5
    statusFrame.Parent = btn
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 5)
    statusCorner.Parent = statusFrame
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -140, 0, 22)
    nameLabel.Position = UDim2.new(0, 32, 0, 10)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = scriptData.name
    nameLabel.TextColor3 = C.white
    nameLabel.TextSize = 15
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 5
    nameLabel.Parent = btn
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -140, 0, 18)
    descLabel.Position = UDim2.new(0, 32, 0, 32)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = scriptData.desc
    descLabel.TextColor3 = C.gray
    descLabel.TextSize = 11
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.ZIndex = 5
    descLabel.Parent = btn
    
    local catLabel = Instance.new("TextLabel")
    catLabel.Size = UDim2.new(0, 70, 0, 20)
    catLabel.Position = UDim2.new(0, 32, 1, -30)
    catLabel.BackgroundColor3 = C.bgDark
    catLabel.Text = scriptData.category
    catLabel.TextColor3 = C.accent2
    catLabel.TextSize = 10
    catLabel.Font = Enum.Font.GothamBold
    catLabel.ZIndex = 5
    catLabel.Parent = btn
    
    local catCorner = Instance.new("UICorner")
    catCorner.CornerRadius = UDim.new(0, 5)
    catCorner.Parent = catLabel
    
    local injectBtn = Instance.new("TextButton")
    injectBtn.Size = UDim2.new(0, 85, 0, 36)
    injectBtn.Position = UDim2.new(1, -100, 0.5, -18)
    injectBtn.BackgroundColor3 = C.accent
    injectBtn.Text = "RUN"
    injectBtn.TextColor3 = C.white
    injectBtn.TextSize = 13
    injectBtn.Font = Enum.Font.GothamBlack
    injectBtn.ZIndex = 5
    injectBtn.Parent = btn
    
    local injectCorner = Instance.new("UICorner")
    injectCorner.CornerRadius = UDim.new(0, 8)
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

local function createMorphButton(morphData, tabName)
    local btn = Instance.new("Frame")
    btn.Size = UDim2.new(1, -10, 0, 75)
    btn.BackgroundColor3 = C.bgLight
    btn.BorderSizePixel = 0
    btn.ZIndex = 4
    btn.Parent = scroll
    btn.Visible = false
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = C.border
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    stroke.Parent = btn
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -120, 0, 22)
    nameLabel.Position = UDim2.new(0, 14, 0, 10)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = morphData.name
    nameLabel.TextColor3 = C.white
    nameLabel.TextSize = 15
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 5
    nameLabel.Parent = btn
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -120, 0, 18)
    descLabel.Position = UDim2.new(0, 14, 0, 34)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = morphData.desc
    descLabel.TextColor3 = C.gray
    descLabel.TextSize = 11
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.ZIndex = 5
    descLabel.Parent = btn
    
    local morphBtn = Instance.new("TextButton")
    morphBtn.Size = UDim2.new(0, 85, 0, 36)
    morphBtn.Position = UDim2.new(1, -100, 0.5, -18)
    morphBtn.BackgroundColor3 = C.accent2
    morphBtn.Text = "MORPH"
    morphBtn.TextColor3 = C.black
    morphBtn.TextSize = 13
    morphBtn.Font = Enum.Font.GothamBlack
    morphBtn.ZIndex = 5
    morphBtn.Parent = btn
    
    local morphCorner = Instance.new("UICorner")
    morphCorner.CornerRadius = UDim.new(0, 8)
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

local function createToolButton(toolData, tabName)
    local btn = Instance.new("Frame")
    btn.Size = UDim2.new(1, -10, 0, 75)
    btn.BackgroundColor3 = C.bgLight
    btn.BorderSizePixel = 0
    btn.ZIndex = 4
    btn.Parent = scroll
    btn.Visible = false
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = C.border
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    stroke.Parent = btn
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -120, 0, 22)
    nameLabel.Position = UDim2.new(0, 14, 0, 10)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = toolData.name
    nameLabel.TextColor3 = C.white
    nameLabel.TextSize = 15
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 5
    nameLabel.Parent = btn
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -120, 0, 18)
    descLabel.Position = UDim2.new(0, 14, 0, 34)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = toolData.desc
    descLabel.TextColor3 = C.gray
    descLabel.TextSize = 11
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.ZIndex = 5
    descLabel.Parent = btn
    
    local toolBtn = Instance.new("TextButton")
    toolBtn.Size = UDim2.new(0, 85, 0, 36)
    toolBtn.Position = UDim2.new(1, -100, 0.5, -18)
    toolBtn.BackgroundColor3 = C.accent
    toolBtn.Text = "GET"
    toolBtn.TextColor3 = C.white
    toolBtn.TextSize = 13
    toolBtn.Font = Enum.Font.GothamBlack
    toolBtn.ZIndex = 5
    toolBtn.Parent = btn
    
    local toolCorner = Instance.new("UICorner")
    toolCorner.CornerRadius = UDim.new(0, 8)
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

local function createScriptBloxBrowser(tabName)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 520)
    container.BackgroundColor3 = C.bgLight
    container.BorderSizePixel = 0
    container.ZIndex = 4
    container.Parent = scroll
    container.Visible = false
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 12)
    containerCorner.Parent = container
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = C.border
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    stroke.Parent = container
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 36)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "ScriptBlox"
    title.TextColor3 = C.accent
    title.TextSize = 18
    title.Font = Enum.Font.GothamBlack
    title.ZIndex = 5
    title.Parent = container
    
    local searchFrame = Instance.new("Frame")
    searchFrame.Size = UDim2.new(1, -20, 0, 42)
    searchFrame.Position = UDim2.new(0, 10, 0, 50)
    searchFrame.BackgroundColor3 = C.bgDark
    searchFrame.BorderSizePixel = 0
    searchFrame.ZIndex = 5
    searchFrame.Parent = container
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 10)
    searchCorner.Parent = searchFrame
    
    local searchInput = Instance.new("TextBox")
    searchInput.Size = UDim2.new(1, -100, 1, 0)
    searchInput.Position = UDim2.new(0, 14, 0, 0)
    searchInput.BackgroundTransparency = 1
    searchInput.Text = ""
    searchInput.PlaceholderText = "поиск скриптов..."
    searchInput.TextColor3 = C.white
    searchInput.PlaceholderColor3 = C.gray
    searchInput.TextSize = 13
    searchInput.Font = Enum.Font.Gotham
    searchInput.ZIndex = 6
    searchInput.Parent = searchFrame
    
    local searchBtn = Instance.new("TextButton")
    searchBtn.Size = UDim2.new(0, 75, 0, 32)
    searchBtn.Position = UDim2.new(1, -85, 0.5, -16)
    searchBtn.BackgroundColor3 = C.accent
    searchBtn.Text = "GO"
    searchBtn.TextColor3 = C.white
    searchBtn.TextSize = 12
    searchBtn.Font = Enum.Font.GothamBold
    searchBtn.ZIndex = 6
    searchBtn.Parent = searchFrame
    
    local searchBtnCorner = Instance.new("UICorner")
    searchBtnCorner.CornerRadius = UDim.new(0, 6)
    searchBtnCorner.Parent = searchBtn
    
    local resultsScroll = Instance.new("ScrollingFrame")
    resultsScroll.Size = UDim2.new(1, -20, 1, -105)
    resultsScroll.Position = UDim2.new(0, 10, 0, 100)
    resultsScroll.BackgroundColor3 = C.bgDark
    resultsScroll.BorderSizePixel = 0
    resultsScroll.ScrollBarThickness = 5
    resultsScroll.ScrollBarImageColor3 = C.accent
    resultsScroll.ZIndex = 5
    resultsScroll.Parent = container
    
    local resultsCorner = Instance.new("UICorner")
    resultsCorner.CornerRadius = UDim.new(0, 10)
    resultsCorner.Parent = resultsScroll
    
    local resultsList = Instance.new("UIListLayout")
    resultsList.Padding = UDim.new(0, 8)
    resultsList.Parent = resultsScroll
    
    local popularScripts = {
        {name = "Infinite Yield", game = "Universal", url = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"},
        {name = "Synapse X", game = "Universal", url = "https://raw.githubusercontent.com/infyiff/backup/main/synapse.lua"},
        {name = "KRNL", game = "Universal", url = "https://raw.githubusercontent.com/infyiff/backup/main/krnl.lua"},
        {name = "Owl Hub", game = "Arsenal", url = "https://raw.githubusercontent.com/CriShoux/OwlHub/master/OwlHub.txt"},
        {name = "Vape V4", game = "Bedwars", url = "https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/NewMainScript.lua"},
    }
    
    local function addScriptCard(scriptInfo)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -16, 0, 80)
        card.BackgroundColor3 = C.bgLight
        card.BorderSizePixel = 0
        card.ZIndex = 6
        card.Parent = resultsScroll
        
        local cardCorner = Instance.new("UICorner")
        cardCorner.CornerRadius = UDim.new(0, 8)
        cardCorner.Parent = card
        
        local cardStroke = Instance.new("UIStroke")
        cardStroke.Color = C.border
        cardStroke.Thickness = 1
        cardStroke.Parent = card
        
        local scriptName = Instance.new("TextLabel")
        scriptName.Size = UDim2.new(1, -120, 0, 22)
        scriptName.Position = UDim2.new(0, 12, 0, 10)
        scriptName.BackgroundTransparency = 1
        scriptName.Text = scriptInfo.name
        scriptName.TextColor3 = C.white
        scriptName.TextSize = 15
        scriptName.Font = Enum.Font.GothamBold
        scriptName.TextXAlignment = Enum.TextXAlignment.Left
        scriptName.ZIndex = 7
        scriptName.Parent = card
        
        local gameLabel = Instance.new("TextLabel")
        gameLabel.Size = UDim2.new(0, 80, 0, 20)
        gameLabel.Position = UDim2.new(0, 12, 0, 34)
        gameLabel.BackgroundColor3 = C.accent
        gameLabel.Text = scriptInfo.game
        gameLabel.TextColor3 = C.white
        gameLabel.TextSize = 10
        gameLabel.Font = Enum.Font.GothamBold
        gameLabel.ZIndex = 7
        gameLabel.Parent = card
        
        local gameCorner = Instance.new("UICorner")
        gameCorner.CornerRadius = UDim.new(0, 5)
        gameCorner.Parent = gameLabel
        
        local runBtn = Instance.new("TextButton")
        runBtn.Size = UDim2.new(0, 70, 0, 32)
        runBtn.Position = UDim2.new(1, -85, 0.5, -16)
        runBtn.BackgroundColor3 = C.green
        runBtn.Text = "RUN"
        runBtn.TextColor3 = C.white
        runBtn.TextSize = 12
        runBtn.Font = Enum.Font.GothamBlack
        runBtn.ZIndex = 7
        runBtn.Parent = card
        
        local runCorner = Instance.new("UICorner")
        runCorner.CornerRadius = UDim.new(0, 6)
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
    
    for _, script in pairs(popularScripts) do
        addScriptCard(script)
    end
    
    resultsScroll.CanvasSize = UDim2.new(0, 0, 0, resultsList.AbsoluteContentSize.Y + 20)
    
    buttons["ScriptBloxBrowser"] = {Btn = container, Tab = tabName, IsBrowser = true}
    return container
end

local function createCustomScriptInput(tabName)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 480)
    container.BackgroundColor3 = C.bgLight
    container.BorderSizePixel = 0
    container.ZIndex = 4
    container.Parent = scroll
    container.Visible = false
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 12)
    containerCorner.Parent = container
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = C.border
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    stroke.Parent = container
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 36)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Executor"
    title.TextColor3 = C.accent
    title.TextSize = 18
    title.Font = Enum.Font.GothamBlack
    title.ZIndex = 5
    title.Parent = container
    
    local nameFrame = Instance.new("Frame")
    nameFrame.Size = UDim2.new(1, -20, 0, 38)
    nameFrame.Position = UDim2.new(0, 10, 0, 50)
    nameFrame.BackgroundColor3 = C.bgDark
    nameFrame.BorderSizePixel = 0
    nameFrame.ZIndex = 5
    nameFrame.Parent = container
    
    local nameFrameCorner = Instance.new("UICorner")
    nameFrameCorner.CornerRadius = UDim.new(0, 8)
    nameFrameCorner.Parent = nameFrame
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0, 80, 1, 0)
    nameLabel.Position = UDim2.new(0, 12, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "Name:"
    nameLabel.TextColor3 = C.gray
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.ZIndex = 6
    nameLabel.Parent = nameFrame
    
    local nameInput = Instance.new("TextBox")
    nameInput.Size = UDim2.new(1, -100, 1, 0)
    nameInput.Position = UDim2.new(0, 90, 0, 0)
    nameInput.BackgroundTransparency = 1
    nameInput.Text = "MyScript"
    nameInput.TextColor3 = C.white
    nameInput.TextSize = 13
    nameInput.Font = Enum.Font.Gotham
    nameInput.ZIndex = 6
    nameInput.Parent = nameFrame
    
    local codeFrame = Instance.new("Frame")
    codeFrame.Size = UDim2.new(1, -20, 0, 240)
    codeFrame.Position = UDim2.new(0, 10, 0, 95)
    codeFrame.BackgroundColor3 = C.bgDark
    codeFrame.BorderSizePixel = 0
    codeFrame.ZIndex = 5
    codeFrame.Parent = container
    
    local codeFrameCorner = Instance.new("UICorner")
    codeFrameCorner.CornerRadius = UDim.new(0, 10)
    codeFrameCorner.Parent = codeFrame
    
    local codeBox = Instance.new("TextBox")
    codeBox.Size = UDim2.new(1, -16, 1, -16)
    codeBox.Position = UDim2.new(0, 8, 0, 8)
    codeBox.BackgroundTransparency = 1
    codeBox.Text = "-- введи Lua код\nprint('hello seal hub')\n\n-- пример:\n-- loadstring(game:HttpGet('URL'))()"
    codeBox.TextColor3 = C.white
    codeBox.TextSize = 12
    codeBox.Font = Enum.Font.Code
    codeBox.MultiLine = true
    codeBox.ClearTextOnFocus = false
    codeBox.TextXAlignment = Enum.TextXAlignment.Left
    codeBox.TextYAlignment = Enum.TextYAlignment.Top
    codeBox.ZIndex = 6
    codeBox.Parent = codeFrame
    
    local buttonsRow = Instance.new("Frame")
    buttonsRow.Size = UDim2.new(1, -20, 0, 40)
    buttonsRow.Position = UDim2.new(0, 10, 0, 342)
    buttonsRow.BackgroundTransparency = 1
    buttonsRow.ZIndex = 5
    buttonsRow.Parent = container
    
    local runBtn = Instance.new("TextButton")
    runBtn.Size = UDim2.new(0, 90, 1, 0)
    runBtn.Position = UDim2.new(0, 0, 0, 0)
    runBtn.BackgroundColor3 = C.green
    runBtn.Text = "▶ Запуск"
    runBtn.TextColor3 = C.white
    runBtn.TextSize = 13
    runBtn.Font = Enum.Font.GothamBlack
    runBtn.ZIndex = 6
    runBtn.Parent = buttonsRow
    
    local runBtnCorner = Instance.new("UICorner")
    runBtnCorner.CornerRadius = UDim.new(0, 8)
    runBtnCorner.Parent = runBtn
    
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0, 90, 1, 0)
    saveBtn.Position = UDim2.new(0, 100, 0, 0)
    saveBtn.BackgroundColor3 = C.accent
    saveBtn.Text = "💾 Сохр"
    saveBtn.TextColor3 = C.white
    saveBtn.TextSize = 13
    saveBtn.Font = Enum.Font.GothamBlack
    saveBtn.ZIndex = 6
    saveBtn.Parent = buttonsRow
    
    local saveBtnCorner = Instance.new("UICorner")
    saveBtnCorner.CornerRadius = UDim.new(0, 8)
    saveBtnCorner.Parent = saveBtn
    
    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0, 90, 1, 0)
    clearBtn.Position = UDim2.new(0, 200, 0, 0)
    clearBtn.BackgroundColor3 = C.red
    clearBtn.Text = "🗑 Очистить"
    clearBtn.TextColor3 = C.white
    clearBtn.TextSize = 13
    clearBtn.Font = Enum.Font.GothamBlack
    clearBtn.ZIndex = 6
    clearBtn.Parent = buttonsRow
    
    local clearBtnCorner = Instance.new("UICorner")
    clearBtnCorner.CornerRadius = UDim.new(0, 8)
    clearBtnCorner.Parent = clearBtn
    
    local savedTitle = Instance.new("TextLabel")
    savedTitle.Size = UDim2.new(1, -20, 0, 22)
    savedTitle.Position = UDim2.new(0, 10, 0, 390)
    savedTitle.BackgroundTransparency = 1
    savedTitle.Text = "Сохраненные скрипты:"
    savedTitle.TextColor3 = C.gray
    savedTitle.TextSize = 12
    savedTitle.Font = Enum.Font.GothamBold
    savedTitle.ZIndex = 5
    savedTitle.Parent = container
    
    local savedList = Instance.new("ScrollingFrame")
    savedList.Size = UDim2.new(1, -20, 0, 75)
    savedList.Position = UDim2.new(0, 10, 0, 415)
    savedList.BackgroundColor3 = C.bgDark
    savedList.BorderSizePixel = 0
    savedList.ScrollBarThickness = 4
    savedList.ZIndex = 5
    savedList.Parent = container
    
    local savedListCorner = Instance.new("UICorner")
    savedListCorner.CornerRadius = UDim.new(0, 8)
    savedListCorner.Parent = savedList
    
    local savedListLayout = Instance.new("UIListLayout")
    savedListLayout.Padding = UDim.new(0, 6)
    savedListLayout.Parent = savedList
    
    local function updateSavedList()
        for _, child in pairs(savedList:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        for name, code in pairs(savedScripts) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 32)
            btn.BackgroundColor3 = C.bgLight
            btn.Text = "📄 " .. name
            btn.TextColor3 = C.white
            btn.TextSize = 12
            btn.Font = Enum.Font.Gotham
            btn.ZIndex = 6
            btn.Parent = savedList
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
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
        
        saveConfig({
            settings = S,
            binds = binds,
            savedScripts = savedScripts,
            injectCount = injectCount,
            openBtnPos = openBtn.Position,
            bg = C.bg,
            bgLight = C.bgLight,
            bgDark = C.bgDark,
            accent = C.accent,
            accent2 = C.accent2,
            border = C.border,
            hover = C.hover,
            text = C.text
        })
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
                    Text = "Script executed!",
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
                Text = "'" .. name .. "' saved!",
                Duration = 2
            })
        end
    end)
    
    clearBtn.MouseButton1Click:Connect(function()
        codeBox.Text = "-- введи Lua код\n"
        nameInput.Text = "MyScript"
    end)
    
    updateSavedList()
    
    buttons["CustomScriptExecutor"] = {Btn = container, Tab = tabName, IsInput = true}
    return container
end

local function createStatsPanel(tabName)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 400)
    container.BackgroundColor3 = C.bgLight
    container.BorderSizePixel = 0
    container.ZIndex = 4
    container.Parent = scroll
    container.Visible = false
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 12)
    containerCorner.Parent = container
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = C.border
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    stroke.Parent = container
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 36)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Статистика"
    title.TextColor3 = C.accent
    title.TextSize = 18
    title.Font = Enum.Font.GothamBlack
    title.ZIndex = 5
    title.Parent = container
    
    local bigAvatar = Instance.new("ImageLabel")
    bigAvatar.Size = UDim2.new(0, 80, 0, 80)
    bigAvatar.Position = UDim2.new(0, 20, 0, 55)
    bigAvatar.BackgroundColor3 = C.bgDark
    bigAvatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png"
    bigAvatar.ZIndex = 5
    bigAvatar.Parent = container
    
    local bigAvatarCorner = Instance.new("UICorner")
    bigAvatarCorner.CornerRadius = UDim.new(1, 0)
    bigAvatarCorner.Parent = bigAvatar
    
    local statsName = Instance.new("TextLabel")
    statsName.Size = UDim2.new(1, -130, 0, 26)
    statsName.Position = UDim2.new(0, 115, 0, 60)
    statsName.BackgroundTransparency = 1
    statsName.Text = player.Name
    statsName.TextColor3 = C.white
    statsName.TextSize = 20
    statsName.Font = Enum.Font.GothamBlack
    statsName.TextXAlignment = Enum.TextXAlignment.Left
    statsName.ZIndex = 5
    statsName.Parent = container
    
    local statsId = Instance.new("TextLabel")
    statsId.Size = UDim2.new(1, -130, 0, 18)
    statsId.Position = UDim2.new(0, 115, 0, 88)
    statsId.BackgroundTransparency = 1
    statsId.Text = "ID: " .. player.UserId
    statsId.TextColor3 = C.gray
    statsId.TextSize = 12
    statsId.Font = Enum.Font.GothamBold
    statsId.TextXAlignment = Enum.TextXAlignment.Left
    statsId.ZIndex = 5
    statsId.Parent = container
    
    local statsDisplay = Instance.new("TextLabel")
    statsDisplay.Size = UDim2.new(1, -130, 0, 18)
    statsDisplay.Position = UDim2.new(0, 115, 0, 108)
    statsDisplay.BackgroundTransparency = 1
        statsDisplay.Text = "Инжектов: " .. injectCount
    statsDisplay.TextColor3 = C.accent2
    statsDisplay.TextSize = 14
    statsDisplay.Font = Enum.Font.GothamBold
    statsDisplay.TextXAlignment = Enum.TextXAlignment.Left
    statsDisplay.ZIndex = 5
    statsDisplay.Parent = container

    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, -40, 0, 1)
    divider.Position = UDim2.new(0, 20, 0, 150)
    divider.BackgroundColor3 = C.border
    divider.BorderSizePixel = 0
    divider.ZIndex = 5
    divider.Parent = container

    local statsGrid = Instance.new("Frame")
    statsGrid.Size = UDim2.new(1, -40, 0, 200)
    statsGrid.Position = UDim2.new(0, 20, 0, 165)
    statsGrid.BackgroundTransparency = 1
    statsGrid.ZIndex = 5
    statsGrid.Parent = container

    local function statCard(label, value, color, pos)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0.48, 0, 0, 70)
        card.Position = pos
        card.BackgroundColor3 = C.bgDark
        card.BorderSizePixel = 0
        card.ZIndex = 6
        card.Parent = statsGrid

        local cardCorner = Instance.new("UICorner")
        cardCorner.CornerRadius = UDim.new(0, 10)
        cardCorner.Parent = card

        local cardStroke = Instance.new("UIStroke")
        cardStroke.Color = C.border
        cardStroke.Thickness = 1
        cardStroke.Parent = card

        local val = Instance.new("TextLabel")
        val.Size = UDim2.new(1, 0, 0, 32)
        val.Position = UDim2.new(0, 0, 0, 8)
        val.BackgroundTransparency = 1
        val.Text = value
        val.TextColor3 = color or C.white
        val.TextSize = 24
        val.Font = Enum.Font.GothamBlack
        val.ZIndex = 7
        val.Parent = card

        local lab = Instance.new("TextLabel")
        lab.Size = UDim2.new(1, 0, 0, 20)
        lab.Position = UDim2.new(0, 0, 0, 42)
        lab.BackgroundTransparency = 1
        lab.Text = label
        lab.TextColor3 = C.gray
        lab.TextSize = 11
        lab.Font = Enum.Font.GothamBold
        lab.ZIndex = 7
        lab.Parent = card
    end

    statCard("Всего инжектов", tostring(injectCount), C.accent, UDim2.new(0, 0, 0, 0))
    statCard("Сохранено скриптов", tostring(#savedScripts), C.green, UDim2.new(0.52, 0, 0, 0))
    statCard("Активные бинды", tostring(#binds), C.yellow, UDim2.new(0, 0, 0, 82))
    statCard("Версия", "v4.0", C.accent2, UDim2.new(0.52, 0, 0, 82))

    buttons["StatsPanel"] = {Btn = container, Tab = tabName, IsStats = true}
    return container
end

local function createThemeSettings(tabName)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 550)
    container.BackgroundColor3 = C.bgLight
    container.BorderSizePixel = 0
    container.ZIndex = 4
    container.Parent = scroll
    container.Visible = false

    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 12)
    containerCorner.Parent = container

    local stroke = Instance.new("UIStroke")
    stroke.Color = C.border
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    stroke.Parent = container

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 36)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Тема"
    title.TextColor3 = C.accent
    title.TextSize = 18
    title.Font = Enum.Font.GothamBlack
    title.ZIndex = 5
    title.Parent = container

    local presets = {
        {name = "Фиолетовый", accent = Color3.fromRGB(124, 58, 237), accent2 = Color3.fromRGB(167, 139, 250)},
        {name = "Синий", accent = Color3.fromRGB(59, 130, 246), accent2 = Color3.fromRGB(96, 165, 250)},
        {name = "Красный", accent = Color3.fromRGB(239, 68, 68), accent2 = Color3.fromRGB(248, 113, 113)},
        {name = "Зеленый", accent = Color3.fromRGB(34, 197, 94), accent2 = Color3.fromRGB(74, 222, 128)},
        {name = "Оранжевый", accent = Color3.fromRGB(249, 115, 22), accent2 = Color3.fromRGB(251, 146, 60)},
        {name = "Розовый", accent = Color3.fromRGB(236, 72, 153), accent2 = Color3.fromRGB(244, 114, 182)},
    }

    local presetFrame = Instance.new("Frame")
    presetFrame.Size = UDim2.new(1, -20, 0, 50)
    presetFrame.Position = UDim2.new(0, 10, 0, 50)
    presetFrame.BackgroundTransparency = 1
    presetFrame.ZIndex = 5
    presetFrame.Parent = container

    local presetList = Instance.new("UIListLayout")
    presetList.FillDirection = Enum.FillDirection.Horizontal
    presetList.Padding = UDim.new(0, 8)
    presetList.Parent = presetFrame

    for _, preset in pairs(presets) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 80, 0, 36)
        btn.BackgroundColor3 = preset.accent
        btn.Text = preset.name
        btn.TextColor3 = C.white
        btn.TextSize = 11
        btn.Font = Enum.Font.GothamBold
        btn.ZIndex = 6
        btn.Parent = presetFrame

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            C.accent = preset.accent
            C.accent2 = preset.accent2
            saveConfig({
                settings = S,
                binds = binds,
                savedScripts = savedScripts,
                injectCount = injectCount,
                openBtnPos = openBtn.Position,
                bg = C.bg,
                bgLight = C.bgLight,
                bgDark = C.bgDark,
                accent = C.accent,
                accent2 = C.accent2,
                border = C.border,
                hover = C.hover,
                text = C.text
            })
            StarterGui:SetCore("SendNotification", {
                Title = "Тема",
                Text = "Выбран: " .. preset.name,
                Duration = 2
            })
        end)
    end

    local darkLabel = Instance.new("TextLabel")
    darkLabel.Size = UDim2.new(1, -20, 0, 22)
    darkLabel.Position = UDim2.new(0, 10, 0, 110)
    darkLabel.BackgroundTransparency = 1
    darkLabel.Text = "Фон:"
    darkLabel.TextColor3 = C.gray
    darkLabel.TextSize = 13
    darkLabel.Font = Enum.Font.GothamBold
    darkLabel.ZIndex = 5
    darkLabel.Parent = container

    local darkModes = {
        {name = "Темный", bg = Color3.fromRGB(13, 13, 18), bgLight = Color3.fromRGB(22, 22, 30), bgDark = Color3.fromRGB(8, 8, 12)},
        {name = "Светлый", bg = Color3.fromRGB(240, 240, 245), bgLight = Color3.fromRGB(220, 220, 230), bgDark = Color3.fromRGB(200, 200, 210)},
        {name = "AMOLED", bg = Color3.fromRGB(0, 0, 0), bgLight = Color3.fromRGB(10, 10, 10), bgDark = Color3.fromRGB(5, 5, 5)},
    }

    local darkFrame = Instance.new("Frame")
    darkFrame.Size = UDim2.new(1, -20, 0, 50)
    darkFrame.Position = UDim2.new(0, 10, 0, 135)
    darkFrame.BackgroundTransparency = 1
    darkFrame.ZIndex = 5
    darkFrame.Parent = container

    local darkList = Instance.new("UIListLayout")
    darkList.FillDirection = Enum.FillDirection.Horizontal
    darkList.Padding = UDim.new(0, 8)
    darkList.Parent = darkFrame

    for _, mode in pairs(darkModes) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 100, 0, 36)
        btn.BackgroundColor3 = mode.bg
        btn.Text = mode.name
        btn.TextColor3 = mode.name == "Светлый" and C.black or C.white
        btn.TextSize = 11
        btn.Font = Enum.Font.GothamBold
        btn.ZIndex = 6
        btn.Parent = darkFrame

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn

        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = C.border
        btnStroke.Thickness = 1
        btnStroke.Parent = btn

        btn.MouseButton1Click:Connect(function()
            C.bg = mode.bg
            C.bgLight = mode.bgLight
            C.bgDark = mode.bgDark
            saveConfig({
                settings = S,
                binds = binds,
                savedScripts = savedScripts,
                injectCount = injectCount,
                openBtnPos = openBtn.Position,
                bg = C.bg,
                bgLight = C.bgLight,
                bgDark = C.bgDark,
                accent = C.accent,
                accent2 = C.accent2,
                border = C.border,
                hover = C.hover,
                text = C.text
            })
            StarterGui:SetCore("SendNotification", {
                Title = "Фон",
                Text = "Выбран: " .. mode.name,
                Duration = 2
            })
        end)
    end

    buttons["ThemeSettings"] = {Btn = container, Tab = tabName, IsSettings = true}
    return container
end

local function createInfoPage(tabName)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 500)
    container.BackgroundColor3 = C.bgLight
    container.BorderSizePixel = 0
    container.ZIndex = 4
    container.Parent = scroll
    container.Visible = false

    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 12)
    containerCorner.Parent = container

    local stroke = Instance.new("UIStroke")
    stroke.Color = C.border
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    stroke.Parent = container

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 36)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Информация"
    title.TextColor3 = C.accent
    title.TextSize = 18
    title.Font = Enum.Font.GothamBlack
    title.ZIndex = 5
    title.Parent = container

    local textBox = Instance.new("TextLabel")
    textBox.Size = UDim2.new(1, -20, 1, -60)
    textBox.Position = UDim2.new(0, 10, 0, 50)
    textBox.BackgroundColor3 = C.bgDark
    textBox.Text = "  Тг скрипта: @SealHub\n  Скрипт был создан недавно и всё находится на этапе разработки"
    textBox.TextColor3 = C.white
    textBox.TextSize = 14
    textBox.Font = Enum.Font.Gotham
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.TextYAlignment = Enum.TextYAlignment.Top
    textBox.ZIndex = 5
    textBox.Parent = container

    local textCorner = Instance.new("UICorner")
    textCorner.CornerRadius = UDim.new(0, 10)
    textCorner.Parent = textBox

    buttons["InfoPage"] = {Btn = container, Tab = tabName}
    return container
end

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
createTab("Статистика", "📊")
createTab("Настройки", "⚙️")
createTab("Инфо", "📄")

createInfoPage("Инфо")

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

for _, morph in pairs(Morphs) do createMorphButton(morph, "Морфы") end

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
                    ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("SEAL HUB V4 🦭", "All")
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

for _, script in pairs(ScriptLibrary) do createScriptButton(script, "Скрипты") end
createScriptBloxBrowser("ScriptBlox")

local customChatGui = Instance.new("ScreenGui")
customChatGui.Name = "SealChat"
customChatGui.ResetOnSpawn = false
customChatGui.Parent = CoreGui
customChatGui.Enabled = false

local chatFrame = Instance.new("Frame")
chatFrame.Size = UDim2.new(0, 400, 0, 480)
chatFrame.Position = UDim2.new(0, 20, 0.5, -240)
chatFrame.BackgroundColor3 = C.bg
chatFrame.BorderSizePixel = 0
chatFrame.ZIndex = 50
chatFrame.Parent = customChatGui

local chatCorner = Instance.new("UICorner")
chatCorner.CornerRadius = UDim.new(0, 14)
chatCorner.Parent = chatFrame

local chatStroke = Instance.new("UIStroke")
chatStroke.Color = C.border
chatStroke.Thickness = 1
chatStroke.Parent = chatFrame

local chatTitle = Instance.new("TextLabel")
chatTitle.Size = UDim2.new(1, 0, 0, 42)
chatTitle.BackgroundColor3 = C.bgLight
chatTitle.Text = "💬 SEAL CHAT"
chatTitle.TextColor3 = C.white
chatTitle.TextSize = 16
chatTitle.Font = Enum.Font.GothamBlack
chatTitle.ZIndex = 51
chatTitle.Parent = chatFrame

local chatTitleCorner = Instance.new("UICorner")
chatTitleCorner.CornerRadius = UDim.new(0, 14)
chatTitleCorner.Parent = chatTitle

local chatTitleFix = Instance.new("Frame")
chatTitleFix.Size = UDim2.new(1, 0, 0, 20)
chatTitleFix.Position = UDim2.new(0, 0, 1, -20)
chatTitleFix.BackgroundColor3 = C.bgLight
chatTitleFix.BorderSizePixel = 0
chatTitleFix.ZIndex = 51
chatTitleFix.Parent = chatTitle

local chatScroll = Instance.new("ScrollingFrame")
chatScroll.Size = UDim2.new(1, -16, 1, -110)
chatScroll.Position = UDim2.new(0, 8, 0, 50)
chatScroll.BackgroundColor3 = C.bgDark
chatScroll.BorderSizePixel = 0
chatScroll.ScrollBarThickness = 4
chatScroll.ZIndex = 51
chatScroll.Parent = chatFrame

local chatScrollCorner = Instance.new("UICorner")
chatScrollCorner.CornerRadius = UDim.new(0, 8)
chatScrollCorner.Parent = chatScroll

local chatList = Instance.new("UIListLayout")
chatList.Padding = UDim.new(0, 6)
chatList.Parent = chatScroll

local chatInput = Instance.new("TextBox")
chatInput.Size = UDim2.new(1, -100, 0, 38)
chatInput.Position = UDim2.new(0, 10, 1, -48)
chatInput.BackgroundColor3 = C.bgLight
chatInput.Text = ""
chatInput.PlaceholderText = "Сообщение..."
chatInput.TextColor3 = C.white
chatInput.PlaceholderColor3 = C.gray
chatInput.TextSize = 13
chatInput.Font = Enum.Font.Gotham
chatInput.ZIndex = 51
chatInput.Parent = chatFrame

local chatInputCorner = Instance.new("UICorner")
chatInputCorner.CornerRadius = UDim.new(0, 8)
chatInputCorner.Parent = chatInput

local chatSend = Instance.new("TextButton")
chatSend.Size = UDim2.new(0, 75, 0, 38)
chatSend.Position = UDim2.new(1, -85, 1, -48)
chatSend.BackgroundColor3 = C.accent
chatSend.Text = "SEND"
chatSend.TextColor3 = C.white
chatSend.TextSize = 13
chatSend.Font = Enum.Font.GothamBlack
chatSend.ZIndex = 51
chatSend.Parent = chatFrame

local chatSendCorner = Instance.new("UICorner")
chatSendCorner.CornerRadius = UDim.new(0, 8)
chatSendCorner.Parent = chatSend

local sealChannel = Instance.new("BindableEvent")
sealChannel.Name = "SealChatChannel"
sealChannel.Parent = ReplicatedStorage

local function addMsg(user, msg, isSeal)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -10, 0, 55)
    f.BackgroundColor3 = C.bgLight
    f.BorderSizePixel = 0
    f.ZIndex = 52
    f.Parent = chatScroll

    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(0, 8)
    fCorner.Parent = f

    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(0, 32, 0, 32)
    avatar.Position = UDim2.new(0, 8, 0, 6)
    avatar.BackgroundColor3 = C.bgDark
    avatar.Image = isSeal and "https://www.roblox.com/headshot-thumbnail/image?userId=" .. user .. "&width=420&height=420&format=png" or ""
    avatar.ZIndex = 53
    avatar.Parent = f

    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(1, 0)
    avatarCorner.Parent = avatar

    local u = Instance.new("TextLabel")
    u.Size = UDim2.new(1, -60, 0, 18)
    u.Position = UDim2.new(0, 46, 0, 4)
    u.BackgroundTransparency = 1
    u.Text = isSeal and Players:GetNameFromUserIdAsync(user) or user
    u.TextColor3 = isSeal and C.accent or Color3.fromRGB(100, 100, 100)
    u.TextSize = 11
    u.Font = Enum.Font.GothamBold
    u.TextXAlignment = Enum.TextXAlignment.Left
    u.ZIndex = 53
    u.Parent = f

    local sealTag = Instance.new("TextLabel")
    sealTag.Size = UDim2.new(0, 40, 0, 16)
    sealTag.Position = UDim2.new(0, 46, 0, 22)
    sealTag.BackgroundColor3 = C.accent
    sealTag.Text = "SEAL"
    sealTag.TextColor3 = C.white
    sealTag.TextSize = 9
    sealTag.Font = Enum.Font.GothamBlack
    sealTag.ZIndex = 53
    sealTag.Visible = isSeal
    sealTag.Parent = f

    local sealTagCorner = Instance.new("UICorner")
    sealTagCorner.CornerRadius = UDim.new(0, 4)
    sealTagCorner.Parent = sealTag

    local m = Instance.new("TextLabel")
    m.Size = UDim2.new(1, -60, 0, 22)
    m.Position = UDim2.new(0, 46, 0, isSeal and 38 or 22)
    m.BackgroundTransparency = 1
    m.Text = msg
    m.TextColor3 = C.white
    m.TextSize = 12
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
        addMsg(player.UserId, msg, true)
        pcall(function()
            sealChannel:FireAllClients({user = player.UserId, msg = msg})
        end)
        chatInput.Text = ""
    end
end)

chatInput.FocusLost:Connect(function(ep) if ep then chatSend.MouseButton1Click:Fire() end end)

sealChannel.Event:Connect(function(data)
    if data.user ~= player.UserId then
        addMsg(data.user, data.msg, true)
    end
end)

createButton("Вкл Custom Chat", "Custom Chat", function(a)
    S.chatEnabled = a
    customChatGui.Enabled = a
    if a then
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
        addMsg("SYSTEM", "Custom Chat активирован!", false)
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
    addMsg("SYSTEM", "Чат очищен", false)
end, false, "Удалить все")

for _, tool in pairs(ToolsLibrary) do createToolButton(tool, "Tools") end
createCustomScriptInput("Executor")
createStatsPanel("Статистика")
createThemeSettings("Настройки")

createButton("Сохранить конфиг", "Настройки", function(a)
    saveConfig({
        settings = S,
        binds = binds,
        savedScripts = savedScripts,
        injectCount = injectCount,
        openBtnPos = openBtn.Position,
        bg = C.bg,
        bgLight = C.bgLight,
        bgDark = C.bgDark,
        accent = C.accent,
        accent2 = C.accent2,
        border = C.border,
        hover = C.hover,
        text = C.text
    })
    StarterGui:SetCore("SendNotification", {Title = "CFG", Text = "Сохранено", Duration = 2})
end, false, "Сохранить настройки")

createButton("Загрузить конфиг", "Настройки", function(a)
    local cfg = loadConfig()
    if cfg then
        savedScripts = cfg.savedScripts or {}
        binds = cfg.binds or {}
        injectCount = cfg.injectCount or injectCount
        StarterGui:SetCore("SendNotification", {Title = "CFG", Text = "Загружено", Duration = 2})
    end
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

local function toggleMenu()
    menuOpen = not menuOpen
    main.Visible = menuOpen
    if menuOpen then
        blur.Size = 8
        main.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Back), {Size = UDim2.new(0, 950, 0, 620)}):Play()
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
    else
        blur.Size = 0
    end
end

keyButton.MouseButton1Click:Connect(function()
    if checkKey(keyInput.Text) then
        injectCount = injectCount + 1
        saveConfig({
            settings = S,
            binds = binds,
            savedScripts = savedScripts,
            injectCount = injectCount,
            openBtnPos = openBtn.Position,
            bg = C.bg,
            bgLight = C.bgLight,
            bgDark = C.bgDark,
            accent = C.accent,
            accent2 = C.accent2,
            border = C.border,
            hover = C.hover,
            text = C.text
        })
        TweenService:Create(keyFrame, TweenInfo.new(0.4), {Position = UDim2.new(0.5, -210, -1, -170)}):Play()
        task.wait(0.4)
        keyFrame:Destroy()
        main.Visible = true
        openBtn.Visible = true
        StarterGui:SetCore("SendNotification", {
            Title = "🦭 Обновление!",
            Text = "----------------------------------------\nИзменено меню и есть кастом стиль.",
            Duration = 5
        })
    else
        keyStatus.Text = "❌ Тюлень говорит что ключ неверный"
        keyInput.Text = ""
        TweenService:Create(keyInput, TweenInfo.new(0.1), {Position = UDim2.new(0.5, -175, 0.5, -26)}):Play()
        task.wait(0.05)
        TweenService:Create(keyInput, TweenInfo.new(0.1), {Position = UDim2.new(0.5, -165, 0.5, -26)}):Play()
        task.wait(0.05)
        TweenService:Create(keyInput, TweenInfo.new(0.1), {Position = UDim2.new(0.5, -170, 0.5, -26)}):Play()
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

task.spawn(function()
    while task.wait(5) do
        local ping = 0
        pcall(function()
            local start = tick()
            game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
            ping = math.floor((tick() - start) * 1000)
        end)
        pingLabel.Text = ping .. " ms"
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
makeDraggable(openBtn, openBtn)

local firstTab = tabs[1]
if firstTab then
    firstTab.HL.Visible = true
    TweenService:Create(firstTab.Btn, TweenInfo.new(0.15), {BackgroundColor3 = C.bgLight}):Play()
    firstTab.Icon.TextColor3 = C.accent
    firstTab.Name.TextColor3 = C.white
end

for _, btn in pairs(buttons) do
    if btn.Tab == currentTab then
        btn.Btn.Visible = true
    end
end
scroll.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 20)
