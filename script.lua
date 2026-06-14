--[[
    ================================================================
    TITLE: MODERN SOUND SCANNER (WITH FULL GUI TOGGLE)
    DESCRIPTION: Clean & Minimalist Dark Theme Sound Scanner for Roblox
    ================================================================
--]]

local ps = cloneref(game:GetService("Players"))
local ms = cloneref(game:GetService("MarketplaceService"))

local on = true
local sc = false
local swept = false
local cnt = 0
local f = {}
local r = {}
local cn = {}

local opt = {
	{k="g", t="Game Tree", v=true},
	{k="n", t="Nil Instances", v=true},
	{k="m", t="Modules", v=true},
	{k="c", t="Garbage Collector", v=false},
	{k="a", t="All Instances", v=false},
}

--// Main GUI Base
local g = Instance.new("ScreenGui")
g.Name = string.char(math.random(97,122)) .. math.random(10000,99999)
g.ResetOnSpawn = false
g.Parent = gethui()

for _,x in pairs(gethui():GetChildren()) do
	if x ~= g and x:IsA("ScreenGui") and #x.Name > 4 and x.Name:sub(1,1):match("%l") then
		pcall(function() x:Destroy() end)
	end
end

--// Modern Window Frame (หน้าต่างหลัก)
local w = Instance.new("Frame")
w.Size = UDim2.new(0, 310, 0, 440)
w.Position = UDim2.new(0.5, -155, 0.5, -220)
w.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
w.BorderSizePixel = 0
w.Active = true
w.Draggable = true
w.Parent = g

local wCorner = Instance.new("UICorner", w)
wCorner.CornerRadius = UDim.new(0, 8)

local wStroke = Instance.new("UIStroke", w)
wStroke.Color = Color3.fromRGB(35, 35, 35)
wStroke.Thickness = 1

--// Small Open Button (ปุ่มเปิดขนาดเล็กเมื่อซ่อน GUI)
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 60, 0, 30)
openBtn.Position = UDim2.new(0, 10, 0.5, -15) -- ไว้ฝั่งซ้ายของจอเพื่อไม่ให้บังส่วนอื่น
openBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
openBtn.BorderSizePixel = 0
openBtn.Text = "Open"
openBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
openBtn.TextSize = 11
openBtn.Font = Enum.Font.Code
openBtn.Visible = false
openBtn.Parent = g

local obCorner = Instance.new("UICorner", openBtn)
obCorner.CornerRadius = UDim.new(0, 6)

local obStroke = Instance.new("UIStroke", openBtn)
obStroke.Color = Color3.fromRGB(45, 45, 45)
obStroke.Thickness = 1

openBtn.MouseEnter:Connect(function() obStroke.Color = Color3.fromRGB(70, 70, 70) openBtn.TextColor3 = Color3.fromRGB(230, 230, 230) end)
openBtn.MouseLeave:Connect(function() obStroke.Color = Color3.fromRGB(45, 45, 45) openBtn.TextColor3 = Color3.fromRGB(180, 180, 180) end)

--// Top Bar Title
local tl = Instance.new("TextLabel")
tl.Size = UDim2.new(1, -85, 0, 32)
tl.Position = UDim2.new(0, 12, 0, 0)
tl.BackgroundTransparency = 1
tl.Text = "SOUND SCANNER (0)"
tl.TextColor3 = Color3.fromRGB(230, 230, 230)
tl.TextSize = 11
tl.Font = Enum.Font.Code
tl.TextXAlignment = Enum.TextXAlignment.Left
tl.Parent = w

--// Minimal Close Button (ปุ่มปิดโปรแกรม)
local cb = Instance.new("TextButton")
cb.Size = UDim2.new(0, 24, 0, 24)
cb.Position = UDim2.new(1, -32, 0, 4)
cb.BackgroundTransparency = 1
cb.Text = "×"
cb.TextColor3 = Color3.fromRGB(130, 130, 130)
cb.TextSize = 16
cb.Font = Enum.Font.Code
cb.Parent = w

cb.MouseEnter:Connect(function() cb.TextColor3 = Color3.fromRGB(250, 100, 100) end)
cb.MouseLeave:Connect(function() cb.TextColor3 = Color3.fromRGB(130, 130, 130) end)

