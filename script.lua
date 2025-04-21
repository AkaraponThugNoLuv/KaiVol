wait(10)
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Knit = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit
local GameService = Knit.Services.GameService

-- เข้าร่วมทีมแบบสุ่ม
local function joinRandomTeam()
    local teamNumber = math.random(1, 2)
    local slotNumber = math.random(1, 6)
    GameService.RF.RequestJoin:InvokeServer(teamNumber, slotNumber)
    print("Joined team:", teamNumber, "Slot:", slotNumber)
end

-- คำสั่งกด Space
local function pressSpace()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
end

-- คำสั่งคลิก
local function pressClick()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
end

-- หาลูกบอลชื่อ CLIENT_BALL_
local function getBall()
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name:find("CLIENT_BALL_") then
            return obj:FindFirstChild("Sphere.001") or obj:FindFirstChild("Cube.001")
        end
    end
    return nil
end

-- เดินไปหาลูกบอลและตี
local function faceAndHit(ballPart)
    local distance = (humanoidRootPart.Position - ballPart.Position).Magnitude
    if distance > 2 then
        humanoid:MoveTo(ballPart.Position)
    end

    if distance <= 15 then
        local lookVector = (ballPart.Position - humanoidRootPart.Position).Unit
        humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + lookVector)
        pressSpace()
        task.wait(0.1)
        pressClick()
    end
end

-- ตรวจสอบว่าเป็นผู้เสิร์ฟหรือไม่ และ Auto เสิร์ฟ
local function autoServe()
    local status = player.PlayerGui:FindFirstChild("Interface")
    if status and status:FindFirstChild("ServeStatus") and status.ServeStatus.Visible then
        -- ถ้าแสดง UI เสิร์ฟ แปลว่าเป็นคนเสิร์ฟ
        GameService.RF.Serve:InvokeServer(Vector3.new(0, 0, 0), math.huge)
        print("Auto Serve Executed!")
    end
end

-- ลูปหลัก AutoFarm + AutoServe + เข้าร่วมทีม
task.spawn(function()
    -- เข้าร่วมทีมแค่รอบแรก
    joinRandomTeam()

    -- ลูปหลัก
    while true do
        -- ทำงานการเสิร์ฟอัตโนมัติ
        autoServe()

        -- หาลูกบอลและตี
        local ball = getBall()
        if ball then
            -- ลูปสำหรับการตีลูกบอล
            for i = 1, 3 do
                faceAndHit(ball)
                task.wait(0.05) -- รอเล็กน้อยระหว่างการตี
            end
        end

        -- รอ 0.1 วินาทีเพื่อให้เกมทำงานได้
        task.wait(0.1)
    end
end)

-- ลูปสุ่มเข้าทีมใหม่ทุก 30 วินาที
task.spawn(function()
    while true do
        task.wait(300)
        joinRandomTeam()  -- เข้าร่วมทีมใหม่ทุก 30 วินาที
    end
end)




local player = game:GetService("Players").LocalPlayer
local coreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")


--
workspace:FindFirstChildOfClass('Terrain').WaterWaveSize = 0
workspace:FindFirstChildOfClass('Terrain').WaterWaveSpeed = 0
workspace:FindFirstChildOfClass('Terrain').WaterReflectance = 0
workspace:FindFirstChildOfClass('Terrain').WaterTransparency = 0
game:GetService("Lighting").GlobalShadows = false
game:GetService("Lighting").FogEnd = 9e9
settings().Rendering.QualityLevel = 1
for i,v in pairs(game:GetDescendants()) do
    if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
        v.Material = "Plastic"
        v.Reflectance = 0
    elseif v:IsA("Decal") then
        v.Transparency = 1
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
        v.Lifetime = NumberRange.new(0)
    elseif v:IsA("Explosion") then
        v.BlastPressure = 1
        v.BlastRadius = 1
    end
end
for i,v in pairs(game:GetService("Lighting"):GetDescendants()) do
    if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
        v.Enabled = false
    end
end
-- สร้าง ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "RewardViewerGui"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent = gethui and gethui() or (syn and syn.protect_gui and syn.protect_gui(gui) or coreGui)

-- พื้นหลังดำเต็มจอ
local blackout = Instance.new("Frame")
blackout.Name = "Blackout"
blackout.BackgroundColor3 = Color3.new(0, 0, 0)
blackout.BackgroundTransparency = 0
blackout.BorderSizePixel = 0
blackout.Size = UDim2.new(1, 0, 1, 0)
blackout.Position = UDim2.new(0, 0, 0, 0)
blackout.ZIndex = 9999
blackout.Active = true
blackout.Selectable = true
blackout.Parent = gui

