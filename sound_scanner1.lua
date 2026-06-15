
local on    = true
local sc    = false
local swept = false
local cnt   = 0
local f     = {}
local r     = {}
local cn    = {}
local hidden = false

-- ── Palette ──────────────────────────────────────────────────────────────────
local C = {
	bg      = Color3.fromRGB(13, 13, 17),
	surface = Color3.fromRGB(20, 20, 27),
	card    = Color3.fromRGB(26, 26, 35),
	border  = Color3.fromRGB(45, 45, 62),
	dim     = Color3.fromRGB(55, 55, 75),
	muted   = Color3.fromRGB(90, 90, 115),
	text    = Color3.fromRGB(185, 185, 205),
	bright  = Color3.fromRGB(220, 220, 235),
	accent  = Color3.fromRGB(100, 210, 145),
	accentD = Color3.fromRGB(30,  60,  42),
	red     = Color3.fromRGB(210, 90,  90),
	redD    = Color3.fromRGB(55,  25,  25),
	play    = Color3.fromRGB(80, 200, 130),
}

-- ── Helpers ───────────────────────────────────────────────────────────────────
local function mk(cls, props)
	local o = Instance.new(cls)
	for k, v in next, props do o[k] = v end
	return o
end

local function corner(parent, rad)
	mk("UICorner", {CornerRadius = UDim.new(0, rad or 5), Parent = parent})
end

local function pad(parent, px)
	mk("UIPadding", {
		PaddingLeft   = UDim.new(0, px),
		PaddingRight  = UDim.new(0, px),
		PaddingTop    = UDim.new(0, px),
		PaddingBottom = UDim.new(0, px),
		Parent        = parent,
	})
end

-- ── Root GUI ──────────────────────────────────────────────────────────────────
local g = mk("ScreenGui", {
	Name            = string.char(math.random(97,122)) .. math.random(10000,99999),
	ResetOnSpawn    = false,
	IgnoreGuiInset  = false,   -- ให้ GUI อยู่ใต้ topbar ของ Roblox
	Parent          = gethui(),
})

for _, x in pairs(gethui():GetChildren()) do
	if x ~= g and x:IsA("ScreenGui") and #x.Name > 4 and x.Name:sub(1,1):match("%l") then
		pcall(function() x:Destroy() end)
	end
end

local W_W, W_H = 310, 380

-- ── Main window ───────────────────────────────────────────────────────────────
local w = mk("Frame", {
	Size             = UDim2.new(0, W_W, 0, W_H),
	Position         = UDim2.new(0, 10, 1, -W_H - 10),  -- มุมล่างซ้าย พ้น topbar
	BackgroundColor3 = C.bg,
	BorderSizePixel  = 0,
	Active           = true,
	Draggable        = true,
	Parent           = g,
})
corner(w, 8)
mk("UIStroke", {Color = C.border, Thickness = 1, Parent = w})

-- accent top line
mk("Frame", {
	Size             = UDim2.new(1, 0, 0, 1),
	BackgroundColor3 = C.accent,
	BackgroundTransparency = 0.5,
	BorderSizePixel  = 0,
	Parent           = w,
})

-- ── Title bar ─────────────────────────────────────────────────────────────────
local titlebar = mk("Frame", {
	Size             = UDim2.new(1, 0, 0, 38),
	BackgroundColor3 = C.surface,
	BorderSizePixel  = 0,
	Parent           = w,
})
corner(titlebar, 8)
-- mask bottom corners
mk("Frame", {
	Size             = UDim2.new(1, 0, 0, 8),
	Position         = UDim2.new(0, 0, 1, -8),
	BackgroundColor3 = C.surface,
	BorderSizePixel  = 0,
	Parent           = titlebar,
})

-- accent dot
local dot = mk("Frame", {
	Size             = UDim2.new(0, 7, 0, 7),
	Position         = UDim2.new(0, 12, 0.5, -3),
	BackgroundColor3 = C.accent,
	BorderSizePixel  = 0,
	Parent           = titlebar,
})
corner(dot, 4)

