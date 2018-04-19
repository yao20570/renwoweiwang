local SingleBossVO = class("SingleBossVO")
function SingleBossVO:ctor( tData )
	self:update(tData)
end

function SingleBossVO:update( tData )
	self.nNpcId =  tData.i	--Integer	NPC_ID
	self.nTroops = tData.t	-- Integer	当前带兵量
end

function SingleBossVO:getTotalTroops( )
	local nTroops = 0
	if self.nNpcId then
		local tNpcData = getNPCData(self.nNpcId)
		if tNpcData then
			nTroops = tNpcData.nTroops or 0
		end
	end
	return nTroops
end

function SingleBossVO:getCurrTroops( )
	return self.nTroops or 0
end

function SingleBossVO:getIsKilled( )
	return self.nTroops == 0
end

return SingleBossVO
