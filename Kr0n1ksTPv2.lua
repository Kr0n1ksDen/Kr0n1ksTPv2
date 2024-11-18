local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Create a ScreenGui to hold our UI elements first
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Kr0n1ksTPGui"
ScreenGui.Parent = CoreGui

-- Create SavedNamesListLayout early since we'll need it
local SavedNamesListLayout = Instance.new("UIListLayout")
SavedNamesListLayout.SortOrder = Enum.SortOrder.LayoutOrder
SavedNamesListLayout.Padding = UDim.new(0, 5)

-- Create a ScreenGui for the loading sequence
local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "LoadingGui"
LoadingGui.Parent = CoreGui

-- Create a Frame for the loading message
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(0, 300, 0, 100)
LoadingFrame.Position = UDim2.new(0.5, -150, 0.5, -50)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
LoadingFrame.BorderSizePixel = 0
LoadingFrame.Parent = LoadingGui

local LoadingUICorner = Instance.new("UICorner")
LoadingUICorner.CornerRadius = UDim.new(0, 10)
LoadingUICorner.Parent = LoadingFrame

local LoadingText = Instance.new("TextLabel")
LoadingText.Size = UDim2.new(1, 0, 1, 0)
LoadingText.BackgroundTransparency = 1
LoadingText.Font = Enum.Font.GothamBold
LoadingText.TextColor3 = Color3.new(1, 1, 1)
LoadingText.TextSize = 18
LoadingText.Text = "This script was made by Kr0n1k ;)"
LoadingText.Parent = LoadingFrame

-- Function to show loading sequence
local function showLoadingSequence(isGoodbye)
    local text = isGoodbye and "Goodbye!" or "This script was made by Kr0n1k ;)"
    LoadingText.Text = text
    LoadingFrame.Position = UDim2.new(0.5, -150, 1.5, 0)
    local goal = {}
    goal.Position = UDim2.new(0.5, -150, 0.5, -50)
    local tween = TweenService:Create(LoadingFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
    tween:Play()
    wait(2)
    goal.Position = UDim2.new(0.5, -150, -0.5, 0)
    tween = TweenService:Create(LoadingFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), goal)
    tween:Play()
    wait(0.5)
    LoadingGui:Destroy()
end

-- Show loading sequence
showLoadingSequence(false)

-- Player name memory system
local PlayerMemory = {}

-- Settings
local Settings = {
    ShowNotifications = true,
    SavePlayerNames = true
}

-- Function to save settings
local function SaveSettings()
    writefile("Kr0n1ksTPSettings.json", HttpService:JSONEncode(Settings))
end

-- Function to load settings
local function LoadSettings()
    if isfile("Kr0n1ksTPSettings.json") then
        Settings = HttpService:JSONDecode(readfile("Kr0n1ksTPSettings.json"))
    end
end

-- Load settings when the script starts
LoadSettings()

-- Function to save player names
local function SavePlayerNames()
    if Settings.SavePlayerNames then
        local players = Players:GetPlayers()
        PlayerMemory = {}
        for _, player in ipairs(players) do
            table.insert(PlayerMemory, player.Name)
        end
        -- Save to file
        writefile("PlayerMemory.json", HttpService:JSONEncode(PlayerMemory))
    end
end

-- Function to load player names
local function LoadPlayerNames()
    if isfile("PlayerMemory.json") then
        PlayerMemory = HttpService:JSONDecode(readfile("PlayerMemory.json"))
    end
end

-- Load player names when the script starts
LoadPlayerNames()

-- Function to show notification
local function ShowNotification(message)
    if Settings.ShowNotifications then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Player Alert";
            Text = message;
            Duration = 5;
        })
    end
end

