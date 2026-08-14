
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Events = ReplicatedStorage:WaitForChild("Events")
--tap AutoFish
_G.AutoFish = false
_G.AutoSell = false
_G.BuyBait = false
_G.FishCFrame = nil
--tap Autoskills
_G.AutoZ = false
_G.AutoX = false
_G.AutoC = false
_G.AutoV = false
_G.EZautoEnzo = false
--tapTeleport
_G.TeleportLocations = {
    
    ["beginning isle"] = CFrame.new(-207.387665, 6.76193953, 32.3229866, 0.768884122, -5.12820471e-08, 0.639388144, 8.21569088e-08, 1, -1.85913631e-08, -0.639388144, 6.68247608e-08, 0.768884122),
    ["bamboo isle"] = CFrame.new(-1234.19836, 6.76233625, 1.52872586, -0.0144769866, -5.80721284e-08, -0.999895215, 3.66464121e-08, 1, -5.86088014e-08, 0.999895215, -3.7491052e-08, -0.0144769866),
    ["FallOut isls"] = CFrame.new(62.1234436, 6.76233625, 1177.48193, 0.995004058, -3.86241368e-08, -0.0998347551, 3.63026551e-08, 1, -2.50699337e-08, 0.0998347551, 2.13204192e-08, 0.995004058),
    ["sovereign isle"] = CFrame.new(-1262.87866, 6.76233625, 1240.38831, 0.884532571, 6.60379973e-10, -0.466478407, 3.28130234e-08, 1, 6.36354613e-08, 0.466478407, -7.15942008e-08, 0.884532571),
    ["perch isle"] = CFrame.new(18.7707157, 9.27601719, -1337.08862, -0.738087237, -3.52821203e-08, -0.674705327, 1.82395432e-08, 1, -7.22456051e-08, 0.674705327, -6.56298766e-08, -0.738087237),
    ["Frost isle"] = CFrame.new(-1498.23523, 53.1889381, -1420.85767, -0.226733074, -1.71602377e-08, -0.973956943, 7.58581251e-08, 1, -3.52785428e-08, 0.973956943, -8.18813604e-08, -0.226733074),
    ["cocont isie"] = CFrame.new(1369.427, 9.27561855, -1454.18469, -0.699772358, -5.73053391e-08, 0.7143659, -3.78265845e-08, 1, 4.31646292e-08, -0.7143659, 3.18339244e-09, -0.699772358),
    ["Amber isie"] = CFrame.new(1246.97705, 6.76193905, 1392.34106, -0.0267343521, -3.50038754e-08, 0.999642551, -1.19177856e-09, 1, 3.49845202e-08, -0.999642551, -2.5606417e-10, -0.0267343521),
    ["Battlefield isie"] = CFrame.new(1321.10535, 8.08194065, 205.195343, -0.653882205, -9.13330211e-08, 0.756596386, -2.61356341e-08, 1, 9.81281474e-08, -0.756596386, 4.439012e-08, -0.653882205),
    ["Mistpeak isie"] = CFrame.new(2576.61548, 9.27561855, -35.829567, -0.00849962048, -6.35730473e-08, 0.99996388, 5.31433315e-08, 1, 6.40270557e-08, -0.99996388, 5.36856177e-08, -0.00849962048)
}
--tapCharacter
_G.CharacterWalkSpeed = 50
_G.CharacterJumpPower = 16
_G.CharacterEnabled = false
_G.AntiAFK = false




local function getFishingUI()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then
        return nil
    end

    local mainGui = playerGui:FindFirstChild("MainGui")
    if not mainGui then
        return nil
    end

    return mainGui:FindFirstChild("Fishing")
end