--// Full GUI Minimize Button (ปุ่มซ่อนทั้ง GUI)
local mb = Instance.new("TextButton")
mb.Size = UDim2.new(0, 24, 0, 24)
mb.Position = UDim2.new(1, -56, 0, 4)
mb.BackgroundTransparency = 1
mb.Text = "_"
mb.TextColor3 = Color3.fromRGB(130, 130, 130)
mb.TextSize = 14
mb.Font = Enum.Font.Code
mb.Parent = w

mb.MouseEnter:Connect(function() mb.TextColor3 = Color3.fromRGB(200, 200, 200) end)
mb.MouseLeave:Connect(function() mb.TextColor3 = Color3.fromRGB(130, 130, 130) end)

--// Toggle Panel Button (ปุ่มหดเฉพาะแถบ Sources ค้างไว้จากเวอร์ชันก่อน)
local tg = Instance.new("TextButton")
tg.Size = UDim2.new(0, 24, 0, 24)
tg.Position = UDim2.new(1, -80, 0, 4)
tg.BackgroundTransparency = 1
tg.Text = "−"
tg.TextColor3 = Color3.fromRGB(130, 130, 130)
tg.TextSize = 14
tg.Font = Enum.Font.Code
tg.Parent = w

tg.MouseEnter:Connect(function() tg.TextColor3 = Color3.fromRGB(200, 200, 200) end)
tg.MouseLeave:Connect(function() tg.TextColor3 = Color3.fromRGB(130, 130, 130) end)

--// Collapsible Source Panel Group Frame
local panel = Instance.new("Frame")
panel.Size = UDim2.new(1, 0, 0, 140)
panel.Position = UDim2.new(0, 0, 0, 32)
panel.BackgroundTransparency = 1
panel.ClipsDescendants = true
panel.Parent = w

--// Subtitle
local sl = Instance.new("TextLabel")
sl.Size = UDim2.new(1, -24, 0, 14)
sl.Position = UDim2.new(0, 12, 0, 4)
sl.BackgroundTransparency = 1
sl.Text = "SOURCES"
sl.TextColor3 = Color3.fromRGB(100, 100, 100)
sl.TextSize = 9
sl.Font = Enum.Font.Code
sl.TextXAlignment = Enum.TextXAlignment.Left
sl.Parent = panel

--// Options Render Loop
local yo = 22
for _, s in next, opt do
	local rf = Instance.new("Frame")
	rf.Size = UDim2.new(1, -24, 0, 22)
	rf.Position = UDim2.new(0, 12, 0, yo)
	rf.BackgroundTransparency = 1
	rf.Parent = panel

	local tb = Instance.new("TextButton")
	tb.Size = UDim2.new(0, 14, 0, 14)
	tb.Position = UDim2.new(0, 0, 0.5, -7)
	tb.BackgroundColor3 = s.v and Color3.fromRGB(45, 85, 55) or Color3.fromRGB(25, 25, 25)
	tb.BorderSizePixel = 0
	tb.Text = ""
	tb.Parent = rf

	local tbCorner = Instance.new("UICorner", tb)
	tbCorner.CornerRadius = UDim.new(0, 3)
	
	local tbStroke = Instance.new("UIStroke", tb)
	tbStroke.Color = s.v and Color3.fromRGB(60, 120, 75) or Color3.fromRGB(40, 40, 40)
	tbStroke.Thickness = 1

	local lb = Instance.new("TextLabel")
	lb.Size = UDim2.new(1, -24, 1, 0)
	lb.Position = UDim2.new(0, 22, 0, 0)
	lb.BackgroundTransparency = 1
	lb.Text = s.t
	lb.TextColor3 = s.v and Color3.fromRGB(180, 180, 180) or Color3.fromRGB(130, 130, 130)
	lb.TextSize = 11
	lb.Font = Enum.Font.Code
	lb.TextXAlignment = Enum.TextXAlignment.Left
	lb.Parent = rf

	tb.MouseButton1Click:Connect(function()
		s.v = not s.v
		tb.BackgroundColor3 = s.v and Color3.fromRGB(45, 85, 55) or Color3.fromRGB(25, 25, 25)
		tbStroke.Color = s.v and Color3.fromRGB(60, 120, 75) or Color3.fromRGB(40, 40, 40)
		lb.TextColor3 = s.v and Color3.fromRGB(180, 180, 180) or Color3.fromRGB(130, 130, 130)
		if s.v then swept = false end
	end)

	yo = yo + 24
