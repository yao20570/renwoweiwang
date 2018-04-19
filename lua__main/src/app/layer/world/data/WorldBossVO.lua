local WorldBossVO = class("WorldBossVO")
function WorldBossVO:ctor( tData )
	self:update(tData)
end

function WorldBossVO:update( tData )
	self.nNpcId = tData.n	--Integer	BOSS的NPCID
	self.tBossList = {}
	for i=1,#tData.bs do --小boss列表
		local SingleBossVO = require("app.layer.world.data.SingleBossVO")
		table.insert(self.tBossList,SingleBossVO.new(tData.bs[i]))
	end
end

--总兵力
function WorldBossVO:getTotalTroops( )
	local nTroops = 0
	for i=1,#self.tBossList do
		nTroops = nTroops + self.tBossList[i]:getTotalTroops()
	end
	return nTroops
end

--剩余兵力
function WorldBossVO:getCurrTroops( )
	local nTroops = 0
	for i=1,#self.tBossList do
		nTroops = nTroops + self.tBossList[i]:getCurrTroops()
	end
	return nTroops
end

--获取BossList
function WorldBossVO:getBossList( )
	return self.tBossList or {}
end

return WorldBossVO