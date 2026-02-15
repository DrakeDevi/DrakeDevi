--//====================================================--
--//                DrakeUI Framework                  //
--//      Developed by DrakeDevi & AxlceBlox           //
--//====================================================--
--// Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--// Main Table
local DrakeUI = {}
DrakeUI.__index = DrakeUI

--// Internal Storage
DrakeUI.Windows = {}
DrakeUI.Flags = {}
DrakeUI.Theme = {}

--// Default Theme
DrakeUI.Theme = {
    Background = Color3.fromRGB(20,20,20),
    Topbar = Color3.fromRGB(30,30,30),
    Accent = Color3.fromRGB(0,170,255),
    Text = Color3.fromRGB(240,240,240),
    DarkText = Color3.fromRGB(150,150,150),
    Stroke = Color3.fromRGB(40,40,40)
}

--// Utility Functions
local function Create(class, properties)
    local obj = Instance.new(class)
    for prop, val in pairs(properties) do
        obj[prop] = val
    end
    return obj
end

local function MakeDraggable(frame, dragbar)
    dragbar = dragbar or frame
    local dragging = false
    local dragInput, mousePos, framePos

    dragbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
end

--// Create Window
function DrakeUI:CreateWindow(settings)
    settings = settings or {}
    
    local window = {}
    window.Tabs = {}
    window.CurrentTab = nil

    --// ScreenGui
    local gui = Create("ScreenGui", {
        Name = settings.Name or "DrakeUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    pcall(function()
        gui.Parent = CoreGui
    end)

    --// Main Frame
    local main = Create("Frame", {
        Parent = gui,
        Size = UDim2.fromOffset(520, 420),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = DrakeUI.Theme.Background,
        BorderSizePixel = 0
    })

    Create("UICorner", {
        Parent = main,
        CornerRadius = UDim.new(0, 10)
    })

    Create("UIStroke", {
        Parent = main,
        Thickness = 1,
        Color = DrakeUI.Theme.Stroke
    })

    --// Topbar
    local topbar = Create("Frame", {
        Parent = main,
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = DrakeUI.Theme.Topbar,
        BorderSizePixel = 0
    })

    Create("UICorner", {
        Parent = topbar,
        CornerRadius = UDim.new(0, 10)
    })

    --// Title
    local title = Create("TextLabel", {
        Parent = topbar,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = settings.Name or "DrakeUI Window",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = DrakeUI.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    --// Tab Holder
    local tabHolder = Create("Frame", {
        Parent = main,
        Position = UDim2.new(0, 0, 0, 45),
        Size = UDim2.new(0, 140, 1, -45),
        BackgroundColor3 = DrakeUI.Theme.Topbar,
        BorderSizePixel = 0
    })

    Create("UIListLayout", {
        Parent = tabHolder,
        Padding = UDim.new(0, 6)
    })

    --// Content Holder
    local contentHolder = Create("Frame", {
        Parent = main,
        Position = UDim2.new(0, 140, 0, 45),
        Size = UDim2.new(1, -140, 1, -45),
        BackgroundTransparency = 1
    })

    --// Dragging
    MakeDraggable(main, topbar)

    window.Gui = gui
    window.Main = main
    window.TabHolder = tabHolder
    window.ContentHolder = contentHolder

    --// Hide / Show Keybind
    local visible = true
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            visible = not visible
            gui.Enabled = visible
        end
    end)

    DrakeUI.Windows[#DrakeUI.Windows+1] = window
    return window
end

--//====================================================--
--//                 TAB SYSTEM                        //
--//====================================================--

--// Tab Creation
function DrakeUI:CreateTab(window, settings)
    settings = settings or {}
    local tab = {}
    
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1, -10, 0, 36)
    tabButton.BackgroundColor3 = DrakeUI.Theme.Background
    tabButton.Text = settings.Name or "Tab"
    tabButton.Font = Enum.Font.Gotham
    tabButton.TextSize = 14
    tabButton.TextColor3 = DrakeUI.Theme.DarkText
    tabButton.BorderSizePixel = 0
    tabButton.Parent = window.TabHolder
    
    Instance.new("UICorner", tabButton).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke")
    stroke.Parent = tabButton
    stroke.Color = DrakeUI.Theme.Stroke
    stroke.Thickness = 1
    
    --// Page Frame
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -20, 1, -20)
    page.Position = UDim2.new(0, 10, 0, 10)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.ScrollBarThickness = 4
    page.Visible = false
    page.BackgroundTransparency = 1
    page.Parent = window.ContentHolder
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = page
    layout.Padding = UDim.new(0, 8)
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)
    
    --// Tab Switching Logic
    tabButton.MouseButton1Click:Connect(function()
        
        -- Hide previous
        if window.CurrentTab then
            window.CurrentTab.Page.Visible = false
            TweenService:Create(
                window.CurrentTab.Button,
                TweenInfo.new(0.2),
                {TextColor3 = DrakeUI.Theme.DarkText}
            ):Play()
            
            TweenService:Create(
                window.CurrentTab.Button,
                TweenInfo.new(0.2),
                {BackgroundColor3 = DrakeUI.Theme.Background}
            ):Play()
        end
        
        -- Show current
        window.CurrentTab = tab
        page.Visible = true
        
        TweenService:Create(
            tabButton,
            TweenInfo.new(0.2),
            {TextColor3 = DrakeUI.Theme.Text}
        ):Play()
        
        TweenService:Create(
            tabButton,
            TweenInfo.new(0.2),
            {BackgroundColor3 = DrakeUI.Theme.Accent}
        ):Play()
    end)
    
    -- Auto-select first tab
    if not window.CurrentTab then
        window.CurrentTab = tab
        page.Visible = true
        tabButton.BackgroundColor3 = DrakeUI.Theme.Accent
        tabButton.TextColor3 = DrakeUI.Theme.Text
    end
    
    tab.Button = tabButton
    tab.Page = page
    tab.Window = window
    
    window.Tabs[#window.Tabs+1] = tab
    
    return tab
end

--//====================================================--
--//                 PAGE ANIMATION                    //
--//====================================================--

function DrakeUI:AnimateElement(element)
    element.BackgroundTransparency = 1
    element.Position = element.Position + UDim2.new(0, 0, 0, 10)
    
    TweenService:Create(
        element,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            BackgroundTransparency = 0,
            Position = element.Position - UDim2.new(0, 0, 0, 10)
        }
    ):Play()
