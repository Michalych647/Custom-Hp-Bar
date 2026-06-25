local Plrs = game:GetService("Players")
local CGui = game:GetService("CoreGui")
local RS = game:GetService("RunService")
local GS = game:GetService("GroupService")

local LP = Plrs.LocalPlayer
local oUID = 0

task.spawn(function()
	if game.CreatorType == Enum.CreatorType.Group then
		pcall(function() oUID = GS:GetGroupInfoAsync(game.CreatorId).Owner.Id end)
	else
		oUID = game.CreatorId
	end
end)

local eGui = CGui:FindFirstChild("CustomHealthBarGui")
if eGui then eGui:Destroy() end

local sGui = Instance.new("ScreenGui")
sGui.Name = "CustomHealthBarGui"
sGui.ResetOnSpawn = false
sGui.DisplayOrder = 999
sGui.Parent = CGui

local bW = 250
local bH = 28

pcall(function()
	local oB = CGui:WaitForChild("TopBarApp", 5):WaitForChild("TopBarApp", 5):WaitForChild("UnibarLeftFrame", 5):WaitForChild("HealthBar", 5):WaitForChild("HealthBar", 5)
	if oB then bW = oB.AbsoluteSize.X + 50 bH = oB.AbsoluteSize.Y + 8 end
end)

local btn = Instance.new("Frame")
btn.Size = UDim2.new(0, bW, 0, bH)
btn.AnchorPoint = Vector2.new(1, 0.5)
btn.Position = UDim2.new(1, -10, 0, 22)
btn.BackgroundTransparency = 1
btn.Visible = false
btn.Parent = sGui

local iBtn = Instance.new("Frame")
iBtn.Size = UDim2.new(1, 0, 1, 0)
iBtn.BackgroundTransparency = 0.08
iBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 21)
iBtn.BorderSizePixel = 0
iBtn.ClipsDescendants = true
iBtn.ZIndex = 2
iBtn.Parent = btn

Instance.new("UICorner", iBtn).CornerRadius = UDim.new(1, 0)

local uG = Instance.new("UIGradient", iBtn)
uG.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0), NumberSequenceKeypoint.new(1,0,0)})

local iSpt = Instance.new("Frame")
iSpt.Size = UDim2.new(1, -8, 1, -8)
iSpt.Position = UDim2.new(0, 4, 0.5, 0)
iSpt.AnchorPoint = Vector2.new(0, 0.5)
iSpt.BackgroundTransparency = 1
iSpt.ZIndex = 5
iSpt.Parent = iBtn

Instance.new("UICorner", iSpt).CornerRadius = UDim.new(1, 0)

local bgFl = Instance.new("Frame")
bgFl.Size = UDim2.new(1, 0, 1, 0)
bgFl.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
bgFl.BackgroundTransparency = 0.7
bgFl.BorderSizePixel = 0
bgFl.ZIndex = 5
bgFl.Visible = false
bgFl.Parent = iSpt

Instance.new("UICorner", bgFl).CornerRadius = UDim.new(1, 0)

