--BFNF

if game.PlaceId ~= 6520999642 then
    return warn('Please join "Basically FNF: Remix" to use this script!')[cite: 1]
end

getgenv().PlayEnabled = getgenv().PlayEnabled or false
getgenv().FarmEnabled = getgenv().FarmEnabled or false
getgenv().Sensibility = getgenv().Sensibility or 2

local u1 = loadstring(game:HttpGet('https://raw.githubusercontent.com/Waza80/scripts/main/Notifications.lua'))()[cite: 1]
local u2 = loadstring(game:HttpGet('https://raw.githubusercontent.com/Waza80/scripts/main/Teleporter.lua'))()[cite: 1]
local u3 = nil
local u4 = 0.5
local v5 = nil
local u6 = false
local u7 = {}
local u8 = {}
local u9 = {
    'Left',
    'Down',
    'Up',
    'Right',
}
local u10, u11, u12, u13, u14, u15, u16, u17, u18, u19 = false, false, false, false, false, false, false, false, false, false
local u20 = Color3.fromRGB(225, 225, 0)
local u21 = Color3.fromRGB(255, 255, 255)
local _LocalPlayer = game.Players.LocalPlayer
local v23 = 'v1.0.5 - By waza80'[cite: 1]
local _CoreGui = game:GetService('CoreGui')
local _HttpService = game:GetService('HttpService')
local _TweenService = game:GetService('TweenService')
local _TeleportService = game:GetService('TeleportService')
local _VirtualInputManager = game:GetService('VirtualInputManager')

-- ==================== 独立 UI 架构 (不依赖官方 CoreGui) ====================
local screenGuiName = "Waza80_BFNF_UI"
if _CoreGui:FindFirstChild(screenGuiName) then
    _CoreGui[screenGuiName]:Destroy()
end

local _ScreenGui = Instance.new('ScreenGui')
_ScreenGui.Name = screenGuiName
_ScreenGui.ResetOnSpawn = false
_ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
_ScreenGui.Parent = _CoreGui

-- 主面板 (替代官方顶栏，采用悬浮窗设计，位于屏幕左上角)
local _MainFrame = Instance.new('Frame', _ScreenGui)
_MainFrame.Name = 'MainFrame'
_MainFrame.Size = UDim2.new(0, 220, 0, 48)
_MainFrame.Position = UDim2.new(0, 20, 0, 20)
_MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
_MainFrame.BackgroundTransparency = 0.2
_MainFrame.BorderSizePixel = 0

local _UICorner = Instance.new('UICorner', _MainFrame)
_UICorner.CornerRadius = UDim.new(0, 8)

local _UIListLayout = Instance.new('UIListLayout', _MainFrame)
_UIListLayout.FillDirection = Enum.FillDirection.Horizontal
_UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
_UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
_UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
_UIListLayout.Padding = UDim.new(0, 6)

-- 创建功能按钮的辅助函数
local function createButton(name, layoutOrder, iconId)
    local btn = Instance.new('TextButton', _MainFrame)
    btn.Name = name
    btn.Size = UDim2.new(0, 36, 0, 36)
    btn.Text = ''
    btn.LayoutOrder = layoutOrder
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.BorderSizePixel = 0
    
    local corner = Instance.new('UICorner', btn)
    corner.CornerRadius = UDim.new(0, 6)
    
    local icon = Instance.new('ImageLabel', btn)
    icon.Name = 'Icon'
    icon.Size = UDim2.new(0, 22, 0, 22)
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.Position = UDim2.new(0.5, 0, 0.5, 0)
    icon.Image = iconId
    icon.BackgroundTransparency = 1
    
    local stringVal = Instance.new('StringValue', btn)
    stringVal.Name = 'ID'
    
    return btn, icon
end

local _TextButton, _ImageLabel = createButton('AutoPlayButton', 1, 'rbxassetid://13882953872')
local _TextButton2, _ImageLabel3 = createButton('AutoFarmButton', 2, 'rbxassetid://13902591674')
local _TextButton3, _ImageLabel5 = createButton('RespawnButton', 3, 'rbxassetid://13903165323')
local _TextButton4, _ImageLabel7 = createButton('TeleportButton', 4, 'rbxassetid://13945246221')
local _TextButton5, _ImageLabel9 = createButton('DeleteButton', 5, 'rbxassetid://13903165548')

