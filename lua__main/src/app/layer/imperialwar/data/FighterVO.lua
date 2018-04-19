local FighterVO = class("FighterVO")

function FighterVO:ctor( tData )
	self:update(tData)
end

function FighterVO:update( tData )
	if not tData then
		return
	end
	self.nCountry = tData.c or self.nCountry --	Integer	国家ID
	self.sHeadIcon = tData.ic or self.sHeadIcon --	String	头像
	self.sHeadBorder = tData.ib or self.sHeadBorder --	String	头像框
	self.sName = tData.n or self.sName --	String	名字
	self.nLv = tData.lv or self.nLv --	Integer	等级
	self.nLoseTroops = tData.lp or self.nLoseTroops --	Long	损失的兵力
	self.nOriginTroops = tData.sp or self.nOriginTroops --	Long	原有的兵力
	self.nKilled = tData.k or self.nKilled --	Long	杀敌数
	self.nMerit = tData.p or self.nMerit --	Long	战功
	self.nNpcId = tData.ni or self.nNpcId --npc

	self.tFHero = {}
	if tData.h then --List<FightHeroInfo>
		local FightHeroInfo = require("app.layer.mail.data.FightHeroInfo")
		for i=1,#tData.h do
			table.insert(self.tFHero, FightHeroInfo.new(tData.h[i]))
		end
	end
end

function FighterVO:getCountry(  )
	return self.nCountry
end

function FighterVO:getHeadIcon(  )
	return self.sHeadIcon
end

function FighterVO:getHeadBorder(  )
	return self.sHeadBorder
end

function FighterVO:getName(  )
	if self.nNpcId then
		local tNpcData = groupIdGetFirstMaster(self.nNpcId)
		if tNpcData then
			return tNpcData.sName
		end
	end
	return self.sName
end

function FighterVO:getLv(  )
	return self.nLv
end

function FighterVO:getLoseTroops(  )
	return self.nLoseTroops
end

function FighterVO:getOriginTroops(  )
	return self.nOriginTroops
end

function FighterVO:getKilled(  )
	return self.nKilled
end

function FighterVO:getMerit(  )
	return self.nMerit
end

function FighterVO:getIsMe( )
	return self.sName == Player:getPlayerInfo().sName
end

function FighterVO:getFHero(  )
	return self.tFHero
end

function FighterVO:getNpcId(  )
	return self.nNpcId
end

return FighterVO