local fill = Instance.new("Frame")
fill.Size = UDim2.new(1, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
fill.BorderSizePixel = 0
fill.ZIndex = 6
fill.Parent = iSpt

Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

local hpLb = Instance.new("TextLabel")
hpLb.Size = UDim2.new(1, 0, 1, 0)
hpLb.BackgroundTransparency = 1
hpLb.ZIndex = 10
hpLb.TextColor3 = Color3.fromRGB(255, 255, 255)
hpLb.TextScaled = true
hpLb.Font = Enum.Font.GothamBold
hpLb.Parent = iSpt

local dLb = Instance.new("TextLabel")
dLb.Size = UDim2.new(0, 40, 1, 0)
dLb.Position = UDim2.new(0.5, 45, 0, 0)
dLb.BackgroundTransparency = 1
dLb.ZIndex = 10
dLb.TextScaled = true
dLb.Font = Enum.Font.GothamBold
dLb.TextXAlignment = Enum.TextXAlignment.Left
dLb.Visible = false
dLb.Parent = iSpt

local tgt = nil
local pDrt = false
local tCon = {}

local function fUTgt()
	local pG = LP:WaitForChild("PlayerGui")
	local tS = pG:FindFirstChild("TopbarStandard")
	local lH = tS and tS:FindFirstChild("Holders") and tS.Holders:FindFirstChild("Left")
	if lH then
		local mX = -math.huge
		for _, c in ipairs(lH:GetChildren()) do
			if c:IsA("GuiObject") and c.AbsolutePosition.X > mX then
				mX = c.AbsolutePosition.X
				tgt = c
			end
		end
	end
	if not tgt then
		pcall(function() tgt = CGui:WaitForChild("TopBarApp", 5):WaitForChild("TopBarApp", 5):WaitForChild("UnibarLeftFrame", 5):WaitForChild("UnibarMenu", 5):WaitForChild("2", 5) end)
	end
end

local function uPos()
	local tS = LP:WaitForChild("PlayerGui"):FindFirstChild("TopbarStandard")
	local rH = tS and tS:FindFirstChild("Holders") and tS.Holders:FindFirstChild("Right")
	local rTgt = nil
	if rH then
		local mnX = math.huge
		for _, c in ipairs(rH:GetChildren()) do
			if c:IsA("GuiObject") and c.AbsolutePosition.X < mnX then
				mnX = c.AbsolutePosition.X
				rTgt = c
			end
		end
	end
	local sW = sGui.AbsoluteSize.X
	if rTgt then
		local pX = sW - 10
		local pY = rTgt.AbsolutePosition.Y + rTgt.AbsoluteSize.Y + bH / 2 + 5
		if pX - bW < 0 then pX = bW end
		if pY + bH / 2 > sGui.AbsoluteSize.Y then pY = sGui.AbsoluteSize.Y - bH / 2 end
		btn.Position = UDim2.new(0, pX, 0, pY)
	elseif tgt then
		btn.Position = UDim2.new(0, sW - 10, 0, tgt.AbsolutePosition.Y + tgt.AbsoluteSize.Y / 2)
	end
	pDrt = false
end

local function cTgt()
	for _, c in ipairs(tCon) do c:Disconnect() end
	table.clear(tCon)
	if tgt then
		table.insert(tCon, tgt:GetPropertyChangedSignal("AbsolutePosition"):Connect(function() pDrt = true end))
		table.insert(tCon, tgt:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() pDrt = true end))
	end
end

task.spawn(function()
	fUTgt()
	if tgt then cTgt() uPos() end
end)

local function rVHB()
	pcall(function()
		local h = CGui:FindFirstChild("TopBarApp") and CGui.TopBarApp:FindFirstChild("TopBarApp") and CGui.TopBarApp.TopBarApp:FindFirstChild("UnibarLeftFrame") and CGui.TopBarApp.TopBarApp.UnibarLeftFrame:FindFirstChild("HealthBar")
		if h then h:Destroy() end
	end)
end

rVHB()

pcall(function()
	local lF = CGui:WaitForChild("TopBarApp", 10):WaitForChild("TopBarApp", 10):WaitForChild("UnibarLeftFrame", 10)
	if lF then
		lF.ChildAdded:Connect(function(c)
			if c.Name == "HealthBar" then task.wait() c:Destroy() end
		end)
	end
end)

local tHms = {}
local N_RAD = 120
local H_RAD = 100

local function cHpC(h, m)
	local r = h / m
	if r <= 0.28 then return Color3.fromRGB(180, 40, 40)
	elseif r <= 0.57 then return Color3.fromRGB(180, 150, 30)
	else return Color3.fromRGB(60, 180, 60) end
end

local function gLRt()
	local c = LP.Character
	return c and c:FindFirstChild("HumanoidRootPart") or nil
end

local frns = {}

