local FBer = require("app.layer.cityfirstblood.data.FBer")

local CityFirstBloodVO = class("CityFirstBloodVO")

function CityFirstBloodVO:ctor( tData )
	self:update(tData)
end

function CityFirstBloodVO:update( tData )
	if not tData then
		return
	end
	self.nCityType = tData.ct or self.nCityType --	Integer	城池类型
	self.nStartCountry = tData.sc or self.nStartCountry --	Integer	发起国家
	self.nSysCityId = tData.id or self.nSysCityId --Integer 城池id
	if tData.sp then --FBer	发起玩家数据
	 	self.tStartFBer = FBer.new(tData.sp)
	end
	if tData.fbs then --List<FBer>	参与者数据
		self.tJoinFBerList = {}
		for i=1,#tData.fbs do
			table.insert(self.tJoinFBerList, FBer.new(tData.fbs[i]))
		end
	end

	-- --测试
	-- if true then
	-- 	if self.nCityType == 1 then
	-- 		for i=1,26 do
	-- 			local tData2 = clone(self.tJoinFBerList[1])
	-- 			table.insert(self.tJoinFBerList, tData2)
	-- 		end
	-- 	end
	-- end
end

function CityFirstBloodVO:getBlockId(  )
	local tCityData = getWorldCityDataById(self.nSysCityId)
	if tCityData then
		return tCityData.map
	end
	return nil
end

function CityFirstBloodVO:getKind(  )
	return self.nCityType
end

function CityFirstBloodVO:getCountry(  )
	return self.nStartCountry
end

function CityFirstBloodVO:getFirstBlooodStr(  )
	if not self.tStartFBer then
		return ""
	end
	return string.format("%s:%s", getFirstBloodStr(self:getKind()) , self.tStartFBer:getName())
end

return CityFirstBloodVO

