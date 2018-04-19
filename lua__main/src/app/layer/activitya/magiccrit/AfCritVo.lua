local AfCritVo = class("AfCritVo")

function AfCritVo:ctor( tData )
	self:update(tData)
end

function AfCritVo:update( tData )
	if not tData then
		return
	end
	self.nId = tData.a
	self.nCrit = tData.c
end

return AfCritVo