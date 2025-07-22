-- Enhanced Autofarm with GUI Controls + ESP + Anti-AFK
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local lplr = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("SummerHarvestRemoteEvent")

-- Default Settings
ggetgenv().AutoFarm = getgenv().AutoFarm or false
getgenv().TargetPlant = getgenv().TargetPlant or "Tomato"
getgenv().HarvestCooldown = getgenv().HarvestCooldown or 0.2
getgenv().IdleDelay = getgenv().IdleDelay or 25
getgenv().SubmitAfterCycles = getgenv().SubmitAfterCycles or 5

local function teleportTo(pos)
    if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
        lplr.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    end
end

local function getFarms()
    local farms = {}
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name == getgenv().TargetPlant and v:FindFirstChild("Fruit") then
            table.insert(farms, v)
        end
    end
    return farms
end

local function spamHarvest(farm)
    for _ = 1, 10 do
        remote:FireServer(farm)
        task.wait(getgenv().HarvestCooldown)
    end
end

local function submit()
    local btn = lplr.PlayerGui:FindFirstChild("UI"):FindFirstChild("Submit")
    if btn then
        fireclickdetector(btn.ClickDetector)
    end
end

local function antiAFK()
    while true do
        VirtualInputManager:SendKeyEvent(true, "W", false, nil)
        task.wait(2)
        VirtualInputManager:SendKeyEvent(false, "W", false, nil)
        task.wait(60)
    end
end

-- ESP
local function createESP(part)
    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = part
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Size = part.Size
    box.Transparency = 0.5
    box.Color3 = Color3.new(0, 1, 0)
    box.Parent = part
end

for _,farm in ipairs(getFarms()) do
    if farm:FindFirstChild("Fruit") then
        createESP(farm.Fruit)
    end
end

-- GUI Init
local ScreenGui = Instance.new("ScreenGui", lplr:WaitForChild("PlayerGui"))
ScreenGui.Name = "AutoFarmControl"

local frame = Instance.new("Frame", ScreenGui)
frame.Size = UDim2.new(0, 300, 0, 220)
frame.Position = UDim2.new(0, 20, 0, 40)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "AutoFarm Controller"
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundTransparency = 1

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Position = UDim2.new(0, 10, 0, 40)
toggleBtn.Size = UDim2.new(0, 120, 0, 30)
toggleBtn.Text = getgenv().AutoFarm and "Stop Farming" or "Start Farming"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)

local plantDropdown = Instance.new("TextButton", frame)
plantDropdown.Position = UDim2.new(0, 10, 0, 80)
plantDropdown.Size = UDim2.new(0, 120, 0, 30)
plantDropdown.Text = "Plant: " .. getgenv().TargetPlant
plantDropdown.BackgroundColor3 = Color3.fromRGB(70,70,70)
plantDropdown.TextColor3 = Color3.new(1,1,1)

local cooldownSlider = Instance.new("TextBox", frame)
cooldownSlider.Position = UDim2.new(0, 150, 0, 40)
cooldownSlider.Size = UDim2.new(0, 130, 0, 30)
cooldownSlider.Text = tostring(getgenv().HarvestCooldown)
cooldownSlider.TextColor3 = Color3.new(1,1,1)
cooldownSlider.BackgroundColor3 = Color3.fromRGB(70,70,70)
cooldownSlider.ClearTextOnFocus = true

local idleSlider = Instance.new("TextBox", frame)
idleSlider.Position = UDim2.new(0, 150, 0, 80)
idleSlider.Size = UDim2.new(0, 130, 0, 30)
idleSlider.Text = tostring(getgenv().IdleDelay)
idleSlider.TextColor3 = Color3.new(1,1,1)
idleSlider.BackgroundColor3 = Color3.fromRGB(70,70,70)
idleSlider.ClearTextOnFocus = true

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Position = UDim2.new(0, 10, 0, 120)
statusLabel.Size = UDim2.new(1, -20, 0, 80)
statusLabel.Text = "Status:\nCycles: 0"
statusLabel.TextSize = 16
statusLabel.TextColor3 = Color3.new(1,1,1)
statusLabel.BackgroundTransparency = 1
statusLabel.TextWrapped = true

local options = {"Tomato", "Pepper", "Berry"}
local menuFrame
plantDropdown.MouseButton1Click:Connect(function()
    if menuFrame then menuFrame:Destroy() end
    menuFrame = Instance.new("Frame", frame)
    menuFrame.Position = UDim2.new(0,10,0,110)
    menuFrame.Size = UDim2.new(0,120,0,#options*30)
    menuFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
    for i, opt in ipairs(options) do
        local btn = Instance.new("TextButton", menuFrame)
        btn.Position = UDim2.new(0,0,0,(i-1)*30)
        btn.Size = UDim2.new(1,0,0,30)
        btn.Text = opt
        btn.TextColor3 = Color3.new(1,1,1)
        btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        btn.MouseButton1Click:Connect(function()
            getgenv().TargetPlant = opt
            plantDropdown.Text = "Plant: "..opt
            menuFrame:Destroy()
        end)
    end
end)

toggleBtn.MouseButton1Click:Connect(function()
    getgenv().AutoFarm = not getgenv().AutoFarm
    toggleBtn.Text = getgenv().AutoFarm and "Stop Farming" or "Start Farming"
end)

cooldownSlider.FocusLost:Connect(function()
    local v = tonumber(cooldownSlider.Text)
    if v then getgenv().HarvestCooldown = v end
end)

idleSlider.FocusLost:Connect(function()
    local v = tonumber(idleSlider.Text)
    if v then getgenv().IdleDelay = v end
end)

-- Loop Farming
local cycle = 0
task.spawn(function()
    while true do
        if getgenv().AutoFarm then
            cycle += 1
            statusLabel.Text = ("Status:\nPlant: %s\nCycle: %d"):format(getgenv().TargetPlant, cycle)
            for _,farm in ipairs(getFarms()) do
                teleportTo(farm.PrimaryPart.Position)
                task.wait(0.5)
                spamHarvest(farm)
            end
            if getgenv().SubmitAfterCycles and cycle % getgenv().SubmitAfterCycles == 0 then
                submit()
            end
        end
        task.wait(getgenv().IdleDelay)
    end
end)

task.spawn(antiAFK)
