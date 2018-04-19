local CountryWarOverview = class("CountryWarOverview")
--	进行中的国战纵览
function CountryWarOverview:ctor( tData )
	self:update(tData)
end

function CountryWarOverview:update( tData )
	if not tData then
		return
	end
	self.nId = tData.i --Integer	城池ID
	self.tCountry = tData.cs --List<Integer>	发起国家ID集
end

return CountryWarOverview

