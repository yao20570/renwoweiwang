local RangeAwardVO = class("RangeAwardVO")

function RangeAwardVO:ctor( tData )
	self.nStart = 0
	self.nEnd = 0
	self.tAward = nil
	self:update(tData)
end

function RangeAwardVO:update( tData )
	if not tData then
		return
	end
	self.nStart = tData.start or self.nStart --	Integer	起点
	self.nEnd = tData["end"] or self.nEnd --	Integer	终点
	self.tAward = tData.award or self.tAward--	List<Pair<Integer,Long>>	奖励
end

return RangeAwardVO