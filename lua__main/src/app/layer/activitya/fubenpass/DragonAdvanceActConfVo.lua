-- DragonAdvanceActConfVo.lua
local DragonAdvanceActConfVo = class("DragonAdvanceActConfVo")

function DragonAdvanceActConfVo:ctor( tData )
	self:update(tData)
end

function DragonAdvanceActConfVo:update( tData )
	if not tData then
		return
	end
	self.nIndex = tData.i or self.nIndex	                	 --Integer	序号
	self.nTarFubenId = tData.cid or self.nTarFubenId	         --Integer	副本id
	self.tAwards = tData.aw or self.tAwards	            		 --List<Pair<Integer,Long>>	奖励
end


return DragonAdvanceActConfVo