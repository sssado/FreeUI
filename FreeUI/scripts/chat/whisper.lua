local F, C = unpack(select(2, ...))
if not C.chat.enable then return end
local module = F:GetModule('Chat')

function module:Whisper()
	if not C.chat.whisperAlert then return end

	local f = CreateFrame('Frame')
	local soundFile = 'Interface\\AddOns\\FreeUI\\assets\\sound\\whisper1.ogg'
	local soundFileAlt = 'Interface\\AddOns\\FreeUI\\assets\\sound\\whisper2.ogg'
	local lastSoundTimer = 0

	f:RegisterEvent('CHAT_MSG_WHISPER')
	f:RegisterEvent('CHAT_MSG_BN_WHISPER')
	f:HookScript('OnEvent', function(self, event, msg, ...)
		local currentTime = GetServerTime()
		if currentTime and currentTime - lastSoundTimer > 30 then
			lastSoundTimer = currentTime
			if event == 'CHAT_MSG_WHISPER' then
				PlaySoundFile(soundFile, 'Master')
			elseif event == 'CHAT_MSG_BN_WHISPER' then
				PlaySoundFile(soundFileAlt, 'Master')
			end
		end 
	end)
end