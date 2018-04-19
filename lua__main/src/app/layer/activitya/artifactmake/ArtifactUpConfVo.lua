-- ArtifactUpConfVo.lua
local ArtifactUpConfVo = class("ArtifactUpConfVo")

function ArtifactUpConfVo:ctor( tData )
	self.nPro = 0 		--当前进度
	self:update(tData)
end

function ArtifactUpConfVo:update( tData )
	if not tData then
		return
	end
	self.nIndex = tData.ci or self.nIndex	                	 --Integer	序号
	self.nTargetNum = tData.num or self.nTargetNum	        	 --Integer	目标件数
	self.nTargetLv = tData.target or self.nTargetLv	        	 --Integer	目标等级数
	self.tAwards = tData.aw or self.tAwards	            		 --List<Pair<Integer,Long>>	奖励
	self.nPro = tData.pro or self.nPro	            			 --List<Pair<Integer,Long>>	奖励
end


return ArtifactUpConfVo