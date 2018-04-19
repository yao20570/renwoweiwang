local ArmyVO = class("ArmyVO")

function ArmyVO:ctor( tData )
	self:update(tData)
end

function ArmyVO:update( tData )
	if not tData then
		return
	end
	self.nCountry = tData.c --Integer	国家ID
	self.sHeadIcon = tData.ic --	String	头像
	self.sHeadBorder = tData.ib --	String	头像框
	self.sName = tData.n --String	名字
	self.nLv = tData.lv --	Integer	等级
	self.nTroops = tData.trp --	Long	兵力

	local nGoupId = tData.npcID --Integer npcId
	self.nNpcId = nil
	if nGoupId then
		local tGropNpc = getNpcGropById(nGoupId)
		if tGropNpc and tGropNpc[1] then
			self.nNpcId = tGropNpc[1].sTid
			self.sName = tGropNpc[1].sName
			self.nLv = tGropNpc[1].nLevel
		end
	end
end

function ArmyVO:getCountry(  )
	return self.nCountry
end

function ArmyVO:getNpcId(  )
	return self.nNpcId
end

function ArmyVO:getHeadIcon(  )
	return self.HeadIcon
end

function ArmyVO:getHeadBorder(  )
	return self.sHeadBorder
end

function ArmyVO:getName(  )
	return self.sName or ""
end

function ArmyVO:getLv(  )
	return self.nLv
end

function ArmyVO:getTroops(  )
	return self.nTroops
end

return ArmyVO