-- Define updateSavedNamesList function early
local SavedNamesList
local Input
local function updateSavedNamesList()
    if not SavedNamesList then return end
    
    -- Clear existing buttons
    for _, v in ipairs(SavedNamesList:GetChildren()) do
        if v:IsA("TextButton") then
            v:Destroy()
        end
    end
    
    -- Add new buttons
    for _, name in ipairs(PlayerMemory or {}) do
        local nameButton = Instance.new("TextButton")
        nameButton.Size = UDim2.new(1, 0, 0, 30)
        nameButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        nameButton.BorderSizePixel = 0
        nameButton.Font = Enum.Font.Gotham
        nameButton.TextColor3 = Color3.new(1, 1, 1)
        nameButton.TextSize = 14
        nameButton.Text = name
        nameButton.Parent = SavedNamesList
        
        nameButton.MouseButton1Click:Connect(function()
            if Input then
                Input.Text = name
            end
        end)
    end
    
    if SavedNamesListLayout then
        SavedNamesList.CanvasSize = UDim2.new(0, 0, 0, SavedNamesListLayout.AbsoluteContentSize.Y)
    end
end

-- Save player names and show notification when players are added
Players.PlayerAdded:Connect(function(player)
    if not table.find(PlayerMemory, player.Name) then
        table.insert(PlayerMemory, player.Name)
        SavePlayerNames()
        ShowNotification(player.Name .. " joined the game!")
    else
        ShowNotification(player.Name .. " (saved player) joined the game!")
    end
    pcall(updateSavedNamesList)
end)

-- Remove player from memory and show notification when players leave
Players.PlayerRemoving:Connect(function(player)
    local index = table.find(PlayerMemory, player.Name)
    if index then
        table.remove(PlayerMemory, index)
        SavePlayerNames()
    end
    ShowNotification(player.Name .. " left the game!")
    pcall(updateSavedNamesList)
end)

-- Save player names periodically (every 5 minutes)
spawn(function()
    while wait(300) do
        SavePlayerNames()
        pcall(updateSavedNamesList)
    end
end)

