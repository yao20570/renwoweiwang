local MainCityOccupyVO = class("MainCityOccupyVO")

function MainCityOccupyVO:ctor( tData )
	self:update(tData)
end

function MainCityOccupyVO:update( tData )
	self.nCityId = tData.c or self.nCityId --	Long	城池ID
	self.nCountry = tData.i or self.nCountry --	Integer	占领国家的ID
end

return MainCityOccupyVO