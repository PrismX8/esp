local ESP_ENABLED = false -- Initial state (ESP is OFF)
local ESP_COLOR = Color3.fromRGB(0, 255, 0) -- Green color for highlight
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ESPButton = script.Parent -- Adjust if needed for your button
local RunService = game:GetService("RunService")

-- Function to create highlight for a character
local function createHighlight(player)
    if player == LocalPlayer then return end -- Ignore local player

    local function applyHighlight(character)
        if not character then return end

        -- Create a full-body highlight
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.FillColor = ESP_COLOR
        highlight.OutlineColor = ESP_COLOR
        highlight.FillTransparency = 0.5
        highlight.Parent = character
    end

    -- Apply highlight immediately if character exists
    if player.Character then
        applyHighlight(player.Character)
    end

    -- Apply highlight when the player respawns
    player.CharacterAdded:Connect(applyHighlight)
end

-- Function to disable ESP highlights
local function disableESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local highlight = player.Character:FindFirstChild("ESP_Highlight")
            if highlight then highlight:Destroy() end
            -- Remove any existing distance labels
            local distanceLabel = player.Character:FindFirstChild("DistanceLabel")
            if distanceLabel then distanceLabel:Destroy() end
        end
    end
    print("[ESP] Disabled")
end

-- Function to enable ESP highlights
local function enableESP()
    for _, player in ipairs(Players:GetPlayers()) do
        createHighlight(player)

        -- Create a distance label above the player's head
        if player.Character then
            local distanceLabel = Instance.new("TextLabel")
            distanceLabel.Name = "DistanceLabel"
            distanceLabel.Size = UDim2.new(0, 100, 0, 20)
            distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            distanceLabel.BackgroundTransparency = 1
            distanceLabel.TextSize = 14
            distanceLabel.Text = "0 studs"
            distanceLabel.Parent = player.Character:FindFirstChild("Head")

            -- Position the label above the player's head
            distanceLabel.Position = UDim2.new(0, -50, 0, -20)
        end
    end
    print("[ESP] Enabled")
end

-- Function to calculate distance between the local player and another player
local function getDistanceToPlayer(player)
    local character = player.Character
    if character and character.PrimaryPart then
        local distance = (LocalPlayer.Character.PrimaryPart.Position - character.PrimaryPart.Position).magnitude
        return distance
    end
    return nil
end

-- Function to update the distance label for each player
local function updateDistanceDisplay()
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

-- Disable and Re-enable ESP every second (as before)
task.spawn(function()
    while true do
        wait(1)  -- Every 1 second
        disableESP()  -- Disable ESP
        wait(0.005)
        enableESP()  -- Re-enable ESP
        updateDistanceDisplay()  -- Update the displayed distance
    end
end)
