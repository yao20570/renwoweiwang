
--[[
	二维矢量对象
--]]

local PlgVectorObj = class("PlgVectorObj")

function PlgVectorObj:ctor( fX, fY )
	-- body
	self.fX = fX
	self.fY = fY
end

function PlgVectorObj:opMinus( pv )
	-- body

	return PlgVectorObj.new(self.fX - pv.fX, self.fY - pv.fY)
end

function PlgVectorObj:dot( pv )
	-- body
	return self.fX * pv.fX + self.fY * pv.fY
end

function PlgVectorObj:cross( pv )
	-- body
	return self.fX * pv.fY - self.fY * pv.fX
end

return PlgVectorObj