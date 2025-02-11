-- ESP Toggleable Script (Highlight players and show distance)
local ESP_ENABLED = false -- Initial state (ESP is OFF)
local ESP_COLOR = Color3.fromRGB(0, 255, 0) -- Green color for highlight
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local ESPButton = script.Parent -- Adjust if needed for your button

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
        end
    end
    print("[ESP] Disabled")
end

-- Function to enable ESP highlights
local function enableESP()
    for _, player in ipairs(Players:GetPlayers()) do
        createHighlight(player)
    end
    print("[ESP] Enabled")
end

-- Detect new players joining
Players.PlayerAdded:Connect(createHighlight)

-- Function to calculate distance between the local player and another player
local function getDistanceToPlayer(player)
    local character = player.Character
    if character and character.PrimaryPart then
        local distance = (LocalPlayer.Character.PrimaryPart.Position - character.PrimaryPart.Position).magnitude
        return distance
    end
    return nil
end

-- Update UI with distance information
local function updateDistanceDisplay()
    local closestPlayer = nil
    local closestDistance = math.huge

    -- Find closest player and display distance
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local distance = getDistanceToPlayer(player)
            if distance and distance < closestDistance then
                closestDistance = distance
                closestPlayer = player
            end
        end
    end

    -- Display the closest player's name and distance on the ESPButton
    if closestPlayer then
        ESPButton.Text = "👁️ ESP: " .. closestPlayer.Name .. " - " .. math.floor(closestDistance) .. " studs"
    else
        ESPButton.Text = "👁️ ESP: No players nearby"
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

-- Toggle ESP with UI Button (Only turns ON when clicked)
ESPButton.MouseButton1Click:Connect(function()
    enableESP()
    ESPButton.Text = "👁️ ESP: ON"
    ESPButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
end)

print("[ESP Script] ESP highlights players and displays the closest player's distance.")
