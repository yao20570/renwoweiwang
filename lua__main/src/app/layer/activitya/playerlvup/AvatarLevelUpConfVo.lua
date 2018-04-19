-- AvatarLevelUpConfVo.lua
local AvatarLevelUpConfVo = class("AvatarLevelUpConfVo")

function AvatarLevelUpConfVo:ctor( tData )
	self:update(tData)
end

function AvatarLevelUpConfVo:update( tData )
	if not tData then
		return
	end
	self.nIndex = tData.ci or self.nIndex	                	 --Integer	序号
	self.nTarget = tData.at or self.nTarget	                     --Integer	目标
	self.tAwards = tData.aw or self.tAwards	            		 --List<Pair<Integer,Long>>	奖励
end


return AvatarLevelUpConfVo