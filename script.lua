-- XÓA GUI CŨ
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("DeltaFling") then
    playerGui.DeltaFling:Destroy()
end

-- GUI
local ScreenGui = Instance.new("ScreenGui", playerGui)
ScreenGui.Name = "DeltaFling"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0,240,0,210)
Main.Position = UDim2.new(0.3,0,0.2,0)
Main.BackgroundColor3 = Color3.fromRGB(30,30,35)
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,35)
Title.Text = "FLING PRO"
Title.BackgroundColor3 = Color3.fromRGB(45,45,50)
Title.TextColor3 = Color3.new(1,1,1)

local Status = Instance.new("TextLabel", Main)
Status.Position = UDim2.new(0.05,0,0.22,0)
Status.Size = UDim2.new(0.9,0,0,20)
Status.Text = "Target: NONE"
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.new(1,1,1)

local Input = Instance.new("TextBox", Main)
Input.Position = UDim2.new(0.05,0,0.35,0)
Input.Size = UDim2.new(0.9,0,0,30)
Input.PlaceholderText = "Nhap ten (bo trong = gan nhat)"
Input.Text = ""
Input.BackgroundColor3 = Color3.fromRGB(55,55,60)
Input.TextColor3 = Color3.new(1,1,1)

local TpBtn = Instance.new("TextButton", Main)
TpBtn.Position = UDim2.new(0.05,0,0.55,0)
TpBtn.Size = UDim2.new(0.9,0,0,30)
TpBtn.Text = "TELEPORT"
TpBtn.BackgroundColor3 = Color3.fromRGB(80,170,255)
TpBtn.TextColor3 = Color3.new(1,1,1)

local Btn = Instance.new("TextButton", Main)
Btn.Position = UDim2.new(0.05,0,0.75,0)
Btn.Size = UDim2.new(0.9,0,0,40)
Btn.Text = "FLING: OFF"
Btn.BackgroundColor3 = Color3.fromRGB(200,50,50)
Btn.TextColor3 = Color3.new(1,1,1)

-- DRAG GUI (FIX CHUẨN)
local UIS = game:GetService("UserInputService")

local dragging = false
local dragInput
local dragStart
local startPos

Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 
    or input.UserInputType == Enum.UserInputType.Touch then
        
        dragging = true
        dragStart = input.Position
        startPos = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement 
    or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- LOGIC
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local active = false
local loop

-- tìm target
local function getTarget()
    local text = Input.Text:lower()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

    local closest, dist = nil, math.huge

    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            
            if text ~= "" then
                if p.Name:lower():sub(1,#text) == text then
                    return p
                end
            else
                if myRoot then
                    local d = (p.Character.HumanoidRootPart.Position - myRoot.Position).Magnitude
                    if d < dist then
                        dist = d
                        closest = p
                    end
                end
            end
        end
    end

    return closest
end

-- TELEPORT
TpBtn.MouseButton1Click:Connect(function()
    local target = getTarget()
    if not target then return end

    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local tRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")

    if root and tRoot then
        root.CFrame = tRoot.CFrame * CFrame.new(0,0,3)
    end
end)

-- FLING
Btn.MouseButton1Click:Connect(function()
    active = not active

    if active then
        Btn.Text = "FLING: ON"
        Btn.BackgroundColor3 = Color3.fromRGB(50,200,50)

        loop = RunService.Heartbeat:Connect(function()
            local target = getTarget()
            if not target then return end

            Status.Text = "Target: "..target.Name

            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            local tChar = target.Character
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")

            -- target chết → mình reset theo
            if tHum and tHum.Health <= 0 then
                if hum then hum.Health = 0 end
                return
            end

            if root and hum and tRoot then
                hum:ChangeState(Enum.HumanoidStateType.Physics)

                local bv = Instance.new("BodyVelocity")
                bv.Velocity = Vector3.new(9999,9999,9999)
                bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
                bv.Parent = root

                local bav = root:FindFirstChild("Spin") or Instance.new("BodyAngularVelocity")
                bav.Name = "Spin"
                bav.AngularVelocity = Vector3.new(0,99999,0)
                bav.MaxTorque = Vector3.new(0,math.huge,0)
                bav.Parent = root

                root.CFrame = tRoot.CFrame * CFrame.new(0,0,0.2)

                game:GetService("Debris"):AddItem(bv,0.1)
            end
        end)

    else
        Btn.Text = "FLING: OFF"
        Btn.BackgroundColor3 = Color3.fromRGB(200,50,50)

        if loop then loop:Disconnect() end

        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end
end)
