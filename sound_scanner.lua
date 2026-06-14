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
	{k="g", t="game tree",        v=true},
	{k="n", t="nil instances",    v=true},
	{k="m", t="modules",          v=true},
	{k="c", t="garbage collector",v=false},
	{k="a", t="all instances",    v=false},
}

-- ── Palette ─────────────────────────────────────────────────────────────────
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

-- ── Helpers ──────────────────────────────────────────────────────────────────
local function mk(cls, props)
	local o = Instance.new(cls)
	for k, v in next, props do o[k] = v end
	return o
end

local function corner(parent, r)
	mk("UICorner", {CornerRadius=UDim.new(0, r or 5), Parent=parent})
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

-- ── Root GUI ─────────────────────────────────────────────────────────────────
local g = mk("ScreenGui", {
	Name          = string.char(math.random(97,122)) .. math.random(10000,99999),
	ResetOnSpawn  = false,
	Parent        = gethui(),
})

-- clean old instances
for _, x in pairs(gethui():GetChildren()) do
	if x ~= g and x:IsA("ScreenGui") and #x.Name > 4 and x.Name:sub(1,1):match("%l") then
		pcall(function() x:Destroy() end)
	end
end

-- ── Window ───────────────────────────────────────────────────────────────────
local W_W, W_H = 310, 430
local w = mk("Frame", {
	Size             = UDim2.new(0, W_W, 0, W_H),
	Position         = UDim2.new(0.5, -W_W/2, 0.5, -W_H/2),
	BackgroundColor3 = C.bg,
	BorderSizePixel  = 0,
	Active           = true,
	Draggable        = true,
	Parent           = g,
})
corner(w, 8)
mk("UIStroke", {Color=C.border, Thickness=1, Parent=w})

-- subtle inner glow at top
local glow = mk("Frame", {
	Size             = UDim2.new(1, 0, 0, 1),
	BackgroundColor3 = C.accent,
	BackgroundTransparency = 0.6,
	BorderSizePixel  = 0,
	Parent           = w,
})

-- ── Title bar ────────────────────────────────────────────────────────────────
local titlebar = mk("Frame", {
	Size             = UDim2.new(1, 0, 0, 36),
	BackgroundColor3 = C.surface,
	BorderSizePixel  = 0,
	Parent           = w,
})
corner(titlebar, 8)
-- mask bottom corners of titlebar
mk("Frame", {
	Size             = UDim2.new(1, 0, 0, 8),
	Position         = UDim2.new(0, 0, 1, -8),
	BackgroundColor3 = C.surface,
	BorderSizePixel  = 0,
	Parent           = titlebar,
})

-- dot accent
mk("Frame", {
	Size             = UDim2.new(0, 6, 0, 6),
	Position         = UDim2.new(0, 12, 0.5, -3),
	BackgroundColor3 = C.accent,
	BorderSizePixel  = 0,
	Parent           = titlebar,
}); do
	local dp = titlebar:FindFirstChildOfClass("Frame")
	if dp then corner(dp, 3) end
end

local tl = mk("TextLabel", {
	Size                = UDim2.new(1, -60, 1, 0),
	Position            = UDim2.new(0, 26, 0, 0),
	BackgroundTransparency = 1,
	Text                = "Sound Scanner  ·  0",
	TextColor3          = C.bright,
	TextSize            = 12,
	Font                = Enum.Font.GothamMedium,
	TextXAlignment      = Enum.TextXAlignment.Left,
	Parent              = titlebar,
})

local cb = mk("TextButton", {
	Size                = UDim2.new(0, 28, 0, 28),
	Position            = UDim2.new(1, -32, 0.5, -14),
	BackgroundColor3    = C.card,
	BorderSizePixel     = 0,
	Text                = "✕",
	TextColor3          = C.muted,
	TextSize            = 11,
	Font                = Enum.Font.GothamBold,
	Parent              = titlebar,
})
corner(cb, 5)

-- hover effect on close button
cb.MouseEnter:Connect(function()
	cb.BackgroundColor3 = C.redD
	cb.TextColor3 = C.red
end)
cb.MouseLeave:Connect(function()
	cb.BackgroundColor3 = C.card
	cb.TextColor3 = C.muted
end)

-- ── Sources section ───────────────────────────────────────────────────────────
local body = mk("Frame", {
	Size             = UDim2.new(1, 0, 1, -36),
	Position         = UDim2.new(0, 0, 0, 36),
	BackgroundTransparency = 1,
	BorderSizePixel  = 0,
	Parent           = w,
})
pad(body, 8)