end

--//====================================================--
--//               ELEMENT SYSTEM                      //
--//====================================================--

--// Section (Optional Divider Title)
function DrakeUI:CreateSection(tab, titleText)

    local section = Instance.new("TextLabel")
    section.Size = UDim2.new(1, -10, 0, 28)
    section.BackgroundTransparency = 1
    section.Text = titleText or "Section"
    section.Font = Enum.Font.GothamBold
    section.TextSize = 14
    section.TextColor3 = DrakeUI.Theme.Text
    section.TextXAlignment = Enum.TextXAlignment.Left
    section.Parent = tab.Page

    DrakeUI:AnimateElement(section)

    return section
end


--// Button
function DrakeUI:CreateButton(tab, settings)
    settings = settings or {}
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 38)
    button.BackgroundColor3 = DrakeUI.Theme.Background
    button.Text = settings.Name or "Button"
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.TextColor3 = DrakeUI.Theme.Text
    button.BorderSizePixel = 0
    button.Parent = tab.Page
    
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke")
    stroke.Parent = button
    stroke.Color = DrakeUI.Theme.Stroke
    stroke.Thickness = 1
    
    -- Hover Effect
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {
            BackgroundColor3 = DrakeUI.Theme.Accent
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {
            BackgroundColor3 = DrakeUI.Theme.Background
        }):Play()
    end)
    
    -- Click
    button.MouseButton1Click:Connect(function()
        if settings.Callback then
            settings.Callback()
        end
    end)
    
    DrakeUI:AnimateElement(button)
    
    return button
end