function GetShortenedPlrFromName(name)
    name = string.lower(tostring(name))
 
    if not game:GetService("Players"):FindFirstChild("me") and name == "me" or game:GetService("Players"):FindFirstChild("me") and game:GetService("Players"):FindFirstChild("me").ClassName ~= "Player" and name == "me" then
        return {LocalPlayer}
    end
    if not game:GetService("Players"):FindFirstChild("all") and name == "all" or game:GetService("Players"):FindFirstChild("all") and game:GetService("Players"):FindFirstChild("all").ClassName ~= "Player" and name == "all" then
        return game:GetService("Players"):GetPlayers()
    end
    if not game:GetService("Players"):FindFirstChild("others") and name == "others" or game:GetService("Players"):FindFirstChild("others") and game:GetService("Players"):FindFirstChild("others").ClassName ~= "Player" and name == "others" then
        name = game:GetService("Players"):GetPlayers()
        for i, v in pairs(name) do
            if v == LocalPlayer then
                table.remove(name, i)
            end
        end
        return name
    end
 
    for i, v in pairs(game.Players:GetPlayers()) do
        if string.lower(string.sub(v.DisplayName, 1, #name)) == name or string.lower(string.sub(v.Name, 1, #name)) == name then
            return {v}
        end
    end
 
    return nil
end

-- Create a Frame for our teleport UI
local TeleportFrame = Instance.new("Frame")
TeleportFrame.Size = UDim2.new(0, 220, 0, 305)
TeleportFrame.Position = UDim2.new(1, 0, 0.5, -152.5)
TeleportFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TeleportFrame.BorderSizePixel = 0
TeleportFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = TeleportFrame

local TextLabel = Instance.new("TextLabel")
TextLabel.Size = UDim2.new(1, -30, 0, 40)
TextLabel.Position = UDim2.new(0, 0, 0, 0)
TextLabel.BackgroundTransparency = 1
TextLabel.Font = Enum.Font.GothamBold
TextLabel.TextColor3 = Color3.new(1, 1, 1)
TextLabel.TextSize = 18
TextLabel.Text = "Kr0n1ks Teleporter V2"
TextLabel.Parent = TeleportFrame

-- Create a close button (X)
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.TextSize = 18
CloseButton.Text = "X"
CloseButton.Parent = TeleportFrame

Input = Instance.new("TextBox")
Input.Size = UDim2.new(0.9, 0, 0, 35)
Input.Position = UDim2.new(0.05, 0, 0.18, 0)
Input.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Input.BorderSizePixel = 0
Input.Font = Enum.Font.Gotham
Input.TextColor3 = Color3.new(1, 1, 1)
Input.TextSize = 14
Input.PlaceholderText = "Enter player name"
Input.Text = ""
Input.Parent = TeleportFrame
Input.ClearTextOnFocus = false

local InputUICorner = Instance.new("UICorner")
InputUICorner.CornerRadius = UDim.new(0, 5)
InputUICorner.Parent = Input

-- Create a button for the player selection tool
local SelectPlayerButton = Instance.new("TextButton")
SelectPlayerButton.Size = UDim2.new(0.9, 0, 0, 35)
SelectPlayerButton.Position = UDim2.new(0.05, 0, 0.33, 0)
SelectPlayerButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SelectPlayerButton.BorderSizePixel = 0
SelectPlayerButton.Font = Enum.Font.Gotham
SelectPlayerButton.TextColor3 = Color3.new(1, 1, 1)
SelectPlayerButton.TextSize = 14
SelectPlayerButton.Text = "Select Player"
SelectPlayerButton.Parent = TeleportFrame

local SelectPlayerUICorner = Instance.new("UICorner")
SelectPlayerUICorner.CornerRadius = UDim.new(0, 5)
SelectPlayerUICorner.Parent = SelectPlayerButton

-- Create a new button for teleporting
local TeleportButton = Instance.new("TextButton")
TeleportButton.Size = UDim2.new(0.9, 0, 0, 35)
TeleportButton.Position = UDim2.new(0.05, 0, 0.48, 0)
TeleportButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
TeleportButton.BorderSizePixel = 0
TeleportButton.Font = Enum.Font.GothamBold
TeleportButton.TextColor3 = Color3.new(1, 1, 1)
TeleportButton.TextSize = 14
TeleportButton.Text = "Teleport"
TeleportButton.Parent = TeleportFrame

local TeleportUICorner = Instance.new("UICorner")
TeleportUICorner.CornerRadius = UDim.new(0, 5)
TeleportUICorner.Parent = TeleportButton

-- Create a new button for click teleport
local ClickTeleportButton = Instance.new("TextButton")
ClickTeleportButton.Size = UDim2.new(0.9, 0, 0, 35)
ClickTeleportButton.Position = UDim2.new(0.05, 0, 0.63, 0)
ClickTeleportButton.BackgroundColor3 = Color3.fromRGB(0, 180, 60)
ClickTeleportButton.BorderSizePixel = 0
ClickTeleportButton.Font = Enum.Font.GothamBold
ClickTeleportButton.TextColor3 = Color3.new(1, 1, 1)
ClickTeleportButton.TextSize = 14
ClickTeleportButton.Text = "Click Teleport"
ClickTeleportButton.Parent = TeleportFrame

local ClickTeleportUICorner = Instance.new("UICorner")
ClickTeleportUICorner.CornerRadius = UDim.new(0, 5)
ClickTeleportUICorner.Parent = ClickTeleportButton

-- Create a new button for saved names
local SavedNamesButton = Instance.new("TextButton")
SavedNamesButton.Size = UDim2.new(0.9, 0, 0, 35)
SavedNamesButton.Position = UDim2.new(0.05, 0, 0.78, 0)
SavedNamesButton.BackgroundColor3 = Color3.fromRGB(180, 0, 180)
SavedNamesButton.BorderSizePixel = 0
SavedNamesButton.Font = Enum.Font.GothamBold
SavedNamesButton.TextColor3 = Color3.new(1, 1, 1)
SavedNamesButton.TextSize = 14
SavedNamesButton.Text = "Saved Names"
SavedNamesButton.Parent = TeleportFrame

local SavedNamesUICorner = Instance.new("UICorner")
SavedNamesUICorner.CornerRadius = UDim.new(0, 5)
SavedNamesUICorner.Parent = SavedNamesButton

-- Create a new button for settings
local SettingsButton = Instance.new("TextButton")
SettingsButton.Size = UDim2.new(0.9, 0, 0, 35)
SettingsButton.Position = UDim2.new(0.05, 0, 0.93, 0)
SettingsButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
SettingsButton.BorderSizePixel = 0
SettingsButton.Font = Enum.Font.GothamBold
SettingsButton.TextColor3 = Color3.new(1, 1, 1)
SettingsButton.TextSize = 14
SettingsButton.Text = "Settings"
SettingsButton.Parent = TeleportFrame

local SettingsUICorner = Instance.new("UICorner")
SettingsUICorner.CornerRadius = UDim.new(0, 5)
SettingsUICorner.Parent = SettingsButton

-- Create a new frame for saved names
local SavedNamesFrame = Instance.new("Frame")
SavedNamesFrame.Size = UDim2.new(0, 200, 0, 300)
SavedNamesFrame.Position = UDim2.new(0.5, -100, 0.5, -150)
SavedNamesFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SavedNamesFrame.BorderSizePixel = 0
SavedNamesFrame.Visible = false
SavedNamesFrame.Parent = ScreenGui

local SavedNamesUICorner = Instance.new("UICorner")
SavedNamesUICorner.CornerRadius = UDim.new(0, 10)
SavedNamesUICorner.Parent = SavedNamesFrame

local SavedNamesTitle = Instance.new("TextLabel")
SavedNamesTitle.Size = UDim2.new(1, -30, 0, 40)
SavedNamesTitle.Position = UDim2.new(0, 0, 0, 0)
SavedNamesTitle.BackgroundTransparency = 1
SavedNamesTitle.Font = Enum.Font.GothamBold
SavedNamesTitle.TextColor3 = Color3.new(1, 1, 1)
SavedNamesTitle.TextSize = 18
SavedNamesTitle.Text = "Saved Names"
SavedNamesTitle.Parent = SavedNamesFrame

local SavedNamesCloseButton = Instance.new("TextButton")
SavedNamesCloseButton.Size = UDim2.new(0, 30, 0, 30)
SavedNamesCloseButton.Position = UDim2.new(1, -30, 0, 0)
SavedNamesCloseButton.BackgroundTransparency = 1
SavedNamesCloseButton.Font = Enum.Font.GothamBold
SavedNamesCloseButton.TextColor3 = Color3.new(1, 1, 1)
SavedNamesCloseButton.TextSize = 18
SavedNamesCloseButton.Text = "X"
SavedNamesCloseButton.Parent = SavedNamesFrame

-- Create our single SavedNamesList here
SavedNamesList = Instance.new("ScrollingFrame")
SavedNamesList.Size = UDim2.new(0.9, 0, 0.8, 0)
SavedNamesList.Position = UDim2.new(0.05, 0, 0.15, 0)
SavedNamesList.BackgroundTransparency = 1
SavedNamesList.BorderSizePixel = 0
SavedNamesList.ScrollBarThickness = 6
SavedNamesList.Parent = SavedNamesFrame

-- Attach the previously created layout
SavedNamesListLayout.Parent = SavedNamesList

-- Create a new frame for settings
local SettingsFrame = Instance.new("Frame")
SettingsFrame.Size = UDim2.new(0, 200, 0, 200)
SettingsFrame.Position = UDim2.new(0.5, -100, 0.5, -100)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SettingsFrame.BorderSizePixel = 0
SettingsFrame.Visible = false
SettingsFrame.Parent = ScreenGui

local SettingsUICorner = Instance.new("UICorner")
SettingsUICorner.CornerRadius = UDim.new(0, 10)
SettingsUICorner.Parent = SettingsFrame

local SettingsTitle = Instance.new("TextLabel")
SettingsTitle.Size = UDim2.new(1, -30, 0, 40)
SettingsTitle.Position = UDim2.new(0, 0, 0, 0)
SettingsTitle.BackgroundTransparency = 1
SettingsTitle.Font = Enum.Font.GothamBold
SettingsTitle.TextColor3 = Color3.new(1, 1, 1)
SettingsTitle.TextSize = 18
SettingsTitle.Text = "Settings"
SettingsTitle.Parent = SettingsFrame

local SettingsCloseButton = Instance.new("TextButton")
SettingsCloseButton.Size = UDim2.new(0, 30, 0, 30)
SettingsCloseButton.Position = UDim2.new(1, -30, 0, 0)
SettingsCloseButton.BackgroundTransparency = 1
SettingsCloseButton.Font = Enum.Font.GothamBold
SettingsCloseButton.TextColor3 = Color3.new(1, 1, 1)
SettingsCloseButton.TextSize = 18
SettingsCloseButton.Text = "X"
SettingsCloseButton.Parent = SettingsFrame

-- Create toggle buttons for settings
local function CreateToggle(text, position, setting)
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0.9, 0, 0, 30)
    ToggleButton.Position = position
    ToggleButton.BackgroundColor3 = Settings[setting] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Font = Enum.Font.Gotham
    ToggleButton.TextColor3 = Color3.new(1, 1, 1)
    ToggleButton.TextSize = 14
    ToggleButton.Text = text .. ": " .. (Settings[setting] and "ON" or "OFF")
    ToggleButton.Parent = SettingsFrame

    local ToggleUICorner = Instance.new("UICorner")
    ToggleUICorner.CornerRadius = UDim.new(0, 5)
    ToggleUICorner.Parent = ToggleButton

    ToggleButton.MouseButton1Click:Connect(function()
        Settings[setting] = not Settings[setting]
        ToggleButton.BackgroundColor3 = Settings[setting] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        ToggleButton.Text = text .. ": " .. (Settings[setting] and "ON" or "OFF")
        SaveSettings()
    end)
end

CreateToggle("Show Notifications", UDim2.new(0.05, 0, 0.3, 0), "ShowNotifications")
CreateToggle("Save Player Names", UDim2.new(0.05, 0, 0.5, 0), "SavePlayerNames")

-- Add this new function to update the Input text
local function updateInputText(player)
    if player then
        Input.Text = player.Name
    end
end

local function createPlayerSelectionTool()
    local tool = Instance.new("Tool")
    tool.Name = "Player Selector"
    tool.RequiresHandle = false
    
    tool.Activated:Connect(function()
        local mouse = LocalPlayer:GetMouse()
        local target = mouse.Target
        
        -- Check if the target is part of a character
        while target and target ~= workspace do
            local humanoid = target:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local player = Players:GetPlayerFromCharacter(humanoid.Parent)
                if player then
                    updateInputText(player)
                    return
                end
            end
            target = target.Parent
        end
        
        print("No player found")
    end)
    
    return tool
end

-- Function to create click teleport tool
local function createClickTeleportTool()
    local tool = Instance.new("Tool")
    tool.Name = "Click Teleporter"
    tool.RequiresHandle = false
    
    tool.Activated:Connect(function()
        local mouse = LocalPlayer:GetMouse()
        local targetPos = mouse.Hit.Position
        
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(targetPos + Vector3.new(0, 3, 0)))
            print("Teleported to clicked location")
        end
    end)
    
    return tool
