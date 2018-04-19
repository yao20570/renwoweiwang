-- EquipTrainActConfVo.lua
local EquipTrainActConfVo = class("EquipTrainActConfVo")

function EquipTrainActConfVo:ctor( tData )
	self:update(tData)
end

function EquipTrainActConfVo:update( tData )
	if not tData then
		return
	end
	self.nIndex = tData.i or self.nIndex	                	 --Integer	序号
	self.nTarTimes = tData.tar or self.nTarTimes	        	 --Integer	目标次数
	self.tAwards = tData.aw or self.tAwards	            		 --List<Pair<Integer,Long>>	奖励
end


return EquipTrainActConfVo