local function centerFishingUI(fishingUI)
    if not (fishingUI and fishingUI.Visible) then
        return
    end

    local barFrame = fishingUI:FindFirstChild("BarFrame")
    if not barFrame then return end

    -- Lock main Bar (indicator) to center
    local bar = barFrame:FindFirstChild("Bar")
    if bar then
        bar.Position = UDim2.new(0.5, -bar.Size.X.Offset / 2, bar.Position.Y.Scale, bar.Position.Y.Offset)
    end

    -- Lock Health/HP bar if exists
    local healthBar = barFrame:FindFirstChild("HealthBar") or barFrame:FindFirstChild("HPBar") or barFrame:FindFirstChild("Health")
    if healthBar then
        healthBar.Size = UDim2.new(1, 0, healthBar.Size.Y.Scale, healthBar.Size.Y.Offset)
        healthBar.Position = UDim2.new(0, 0, healthBar.Position.Y.Scale, healthBar.Position.Y.Offset)
    end

    -- Also check for any colored bars that might need locking
    for _, child in ipairs(barFrame:GetChildren()) do
        if child:IsA("Frame") or child:IsA("ImageLabel") then
            local childName = child.Name:lower()
            if childName:find("health") or childName:find("hp") or childName:find("fill") then
                -- Keep it at full width and proper position
                if not (childName == "bar") then
                    child.Size = UDim2.new(1, 0, child.Size.Y.Scale, child.Size.Y.Offset)
                end
            end
        end
    end
end

local function countAttachments(buoy)
    local count = 0
    if buoy then
        for _, child in ipairs(buoy:GetChildren()) do
            if child:IsA("Attachment") then
                count = count + 1
            end
        end
    end
    return count
end

local function getCharacter()
    return LocalPlayer and LocalPlayer.Character
end

local function getHumanoid()
    local character = getCharacter()
    if not character then
        return nil
    end

    return character:FindFirstChildOfClass("Humanoid")
end

local function setCharacterValues(humanoid, speed, jumpPower)
    if not humanoid then
        return
    end

    if humanoid.WalkSpeed ~= nil then
        humanoid.WalkSpeed = speed
    end

    if humanoid.JumpPower ~= nil then
        humanoid.JumpPower = jumpPower
    end

    if humanoid.JumpHeight ~= nil then
        humanoid.JumpHeight = jumpPower
    end
end

local function applyCharacterSettings()
    if not _G.CharacterEnabled then
        return
    end

    local humanoid = getHumanoid()
    if not humanoid then
        return
    end

    setCharacterValues(humanoid, _G.CharacterWalkSpeed or humanoid.WalkSpeed, _G.CharacterJumpPower or humanoid.JumpPower)
end

local function disableCharacterSettings()
    local humanoid = getHumanoid()
    if not humanoid then
        return
    end

    setCharacterValues(humanoid, 16, 16)
end

local function setFishCFrame()
    local character = getCharacter()
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        _G.FishCFrame = humanoidRootPart.CFrame
        print("Fishing position set:", _G.FishCFrame.Position)
    end
end

local function setTeleportLocation(slot)
    local character = getCharacter()
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        _G.TeleportLocations[slot] = humanoidRootPart.CFrame
        print("Saved teleport location slot " .. slot .. ":", _G.TeleportLocations[slot].Position)
    end
end

local function teleportToLocation(slot)
    local location = _G.TeleportLocations[slot]
    if not location then
        print("Teleport slot " .. slot .. " not set.")
        return
    end

    local character = getCharacter()
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        humanoidRootPart.CFrame = location
        humanoidRootPart.Velocity = Vector3.new()
        humanoidRootPart.RotVelocity = Vector3.new()
        print("Teleported to slot " .. slot .. ".")
    end
end

local function registerTeleportLocation(name, cframe)
    if typeof(name) ~= "string" or name == "" then
        warn("Teleport name must be a non-empty string.")
        return
    end

    if typeof(cframe) ~= "CFrame" then
        warn("Teleport cframe must be a CFrame value.")
        return
    end

    _G.TeleportLocations[name] = cframe
    print("Registered teleport location:", name, cframe.Position)
end

local function teleportToLocationByName(name)
    if typeof(name) ~= "string" or name == "" then
        warn("Teleport name must be a non-empty string.")
        return
    end

    local location = _G.TeleportLocations[name]
    if not location then
        warn("Teleport location '" .. name .. "' not found.")
        return
    end

    local character = getCharacter()
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        humanoidRootPart.CFrame = location
        humanoidRootPart.Velocity = Vector3.new()
        humanoidRootPart.RotVelocity = Vector3.new()
        print("Teleported to location:", name)
    end