local function uBB(d)
	local h = d.hum.Health
	local m = d.hum.MaxHealth
	if m <= 0 then d.bg.Enabled = false return end
	local lR = gLRt()
	if not lR or not d.hd or not d.hd.Parent then d.bg.Enabled = false return end
	local dst = (d.hd.Position - lR.Position).Magnitude
	if dst > N_RAD then d.bg.Enabled = false return end
	d.bg.Enabled = true

	local p = Plrs:GetPlayerFromCharacter(d.chr)
	d.nLb.TextColor3 = (p and p.Team) and p.Team.TeamColor.Color or Color3.fromRGB(255, 255, 255)

	if p then
		d.nLb.Text = p.DisplayName
		d.oIc.Visible = (p.UserId == oUID)
		d.fIc.Visible = (frns[p] == true)
		d.vIc.Visible = p.HasVerifiedBadge
		local prm = false
		pcall(function() prm = (p.MembershipType ~= Enum.MembershipType.None or p["HasRobloxSubscription"]) end)
		d.pIc.Visible = prm
	end

	local sH = dst <= H_RAD and h < m
	if not sH then
		d.bBG.Visible = false
		d.tLb.Visible = false
		d.dLb.Visible = false
		d.bFl.Visible = false
	else
		d.bBG.Visible = true
		d.tLb.Visible = true

		if h ~= d.lHp then
			local v = h - (d.lHp == -1 and h or d.lHp)
			if v ~= 0 then d.dV = v d.dT = os.clock() end
			d.lHp = h
		end

		if h <= 0 then
			d.fl.Visible = false
			d.bFl.Visible = false
			d.tLb.Text = "0/" .. math.floor(m)
			d.dLb.Visible = false
		else
			d.fl.Visible = true
			d.bFl.Visible = false
			d.fl.Size = UDim2.new(math.clamp(h/m, 0, 1), 0, 1, 0)
			d.fl.BackgroundColor3 = cHpC(h, m)
			d.tLb.Text = math.floor(h) .. "/" .. math.floor(m)
			d.dLb.Visible = false
		end
	end
end

local function mkIc(id, ord, pt)
	local i = Instance.new("ImageLabel")
	i.BackgroundTransparency = 1
	i.Size = UDim2.new(0, 14, 0, 14)
	i.LayoutOrder = ord
	i.Visible = false
	if id ~= "" then i.Image = id end
	i.Parent = pt
	return i
end

local function mkTx(t, c, ord, pt)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Text = t
	l.TextColor3 = c
	l.Size = UDim2.new(0, 14, 0, 14)
	l.TextSize = 12
	l.LayoutOrder = ord
	l.Visible = false
	l.Parent = pt
	return l
end

