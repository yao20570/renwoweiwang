local VipDiscount = class("VipDiscount")

function VipDiscount:ctor( tData )
	self:update(tData)
end

function VipDiscount:update( tData )
	self.nExchangeId =  tData.e	or self.nExchangeId --Integer	兑换ID
	self.nDiscount =  tData.m or self.nDiscount --	Integer	已购买打折次数
end

return VipDiscount