local srcLabel = mk("TextLabel", {
	Size                = UDim2.new(1, 0, 0, 14),
	BackgroundTransparency = 1,
	Text                = "SOURCES",
	TextColor3          = C.dim,
	TextSize            = 9,
	Font                = Enum.Font.GothamBold,
	TextXAlignment      = Enum.TextXAlignment.Left,
	LayoutOrder         = 1,
	Parent              = body,
})

local yo = 18
for _, s in next, opt do
	local rf = mk("Frame", {
		Size             = UDim2.new(1, 0, 0, 24),
		Position         = UDim2.new(0, 0, 0, yo),
		BackgroundColor3 = s.v and C.accentD or C.card,
		BorderSizePixel  = 0,
		Parent           = body,
	})
	corner(rf, 4)

	-- checkbox
	local tb = mk("TextButton", {
		Size             = UDim2.new(0, 14, 0, 14),
		Position         = UDim2.new(0, 6, 0.5, -7),
		BackgroundColor3 = s.v and C.accent or C.dim,
		BorderSizePixel  = 0,
		Text             = s.v and "✓" or "",
		TextColor3       = C.bg,
		TextSize         = 9,
		Font             = Enum.Font.GothamBold,
		Parent           = rf,
	})
	corner(tb, 3)

	mk("TextLabel", {
		Size                = UDim2.new(1, -30, 1, 0),
		Position            = UDim2.new(0, 26, 0, 0),
		BackgroundTransparency = 1,
		Text                = s.t,
		TextColor3          = s.v and C.text or C.muted,
		TextSize            = 10,
		Font                = Enum.Font.Gotham,
		TextXAlignment      = Enum.TextXAlignment.Left,
		Parent              = rf,
	})

	local lbl = rf:FindFirstChildOfClass("TextLabel")

	tb.MouseButton1Click:Connect(function()
		s.v = not s.v
		tb.Text             = s.v and "✓" or ""
		tb.BackgroundColor3 = s.v and C.accent or C.dim
		rf.BackgroundColor3 = s.v and C.accentD or C.card
		if lbl then lbl.TextColor3 = s.v and C.text or C.muted end
		if s.v then swept = false end
	end)

	yo = yo + 27
end

-- ── Divider ───────────────────────────────────────────────────────────────────
local divY = yo + 6
mk("Frame", {
	Size             = UDim2.new(1, 0, 0, 1),
	Position         = UDim2.new(0, 0, 0, divY),
	BackgroundColor3 = C.border,
	BorderSizePixel  = 0,
	Parent           = body,
})

-- ── Action buttons ────────────────────────────────────────────────────────────
local btnY  = divY + 9
local btnH  = 26
local gap   = 5
local btnW  = (W_W - 16 - gap*2) / 3

local function mkBtn(label, xOff, color)
	local b = mk("TextButton", {
		Size             = UDim2.new(0, btnW, 0, btnH),
		Position         = UDim2.new(0, xOff, 0, btnY),
		BackgroundColor3 = color or C.card,
		BorderSizePixel  = 0,
		Text             = label,
		TextColor3       = C.text,
		TextSize         = 11,
		Font             = Enum.Font.GothamMedium,
		Parent           = body,
	})
	corner(b, 5)
	mk("UIStroke", {Color=C.border, Thickness=1, Parent=b})
	return b
end

local sb = mkBtn("⟳  scan", 0)
local sv = mkBtn("↓  save", btnW + gap)
local cl = mkBtn("✕  clear", (btnW + gap) * 2)

-- ── Results list ──────────────────────────────────────────────────────────────
local listY  = btnY + btnH + 8
local listH  = W_H - 36 - 8 - listY   -- remaining space

local sf = mk("ScrollingFrame", {
	Size                = UDim2.new(1, 0, 0, listH),
	Position            = UDim2.new(0, 0, 0, listY),
	BackgroundColor3    = C.surface,
	BorderSizePixel     = 0,
	ScrollBarThickness  = 3,
	ScrollBarImageColor3 = C.dim,
	CanvasSize          = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	Parent              = body,
})
corner(sf, 5)
mk("UIStroke", {Color=C.border, Thickness=1, Parent=sf})

local ll = mk("UIListLayout", {
	Padding        = UDim.new(0, 1),
	Parent         = sf,
})
pad(sf, 4)