-- 附加版权文字标签
local _TextLabel = Instance.new('TextLabel', _MainFrame)
_TextLabel.Name = 'Credits'
_TextLabel.Size = UDim2.new(0, 0, 0, 36)
_TextLabel.Position = UDim2.new(1, 10, 0, 0)
_TextLabel.BackgroundTransparency = 1
_TextLabel.Text = v23
_TextLabel.TextSize = 14
_TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
_TextLabel.TextStrokeTransparency = 0.6
_TextLabel.FontFace = Font.new('rbxasset://fonts/families/FredokaOne.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
_TextLabel.AutomaticSize = Enum.AutomaticSize.X

local u66 = _HttpService:GenerateGUID(false)
_TextButton.ID.Value = u66
-- ===========================================================================

function GetClosestP2()
    local _huge = math.huge
    local v51, v52, v53 = pairs(workspace.PersonalStages:GetChildren())
    local v54 = nil

    while true do
        local v55
        v53, v55 = v51(v52, v53)
        if v53 == nil then break end

        local StageDistance = (v55.P2.Position - _LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        if StageDistance < _huge then
            _huge = StageDistance
            v54 = v55.P2
        end
    end

    return v54
end

function fireproximityprompt(p56)
    local _HoldDuration = p56.HoldDuration
    p56.HoldDuration = 0
    p56:InputHoldBegin()
    task.wait(0.05)
    p56:InputHoldEnd()
    p56.HoldDuration = _HoldDuration
end

function shuffle(p58)
    for v59 = #p58, 2, -1 do
        local v60 = math.random(v59)
        local v61 = p58[v60]
        p58[v60] = p58[v59]
        p58[v59] = v61
    end
    return p58
end

local u62 = _LocalPlayer
if not isfile('BFNF-Waza80-ST') then
    v5 = true
end

repeat
    task.wait()
until game:GetService('Players').LocalPlayer.PlayerGui.Main.Loading.Visible == false

local _TPPart = workspace.Interactables.TPPart
local _SongSelect = u62.PlayerGui.Main.SongSelect
local u65 = _HttpService:GenerateGUID(false)

u8.Left = u62.PlayerGui.Main.MainFrame.Menu.Settings.Controls.KeyL.Input.Text
u8.Down = u62.PlayerGui.Main.MainFrame.Menu.Settings.Controls.KeyD.Input.Text
u8.Up = u62.PlayerGui.Main.MainFrame.Menu.Settings.Controls.KeyU.Input.Text
u8.Right = u62.PlayerGui.Main.MainFrame.Menu.Settings.Controls.KeyR.Input.Text

if getgenv().PlayEnabled ~= true then
    _ImageLabel.ImageColor3 = u21
else
    _ImageLabel.ImageColor3 = u20
    _TextLabel.TextColor3 = u20
end
if getgenv().FarmEnabled ~= true then
    _ImageLabel3.ImageColor3 = u21
else
    _ImageLabel3.ImageColor3 = u20
end

-- 按钮交互逻辑恢复
_TextButton.MouseEnter:Connect(function()
    _TweenService:Create(_ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Cubic), { Size = UDim2.new(0, 24, 0, 24) }):Play()
    u10 = true
end)
_TextButton.MouseLeave:Connect(function()
    u15 = false
    _TweenService:Create(_ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Cubic), { Size = UDim2.new(0, 22, 0, 22) }):Play()
    u10 = false
end)
_TextButton.MouseButton1Down:Connect(function()
    _TweenService:Create(_ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Cubic), { Size = UDim2.new(0, 20, 0, 20) }):Play()
    local u67 = true
    local u68 = false
    local u69 = _TextButton.MouseLeave:Connect(function() u67 = false end)
    local u70 = _TextButton.MouseButton1Up:Connect(function() u68 = true end)

    task.spawn(function()
        local v71 = 0
        repeat
            v71 = v71 + 1
            task.wait(0.1)
        until v71 == 9 or (u67 == false or u68 == true)

        if not (u67 == false or u68 == true) then
            u15 = true
            if not u6 then
                u6 = true
                u1:Info('AutoPlay', 'Allows you to automatically play notes!', nil, nil, true)
                u6 = false
            end
            u15 = false
        end
        u69:Disconnect()
        u70:Disconnect()
    end)
end)
_TextButton.MouseButton1Up:Connect(function()
    local targetSize = u10 and UDim2.new(0, 24, 0, 24) or UDim2.new(0, 22, 0, 22)
    _TweenService:Create(_ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Cubic), { Size = targetSize }):Play()
