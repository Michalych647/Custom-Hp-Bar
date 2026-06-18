local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local GroupService = game:GetService("GroupService")

local LocalPlayer = Players.LocalPlayer

local ownerUserId = 0

task.spawn(function()
	if game.CreatorType == Enum.CreatorType.Group then
		local success, groupInfo = pcall(function()
			return GroupService:GetGroupInfoAsync(game.CreatorId)
		end)
		if success and groupInfo then
			ownerUserId = groupInfo.Owner.Id
		end
	else
		ownerUserId = game.CreatorId
	end
end)

local existingGui = CoreGui:FindFirstChild("CustomHealthBarGui")
if existingGui then existingGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomHealthBarGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.Parent = CoreGui

local barWidth = 250
local barHeight = 28

pcall(function()
	local originalBar = CoreGui:WaitForChild("TopBarApp", 5)
		:WaitForChild("TopBarApp", 5)
		:WaitForChild("UnibarLeftFrame", 5)
		:WaitForChild("HealthBar", 5)
		:WaitForChild("HealthBar", 5)
	if originalBar then
		barWidth = originalBar.AbsoluteSize.X + 50
		barHeight = originalBar.AbsoluteSize.Y + 8
	end
end)

local button = Instance.new("Frame")
button.Name = "CustomHealthBar"
button.Size = UDim2.new(0, barWidth, 0, barHeight)
button.AnchorPoint = Vector2.new(1, 0.5)
button.Position = UDim2.new(1, -10, 0, 22)
button.BackgroundTransparency = 1
button.Visible = false
button.Parent = screenGui

local iconButton = Instance.new("Frame")
iconButton.Name = "IconButton"
iconButton.Size = UDim2.new(1, 0, 1, 0)
iconButton.Position = UDim2.new(0, 0, 0, 0)
iconButton.BackgroundTransparency = 0.08
iconButton.BackgroundColor3 = Color3.fromRGB(18, 18, 21)
iconButton.BorderSizePixel = 0
iconButton.ClipsDescendants = true
iconButton.ZIndex = 2
iconButton.Parent = button

local uiCornerBtn = Instance.new("UICorner")
uiCornerBtn.CornerRadius = UDim.new(1, 0)
uiCornerBtn.Parent = iconButton

local uiGradient = Instance.new("UIGradient")
uiGradient.Name = "IconGradient"
uiGradient.Rotation = 0
uiGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0, 0), NumberSequenceKeypoint.new(1, 0, 0)})
uiGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))})
uiGradient.Parent = iconButton

local iconSpot = Instance.new("Frame")
iconSpot.Name = "IconSpot"
iconSpot.Size = UDim2.new(1, -8, 1, -8)
iconSpot.Position = UDim2.new(0, 4, 0.5, 0)
iconSpot.AnchorPoint = Vector2.new(0, 0.5)
iconSpot.BackgroundTransparency = 1
iconSpot.BorderSizePixel = 0
iconSpot.ClipsDescendants = true
iconSpot.ZIndex = 5
iconSpot.Parent = iconButton

local uiCornerSpot = Instance.new("UICorner")
uiCornerSpot.CornerRadius = UDim.new(1, 0)
uiCornerSpot.Parent = iconSpot

local fill = Instance.new("Frame")
fill.Name = "Fill"
fill.Size = UDim2.new(1, 0, 1, 0)
fill.Position = UDim2.new(0, 0, 0, 0)
fill.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
fill.BackgroundTransparency = 0
fill.BorderSizePixel = 0
fill.ZIndex = 6
fill.Visible = true
fill.Parent = iconSpot

local uiCornerFill = Instance.new("UICorner")
uiCornerFill.CornerRadius = UDim.new(1, 0)
uiCornerFill.Parent = fill

local iconOverlay = Instance.new("Frame")
iconOverlay.Name = "IconOverlay"
iconOverlay.Size = UDim2.new(1, 0, 1, 0)
iconOverlay.BackgroundTransparency = 0.85
iconOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
iconOverlay.BorderSizePixel = 0
iconOverlay.Visible = false
iconOverlay.ZIndex = 7
iconOverlay.Parent = iconSpot

