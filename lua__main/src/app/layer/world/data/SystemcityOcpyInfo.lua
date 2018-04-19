local SystemcityOcpyInfo = class("SystemcityOcpyInfo")
--	区域内各个城池占领信息
function SystemcityOcpyInfo:ctor( tData, tViewDotMsg )
	self:update(tData)
	self:udpateByViewDotMsg(tViewDotMsg)
end

function SystemcityOcpyInfo:update( tData )
	if not tData then
		return
	end
	self.nId = tData.i --Integer	城池ID
	self.nCountry = tData.c --Integer	占领国家
	self.sName = tData.cn --Integer 没有字段时读取配表名字
	--tData.cp --Integer 0 否 1 是
	if tData.cp and tData.cp == 1 then
		self.bCanCollect = true
	else
		self.bCanCollect = false
	end
	
	if tData.pcd then
		self.nProtectCd = milliSecondToSecond(tData.pcd) ----Integer 保护cd时间毫秒
		self.nProtectCdSystemTime = getSystemTime()
	end
end

function SystemcityOcpyInfo:udpateByViewDotMsg( tViewDotMsg )
	if not tViewDotMsg then
		return
	end

	self.nId = tViewDotMsg.nSystemCityId
	self.nCountry = tViewDotMsg.nSysCountry
	self.sName = tViewDotMsg.sSysCityName
	if self.nCountry == Player:getPlayerInfo().nInfluence then
		self.bCanCollect = tViewDotMsg.bHasPaper
	else
		self.bCanCollect = false
	end
	
	if tViewDotMsg.nProtectCd then
		self.nProtectCd = tViewDotMsg.nProtectCd
		self.nProtectCdSystemTime = tViewDotMsg.nProtectCdSystemTime
	end
end

--获得系统城池保护时间/毫秒(系统城池独有)
function SystemcityOcpyInfo:getProtectCd( )
	if self.nProtectCd and self.nProtectCd > 0 then
		local fCurTime = getSystemTime()
		local fLeft = self.nProtectCd - (fCurTime - self.nProtectCdSystemTime)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end
end

function SystemcityOcpyInfo:getName( )
	local sName = self.sName
	if not sName then
		local tCityData = getWorldCityDataById(self.nId)
		if tCityData then
			sName = tCityData.name
		end
	end
	return sName or ""
end

return SystemcityOcpyInfo