local tl = mk("TextLabel", {
	Size               = UDim2.new(1, -90, 1, 0),
	Position           = UDim2.new(0, 26, 0, 0),
	BackgroundTransparency = 1,
	Text               = "SOUND SCANNER by Candybibi  -  0",
	TextColor3         = C.bright,
	TextSize           = 11,
	Font               = Enum.Font.GothamBold,
	TextXAlignment     = Enum.TextXAlignment.Left,
	Parent             = titlebar,
})

-- minimize button (-)
local toggle = mk("TextButton", {
	Size             = UDim2.new(0, 28, 0, 26),
	Position         = UDim2.new(1, -64, 0.5, -13),
	BackgroundColor3 = C.card,
	BorderSizePixel  = 0,
	Text             = "-",
	TextColor3       = C.muted,
	TextSize         = 14,
	Font             = Enum.Font.GothamBold,
	Parent           = titlebar,
})
corner(toggle, 5)
toggle.MouseEnter:Connect(function() toggle.BackgroundColor3 = C.accentD; toggle.TextColor3 = C.accent end)
toggle.MouseLeave:Connect(function() toggle.BackgroundColor3 = C.card; toggle.TextColor3 = C.muted end)

-- close button
local cb = mk("TextButton", {
	Size             = UDim2.new(0, 28, 0, 26),
	Position         = UDim2.new(1, -32, 0.5, -13),
	BackgroundColor3 = C.card,
	BorderSizePixel  = 0,
	Text             = "X",
	TextColor3       = C.muted,
	TextSize         = 11,
	Font             = Enum.Font.GothamBold,
	Parent           = titlebar,
})
corner(cb, 5)
cb.MouseEnter:Connect(function() cb.BackgroundColor3 = C.redD; cb.TextColor3 = C.red end)
cb.MouseLeave:Connect(function() cb.BackgroundColor3 = C.card; cb.TextColor3 = C.muted end)

-- ── Body ──────────────────────────────────────────────────────────────────────
local body = mk("Frame", {
	Size             = UDim2.new(1, 0, 1, -38),
	Position         = UDim2.new(0, 0, 0, 38),
	BackgroundTransparency = 1,
	BorderSizePixel  = 0,
	Parent           = w,
})
pad(body, 8)

-- ── Action buttons (only Scan + Save) ────────────────────────────────────────
local btnH = 28
local gap  = 6
local btnW = (W_W - 16 - gap) / 2

local function mkBtn(label, xOff)
	local b = mk("TextButton", {
		Size             = UDim2.new(0, btnW, 0, btnH),
		Position         = UDim2.new(0, xOff, 0, 0),
		BackgroundColor3 = C.card,
		BorderSizePixel  = 0,
		Text             = label,
		TextColor3       = C.text,
		TextSize         = 11,
		Font             = Enum.Font.GothamMedium,
		Parent           = body,
	})
	corner(b, 6)
	mk("UIStroke", {Color = C.border, Thickness = 1, Parent = b})
	return b
end

local sb = mkBtn("SCAN", 0)
local cl = mkBtn("CLEAR", btnW + gap)

-- ── Results list ──────────────────────────────────────────────────────────────
local listY = btnH + 8
local listH = W_H - 38 - 8 - listY

local sf = mk("ScrollingFrame", {
	Size                 = UDim2.new(1, 0, 0, listH),
	Position             = UDim2.new(0, 0, 0, listY),
	BackgroundColor3     = C.surface,
	BorderSizePixel      = 0,
	ScrollBarThickness   = 3,
	ScrollBarImageColor3 = C.dim,
	CanvasSize           = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize  = Enum.AutomaticSize.Y,
	Parent               = body,
})
corner(sf, 6)
mk("UIStroke", {Color = C.border, Thickness = 1, Parent = sf})
mk("UIListLayout", {Padding = UDim.new(0, 2), Parent = sf})
pad(sf, 4)

