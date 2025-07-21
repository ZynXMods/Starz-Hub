-- AUTO-GENERATED SCRIPT EDITOR BY CHATGPT - RUN IN LOCALSCRIPT

-- Remote setup (jika belum ada)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
if not ReplicatedStorage:FindFirstChild("SaveScriptEvent") then
	local remoteSave = Instance.new("RemoteEvent", ReplicatedStorage)
	remoteSave.Name = "SaveScriptEvent"
end
if not ReplicatedStorage:FindFirstChild("LoadScriptEvent") then
	local remoteLoad = Instance.new("RemoteEvent", ReplicatedStorage)
	remoteLoad.Name = "LoadScriptEvent"
end

-- Client GUI Script
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local SaveEvent = ReplicatedStorage:WaitForChild("SaveScriptEvent")
local LoadEvent = ReplicatedStorage:WaitForChild("LoadScriptEvent")

-- Create GUI
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "ScriptEditor"

-- TextBox
local TextBox = Instance.new("TextBox", ScreenGui)
TextBox.Size = UDim2.new(0, 400, 0, 200)
TextBox.Position = UDim2.new(0.5, -200, 0.3, 0)
TextBox.Text = ""
TextBox.ClearTextOnFocus = false
TextBox.MultiLine = true
TextBox.TextWrapped = true
TextBox.TextXAlignment = Enum.TextXAlignment.Left
TextBox.TextYAlignment = Enum.TextYAlignment.Top
TextBox.Font = Enum.Font.Code
TextBox.TextSize = 18
TextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Run Button
local RunButton = Instance.new("TextButton", ScreenGui)
RunButton.Size = UDim2.new(0, 100, 0, 40)
RunButton.Position = UDim2.new(0.5, -110, 0.65, 0)
RunButton.Text = "Run"
RunButton.Font = Enum.Font.SourceSansBold
RunButton.TextSize = 22
RunButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
RunButton.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Save Button
local SaveButton = Instance.new("TextButton", ScreenGui)
SaveButton.Size = UDim2.new(0, 100, 0, 40)
SaveButton.Position = UDim2.new(0.5, 10, 0.65, 0)
SaveButton.Text = "Save"
SaveButton.Font = Enum.Font.SourceSansBold
SaveButton.TextSize = 22
SaveButton.BackgroundColor3 = Color3.fromRGB(0, 0, 170)
SaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Load from server
LoadEvent:FireServer()
LoadEvent.OnClientEvent:Connect(function(scriptText)
	TextBox.Text = scriptText
end)

-- Run code
RunButton.MouseButton1Click:Connect(function()
	local code = TextBox.Text
	local func, err = loadstring(code)
	if func then
		func()
	else
		warn("Gagal eksekusi: " .. err)
	end
end)

-- Save code
SaveButton.MouseButton1Click:Connect(function()
	local code = TextBox.Text
	SaveEvent:FireServer(code)
end)
