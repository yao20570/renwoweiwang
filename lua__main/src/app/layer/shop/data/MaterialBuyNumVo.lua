local MaterialBuyNumVo = class("MaterialBuyNumVo")

function MaterialBuyNumVo:ctor( tData )
	self:update(tData)
end

function MaterialBuyNumVo:update( tData )
	self.nId = tData.i or self.nId --Integer	物品ID
	self.nNum = tData.m or self.nNum --	Integer	物品数量
end

return MaterialBuyNumVo