end)
_TextButton.MouseButton1Click:Connect(function()
    if not u15 then
        if not getgenv().FarmEnabled then
            if not getgenv().PlayEnabled or u3 ~= nil then
                if not getgenv().PlayEnabled and u3 == nil then
                    getgenv().PlayEnabled = true
                    _TweenService:Create(_ImageLabel, TweenInfo.new(u4, Enum.EasingStyle.Cubic), { ImageColor3 = u20 }):Play()
                    _TweenService:Create(_TextLabel, TweenInfo.new(u4, Enum.EasingStyle.Cubic), { TextColor3 = u20 }):Play()
                end
            else
                getgenv().PlayEnabled = false
                _TweenService:Create(_ImageLabel, TweenInfo.new(u4, Enum.EasingStyle.Cubic), { ImageColor3 = u21 }):Play()
                _TweenService:Create(_TextLabel, TweenInfo.new(u4, Enum.EasingStyle.Cubic), { TextColor3 = u21 }):Play()
            end
        elseif not u6 then
            u6 = true
            local Result = u1:Prompt("You can't disable AutoPlay because AutoFarm is enabled.\nDisable AutoFarm?")
            u6 = false
            if Result == true then
                getgenv().FarmEnabled = false
                getgenv().PlayEnabled = false
                _TweenService:Create(_ImageLabel3, TweenInfo.new(u4, Enum.EasingStyle.Cubic), { ImageColor3 = u21 }):Play()
                _TweenService:Create(_ImageLabel, TweenInfo.new(u4, Enum.EasingStyle.Cubic), { ImageColor3 = u21 }):Play()
                _TweenService:Create(_TextLabel, TweenInfo.new(u4, Enum.EasingStyle.Cubic), { TextColor3 = u21 }):Play()
            end
        end
    else
        u15 = false
    end
end)

_TextButton2.MouseEnter:Connect(function()
    if not getgenv().FarmEnabled then
        _TweenService:Create(_ImageLabel3, TweenInfo.new(0.25, Enum.EasingStyle.Cubic), { ImageColor3 = Color3.fromRGB(0, 150, 255) }):Play()
    end
    u11 = true
end)
_TextButton2.MouseLeave:Connect(function()
    u16 = false
    local col = getgenv().FarmEnabled and u20 or u21
    _TweenService:Create(_ImageLabel3, TweenInfo.new(0.25, Enum.EasingStyle.Cubic), { ImageColor3 = col }):Play()
    u11 = false
end)
_TextButton2.MouseButton1Down:Connect(function()
    local u81 = true
    local u82 = false
    local u83 = _TextButton2.MouseLeave:Connect(function() u81 = false end)
    local u84 = _TextButton2.MouseButton1Up:Connect(function() u82 = true end)

    task.spawn(function()
        local v85 = 0
        repeat
            v85 = v85 + 1
            task.wait(0.1)
        until v85 == 9 or (u81 == false or u82 == true)

        if not (u81 == false or u82 == true) then
            u16 = true
            if not u6 then
                u6 = true
                u1:Info('AutoFarm', '[BETA]\nAutomatically play songs!\nForcefully enables AutoPlay.', nil, nil, true)
                u6 = false
            end
            u16 = false
        end
        u83:Disconnect()
        u84:Disconnect()
    end)
end)
_TextButton2.MouseButton1Click:Connect(function()
    if not u16 then
        if not getgenv().FarmEnabled or u3 ~= nil then
            if not getgenv().FarmEnabled and u3 == nil then
                getgenv().FarmEnabled = true
                if not getgenv().PlayEnabled then
                    getgenv().PlayEnabled = true
                    _TweenService:Create(_ImageLabel, TweenInfo.new(u4, Enum.EasingStyle.Cubic), { ImageColor3 = u20 }):Play()
                    _TweenService:Create(_TextLabel, TweenInfo.new(u4, Enum.EasingStyle.Cubic), { TextColor3 = u20 }):Play()
                end
                _TweenService:Create(_ImageLabel3, TweenInfo.new(u4, Enum.EasingStyle.Cubic), { ImageColor3 = u20 }):Play()
            end
        else
            getgenv().FarmEnabled = false
            if not u11 then
                _TweenService:Create(_ImageLabel3, TweenInfo.new(u4, Enum.EasingStyle.Cubic), { ImageColor3 = u21 }):Play()
            else
                _TweenService:Create(_ImageLabel3, TweenInfo.new(0.25, Enum.EasingStyle.Cubic), { ImageColor3 = Color3.fromRGB(0, 150, 255) }):Play()
            end
        end
    else
        u16 = false
    end
end)