--// Toggle
function DrakeUI:CreateToggle(tab, settings)
    settings = settings or {}
    
    local state = settings.Default or false
    
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -10, 0, 38)
    holder.BackgroundColor3 = DrakeUI.Theme.Background
    holder.BorderSizePixel = 0
    holder.Parent = tab.Page
    
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke")
    stroke.Parent = holder
    stroke.Color = DrakeUI.Theme.Stroke
    
    local title = Instance.new("TextLabel")
    title.Parent = holder
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = settings.Name or "Toggle"
    title.Font = Enum.Font.Gotham
    title.TextSize = 14
    title.TextColor3 = DrakeUI.Theme.Text
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggleBtn = Instance.new("Frame")
    toggleBtn.Parent = holder
    toggleBtn.Size = UDim2.fromOffset(40, 20)
    toggleBtn.Position = UDim2.new(1, -50, 0.5, -10)
    toggleBtn.BackgroundColor3 = DrakeUI.Theme.Stroke
    toggleBtn.BorderSizePixel = 0
    
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame")
    circle.Parent = toggleBtn
    circle.Size = UDim2.fromOffset(16, 16)
    circle.Position = UDim2.new(0, 2, 0.5, -8)
    circle.BackgroundColor3 = DrakeUI.Theme.Text
    circle.BorderSizePixel = 0
    
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    local function UpdateToggle()
        if state then
            TweenService:Create(toggleBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = DrakeUI.Theme.Accent
            }):Play()
            
            TweenService:Create(circle, TweenInfo.new(0.2), {
                Position = UDim2.new(1, -18, 0.5, -8)
            }):Play()
        else
            TweenService:Create(toggleBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = DrakeUI.Theme.Stroke
            }):Play()
            
            TweenService:Create(circle, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 2, 0.5, -8)
            }):Play()
        end
        
        if settings.Callback then
            settings.Callback(state)
        end
    end
    
    holder.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            DrakeUI.Flags[settings.Flag or settings.Name] = state
            UpdateToggle()
        end
    end)
    
    UpdateToggle()
    DrakeUI:AnimateElement(holder)
    
    return holder
end

--//====================================================--
--//           ADVANCED ELEMENTS SYSTEM                //
--//====================================================--

--// Dropdown
function DrakeUI:CreateDropdown(tab, settings)
    settings = settings or {}
    local opened = false
    local selected = settings.Default or nil
    
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -10, 0, 40)
    holder.BackgroundColor3 = DrakeUI.Theme.Background
    holder.BorderSizePixel = 0
    holder.Parent = tab.Page
    
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", holder)
    stroke.Color = DrakeUI.Theme.Stroke
    
    local title = Instance.new("TextLabel")
    title.Parent = holder
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = settings.Name or "Dropdown"
    title.Font = Enum.Font.Gotham
    title.TextSize = 14
    title.TextColor3 = DrakeUI.Theme.Text
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local arrow = Instance.new("TextLabel")
    arrow.Parent = holder
    arrow.Size = UDim2.fromOffset(20, 20)
    arrow.Position = UDim2.new(1, -25, 0.5, -10)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 14
    arrow.TextColor3 = DrakeUI.Theme.Text
    
    local dropFrame = Instance.new("Frame")
    dropFrame.Parent = holder
    dropFrame.Position = UDim2.new(0, 0, 1, 5)
    dropFrame.Size = UDim2.new(1, 0, 0, 0)
    dropFrame.BackgroundColor3 = DrakeUI.Theme.Background
    dropFrame.BorderSizePixel = 0
    dropFrame.ClipsDescendants = true
    
    Instance.new("UICorner", dropFrame).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", dropFrame).Color = DrakeUI.Theme.Stroke
    
    local layout = Instance.new("UIListLayout", dropFrame)
    layout.Padding = UDim.new(0, 5)
    
    local function ToggleDropdown()
        opened = not opened
        
        TweenService:Create(dropFrame, TweenInfo.new(0.25), {
            Size = opened and UDim2.new(1, 0, 0, #settings.Options * 32 + 5)
                or UDim2.new(1, 0, 0, 0)
        }):Play()
    end
    
    holder.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            ToggleDropdown()
        end
    end)
    
    for _, option in ipairs(settings.Options or {}) do
        local optionBtn = Instance.new("TextButton")
        optionBtn.Size = UDim2.new(1, -10, 0, 28)
        optionBtn.BackgroundColor3 = DrakeUI.Theme.Stroke
        optionBtn.Text = option
        optionBtn.Font = Enum.Font.Gotham
        optionBtn.TextSize = 13
        optionBtn.TextColor3 = DrakeUI.Theme.Text
        optionBtn.BorderSizePixel = 0
        optionBtn.Parent = dropFrame
        
        Instance.new("UICorner", optionBtn).CornerRadius = UDim.new(0, 6)
        
        optionBtn.MouseButton1Click:Connect(function()
            selected = option
            DrakeUI.Flags[settings.Flag or settings.Name] = option
            title.Text = (settings.Name or "Dropdown") .. ": " .. option
            ToggleDropdown()
            
            if settings.Callback then
                settings.Callback(option)
            end
        end)
    end
    
    DrakeUI:AnimateElement(holder)
    return holder
