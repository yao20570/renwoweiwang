local DragonTurnConfVo = class("DragonTurnConfVo")

function DragonTurnConfVo:ctor( tData )
	self.tTurnConfVos = {}
	self:update(tData)
end

function DragonTurnConfVo:update( tData )
	if not tData then
		return
	end

	self.tTurnConfVos = {}
	local TreasureTurnConfVo = require("app.layer.activityb.dragontreasure.TreasureTurnConfVo")
	for i=1, #tData do
		table.insert(self.tTurnConfVos, TreasureTurnConfVo.new(tData[i]))
	end
	table.sort(self.tTurnConfVos, function(a, b)
		return a.nPos < b.nPos
	end)
end


return DragonTurnConfVo