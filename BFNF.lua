local v0 = game:GetService("RunService");
local v1 = game:GetService("VirtualInputManager");
local v2 = game:GetService("Players");
local v3 = game:GetService("TweenService");

local v4 = {
    KeyBinds = {[1] = Enum.KeyCode.A, [2] = Enum.KeyCode.S, [3] = Enum.KeyCode.W, [4] = Enum.KeyCode.D},
    HitPixels = 15, 
    TapDuration = 0.03, -- 单点瞬时释放延迟
};

local v5 = v2.LocalPlayer;
local v6 = {}; 
local v8 = false;
local v_minimized = false;
local mainLoop = nil;

-- GUI SETUP
local v9 = Instance.new("ScreenGui", v5:WaitForChild("PlayerGui"));
v9.Name = "AutoPlayer_Orbit_V5";
v9.ResetOnSpawn = false;

local v15 = Instance.new("Frame", v9);
v15.Size = UDim2.new(0, 200, 0, 120);
v15.Position = UDim2.new(0.5, -100, 0.5, -60);
v15.BackgroundColor3 = Color3.fromRGB(35, 35, 35);
v15.BorderSizePixel = 0;
v15.Active = true;
v15.Draggable = true;
v15.ClipsDescendants = true;

local TopBar = Instance.new("Frame", v15);
TopBar.Size = UDim2.new(1, 0, 0, 30);
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25);
TopBar.BorderSizePixel = 0;

local Title = Instance.new("TextLabel", TopBar);
Title.Size = UDim2.new(1, -70, 1, 0);
Title.Position = UDim2.new(0, 10, 0, 0);
Title.BackgroundTransparency = 1;
Title.Text = "AutoPlayer (Stable)";
Title.TextColor3 = Color3.new(1, 1, 1);
Title.Font = Enum.Font.GothamBold;
Title.TextSize = 14;
Title.TextXAlignment = Enum.TextXAlignment.Left;

-- BUTTONS
local CloseBtn = Instance.new("TextButton", TopBar);
CloseBtn.Size = UDim2.new(0, 30, 0, 30);
CloseBtn.Position = UDim2.new(1, -30, 0, 0);
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50);
CloseBtn.BorderSizePixel = 0;
CloseBtn.Text = "X";
CloseBtn.TextColor3 = Color3.new(1, 1, 1);

local MinBtn = Instance.new("TextButton", TopBar);
MinBtn.Size = UDim2.new(0, 30, 0, 30);
MinBtn.Position = UDim2.new(1, -60, 0, 0);
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60);
MinBtn.BorderSizePixel = 0;
MinBtn.Text = "-";
MinBtn.TextColor3 = Color3.new(1, 1, 1);
MinBtn.TextSize = 18;

local v36 = Instance.new("TextButton", v15);
v36.Size = UDim2.new(0.85, 0, 0, 50);
v36.Position = UDim2.new(0.075, 0, 0.45, 0);
v36.BackgroundColor3 = Color3.fromRGB(50, 50, 50);
v36.Text = "OFF";
v36.TextColor3 = Color3.new(1, 1, 1);
v36.Font = Enum.Font.GothamBold;
v36.TextSize = 22;

local function getMyKeySync()
    local Match = v5.PlayerGui:FindFirstChild("Main") and v5.PlayerGui.Main:FindFirstChild("MatchFrame")
    if not (Match and Match.Visible) then return nil end
    local playerVal = v5:FindFirstChild("File") and v5.File:FindFirstChild("CurrentPlayer")
    if playerVal and playerVal.Value then
        local side = (playerVal.Value.Name == "Player2") and "KeySync2" or "KeySync1"
        return Match:FindFirstChild(side)
    end
    return nil
end

local function startLoop()
    if mainLoop then mainLoop:Disconnect() end
    mainLoop = v0.Heartbeat:Connect(function()
        if not v8 then return end
        local KeySync = getMyKeySync()
        if not (KeySync and KeySync.Visible) then return end
        
        for i = 1, 4 do
            local folder = KeySync:FindFirstChild("Arrow"..i)
            local receptor = folder and folder:FindFirstChild("Arrow")
            local notes = folder and folder:FindFirstChild("Notes")
            
            if receptor and notes then
                local targetY = receptor.AbsolutePosition.Y
                for _, note in pairs(notes:GetChildren()) do
                    if not note:IsA("GuiObject") or not note.Visible or note.Name == "Arrow" or v6[note] then continue end
                    
                    local distance = note.AbsolutePosition.Y - targetY
                    
                    if math.abs(distance) <= v4.HitPixels then
                        v6[note] = true 
                        
                        -- 检测长条组件（检查是否有 Tail、HoldBody 或高度明显大于普通单点）
                        local tail = note:FindFirstChild("Tail") or note:FindFirstChild("HoldBody") or note:FindFirstChild("LongNote")
                        local isHold = tail ~= nil or (note.AbsoluteSize.Y > 45)
                        local key = v4.KeyBinds[i]
                        
                        if not isHold then
                            -- 【单点打击】瞬时按下并在极短时间后松开
                            task.spawn(function()
                                v1:SendKeyEvent(true, key, false, game)
                                task.wait(v4.TapDuration)
                                v1:SendKeyEvent(false, key, false, game)
                            end)
                            note.AncestryChanged:Once(function() v6[note] = nil end)
                        else
                            -- 【长条稳定打击】根据长条的实际像素高度计算精准按压时间
                            -- 提取长条总长度（优先取 Tail 高度，其次取整体高度减去偏移）
                            local bodySize = tail and tail.AbsoluteSize.Y or note.AbsoluteSize.Y
                            -- 速度换算系数：可根据游戏下落速度微调分母（当前 180~200 适配常规下落速度）
                            local holdDuration = math.max(0.1, bodySize / 190)
                            
                            task.spawn(function()
                                v1:SendKeyEvent(true, key, false, game)
                                task.wait(holdDuration)
                                v1:SendKeyEvent(false, key, false, game)
                                v6[note] = nil
                            end)
                        end
                    end
                end
            end
        end
    end)
end

-- BUTTON EVENTS
v36.MouseButton1Click:Connect(function()
    v8 = not v8
    v36.Text = v8 and "ON" or "OFF"
    v3:Create(v36, TweenInfo.new(0.2), {BackgroundColor3 = v8 and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(50, 50, 50)}):Play()
    if v8 then startLoop() else if mainLoop then mainLoop:Disconnect() end end
end)

MinBtn.MouseButton1Click:Connect(function()
    v_minimized = not v_minimized
    MinBtn.Text = v_minimized and "+" or "-"
    local targetSize = v_minimized and UDim2.new(0, 200, 0, 30) or UDim2.new(0, 200, 0, 120)
    v15:TweenSize(targetSize, "Out", "Quad", 0.25, true)
    v36.Visible = not v_minimized
end)

CloseBtn.MouseButton1Click:Connect(function()
    v8 = false; if mainLoop then mainLoop:Disconnect() end; v9:Destroy()
end)
