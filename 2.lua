local ESP_ENABLED = false -- Initial state (ESP is OFF)
local ESP_PERMANENTLY_DISABLED = false -- Prevents ESP from being toggled back on
local ESP_COLOR = Color3.fromRGB(0, 255, 0) -- Green color for text
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Store ESP GUI objects
local espObjects = {}

-- Function to create ESP elements using BillboardGui
local function createESP(character)
    if not character or not character:FindFirstChild("Head") then return end

    -- Create BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_GUI"
    billboard.Size = UDim2.new(0, 100, 0, 50) -- Adjust size as needed
    billboard.StudsOffset = Vector3.new(0, 2, 0) -- Position above head
    billboard.AlwaysOnTop = true
    billboard.Parent = character.Head

    -- Create TextLabel inside BillboardGui
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = ESP_COLOR
    label.TextSize = 14
    label.Font = Enum.Font.SourceSansBold
    label.Text = "[ESP]"
    label.Parent = billboard

    -- Store ESP objects for cleanup
    espObjects[character] = {billboard, label}
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

-- Function to refresh ESP
local function refreshESP()
    if ESP_PERMANENTLY_DISABLED then return end

    -- Remove existing ESP
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            removeESP(player.Character)
        end
    end

    -- Recreate ESP
    task.wait(0.5) -- Small delay to ensure cleanup
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            createESP(player.Character)
        end
    end
    print("[ESP] Refreshed")
end

-- Continuously update ESP text with distance
RunService.Heartbeat:Connect(function()
    if ESP_PERMANENTLY_DISABLED or not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then return end

    for character, data in pairs(espObjects) do
        if character.Parent and character:FindFirstChild("Head") then
            local distance = (LocalPlayer.Character.PrimaryPart.Position - character.PrimaryPart.Position).magnitude
            data[2].Text = "[" .. math.floor(distance) .. " studs]"
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
    player.CharacterAdded:Connect(onCharacterAdded)

    -- Apply ESP to the current character if it exists
    if player.Character then
        onCharacterAdded(player.Character)
    end
end

local function onPlayerRemoving(player)
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

-- Ensure ESP refreshes on the local player's respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1) -- Small delay to allow character to fully load
    refreshESP()
end)

-- Auto-refresh ESP every 30 seconds
task.spawn(function()
    while true do
        task.wait(30) -- Wait 30 seconds before refreshing
        refreshESP()
    end
end)

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