-- ── Empty state label ─────────────────────────────────────────────────────────
local emptyLbl = mk("TextLabel", {
	Size               = UDim2.new(1, 0, 0, listH),
	Position           = UDim2.new(0, 0, 0, listY),
	BackgroundTransparency = 1,
	Text               = "Press SCAN to find sounds",
	TextColor3         = C.dim,
	TextSize           = 10,
	Font               = Enum.Font.Gotham,
	Parent             = body,
})

-- ── Sound row factory ─────────────────────────────────────────────────────────
local function mr(id, nm)
	local url = "https://create.roblox.com/store/asset/" .. id

	emptyLbl.Visible = false

	local e = mk("Frame", {
		Size             = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = C.card,
		BorderSizePixel  = 0,
		Parent           = sf,
	})
	corner(e, 5)

	-- playing dot
	local d = mk("Frame", {
		Name             = "d",
		Size             = UDim2.new(0, 6, 0, 6),
		Position         = UDim2.new(0, 6, 0.5, -3),
		BackgroundColor3 = C.play,
		BackgroundTransparency = 1,
		BorderSizePixel  = 0,
		Parent           = e,
	})
	corner(d, 3)

	mk("TextLabel", {
		Size               = UDim2.new(1, -62, 1, 0),
		Position           = UDim2.new(0, 17, 0, 0),
		BackgroundTransparency = 1,
		Text               = nm .. "  " .. id,
		TextColor3         = C.text,
		TextSize           = 10,
		Font               = Enum.Font.Gotham,
		TextXAlignment     = Enum.TextXAlignment.Left,
		TextTruncate       = Enum.TextTruncate.AtEnd,
		Parent             = e,
	})

	local b = mk("TextButton", {
		Size             = UDim2.new(0, 42, 0, 22),
		Position         = UDim2.new(1, -46, 0.5, -11),
		BackgroundColor3 = C.surface,
		BorderSizePixel  = 0,
		Text             = "copy",
		TextColor3       = C.muted,
		TextSize         = 10,
		Font             = Enum.Font.GothamMedium,
		Parent           = e,
	})
	corner(b, 4)
	mk("UIStroke", {Color = C.border, Thickness = 1, Parent = b})

	b.MouseButton1Click:Connect(function()
		setclipboard(url)
		b.Text       = "OK"
		b.TextColor3 = C.accent
		task.delay(0.8, function()
			if b.Parent then b.Text = "copy"; b.TextColor3 = C.muted end
		end)
	end)

	return e
end

-- ── Core scan logic ───────────────────────────────────────────────────────────
local function ta(obj)
	if not on then return end
	if typeof(obj) ~= "Instance" then return end
	local s, sid = pcall(function() return obj.SoundId end)
	if not s or not sid or sid == "" then return end
	if not string.find(sid, "rbxassetid") then return end
	local num = sid:match("(%d+)")
	if not num or f[num] then return end
	local nm = "Unknown"
	pcall(function() nm = obj.Name end)

	-- แสดงเฉพาะ BeamMusicSystem เท่านั้น
	if not nm:lower():find("beammusicsystem") then return end

	f[num] = {n = nm, o = obj}
	r[num] = mr(num, nm)
	cnt = cnt + 1
	tl.Text = "SOUND SCANNER by Candybibi  -  " .. cnt
end

-- always scan all sources
local function dosweep()
	local i = 0

	-- game tree
	if sc then
		local d = game:GetDescendants()
		for j = 1, #d do
			if not sc then return end
			if typeof(d[j]) == "Instance" then
				local ok, is = pcall(d[j].IsA, d[j], "Sound")
				if ok and is then ta(d[j]) end
			end
			i += 1; if i % 300 == 0 then task.wait() end
		end
		d = nil; task.wait()
	end

	-- nil instances
	if sc then
		pcall(function()
			local ni = getnilinstances()
			for j = 1, #ni do
				if not sc then return end
				pcall(function() if ni[j]:IsA("Sound") then ta(ni[j]) end end)
				i += 1; if i % 300 == 0 then task.wait() end
			end
		end)
		task.wait()
	end

	-- modules
	if sc then
		pcall(function()
			local md = getloadedmodules()
			for j = 1, #md do
				if not sc then return end
				pcall(function()
					if md[j]:IsA("ModuleScript") then
						for _, ch in ipairs(md[j]:GetDescendants()) do
							if not sc then return end
							pcall(function() if ch:IsA("Sound") then ta(ch) end end)
							i += 1; if i % 300 == 0 then task.wait() end
						end
					end
				end)
			end
		end)
		task.wait()
	end

	-- all instances
	if sc then
		pcall(function()
			local al = getinstances()
			for j = 1, #al do
				if not sc then return end
				pcall(function() if al[j]:IsA("Sound") then ta(al[j]) end end)
				i += 1; if i % 300 == 0 then task.wait() end
			end
			al = nil
		end)
	end

	if sc then swept = true end