-- ── Sound row factory ─────────────────────────────────────────────────────────
local function mr(id, nm)
	local url = "https://create.roblox.com/store/asset/" .. id

	local e = mk("Frame", {
		Size             = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = C.card,
		BorderSizePixel  = 0,
		Parent           = sf,
	})
	corner(e, 4)

	-- playing indicator dot
	local d = mk("Frame", {
		Name             = "d",
		Size             = UDim2.new(0, 6, 0, 6),
		Position         = UDim2.new(0, 5, 0.5, -3),
		BackgroundColor3 = C.play,
		BackgroundTransparency = 1,
		BorderSizePixel  = 0,
		Parent           = e,
	})
	corner(d, 3)

	mk("TextLabel", {
		Size                = UDim2.new(1, -60, 1, 0),
		Position            = UDim2.new(0, 16, 0, 0),
		BackgroundTransparency = 1,
		Text                = nm .. "  " .. id,
		TextColor3          = C.text,
		TextSize            = 10,
		Font                = Enum.Font.Gotham,
		TextXAlignment      = Enum.TextXAlignment.Left,
		TextTruncate        = Enum.TextTruncate.AtEnd,
		Parent              = e,
	})

	local b = mk("TextButton", {
		Size             = UDim2.new(0, 40, 0, 20),
		Position         = UDim2.new(1, -44, 0.5, -10),
		BackgroundColor3 = C.surface,
		BorderSizePixel  = 0,
		Text             = "copy",
		TextColor3       = C.muted,
		TextSize         = 10,
		Font             = Enum.Font.GothamMedium,
		Parent           = e,
	})
	corner(b, 4)
	mk("UIStroke", {Color=C.border, Thickness=1, Parent=b})

	b.MouseButton1Click:Connect(function()
		setclipboard(url)
		b.Text      = "✓"
		b.TextColor3 = C.accent
		task.delay(0.8, function()
			if b.Parent then
				b.Text       = "copy"
				b.TextColor3 = C.muted
			end
		end)
	end)

	return e
end

-- ── Core logic (unchanged) ────────────────────────────────────────────────────
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
	f[num] = {n=nm, o=obj}
	r[num] = mr(num, nm)
	cnt = cnt + 1
	tl.Text = "Sound Scanner  ·  " .. cnt
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
			i += 1; if i % 300 == 0 then task.wait() end
		end
		d = nil; task.wait()
	end
	if chk("n") and sc then
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
	if chk("m") and sc then
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
	if chk("a") and sc then
		pcall(function()
			local al = getinstances()
			for j = 1, #al do
				if not sc then return end
				pcall(function() if al[j]:IsA("Sound") then ta(al[j]) end end)
				i += 1; if i % 300 == 0 then task.wait() end
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
					pcall(function() if gc[j]:IsA("Sound") then ta(gc[j]) end end)
				end
				i += 1; if i % 600 == 0 then task.wait() end
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
		local dot = row:FindFirstChild("d")
		if dot then
			local ok, p = pcall(function() return f[k].o and f[k].o.IsPlaying end)
			dot.BackgroundTransparency = (ok and p) and 0 or 1
		end
		i += 1; if i % 120 == 0 then task.wait() end
	end
end

-- ── Hooks & connections ───────────────────────────────────────────────────────
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

-- ── Button handlers ───────────────────────────────────────────────────────────
cb.MouseButton1Click:Connect(function()
	on = false; sc = false
	for _, c in next, cn do pcall(function() c:Disconnect() end) end
	g:Destroy()
end)

cl.MouseButton1Click:Connect(function()
	for _, row in next, r do pcall(function() row:Destroy() end) end
	f = {}; r = {}; cnt = 0; swept = false
	tl.Text = "Sound Scanner  ·  0"
end)

sv.MouseButton1Click:Connect(function()
	if cnt == 0 then
		sv.Text = "empty"; task.delay(0.8, function() if sv.Parent then sv.Text = "↓  save" end end)
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
	sv.Text = ok and "✓ saved" or "error"
	task.delay(1, function() if sv.Parent then sv.Text = "↓  save" end end)
end)

sb.MouseButton1Click:Connect(function()
	sc = not sc
	if sc then
		sb.Text             = "■  stop"
		sb.BackgroundColor3 = C.redD
		mk("UIStroke", {Color=C.red, Thickness=1, Parent=sb})
		print("[SoundScanner] Scanning...")
		if not swept then task.spawn(dosweep) end
	else
		print("[SoundScanner] Stopped. Found " .. cnt .. " sounds.")
		sb.Text             = "⟳  scan"
		sb.BackgroundColor3 = C.card
		local s = sb:FindFirstChildOfClass("UIStroke")
		if s then s.Color = C.border end
	end
end)

-- ── Update loop ───────────────────────────────────────────────────────────────
task.spawn(function()
	while on and g.Parent do
		if sc then upd() end
		task.wait(2.5)
	end
end)