end

--// Action Buttons Setup
local bw = UDim2.new(1/3, -6, 0, 26)
local abFrame = Instance.new("Frame")
abFrame.Size = UDim2.new(1, 0, 0, 26)
abFrame.Position = UDim2.new(0, 0, 0, 180)
abFrame.BackgroundTransparency = 1
abFrame.Parent = w

local function styleActionBtn(text, posX)
	local btn = Instance.new("TextButton")
	btn.Size = bw
	btn.Position = UDim2.new(posX, posX == 0 and 12 or (posX == 1/3 and 3 or -6), 0, 0)
	btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	btn.BorderSizePixel = 0
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(170, 170, 170)
	btn.TextSize = 11
	btn.Font = Enum.Font.Code
	btn.Parent = abFrame

	local bCorner = Instance.new("UICorner", btn)
	bCorner.CornerRadius = UDim.new(0, 4)

	local bStroke = Instance.new("UIStroke", btn)
	bStroke.Color = Color3.fromRGB(40, 40, 40)
	bStroke.Thickness = 1

	btn.MouseEnter:Connect(function() bStroke.Color = Color3.fromRGB(60, 60, 60) btn.TextColor3 = Color3.fromRGB(210, 210, 210) end)
	btn.MouseLeave:Connect(function() bStroke.Color = Color3.fromRGB(40, 40, 40) btn.TextColor3 = Color3.fromRGB(170, 170, 170) end)
	
	return btn, bStroke
end

local sb, sbStroke = styleActionBtn("scan", 0)
local sv, svStroke = styleActionBtn("save", 1/3)
local cl, clStroke = styleActionBtn("clear", 2/3)

--// Scrolling List Frame
local sf = Instance.new("ScrollingFrame")
sf.Size = UDim2.new(1, -24, 1, -218)
sf.Position = UDim2.new(0, 12, 0, 218)
sf.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
sf.BorderSizePixel = 0
sf.ScrollBarThickness = 2
sf.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 45)
sf.CanvasSize = UDim2.new(0, 0, 0, 0)
sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
sf.Parent = w

local sfCorner = Instance.new("UICorner", sf)
sfCorner.CornerRadius = UDim.new(0, 4)

local sfStroke = Instance.new("UIStroke", sf)
sfStroke.Color = Color3.fromRGB(25, 25, 25)
sfStroke.Thickness = 1

Instance.new("UIListLayout", sf).Padding = UDim.new(0, 2)

--// Toggle Sources Animation Logic
local isFolded = false
tg.MouseButton1Click:Connect(function()
	isFolded = not isFolded
	if isFolded then
		tg.Text = "+"
		panel.Visible = false
		abFrame.Position = UDim2.new(0, 0, 0, 40)
		sf.Position = UDim2.new(0, 12, 0, 78)
		sf.Size = UDim2.new(1, -24, 1, -90)
	else
		tg.Text = "−"
		panel.Visible = true
		abFrame.Position = UDim2.new(0, 0, 0, 180)
		sf.Position = UDim2.new(0, 12, 0, 218)
		sf.Size = UDim2.new(1, -24, 1, -230)
	end
end)

--// Full GUI Show / Hide Logic (เปิด-ปิดหน้าต่างหลัก)
mb.MouseButton1Click:Connect(function()
	w.Visible = false
	openBtn.Visible = true
end)

openBtn.MouseButton1Click:Connect(function()
	openBtn.Visible = false
	w.Visible = true
end)

