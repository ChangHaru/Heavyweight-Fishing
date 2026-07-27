
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Events = ReplicatedStorage:WaitForChild("Events")

_G.AutoFish = false
_G.AutoZ = false
_G.AutoX = false
_G.AutoC = false
_G.AutoV = false
_G.AutoSell = false

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

_G.CharacterWalkSpeed = 30
_G.CharacterJumpPower = 16
_G.CharacterEnabled = false

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
    Title = "Heavyweight Fishing V.1.0.0.0",
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
    Character = Window:AddTab({ Title = "Character", Icon = "user" }),
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
end)


local AutoSellToggle = Tabs.Main:AddToggle("AutoSellToggle", {
    Title = "Auto Sell Fish",
    Default = false
})

AutoSellToggle:OnChanged(function()
    _G.AutoSell = Options.AutoSellToggle.Value
end)

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

local CharacterTab = Tabs.Character

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