end

local function upd()
	local i = 0
	for k, row in next, r do
		if not sc then break end
		local dot = row:FindFirstChild("d")
		if dot then
			local ok, p = pcall(function() return f[k].o and f[k].o.IsPlaying end)
			dot.BackgroundTransparency = (ok and p) and 0 or 1
		end
		i += 1; if i % 120 == 0 then task.wait() end
	end
end

-- ── Hooks ─────────────────────────────────────────────────────────────────────
local onc
onc = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	local args = {...}

	-- ห่อทุกอย่างด้วย pcall เพื่อป้องกัน error ทำให้ call chain ขาด
	if on then
		local ok1, isCaller = pcall(checkcaller)
		if ok1 and not isCaller then
			local ok2, m = pcall(getnamecallmethod)
			if ok2 and m == "Play" then
				local ok3, isSound = pcall(function()
					return typeof(self) == "Instance" and self:IsA("Sound")
				end)
				if ok3 and isSound then
					task.defer(ta, self)
				end
			end
		end
	end

	-- return original เสมอ ไม่มีเงื่อนไข
	return onc(self, table.unpack(args))
end))

cn[#cn+1] = game.DescendantAdded:Connect(function(obj)
	if not on then return end
	pcall(function()
		if obj:IsA("Sound") then task.defer(ta, obj) end
	end)
end)

-- ── Button handlers ───────────────────────────────────────────────────────────
cb.MouseButton1Click:Connect(function()
	on = false; sc = false
	for _, c in next, cn do pcall(function() c:Disconnect() end) end
	g:Destroy()
end)

cl.MouseButton1Click:Connect(function()
	for _, row in next, r do pcall(function() row:Destroy() end) end
	f = {}; r = {}; cnt = 0; swept = false
	emptyLbl.Visible = true
	tl.Text = "SOUND SCANNER by Candybibi  -  0"
end)

sb.MouseButton1Click:Connect(function()
	sc = not sc
	if sc then
		sb.Text             = "STOP"
		sb.BackgroundColor3 = C.redD
		local stroke = sb:FindFirstChildOfClass("UIStroke")
		if stroke then stroke.Color = C.red end
		sb.TextColor3 = C.red
		print("[SoundScanner] Scanning...")
		if not swept then task.spawn(dosweep) end
	else
		print("[SoundScanner] Stopped. Found " .. cnt .. " sounds.")
		sb.Text             = "SCAN"
		sb.BackgroundColor3 = C.card
		sb.TextColor3       = C.text
		local stroke = sb:FindFirstChildOfClass("UIStroke")
		if stroke then stroke.Color = C.border end
	end
end)

-- ── Toggle hide/show ──────────────────────────────────────────────────────────
toggle.MouseButton1Click:Connect(function()
	hidden = not hidden
	body.Visible     = not hidden
	toggle.Text      = hidden and "+" or "-"
	toggle.TextColor3 = hidden and C.accent or C.muted
	toggle.BackgroundColor3 = hidden and C.accentD or C.card
	w.Size = hidden and UDim2.new(0, W_W, 0, 38) or UDim2.new(0, W_W, 0, W_H)
end)

-- ── Update loop ───────────────────────────────────────────────────────────────
task.spawn(function()
	while on and g.Parent do
		if sc then upd() end
		task.wait(2.5)
	end
end)