end

local FriendTeleportDropdown

local function findEnzoBoss()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("enzo") then
            return obj
        end
    end
    return nil
end

local function getBossPhaseValue(boss)
    if not boss then
        return nil
    end

    local checked = {}
    for _, child in ipairs(boss:GetDescendants()) do
        local name = string.lower(child.Name)
        if name:find("phase") or name:find("stage") or name:find("state") or name:find("boss") then
            if child:IsA("StringValue") then
                local value = string.lower(child.Value)
                table.insert(checked, name .. "=" .. value)
                if value:find("phase2") or value:find("bossphase2") or value == "2" then
                    return value
                end
            elseif child:IsA("IntValue") then
                local value = tostring(child.Value)
                table.insert(checked, name .. "=" .. value)
                if value == "2" then
                    return value
                end
            end
        end
    end

    if #checked > 0 then
        print("[EnzoBoss] Boss state candidates:", table.concat(checked, ", "))
    end

    return nil
end

local function printBossDebugInfo(boss)
    if not boss then
        return
    end

    local names = {}
    for _, child in ipairs(boss:GetChildren()) do
        table.insert(names, child.Name .. " (" .. child.ClassName .. ")")
    end

    print("[EnzoBoss] Boss children:", table.concat(names, ", "))
end

local function isEnzoPhase2(boss)
    if not boss then
        return false
    end

    local phaseValue = getBossPhaseValue(boss)
    if phaseValue then
        if phaseValue:find("phase2") or phaseValue:find("bossphase2") or phaseValue == "2" then
            return true
        end
    end

    local humanoid = boss:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.MaxHealth and humanoid.MaxHealth > 0 then
        local healthRatio = humanoid.Health / humanoid.MaxHealth
        if healthRatio <= 0.5 then
            return true
        end
    end

    return false
end

local function teleportToPlayer(name)
    if typeof(name) ~= "string" or name == "" then
        warn("Player name must be a non-empty string.")
        return
    end

    local targetPlayer = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name == name or player.DisplayName == name then
            targetPlayer = player
            break
        end
    end

    if not targetPlayer then
        warn("Player '" .. name .. "' not found.")
        return
    end

    local character = getCharacter()
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    local targetCharacter = targetPlayer.Character
    local targetRootPart = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")

    if humanoidRootPart and targetRootPart then
        humanoidRootPart.CFrame = targetRootPart.CFrame
        humanoidRootPart.Velocity = Vector3.new()
        humanoidRootPart.RotVelocity = Vector3.new()
        print("Teleported to player:", name)
    else
        warn("Unable to teleport to player:", name)
    end
end

local function refreshFriendDropdown()
    local friendNames = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(friendNames, player.Name)
        end
    end
    if #friendNames == 0 then
        friendNames = {"No players available"}
    end
    if FriendTeleportDropdown then
        FriendTeleportDropdown.Values = friendNames
        if FriendTeleportDropdown.SetValue then
            FriendTeleportDropdown:SetValue(friendNames[1])
        elseif Options and Options.FriendTeleportDropdown then
            Options.FriendTeleportDropdown.Value = friendNames[1]
        end
    end
end

_G.RegisterTeleportLocation = registerTeleportLocation
_G.TeleportToLocationByName = teleportToLocationByName

local function applyFishingPositionLock()
    if not _G.AutoFish or not _G.FishCFrame then
        return
    end

    local character = getCharacter()
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        humanoidRootPart.CFrame = _G.FishCFrame
        humanoidRootPart.Velocity = Vector3.new()
        humanoidRootPart.RotVelocity = Vector3.new()
    end
end

local function applyCharacterSettingsOnSpawn()
    if not _G.CharacterEnabled then
        return
    end

    local character = getCharacter()
    if not character then
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        applyCharacterSettings()
    else
        character:WaitForChild("Humanoid", 5)
        applyCharacterSettings()
    end