local function cBB(hd, hm, ch)
	local bg = Instance.new("BillboardGui")
	bg.Size = UDim2.new(0, 160, 0, 60)
	bg.StudsOffset = Vector3.new(0, 2.5, 0)
	bg.Adornee = hd
	bg.Parent = hd

	local ct = Instance.new("Frame")
	ct.Size = UDim2.new(1, 0, 1, 0)
	ct.BackgroundTransparency = 1
	ct.Parent = bg

	local p = Plrs:GetPlayerFromCharacter(ch)
	local isP = p ~= nil

	local av = Instance.new("ImageLabel")
	av.BackgroundTransparency = 1
	av.Size = UDim2.new(0, 24, 0, 24)
	av.Visible = isP
	av.Parent = ct
	Instance.new("UICorner", av).CornerRadius = UDim.new(1, 0)

	if isP then task.spawn(function() pcall(function() av.Image = Plrs:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end) end) end

	local iFr = Instance.new("Frame")
	iFr.BackgroundTransparency = 1
	iFr.Size = UDim2.new(0, 130, 0, 14)
	iFr.Parent = ct

	local lst = Instance.new("UIListLayout")
	lst.FillDirection = Enum.FillDirection.Horizontal
	lst.SortOrder = Enum.SortOrder.LayoutOrder
	lst.Padding = UDim.new(0, 2)
	lst.Parent = iFr

	local nLb = Instance.new("TextLabel")
	nLb.BackgroundTransparency = 1
	nLb.Font = Enum.Font.GothamBold
	nLb.TextSize = 12
	nLb.AutomaticSize = Enum.AutomaticSize.X
	nLb.Size = UDim2.new(0, 0, 1, 0)
	nLb.LayoutOrder = 0
	nLb.Parent = iFr

	local vIc = mkTx(utf8.char(0xE000), Color3.fromRGB(0, 162, 255), 1, iFr)
	local pIc = mkTx(utf8.char(0xE003), Color3.fromRGB(255, 255, 255), 2, iFr)
	local oIc = mkIc("rbxassetid://11322089611", 3, iFr)
	local fIc = mkIc("rbxassetid://5422861547", 4, iFr)

	local rLb = Instance.new("TextLabel")
	rLb.BackgroundTransparency = 1
	rLb.TextColor3 = Color3.fromRGB(255, 255, 255)
	rLb.Font = Enum.Font.Gotham
	rLb.TextSize = 10
	rLb.Parent = ct

	local bBG = Instance.new("Frame")
	bBG.Size = UDim2.new(0, 80, 0, 8)
	bBG.BackgroundColor3 = Color3.fromRGB(18, 18, 21)
	bBG.BackgroundTransparency = 0.08
	bBG.BorderSizePixel = 0
	bBG.ClipsDescendants = true
	bBG.Parent = ct
	Instance.new("UICorner", bBG).CornerRadius = UDim.new(1, 0)

	local bFl = Instance.new("Frame")
	bFl.Size = UDim2.new(1, 0, 1, 0)
	bFl.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	bFl.BackgroundTransparency = 0.7
	bFl.BorderSizePixel = 0
	bFl.Visible = false
	bFl.Parent = bBG
	Instance.new("UICorner", bFl).CornerRadius = UDim.new(1, 0)

	local fl = Instance.new("Frame")
	fl.Size = UDim2.new(1, 0, 1, 0)
	fl.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
	fl.BorderSizePixel = 0
	fl.Parent = bBG
	Instance.new("UICorner", fl).CornerRadius = UDim.new(1, 0)

	local tLb = Instance.new("TextLabel")
	tLb.Size = UDim2.new(0, 40, 0, 12)
	tLb.BackgroundTransparency = 1
	tLb.TextColor3 = Color3.fromRGB(255, 255, 255)
	tLb.TextSize = 10
	tLb.Font = Enum.Font.GothamBold
	tLb.TextXAlignment = Enum.TextXAlignment.Left
	tLb.Parent = ct

	local dbL = Instance.new("TextLabel")
	dbL.Size = UDim2.new(0, 40, 0, 12)
	dbL.BackgroundTransparency = 1
	dbL.TextSize = 10
	dbL.Font = Enum.Font.GothamBold
	dbL.TextXAlignment = Enum.TextXAlignment.Left
	dbL.Visible = false
	dbL.Parent = ct

	if isP then
		iFr.Position = UDim2.new(0, 30, 0, 0)
		lst.HorizontalAlignment = Enum.HorizontalAlignment.Left
		rLb.Size = UDim2.new(0, 130, 0, 12)
		rLb.Position = UDim2.new(0, 30, 0, 14)
		rLb.TextXAlignment = Enum.TextXAlignment.Left
		rLb.Text = "@" .. p.Name
		bBG.Position = UDim2.new(0.5, -40, 0, 30)
		tLb.Position = UDim2.new(0.5, 45, 0, 28)
		dbL.Position = UDim2.new(0.5, 85, 0, 28)
	else
		iFr.Position = UDim2.new(0, 0, 0, 0)
		iFr.Size = UDim2.new(0, 160, 0, 14)
		lst.HorizontalAlignment = Enum.HorizontalAlignment.Center
		nLb.Text = hm.DisplayName ~= "" and hm.DisplayName or ch.Name
		rLb.Size = UDim2.new(0, 160, 0, 12)
		rLb.Position = UDim2.new(0, 0, 0, 14)
		rLb.TextXAlignment = Enum.TextXAlignment.Center
		rLb.Text = "NPC"
		bBG.Position = UDim2.new(0.5, -40, 0, 30)
		tLb.Position = UDim2.new(0.5, 45, 0, 28)
		dbL.Position = UDim2.new(0.5, 85, 0, 28)
	end

	local cns = {}
	local d = {bg=bg, nLb=nLb, rLb=rLb, bBG=bBG, fl=fl, bFl=bFl, tLb=tLb, dLb=dbL, hum=hm, hd=hd, chr=ch, isP=isP, plr=p, vIc=vIc, pIc=pIc, oIc=oIc, fIc=fIc, lHp=-1, dV=0, dT=0}

	local function cln()
		tHms[hm] = nil
		for _, c in ipairs(cns) do c:Disconnect() end
		if bg then bg.Enabled = false bg:Destroy() end
	end

	table.insert(cns, hm.HealthChanged:Connect(function() uBB(d) end))
	table.insert(cns, hm.Died:Connect(cln))
	table.insert(cns, hm.AncestryChanged:Connect(function() if not hm:IsDescendantOf(workspace) then cln() end end))

	uBB(d)
	return d
