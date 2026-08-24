local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "XcreationOS | ",
   LoadingTitle = "XcreationOS",
   LoadingSubtitle = "Initializing System...",
   Theme = "Green", -- Larp green

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, 

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, 
      FileName = "XcreationOS_Config"
   },

   Discord = {
      Enabled = false, 
      Invite = "noinvitelink", 
      RememberJoins = true 
   },

   KeySystem = false, 
   KeySettings = {
      Title = "XcreationOS",
      Subtitle = "Security Bypass",
      Note = "Access Granted", 
      FileName = "XcreationKey", 
      SaveKey = true, 
      GrabKeyFromSite = false, 
      Key = {"Hello"} 
   }
})

Rayfield:Notify({
   Title = "SYSTEM ONLINE",
   Content = "XcreationOS successfully injected. Welcome, Operator.",
   Duration = 3.5,
   Image = 4483362458,
})

local VisualsTab = Window:CreateTab("Visuals", 4483362458) 
local VisualsSection = VisualsTab:CreateSection("ESP - Hacker Vision")

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Variables for ESP
local espEnabled = false 
local espConnection 

-- Variables for Tracers
local drawLinesEnabled = false
local lines = {} 
local tracerConnection 

-- Function to create a hollow rectangle with thicker borders (ESP box)
local function createHollowBox()
    local box = Instance.new("BillboardGui")
    box.Size = UDim2.new(4, 0, 5, 0)
    box.AlwaysOnTop = true
    box.Adornee = nil
    box.Name = "PlayerBox"

    local borderThickness = 0.05 

    local top = Instance.new("Frame")
    top.Size = UDim2.new(1, 0, borderThickness, 0)
    top.Position = UDim2.new(0, 0, 0, 0)
    top.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- VERDE NEON
    top.BorderSizePixel = 0
    top.Parent = box

    local bottom = Instance.new("Frame")
    bottom.Size = UDim2.new(1, 0, borderThickness, 0)
    bottom.Position = UDim2.new(0, 0, 1 - borderThickness, 0)
    bottom.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- VERDE NEON
    bottom.BorderSizePixel = 0
    bottom.Parent = box

    local left = Instance.new("Frame")
    left.Size = UDim2.new(borderThickness, 0, 1, 0)
    left.Position = UDim2.new(0, 0, 0, 0)
    left.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- VERDE NEON
    left.BorderSizePixel = 0
    left.Parent = box

    local right = Instance.new("Frame")
    right.Size = UDim2.new(borderThickness, 0, 1, 0)
    right.Position = UDim2.new(1 - borderThickness, 0, 0, 0)
    right.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- VERDE NEON
    right.BorderSizePixel = 0
    right.Parent = box

    return box
end

-- Function to check if a player is on the enemy team
local function isEnemyTeam(player)
    return player.Team ~= LocalPlayer.Team
end

-- Function to highlight all enemy players (ESP)
local function highlightAllPlayers()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isEnemyTeam(player) then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if not player.Character:FindFirstChild("PlayerBox") then
                    local box = createHollowBox()
                    box.Adornee = player.Character:FindFirstChild("HumanoidRootPart")
                    box.Parent = player.Character
                end
            end
        else
            if player.Character and player.Character:FindFirstChild("PlayerBox") then
                player.Character.PlayerBox:Destroy()
            end
        end
    end
end

-- Clean up highlights when players leave
local function onPlayerRemoving(player)
    if player.Character and player.Character:FindFirstChild("PlayerBox") then
        player.Character.PlayerBox:Destroy()
    end
end

-- Enable or disable ESP
local function toggleESP(state)
    if state then
        espConnection = RunService.RenderStepped:Connect(highlightAllPlayers)
        Players.PlayerRemoving:Connect(onPlayerRemoving)
    else
        if espConnection then
            espConnection:Disconnect()
            espConnection = nil
        end
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("PlayerBox") then
                player.Character.PlayerBox:Destroy()
            end
        end
    end
end

-- Function to create and update tracers (lines)
local function createLine()
    local line = Drawing.new("Line")
    line.Visible = true
    line.Thickness = 3 
    line.Color = Color3.fromRGB(0, 255, 0) -- VERDE NEON
    return line
end