-- ปุ่ม Toggle UI
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 100, 0, 40)
toggleButton.Position = UDim2.new(1, -110, 0, 10)
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleButton.Text = "Toggle"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 18
toggleButton.ZIndex = 10001
toggleButton.Parent = gui

-- ตั้งค่า FPS ทันทีเมื่อเริ่มต้น
setfpscap(5)

-- Toggle UI และเปลี่ยน FPS
local visible = true
toggleButton.MouseButton1Click:Connect(function()
    visible = not visible
    blackout.Visible = visible

    if visible then
        setfpscap(5)
    else
        setfpscap(30)
    end
end)

-- หัวข้อ GUYITEMS
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Text = "GUYITEMS"
title.Font = Enum.Font.GothamBold
title.TextSize = 50
title.BackgroundTransparency = 1
title.AnchorPoint = Vector2.new(0.5, 0)
title.Position = UDim2.new(0.5, 0, 0.1, 0)
title.Size = UDim2.new(0.6, 0, 0, 40)
title.TextXAlignment = Enum.TextXAlignment.Center
title.TextYAlignment = Enum.TextYAlignment.Center
title.ZIndex = 10001
title.Parent = blackout

-- RGB คลื่น
local RunService = game:GetService("RunService")
spawn(function()
	local t = 0
	while true do
		t += 0.03
		local r = math.sin(t) * 127 + 128
		local g = math.sin(t + 2) * 127 + 128
		local b = math.sin(t + 4) * 127 + 128
		title.TextColor3 = Color3.fromRGB(r, g, b)
		RunService.RenderStepped:Wait()
	end
end)

-- ชื่อตัวละครใต้ GUYITEMS
local playerNameLabel = Instance.new("TextLabel")
playerNameLabel.Name = "PlayerName"
playerNameLabel.Text = player.Name
playerNameLabel.Font = Enum.Font.GothamBold
playerNameLabel.TextSize = 30
playerNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
playerNameLabel.BackgroundTransparency = 1
playerNameLabel.AnchorPoint = Vector2.new(0.5, 0)
playerNameLabel.Position = UDim2.new(0.5, 0, 0.155, 0) -- ย้ายขึ้นสูงๆหน่อย
playerNameLabel.Size = UDim2.new(0.6, 0, 0, 30)
playerNameLabel.TextXAlignment = Enum.TextXAlignment.Center
playerNameLabel.TextYAlignment = Enum.TextYAlignment.Center
playerNameLabel.ZIndex = 10001
playerNameLabel.Parent = blackout

-- เพิ่มข้อมูล Level
local levelLabel = Instance.new("TextLabel")
levelLabel.Name = "LevelLabel"
levelLabel.Text = "Level: " .. game:GetService("Players").LocalPlayer.PlayerGui.Interface.Stats.LeftSidePanel.PlayerLevelButton.Amount.Text
levelLabel.Font = Enum.Font.GothamBold
levelLabel.TextSize = 30
levelLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
levelLabel.BackgroundTransparency = 1
levelLabel.AnchorPoint = Vector2.new(0.5, 0)
levelLabel.Position = UDim2.new(0.5, 0, 0.2, 0) -- ปรับตำแหน่ง
levelLabel.Size = UDim2.new(0.6, 0, 0, 30)
levelLabel.TextXAlignment = Enum.TextXAlignment.Center
levelLabel.TextYAlignment = Enum.TextYAlignment.Center
levelLabel.ZIndex = 10001
levelLabel.Parent = blackout

-- เพิ่มข้อมูล Yen
local yenLabel = Instance.new("TextLabel")
yenLabel.Name = "YenLabel"
yenLabel.Text = "Yen: " .. game:GetService("Players").LocalPlayer.PlayerGui.Interface.Stats.LeftSidePanel.YenAmountButton.Amount.Text
yenLabel.Font = Enum.Font.GothamBold
yenLabel.TextSize = 30
yenLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
yenLabel.BackgroundTransparency = 1
yenLabel.AnchorPoint = Vector2.new(0.5, 0)
yenLabel.Position = UDim2.new(0.5, 0, 0.25, 0) -- ปรับตำแหน่ง
yenLabel.Size = UDim2.new(0.6, 0, 0, 30)
yenLabel.TextXAlignment = Enum.TextXAlignment.Center
yenLabel.TextYAlignment = Enum.TextYAlignment.Center
yenLabel.ZIndex = 10001
yenLabel.Parent = blackout