local uiCornerOverlay = Instance.new("UICorner")
uiCornerOverlay.Name = "OverlayUICorner"
uiCornerOverlay.CornerRadius = UDim.new(1, 0)
uiCornerOverlay.Parent = iconOverlay

local hpLabel = Instance.new("TextLabel")
hpLabel.Name = "HpLabel"
hpLabel.Size = UDim2.new(1, 0, 1, 0)
hpLabel.Position = UDim2.new(0, 0, 0, 0)
hpLabel.BackgroundTransparency = 1
hpLabel.ZIndex = 10
hpLabel.Text = ""
hpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
hpLabel.TextScaled = true
hpLabel.Font = Enum.Font.GothamBold
hpLabel.Parent = iconSpot

local target = nil
local positionDirty = false
local targetConnections = {}

local function findUnibarTarget()
	local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
	local topbarStandard = PlayerGui:FindFirstChild("TopbarStandard")
	local leftHolder = topbarStandard and topbarStandard:FindFirstChild("Holders") and topbarStandard.Holders:FindFirstChild("Left")

	if leftHolder then
		local maxX = -math.huge
		for _, child in ipairs(leftHolder:GetChildren()) do
			if child:IsA("GuiObject") then
				if child.AbsolutePosition.X > maxX then
					maxX = child.AbsolutePosition.X
					target = child
				end
			end
		end
	end

	if not target then
		pcall(function()
			target = CoreGui:WaitForChild("TopBarApp", 5):WaitForChild("TopBarApp", 5):WaitForChild("UnibarLeftFrame", 5):WaitForChild("UnibarMenu", 5):WaitForChild("2", 5)
		end)
	end
end

local function updatePosition()
	local topbarStandard = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("TopbarStandard")
	local rightHolder = topbarStandard and topbarStandard:FindFirstChild("Holders") and topbarStandard.Holders:FindFirstChild("Right")

	local rightTarget = nil
	if rightHolder then
		local minX = math.huge
		for _, child in ipairs(rightHolder:GetChildren()) do
			if child:IsA("GuiObject") then
				if child.AbsolutePosition.X < minX then
					minX = child.AbsolutePosition.X
					rightTarget = child
				end
			end
		end
	end

	if rightTarget then
		local screenWidth = screenGui.AbsoluteSize.X
		local posX = screenWidth - 10
		local posY = rightTarget.AbsolutePosition.Y + rightTarget.AbsoluteSize.Y + barHeight / 2 + 5
		if posX - barWidth < 0 then posX = barWidth end
		if posY + barHeight / 2 > screenGui.AbsoluteSize.Y then
			posY = screenGui.AbsoluteSize.Y - barHeight / 2
		end
		button.Position = UDim2.new(0, posX, 0, posY)
		button.AnchorPoint = Vector2.new(1, 0.5)
	else
		if not target then return end
		local targetAbsoluteSize = target.AbsoluteSize
		local targetAbsolutePosition = target.AbsolutePosition
		local screenWidth = screenGui.AbsoluteSize.X
		button.Position = UDim2.new(0, screenWidth - 10, 0, targetAbsolutePosition.Y + targetAbsoluteSize.Y / 2)
		button.AnchorPoint = Vector2.new(1, 0.5)
	end
	positionDirty = false
end

local function connectTarget()
	for _, c in ipairs(targetConnections) do
		c:Disconnect()
	end
	table.clear(targetConnections)
	if target then
		table.insert(targetConnections, target:GetPropertyChangedSignal("AbsolutePosition"):Connect(function() positionDirty = true end))
		table.insert(targetConnections, target:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() positionDirty = true end))
	end
end

task.spawn(function()
	findUnibarTarget()
	if target then
		connectTarget()
		updatePosition()
	end
end)

local function removeVanillaHealthBar()
	pcall(function()
		local hb = CoreGui:FindFirstChild("TopBarApp")
			and CoreGui.TopBarApp:FindFirstChild("TopBarApp")
			and CoreGui.TopBarApp.TopBarApp:FindFirstChild("UnibarLeftFrame")
			and CoreGui.TopBarApp.TopBarApp.UnibarLeftFrame:FindFirstChild("HealthBar")
		if hb then hb:Destroy() end
	end)