local function updateLines()
    for _, line in ipairs(lines) do
        line.Visible = false
    end

    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local index = 1
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isEnemyTeam(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            local rootPart = character.HumanoidRootPart
            local worldPosition = rootPart.Position
            local screenPosition, onScreen = Camera:WorldToViewportPoint(worldPosition)

            if onScreen then
                local line = lines[index] or createLine()
                line.From = screenCenter
                line.To = Vector2.new(screenPosition.X, screenPosition.Y)
                line.Visible = true

                lines[index] = line
                index = index + 1
            end
        end
    end

    for i = index, #lines do
        lines[i].Visible = false
    end
end

local function cleanupLines()
    for _, line in ipairs(lines) do
        line.Visible = false
        line:Remove()
    end
    lines = {}
end

-- Toggle for tracers (line drawing)
local function toggleLineDrawing(state)
    if state then
        tracerConnection = RunService.RenderStepped:Connect(updateLines)
    else
        if tracerConnection then
            tracerConnection:Disconnect()
            tracerConnection = nil
        end
        cleanupLines()
    end
end

-- Rayfield UI Toggles
VisualsTab:CreateToggle({
    Name = "Enemy Boxes",
    CurrentValue = false,
    Flag = "BOX1",
    Callback = function(Value)
        espEnabled = Value
        toggleESP(Value)
    end,
})

VisualsTab:CreateToggle({
    Name = "Enemy Tracers",
    CurrentValue = false,
    Flag = "Tracer1",
    Callback = function(Value)
        drawLinesEnabled = Value
        toggleLineDrawing(Value)
    end,
})


local MoveTab = Window:CreateTab("Misc", 4483362458) 
local MoveSection = MoveTab:CreateSection("Movement Hacks")

local Toggle = MoveTab:CreateButton({
    Name = "Strafe/bhop",
    Callback = function(Value)
local STRAFE_SPEED = 30
local AIR_MULTIPLIER = 1.5
local BHOP_POWER = 40
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local moveKeys = {W = false, A = false, S = false, D = false, Space = false}
local function getChar() return player.Character or player.CharacterAdded:Wait() end
local function getRoot() return getChar():FindFirstChild("HumanoidRootPart") end
local function getHumanoid() return getChar():FindFirstChild("Humanoid") end
local function calculateMoveDirection()
    local dir = Vector3.new(0, 0, 0)
    local char = getChar()
    if not char then return dir end
    local cf = workspace.CurrentCamera.CFrame
    if moveKeys.W then dir = dir + cf.LookVector end
    if moveKeys.S then dir = dir - cf.LookVector end
    if moveKeys.A then dir = dir - cf.RightVector end
    if moveKeys.D then dir = dir + cf.RightVector end
    dir = Vector3.new(dir.X, 0, dir.Z).Unit
    return dir
end
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.W then moveKeys.W = true
    elseif input.KeyCode == Enum.KeyCode.A then moveKeys.A = true
    elseif input.KeyCode == Enum.KeyCode.S then moveKeys.S = true
    elseif input.KeyCode == Enum.KeyCode.D then moveKeys.D = true
    elseif input.KeyCode == Enum.KeyCode.Space then moveKeys.Space = true end
end)
UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.W then moveKeys.W = false
    elseif input.KeyCode == Enum.KeyCode.A then moveKeys.A = false
    elseif input.KeyCode == Enum.KeyCode.S then moveKeys.S = false
    elseif input.KeyCode == Enum.KeyCode.D then moveKeys.D = false
    elseif input.KeyCode == Enum.KeyCode.Space then moveKeys.Space = false end
end)
RunService.Heartbeat:Connect(function()
    local char = getChar()
    local root = getRoot()
    local humanoid = getHumanoid()
    if not char or not root or not humanoid then return end
    local moveDir = calculateMoveDirection()
    local isInAir = humanoid:GetState() == Enum.HumanoidStateType.Jumping or humanoid:GetState() == Enum.HumanoidStateType.Freefall
    if moveDir.Magnitude > 0 then
        local speed = STRAFE_SPEED
        if isInAir then speed = speed * AIR_MULTIPLIER end
        local newVel = moveDir * speed
        root.Velocity = Vector3.new(newVel.X, root.Velocity.Y, newVel.Z)
        if moveKeys.Space and root.Velocity.Y < 1 then
            root.Velocity = Vector3.new(root.Velocity.X, BHOP_POWER, root.Velocity.Z)
        end
    end
end)
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Movement Loaded",
    Text = "WASD + Space active",
    Duration = 5
})
    end,
})

local Button = MoveTab:CreateButton({
   Name = "Infinite Yield",
   Callback = function()
   loadstring(game:HttpGet("https://cdn.wearedevs.net/scripts/Infinite%20Yield.txt"))()
   end,
})

