----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-04-8 10:01:00
-- Description: 新国家系统，国家城池
-----------------------------------------------------
local CountryCityVo = require("app.layer.country.data.CountryCityVo")
local CountryCityData = class("CountryCityData")

function CountryCityData:ctor(  )
	self.tMyCoutnryCity = {} --我国所有城市字典
end

function CountryCityData:release(  )
	-- body
end

--获取我国的所有城池
function CountryCityData:getMyCountryCitys(  )
	return self.tMyCoutnryCity
end

--设置我国的所有城池
function CountryCityData:setMyCountryCitys( tData )
	self.tMyCoutnryCity = {}
	if tData then
		for i=1,#tData do
			local tVo = CountryCityVo.new()
			tVo:refreshDataByService(tData[i])
			local nId = tVo:getId()
			self.tMyCoutnryCity[nId] = tVo
		end
	end
end

--更新我国的所有城池
function CountryCityData:updateMyCountryCitys( tDataList )
	if not tDataList then
		return
	end
	for i=1,#tDataList do
		local tData = tDataList[i]
		if self.tMyCoutnryCity[tData.t] then
			self.tMyCoutnryCity[tData.t]:refreshDataByService(tData)
		else
			local tVo = CountryCityVo.new()
			tVo:refreshDataByService(tData)
			local nId = tVo:getId()
			self.tMyCoutnryCity[nId]  = tVo
		end
	end
	
end

--移除我国城池
function CountryCityData:delMyCountryCitys( tData )
	if not tData then
		return
	end
	for i=1,#tData do
		local nId = tData[i]
		self.tMyCoutnryCity[nId] = nil
	end
end

return CountryCityData