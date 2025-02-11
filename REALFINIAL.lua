local ESP_ENABLED = false -- Initial state (ESP is OFF)
local ESP_PERMANENTLY_DISABLED = false -- Prevents ESP from being toggled back on
local ESP_COLOR = Color3.fromRGB(0, 255, 0) -- Green color for highlight
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Function to create highlight for a character
local function createHighlight(player)
    if player == LocalPlayer or ESP_PERMANENTLY_DISABLED then return end -- Ignore local player or if permanently disabled

    local function applyHighlight(character)
        if not character then return end
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.FillColor = ESP_COLOR
        highlight.OutlineColor = ESP_COLOR
        highlight.FillTransparency = 0.5
        highlight.Parent = character
    end

    if player.Character then
        applyHighlight(player.Character)
    end

    player.CharacterAdded:Connect(applyHighlight)
end

-- Function to disable ESP highlights
local function disableESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local highlight = player.Character:FindFirstChild("ESP_Highlight")
            if highlight then highlight:Destroy() end
            local distanceLabel = player.Character:FindFirstChild("DistanceLabel")
            if distanceLabel then distanceLabel:Destroy() end
        end
    end
    print("[ESP] Disabled")
end

-- Function to enable ESP highlights
local function enableESP()
    if ESP_PERMANENTLY_DISABLED then return end -- Prevent enabling if permanently disabled

    for _, player in ipairs(Players:GetPlayers()) do
        createHighlight(player)

        if player.Character and player.Character:FindFirstChild("Head") then
            local distanceLabel = Instance.new("TextLabel")
            distanceLabel.Name = "DistanceLabel"
            distanceLabel.Size = UDim2.new(0, 100, 0, 20)
            distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            distanceLabel.BackgroundTransparency = 1
            distanceLabel.TextSize = 14
            distanceLabel.Text = "0 studs"
            distanceLabel.Parent = player.Character:FindFirstChild("Head")
            distanceLabel.Position = UDim2.new(0, -50, 0, -20)
        end
    end
    print("[ESP] Enabled")
end

-- Function to permanently disable ESP
local function disableESPForever()
    ESP_PERMANENTLY_DISABLED = true
    ESP_ENABLED = false
    disableESP()
    print("[ESP] Permanently Disabled - Cannot be turned on again until script restarts")
end

-- Function to calculate distance between the local player and another player
local function getDistanceToPlayer(player)
    local character = player.Character
    if character and character.PrimaryPart then
        return (LocalPlayer.Character.PrimaryPart.Position - character.PrimaryPart.Position).magnitude
    end
    return nil
end

-- Function to update the distance label for each player
local function updateDistanceDisplay()
    if ESP_PERMANENTLY_DISABLED then return end -- Stop updating if permanently disabled

    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Head") then
            local distance = getDistanceToPlayer(player)
            local distanceLabel = player.Character:FindFirstChild("DistanceLabel")
            if distanceLabel and distance then
                distanceLabel.Text = math.floor(distance) .. " studs"
            end
        end
    end
end

-- ESP Toggle Loop
task.spawn(function()
    while true do
        wait(4)
        if ESP_PERMANENTLY_DISABLED then return end -- Stop the loop if permanently disabled
        disableESP()
        wait(0.005)
        enableESP()
    end
end)
