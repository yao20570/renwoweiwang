local EpangLineVo = class("EpangLineVo")

function EpangLineVo:ctor( tData )
	self:update(tData)
end

function EpangLineVo:update( tData )
	if not tData then
		return
	end
	self.nCountry =  tData.c --	Integer	国家
	self.nX = tData.x --	Integer	x坐标点
	self.nY = tData.y --	Integer	y坐标点
	self.nCityId = tData.id	--Long	城市id
	self.nId = tData.uuid --唯一id
end

function EpangLineVo:getCountry( )
	return self.nCountry
end

function EpangLineVo:getX(  )
	return self.nX
end

function EpangLineVo:getY(  )
	return self.nY
end

function EpangLineVo:getCityId(  )
	return self.nCityId
end

function EpangLineVo:getId(  )
	return self.nId
end


return EpangLineVo