_TextButton3.MouseEnter:Connect(function()
    _TweenService:Create(_ImageLabel5, TweenInfo.new(u4, Enum.EasingStyle.Cubic), { Rotation = -360, ImageColor3 = Color3.fromRGB(75, 215, 255) }):Play()
    u12 = true
end)
_TextButton3.MouseLeave:Connect(function()
    u17 = false
    _TweenService:Create(_ImageLabel5, TweenInfo.new(u4, Enum.EasingStyle.Cubic), { Rotation = 0, ImageColor3 = u21 }):Play()
    u12 = false
end)
_TextButton3.MouseButton1Down:Connect(function()
    local u91 = true
    local u92 = false
    local u93 = _TextButton3.MouseLeave:Connect(function() u91 = false end)
    local u94 = _TextButton3.MouseButton1Up:Connect(function() u92 = true end)

    task.spawn(function()
        local v95 = 0
        repeat
            v95 = v95 + 1
            task.wait(0.1)
        until v95 == 9 or (u91 == false or u92 == true)

        if not (u91 == false or u92 == true) then
            u17 = true
            if not u6 then
                u6 = true
                u1:Info('Respawn', 'Kills your character!\nUseful in games.', nil, nil, true)
                u6 = false
            end
            u17 = false
        end
        u93:Disconnect()
        u94:Disconnect()
    end)
end)
_TextButton3.MouseButton1Click:Connect(function()
    if not u17 then
        if u62.Character and u62.Character:FindFirstChild('Humanoid') then
            u62.Character.Humanoid.Health = 0
        end
    else
        u17 = false
    end
end)

_TextButton4.MouseEnter:Connect(function()
    _TweenService:Create(_ImageLabel7, TweenInfo.new(u4, Enum.EasingStyle.Cubic), { ImageColor3 = Color3.fromRGB(0, 255, 80) }):Play()
    u13 = true
end)
_TextButton4.MouseLeave:Connect(function()
    u18 = false
    _TweenService:Create(_ImageLabel7, TweenInfo.new(u4, Enum.EasingStyle.Cubic), { ImageColor3 = u21 }):Play()
    u13 = false
end)
_TextButton4.MouseButton1Click:Connect(function()
    if not u18 then
        if not u6 then
            u6 = true
            local NotificationResult = u1:Prompt('What would you like to do?', 'Rejoin', 'Serverhop')
            u6 = false
            if NotificationResult == false then
                u2()
            elseif NotificationResult == true then
                _TeleportService:Teleport(game.PlaceId, u62)
            end
        end
    else
        u18 = false
    end
end)

_TextButton5.MouseEnter:Connect(function()
    _TweenService:Create(_ImageLabel9, TweenInfo.new(u4, Enum.EasingStyle.Cubic), { ImageColor3 = Color3.fromRGB(255, 0, 0) }):Play()
    u14 = true
end)
_TextButton5.MouseLeave:Connect(function()
    u19 = false
    _TweenService:Create(_ImageLabel9, TweenInfo.new(u4, Enum.EasingStyle.Cubic), { ImageColor3 = u21 }):Play()
    u14 = false
end)
_TextButton5.MouseButton1Click:Connect(function()
    if not u19 then
        if not u6 then
            u6 = true
            local Result = u1:Prompt('Are you sure you want to delete the UI?')
            u6 = false
            if Result == true then
                _ScreenGui:Destroy()
                getgenv().PlayEnabled = nil
                getgenv().FarmEnabled = nil
            end
        end
    else
        u19 = false
    end
end)

-- 游戏内匹配判定绑定
if u62:FindFirstChild('CurrentMatch') then
    local currentPlayerData = u62:FindFirstChild('File') and u62.File:FindFirstChild('CurrentPlayer')
    if currentPlayerData and u62.PlayerGui:FindFirstChild('Main') then
        local matchFrame = u62.PlayerGui.Main:FindFirstChild('MatchFrame')
        if matchFrame then
            local v108 = matchFrame['KeySync' .. currentPlayerData.Value.Name:sub(7)]
            u7.Left = v108.Arrow1
            u7.Down = v108.Arrow2
            u7.Up = v108.Arrow3
            u7.Right = v108.Arrow4
        end
    end
end

