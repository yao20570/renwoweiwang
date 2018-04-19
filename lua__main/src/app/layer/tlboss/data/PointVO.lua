local PointVO = class("PointVO")

function PointVO:ctor( tData )
	self:update(tData)
end

function PointVO:update( tData )
	if not tData then
		return
	end

	self.nX = tData.x or self.nX --Integer	null
	self.nY = tData.y or self.nY --Integer	null
	self.nCountry = tData.c or self.nCountry
	self.sDotKey = string.format("%s_%s",self.nX, self.nY)
end

function PointVO:getX(  )
	return self.nX
end

function PointVO:getY(  )
	return self.nY
end

function PointVO:getCountry( )
	return self.nCountry
end

function PointVO:getDotKey( )
	return self.sDotKey
end

return PointVO