end


--// Slider
function DrakeUI:CreateSlider(tab, settings)
    settings = settings or {}
    local min = settings.Min or 0
    local max = settings.Max or 100
    local value = settings.Default or min
    
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -10, 0, 50)
    holder.BackgroundColor3 = DrakeUI.Theme.Background
    holder.BorderSizePixel = 0
    holder.Parent = tab.Page
    
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", holder).Color = DrakeUI.Theme.Stroke
    
    local title = Instance.new("TextLabel")
    title.Parent = holder
    title.Size = UDim2.new(1, -20, 0, 20)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = (settings.Name or "Slider") .. ": " .. tostring(value)
    title.Font = Enum.Font.Gotham
    title.TextSize = 13
    title.TextColor3 = DrakeUI.Theme.Text
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local bar = Instance.new("Frame")
    bar.Parent = holder
    bar.Size = UDim2.new(1, -20, 0, 8)
    bar.Position = UDim2.new(0, 10, 0, 30)
    bar.BackgroundColor3 = DrakeUI.Theme.Stroke
    bar.BorderSizePixel = 0
    
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame")
    fill.Parent = bar
    fill.Size = UDim2.new((value - min)/(max - min), 0, 1, 0)
    fill.BackgroundColor3 = DrakeUI.Theme.Accent
    fill.BorderSizePixel = 0
    
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = math.clamp(
                (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X,
                0, 1
            )
            
            value = math.floor(min + (max - min) * percent)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            title.Text = (settings.Name or "Slider") .. ": " .. tostring(value)
            
            DrakeUI.Flags[settings.Flag or settings.Name] = value
            
            if settings.Callback then
                settings.Callback(value)
            end
        end
    end)
    
    DrakeUI:AnimateElement(holder)
    return holder
end


--// Input Box
function DrakeUI:CreateInput(tab, settings)
    settings = settings or {}
    
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -10, 0, 45)
    holder.BackgroundColor3 = DrakeUI.Theme.Background
    holder.BorderSizePixel = 0
    holder.Parent = tab.Page
    
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", holder).Color = DrakeUI.Theme.Stroke
    
    local title = Instance.new("TextLabel")
    title.Parent = holder
    title.Size = UDim2.new(1, -20, 0, 18)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = settings.Name or "Input"
    title.Font = Enum.Font.Gotham
    title.TextSize = 13
    title.TextColor3 = DrakeUI.Theme.Text
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local box = Instance.new("TextBox")
    box.Parent = holder
    box.Size = UDim2.new(1, -20, 0, 20)
    box.Position = UDim2.new(0, 10, 0, 22)
    box.BackgroundColor3 = DrakeUI.Theme.Stroke
    box.Text = settings.Default or ""
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    box.TextColor3 = DrakeUI.Theme.Text
    box.ClearTextOnFocus = false
    box.BorderSizePixel = 0
    
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    
    box.FocusLost:Connect(function()
        DrakeUI.Flags[settings.Flag or settings.Name] = box.Text
        
        if settings.Callback then
            settings.Callback(box.Text)
        end
    end)
    
    DrakeUI:AnimateElement(holder)
    return holder
end

--//====================================================--
--//              THEME MANAGER SYSTEM                 //
--//====================================================--

DrakeUI.Themes = {
    Dark = {
        Background = Color3.fromRGB(30,30,30),
        Accent = Color3.fromRGB(0,170,255),
        Stroke = Color3.fromRGB(50,50,50),
        Text = Color3.fromRGB(255,255,255),
        DarkText = Color3.fromRGB(180,180,180)
    },

    Light = {
        Background = Color3.fromRGB(240,240,240),
        Accent = Color3.fromRGB(0,120,255),
        Stroke = Color3.fromRGB(200,200,200),
        Text = Color3.fromRGB(20,20,20),
        DarkText = Color3.fromRGB(80,80,80)
    },

    Neon = {
        Background = Color3.fromRGB(20,20,25),
        Accent = Color3.fromRGB(0,255,140),
        Stroke = Color3.fromRGB(40,40,45),
        Text = Color3.fromRGB(0,255,140),
        DarkText = Color3.fromRGB(120,255,200)
    }
}

