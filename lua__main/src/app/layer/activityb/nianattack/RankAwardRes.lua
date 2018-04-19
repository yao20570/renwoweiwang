local RankAwardRes = class("RankAwardRes")

function RankAwardRes:ctor( tData )
	self.nStage = 0
	self:update(tData)
end

function RankAwardRes:update( tData )
	if not tData then
		return
	end

	self.nStage = tData.stage or self.nStage --阶段
	self.tLv = tData.lvl or self.tLv --排名范围
	self.tAward = tData.award or self.tAward --奖励
end

return RankAwardRes