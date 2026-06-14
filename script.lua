-- [[
    ================================================================
    TITLE: MINIMAL SOUND SCANNER (CANDYBIBI EDITION) - ID & LINK BUTTONS
    DESCRIPTION: Clean Dark Theme with Dual Copy Buttons (ID Only & Full URL Link)
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

--// Modern Compact Window Frame (ขยายความกว้างเป็น 340 เพื่อรองรับปุ่มคู่ id & link)
local w = Instance.new("Frame")
w.Size = UDim2.new(0, 340, 0, 320)
w.Position = UDim2.new(0.5, -170, 0.5, -160)
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

--// [ปุ่มเปิดตอนซ่อน] Small Open Button 
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 60, 0, 30)
openBtn.Position = UDim2.new(0, 10, 0.5, -15)
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
tl.Size = UDim2.new(1, -65, 0, 32)
tl.Position = UDim2.new(0, 12, 0, 0)
tl.BackgroundTransparency = 1
tl.Text = "SOUND SCANNER by Candybibi (" .. cnt .. ")"
tl.TextColor3 = Color3.fromRGB(230, 230, 230)
tl.TextSize = 10
tl.Font = Enum.Font.Code
tl.TextXAlignment = Enum.TextXAlignment.Left
tl.Parent = w

--// Minimal Close Button (ปุ่มปิด ×)
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

--// [ปุ่มซ่อน GUI] Minimize Button (_)
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

--// Scrolling List Frame
local sf = Instance.new("ScrollingFrame")
sf.Size = UDim2.new(1, -24, 1, -80)
sf.Position = UDim2.new(0, 12, 0, 36)
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

--// Action Buttons Setup (scan / clear)
local abFrame = Instance.new("Frame")
abFrame.Size = UDim2.new(1, -24, 0, 30)
abFrame.Position = UDim2.new(0, 12, 1, -38)
abFrame.BackgroundTransparency = 1
abFrame.Parent = w

local function styleBtn(text, posX)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.5, -4, 1, 0)
	btn.Position = UDim2.new(posX, posX == 0 and 0 or 4, 0, 0)
	btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	btn.BorderSizePixel = 0
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(170, 170, 170)
	btn.TextSize = 11
	btn.Font = Enum.Font.Code
	btn.Parent = abFrame

	local bCorner = Instance.new("UICorner", btn)
	bCorner.CornerRadius = UDim.new(0, 5)

	local bStroke = Instance.new("UIStroke", btn)
	bStroke.Color = Color3.fromRGB(40, 40, 40)
	bStroke.Thickness = 1

	return btn, bStroke
end

local sb, sbStroke = styleBtn("scan", 0)
local cl, clStroke = styleBtn("clear", 0.5)

-- Button Hover Effects
sb.MouseEnter:Connect(function() if not sc then sbStroke.Color = Color3.fromRGB(60, 60, 60) sb.TextColor3 = Color3.fromRGB(210, 210, 210) end end)
sb.MouseLeave:Connect(function() if not sc then sbStroke.Color = Color3.fromRGB(40, 40, 40) sb.TextColor3 = Color3.fromRGB(170, 170, 170) end end)
cl.MouseEnter:Connect(function() clStroke.Color = Color3.fromRGB(60, 60, 60) cl.TextColor3 = Color3.fromRGB(210, 210, 210) end)
cl.MouseLeave:Connect(function() clStroke.Color = Color3.fromRGB(40, 40, 40) cl.TextColor3 = Color3.fromRGB(170, 170, 170) end)

--// Full GUI Show / Hide Logic
mb.MouseButton1Click:Connect(function()
	w.Visible = false
	openBtn.Visible = true
end)

openBtn.MouseButton1Click:Connect(function()
	openBtn.Visible = false
	w.Visible = true
end)

--// Modern Row Element Creator (ปรับปรุงเป็นปุ่มคู่ id และ link)
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
	l.Size = UDim2.new(1, -100, 1, 0) -- ปรับพื้นที่ text ให้สมดุลกับปุ่มที่เพิ่มขึ้นมา
	l.Position = UDim2.new(0, 22, 0, 0)
	l.BackgroundTransparency = 1
	l.Text = nm .. " [" .. id .. "]"
	l.TextColor3 = Color3.fromRGB(150, 150, 150)
	l.TextSize = 10
	l.Font = Enum.Font.Code
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextTruncate = Enum.TextTruncate.AtEnd
	l.Parent = e

	-- ฟังก์ชันช่วยสร้างปุ่มในแถวแบบคุมธีมเดียวกัน
	local function createRowBtn(text, posX)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 36, 0, 18)
		btn.Position = UDim2.new(1, posX, 0.5, -9)
		btn.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
		btn.BorderSizePixel = 0
		btn.Text = text
		btn.TextColor3 = Color3.fromRGB(130, 130, 130)
		btn.TextSize = 9.5
		btn.Font = Enum.Font.Code
		btn.Parent = e

		local bCorner = Instance.new("UICorner", btn)
		bCorner.CornerRadius = UDim.new(0, 3)
		
		local bStroke = Instance.new("UIStroke", btn)
		bStroke.Color = Color3.fromRGB(40, 40, 40)
		bStroke.Thickness = 1

		return btn, bStroke
	end

	-- สร้างปุ่มย่อย id และ link ฝั่งขวาของแถว
	local bId, strokeId = createRowBtn("id", -84)
	local bLink, strokeLink = createRowBtn("link", -42)

	-- กลไกปุ่มคัดลอกเฉพาะเลข ID
	bId.MouseButton1Click:Connect(function()
		setclipboard(id) -- ดึงเฉพาะเลข ID ล้วน ๆ
		bId.Text = "ok"
		bId.TextColor3 = Color3.fromRGB(85, 185, 105)
		strokeId.Color = Color3.fromRGB(45, 85, 55)
		task.delay(0.8, function()
			if bId.Parent then 
				bId.Text = "id" 
				bId.TextColor3 = Color3.fromRGB(130, 130, 130)
				strokeId.Color = Color3.fromRGB(40, 40, 40)
			end
		end)
	end)

	-- กลไกปุ่มคัดลอกเป็น URL ลิงก์เต็มรูปแบบ
	bLink.MouseButton1Click:Connect(function()
		setclipboard(u) -- ดึง URL เต็มรูปแบบ
		bLink.Text = "ok"
		bLink.TextColor3 = Color3.fromRGB(85, 185, 105)
		strokeLink.Color = Color3.fromRGB(45, 85, 55)
		task.delay(0.8, function()
			if bLink.Parent then 
				bLink.Text = "link" 
				bLink.TextColor3 = Color3.fromRGB(130, 130, 130)
				strokeLink.Color = Color3.fromRGB(40, 40, 40)
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
	tl.Text = "SOUND SCANNER by Candybibi (" .. cnt .. ")"
end

local function dosweep()
	local i = 0

	-- Game Descendants
	if sc then
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

	-- Nil Instances
	if sc then
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

	-- Loaded Modules
	if sc then
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
	tl.Text = "SOUND SCANNER by Candybibi (0)"
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