function DrakeUI:SetTheme(themeName)
    if DrakeUI.Themes[themeName] then
        DrakeUI.Theme = DrakeUI.Themes[themeName]
        DrakeUI:Notify("Theme switched to "..themeName, 3)
    end
end

--//====================================================--
--//              NOTIFICATION SYSTEM                  //
--//====================================================--

function DrakeUI:CreateNotificationHolder()
    if DrakeUI.NotificationHolder then return end
    
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(0, 300, 1, -20)
    holder.Position = UDim2.new(1, -310, 0, 10)
    holder.BackgroundTransparency = 1
    holder.Parent = DrakeUI.ScreenGui
    
    local layout = Instance.new("UIListLayout", holder)
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    
    DrakeUI.NotificationHolder = holder
end

function DrakeUI:Notify(text, duration)
    duration = duration or 3
    DrakeUI:CreateNotificationHolder()
    
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 0, 0, 50)
    notif.BackgroundColor3 = DrakeUI.Theme.Background
    notif.BorderSizePixel = 0
    notif.Parent = DrakeUI.NotificationHolder
    
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke", notif)
    stroke.Color = DrakeUI.Theme.Accent
    
    local label = Instance.new("TextLabel")
    label.Parent = notif
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextWrapped = true
    label.TextColor3 = DrakeUI.Theme.Text
    
    notif.Position = notif.Position + UDim2.new(1,0,0,0)
    
    TweenService:Create(notif, TweenInfo.new(0.3), {
        Position = notif.Position - UDim2.new(1,0,0,0)
    }):Play()
    
    task.delay(duration, function()
        TweenService:Create(notif, TweenInfo.new(0.3), {
            Position = notif.Position + UDim2.new(1,0,0,0)
        }):Play()
        
        task.wait(0.3)
        notif:Destroy()
    end)
end

--//====================================================--
--//              CONFIG SAVE / LOAD                   //
--//====================================================--

DrakeUI.ConfigFolder = "DrakeUIConfigs"

local HttpService = game:GetService("HttpService")

function DrakeUI:SaveConfig(name)
    if not writefile then
        DrakeUI:Notify("Executor does not support writefile.", 3)
        return
    end
    
    if not isfolder(DrakeUI.ConfigFolder) then
        makefolder(DrakeUI.ConfigFolder)
    end
    
    local encoded = HttpService:JSONEncode(DrakeUI.Flags)
    writefile(DrakeUI.ConfigFolder.."/"..name..".json", encoded)
    
    DrakeUI:Notify("Config saved: "..name, 3)
end

function DrakeUI:LoadConfig(name)
    if not readfile then
        DrakeUI:Notify("Executor does not support readfile.", 3)
        return
    end
    
    local path = DrakeUI.ConfigFolder.."/"..name..".json"
    
    if not isfile(path) then
        DrakeUI:Notify("Config not found.", 3)
        return
    end
    
    local decoded = HttpService:JSONDecode(readfile(path))
    
    for flag, value in pairs(decoded) do
        DrakeUI.Flags[flag] = value
    end
    
    DrakeUI:Notify("Config loaded: "..name, 3)
end

--//====================================================--
--//           AUTO CONFIG LOAD SYSTEM                 //
--//====================================================--

DrakeUI.AutoLoadConfig = "autoload"

function DrakeUI:EnableAutoLoad(name)
    DrakeUI.AutoLoadConfig = name
    DrakeUI:Notify("Autoload set to "..name, 3)
end

task.spawn(function()
    task.wait(1)
    if DrakeUI.AutoLoadConfig then
        DrakeUI:LoadConfig(DrakeUI.AutoLoadConfig)
    end
end)

--//====================================================--
--//                MINIMIZE SYSTEM                    //
--//====================================================--

