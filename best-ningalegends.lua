if not getgenv then error("请使用高等级注入器执行") end

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/theyin345/Roblox/refs/heads/main/windui.lua"))()

getgenv().BringConfig = {
    SelectedTargets = {},
    Distance = 3,
    Enabled = false
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

local fakeHitboxes = {}                         
local fixedLockPosition = Vector3.new(236, 89, -285) 
local fixedLockEnabled = false                  
local antiAFKConnection = nil

local lightKarmaRunning = false
local evilKarmaRunning = false
local thunderRunning = false
local wonderRunning = false

getgenv().autoswing = false
getgenv().autobuyswords = false
getgenv().autobuybelts = false
getgenv().autobuyranks = false
getgenv().autobuyskill = false
getgenv().autobuyshurikens = false    
getgenv().autosell = false       

getgenv().AutoBo = false
getgenv().AutoBo1 = false
getgenv().AutoBo2 = false
getgenv().AutoDuel = false 

local function teleportTo(placeCFrame)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = placeCFrame
    end
end

-- 克隆逻辑
_G.autoClone = false
_G.autoClone440 = false

local function cloneYellowSqueak(loopCount, switchGetter)
    spawn(function()
        while switchGetter() do
            pcall(function()
                local basic = game.Players.LocalPlayer.petsFolder:FindFirstChild("Basic")
                if not basic then return end

                local yellowSqueak = basic:FindFirstChild("Yellow Squeak")
                if not yellowSqueak then
                    local shopItem = game:GetService("ReplicatedStorage").cPetShopFolder:FindFirstChild("Yellow Squeak")
                    if shopItem then
                        game:GetService("ReplicatedStorage").cPetShopRemote:InvokeServer(shopItem)
                        task.wait(0.1)
                        yellowSqueak = basic:FindFirstChild("Yellow Squeak")
                    end
                end

                if yellowSqueak then
                    for i = 1, loopCount do
                        game:GetService("ReplicatedStorage").rEvents.petCloneEvent:FireServer("clonePet", yellowSqueaks)
                    end
                end
            end)
            task.wait(0.01)
        end
    end)
end

_G.autoSellYellowSqueak = false

spawn(function()
    while task.wait(1) do
        if _G.autoSellYellowSqueak then
            pcall(function()
                local petsFolder = game.Players.LocalPlayer:FindFirstChild("petsFolder")
                if petsFolder then
                    local basic = petsFolder:FindFirstChild("Basic")
                    if basic then
                        local yellowSqueaks = {}
                        for _, pet in ipairs(basic:GetChildren()) do
                            if pet.Name == "Yellow Squeak" then
                                table.insert(yellowSqueaks, pet)
                            end
                        end
                        if #yellowSqueaks > 1 then
                            for i = 2, #yellowSqueaks do
                                game:GetService("ReplicatedStorage").rEvents.sellPetEvent:FireServer("sellPet", yellowSqueaks)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

local function cleanCoinUI()
    local playerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        local statGui = playerGui:FindFirstChild("statEffectsGui")
        if statGui then
            statGui:Destroy()
            print("已删除UI")
        end
    end
end

local function clearFakeHitboxes()
    for _, box in pairs(fakeHitboxes) do
        if box then box:Destroy() end
    end
    fakeHitboxes = {}
end

local bringConnection
local function startBring()
    if bringConnection then bringConnection:Disconnect() end
    bringConnection = RunService.Heartbeat:Connect(function()
        if not getgenv().BringConfig.Enabled then
            clearFakeHitboxes()
            return
        end

        local targets = getgenv().BringConfig.SelectedTargets
        if not targets or type(targets) ~= "table" or #targets == 0 or not LocalPlayer.Character then
            clearFakeHitboxes()
            return
        end

        local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end

        local desiredCFrame = myRoot.CFrame * CFrame.new(0, 0, -getgenv().BringConfig.Distance)
        local activeNames = {}

        for _, targetName in ipairs(targets) do
            local targetPlayer = Players:FindFirstChild(targetName)
            if targetPlayer and targetPlayer ~= LocalPlayer then
                activeNames[targetName] = true

                if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local targetRoot = targetPlayer.Character.HumanoidRootPart
                    targetRoot.CFrame = desiredCFrame
                    targetRoot.AssemblyLinearVelocity = Vector3.zero

                    local fakeHitbox = fakeHitboxes[targetName]
                    if not fakeHitbox or fakeHitbox.Parent ~= workspace then
                        fakeHitbox = Instance.new("Part")
                        fakeHitbox.Size = targetRoot.Size or Vector3.new(2, 2, 1)
                        fakeHitbox.Transparency = 0.5
                        fakeHitbox.Color = Color3.fromRGB(255, 0, 0)
                        fakeHitbox.CanCollide = true
                        fakeHitbox.Anchored = true
                        fakeHitbox.Name = "HumanoidRootPart"
                        fakeHitbox.Parent = workspace

                        local fakeInstance = Instance.new("ObjectValue")
                        fakeInstance.Name = "Creator"
                        fakeInstance.Value = targetPlayer
                        fakeInstance.Parent = fakeHitbox

                        fakeHitboxes[targetName] = fakeHitbox
                    end
                    fakeHitbox.CFrame = desiredCFrame
                end
            end
        end

        for name, box in pairs(fakeHitboxes) do
            if not activeNames[name] then
                if box then box:Destroy() end
                fakeHitboxes[name] = nil
            end
        end
    end)
end

local function startPositionLock()
    spawn(function()
        while true do
            if fixedLockEnabled and LocalPlayer.Character then
                local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(fixedLockPosition)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                end
            end
            task.wait(0.1)
        end
    end)
end

local function getPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.Name)
        end
    end
    return list
end

local function toggleAntiAFK(state)
    if state then
        if antiAFKConnection then antiAFKConnection:Disconnect() end
        antiAFKConnection = LocalPlayer.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    else
        if antiAFKConnection then antiAFKConnection:Disconnect() end
        antiAFKConnection = nil
    end
end

local function autoSwing()
    spawn(function()
        while getgenv().autoswing do task.wait() game.Players.LocalPlayer.ninjaEvent:FireServer("swingKatana") end
    end)
end

local IslandList = {"Ground","Astral Island","Space Island","Tundra Island","Eternal Island","Sandstorm","Thunderstorm","Ancient Inferno Island","Midnight Shadow Island","Mythical Souls Island","Winter Wonder Island"}

local function autoBuySwords() spawn(function() while getgenv().autobuyswords do task.wait(0.5) for _,v in ipairs(IslandList) do game.Players.LocalPlayer.ninjaEvent:FireServer("buyAllSwords",v) end end end) end
local function autoBuyBelts() spawn(function() while getgenv().autobuybelts do task.wait(0.5) for _,v in ipairs(IslandList) do game.Players.LocalPlayer.ninjaEvent:FireServer("buyAllBelts",v) end end end) end
local function autoBuyRanks() spawn(function() while getgenv().autobuyranks do task.wait(0.5) for _,v in ipairs(game:GetService("ReplicatedStorage").Ranks.Ground:GetChildren()) do game.Players.LocalPlayer.ninjaEvent:FireServer("buyRank",v.Name) end end end) end
local function autoBuySkills() spawn(function() while getgenv().autobuyskill do task.wait(0.5) for _,v in ipairs(IslandList) do game.Players.LocalPlayer.ninjaEvent:FireServer("buyAllSkills",v) end end end) end
local function autoBuyShurikens() spawn(function() while getgenv().autobuyshurikens do task.wait(0.5) for _,v in ipairs(IslandList) do game.Players.LocalPlayer.ninjaEvent:FireServer("buyAllShurikens",v) end end end) end


-- 忍术出售循环
spawn(function()
    while task.wait(0.1) do
        if getgenv().autosell then
            pcall(function()
                local sellCirclesFolder = workspace:FindFirstChild("sellAreaCircles")
                if sellCirclesFolder and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local targetCircleInner = nil
                    local count = 0
                    
                    for _, v in ipairs(sellCirclesFolder:GetChildren()) do
                        if v.Name == "sellAreaCircle16" then
                            count = count + 1
                            if count == 2 then
                                targetCircleInner = v:FindFirstChild("circleInner")
                                break
                            end
                        end
                    end
                    
                    if not targetCircleInner and sellCirclesFolder:FindFirstChild("sellAreaCircle16") then
                        local firstCircle = sellCirclesFolder:FindFirstChild("sellAreaCircle16")
                        if firstCircle then
                            targetCircleInner = firstCircle:FindFirstChild("circleInner")
                        end
                    end

                    if targetCircleInner and workspace:FindFirstChild("Part") then
                        local hrp = LocalPlayer.Character.HumanoidRootPart
                        targetCircleInner.CFrame = hrp.CFrame
                        task.wait(0.1)
                        targetCircleInner.CFrame = workspace.Part.CFrame
                    end
                end
            end)
        end
    end
end)

local BossFunctions = {
    doBo = function()
        spawn(function()
            while getgenv().AutoBo == true do
                teleportTo(game:GetService("Workspace").bossFolder.RobotBoss.UpperTorso.CFrame)
                local args = {[1] = "swingKatana"}
                game.Players.LocalPlayer:WaitForChild("ninjaEvent"):FireServer(unpack(args))
                task.wait()
            end
        end)
    end,

    doBo1 = function()
        spawn(function()
            while getgenv().AutoBo1 == true do
                teleportTo(game:GetService("Workspace").bossFolder.EternalBoss.UpperTorso.CFrame)
                local args = {[1] = "swingKatana"}
                game.Players.LocalPlayer:WaitForChild("ninjaEvent"):FireServer(unpack(args))
                task.wait()
            end
        end)
    end,

    doBo2 = function()
        spawn(function()
            while getgenv().AutoBo2 == true do
                teleportTo(game:GetService("Workspace").bossFolder.AncientMagmaBoss.UpperTorso.CFrame)
                local args = {[1] = "swingKatana"}
                game.Players.LocalPlayer:WaitForChild("ninjaEvent"):FireServer(unpack(args))
                task.wait()
            end
        end)
    end,

    doDuel = function()
        spawn(function()
            while getgenv().AutoDuel == true do
                pcall(function()
                    local args = {"joinDuel"}
                    game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("duelEvent"):FireServer(unpack(args))
                end)
                task.wait(1)
            end
        end)
    end
}

local function masterAllElements()
    local elements = {"Shadow Charge","Electral Chaos","Blazing Entity","Shadowfire","Lightning","Masterful Wrath","Inferno","Eternity Storm","Frost"}
    for _, element in ipairs(elements) do
        game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("elementMasteryEvent"):FireServer(element)
        task.wait(0.3)
    end
    WindUI:Notify({Title = "成功", Content = "已获取所有元素", Duration = 5})
end

local function unlockAllIslands()
    local islands = workspace.islandUnlockParts:GetChildren()
    for _, part in pairs(islands) do
        if part:FindFirstChild("islandSignPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = part.islandSignPart.CFrame
            task.wait(0.6)
        end
    end
    WindUI:Notify({Title = "成功", Content = "已解锁所有岛屿", Duration = 5})
end

WindUI:SetTheme("Dark")

local Window = WindUI:CreateWindow({
    Title = "Ninja Legends ⚡",
    Author = "By 九夏云深",
    Folder = "NinjaLegends_WindUI",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    ToggleKey = Enum.KeyCode.G
})

Window:OnOpen(function()
    WindUI:Notify({Title = "UI已打开", Content = "已显示，按G键隐藏", Duration = 2})
end)

Window:OnClose(function()
    WindUI:Notify({Title = "UI已隐藏", Content = "已隐藏，按G键打开", Duration = 2})
end)

local MainSection = Window:Section({
    Title = "功能菜单",
    Opened = true,
})

local function AddTab(section, title, icon)
    return section:Tab({ Title = title, Icon = icon, Opened = true })
end

local TabOne   = AddTab(MainSection, "一键区", "sparkles")
local TabAuto  = AddTab(MainSection, "自动区", "zap")
local TabBring = AddTab(MainSection, "刷击杀", "crosshair")
local TabBoss  = AddTab(MainSection, "刷Boss区", "shield-alert")
local TabDuel  = AddTab(MainSection, "决斗区", "swords")
local TabPet   = AddTab(MainSection, "宠物克隆", "dog")
local TabGem   = AddTab(MainSection, "金币修改", "coins")
local TabMisc  = AddTab(MainSection, "其他", "settings")

TabOne:Select()

local SecBring = TabBring:Section({ Title = "击杀设定", Opened = true })
SecBring:Paragraph({ Title = "上榜专属", Desc = "可多选玩家" })

local initialList = getPlayerList()
local playerDropdown = SecBring:Dropdown({
    Title = "选择目标玩家 (可多选)",
    Values = #initialList > 0 and initialList or {"无其他玩家"},
    Value = {},          
    Multi = true,        
    AllowNone = true,    
    Callback = function(options)
        getgenv().BringConfig.SelectedTargets = options or {}
    end
})

SecBring:Button({
    Title = "刷新玩家列表",
    Callback = function()
        local updatedList = getPlayerList()
        playerDropdown:SetValues(#updatedList > 0 and updatedList or {"无其他玩家"})
        WindUI:Notify({Title = "成功", Content = "已刷新当前服务器玩家列表", Duration = 3})
    end
})

SecBring:Slider({
    Title = "吸取距离",
    Step = 1,
    Value = { Min = 1, Max = 10, Default = 3 },
    Callback = function(v) getgenv().BringConfig.Distance = v end
})

SecBring:Toggle({
    Title = "启用吸人",
    Value = false,
    Callback = function(state)
        getgenv().BringConfig.Enabled = state
        if state then startBring() else clearFakeHitboxes() end
    end
})

SecBring:Divider()
SecBring:Paragraph({ Title = "其他辅助", Desc = "拥有快剑刷的更快" })

SecBring:Button({
    Title = "获取快剑通行证",
    Callback = function()
        local success, err = pcall(function()
            game:GetService("ReplicatedStorage").gamepassIds["Faster Sword"].Parent = game.Players.LocalPlayer.ownedGamepasses
        end)
        if success then
            WindUI:Notify({Title = "成功", Content = "已成功获取快剑！", Duration = 4})
        else
            WindUI:Notify({Title = "错误", Content = "获取失败: " .. tostring(err), Duration = 4})
        end
    end
})

SecBring:Divider()
SecBring:Paragraph({ Title = "锁定位置", Desc = "强行锁定位置到山丘" })
SecBring:Toggle({
    Title = "强锁位置",
    Value = false,
    Callback = function(state)
        fixedLockEnabled = state
        WindUI:Notify({Title = "位置锁定", Content = state and "已开启锁定" or "已关闭锁定", Duration = 3})
    end
})

local SecAuto = TabAuto:Section({ Title = "自动功能区", Opened = true })
SecAuto:Paragraph({ Title = "自动功能", Desc = "基础日常自动挂机" })
SecAuto:Toggle({Title = "自动挥剑", Value = false, Callback = function(state) getgenv().autoswing = state; if state then autoSwing() end end})
SecAuto:Toggle({Title = "自动出售", Value = false, Callback = function(state) getgenv().autosell = state end})
SecAuto:Toggle({Title = "自动买剑", Value = false, Callback = function(state) getgenv().autobuyswords = state; if state then autoBuySwords() end end})
SecAuto:Toggle({Title = "自动买腰带", Value = false, Callback = function(state) getgenv().autobuybelts = state; if state then autoBuyBelts() end end})
SecAuto:Toggle({Title = "自动买阶级", Value = false, Callback = function(state) getgenv().autobuyranks = state; if state then autoBuyRanks() end end})
SecAuto:Toggle({Title = "自动买技能", Value = false, Callback = function(state) getgenv().autobuyskill = state; if state then autoBuySkills() end end})
SecAuto:Toggle({Title = "自动买手里剑", Value = false, Callback = function(state) getgenv().autobuyshurikens = state; if state then autoBuyShurikens() end end})

local SecBoss = TabBoss:Section({ Title = "刷Boss区", Opened = true })
SecBoss:Paragraph({ Title = "自动打Boss", Desc = "全自动传送击杀Boss" })
SecBoss:Toggle({
    Title = "普通Boss",
    Value = false,
    Callback = function(state)
        getgenv().AutoBo = state
        if state then BossFunctions.doBo() end
    end
})
SecBoss:Toggle({
    Title = "永恒Boss",
    Value = false,
    Callback = function(state)
        getgenv().AutoBo1 = state
        if state then BossFunctions.doBo1() end
    end
})
SecBoss:Toggle({
    Title = "岩浆Boss",
    Value = false,
    Callback = function(state)
        getgenv().AutoBo2 = state
        if state then BossFunctions.doBo2() end
    end
})

local SecDuel = TabDuel:Section({ Title = "决斗匹配", Opened = true })
SecDuel:Paragraph({ Title = "决斗功能", Desc = "自动参与决斗" })
SecDuel:Toggle({
    Title = "自动加入决斗",
    Value = false,
    Callback = function(state)
        getgenv().AutoDuel = state
        if state then BossFunctions.doDuel() end
    end
})

local SecPet = TabPet:Section({ Title = "宠物克隆与出售", Opened = true })
SecPet:Paragraph({ Title = "上榜用 程子乐同款", Desc = "优化环境之前先出售一次忍术" })

-- 克隆60宠物
SecPet:Toggle({
    Title = "自动克隆（60宠物）",
    Value = false,
    Callback = function(state)
        _G.autoClone = state
        if state then
            cloneYellowSqueak(15, function() return _G.autoClone end)
            WindUI:Notify({Title = "克隆", Content = "已开启60宠物克隆", Duration = 3})
        else
            WindUI:Notify({Title = "克隆", Content = "已停止60宠物克隆", Duration = 3})
        end
    end
})

-- 克隆440宠物
SecPet:Toggle({
    Title = "自动克隆（440宠物）",
    Value = false,
    Callback = function(state)
        _G.autoClone440 = state
        if state then
            cloneYellowSqueak(10, function() return _G.autoClone440 end)
            WindUI:Notify({Title = "克隆", Content = "已开启440宠物克隆", Duration = 3})
        else
            WindUI:Notify({Title = "克隆", Content = "已停止440宠物克隆", Duration = 3})
        end
    end
})

-- 出售
SecPet:Toggle({
    Title = "自动出售",
    Value = false,
    Callback = function(state)
        _G.autoSellYellowSqueak = state
        if state then
            WindUI:Notify({Title = "出售", Content = "已开启出售", Duration = 3})
        else
            WindUI:Notify({Title = "出售", Content = "已停止出售", Duration = 3})
        end
    end
})

-- 优化环境
SecPet:Button({
    Title = "优化环境（先出售一次忍术）",
    Callback = function()
        pcall(cleanCoinUI)
        spawn(function()
            while true do
                task.wait(0.5)
                pcall(cleanCoinUI)
            end
        end)
        WindUI:Notify({Title = "优化环境", Content = "已删除UI", Duration = 4})
    end
})

local SecOne = TabOne:Section({ Title = "一键功能区域", Opened = true })
SecOne:Paragraph({ Title = "快捷功能", Desc = "一键完成大量操作" })
SecOne:Button({Title = "一键满元素", Callback = masterAllElements})
SecOne:Button({Title = "一键解锁所有岛屿", Callback = unlockAllIslands})
SecOne:Button({
    Title = "一键买绝版宠物(需要足够气)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/theyin345/Roblox/refs/heads/main/ningalegends.lua"))()
    end
})

SecOne:Divider()

local islandCFrameMap = {
    ["传送到出生点"] = CFrame.new(25.665502548217773, 3.4228405952453613, 29.919952392578125),
    ["传送到附魔岛"] = CFrame.new(51.17238235473633, 766.1807861328125, -138.44842529296875),
    ["传送到星界岛"] = CFrame.new(207.2932891845703, 2013.88037109375, 237.36672973632812),
    ["传送到神秘岛"] = CFrame.new(171.97178649902344, 4047.380859375, 42.0699577331543),
    ["传送到太空岛"] = CFrame.new(148.83824157714844, 5657.18505859375, 73.5014877319336),
    ["传送到冻土岛"] = CFrame.new(139.28330993652344, 9285.18359375, 77.36406707763672),
    ["传送到永恒岛"] = CFrame.new(149.34817504882812, 13680.037109375, 73.3861312866211),
    ["传送到沙暴岛"] = CFrame.new(133.37144470214844, 17686.328125, 72.00334167480469),
    ["传送到雷暴岛"] = CFrame.new(143.19349670410156, 24070.021484375, 78.05432891845703),
    ["传送到远古炼狱岛"] = CFrame.new(141.27163696289062, 28256.294921875, 69.3790283203125),
    ["传送到午夜暗影岛"] = CFrame.new(132.74267578125, 33206.98046875, 57.495574951171875),
    ["传送到神秘灵魂岛"] = CFrame.new(137.76148986816406, 39317.5703125, 61.06639862060547),
    ["传送到冬季奇迹岛"] = CFrame.new(137.2720184326172, 46010.5546875, 55.941951751708984),
    ["传送到黄金大师岛"] = CFrame.new(128.32339477539062, 52607.765625, 56.69411849975586),
    ["传送到龙传奇岛"] = CFrame.new(146.35226440429688, 59594.6796875, 77.53300476074219),
    ["传送到赛博传奇岛"] = CFrame.new(137.3321075439453, 66669.1640625, 72.21722412109375),
    ["传送到天岚超能岛"] = CFrame.new(135.48077392578125, 70271.15625, 57.02311325073242),
    ["传送到混沌传奇岛"] = CFrame.new(148.58590698242188, 74442.8515625, 69.3177719116211),
    ["传送到灵魂融合岛"] = CFrame.new(136.9700927734375, 79746.984375, 58.54051971435547),
    ["传送到黑暗元素岛"] = CFrame.new(141.697265625, 83198.984375, 72.73107147216797),
    ["传送到内心和平岛"] = CFrame.new(135.3157501220703, 87051.0625, 66.78429412841797),
    ["传送到炽烈漩涡岛"] = CFrame.new(135.08216857910156, 91246.0703125, 69.56692504882812),
    ["传送到35倍金币区域"] = CFrame.new(86.2938232421875, 91245.765625, 120.54232788085938),
    ["传送到克隆宠物"] = CFrame.new(4593.21337890625, 130.87181091308594, 1430.2239990234375)
}

local islandNamesClean = {
    "传送到出生点", "传送到附魔岛", "传送到星界岛", "传送到神秘岛", "传送到太空岛", 
    "传送到冻土岛", "传送到永恒岛", "传送到沙暴岛", "传送到雷暴岛", "传送到远古炼狱岛", 
    "传送到午夜暗影岛", "传送到神秘灵魂岛", "传送到冬季奇迹岛", "传送到黄金大师岛", 
    "传送到龙传奇岛", "传送到赛博传奇岛", "传送到天岚超能岛", "传送到混沌传奇岛", 
    "传送到灵魂融合岛", "传送到黑暗元素岛", "传送到内心和平岛", "传送到炽烈漩涡岛", 
    "传送到35倍金币区域", "传送到克隆宠物"
}

SecOne:Dropdown({
    Title = "选择传送岛屿",
    Values = islandNamesClean,
    Value = "",
    Callback = function(selected)
        if islandCFrameMap[selected] then
            teleportTo(islandCFrameMap[selected])
        end
    end
})

local SecGem = TabGem:Section({ Title = "优化了功能", Opened = true })

SecGem:Paragraph({ 
    Title = "【必看内容】", 
    Desc = "【满元素禁用 请换新号！！！】按照①②③等的顺序点击，否则将无法购买任何东西！直接点人名后的交易按钮就能交易" 
})

SecGem:Button({
    Title = "①：金币变成-inf",
    Callback = function()
        game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("zenMasterEvent"):FireServer("convertGems", -99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999)
        WindUI:Notify({Title = "第一步", Content = "第一步已执行！请执行第二步。", Duration = 4})
    end
})

SecGem:Button({
    Title = "②：解锁交易",
    Callback = function()
        game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("zenMasterEvent"):FireServer("convertGems", 1000000010000000100000001000000010000000100000001000000010000000100000001000000010000000100000001000000010000000100000001000000000000000000000000000000000000000000000000010000000100000001000000010000000100000001000000010000000100000001000000010000000100000001000000010000000000000000000000000000000000000000000000000)
        WindUI:Notify({Title = "第二步", Content = "第二步已执行！直接点交易按钮即可", Duration = 4})
    end
})

SecGem:Button({
    Title = "③：一键元素重生",
    Callback = function()
        game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("elementMasteryEvent"):FireServer("Shadow Charge")
        game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("elementMasteryEvent"):FireServer("Electral Chaos")
        game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("elementMasteryEvent"):FireServer("Blazing Entity")
        game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("elementMasteryEvent"):FireServer("Shadowfire")
        game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("elementMasteryEvent"):FireServer("Lightning")
        game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("elementMasteryEvent"):FireServer("Masterful Wrath")
        game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("elementMasteryEvent"):FireServer("Inferno")
        game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("elementMasteryEvent"):FireServer("Eternity Storm")
        game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("elementMasteryEvent"):FireServer("Frost")
        task.wait(0.3)
        WindUI:Notify({Title = "第三步", Content = "第三步已执行！现在可以进行金币修改。", Duration = 4})
    end
})

local lastInputValue = 0
local isLooping = false

SecGem:Input({
    Title = "金币数量修改",
    Placeholder = "请输入你想要的金币数量",
    Callback = function(I)
        local num = tonumber(I)
        if num and num > 0 then
            lastInputValue = num
            game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("zenMasterEvent"):FireServer("convertGems", num)
            WindUI:Notify({Title = "金币修改", Content = "已设定金币数量：" .. num, Duration = 3})
        else
            WindUI:Notify({Title = "错误", Content = "请输入有效正整数！", Duration = 3})
        end
    end
})

SecGem:Toggle({
    Title = "循环修改",
    Value = false,
    Callback = function(Value)
        isLooping = Value
        if isLooping and lastInputValue > 0 then
            spawn(function()
                while isLooping and lastInputValue > 0 do
                    game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("zenMasterEvent"):FireServer("convertGems", lastInputValue)
                    task.wait(0.5)
                end
            end)
        end
    end
})

local SecMisc = TabMisc:Section({ Title = "业报收集", Opened = true })
SecMisc:Paragraph({ Title = "实用功能", Desc = "反挂机与业报收集" })

SecMisc:Toggle({
    Title = "反挂机",
    Value = false,
    Callback = function(state)
        toggleAntiAFK(state)
    end
})

SecMisc:Toggle({
    Title = "自动收集光明业报",
    Value = false,
    Callback = function(state)
        lightKarmaRunning = state
        if state then
            task.spawn(function()
                while lightKarmaRunning do
                    pcall(function()
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local part = workspace:FindFirstChild("Part")
                        if hrp and workspace:FindFirstChild("lightKarmaChest") then
                            workspace.lightKarmaChest["circleInner"].CFrame = hrp.CFrame
                            task.wait(0.2)
                            if part then
                                workspace.lightKarmaChest["circleInner"].CFrame = part.CFrame
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

SecMisc:Toggle({
    Title = "自动收集黑暗业报",
    Value = false,
    Callback = function(state)
        evilKarmaRunning = state
        if state then
            task.spawn(function()
                while evilKarmaRunning do
                    pcall(function()
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local part = workspace:FindFirstChild("Part")
                        if hrp and workspace:FindFirstChild("evilKarmaChest") then
                            workspace.evilKarmaChest["circleInner"].CFrame = hrp.CFrame
                            task.wait(0.2)
                            if part then
                                workspace.evilKarmaChest["circleInner"].CFrame = part.CFrame
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

SecMisc:Toggle({
    Title = "自动收集灵魂",
    Value = false,
    Callback = function(state)
        thunderRunning = state
        if state then
            task.spawn(function()
                while thunderRunning do
                    pcall(function()
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local part = workspace:FindFirstChild("Part")
                        if hrp and workspace:FindFirstChild("thunderChest") then
                            workspace.thunderChest["circleInner"].CFrame = hrp.CFrame
                            task.wait(0.2)
                            if part then
                                workspace.thunderChest["circleInner"].CFrame = part.CFrame
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

SecMisc:Toggle({
    Title = "自动收集宝石",
    Value = false,
    Callback = function(state)
        wonderRunning = state
        if state then
            task.spawn(function()
                while wonderRunning do
                    pcall(function()
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local part = workspace:FindFirstChild("Part")
                        if hrp and workspace:FindFirstChild("wonderChest") then
                            workspace.wonderChest["circleInner"].CFrame = hrp.CFrame
                            task.wait(0.2)
                            if part then
                                workspace.wonderChest["circleInner"].CFrame = part.CFrame
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

startPositionLock()

WindUI:Notify({
    Title = "加载成功",
    Content = "感谢使用",
    Duration = 6
})
