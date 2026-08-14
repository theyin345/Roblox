if game.PlaceId ~= 6520999642 then
    return warn('Please join "Basically FNF: Remix" to use this script!')
end

getgenv().PlayEnabled = getgenv().PlayEnabled or false
getgenv().FarmEnabled = getgenv().FarmEnabled or false
getgenv().Sensibility = getgenv().Sensibility or 2

local u1 = loadstring(game:HttpGet('https://raw.githubusercontent.com/Waza80/scripts/main/Notifications.lua'))()
local u2 = loadstring(game:HttpGet('https://raw.githubusercontent.com/Waza80/scripts/main/Teleporter.lua'))()
local u3 = nil
local u4 = 0.5
local v5 = nil
local u6 = false
local u10, u11, u12, u13, u14, u15, u16, u17, u18, u19 = false, false, false, false, false, false, false, false, false, false
local u20 = Color3.fromRGB(225, 225, 0)
local u21 = Color3.fromRGB(255, 255, 255)
local _LocalPlayer = game.Players.LocalPlayer
local v23 = ''
local _CoreGui = game:GetService('CoreGui')
local _HttpService = game:GetService('HttpService')
local _TweenService = game:GetService('TweenService')
local _TeleportService = game:GetService('TeleportService')
local _VirtualInputManager = game:GetService('VirtualInputManager')
local _RunService = game:GetService('RunService')
local _UserInputService = game:GetService('UserInputService')

-- ==================== 手机端适配：文字独立悬浮于 UI 正上方 ====================
local screenGuiName = "Waza80_BFNF_Mobile_UI"
if _CoreGui:FindFirstChild(screenGuiName) then
    _CoreGui[screenGuiName]:Destroy()
end

local _ScreenGui = Instance.new('ScreenGui')
_ScreenGui.Name = screenGuiName
_ScreenGui.ResetOnSpawn = false
_ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
_ScreenGui.Parent = _CoreGui

-- 主背景框（纯净容纳 5 个按钮）
local _MainFrame = Instance.new('Frame', _ScreenGui)
_MainFrame.Name = 'MainFrame'
_MainFrame.Size = UDim2.new(0, 215, 0, 44)
_MainFrame.Position = UDim2.new(0, 15, 0, 60) -- 整体往下，留出上方文字空间
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
_UIListLayout.Padding = UDim.new(0, 5)