end

removeVanillaHealthBar()

pcall(function()
	local leftFrame = CoreGui:WaitForChild("TopBarApp", 10)
		:WaitForChild("TopBarApp", 10)
		:WaitForChild("UnibarLeftFrame", 10)
	if leftFrame then
		leftFrame.ChildAdded:Connect(function(child)
			if child.Name == "HealthBar" then
				task.wait()
				child:Destroy()
			end
		end)
	end
end)

local trackedHumanoids = {}
local NAME_RADIUS = 120
local HP_RADIUS = 70

local function getHpColor(health, maxHealth)
	local ratio = health / maxHealth
	if ratio <= 0.25 then
		return Color3.fromRGB(255, 60, 60)
	elseif ratio <= 0.57 then
		return Color3.fromRGB(255, 220, 50)
	else
		return Color3.fromRGB(85, 255, 85)
	end
end

local function getLocalRootPart()
	local char = LocalPlayer.Character
	if char then
		return char:FindFirstChild("HumanoidRootPart")
	end
	return nil
end

local function updateBillboardHealth(data)
	local humanoid = data.humanoid
	local health = humanoid.Health
	local maxHealth = humanoid.MaxHealth

	if maxHealth <= 0 then
		data.bgui.Enabled = false
		return
	end

	local localRoot = getLocalRootPart()
	if not localRoot then
		data.bgui.Enabled = false
		return
	end

	local head = data.head
	if not head or not head.Parent then
		data.bgui.Enabled = false
		return
	end

	local dist = (head.Position - localRoot.Position).Magnitude
	if dist > NAME_RADIUS then
		data.bgui.Enabled = false
		return
	end

	data.bgui.Enabled = true

	local plr = Players:GetPlayerFromCharacter(data.char)
	if plr and plr.Team then
		data.nameLabel.TextColor3 = plr.Team.TeamColor.Color
	else
		data.nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	end

	local showHP = dist <= HP_RADIUS and health < maxHealth

	if not showHP then
		data.barBG.Visible = false
		data.textLabel.Visible = false
	else
		data.barBG.Visible = true
		data.textLabel.Visible = true

		if health <= 0 then
			data.fillFrame.Visible = false
			data.textLabel.Text = "0/" .. math.floor(maxHealth)
		else
			data.fillFrame.Visible = true
			local ratio = math.clamp(health / maxHealth, 0, 1)
			data.fillFrame.Size = UDim2.new(ratio, 0, 1, 0)
			data.fillFrame.BackgroundColor3 = getHpColor(health, maxHealth)
			data.textLabel.Text = math.floor(health) .. "/" .. math.floor(maxHealth)
		end
	end
end

