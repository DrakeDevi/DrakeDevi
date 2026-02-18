--[[ 
    UI LIBRARY - INSTANT UGC (PRO REFACTOR)
    Features: Smooth Tweens, Auto-Stacking Notifications, Modern Toggles
]]

local Library = {}

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Default Theme / Constants
local COLORS = {
    Background = Color3.fromRGB(25, 25, 25),
    Section = Color3.fromRGB(35, 35, 35),
    Accent = Color3.fromRGB(60, 60, 65),
    Text = Color3.fromRGB(240, 240, 240),
    ToggleOn = Color3.fromRGB(0, 200, 100),
    ToggleOff = Color3.fromRGB(200, 50, 50)
}

-- ================= NOTIFICATION SYSTEM =================

local function GetNotifyContainer(position)
    local playerGui = Player:WaitForChild("PlayerGui")
    local screenName = "LibraryNotifs_" .. position
    local screenGui = playerGui:FindFirstChild(screenName)

    if not screenGui then
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = screenName
        screenGui.Parent = playerGui

        local container = Instance.new("Frame")
        container.Name = "Container"
        container.Size = UDim2.new(0, 280, 1, -40)
        container.BackgroundTransparency = 1
        container.Parent = screenGui

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 8)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = container

        if position:find("Left") then
            container.Position = UDim2.new(0, 20, 0, 20)
        else
            container.Position = UDim2.new(1, -300, 0, 20)
        end

        if position:find("Bottom") then
            layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
            container.Position = UDim2.new(container.Position.X.Scale, container.Position.X.Offset, 0, -20)
        end
    end
    return screenGui.Container
end

function Library:Notify(options)
    local text = options.Text or "Notification"
    local duration = options.Duration or 3
    local icon = options.Icon
    local position = options.Position or "BottomRight"
    
    local container = GetNotifyContainer(position)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 0)
    frame.BackgroundColor3 = COLORS.Background
    frame.ClipsDescendants = true
    frame.Parent = container

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", frame).Color = COLORS.Accent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, icon and -50 or -20, 1, 0)
    label.Position = UDim2.new(0, icon and 45 or 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = COLORS.Text
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    if icon then
        local img = Instance.new("ImageLabel")
        img.Size = UDim2.new(0, 24, 0, 24)
        img.Position = UDim2.new(0, 10, 0.5, -12)
        img.BackgroundTransparency = 1
        img.Image = icon
        img.Parent = frame
    end

    -- Animate In
    TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(1, 0, 0, 45)}):Play()

    task.delay(duration, function()
        local out = TweenService:Create(frame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1})
        out:Play()
        out.Completed:Wait()
        frame:Destroy()
    end)
end

-- ================= WINDOW LOGIC =================

function Library:CreateWindow(Config)
    Config = Config or {}
    local Window = {}
    local toggled = false

    local Gui = Instance.new("ScreenGui")
    Gui.Name = "CustomLibrary"
    Gui.ResetOnSpawn = false
    Gui.Parent = Player:WaitForChild("PlayerGui")

    local Main = Instance.new("Frame")
    Main.Name = "MainFrame"
    Main.Size = UDim2.new(0, 210, 0, 40)
    Main.Position = UDim2.new(0.5, -105, 0.3, 0)
    Main.BackgroundColor3 = COLORS.Background
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = Gui

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = COLORS.Accent
    Stroke.Thickness = 1.5

    local Header = Instance.new("TextButton")
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundTransparency = 1
    Header.Text = "  " .. (Config.Title or "UI Library")
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 14
    Header.TextColor3 = COLORS.Text
    Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.Parent = Main

    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Position = UDim2.new(0, 0, 0, 40)
    Content.Size = UDim2.new(1, 0, 0, 0)
    Content.BackgroundTransparency = 1
    Content.Visible = false
    Content.Parent = Main

    local UIList = Instance.new("UIListLayout", Content)
    UIList.Padding = UDim.new(0, 5)
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    Instance.new("UIPadding", Content).PaddingTop = UDim.new(0, 8)

    local Credits = Instance.new("TextLabel")
    Credits.Size = UDim2.new(1, -10, 0, 20)
    Credits.Position = UDim2.new(0, 0, 1, -20)
    Credits.BackgroundTransparency = 1
    Credits.Text = Config.Creator or "Credits: FynxBlox"
    Credits.Font = Enum.Font.Gotham
    Credits.TextSize = 10
    Credits.TextXAlignment = Enum.TextXAlignment.Right
    Credits.Parent = Main

    -- Rainbow Loop
    task.spawn(function()
        while Gui.Parent do
            local hue = (os.clock() % 5) / 5
            Credits.TextColor3 = Color3.fromHSV(hue, 0.8, 1)
            RunService.RenderStepped:Wait()
        end
    end)

    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Smooth Toggle Window
    local function UpdateSize()
        local targetContentHeight = UIList.AbsoluteContentSize.Y + 20
        local targetMainHeight = toggled and (40 + targetContentHeight + 20) or 40
        
        Content.Visible = true -- Keep visible for tween
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 210, 0, targetMainHeight)}):Play()
        TweenService:Create(Content, TweenInfo.new(0.4), {Size = UDim2.new(1, 0, 0, targetContentHeight)}):Play()
    end

    Header.MouseButton1Click:Connect(function()
        toggled = not toggled
        UpdateSize()
    end)

    -- Elements
    function Window:AddButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 190, 0, 30)
        btn.BackgroundColor3 = COLORS.Section
        btn.Text = text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.TextColor3 = COLORS.Text
        btn.Parent = Content
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

        btn.MouseButton1Click:Connect(function()
            pcall(callback)
            -- Click animation
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = COLORS.Accent}):Play()
            task.wait(0.1)
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = COLORS.Section}):Play()
        end)
    end

    function Window:AddToggle(text, default, callback)
        local currState = default or false
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 190, 0, 32)
        btn.BackgroundColor3 = COLORS.Section
        btn.Text = "  " .. text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.TextColor3 = COLORS.Text
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = Content
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 30, 0, 16)
        indicator.Position = UDim2.new(1, -40, 0.5, -8)
        indicator.BackgroundColor3 = currState and COLORS.ToggleOn or COLORS.ToggleOff
        indicator.Parent = btn
        Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 12, 0, 12)
        dot.Position = UDim2.new(currState and 0.55 or 0.1, 0, 0.5, -6)
        dot.BackgroundColor3 = Color3.new(1,1,1)
        dot.Parent = indicator
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        btn.MouseButton1Click:Connect(function()
            currState = not currState
            TweenService:Create(indicator, TweenInfo.new(0.2), {BackgroundColor3 = currState and COLORS.ToggleOn or COLORS.ToggleOff}):Play()
            TweenService:Create(dot, TweenInfo.new(0.2), {Position = UDim2.new(currState and 0.55 or 0.1, 0, 0.5, -6)}):Play()
            pcall(callback, currState)
        end)
    end

    return Window
end

return Library