-- 版本号文字（作为独立挂载在 ScreenGui 下的组件，利用绑定跟随主框或固定在上方）
-- 为了让它跟随拖拽，我们直接把它放进 _MainFrame 内部，但强制改变其 X 轴对齐和顶部偏移，确保不挤在左侧
-- 或者更完美的做法：让文字作为 MainFrame 的子代，但宽度设为100%，Position 设到上方外部：
local _TextLabel = Instance.new('TextLabel', _MainFrame)
_TextLabel.Name = 'Credits'
_TextLabel.Size = UDim2.new(1, 0, 0, 16)
_TextLabel.Position = UDim2.new(0, 0, 0, -20) -- 绝对定位在背景框正上方外部
_TextLabel.BackgroundTransparency = 1
_TextLabel.Text = v23
_TextLabel.TextSize = 11
_TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
_TextLabel.TextStrokeTransparency = 0.6
_TextLabel.TextXAlignment = Enum.TextXAlignment.Center -- 居中对齐
_TextLabel.FontFace = Font.new('rbxasset://fonts/families/FredokaOne.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)

-- ==================== 手机端全局拖拽支持 (Draggable) ====================
local dragging, dragInput, dragStart, startPos

_MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = _MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

_MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

_UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        _MainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

local function createButton(name, layoutOrder, iconId)
    local btn = Instance.new('TextButton', _MainFrame)
    btn.Name = name
    btn.Size = UDim2.new(0, 34, 0, 34)
    btn.Text = ''
    btn.LayoutOrder = layoutOrder
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.BorderSizePixel = 0
    
    local corner = Instance.new('UICorner', btn)
    corner.CornerRadius = UDim.new(0, 6)
    
    local icon = Instance.new('ImageLabel', btn)
    icon.Name = 'Icon'
    icon.Size = UDim2.new(0, 20, 0, 20)
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

local u66 = _HttpService:GenerateGUID(false)
_TextButton.ID.Value = u66

-- ==================== 基础辅助函数 ====================
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

local u62 = _LocalPlayer
if not isfile('BFNF-Waza80-ST') then
    v5 = true
end

repeat
    task.wait()
until game:GetService('Players').LocalPlayer.PlayerGui.Main.Loading.Visible == false

local _TPPart = workspace.Interactables.TPPart
local _SongSelect = u62.PlayerGui.Main.SongSelect

-- ==================== 键位配置 ====================
local Config = {
    KeyBinds = {
        [1] = Enum.KeyCode.A, 
        [2] = Enum.KeyCode.S, 
        [3] = Enum.KeyCode.W, 
        [4] = Enum.KeyCode.D
    },
}

task.spawn(function()
    pcall(function()
        local settingsMenu = u62.PlayerGui.Main.MainFrame.Menu.Settings.Controls
        Config.KeyBinds[1] = Enum.KeyCode[settingsMenu.KeyL.Input.Text] or Enum.KeyCode.A
        Config.KeyBinds[2] = Enum.KeyCode[settingsMenu.KeyD.Input.Text] or Enum.KeyCode.S
        Config.KeyBinds[3] = Enum.KeyCode[settingsMenu.KeyU.Input.Text] or Enum.KeyCode.W
        Config.KeyBinds[4] = Enum.KeyCode[settingsMenu.KeyR.Input.Text] or Enum.KeyCode.D
    end)
end)

if getgenv().PlayEnabled ~= true then
    _ImageLabel.ImageColor3 = u21
else
    _ImageLabel.ImageColor3 = u20
end
if getgenv().FarmEnabled ~= true then
    _ImageLabel3.ImageColor3 = u21
else
    _ImageLabel3.ImageColor3 = u20
end

-- ==================== 按钮交互逻辑 ====================
_TextButton.MouseEnter:Connect(function()
    _TweenService:Create(_ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Cubic), { Size = UDim2.new(0, 22, 0, 22) }):Play()
    u10 = true
end)
_TextButton.MouseLeave:Connect(function()
    u15 = false
    _TweenService:Create(_ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Cubic), { Size = UDim2.new(0, 20, 0, 20) }):Play()
    u10 = false
end)
_TextButton.MouseButton1Down:Connect(function()
    _TweenService:Create(_ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Cubic), { Size = UDim2.new(0, 18, 0, 18) }):Play()
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
    local targetSize = u10 and UDim2.new(0, 22, 0, 22) or UDim2.new(0, 20, 0, 20)
    _TweenService:Create(_ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Cubic), { Size = targetSize }):Play()