local function createBillboardGui(head, humanoid, char)
	local bgui = Instance.new("BillboardGui")
	bgui.Name = "CustomHealthBBGui"
	bgui.Size = UDim2.new(0, 160, 0, 60)
	bgui.AlwaysOnTop = false
	bgui.StudsOffset = Vector3.new(0, 2.5, 0)
	bgui.ResetOnSpawn = false
	bgui.Adornee = head
	bgui.Enabled = false
	bgui.Parent = head

	local container = Instance.new("Frame")
	container.Name = "Container"
	container.Size = UDim2.new(1, 0, 1, 0)
	container.BackgroundTransparency = 1
	container.Parent = bgui

	local player = Players:GetPlayerFromCharacter(char)
	local isPlayer = player ~= nil

	local avatar = Instance.new("ImageLabel")
	avatar.Name = "Avatar"
	avatar.BackgroundTransparency = 1
	avatar.Size = UDim2.new(0, 24, 0, 24)
	avatar.Position = UDim2.new(0, 0, 0, 0)
	avatar.Visible = isPlayer
	avatar.Parent = container

	local uiCornerAv = Instance.new("UICorner")
	uiCornerAv.CornerRadius = UDim.new(1, 0)
	uiCornerAv.Parent = avatar

	if isPlayer then
		task.spawn(function()
			pcall(function()
				avatar.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
			end)
		end)
	end

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 12
	nameLabel.TextScaled = false
	nameLabel.Parent = container

	local realNameLabel = Instance.new("TextLabel")
	realNameLabel.Name = "RealNameLabel"
	realNameLabel.BackgroundTransparency = 1
	realNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	realNameLabel.Font = Enum.Font.Gotham
	realNameLabel.TextSize = 10
	realNameLabel.TextScaled = false
	realNameLabel.Visible = true
	realNameLabel.Parent = container

	local barBG = Instance.new("Frame")
	barBG.Name = "BarBG"
	barBG.Size = UDim2.new(0, 80, 0, 8)
	barBG.BackgroundColor3 = Color3.fromRGB(18, 18, 21)
	barBG.BackgroundTransparency = 0.08
	barBG.BorderSizePixel = 0
	barBG.ClipsDescendants = true
	barBG.Parent = container

	local uiCornerBar = Instance.new("UICorner")
	uiCornerBar.CornerRadius = UDim.new(1, 0)
	uiCornerBar.Parent = barBG

	local fillFrame = Instance.new("Frame")
	fillFrame.Name = "Fill"
	fillFrame.Size = UDim2.new(1, 0, 1, 0)
	fillFrame.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
	fillFrame.BorderSizePixel = 0
	fillFrame.Parent = barBG

	local uiCornerFill = Instance.new("UICorner")
	uiCornerFill.CornerRadius = UDim.new(1, 0)
	uiCornerFill.Parent = fillFrame

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "HealthText"
	textLabel.Size = UDim2.new(0, 40, 0, 12)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextSize = 10
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Parent = container

	if isPlayer then
		nameLabel.Size = UDim2.new(0, 130, 0, 14)
		nameLabel.Position = UDim2.new(0, 30, 0, 0)
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		
		local iconsStr = ""
		
		if player.HasVerifiedBadge then
			iconsStr = iconsStr .. '<font color="#00a2ff">' .. utf8.char(0xE000) .. '</font> '
		end
		
		local hasPremium = false
		pcall(function()
			if player.MembershipType ~= Enum.MembershipType.None or player["HasRobloxSubscription"] then
				hasPremium = true
			end
		end)
		
		if hasPremium then
			iconsStr = iconsStr .. '<font color="#ffffff">' .. utf8.char(0xE003) .. '</font> '
		end
		
		if player.UserId == ownerUserId then
			iconsStr = iconsStr .. '<image="rbxassetid://11322089611"> '
		end
		
		nameLabel.RichText = true
		nameLabel.Text = player.DisplayName .. " " .. iconsStr

		realNameLabel.Size = UDim2.new(0, 130, 0, 12)
		realNameLabel.Position = UDim2.new(0, 30, 0, 14)
		realNameLabel.TextXAlignment = Enum.TextXAlignment.Left
		realNameLabel.Text = "@" .. player.Name

		barBG.Position = UDim2.new(0, 30, 0, 30)
		textLabel.Position = UDim2.new(0, 115, 0, 28)
	else
		nameLabel.Size = UDim2.new(0, 160, 0, 14)
		nameLabel.Position = UDim2.new(0, 0, 0, 0)
		nameLabel.TextXAlignment = Enum.TextXAlignment.Center
		nameLabel.Text = humanoid.DisplayName ~= "" and humanoid.DisplayName or char.Name
		
		realNameLabel.Size = UDim2.new(0, 160, 0, 12)
		realNameLabel.Position = UDim2.new(0, 0, 0, 14)
		realNameLabel.TextXAlignment = Enum.TextXAlignment.Center
		realNameLabel.Text = "NPC"

		barBG.Position = UDim2.new(0.5, -40, 0, 30)
		textLabel.Position = UDim2.new(0.5, 45, 0, 28)
	end

	local connections = {}

	local data = {
		bgui = bgui,
		nameLabel = nameLabel,
		realNameLabel = realNameLabel,
		barBG = barBG,
		fillFrame = fillFrame,
		textLabel = textLabel,
		humanoid = humanoid,
		head = head,
		char = char,
		isPlayer = isPlayer,
	}

	local function cleanup()
		trackedHumanoids[humanoid] = nil
		for _, c in ipairs(connections) do
			c:Disconnect()
		end
		table.clear(connections)
		if bgui then
			bgui.Enabled = false
			bgui:Destroy()
		end
	end

	table.insert(connections, humanoid.HealthChanged:Connect(function()
		updateBillboardHealth(data)
	end))

	table.insert(connections, humanoid.Died:Connect(cleanup))

	table.insert(connections, humanoid.AncestryChanged:Connect(function()
		if not humanoid:IsDescendantOf(workspace) then
			cleanup()
		end
	end))

	updateBillboardHealth(data)

	return data
