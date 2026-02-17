--[[ 
    UI LIBRARY - INSTANT UGC 
    Refactored by: FynxBlox
    Original Credits: FynxBlox
]]

local Library = {}
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

-- ================= LIBRARY LOGIC =================

function Library:CreateWindow(Config)
    local Window = {}
    local TitleText = Config.Title or "UI Library"
    local CreatorName = Config.Creator or "Credits: FynxBlox"
    
    -- 1. ScreenGui Setup
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "CustomLibrary"
    Gui.ResetOnSpawn = false
    Gui.Parent = Player:WaitForChild("PlayerGui")

    -- 2. Main Frame
    local Main = Instance.new("Frame", Gui)
    Main.Name = "MainFrame"
    Main.Size = UDim2.new(0, 200, 0, 36) -- Start closed
    Main.Position = UDim2.new(0.5, -100, 0.35, 0)
    Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Selectable = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

    -- 3. Title Header (Click to Open/Close)
    local Header = Instance.new("TextButton", Main)
    Header.Size = UDim2.new(1, -10, 0, 36)
    Header.Position = UDim2.new(0, 5, 0, 0)
    Header.BackgroundTransparency = 1
    Header.Text = "" .. TitleText
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 12
    Header.TextColor3 = Color3.fromRGB(235,235,235)
    Header.TextXAlignment = Enum.TextXAlignment.Left

    -- 4. Content Container
    local Content = Instance.new("Frame", Main)
    Content.Name = "Content"
    Content.Position = UDim2.new(0, 0, 0, 36)
    Content.Size = UDim2.new(1, 0, 0, 0) -- Starts height 0
    Content.BackgroundColor3 = Color3.fromRGB(35,35,35)
    Content.BorderSizePixel = 0
    Content.Visible = false
    Content.ClipsDescendants = true
    Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 8)

    -- Layout for Buttons
    local UIList = Instance.new("UIListLayout", Content)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 4)
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    -- Padding for list
    local UIPadding = Instance.new("UIPadding", Content)
    UIPadding.PaddingTop = UDim.new(0, 6)
    UIPadding.PaddingBottom = UDim.new(0, 20) -- Room for credits

    -- 5. Credits (Rainbow)
    local Credits = Instance.new("TextLabel", Main) -- Parented to Main so it moves with resize, but we adjust pos
    Credits.Size = UDim2.new(1, -8, 0, 12)
    Credits.BackgroundTransparency = 1
    Credits.Text = CreatorName
    Credits.Font = Enum.Font.Gotham
    Credits.TextSize = 9
    Credits.TextXAlignment = Enum.TextXAlignment.Right
    Credits.ZIndex = 5 -- On top
    
    -- Rainbow Logic
    task.spawn(function()
        while Main.Parent do
            local hue = tick() % 5 / 5
            local color = Color3.fromHSV(hue, 1, 1)
            Credits.TextColor3 = color
            RunService.RenderStepped:Wait()
        end
    end)

    -- 6. Dragging Logic
    local dragging, dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)

    -- 7. Toggle Logic
    local toggled = false
    local function UpdateSize()
        local contentHeight = UIList.AbsoluteContentSize.Y + 25 -- +25 for padding/credits area
        if toggled then
            Content.Visible = true
            Content.Size = UDim2.new(1, 0, 0, contentHeight)
            Main.Size = UDim2.new(0, 200, 0, 36 + contentHeight)
            Credits.Position = UDim2.new(0, -4, 1, -14) -- Bottom right
        else
            Content.Visible = false
            Main.Size = UDim2.new(0, 200, 0, 36)
        end
    end

    Header.MouseButton1Click:Connect(function()
        toggled = not toggled
        UpdateSize()
    end)

    -- 8. Add Button Function
    function Window:AddButton(text, callback)
        local btn = Instance.new("TextButton", Content)
        btn.Size = UDim2.new(1, -12, 0, 28)
        btn.BackgroundColor3 = Color3.fromRGB(55,55,55)
        btn.Text = "" .. text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
        btn.TextColor3 = Color3.fromRGB(220,220,220)
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            pcall(callback)
        end)
        
        -- Update size if currently open
        if toggled then UpdateSize() end
    end
    
    -- Function to update title later if needed
    function Window:UpdateTitle(newTitle)
        Header.Text = "" .. newTitle
    end

    return Window
end