local v111 = u62.ChildAdded:Connect(function(p109)
    if p109:IsA('BoolValue') and p109.Name == 'CurrentMatch' then
        local currentPlayerData = u62:FindFirstChild('File') and u62.File:FindFirstChild('CurrentPlayer')
        if currentPlayerData and u62.PlayerGui:FindFirstChild('Main') then
            local matchFrame = u62.PlayerGui.Main:FindFirstChild('MatchFrame')
            if matchFrame then
                local v110 = matchFrame['KeySync' .. currentPlayerData.Value.Name:sub(7)]
                u7.Left = v110.Arrow1
                u7.Down = v110.Arrow2
                u7.Up = v110.Arrow3
                u7.Right = v110.Arrow4
            end
        end
    end
end)
local v113 = u62.ChildRemoved:Connect(function(p112)
    if p112:IsA('BoolValue') and p112.Name == 'CurrentMatch' then
        u7.Left = nil
        u7.Down = nil
        u7.Up = nil
        u7.Right = nil
    end
end)

local function v127()
    local v114 = u65

    while task.wait() and (_ScreenGui.Parent and v114 == u65) do
        repeat
            task.wait()
        until u7.Right ~= nil and getgenv().PlayEnabled == true

        if v114 ~= u65 then break end

        local v115, v116, v117 = pairs(u9)

        while true do
            local u118
            v117, u118 = v115(v116, v117)
            if v117 == nil then break end

            task.spawn(function()
                if not u7[u118] or not u7[u118]:FindFirstChild('Notes') then return end
                local v119, v120, v121 = pairs(u7[u118].Notes:GetChildren())

                while true do
                    local u122
                    v121, u122 = v119(v120, v121)
                    if v121 == nil then break end

                    if u7[u118].AbsolutePosition.y + getgenv().Sensibility > u122.AbsolutePosition.y then
                        task.spawn(function()
                            if u8[u118] and Enum.KeyCode[u8[u118]] then
                                _VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[u8[u118]], false, game)
                            end

                            local v123, v124, v125 = pairs(u7[u118].Notes:GetChildren())
                            while true do
                                local v126
                                v125, v126 = v123(v124, v125)
                                if v125 == nil then break end
                                if v126:IsA('Frame') and v126.Name == u122.Name then
                                    u122 = v126
                                    break
                                end
                            end

                            repeat
                                task.wait()
                            until not u122 or u122:FindFirstChild('Hold') == nil or u7[u118].AbsolutePosition.Y > u122.Hold.End.AbsolutePosition.Y or not u62:FindFirstChild('CurrentMatch')

                            if u8[u118] and Enum.KeyCode[u8[u118]] then
                                _VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[u8[u118]], false, game)
                            end
                        end)
                    end
                end
            end)
        end
    end
end

if v5 == true then
    task.spawn(function()
        u1:Notify('Click the play button in the panel to toggle Auto Play!', 'Okay', nil, true)
        u1:Notify('Hold a button to see its description!', 'Okay', nil, true)
        writefile('BFNF-Waza80-ST', '')
    end)
end

-- 自动挂机 (AutoFarm) 核心循环
task.spawn(function()
    while task.wait() and _ScreenGui.Parent do
        if getgenv().FarmEnabled == true and u62:FindFirstChild('CurrentMatch') == nil then
            local closestP2 = GetClosestP2()
            if closestP2 and u62.Character and u62.Character:FindFirstChild('HumanoidRootPart') then
                if (closestP2.Position - u62.Character.HumanoidRootPart.Position).Magnitude <= 75 then
                    u62.Character.HumanoidRootPart.CFrame = closestP2.CFrame
                    task.wait()
                    if closestP2:FindFirstChild('ProximityPrompt') then
                        fireproximityprompt(closestP2.ProximityPrompt)
                    end
                    task.wait(0.5)
                else
                    u62.Character.HumanoidRootPart.CFrame = _TPPart.CFrame
                    task.wait()
                    if _TPPart:FindFirstChild('EnterTheater') then
                        fireproximityprompt(_TPPart.EnterTheater)
                    end
                    task.wait(0.5)
                end
                if _SongSelect.Visible == true then
                    game:GetService('ReplicatedStorage').Remotes.SongSelect:FireServer('Nothing')
                    repeat
                        task.wait()
                    until u62:FindFirstChild('CurrentMatch')

                    if u62.CurrentMatch.Value ~= true then
                        break
                    end
                end
            end
        end
    end
end)

while task.wait() and _ScreenGui.Parent do
    repeat
        task.wait()
    until u7.Right ~= nil and getgenv().PlayEnabled == true

    local v128 = task.spawn(v127)
    task.wait(15)
    task.cancel(v128)
end

v111:Disconnect()
v113:Disconnect()