end

SelectPlayerButton.MouseButton1Click:Connect(function()
    local tool = createPlayerSelectionTool()
    if LocalPlayer.Character then
        tool.Parent = LocalPlayer.Backpack
        LocalPlayer.Character.Humanoid:EquipTool(tool)
    end
end)

ClickTeleportButton.MouseButton1Click:Connect(function()
    local tool = createClickTeleportTool()
    if LocalPlayer.Character then
        tool.Parent = LocalPlayer.Backpack
        LocalPlayer.Character.Humanoid:EquipTool(tool)
    end
end)

-- Add this new function to handle player selection
local function selectPlayer(player)
    if player then
        Input.Text = player.Name
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and 
           LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
            local targetCFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            LocalPlayer.Character:SetPrimaryPartCFrame(targetCFrame)
            print("Teleported to", player.DisplayName)
        else
            print("Unable to teleport - Character or HumanoidRootPart not found")
        end
    end
end

-- Function to autocomplete player name
local function autocompletePlayerName(input)
    input = string.lower(input)
    for _, name in ipairs(PlayerMemory) do
        if string.lower(string.sub(name, 1, #input)) == input then
            return name
        end
    end
    return nil
end

Input.Changed:Connect(function(property)
    if property == "Text" then
        local autocompletedName = autocompletePlayerName(Input.Text)
        if autocompletedName and Input.Text ~= "" then
            Input.Text = autocompletedName
            Input.CursorPosition = #Input.Text + 1
        end
    end
end)

Input.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local players = GetShortenedPlrFromName(Input.Text)
        if players and #players > 0 then
            selectPlayer(players[1])
        else
            print("Player not found")
        end
    end
end)

TeleportButton.MouseButton1Click:Connect(function()
    local players = GetShortenedPlrFromName(Input.Text)
    if players and #players > 0 then
        selectPlayer(players[1])
    else
        print("Player not found")
    end
end)

-- Connect saved names button
SavedNamesButton.MouseButton1Click:Connect(function()
    updateSavedNamesList()
    SavedNamesFrame.Visible = true
end)

-- Connect saved names close button
SavedNamesCloseButton.MouseButton1Click:Connect(function()
    SavedNamesFrame.Visible = false
end)

-- Connect settings button
SettingsButton.MouseButton1Click:Connect(function()
    SettingsFrame.Visible = true
end)

-- Connect settings close button
SettingsCloseButton.MouseButton1Click:Connect(function()
    SettingsFrame.Visible = false
end)

-- Create a toggle button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 30, 0, 305)
ToggleButton.Position = UDim2.new(1, -30, 0.5, -152.5)
ToggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ToggleButton.BorderSizePixel = 0
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.TextSize = 18
ToggleButton.Text = ">"
ToggleButton.Parent = ScreenGui

