local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Создаем интерфейс меню
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 450)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.BorderSizePixel = 0
Title.Text = "Anti-Aim Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = MainFrame

-- Чекбокс для включения Anti-Aim
local AntiAimEnabled = Instance.new("TextButton")
AntiAimEnabled.Size = UDim2.new(1, -20, 0, 40)
AntiAimEnabled.Position = UDim2.new(0, 10, 0, 50)
AntiAimEnabled.Text = "Enable Anti-Aim: OFF"
AntiAimEnabled.TextColor3 = Color3.fromRGB(255, 255, 255)
AntiAimEnabled.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AntiAimEnabled.Font = Enum.Font.SourceSans
AntiAimEnabled.TextSize = 16
AntiAimEnabled.Parent = MainFrame

local antiAimActive = false
AntiAimEnabled.MouseButton1Click:Connect(function()
    antiAimActive = not antiAimActive
    AntiAimEnabled.Text = "Enable Anti-Aim: " .. (antiAimActive and "ON" or "OFF")
    AntiAimEnabled.BackgroundColor3 = antiAimActive and Color3.fromRGB(70, 140, 70) or Color3.fromRGB(50, 50, 50)
end)

-- Функция для создания слайдера
local function CreateSlider(name, positionY, min, max, default)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -20, 0, 50)
    Frame.Position = UDim2.new(0, 10, 0, positionY)
    Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Frame.Parent = MainFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name .. ": " .. tostring(default)
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.Parent = Frame

    local Slider = Instance.new("TextButton")
    Slider.Size = UDim2.new(0.4, 0, 1, 0)
    Slider.Position = UDim2.new(0.6, 0, 0, 0)
    Slider.Text = tostring(default)
    Slider.TextColor3 = Color3.fromRGB(255, 255, 255)
    Slider.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    Slider.Font = Enum.Font.SourceSans
    Slider.TextSize = 14
    Slider.Parent = Frame

    local value = default
    Slider.MouseButton1Click:Connect(function()
        value = math.clamp(value + 10, min, max)
        if value >= max then value = min end
        Label.Text = name .. ": " .. tostring(value)
        Slider.Text = tostring(value)
    end)

    return function() return value end
end

-- Слайдеры для параметров
local getSpinBotValue = CreateSlider("Spin Bot Speed", 110, 0, 360, 90)
local getYawValue = CreateSlider("Yaw Offset", 170, -180, 180, 0)
local getBodyYawValue = CreateSlider("Body Yaw", 230, -180, 180, 45)
local getDefensiveValue = CreateSlider("Defensive Level", 290, 0, 100, 50)

-- Логика для каждого параметра
local function applyAntiAim()
    local spinBotValue = getSpinBotValue()
    local yawValue = getYawValue()
    local bodyYawValue = getBodyYawValue()
    local defensiveValue = getDefensiveValue()

    -- Spin Bot логика
    if spinBotValue > 0 then
        LocalPlayer.Character.HumanoidRootPart.CFrame = 
            LocalPlayer.Character.HumanoidRootPart.CFrame * 
            CFrame.Angles(0, math.rad(spinBotValue), 0)
    end

    -- Yaw логика (положение головы вверх или вниз)
    if yawValue ~= 0 then
        local head = LocalPlayer.Character:FindFirstChild("Head")
        if head then
            head.CFrame = head.CFrame * CFrame.Angles(math.rad(yawValue), 0, 0)
        end
    end

    -- Body Yaw логика (шатание тела влево и вправо)
    if bodyYawValue ~= 0 then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "Head" then
                part.CFrame = part.CFrame * CFrame.Angles(0, math.rad(bodyYawValue), 0)
            end
        end
    end

    -- Defensive логика (переворачиваем персонажа)
    if defensiveValue > 0 then
        local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            LocalPlayer.Character:SetPrimaryPartCFrame(humanoidRootPart.CFrame * CFrame.Angles(math.rad(180), 0, 0))
        end
    end
end

-- Anti-Aim активатор
RunService.RenderStepped:Connect(function()
    if antiAimActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        applyAntiAim()
    end
end)
