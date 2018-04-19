local HarmAwardRes = class("HarmAwardRes")

function HarmAwardRes:ctor( tData )
	self.nHarm = 0
	self.tAward = {}
	self:update(tData)
end

function HarmAwardRes:update( tData )
	if not tData then
		return
	end

	self.nHarm = tData.harm or self.nHarm --阶段值
	self.tAward = tData.aw or self.tAward --奖励
end

function HarmAwardRes:getHarm( )
	return self.nHarm
end

function HarmAwardRes:getAward( )
	return self.tAward
end

return HarmAwardRes