local ToggleUICorner = Instance.new("UICorner")
ToggleUICorner.CornerRadius = UDim.new(0, 5)
ToggleUICorner.Parent = ToggleButton

local isVisible = false

-- Function to show UI
local function showUI()
    local goal = {}
    goal.Position = UDim2.new(1, -240, 0.5, -152.5)
    local tween = TweenService:Create(TeleportFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
    tween:Play()
    ToggleButton.Text = "<"
    isVisible = true
end

-- Function to hide UI
local function hideUI()
    local goal = {}
    goal.Position = UDim2.new(1, 0, 0.5, -152.5)
    local tween = TweenService:Create(TeleportFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
    tween:Play()
    ToggleButton.Text = ">"
    isVisible = false
end

-- Function to show goodbye sequence
local function showGoodbyeSequence()
    local GoodbyeGui = Instance.new("ScreenGui")
    GoodbyeGui.Name = "Kr0n1ksTPGoodbyeGui"
    GoodbyeGui.Parent = CoreGui

    -- Create a Frame for the goodbye message
    local GoodbyeFrame = Instance.new("Frame")
    GoodbyeFrame.Size = UDim2.new(0, 300, 0, 100)
    GoodbyeFrame.Position = UDim2.new(0.5, -150, 1.5, 0)
    GoodbyeFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    GoodbyeFrame.BorderSizePixel = 0
    GoodbyeFrame.Parent = GoodbyeGui

    local GoodbyeUICorner = Instance.new("UICorner")
    GoodbyeUICorner.CornerRadius = UDim.new(0, 10)
    GoodbyeUICorner.Parent = GoodbyeFrame

    local GoodbyeText = Instance.new("TextLabel")
    GoodbyeText.Size = UDim2.new(1, 0, 1, 0)
    GoodbyeText.BackgroundTransparency = 1
    GoodbyeText.Font = Enum.Font.GothamBold
    GoodbyeText.TextColor3 = Color3.new(1, 1, 1)
    GoodbyeText.TextSize = 18
    GoodbyeText.Text = "Goodbye!"
    GoodbyeText.Parent = GoodbyeFrame

    -- Animate the goodbye message
    local goal = {}
    goal.Position = UDim2.new(0.5, -150, 0.5, -50)
    local tween = TweenService:Create(GoodbyeFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
    tween:Play()
    wait(2)
    goal.Position = UDim2.new(0.5, -150, -0.5, 0)
    tween = TweenService:Create(GoodbyeFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), goal)
    tween:Play()
    wait(0.5)
    GoodbyeGui:Destroy()
end

-- Connect toggle button
ToggleButton.MouseButton1Click:Connect(function()
    if isVisible then
        hideUI()
    else
        showUI()
    end
end)

-- Connect close button
CloseButton.MouseButton1Click:Connect(function()
    showGoodbyeSequence()
    wait(3)
    ScreenGui:Destroy()
end)

-- Show UI initially
showUI()