-- อัพเดตข้อมูล Level และ Yen เมื่อค่าตัวเลขเปลี่ยน
game:GetService("Players").LocalPlayer.PlayerGui.Interface.Stats.LeftSidePanel.PlayerLevelButton.Amount:GetPropertyChangedSignal("Text"):Connect(function()
    levelLabel.Text = "Level: " .. game:GetService("Players").LocalPlayer.PlayerGui.Interface.Stats.LeftSidePanel.PlayerLevelButton.Amount.Text
end)

game:GetService("Players").LocalPlayer.PlayerGui.Interface.Stats.LeftSidePanel.YenAmountButton.Amount:GetPropertyChangedSignal("Text"):Connect(function()
    yenLabel.Text = "Yen: " .. game:GetService("Players").LocalPlayer.PlayerGui.Interface.Stats.LeftSidePanel.YenAmountButton.Amount.Text
end)




local RAMAccount, SettingAcc = loadstring(game:HttpGet('https://raw.githubusercontent.com/ic3w0lf22/Roblox-Account-Manager/master/RAMAccount.lua'))()

local player = game:GetService("Players").LocalPlayer
local MyAccount = RAMAccount.new(player.Name)

AutoSetDescription = true

spawn(function()
	while wait() do 
		if AutoSetDescription then
			xpcall(function()
				local levelText, yenText

				local success, err = pcall(function()
					local statsPanel = player:WaitForChild("PlayerGui"):WaitForChild("Interface")
						:WaitForChild("Stats"):WaitForChild("LeftSidePanel")

					levelText = statsPanel:WaitForChild("PlayerLevelButton"):WaitForChild("Amount").Text
					yenText = statsPanel:WaitForChild("YenAmountButton"):WaitForChild("Amount").Text
				end)

				if not success then return end

				local description = string.format("Level: %s | Yen: %s", levelText, yenText)

				MyAccount = RAMAccount.new(player.Name)
				if MyAccount then
					local CheckDone = MyAccount:SetDescription(description)
					if CheckDone ~= false then
						print("SET")
					else
						messagebox("You Not Open Allow Modify Methods", "Alert", 0)
						ChangeToggle(ATSDES, false)
					end
				else
					messagebox("Can't Connect To RAM", "Alert", 0)
					ChangeToggle(ATSDES, false)
				end
			end, print)
		else
			break
		end
		wait(3) -- ตรวจทุก 3 วิ
	end
end)

-- ฟังก์ชันที่ใช้ค้นหาเซิร์ฟเวอร์ที่มีผู้เล่นน้อย
local function hopToServerWithFewPlayers()
    -- ฟังก์ชันที่เช็คจำนวนผู้เล่นในเซิร์ฟเวอร์
    local function checkPlayerCount()
        local players = game:GetService("Players")
        return #players:GetPlayers() -- คืนค่าจำนวนผู้เล่นทั้งหมดในเซิร์ฟเวอร์
    end

    -- เริ่มการ loop เพื่อตรวจสอบเซิร์ฟเวอร์
    while true do
        -- ถ้าจำนวนผู้เล่นในเซิร์ฟเวอร์ปัจจุบันน้อยกว่า 4 คน
        if checkPlayerCount() < 4 then
            print("Player count is less than 4, hopping to another server...")
            
            -- ใช้ TeleportService เพื่อย้ายไปเซิร์ฟเวอร์ใหม่
            local TeleportService = game:GetService("TeleportService")
            local placeId = game.PlaceId
            local jobId = game.JobId
            
            -- ใช้คำสั่งนี้เพื่อย้ายไปยังเซิร์ฟเวอร์ใหม่
            TeleportService:TeleportToPlaceInstance(placeId, jobId)
            return -- หยุดการ loop เมื่อย้ายไปเซิร์ฟเวอร์ใหม่แล้ว
        else
            print("Player count in this server is more than 4... Trying again.")
        end

        -- รอ 30 วินาทีแล้วลองใหม่ (คุณสามารถปรับเวลาได้ตามต้องการ)
        wait(30)
    end
end

-- เรียกใช้งานฟังก์ชัน
hopToServerWithFewPlayers()



task.delay(3600, function()
    game:GetService("Players").LocalPlayer:Kick("Kicked after min.")
end)
