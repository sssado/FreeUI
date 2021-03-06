local F, C, L = unpack(select(2, ...))
local THEME = F:GetModule('Theme')
local TOOLTIP = F:GetModule("Tooltip")

local strfind, strmatch, gsub = string.find, string.match, string.gsub

function THEME:ReskinDBM()
	local RaidNotice_AddMessage_ = RaidNotice_AddMessage
	RaidNotice_AddMessage = function(noticeFrame, textString, colorInfo)
		if strfind(textString, '|T') then
            if strmatch(textString, ':(%d+):(%d+)') then
                local size1, size2 = strmatch(textString, ':(%d+):(%d+)')
                size1, size2 = size1 + 4, size2 + 4
                textString = gsub(textString,':(%d+):(%d+)',':'..size1..':'..size2..':0:0:64:64:5:59:5:59')
            elseif strmatch(textString, ':(%d+)|t') then
                local size = strmatch(textString, ':(%d+)|t')
                size = size + 4
                textString = gsub(textString,':(%d+)|t',':'..size..':'..size..':0:0:64:64:5:59:5:59|t')
            end
		end
		return RaidNotice_AddMessage_(noticeFrame, textString, colorInfo)
	end

	if not IsAddOnLoaded('DBM-Core') then return end
	if not C.appearance.reskinDBM then return end

	local buttonsize = 24
	local function SkinBars(self)
		for bar in self:GetBarIterator() do
			if not bar.injected then
				local frame		= bar.frame
				local tbar		= _G[frame:GetName()..'Bar']
				local spark		= _G[frame:GetName()..'BarSpark']
				local texture	= _G[frame:GetName()..'BarTexture']
				local icon1		= _G[frame:GetName()..'BarIcon1']
				local icon2		= _G[frame:GetName()..'BarIcon2']
				local name		= _G[frame:GetName()..'BarName']
				local timer		= _G[frame:GetName()..'BarTimer']

				if not (icon1.overlay) then
					icon1.overlay = CreateFrame('Frame', '$parentIcon1Overlay', tbar)
					icon1.overlay:SetSize(buttonsize+2, buttonsize+2)
					icon1.overlay:SetFrameStrata('BACKGROUND')
					icon1.overlay:SetPoint('BOTTOMRIGHT', tbar, 'BOTTOMLEFT', -buttonsize/6, -3)

					local backdroptex = icon1.overlay:CreateTexture(nil, 'BORDER')
					backdroptex:SetTexture([=[Interface\Icons\Spell_Nature_WispSplode]=])
					backdroptex:SetPoint('TOPLEFT', icon1.overlay, 'TOPLEFT', 1, -1)
					backdroptex:SetPoint('BOTTOMRIGHT', icon1.overlay, 'BOTTOMRIGHT', -1, 1)
					backdroptex:SetTexCoord(unpack(C.TexCoord))

					F.CreateSD(icon1.overlay)
				end

				if not (icon2.overlay) then
					icon2.overlay = CreateFrame('Frame', '$parentIcon2Overlay', tbar)
					icon2.overlay:SetSize(buttonsize+2, buttonsize+2)
					icon2.overlay:SetPoint('BOTTOMLEFT', tbar, 'BOTTOMRIGHT', buttonsize/6, -3)

					local backdroptex = icon2.overlay:CreateTexture(nil, 'BORDER')
					backdroptex:SetTexture([=[Interface\Icons\Spell_Nature_WispSplode]=])
					backdroptex:SetPoint('TOPLEFT', icon2.overlay, 'TOPLEFT', 1, -1)
					backdroptex:SetPoint('BOTTOMRIGHT', icon2.overlay, 'BOTTOMRIGHT', -1, 1)
					backdroptex:SetTexCoord(unpack(C.TexCoord))

					F.CreateSD(icon2.overlay)
				end

				if bar.color then
					tbar:SetStatusBarColor(bar.color.r, bar.color.g, bar.color.b)
				else
					tbar:SetStatusBarColor(bar.owner.options.StartColorR, bar.owner.options.StartColorG, bar.owner.options.StartColorB)
				end

				if bar.enlarged then frame:SetWidth(bar.owner.options.HugeWidth) else frame:SetWidth(bar.owner.options.Width) end
				if bar.enlarged then tbar:SetWidth(bar.owner.options.HugeWidth) else tbar:SetWidth(bar.owner.options.Width) end

				if not frame.styled then
					frame:SetScale(1)
					frame.SetScale = F.Dummy
					frame:SetHeight(buttonsize/2)
					frame.SetHeight = F.Dummy
					if not frame.bg then
						frame.bg = CreateFrame('Frame', nil, frame)
						frame.bg:SetAllPoints()
					end
					F.CreateSD(frame.bg)
					F.CreateBDFrame(frame.bg)
					frame.styled = true
				end

				if not spark.killed then
					spark:SetAlpha(0)
					spark:SetTexture(nil)
					spark.killed = true
				end

				if not icon1.styled then
					icon1:SetTexCoord(unpack(C.TexCoord))
					icon1:ClearAllPoints()
					icon1:SetPoint('TOPLEFT', icon1.overlay, 1, -1)
					icon1:SetPoint('BOTTOMRIGHT', icon1.overlay, -1, 1)
					icon1.SetSize = F.Dummy
					icon1.styled = true
				end
		
				if not icon2.styled then
					icon2:SetTexCoord(unpack(C.TexCoord))
					icon2:ClearAllPoints()
					icon2:SetPoint('TOPLEFT', icon2.overlay, 1, -1)
					icon2:SetPoint('BOTTOMRIGHT', icon2.overlay, -1, 1)
					icon2.SetSize = F.Dummy
					icon2.styled = true
				end

				if not texture.styled then
					texture:SetTexture(C.media.sbTex)
					texture.styled = true
				end

				tbar:SetStatusBarTexture(C.media.sbTex)

				if not tbar.styled then
					tbar:SetPoint('TOPLEFT', frame, 'TOPLEFT', 2, -2)
					tbar:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -2, 2)
					tbar.SetPoint = F.Dummy
					tbar.styled = true

					tbar.Spark = tbar:CreateTexture(nil, 'OVERLAY')
					tbar.Spark:SetTexture('Interface\\CastingBar\\UI-CastingBar-Spark')
					tbar.Spark:SetBlendMode('ADD')
					tbar.Spark:SetAlpha(.8)
					tbar.Spark:SetPoint('TOPLEFT', tbar:GetStatusBarTexture(), 'TOPRIGHT', -10, 10)
					tbar.Spark:SetPoint('BOTTOMRIGHT', tbar:GetStatusBarTexture(), 'BOTTOMRIGHT', 10, -10)
				end

				if not name.styled then
					name:ClearAllPoints()
					name:SetPoint('LEFT', frame, 'LEFT', 2, 8)
					name:SetPoint('RIGHT', frame, 'LEFT', tbar:GetWidth()*.85, 8)
					name.SetPoint = F.Dummy
					
					if C.Client == 'zhCN' or C.Client == 'zhTW' then
						name:SetFont(C.font.normal, 12)
						name:SetShadowColor(0, 0, 0, 1)
						name:SetShadowOffset(2, -2)
					else
						F.SetFS(name)
						name:SetShadowColor(0, 0, 0, 1)
						name:SetShadowOffset(1, -1)
					end

					name.SetFont = F.Dummy
					name:SetJustifyH('LEFT')
					name:SetWordWrap(false)
					
					name.styled = true
				end
		
				if not timer.styled then	
					timer:ClearAllPoints()
					timer:SetPoint('RIGHT', frame, 'RIGHT', -2, 8)
					timer.SetPoint = F.Dummy
					F.SetFS(timer)
					timer.SetFont = F.Dummy
					timer:SetJustifyH('RIGHT')

					timer.styled = true
				end

				if bar.owner.options.IconLeft then icon1:Show() icon1.overlay:Show() else icon1:Hide() icon1.overlay:Hide() end
				if bar.owner.options.IconRight then icon2:Show() icon2.overlay:Show() else icon2:Hide() icon2.overlay:Hide() end
				
				tbar:SetAlpha(1)
				frame:SetAlpha(1)
				texture:SetAlpha(1)
				frame:Show()
				bar:Update(0)
				bar.injected = true
			end
		end
	end
	hooksecurefunc(DBT, 'CreateBar', SkinBars)

	local function SkinRange()
		if DBMRangeCheckRadar and not DBMRangeCheckRadar.styled then
			TOOLTIP.ReskinTooltip(DBMRangeCheckRadar)
			DBMRangeCheckRadar.styled = true
		end

		if DBMRangeCheck and not DBMRangeCheck.styled then
			TOOLTIP.ReskinTooltip(DBMRangeCheck)
			DBMRangeCheck.styled = true
		end
	end
	hooksecurefunc(DBM.RangeCheck, 'Show', SkinRange)

	if DBM.InfoFrame then
		DBM.InfoFrame:Show(5, 'test')
		DBM.InfoFrame:Hide()
		DBMInfoFrame:HookScript('OnShow', TOOLTIP.ReskinTooltip)
	end


	-- Force Settings
	if not DBM_AllSavedOptions['Default'] then DBM_AllSavedOptions['Default'] = {} end
	DBM_AllSavedOptions['Default']['BlockVersionUpdateNotice'] = true
	if IsAddOnLoaded('DBM-VPYike') then
		DBM_AllSavedOptions['Default']['CountdownVoice'] = 'VP:Yike'
		DBM_AllSavedOptions['Default']['ChosenVoicePack'] = 'Yike'
	end
end