end

local antiAFKThread = nil

local function startAntiAFK()
    if antiAFKThread then
        return
    end

    antiAFKThread = task.spawn(function()
        while _G.AntiAFK do
            task.wait(10)
            if not _G.AntiAFK then
                break
            end

            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
                local ok = pcall(function()
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end)

                if not ok then
                    warn("Anti AFK jump failed.")
                end
            end
        end

        antiAFKThread = nil
    end)
end

local function stopAntiAFK()
    _G.AntiAFK = false
    antiAFKThread = nil
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.1)
    applyCharacterSettingsOnSpawn()
end)

if LocalPlayer.Character then
    applyCharacterSettingsOnSpawn()
end

local function castFishing()
    local character = LocalPlayer.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

    if not humanoidRootPart then
        return
    end

    if character:FindFirstChild("Tool") then
        local fishingEvent = Events:FindFirstChild("Fishing")

        if fishingEvent then
            local rootCFrame = humanoidRootPart.CFrame
            if _G.FishCFrame then
                rootCFrame = _G.FishCFrame
            end

            local forward = rootCFrame.LookVector
            local castPosition = Vector3.new(
                rootCFrame.Position.X + forward.X * 6,
                rootCFrame.Position.Y,
                rootCFrame.Position.Z + forward.Z * 6
            )

            -- Create CFrame that points in the forward direction
            local castCFrame = CFrame.new(castPosition, castPosition + forward)
            fishingEvent:FireServer(castCFrame)
        end
    else
        local toggleHotbar = Events:FindFirstChild("ToggleHotbar")
        if toggleHotbar then
            toggleHotbar:InvokeServer("1", nil)
        end
    end
end

-- RenderStepped for UI centering
RunService.RenderStepped:Connect(function()
    if not _G.AutoFish then
        return
    end

    local fishingUI = getFishingUI()
    applyFishingPositionLock()

    if fishingUI and fishingUI.Visible then
        centerFishingUI(fishingUI)
    end
end)

-- Auto fish loop in background
local autoFishCoroutine = coroutine.create(function()
    while true do
        if _G.AutoFish then
            local character = LocalPlayer.Character

            if not character then
                task.wait(0.5)
            elseif character:FindFirstChild("Tool") then
                local buoy = character:FindFirstChild("Buoy")

                if buoy then
                    local attachmentCount = countAttachments(buoy)

                    if attachmentCount >= 4 then
                        
                        local fishingUI = getFishingUI()
                        local minigameEvent = Events:FindFirstChild("FishingMinigame")
                        
                        -- Loop ขณะที่ยังมี buoy และ attachment >= 4
                        while _G.AutoFish and character:FindFirstChild("Buoy") and countAttachments(character:FindFirstChild("Buoy")) >= 4 do
                            if fishingUI then
                                centerFishingUI(fishingUI)
                            end
                            
                            -- Fire minigame event ที่ตำแหน่งกลาง (0.5)
                            if minigameEvent then
                                minigameEvent:FireServer(0.5, 0.5)
                            end
                            
                            task.wait(0.05)
                        end
                        
                      
                        task.wait(1)
                        
                        -- Auto sell if enabled
                        if _G.AutoSell then
                            local sellFishEvent = Events:FindFirstChild("SellFish")
                            if sellFishEvent then
                                sellFishEvent:FireServer("All")
                              
                                task.wait(0.5)
                            end
                        end
                    else
                    
                        task.wait(0.5)
                    end
                else
                   
                    castFishing()
                    task.wait(0.5)
                end
            else
               
                castFishing()
                task.wait(0.5)
            end
        else
            task.wait(0.1)
        end
    end
end)

coroutine.resume(autoFishCoroutine)