end)
_TextButton.MouseButton1Click:Connect(function()
    if not u15 then
        if not getgenv().FarmEnabled then
            if not getgenv().PlayEnabled or u3 ~= nil then
                if not getgenv().PlayEnabled and u3 == nil then
                    getgenv().PlayEnabled = true
                    _TweenService:Create(_ImageLabel, TweenInfo.new(u4, Enum.EasingStyle.Cubic), { ImageColor3 = u20 }):Play()
                end
            else
                getgenv().PlayEnabled = false
                _TweenService:Create(_ImageLabel, TweenInfo.new(u4, Enum.EasingStyle.Cubic), { ImageColor3 = u21 }):Play()
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

-- ==================== 核心打谱与动态长按判定逻辑 ====================
local FNFState = {
    ProcessedNotes = {},  
    ActiveKeys = {},      
    MainLoop = nil
}

local function releaseAllKeys()
    for arrowIdx, isPressed in pairs(FNFState.ActiveKeys) do
        if isPressed then
            _VirtualInputManager:SendKeyEvent(false, Config.KeyBinds[arrowIdx], false, game)
            FNFState.ActiveKeys[arrowIdx] = false
        end
    end
end

local function getActiveKeySync()
    local mainGui = u62.PlayerGui:FindFirstChild("Main")
    if not mainGui then return nil end
    
    local matchFrame = mainGui:FindFirstChild("MatchFrame")
    if not (matchFrame and matchFrame.Visible) then return nil end
    
    local playerSide = "KeySync1"
    local file = u62:FindFirstChild("File")
    if file and file:FindFirstChild("CurrentPlayer") then
        if file.CurrentPlayer.Value and file.CurrentPlayer.Value.Name == "Player2" then
            playerSide = "KeySync2"
        end
    end
    
    return matchFrame:FindFirstChild(playerSide)
end

local function processHit(arrowIdx, note, folder, receptor)
    if FNFState.ActiveKeys[arrowIdx] then return end 
    FNFState.ActiveKeys[arrowIdx] = true
    
    task.spawn(function()
        local key = Config.KeyBinds[arrowIdx]
        
        _VirtualInputManager:SendKeyEvent(true, key, false, game)
        
        local notesFolder = folder:FindFirstChild("Notes")
        local activeHold = nil
        
        if notesFolder then
            activeHold = notesFolder:FindFirstChild("Hold_" .. tostring(note.Name))
            if not activeHold then
                for _, child in ipairs(notesFolder:GetChildren()) do
                    local lowerName = string.lower(child.Name)
                    if string.find(lowerName, "hold") or string.find(lowerName, "tail") or string.find(lowerName, "sust") then
                        activeHold = child
                        break
                    end
                end
            end
        end
        
        if activeHold and receptor then
            local maxSafetyTimeout = tick() + 15 
            while activeHold and activeHold.Parent and activeHold.Visible do
                _RunService.Heartbeat:Wait()
                if tick() > maxSafetyTimeout then break end
                
                local targetY = receptor.AbsolutePosition.Y
                local holdY = activeHold.AbsolutePosition.Y
                local holdHeight = activeHold.AbsoluteSize.Y
                local holdBottomY = holdY + holdHeight
                
                if holdBottomY <= targetY + 5 or holdHeight < 5 then
                    break
                end
            end
        else
            task.wait(0.035)
        end

        _VirtualInputManager:SendKeyEvent(false, key, false, game)
        FNFState.ActiveKeys[arrowIdx] = false
    end)
end

local function engageAutoPlayer()
    if FNFState.MainLoop then FNFState.MainLoop:Disconnect() end
    releaseAllKeys()
    
    FNFState.MainLoop = _RunService.Heartbeat:Connect(function()
        if not getgenv().PlayEnabled then return end
        
        local KeySync = getActiveKeySync()
        if not KeySync then return end
        
        for i = 1, 4 do
            local folder = KeySync:FindFirstChild("Arrow" .. i)
            local receptor = folder and folder:FindFirstChild("Arrow")
            local notes = folder and folder:FindFirstChild("Notes")
            
            if receptor and notes then
                local targetY = receptor.AbsolutePosition.Y
                
                for _, note in ipairs(notes:GetChildren()) do
                    if FNFState.ProcessedNotes[note] or not note:IsA("GuiObject") or not note.Visible or note.Name == "Arrow" or string.find(string.lower(note.Name), "hold") then 
                        continue 
                    end
                    
                    local noteY = note.AbsolutePosition.Y
                    
                    if noteY <= targetY then
                        FNFState.ProcessedNotes[note] = true 
                        
                        processHit(i, note, folder, receptor)
                        
                        note.AncestryChanged:Once(function() 
                            FNFState.ProcessedNotes[note] = nil 
                        end)
                        
                        break 
                    end
                end
            end
        end
    end)
end

task.spawn(function()
    local lastState = false
    while task.wait(0.1) do
        local currentState = getgenv().PlayEnabled
        if currentState ~= lastState then
            lastState = currentState
            if currentState then
                engageAutoPlayer()
            else
                if FNFState.MainLoop then FNFState.MainLoop:Disconnect() end
                releaseAllKeys()
            end
        end
    end
end)

if v5 == true then
    task.spawn(function()
        u1:Notify('Click the play button in the panel to toggle Auto Play!', 'Okay', nil, true)
        u1:Notify('Hold a button to see its description!', 'Okay', nil, true)
        writefile('BFNF-Waza80-ST', '')
    end)
end

-- ==================== 自动挂机 (AutoFarm) 核心循环 ====================
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