function DrakeUI:AddMinimize(window)

    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(30, 30)
    button.Position = UDim2.new(1, -35, 0, 5)
    button.Text = "-"
    button.Font = Enum.Font.GothamBold
    button.TextSize = 16
    button.BackgroundColor3 = DrakeUI.Theme.Accent
    button.TextColor3 = DrakeUI.Theme.Text
    button.Parent = window.Main
    
    Instance.new("UICorner", button).CornerRadius = UDim.new(1,0)

    local minimized = false

    button.MouseButton1Click:Connect(function()
        minimized = not minimized
        
        TweenService:Create(window.ContentHolder, TweenInfo.new(0.3), {
            Size = minimized and UDim2.new(1,0,0,0)
                or UDim2.new(1,0,1,-50)
        }):Play()
    end)
end

--//====================================================--
--//               WATERMARK SYSTEM                    //
--//====================================================--

function DrakeUI:AddWatermark(text)
    local mark = Instance.new("TextLabel")
    mark.Size = UDim2.fromOffset(250, 25)
    mark.Position = UDim2.new(0, 10, 1, -35)
    mark.BackgroundTransparency = 1
    mark.Text = text or "DrakeUI Premium"
    mark.Font = Enum.Font.Gotham
    mark.TextSize = 14
    mark.TextColor3 = DrakeUI.Theme.Accent
    mark.TextXAlignment = Enum.TextXAlignment.Left
    mark.Parent = DrakeUI.ScreenGui
    
    DrakeUI.Watermark = mark
end

--//====================================================--
--//                 FPS COUNTER                       //
--//====================================================--

function DrakeUI:AddFPSCounter()

    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.fromOffset(120, 25)
    fpsLabel.Position = UDim2.new(1, -130, 1, -35)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Font = Enum.Font.Gotham
    fpsLabel.TextSize = 14
    fpsLabel.TextColor3 = DrakeUI.Theme.Accent
    fpsLabel.Parent = DrakeUI.ScreenGui

    local RunService = game:GetService("RunService")
    local last = tick()
    local frames = 0

    RunService.RenderStepped:Connect(function()
        frames += 1
        if tick() - last >= 1 then
            fpsLabel.Text = "FPS: "..frames
            frames = 0
            last = tick()
        end
    end)
end

--//====================================================--
--//                 KEYBIND ELEMENT                   //
--//====================================================--

function DrakeUI:CreateKeybind(tab, settings)
    settings = settings or {}
    local currentKey = settings.Default or Enum.KeyCode.RightControl
    
    local holder = Instance.new("TextButton")
    holder.Size = UDim2.new(1,-10,0,38)
    holder.BackgroundColor3 = DrakeUI.Theme.Background
    holder.Text = settings.Name.." ["..currentKey.Name.."]"
    holder.Font = Enum.Font.Gotham
    holder.TextSize = 14
    holder.TextColor3 = DrakeUI.Theme.Text
    holder.BorderSizePixel = 0
    holder.Parent = tab.Page
    
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0,8)
    Instance.new("UIStroke", holder).Color = DrakeUI.Theme.Stroke
    
    local listening = false
    
    holder.MouseButton1Click:Connect(function()
        holder.Text = "Press any key..."
        listening = true
    end)
    
    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if listening and input.KeyCode ~= Enum.KeyCode.Unknown then
            currentKey = input.KeyCode
            holder.Text = settings.Name.." ["..currentKey.Name.."]"
            listening = false
            
            DrakeUI.Flags[settings.Flag or settings.Name] = currentKey.Name
        end
        
        if input.KeyCode == currentKey then
            if settings.Callback then
                settings.Callback()
            end
        end
    end)
    
    DrakeUI:AnimateElement(holder)
end

--//====================================================--
--//                BLUR BACKGROUND                    //
--//====================================================--

function DrakeUI:EnableBlur()
    local blur = Instance.new("BlurEffect")
    blur.Size = 15
    blur.Parent = game:GetService("Lighting")
    
    DrakeUI:Notify("Blur enabled", 3)
end

--//====================================================--
--//             GRADIENT ACCENT ENGINE                //
--//====================================================--

function DrakeUI:ApplyGradientAccent(frame)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, DrakeUI.Theme.Accent),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
    }
    gradient.Rotation = 45
    gradient.Parent = frame
end

--//====================================================--
--//                DrakeUI CORE ENGINE                  //
--//====================================================--

-- Element Registry
DrakeUI.Elements = {}
DrakeUI.Connections = {}

