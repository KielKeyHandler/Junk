--// SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local camera = workspace.CurrentCamera

local player = Players.LocalPlayer

--// ESSENCE FOLDERS
local EssenceFolders = {
    workspace.BlockEssenceSpawns:WaitForChild("Normal"),
    workspace.BlockEssenceSpawns:WaitForChild("Rainbow"),
    workspace.BlockEssenceSpawns:WaitForChild("Red"),
}

local espObjects = {}
local viewing = false
local viewTarget
local camYaw, camPitch = 0,0
local camDistance = 12
local defaultType = camera.CameraType
local defaultSubject = camera.CameraSubject

--// FUNCTIONS
local function addESP(part)
    if espObjects[part] then return end
    local h = Instance.new("Highlight")
    h.FillTransparency = 1
    h.OutlineColor = Color3.fromRGB(178,132,255)
    h.Parent = part
    h.Adornee = part
    espObjects[part] = h
end

local function removeESP(part)
    if espObjects[part] then
        espObjects[part]:Destroy()
        espObjects[part] = nil
    end
end

local function updateCamera()
    if viewing and viewTarget then
        local offset = CFrame.new(0,0,camDistance)
        local rotation = CFrame.Angles(camPitch, camYaw,0)
        camera.CFrame = CFrame.new(viewTarget.Position) * rotation * offset
    end
end

--// GUI SETTINGS
local UI_SETTINGS = {
    MainColor = Color3.fromRGB(5,5,5),
    BorderColor = Color3.fromRGB(178,132,255),
    TextColor = Color3.fromRGB(255,255,255),
    WindowWidth = 400,
    WindowHeight = 200,
    CornerRadius = 15,
    Font = Enum.Font.SourceSansBold,
    ToggleColor = Color3.fromRGB(40,40,40),
    ToggleActiveColor = Color3.fromRGB(178,132,255),
    ToggleSize = UDim2.new(0,40,0,20),
    ToggleCorner = 8,
    ButtonHeight = 22,
    ButtonSpacing = 4,
    CameraSensitivity = 0.004
}

--// CREATE GUI
local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, UI_SETTINGS.WindowWidth, 0, UI_SETTINGS.WindowHeight)
MainFrame.Position = UDim2.new(0.5, -UI_SETTINGS.WindowWidth/2, 0.5, -UI_SETTINGS.WindowHeight/2)
MainFrame.BackgroundColor3 = UI_SETTINGS.MainColor
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, UI_SETTINGS.CornerRadius)
Instance.new("UIStroke", MainFrame).Color = UI_SETTINGS.BorderColor

local TitleLabel = Instance.new("TextLabel", MainFrame)
TitleLabel.Size = UDim2.new(1,-20,0,25)
TitleLabel.Position = UDim2.new(0,10,0,5)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Garcia's Essence GUI"
TitleLabel.Font = UI_SETTINGS.Font
TitleLabel.TextSize = 18
TitleLabel.TextColor3 = UI_SETTINGS.TextColor
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- SCROLL FRAME
local FunctionWindow = Instance.new("ScrollingFrame", MainFrame)
FunctionWindow.Size = UDim2.new(1,-20,1,-40)
FunctionWindow.Position = UDim2.new(0,10,0,35)
FunctionWindow.BackgroundTransparency = 1
FunctionWindow.BorderSizePixel = 0
FunctionWindow.ScrollBarThickness = 6
FunctionWindow.CanvasSize = UDim2.new(0,0,0,0)
FunctionWindow.AutomaticCanvasSize = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout", FunctionWindow)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, UI_SETTINGS.ButtonSpacing)

-- CREATE TELEPORT/VIEW BUTTON
local function createEssenceButton(part)
    addESP(part)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,0,0,UI_SETTINGS.ButtonHeight)
    row.BackgroundTransparency = 1
    row.Parent = FunctionWindow

    -- TELEPORT BUTTON
    local tpBtn = Instance.new("TextButton")
    tpBtn.Size = UDim2.new(0.48,0,1,0)
    tpBtn.Position = UDim2.new(0,0,0,0)
    tpBtn.BackgroundColor3 = UI_SETTINGS.ToggleColor
    tpBtn.BorderSizePixel = 0
    tpBtn.Text = "Teleport"
    tpBtn.TextColor3 = UI_SETTINGS.TextColor
    tpBtn.Font = UI_SETTINGS.Font
    tpBtn.TextSize = 14
    Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0,UI_SETTINGS.ToggleCorner)
    tpBtn.Parent = row

    tpBtn.MouseButton1Click:Connect(function()
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = part.CFrame + Vector3.new(0,3,0)
        end
    end)

    -- VIEW/UNVIEW BUTTON
    local viewBtn = Instance.new("TextButton")
    viewBtn.Size = UDim2.new(0.48,0,1,0)
    viewBtn.Position = UDim2.new(0.52,0,0,0)
    viewBtn.BackgroundColor3 = UI_SETTINGS.ToggleColor
    viewBtn.BorderSizePixel = 0
    viewBtn.Text = "View"
    viewBtn.TextColor3 = UI_SETTINGS.TextColor
    viewBtn.Font = UI_SETTINGS.Font
    viewBtn.TextSize = 14
    Instance.new("UICorner", viewBtn).CornerRadius = UDim.new(0,UI_SETTINGS.ToggleCorner)
    viewBtn.Parent = row

    local draggingCamera = false
    local lastInputPos = nil

    viewBtn.MouseButton1Click:Connect(function()
        if not viewing then
            viewing = true
            viewTarget = part
            defaultType = camera.CameraType
            defaultSubject = camera.CameraSubject
            camera.CameraType = Enum.CameraType.Scriptable
            camYaw, camPitch = 0,0
            updateCamera()
            viewBtn.Text = "Unview"
        else
            viewing = false
            viewTarget = nil
            camera.CameraType = defaultType
            camera.CameraSubject = defaultSubject
            viewBtn.Text = "View"
        end
    end)

    -- MOVABLE VIEW (PC + Mobile)
    UIS.InputBegan:Connect(function(input)
        if viewing and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then
            draggingCamera = true
            lastInputPos = input.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if draggingCamera and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
            local delta = input.Position - lastInputPos
            camYaw = camYaw - delta.X * UI_SETTINGS.CameraSensitivity
            camPitch = math.clamp(camPitch - delta.Y * UI_SETTINGS.CameraSensitivity, -math.pi/2, math.pi/2)
            lastInputPos = input.Position
            updateCamera()
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if draggingCamera and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then
            draggingCamera = false
        end
    end)
end

-- LOAD ALL AVAILABLE ESSENCES
for _,folder in ipairs(EssenceFolders) do
    for _,part in ipairs(folder:GetChildren()) do
        if tonumber(part.Name) then
            createEssenceButton(part)
        end
    end
end

-- AUTO UPDATE SPAWN/DESPAN
for _,folder in ipairs(EssenceFolders) do
    folder.ChildAdded:Connect(function(part)
        if tonumber(part.Name) then createEssenceButton(part) end
    end)
    folder.ChildRemoved:Connect(function(part)
        removeESP(part)
    end)
end

--// DRAGGING GUI (PC + Mobile)
local dragging, dragInput, startPos, startMouse = false, nil, nil, nil
local function updateDrag(input)
    if dragging and startPos and startMouse then
        local delta = input.Position - startMouse
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        startPos = MainFrame.Position
        startMouse = input.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging=false end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
        dragInput=input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input==dragInput then updateDrag(input) end
end)