end

local function trackHumanoid(humanoid)
	if trackedHumanoids[humanoid] then return end

	task.spawn(function()
		local char = humanoid.Parent
		if not char then return end
		if char == LocalPlayer.Character then return end

		local head = char:WaitForChild("Head", 10)
		if not head or not head:IsA("BasePart") then return end
		if char == LocalPlayer.Character then return end

		if head:FindFirstChild("CustomHealthBBGui") then return end
		if trackedHumanoids[humanoid] then return end

		trackedHumanoids[humanoid] = createBillboardGui(head, humanoid, char)

		if humanoid.DisplayDistanceType ~= Enum.HumanoidDisplayDistanceType.None then
			pcall(function()
				humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			end)
		end
	end)
end

local function handleDescendant(descendant)
	if descendant:IsA("Humanoid") then
		trackHumanoid(descendant)
	end
end

for _, descendant in ipairs(workspace:GetDescendants()) do
	handleDescendant(descendant)
end

workspace.DescendantAdded:Connect(handleDescendant)

local cachedHumanoid = nil
local cachedLastHealth = -1
local cachedLastMax = -1

local RADIUS_CHECK_RATE = 0.2
local lastRadiusCheck = 0

local function getHumanoid()
	local char = LocalPlayer.Character
	if char then
		if cachedHumanoid and cachedHumanoid:IsDescendantOf(char) then
			return cachedHumanoid
		end
		cachedHumanoid = char:FindFirstChildOfClass("Humanoid")
		return cachedHumanoid
	end
	cachedHumanoid = nil
	return nil
end

RunService.Heartbeat:Connect(function(dt)
	if positionDirty and button.Visible then
		updatePosition()
	end

	local now = os.clock()
	if now - lastRadiusCheck >= RADIUS_CHECK_RATE then
		lastRadiusCheck = now
		for _, data in pairs(trackedHumanoids) do
			updateBillboardHealth(data)
		end
	end

	local humanoid = getHumanoid()
	if humanoid then
		local health = humanoid.Health
		local maxHealth = humanoid.MaxHealth

		if health ~= cachedLastHealth or maxHealth ~= cachedLastMax then
			cachedLastHealth = health
			cachedLastMax = maxHealth

			if maxHealth > 0 and health < maxHealth and health > 0 then
				button.Visible = true
				if positionDirty then
					updatePosition()
				end
				local ratio = math.clamp(health / maxHealth, 0, 1)
				fill.Visible = true
				fill.Size = UDim2.new(ratio, 0, 1, 0)
				fill.BackgroundColor3 = getHpColor(health, maxHealth)
				hpLabel.Text = math.floor(health) .. "/" .. math.floor(maxHealth)
			elseif maxHealth > 0 and health <= 0 then
				button.Visible = true
				fill.Visible = false
				hpLabel.Text = "0/" .. math.floor(maxHealth)
			else
				button.Visible = false
			end
		end
	else
		if button.Visible then
			button.Visible = false
		end
		cachedLastHealth = -1
		cachedLastMax = -1
	end
end)

LocalPlayer.CharacterAdded:Connect(function()
	cachedHumanoid = nil
	cachedLastHealth = -1
	cachedLastMax = -1
	task.wait(1)
	removeVanillaHealthBar()
	findUnibarTarget()
	if target then
		connectTarget()
		updatePosition()
	end
end)