--// Centralized connection manager
function DrakeUI:BindConnection(signal, func)
    local conn = signal:Connect(func)
    table.insert(DrakeUI.Connections, conn)
    return conn
end

function DrakeUI:Cleanup()
    for _, conn in ipairs(DrakeUI.Connections) do
        pcall(function()
            conn:Disconnect()
        end)
    end
    DrakeUI.Connections = {}
end

--// Register element to registry
function DrakeUI:RegisterElement(flag, object, elementType, updateFunc)
    DrakeUI.Elements[flag] = {
        Object = object,
        Type = elementType,
        Update = updateFunc
    }
end

--// Programmatic Flag Setter
function DrakeUI:SetFlag(flag, value)
    DrakeUI.Flags[flag] = value
    
    if DrakeUI.Elements[flag] then
        if DrakeUI.Elements[flag].Update then
            DrakeUI.Elements[flag].Update(value)
        end
    end
end

--// Get Flag
function DrakeUI:GetFlag(flag)
    return DrakeUI.Flags[flag]
end

--//====================================================--
--//           LIVE THEME REFRESH ENGINE               //
--//====================================================--

function DrakeUI:RefreshTheme()

    for _, element in pairs(DrakeUI.Elements) do
        if element.Object and element.Object.Parent then
            
            if element.Type == "Button" then
                element.Object.BackgroundColor3 = DrakeUI.Theme.Background
                element.Object.TextColor3 = DrakeUI.Theme.Text
            
            elseif element.Type == "Toggle" then
                element.Object.BackgroundColor3 = DrakeUI.Theme.Background
            
            elseif element.Type == "Dropdown" then
                element.Object.BackgroundColor3 = DrakeUI.Theme.Background
            
            elseif element.Type == "Slider" then
                element.Object.BackgroundColor3 = DrakeUI.Theme.Background
            
            elseif element.Type == "Input" then
                element.Object.BackgroundColor3 = DrakeUI.Theme.Background
            end
            
        end
    end

    DrakeUI:Notify("Theme Refreshed", 2)
end

-- Override SetTheme to auto refresh
local oldSetTheme = DrakeUI.SetTheme

function DrakeUI:SetTheme(themeName)
    if DrakeUI.Themes[themeName] then
        DrakeUI.Theme = DrakeUI.Themes[themeName]
        DrakeUI:RefreshTheme()
        DrakeUI:Notify("Elite Theme switched: "..themeName, 3)
    end
end

--//====================================================--
--//           DrakeUI TAB INDICATOR SYSTEM              //
--//====================================================--

function DrakeUI:AddTabIndicator(window)

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 4, 0, 36)
    indicator.BackgroundColor3 = DrakeUI.Theme.Accent
    indicator.BorderSizePixel = 0
    indicator.Parent = window.TabHolder

    window.TabIndicator = indicator

    for _, tab in ipairs(window.Tabs) do
        DrakeUI:BindConnection(tab.Button.MouseButton1Click, function()
            TweenService:Create(indicator, TweenInfo.new(0.25), {
                Position = UDim2.new(0, 0, 0, tab.Button.Position.Y.Offset)
            }):Play()
        end)
    end
end

--//====================================================--
--//           DrakeUI CONFIG AUTO SYNC                  //
--//====================================================--

function DrakeUI:SyncLoadedConfig()
    for flag, value in pairs(DrakeUI.Flags) do
        DrakeUI:SetFlag(flag, value)
    end
end

-- Hook into LoadConfig
local oldLoad = DrakeUI.LoadConfig

function DrakeUI:LoadConfig(name)
    oldLoad(self, name)
    DrakeUI:SyncLoadedConfig()
end

--//====================================================--
--//              DrakeUI DOCK SYSTEM                    //
--//====================================================--

function DrakeUI:SetDockMode(window, mode)
    -- Modes: "Sidebar", "Topbar", "Floating"

    if mode == "Sidebar" then
        window.TabHolder.Size = UDim2.new(0, 160, 1, -50)
        window.TabHolder.Position = UDim2.new(0, 0, 0, 50)
        window.ContentHolder.Position = UDim2.new(0, 170, 0, 50)
        window.ContentHolder.Size = UDim2.new(1, -180, 1, -60)

    elseif mode == "Topbar" then
        window.TabHolder.Size = UDim2.new(1, 0, 0, 40)
        window.TabHolder.Position = UDim2.new(0, 0, 0, 50)
        window.ContentHolder.Position = UDim2.new(0, 10, 0, 100)
        window.ContentHolder.Size = UDim2.new(1, -20, 1, -110)

    elseif mode == "Floating" then
        window.Main.Size = UDim2.new(0, 600, 0, 450)
    end

    DrakeUI:Notify("Dock mode: "..mode, 2)
