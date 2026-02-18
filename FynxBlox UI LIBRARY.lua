--[[ 
    UI LIBRARY - INSTANT UGC
    Refactored / Fixed
    Original Credits: FynxBlox
]]

local Library = {}

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

-- ================= LIBRARY LOGIC =================

function Library:CreateWindow(Config)
    Config = Config or {}

    local Window = {}
    local TitleText = Config.Title or "UI Library"
    local CreatorName = Config.Creator or "Credits: FynxBlox"

    -- ScreenGui
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "CustomLibrary"
    Gui.ResetOnSpawn = false
    Gui.IgnoreGuiInset = true
    Gui.Parent = Player:WaitForChild("PlayerGui")

    -- Main Frame
    local Main = Instance.new("Frame")
    Main.Name = "MainFrame"
    Main.Size = UDim2.new(0, 200, 0, 36)
    Main.Position = UDim2.new(0.5, -100, 0.35, 0)
    Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Parent = Gui

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

    -- Header
    local Header = Instance.new("TextButton")
    Header.Parent = Main
    Header.Size = UDim2.new(1, -10, 0, 36)
    Header.Position = UDim2.new(0, 5, 0, 0)
    Header.BackgroundTransparency = 1
    Header.Text = TitleText
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 12
    Header.TextColor3 = Color3.fromRGB(235,235,235)
    Header.TextXAlignment = Enum.TextXAlignment.Left

    -- Content
    local Content = Instance.new("Frame")
    Content.Parent = Main
    Content.Name = "Content"
    Content.Position = UDim2.new(0, 0, 0, 36)
    Content.Size = UDim2.new(1, 0, 0, 0)
    Content.BackgroundColor3 = Color3.fromRGB(35,35,35)
    Content.BorderSizePixel = 0
    Content.Visible = false
    Content.ClipsDescendants = true

    Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 8)

    -- Layout
    local UIList = Instance.new("UIListLayout", Content)
    UIList.Padding = UDim.new(0, 4)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local UIPadding = Instance.new("UIPadding", Content)
    UIPadding.PaddingTop = UDim.new(0, 6)
    UIPadding.PaddingBottom = UDim.new(0, 6)

    -- Credits
    local Credits = Instance.new("TextLabel")
    Credits.Parent = Main
    Credits.Size = UDim2.new(1, -8, 0, 17)
    Credits.Position = UDim2.new(0, 4, 1, -18)
    Credits.BackgroundTransparency = 1
    Credits.Text = CreatorName
    Credits.Font = Enum.Font.Gotham
    Credits.TextSize = 11
    Credits.TextXAlignment = Enum.TextXAlignment.Right

    -- Rainbow Credits
    task.spawn(function()
        while Gui.Parent do
            local hue = (tick() % 5) / 5
            Credits.TextColor3 = Color3.fromHSV(hue,1,1)
            RunService.RenderStepped:Wait()
        end
    end)

    -- Dragging
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPos = Main.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)

    -- Toggle
    local toggled = false

    local function UpdateSize()
        local contentHeight = UIList.AbsoluteContentSize.Y + 12

        if toggled then
            Content.Visible = true
            Content.Size = UDim2.new(1,0,0,contentHeight)
            Main.Size = UDim2.new(0,200,0,36 + contentHeight + 14)
            Credits.Position = UDim2.new(0,4,1,-14)
        else
            Content.Visible = false
            Main.Size = UDim2.new(0,200,0,36)
        end
    end

    UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if toggled then
            UpdateSize()
        end
    end)

    Header.MouseButton1Click:Connect(function()
        toggled = not toggled
        UpdateSize()
    end)

    -- Add Button
    function Window:AddButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Parent = Content
        btn.Size = UDim2.new(1,-12,0,28)
        btn.BackgroundColor3 = Color3.fromRGB(55,55,55)
        btn.Text = text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
        btn.TextColor3 = Color3.fromRGB(220,220,220)
        btn.BorderSizePixel = 0

        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

        btn.MouseButton1Click:Connect(function()
            if callback then
                local ok, err = pcall(callback)
                if not ok then
                    warn(err)
                end
            end
        end)
    end

function Window:AddToggle(text, default, callback)
    local toggled = default or false

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(1, 0, 0, 30)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ToggleButton.TextColor3 = Color3.new(1,1,1)
    ToggleButton.Text = text .. " : " .. (toggled and "ON" or "OFF")
    ToggleButton.Parent = Content

    ToggleButton.MouseButton1Click:Connect(function()
        toggled = not toggled
        ToggleButton.Text = text .. " : " .. (toggled and "ON" or "OFF")

        if callback then
            callback(toggled)
        end
    end)
end
  
    -- Update Title
    function Window:UpdateTitle(newTitle)
        Header.Text = tostring(newTitle)
    end

    return Window
end

function Library:Notify(options)
    local text = options.Text or "Notification"
    local duration = options.Duration or 3
    local icon = options.Icon
    local position = options.Position or "BottomRight"

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CustomNotification"
    screenGui.Parent = game.Players.LocalPlayer.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 60)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    -- Position logic
    if position == "TopLeft" then
        frame.Position = UDim2.new(0, 10, 0, 10)
    elseif position == "TopRight" then
        frame.Position = UDim2.new(1, -260, 0, 10)
    elseif position == "BottomLeft" then
        frame.Position = UDim2.new(0, 10, 1, -70)
    else -- BottomRight default
        frame.Position = UDim2.new(1, -260, 1, -70)
    end

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 50, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    if icon then
        local image = Instance.new("ImageLabel")
        image.Size = UDim2.new(0, 40, 0, 40)
        image.Position = UDim2.new(0, 5, 0.5, -20)
        image.BackgroundTransparency = 1
        image.Image = icon
        image.Parent = frame
    end

    task.delay(duration, function()
        screenGui:Destroy()
    end)
end

return Library
