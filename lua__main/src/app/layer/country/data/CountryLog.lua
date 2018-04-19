--官员
local CountryLog = class("CountryLog")

function CountryLog:ctor(  )
	--body
	self:myInit()
end

function CountryLog:myInit(  )
	-- body
	self.nTime = nil
	self.nTypeID = nil
	self.nCountry = nil
	self.sName = nil
	self.nCityID = nil
end

function CountryLog:updateByService(_data)
	-- body
	self.nTime = _data.time or self.nTime--time	long	事件发生时间	
	self.nTypeID = _data.tid or self.nTypeID	--tid	int	事件模板ID
	self.nCountry = _data.country or self.nCountry--country	int	事件触发者国家
	self.sName = _data.name or self.sName--name	String	事件触发者名字
	self.nCityID = _data.cityID or self.nCityID --cityID	long	事件发生城池ID
end

function CountryLog:release(  )

end

--获取日志文本
function CountryLog:getJournalContentTextColor(  )
	-- bn,dn,dx,dy:事件发生城池ID获取，ac事件触发者国家，an事件触发者名字

	local tCityData = getWorldCityDataById(self.nCityID)
	if not tCityData then
		return nil
	end

	local tBlockData = getWorldMapDataById(tCityData.map)
	if not tBlockData then
		return nil
	end

	--参数集
	local tParamDict = {
		bn = tBlockData.name,
		dn = tCityData.name,
		dx = tCityData.tCoordinate.x,
		dy = tCityData.tCoordinate.y,
		ac = getCountryShortName(self.nCountry, true),
		an = self.sName,
	}

	local sContent = getCountryLogTemplate(self.nTypeID)
	if not sContent then
		return nil
	end

	local sStr = string.gsub(sContent, "%b{}", function ( sSubStr )
	        local sKey = string.sub(sSubStr,2,-2)
	        if tParamDict[sKey] then
	        	return tParamDict[sKey]
	        end
	        return sSubStr
	    end)
	return getTextColorByConfigure(sStr)
end

return CountryLog