end

--//====================================================--
--//              DrakeUI DEBUG CONSOLE                  //
--//====================================================--

DrakeUI.Logger = {}
DrakeUI.ConsoleVisible = false

function DrakeUI:Log(message)
    table.insert(DrakeUI.Logger, "["..os.date("%X").."] "..message)
end

function DrakeUI:OpenConsole()

    if DrakeUI.ConsoleVisible then return end
    DrakeUI.ConsoleVisible = true

    local console = Instance.new("Frame")
    console.Size = UDim2.new(0, 500, 0, 300)
    console.Position = UDim2.new(0.5, -250, 0.5, -150)
    console.BackgroundColor3 = DrakeUI.Theme.Background
    console.Parent = DrakeUI.ScreenGui

    Instance.new("UICorner", console).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", console).Color = DrakeUI.Theme.Accent

    local box = Instance.new("TextLabel")
    box.Size = UDim2.new(1, -20, 1, -20)
    box.Position = UDim2.new(0, 10, 0, 10)
    box.BackgroundTransparency = 1
    box.TextWrapped = true
    box.TextYAlignment = Enum.TextYAlignment.Top
    box.Font = Enum.Font.Code
    box.TextSize = 13
    box.TextColor3 = DrakeUI.Theme.Text
    box.Parent = console

    box.Text = table.concat(DrakeUI.Logger, "\n")

    DrakeUI.Console = console
end

--//====================================================--
--//          DrakeUI ENCRYPTED CONFIG SYSTEM            //
--//====================================================--

local HttpService = game:GetService("HttpService")

local function SimpleEncrypt(text)
    return HttpService:Base64Encode(text)
end

local function SimpleDecrypt(text)
    return HttpService:Base64Decode(text)
end

function DrakeUI:SaveConfigSecure(name)

    if not writefile then return end
    if not isfolder(DrakeUI.ConfigFolder) then
        makefolder(DrakeUI.ConfigFolder)
    end

    local json = HttpService:JSONEncode(DrakeUI.Flags)
    local encrypted = SimpleEncrypt(json)

    writefile(DrakeUI.ConfigFolder.."/"..name..".secure", encrypted)

    DrakeUI:Notify("Encrypted config saved.", 3)
end

function DrakeUI:LoadConfigSecure(name)

    if not readfile then return end

    local path = DrakeUI.ConfigFolder.."/"..name..".secure"
    if not isfile(path) then return end

    local decrypted = SimpleDecrypt(readfile(path))
    local decoded = HttpService:JSONDecode(decrypted)

    DrakeUI.Flags = decoded
    DrakeUI:SyncLoadedConfig()

    DrakeUI:Notify("Encrypted config loaded.", 3)
end

--//====================================================--
--//          RESPONSIVE SCALING ENGINE                //
--//====================================================--

function DrakeUI:EnableResponsiveScaling(window)

    local camera = workspace.CurrentCamera

    local function UpdateScale()
        local size = camera.ViewportSize
        local scaleFactor = math.clamp(size.X / 1920, 0.6, 1)

        window.Main.UIScale = window.Main:FindFirstChild("UIScale") or Instance.new("UIScale", window.Main)
        window.Main.UIScale.Scale = scaleFactor
    end

    UpdateScale()

    game:GetService("RunService").RenderStepped:Connect(UpdateScale)
end

--//====================================================--
--//          DrakeUI TWEEN ENGINE V2                    //
--//====================================================--

DrakeUI.TweenCache = {}

function DrakeUI:SmartTween(object, time, properties)
    if DrakeUI.TweenCache[object] then
        DrakeUI.TweenCache[object]:Cancel()
    end

    local tween = TweenService:Create(
        object,
        TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        properties
    )

    DrakeUI.TweenCache[object] = tween
    tween:Play()
end