--// Modern Row Element Creator
local function mr(id, nm)
	local u = "https://create.roblox.com/store/asset/" .. id
	local e = Instance.new("Frame")
	e.Size = UDim2.new(1, 0, 0, 30)
	e.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
	e.BorderSizePixel = 0
	e.Parent = sf

	local eCorner = Instance.new("UICorner", e)
	eCorner.CornerRadius = UDim.new(0, 4)

	local d = Instance.new("TextLabel")
	d.Name = "d"
	d.Size = UDim2.new(0, 14, 1, 0)
	d.Position = UDim2.new(0, 8, 0, 0)
	d.BackgroundTransparency = 1
	d.Text = ""
	d.TextColor3 = Color3.fromRGB(85, 185, 105)
	d.TextSize = 10
	d.Font = Enum.Font.Code
	d.Parent = e

	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -66, 1, 0)
	l.Position = UDim2.new(0, 22, 0, 0)
	l.BackgroundTransparency = 1
	l.Text = nm .. " [" .. id .. "]"
	l.TextColor3 = Color3.fromRGB(150, 150, 150)
	l.TextSize = 10
	l.Font = Enum.Font.Code
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextTruncate = Enum.TextTruncate.AtEnd
	l.Parent = e

	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 38, 0, 18)
	b.Position = UDim2.new(1, -44, 0.5, -9)
	b.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
	b.BorderSizePixel = 0
	b.Text = "copy"
	b.TextColor3 = Color3.fromRGB(130, 130, 130)
	b.TextSize = 10
	b.Font = Enum.Font.Code
	b.Parent = e

	local bCorner = Instance.new("UICorner", b)
	bCorner.CornerRadius = UDim.new(0, 3)
	
	local bStroke = Instance.new("UIStroke", b)
	bStroke.Color = Color3.fromRGB(40, 40, 40)
	bStroke.Thickness = 1

	b.MouseButton1Click:Connect(function()
		setclipboard(u)
		b.Text = "ok"
		b.TextColor3 = Color3.fromRGB(85, 185, 105)
		bStroke.Color = Color3.fromRGB(45, 85, 55)
		task.delay(0.8, function()
			if b.Parent then 
				b.Text = "copy" 
				b.TextColor3 = Color3.fromRGB(130, 130, 130)
				bStroke.Color = Color3.fromRGB(40, 40, 40)
			end
		end)
	end)
	return e
end

--// Core Logic Setup
local function ta(obj)
	if not on then return end
	if typeof(obj) ~= "Instance" then return end

	local s, sid
	s, sid = pcall(function() return obj.SoundId end)
	if not s or not sid or sid == "" then return end
	if not string.find(sid, "rbxassetid") then return end

	local num = sid:match("(%d+)")
	if not num or f[num] then return end

	local nm = "Unknown"
	pcall(function() nm = obj.Name end)

	f[num] = {n = nm, o = obj}
	r[num] = mr(num, nm)
	cnt = cnt + 1
	tl.Text = "SOUND SCANNER (" .. cnt .. ")"
end

local function chk(k)
	for _, x in next, opt do
		if x.k == k then return x.v end
	end
end

local function dosweep()
	local i = 0

	if chk("g") and sc then
		local d = game:GetDescendants()
		for j = 1, #d do
			if not sc then return end
			if typeof(d[j]) == "Instance" then
				local ok, is = pcall(d[j].IsA, d[j], "Sound")
				if ok and is then ta(d[j]) end
			end
			i = i + 1
			if i % 300 == 0 then task.wait() end
		end
		d = nil
		task.wait()
	end

	if chk("n") and sc then
		pcall(function()
			local ni = getnilinstances()
			for j = 1, #ni do
				if not sc then return end
				pcall(function()
					if ni[j]:IsA("Sound") then ta(ni[j]) end
				end)
				i = i + 1
				if i % 300 == 0 then task.wait() end
			end
		end)
		task.wait()
	end

	if chk("m") and sc then
		pcall(function()
			local md = getloadedmodules()
			for j = 1, #md do
				if not sc then return end
				pcall(function()
					if md[j]:IsA("ModuleScript") then
						local ch = md[j]:GetDescendants()
						for x = 1, #ch do
							if not sc then return end
							pcall(function()
								if ch[x]:IsA("Sound") then ta(ch[x]) end
							end)
							i = i + 1
							if i % 300 == 0 then task.wait() end
						end
					end
				end)
			end
		end)
		task.wait()
	end

	if chk("a") and sc then
		pcall(function()
			local al = getinstances()
			for j = 1, #al do
				if not sc then return end
				pcall(function()
					if al[j]:IsA("Sound") then ta(al[j]) end
				end)
				i = i + 1
				if i % 300 == 0 then task.wait() end
			end
			al = nil
		end)
		task.wait()
	end

	if chk("c") and sc then
		pcall(function()
			local gc = getgc(true)
			for j = 1, #gc do
				if not sc then return end
				if typeof(gc[j]) == "Instance" then
					pcall(function()
						if gc[j]:IsA("Sound") then ta(gc[j]) end
					end)
				end
				i = i + 1
				if i % 600 == 0 then task.wait() end
			end
			gc = nil
		end)
	end

	if sc then swept = true end
