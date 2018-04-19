local TurnFruitVo = class("TurnFruitVo")

function TurnFruitVo:ctor( tData )
	self.nIndex = 0
	self:update(tData)
end

function TurnFruitVo:update( tData )
	if not tData then
		return
	end
	self.nIndex = tData.l or self.nIndex --	Integer	转动到的位置
	self.tOb    = tData.o	--Pair<Integer,Long>	获得物品奖励
end

function TurnFruitVo:getId()
	if self.tOb then
		return self.tOb["k"]
	end
	return nil
end

--用于夺宝转盘判断是否是装备碎片
function TurnFruitVo:isEquipFragment()
	local id = self:getId()
	if id then
		local tItemData = getBaseItemDataByID(id)
		if not tItemData then
			return false
		end
		if tItemData.nItemType and tItemData.nItemType == 7 and 
			tItemData.nEffectType and tItemData.nEffectType == 9 then
			return true
		end
	end
	return false
end

-------------用于夺宝转盘--------------------

function TurnFruitVo:setShowId(_Id)
	self.nShowId = _Id
end

function TurnFruitVo:getShowId(_Id)
	return self.nShowId
end

return TurnFruitVo