end

local function tHm(hm)
	if tHms[hm] then return end
	task.spawn(function()
		local c = hm.Parent
		if not c or c == LP.Character then return end
		local hd = c:WaitForChild("Head", 10)
		if not hd or not hd:IsA("BasePart") or c == LP.Character or hd:FindFirstChild("CustomHealthBBGui") or tHms[hm] then return end
		tHms[hm] = cBB(hd, hm, c)
		if hm.DisplayDistanceType ~= Enum.HumanoidDisplayDistanceType.None then pcall(function() hm.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end) end
	end)
end

local function hDs(ds) if ds:IsA("Humanoid") then tHm(ds) end end
for _, ds in ipairs(workspace:GetDescendants()) do hDs(ds) end
workspace.DescendantAdded:Connect(hDs)

local cHm = nil
local cLHp = -1
local cLMx = -1
local cDV = 0
local cDT = 0

local lRCk = 0
local fCk = 0

local function gHm()
	local c = LP.Character
	if c then
		if cHm and cHm:IsDescendantOf(c) then return cHm end
		cHm = c:FindFirstChildOfClass("Humanoid")
		return cHm
	end
	cHm = nil
	return nil
end

RS.Heartbeat:Connect(function()
	if pDrt and btn.Visible then uPos() end
	local nw = os.clock()

	if nw - fCk >= 5 then
		fCk = nw
		task.spawn(function()
			for _, p in ipairs(Plrs:GetPlayers()) do
				if p ~= LP then
					pcall(function() frns[p] = LP:IsFriendsWith(p.UserId) end)
				end
			end
		end)
	end

	if nw - lRCk >= 0.2 then
		lRCk = nw
		for _, d in pairs(tHms) do uBB(d) end
	end

	local hm = gHm()
	if hm then
		local h = hm.Health
		local m = hm.MaxHealth

		if h ~= cLHp or m ~= cLMx then
			local v = h - (cLHp == -1 and h or cLHp)
			if v ~= 0 then cDV = v cDT = nw end
			cLHp = h
			cLMx = m

			if m > 0 and h < m and h > 0 then
				btn.Visible = true
				if pDrt then uPos() end
				bgFl.Visible = false
				fill.Visible = true
				fill.Size = UDim2.new(math.clamp(h/m, 0, 1), 0, 1, 0)
				fill.BackgroundColor3 = cHpC(h, m)
				hpLb.Text = math.floor(h) .. "/" .. math.floor(m)
			elseif m > 0 and h <= 0 then
				btn.Visible = true
				bgFl.Visible = false
				fill.Visible = false
				hpLb.Text = "0/" .. math.floor(m)
			else
				btn.Visible = false
				bgFl.Visible = false
			end
		end

		dLb.Visible = false
	else
		if btn.Visible then btn.Visible = false end
		cLHp = -1
		cLMx = -1
	end
end)

LP.CharacterAdded:Connect(function()
	cHm = nil
	cLHp = -1
	cLMx = -1
	task.wait(1)
	rVHB()
	fUTgt()
	if tgt then cTgt() uPos() end
end)
