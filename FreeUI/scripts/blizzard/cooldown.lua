local F, C, L = unpack(select(2, ...))
local BLIZZARD = F:GetModule('Blizzard')

local MIN_DURATION = 2.5                    -- the minimum duration to show cooldown text for
local MIN_SCALE = 0.5                       -- the minimum scale we want to show cooldown counts at, anything below this will be hidden
local ICON_SIZE = 36
local hideNumbers, active, hooked = {}, {}, {}
local pairs, floor, strfind = pairs, math.floor, string.find
local GetTime, GetActionCooldown = GetTime, GetActionCooldown

function BLIZZARD:StopTimer()
	self.enabled = nil
	self:Hide()
end

function BLIZZARD:ForceUpdate()
	self.nextUpdate = 0
	self:Show()
end

function BLIZZARD:OnSizeChanged(width)
	local fontScale = floor(width + 0.5) / ICON_SIZE
	if fontScale == self.fontScale then return end
	self.fontScale = fontScale

	if fontScale < MIN_SCALE then
		self:Hide()
	else
		self.text:SetFont('Interface\\AddOns\\FreeUI\\assets\\font\\supereffective.ttf', 16, 'OUTLINEMONOCHROME')
		self.text:SetShadowColor(0, 0, 0, 0)

		if self.enabled then
			BLIZZARD.ForceUpdate(self)
		end
	end
end

function BLIZZARD:TimerOnUpdate(elapsed)
	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
	else
		local remain = self.duration - (GetTime() - self.start)
		if remain > 0 then
			local getTime, nextUpdate = F.FormatTime(remain)
			self.text:SetText(getTime)
			self.nextUpdate = nextUpdate
		else
			BLIZZARD.StopTimer(self)
		end
	end
end

function BLIZZARD:OnCreate()
	local scaler = CreateFrame("Frame", nil, self)
	scaler:SetAllPoints(self)

	local timer = CreateFrame("Frame", nil, scaler)
	timer:Hide()
	timer:SetAllPoints(scaler)
	timer:SetScript("OnUpdate", BLIZZARD.TimerOnUpdate)

	local text = timer:CreateFontString(nil, "BACKGROUND")
	text:SetPoint("CENTER", 2, 0)
	text:SetJustifyH("CENTER")
	timer.text = text

	BLIZZARD.OnSizeChanged(timer, scaler:GetSize())
	scaler:SetScript("OnSizeChanged", function(_, ...)
		BLIZZARD.OnSizeChanged(timer, ...)
	end)

	self.timer = timer
	return timer
end

function BLIZZARD:StartTimer(start, duration)
	if self:IsForbidden() then return end
	if self.noOCC or hideNumbers[self] then return end

	local frameName = self.GetName and self:GetName() or ""
	if C.general.cooldown_overrideWA and strfind(frameName, "WeakAuras") then
		self.noOCC = true
		return
	end

	if start > 0 and duration > MIN_DURATION then
		local timer = self.timer or BLIZZARD.OnCreate(self)
		timer.start = start
		timer.duration = duration
		timer.enabled = true
		timer.nextUpdate = 0

		-- wait for blizz to fix itself
		local parent = self:GetParent()
		local charge = parent and parent.chargeCooldown
		local chargeTimer = charge and charge.timer
		if chargeTimer and chargeTimer ~= timer then
			BLIZZARD.StopTimer(chargeTimer)
		end

		if timer.fontScale >= MIN_SCALE then
			timer:Show()
		end
	elseif self.timer then
		BLIZZARD.StopTimer(self.timer)
	end

	-- hide cooldown flash if barFader enabled
	if self:GetParent().__faderParent then
		if self:GetEffectiveAlpha() > 0 then
			self:Show()
		else
			self:Hide()
		end
	end
end

function BLIZZARD:HideCooldownNumbers()
	hideNumbers[self] = true
	if self.timer then BLIZZARD.StopTimer(self.timer) end
end

function BLIZZARD:CooldownOnShow()
	active[self] = true
end

function BLIZZARD:CooldownOnHide()
	active[self] = nil
end

local function shouldUpdateTimer(self, start)
	local timer = self.timer
	if not timer then
		return true
	end
	return timer.start ~= start
end

function BLIZZARD:CooldownUpdate()
	local button = self:GetParent()
	local start, duration = GetActionCooldown(button.action)

	if shouldUpdateTimer(self, start) then
		BLIZZARD.StartTimer(self, start, duration)
	end
end

function BLIZZARD:ActionbarUpateCooldown()
	for cooldown in pairs(active) do
		BLIZZARD.CooldownUpdate(cooldown)
	end
end

function BLIZZARD:RegisterActionButton()
	local cooldown = self.cooldown
	if not hooked[cooldown] then
		cooldown:HookScript("OnShow", BLIZZARD.CooldownOnShow)
		cooldown:HookScript("OnHide", BLIZZARD.CooldownOnHide)

		hooked[cooldown] = true
	end
end

function BLIZZARD:ReskinCooldown()
	if not C.general.cooldown then return end

	local cooldownIndex = getmetatable(ActionButton1Cooldown).__index
	hooksecurefunc(cooldownIndex, "SetCooldown", BLIZZARD.StartTimer)

	hooksecurefunc("CooldownFrame_SetDisplayAsPercentage", BLIZZARD.HideCooldownNumbers)

	F:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN", BLIZZARD.ActionbarUpateCooldown)

	if _G["ActionBarButtonEventsFrame"].frames then
		for _, frame in pairs(_G["ActionBarButtonEventsFrame"].frames) do
			BLIZZARD.RegisterActionButton(frame)
		end
	end
	hooksecurefunc("ActionBarButtonEventsFrame_RegisterFrame", BLIZZARD.RegisterActionButton)

	-- Hide Default Cooldown
	SetCVar("countdownForCooldowns", 0)
	F.HideOption(InterfaceOptionsActionBarsPanelCountdownCooldowns)
end