end

local function upd()
	local i = 0
	for k, row in next, r do
		if not sc then break end
		local dt = row:FindFirstChild("d")
		if dt then
			local ok, p = pcall(function() return f[k].o and f[k].o.IsPlaying end)
			dt.Text = (ok and p) and "▶" or ""
		end
		i = i + 1
		if i % 120 == 0 then task.wait() end
	end
end

local onc
onc = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	if not on then return onc(self, ...) end
	if not checkcaller() then
		local m = getnamecallmethod()
		if m == "Play" and typeof(self) == "Instance" then
			pcall(function()
				if self:IsA("Sound") then task.defer(ta, self) end
			end)
		end
	end
	return onc(self, ...)
end))

cn[#cn+1] = game.DescendantAdded:Connect(function(obj)
	if not on then return end
	pcall(function()
		if obj:IsA("Sound") then task.defer(ta, obj) end
	end)
end)

cb.MouseButton1Click:Connect(function()
	on = false
	sc = false
	for _, c in next, cn do
		pcall(function() c:Disconnect() end)
	end
	g:Destroy()
end)

cl.MouseButton1Click:Connect(function()
	for _, row in next, r do
		pcall(function() row:Destroy() end)
	end
	f = {}
	r = {}
	cnt = 0
	swept = false
	tl.Text = "SOUND SCANNER (0)"
end)

sv.MouseButton1Click:Connect(function()
	if cnt == 0 then
		sv.Text = "empty"
		svStroke.Color = Color3.fromRGB(120, 60, 60)
		task.delay(0.8, function() 
			if sv.Parent then 
				sv.Text = "save" 
				svStroke.Color = Color3.fromRGB(40, 40, 40)
			end 
		end)
		return
	end
	local ln = {}
	for num, data in next, f do
		ln[#ln+1] = data.n .. " | https://create.roblox.com/store/asset/" .. num
	end
	table.sort(ln)
	local ok = pcall(function()
		local gn = ms:GetProductInfo(game.PlaceId).Name
		gn = gn:gsub("[^%w%s%-_]",""):gsub("%s+","_")
		makefolder("SoundScanner")
		writefile("SoundScanner/" .. gn .. ".txt", table.concat(ln, "\n"))
	end)
	sv.Text = ok and "saved" or "error"
	svStroke.Color = ok and Color3.fromRGB(45, 85, 55) or Color3.fromRGB(120, 60, 60)
	task.delay(1, function() 
		if sv.Parent then 
			sv.Text = "save" 
			svStroke.Color = Color3.fromRGB(40, 40, 40)
		end 
	end)
end)

sb.MouseButton1Click:Connect(function()
	sc = not sc
	if sc then
		sb.Text = "stop"
		sb.TextColor3 = Color3.fromRGB(240, 110, 110)
		sb.BackgroundColor3 = Color3.fromRGB(35, 20, 20)
		sbStroke.Color = Color3.fromRGB(90, 40, 40)
		print("Scanning for sounds....")
		if not swept then
			task.spawn(dosweep)
		end
	else
		print("Stopped scanning. Found " .. cnt .. " sounds.")
		sb.Text = "scan"
		sb.TextColor3 = Color3.fromRGB(170, 170, 170)
		sb.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		sbStroke.Color = Color3.fromRGB(40, 40, 40)
	end
end)

task.spawn(function()
	while on and g.Parent do
		if sc then upd() end
		task.wait(2.5)
	end
end)