local Button = MoveTab:CreateButton({
   Name = "NoClip(N)",
   Callback = function()
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local noclip = false 
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.N then noclip = not noclip end
end)
game:GetService("RunService").Stepped:Connect(function()
    if noclip then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
        end
    else
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and not part.CanCollide then part.CanCollide = true end
        end
    end
end)
   end,
})

local AimTab = Window:CreateTab("Aimbot", 4483362458) 
local AimbotSection = AimTab:CreateSection("Combat Systems")

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local LockedPlayer = nil
local LastKnownPosition = nil
local FieldOfView = 40 
local CenterPrioritizationFactor = 0.5 
local AimbotEnabled = false 

local function isEnemyTeam(player)
    if not LocalPlayer.Team or not player.Team then return false end
    return LocalPlayer.Team ~= player.Team
end

local function getTargetBodyPart()
    return math.random() <= 0.7 and "UpperTorso" or "Head"
end

local function getClosestEnemyPlayerToCrosshair()
    local mousePosition = UserInputService:GetMouseLocation()
    local closestPlayer = nil
    local closestDistance = math.huge
    local cameraPosition = Camera.CFrame.Position
    local cameraForward = Camera.CFrame.LookVector
    local centerOfScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and isEnemyTeam(player) then
            local targetBodyPartName = getTargetBodyPart()
            local bodyPart = player.Character:FindFirstChild(targetBodyPartName)
            if bodyPart then
                local screenPosition, onScreen = Camera:WorldToViewportPoint(bodyPart.Position)
                if onScreen then
                    local playerPosition = bodyPart.Position - cameraPosition
                    local angle = math.acos(cameraForward:Dot(playerPosition.Unit)) * (180 / math.pi)
                    if angle <= FieldOfView / 2 then
                        local screenDist = (Vector2.new(screenPosition.X, screenPosition.Y) - mousePosition).Magnitude
                        local distanceFromCenter = (Vector2.new(screenPosition.X, screenPosition.Y) - centerOfScreen).Magnitude * CenterPrioritizationFactor
                        local distanceToPlayer = (LocalPlayer.Character.Head.Position - bodyPart.Position).Magnitude
                        local weightedScore = screenDist + distanceFromCenter + distanceToPlayer
                        if weightedScore < closestDistance then
                            closestDistance = weightedScore
                            closestPlayer = {player = player, bodyPart = targetBodyPartName}
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

local function lockCameraOnPlayer(targetData)
    if targetData and targetData.player.Character then
        local bodyPart = targetData.player.Character:FindFirstChild(targetData.bodyPart)
        if bodyPart then
            LockedPlayer = targetData.player
            LastKnownPosition = bodyPart.Position
            RunService:BindToRenderStep("LockCamera", Enum.RenderPriority.Camera.Value, function()
                if LockedPlayer and LockedPlayer.Character and isEnemyTeam(LockedPlayer) then
                    local currentBodyPart = LockedPlayer.Character:FindFirstChild(targetData.bodyPart)
                    if currentBodyPart then
                        local targetPosition = currentBodyPart.Position
                        if (targetPosition - LastKnownPosition).Magnitude > 5 then
                            RunService:UnbindFromRenderStep("LockCamera")
                            LockedPlayer = nil
                            return
                        end
                        LastKnownPosition = targetPosition
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
                    else
                        RunService:UnbindFromRenderStep("LockCamera")
                        LockedPlayer = nil
                    end
                else
                    RunService:UnbindFromRenderStep("LockCamera")
                    LockedPlayer = nil
                end
            end)
        end
    end
end

local Toggle = AimTab:CreateToggle({
    Name = "Aimbot (RCLICK)",
    CurrentValue = false,
    Flag = "AIM1",
    Callback = function(Value)
        AimbotEnabled = Value
        if not AimbotEnabled then
            RunService:UnbindFromRenderStep("LockCamera")
            LockedPlayer = nil
        end
    end,
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton2 and AimbotEnabled then
        lockCameraOnPlayer(getClosestEnemyPlayerToCrosshair())
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RunService:UnbindFromRenderStep("LockCamera")
        LockedPlayer = nil
    end
end)

local function getPlayersName()
    for i, v in pairs(game:GetChildren()) do if v.ClassName == "Players" then return v.Name end end
end
local playersService = getPlayersName()
local localPlayer = game[playersService].LocalPlayer
local isModificationEnabled = false
local modificationCoroutine = nil

local function modifyPlayerParts()
    while isModificationEnabled do
        for _, v in pairs(game[playersService]:GetPlayers()) do
            if v.Name ~= localPlayer.Name and v.Character then
                for _, partName in ipairs({"RightUpperLeg", "LeftUpperLeg", "HeadHB", "HumanoidRootPart"}) do
                    local part = v.Character:FindFirstChild(partName)
                    if part then part.CanCollide = false part.Transparency = 10 part.Size = Vector3.new(10, 10, 10) end
                end
            end
        end
        wait(1)
    end
    for _, v in pairs(game[playersService]:GetPlayers()) do
        if v.Name ~= localPlayer.Name and v.Character then
            for _, partName in ipairs({"RightUpperLeg", "LeftUpperLeg", "HeadHB", "HumanoidRootPart"}) do
                local part = v.Character:FindFirstChild(partName)
                if part then part.CanCollide = true part.Transparency = 0 part.Size = Vector3.new(1, 1, 1) end
            end
        end
    end
end

local Toggle = AimTab:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = false,
    Flag = "PlayerPartModification",
    Callback = function(Value)
        isModificationEnabled = Value
        if Value then
            modificationCoroutine = coroutine.create(modifyPlayerParts)
            coroutine.resume(modificationCoroutine)
        else
            modificationCoroutine = nil
        end
    end,
})

