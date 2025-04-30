wait(10)
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Knit = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit
local GameService = Knit.Services.GameService

-- Declare the player
local enablejoin = true -- ตั้งค่าเป็น true ทันที

-- Function to handle team selection (called after the reset)
local function teamSelection()
    if not enablejoin then return end

    task.wait(10)

    -- Check if Team Selection GUI exists and can be accessed
    local teamSelectionGui = player.PlayerGui.Interface.TeamSelection
    local gameInterface = player.PlayerGui.Interface.Game

    -- Only make the team selection GUI visible if the game interface is not yet visible
    if not gameInterface.Visible then
        teamSelectionGui.Visible = true
    end

    while not gameInterface.Visible and enablejoin do
        -- Select a random number between 1 and 6
        local randomNum = math.random(1, 6)
        --local button = teamSelectionGui["2"][tostring(randomNum)]
        local button = teamSelectionGui[tostring(math.random(1, 2))][tostring(randomNum)]
        if button and button:IsA("ImageButton") then
            local absPos = button.AbsolutePosition
            local absSize = button.AbsoluteSize
            local clickPosition = absPos + (absSize / 2) -- Center of the button

            -- Simulate mouse button down
            VirtualInputManager:SendMouseButtonEvent(clickPosition.X, clickPosition.Y, 0, true, game, 1)
            -- Simulate mouse button up
            VirtualInputManager:SendMouseButtonEvent(clickPosition.X, clickPosition.Y, 0, false, game, 1)
        end

        -- Add a random delay between clicks to simulate human-like behavior
        task.wait(math.random(5, 15) / 10) -- Delay between 0.5 and 1.5 seconds
    end

    -- Hide the team selection GUI when the game GUI becomes visible
    if gameInterface.Visible then
        teamSelectionGui.Visible = false
    end
end
local player = game.Players.LocalPlayer
local interface = player.PlayerGui.Interface
local roundOverStats = interface.RoundOverStats

local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local function pressEscTwice()
    task.wait(1)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Escape, false, game)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Escape, false, game)
    task.wait(0.3)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Escape, false, game)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Escape, false, game)
end

local function hopServer()
    local placeId = game.PlaceId
    local currentJobId = game.JobId
    local success, servers = pcall(function()
        local response = game:HttpGetAsync(
            "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
        )
        return HttpService:JSONDecode(response)
    end)

    if success and servers and servers.data then
        for _, server in ipairs(servers.data) do
            if server.id ~= currentJobId and server.playing < server.maxPlayers then
                TeleportService:TeleportToPlaceInstance(placeId, server.id, Players.LocalPlayer)
                break
            end
        end
    end
end

local escPressed = false

local function checkRoundOverStats()
    while true do
        if roundOverStats.Visible then
            if not escPressed then
                pressEscTwice()
                hopServer()
                escPressed = true
            end
        else
            escPressed = false
        end
        task.wait(0.5)
    end
end

task.spawn(checkRoundOverStats)
-- Listen for the player's character reset and re-trigger the team selection
player.CharacterAdded:Connect(function(character)
    -- ถ้าเปิด toggle แล้วให้เริ่มเลือกทีม
    if enablejoin then
        teamSelection()
    end
end)

-- เรียกครั้งแรกเลย ไม่ต้องรอ reset
teamSelection()

-- ต้องใช้ Synapse Input library
local VirtualInputManager = game:GetService("VirtualInputManager")

-- ตัวแปรสำคัญ
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local isRunning = true
local ballPrefix = "CLIENT_BALL_"

-- ฟังก์ชันกด Space
local function pressSpace()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
end

-- ฟังก์ชันคลิกซ้าย
local function pressClick()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
end

-- หาตำแหน่งของลูกบอล
local function getBall()
    for _, object in pairs(workspace:GetChildren()) do
        if object:IsA("Model") and object.Name:match(ballPrefix) then
            return object:FindFirstChild("Sphere.001") or object:FindFirstChild("Cube.001")
        end
    end
    return nil
end

-- หาตำแหน่งเป้าหมายแบบสุ่ม (สำหรับหันไปหา)
local function getRandomTargetPart()
    local targets = workspace:GetDescendants()
    for _, target in pairs(targets) do
        if target:IsA("BasePart") and target ~= humanoidRootPart then
            return target
        end
    end
    return nil
end

-- ลูปทำงานหลัก
task.spawn(function()
    while task.wait(0.3) do
        if not isRunning then
            continue
        end

        local ballPart = getBall()
        if ballPart then
            humanoid:MoveTo(ballPart.Position)

            local distance = (ballPart.Position - humanoidRootPart.Position).Magnitude

            if distance <= 15 then
                local targetPart = getRandomTargetPart()
                if targetPart then
                    local lookVector = (targetPart.Position - humanoidRootPart.Position).Unit
                    humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + lookVector)
                end

                if ballPart.Position.Y > humanoidRootPart.Position.Y + 5 then
                    pressSpace()
                    pressClick()
                end
            end
        end
    end
end)


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



-- ตั้งค่า FPS ทันทีเมื่อเริ่มต้น
setfpscap(5)

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

task.delay(1000, function()
    game:GetService("Players").LocalPlayer:Kick("Kicked after 30 min.")
end)




