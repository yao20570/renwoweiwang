local BossRankVo = class("BossRankVo")

function BossRankVo:ctor( tData )
	self.nHarm = 0
	self.nHitNum = 0
	self:update(tData)
end

function BossRankVo:update( tData )
	if not tData then
		return
	end
	self.nPlayerId = tData.i or self.nPlayerId --Id
	self.sName = tData.n or self.sName --String	玩家名字
	self.nCountry = tData.c or self.nCountry --	Integer	玩家国家
	self.nHarm = tData.h or self.nHarm --	Long	伤害数值
	self.nHitNum = tData.f or self.nHitNum --	Integer	攻击次数
end

function BossRankVo:getPlayerId(  )
	return self.nPlayerId
end

function BossRankVo:getName(  )
	return self.sName
end

function BossRankVo:getCountry(  )
	return self.nCountry
end

function BossRankVo:getHarm( )
	return self.nHarm
end

function BossRankVo:getHitNum(  )
	return self.nHitNum
end


return BossRankVo