local Toggle = AimTab:CreateToggle({
    Name = "TriggerBot",
    CurrentValue = false,
    Flag = "EnemyAutoClickToggle",
    Callback = function(Value)
        if Value then
            getgenv().AutoClickConnection = game:GetService("RunService").RenderStepped:Connect(function()
                local Mouse = LocalPlayer:GetMouse()
                if Mouse.Target and Mouse.Target.Parent then
                    local TargetPlayer = Players:GetPlayerFromCharacter(Mouse.Target.Parent)
                    if TargetPlayer and TargetPlayer ~= LocalPlayer and (not TargetPlayer.Team or TargetPlayer.Team ~= LocalPlayer.Team) then
                        mouse1press() wait() mouse1release()
                    end
                end
            end)
        else
            if getgenv().AutoClickConnection then getgenv().AutoClickConnection:Disconnect() end
        end
    end
})

local ModsTab = Window:CreateTab("Gun Mods", 4483362458) 
local ModsSection = ModsTab:CreateSection("Weapon Overrides")

local Toggle = ModsTab:CreateButton({
    Name = "Infinite ammo (arsenal)",
    Callback = function()
        for i,v in next, game.ReplicatedStorage.Weapons:GetChildren() do
            for i,c in next, v:GetChildren() do
                for i,x in next, getconnections(c.Changed) do x:Disable() end
                if c.Name == "Ammo" or c.Name == "StoredAmmo" then c.Value = 300 end
            end
        end
    end,
})

local Toggle = ModsTab:CreateButton({
    Name = "Infinite range (arsenal)",
    Callback = function()
        for i,v in next, game.ReplicatedStorage.Weapons:GetChildren() do
            for i,c in next, v:GetChildren() do
                for i,x in next, getconnections(c.Changed) do x:Disable() end
                if c.Name == "Range" then c.Value = 9e9 end
            end
        end
    end,
})

local Toggle = ModsTab:CreateButton({
    Name = "100% accuracy (arsenal)",
    Callback = function()
        for i,v in next, game.ReplicatedStorage.Weapons:GetChildren() do
            for i,c in next, v:GetChildren() do
                for i,x in next, getconnections(c.Changed) do x:Disable() end
                if c.Name == "AReload" or c.Name == "RecoilControl" or c.Name == "EReload" or c.Name == "SReload" or c.Name == "ReloadTime" or c.Name == "EquipTime" or c.Name == "Spread" or c.Name == "MaxSpread" then
                    c.Value = 0
                end
            end
        end
    end,
})

local Toggle = ModsTab:CreateButton({
    Name = "Fire rate (arsenal)",
    Callback = function()
        for i,v in next, game.ReplicatedStorage.Weapons:GetChildren() do
            for i,c in next, v:GetChildren() do
                for i,x in next, getconnections(c.Changed) do x:Disable() end
                if c.Name == "FireRate" or c.Name == "BFireRate" then c.Value = 0.02 end
            end
        end
    end,
})

local Toggle = ModsTab:CreateButton({
    Name = "All Weapons Automatic (Arsenal)",
    Callback = function()
        for _, weapon in pairs(game.ReplicatedStorage.Weapons:GetChildren()) do
            for _, child in pairs(weapon:GetChildren()) do
                if child:IsA("ModuleScript") then
                    local weaponData = require(child)
                    if weaponData.Auto == false then weaponData.Auto = true end
                end
            end
        end
    end
})

print("XcreationOS | Hacker Edition Loaded")
