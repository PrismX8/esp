local ESP_ENABLED = false -- Initial state (ESP is OFF)
local ESP_PERMANENTLY_DISABLED = false -- Prevents ESP from being toggled back on
local ESP_COLOR = Color3.fromRGB(0, 255, 0) -- Green color for highlight
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Store player connections and ESP objects to manage them properly
local playerConnections = {}
local espObjects = {}

-- Function to create ESP elements for a character
local function createESP(character)
    if not character or not character:FindFirstChild("Head") then return end

    -- Create Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillColor = ESP_COLOR
    highlight.OutlineColor = ESP_COLOR
    highlight.FillTransparency = 0.5
    highlight.Parent = character

    -- Create Distance Label
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "DistanceLabel"
    distanceLabel.Size = UDim2.new(0, 100, 0, 20)
    distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextSize = 14
    distanceLabel.Text = "0 studs"
    distanceLabel.Parent = character.Head
    distanceLabel.Position = UDim2.new(0, -50, 0, -20)

    -- Store ESP objects for cleanup
    espObjects[character] = {highlight, distanceLabel}
end

-- Function to remove ESP elements
local function removeESP(character)
    if espObjects[character] then
        for _, obj in ipairs(espObjects[character]) do
            obj:Destroy()
        end
        espObjects[character] = nil
    end
end

-- Update distance labels continuously
RunService.Heartbeat:Connect(function()
    if ESP_PERMANENTLY_DISABLED or not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then return end

    for character, data in pairs(espObjects) do
        if character.Parent and character:FindFirstChild("Head") then
            local distance = (LocalPlayer.Character.PrimaryPart.Position - character.PrimaryPart.Position).magnitude
            data[2].Text = math.floor(distance) .. " studs"
        else
            removeESP(character)
        end
    end
end)

-- Manage players
local function onPlayerAdded(player)
    if player == LocalPlayer then return end

    local function onCharacterAdded(character)
        removeESP(character) -- Cleanup previous ESP if exists
        createESP(character)
    end

    -- Connect to CharacterAdded event
    playerConnections[player] = player.CharacterAdded:Connect(onCharacterAdded)

    -- Apply ESP to the current character if it exists
    if player.Character then
        onCharacterAdded(player.Character)
    end
end

local function onPlayerRemoving(player)
    if playerConnections[player] then
        playerConnections[player]:Disconnect()
        playerConnections[player] = nil
    end
    if player.Character then
        removeESP(player.Character)
    end
end

-- Initialize ESP for existing players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        onPlayerAdded(player)
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Control functions
function disableESPForever()
    ESP_PERMANENTLY_DISABLED = true
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            removeESP(player.Character)
        end
    end
    print("[ESP] Permanently Disabled")
end

_G.ESP = _G.ESP or {}
_G.ESP.disableESPForever = disableESPForever
