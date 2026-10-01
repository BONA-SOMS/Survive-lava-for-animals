-- BONA TELEPORT | SURVIVE LAVA FOR ANIMALS!
-- Rayfield + outside buttons | Run/Instant | 10M default speed

local RayfieldSuccess, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)
if not RayfieldSuccess or not Rayfield then
    warn("[BONA] Failed to load Rayfield")
    return
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local SafeZone = Vector3.new(109.223, 19.180, 327.889)
local LastStage = Vector3.new(1393.142, 495.180, 327.682)

local TeleportMode = "Run"
local RunSpeed = 10000000
local MAX_SPEED = 1000000000000000000000000
local CurrentTween

local function StopMovement()
    if CurrentTween then
        pcall(function() CurrentTween:Cancel() end)
        CurrentTween = nil
    end
end

local function TeleportTo(Position)
    local Character = Player.Character
    if not Character then return end
    local Root = Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end

    StopMovement()

    if TeleportMode == "Instant" then
        Root.CFrame = CFrame.new(Position)
        return
    end

    local Distance = (Root.Position - Position).Magnitude
    if Distance <= 0.1 then return end

    RunSpeed = math.clamp(RunSpeed, 1, MAX_SPEED)
    local TravelTime = math.max(Distance / RunSpeed, 0.03)

    CurrentTween = TweenService:Create(
        Root,
        TweenInfo.new(TravelTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
        {CFrame = CFrame.new(Position)}
    )
    CurrentTween:Play()
    CurrentTween.Completed:Connect(function()
        CurrentTween = nil
    end)
end

local Window = Rayfield:CreateWindow({
    Name = "SURVIVE LAVA FOR ANIMALS!",
    LoadingTitle = "SURVIVE LAVA FOR ANIMALS!",
    LoadingSubtitle = "BONA Teleport",
    ShowText = "Rayfield",
    ToggleUIKeybind = "K",
    ConfigurationSaving = {Enabled = false},
    Discord = {Enabled = false},
    KeySystem = false
})

local TeleportTab = Window:CreateTab("Teleport", 4483362458)

TeleportTab:CreateDropdown({
    Name = "Teleport Mode",
    Options = {"Run", "Instant"},
    CurrentOption = {"Run"},
    MultipleOptions = false,
    Callback = function(Option)
        if type(Option) == "table" then Option = Option[1] end
        TeleportMode = Option == "Instant" and "Instant" or "Run"
        Rayfield:Notify({
            Title = "Teleport Mode",
            Content = "Mode: " .. TeleportMode,
            Duration = 2
        })
    end
})

TeleportTab:CreateInput({
    Name = "Run Speed",
    CurrentValue = "10000000",
    PlaceholderText = "Enter speed...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Value)
        local Number = tonumber(Value)
        if not Number then
            Rayfield:Notify({Title = "Invalid Speed", Content = "Please enter a number.", Duration = 3})
            return
        end
        RunSpeed = math.clamp(Number, 1, MAX_SPEED)
        Rayfield:Notify({
            Title = "Run Speed",
            Content = "Speed set to " .. tostring(RunSpeed),
            Duration = 2
        })
    end
})

TeleportTab:CreateButton({
    Name = "🟢 Safe Zone",
    Callback = function() TeleportTo(SafeZone) end
})

TeleportTab:CreateButton({
    Name = "🟣 Last Stage",
    Callback = function() TeleportTo(LastStage) end
})

TeleportTab:CreateParagraph({
    Title = "Locations",
    Content =
        "🟢 Safe Zone\nVector3.new(109.223, 19.180, 327.889)\n\n" ..
        "🟣 Last Stage\nVector3.new(1393.142, 495.180, 327.682)"
})

TeleportTab:CreateParagraph({
    Title = "Run Settings",
    Content =
        "Default Speed: 10M\n10M = 10,000,000\n\n" ..
        "Maximum Speed: 1,000,000,000,000,000,000,000,000\n\n" ..
        "Default Mode: Run"
})

local UIParent
pcall(function()
    if gethui then UIParent = gethui() end
end)
if not UIParent then UIParent = PlayerGui end

local OldUI = UIParent:FindFirstChild("BONA_OutsideTeleport")
if OldUI then OldUI:Destroy() end

local OutsideUI = Instance.new("ScreenGui")
OutsideUI.Name = "BONA_OutsideTeleport"
OutsideUI.ResetOnSpawn = false
OutsideUI.IgnoreGuiInset = true
OutsideUI.DisplayOrder = 2147483647
OutsideUI.ZIndexBehavior = Enum.ZIndexBehavior.Global
OutsideUI.Parent = UIParent

local Holder = Instance.new("Frame")
Holder.Name = "TeleportButtons"
Holder.AnchorPoint = Vector2.new(1, 0)
Holder.Position = UDim2.new(1, -265, 0, 78)
Holder.Size = UDim2.new(0, 260, 0, 60)
Holder.BackgroundTransparency = 1
Holder.BorderSizePixel = 0
Holder.ZIndex = 1000
Holder.Parent = OutsideUI

local function MakeButton(Name, Text, Position, Color, TextSize, Callback)
    local Button = Instance.new("TextButton")
    Button.Name = Name
    Button.Size = UDim2.new(0, 125, 0, 60)
    Button.Position = Position
    Button.BackgroundColor3 = Color
    Button.BackgroundTransparency = 0.05
    Button.Text = Text
    Button.TextColor3 = Color3.fromRGB(0, 0, 0)
    Button.TextSize = TextSize
    Button.Font = Enum.Font.GothamBold
    Button.BorderSizePixel = 0
    Button.AutoButtonColor = true
    Button.ZIndex = 1001
    Button.Parent = Holder

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 7)
    Corner.Parent = Button

    Button.Activated:Connect(Callback)
    return Button
end

MakeButton(
    "SafeZone", "safe", UDim2.new(0, 0, 0, 0),
    Color3.fromRGB(125, 190, 65), 25,
    function() TeleportTo(SafeZone) end
)

MakeButton(
    "LastStage", "last stage", UDim2.new(0, 135, 0, 0),
    Color3.fromRGB(175, 65, 195), 23,
    function() TeleportTo(LastStage) end
)

local Dragging = false
local DragStart
local StartPosition

Holder.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.Touch
    or Input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        DragStart = Input.Position
        StartPosition = Holder.Position
        Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(Input)
    if not Dragging then return end
    if Input.UserInputType == Enum.UserInputType.Touch
    or Input.UserInputType == Enum.UserInputType.MouseMovement then
        local Delta = Input.Position - DragStart
        Holder.Position = UDim2.new(
            StartPosition.X.Scale, StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y
        )
    end
end)

Rayfield:Notify({
    Title = "SURVIVE LAVA FOR ANIMALS!",
    Content = "🟩 Run mode | 10M speed | 🟪 Ready!",
    Duration = 4
})