-- ========== FLUENT UI ==========
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Heavyweight Fishing V.1.4.2.0",
    SubTitle = "by Haru",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Auto Fish", Icon = "FishingRod" }),
    Skills = Window:AddTab({ Title = "Auto Skills", Icon = "activity" }),
    Boss = Window:AddTab({ Title = "Boss", Icon = "sword" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "MapPin" }),
    Character = Window:AddTab({ Title = "Character", Icon = "user" }),
    Shop = Window:AddTab({ Title = "Shop", Icon = "shopping-cart" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- Main Tab
local AutoFishToggle = Tabs.Main:AddToggle("AutoFishToggle", {
    Title = "Auto Fish",
    Default = false
})

AutoFishToggle:OnChanged(function()
    _G.AutoFish = Options.AutoFishToggle.Value
    if _G.AutoFish and _G.FishCFrame then
        applyFishingPositionLock()
    end
end)    


local AutoSellToggle = Tabs.Main:AddToggle("AutoSellToggle", {
    Title = "Auto Sell Fish",
    Default = false
})

AutoSellToggle:OnChanged(function()
    _G.AutoSell = Options.AutoSellToggle.Value
end)

local SetFishPositionButton = Tabs.Main:AddButton({
    Title = "Set Fish Position",
    Description = "Save current position as fishing location.",
    Callback = function()
        setFishCFrame()
    end
})

local BossTab = Tabs.Boss

local ChooseDialogueButton = Tabs.Main:AddButton({
    Title = "Ticket Quest Giver",
    Description = "Fire ChooseDialogueOption for the quest giver.",
    Callback = function()
        local Event = game:GetService("ReplicatedStorage"):WaitForChild("Events"):FindFirstChild("ChooseDialogueOption")
        if not Event then
            warn("ChooseDialogueOption event not found.")
            return
        end

        Event:FireServer(
            "Ticket Quest Giver",
            1,
            "Quest",
            {
                workspace.NPC.Function["Ticket Quest Giver"]
            }
        )
    end
})

local ChooseHardAcceptQuestButton = Tabs.Main:AddButton({
    Title = "Ticket Quest Hard Accept",
    Description = "Fire the hard accept quest dialogue option.",
    Callback = function()
        local Event = game:GetService("ReplicatedStorage"):WaitForChild("Events"):FindFirstChild("ChooseDialogueOption")
        if not Event then
            warn("ChooseDialogueOption event not found.")
            return
        end

        Event:FireServer(
            "Ticket Quest Giver",
            2,
            "HardAcceptQuest",
            {
                workspace.NPC.Function["Ticket Quest Giver"],
                "Ticket Quest"
            }
        )
    end
})

local PredefinedIslandTeleport = Tabs.Teleport:AddDropdown("PredefinedIslandTeleport", {
    Title = "Teleport Island",
    Description = "เลือกชื่อเกาะเพื่อ TP",
    Values = {
        "beginning isle",
        "bamboo isle",
        "FallOut isls",
        "sovereign isle",
        "perch isle",
        "Frost isle",
        "cocont isie",
        "Amber isie",
        "Battlefield isie",
        "Mistpeak isie"
    },
    Multi = false,
    Default = 1
})

local TeleportIslandButton = Tabs.Teleport:AddButton({
    Title = "Teleport To Selected Island",
    Description = "ไปยังเกาะที่เลือกใน dropdown",
    Callback = function()
        teleportToLocationByName(Options.PredefinedIslandTeleport.Value)
    end
})

FriendTeleportDropdown = Tabs.Teleport:AddDropdown("FriendTeleportDropdown", {
    Title = "Friend",
    Default = 1,
    Values = {"Loading..."},
    Multi = false,
    Description = "เลือกเพื่อนเพื่อเทเลพอร์ต"
})

local TeleportFriendButton = Tabs.Teleport:AddButton({
    Title = "Teleport To Friend",
    Description = "Teleport to the selected player.",
    Callback = function()
        teleportToPlayer(Options.FriendTeleportDropdown.Value or "")
    end
})

Players.PlayerAdded:Connect(refreshFriendDropdown)
Players.PlayerRemoving:Connect(refreshFriendDropdown)

task.spawn(refreshFriendDropdown)

local SaveIsPositionButton = Tabs.Teleport:AddButton({
    Title = "Save Position",
    Description = "Save current location for Position.",
    Callback = function()
        setTeleportLocation(1)
    end
})

local TeleportPositionButton = Tabs.Teleport:AddButton({
    Title = "TP Position ",
    Description = "Teleport to saved Position .",
    Callback = function()
        teleportToLocation(1)
    end
})

-- Auto Skills Tab
local AutoZToggle = Tabs.Skills:AddToggle("AutoZToggle", {
    Title = "Auto Z (Skill 1)",
    Default = false
})

AutoZToggle:OnChanged(function()
    _G.AutoZ = Options.AutoZToggle.Value
end)

local AutoXToggle = Tabs.Skills:AddToggle("AutoXToggle", {
    Title = "Auto X (Skill 2)",
    Default = false
})

AutoXToggle:OnChanged(function()
    _G.AutoX = Options.AutoXToggle.Value
end)

local AutoCToggle = Tabs.Skills:AddToggle("AutoCToggle", {
    Title = "Auto C (Skill 3)",
    Default = false
})

AutoCToggle:OnChanged(function()
    _G.AutoC = Options.AutoCToggle.Value
end)

local AutoVToggle = Tabs.Skills:AddToggle("AutoVToggle", {
    Title = "Auto V (Skill 4)",
    Default = false
})

AutoVToggle:OnChanged(function()
    _G.AutoV = Options.AutoVToggle.Value
end)

local ShopTab = Tabs.Shop


local BuyBaitToggle = ShopTab:AddToggle("BuyBaitToggle", {
    Title = "Buy Ancestral Bait",
    Default = false
})

local BuyBaitAmountSlider = ShopTab:AddSlider("BuyBaitAmount", {
    Title = "Amount",
    Min = 1,
    Max = 100,
    Default = 1,
    Rounding = 1,
    Suffix = "x"
})

local buyBaitThread = nil

local function runBuyBaitLoop()
    if buyBaitThread ~= nil then
        return
    end

    buyBaitThread = task.spawn(function()
        while _G.BuyBait do
            local baitEvent = Events:FindFirstChild("BuyBait")
            if baitEvent then
                baitEvent:FireServer("Ancestral Bait", math.max(1, math.floor(Options.BuyBaitAmount.Value or 1)))
            else
                warn("BuyBait event not found.")
                break
            end

            task.wait(0.2)
        end

        buyBaitThread = nil
    end)
end

BuyBaitToggle:OnChanged(function()
    _G.BuyBait = Options.BuyBaitToggle.Value
    if _G.BuyBait then
        runBuyBaitLoop()
    end
end)

local EZAutoEnzoToggle = BossTab:AddToggle("EZAutoEnzoToggle", {
    Title = "Auto Enzo Boss",
    Default = false
})

local ezAutoEnzoThread = nil

local function runEZAutoEnzoLoop()
    if ezAutoEnzoThread ~= nil then
        return
    end

    print("[EnzoBoss] Auto loop started")
    ezAutoEnzoThread = task.spawn(function()
        local bossPhaseEvent = Events:FindFirstChild("BossPhase2Action")
        if not bossPhaseEvent then
            warn("[EnzoBoss] BossPhase2Action event not found.")
            ezAutoEnzoThread = nil
            return
        end

        local index = 1
        while _G.EZautoEnzo do
            local boss = findEnzoBoss()
            if not boss then
                print("[EnzoBoss] Waiting for Enzo boss to spawn...")
                task.wait(0.5)
            else
                bossPhaseEvent:FireServer({
                    Index = index,
                    Hit = true
                })

                index = index + 1
                task.wait(0.2)
            end
        end

        print("[EnzoBoss] Auto loop stopped")
        ezAutoEnzoThread = nil
    end)
end

EZAutoEnzoToggle:OnChanged(function()
    _G.EZautoEnzo = Options.EZAutoEnzoToggle.Value

    if _G.EZautoEnzo then
        print("[EnzoBoss] Toggle enabled. Starting Enzo fight.")
        local startBossEvent = Events:FindFirstChild("StartBossFight")
        if startBossEvent then
            startBossEvent:FireServer("Enzo", "Nightmare")
        else
            warn("[EnzoBoss] StartBossFight event not found.")
        end
        runEZAutoEnzoLoop()
    else
        print("[EnzoBoss] Toggle disabled.")
    end
end)

local CharacterTab = Tabs.Character

local AntiAFKToggle = CharacterTab:AddToggle("AntiAFKToggle", {
    Title = "Anti AFK",
    Default = false
})

AntiAFKToggle:OnChanged(function()
    _G.AntiAFK = Options.AntiAFKToggle.Value
    if _G.AntiAFK then
        startAntiAFK()
    else
        stopAntiAFK()
    end
end)

local SpeedSlider = CharacterTab:AddSlider("CharacterSpeed", {
    Title = "Walk Speed",
    Default = _G.CharacterWalkSpeed,
    Min = 30,
    Max = 200,
    Rounding = 1,
    Suffix = ""
})

SpeedSlider:OnChanged(function(Value)
    _G.CharacterWalkSpeed = Value
    applyCharacterSettings()
end)

local JumpSlider = CharacterTab:AddSlider("CharacterJump", {
    Title = "Jump Power",
    Default = _G.CharacterJumpPower,
    Min = 16,
    Max = 200,
    Rounding = 1,
    Suffix = ""
})

JumpSlider:OnChanged(function(Value)
    _G.CharacterJumpPower = Value
    applyCharacterSettings()
end)

local CharacterToggle = CharacterTab:AddToggle("CharacterEnabled", {
    Title = "Enable Character Mod",
    Default = _G.CharacterEnabled
})

CharacterToggle:OnChanged(function()
    _G.CharacterEnabled = Options.CharacterEnabled.Value

    if _G.CharacterEnabled then
        applyCharacterSettings()
    else
        disableCharacterSettings()
    end
end)

local ResetCharacterButton = CharacterTab:AddButton({
    Title = "Reset Character Stats",
    Description = "Reset speed and jump to default values",
    Callback = function()
        _G.CharacterWalkSpeed = 16
        _G.CharacterJumpPower = 16
        SpeedSlider:SetValue(_G.CharacterWalkSpeed)
        JumpSlider:SetValue(_G.CharacterJumpPower)
        if _G.CharacterEnabled then
            applyCharacterSettings()
        end
    end
})

local SkillIntervalSlider = Tabs.Skills:AddSlider("SkillInterval", {
    Title = "Delay(s)",
    Min = 0.1,
    Max = 5,
    Default = 1,
    Rounding = 1,
    Suffix = "s"
})

-- Auto Skills Coroutine (starts after UI is created)
local autoSkillsCoroutine = coroutine.create(function()
    while true do
        local skillInterval = Options.SkillInterval.Value or 1
        
        if _G.AutoZ or _G.AutoX or _G.AutoC or _G.AutoV then
            if _G.AutoZ then
                local useSkillEvent = Events:FindFirstChild("UseSkill")
                if useSkillEvent then
                    useSkillEvent:FireServer("Z")
                end
            end
            task.wait(skillInterval / 4)
            if _G.AutoX then
                local useSkillEvent = Events:FindFirstChild("UseSkill")
                if useSkillEvent then
                    useSkillEvent:FireServer("X")
                end
            end
            task.wait(skillInterval / 4)
            if _G.AutoC then
                local useSkillEvent = Events:FindFirstChild("UseSkill")
                if useSkillEvent then
                    useSkillEvent:FireServer("C")
                end
            end
            task.wait(skillInterval / 4)
            if _G.AutoV then
                local useSkillEvent = Events:FindFirstChild("UseSkill")
                if useSkillEvent then
                    useSkillEvent:FireServer("V")
                end
            end
            task.wait(skillInterval / 4)
        else
            task.wait(0.1)
        end
    end
end)

coroutine.resume(autoSkillsCoroutine)

-- Settings Tab
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Auto Fish",
    Content = "สคริปต์ Auto Fish โหลดสำเร็จแล้ว",
    Duration = 5
})
SaveManager:LoadAutoloadConfig()
