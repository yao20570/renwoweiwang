----------------------------------------------------- 
-- author: xiesite
-- updatetime: 2018-04-04 14:10:33
-- Description: 国家互助数据
-----------------------------------------------------

local BCountryHelp = require("app.layer.newcountry.newcountryhelp.data.BCountryHelp")
--免费宝箱数据
local DataCountryHelp = class("DataCountryHelp")

function DataCountryHelp:ctor(  )
	self:myInit()
end

function DataCountryHelp:myInit(  )		
	self.tHelps = {} 
end

-- 读取服务器中的数据
function DataCountryHelp:refreshDatasByService( _tData )
	if not _tData then
		return
	end

	local nNum = #self.tHelps
	local nNumNow = #_tData
	if nNum > nNumNow then
		for i=nNum , 1, -1 do
			if i > nNumNow then
				table.remove(self.tHelps,i)
			else
				if self.tHelps[i] then
					self.tHelps[i]:updateInfo(_tData[i])
				end
			end
		end
	else
		for i=1, nNumNow do
			if i <= nNum then
				if self.tHelps[i] then
					self.tHelps[i]:updateInfo(_tData[i])
				end
			else
				self.tHelps[i] = BCountryHelp.new()
				self.tHelps[i]:updateInfo(_tData[i])
			end
		end
	end

	--剔除本人和已经帮助满的数据
	local sName = Player:getPlayerInfo().sName;

	for i=#self.tHelps , 1, -1 do
		if sName == self.tHelps[i].tAva.n or self.tHelps[i]:isHelpFull() then
			table.remove(self.tHelps, i)
		end
	end

end

function DataCountryHelp:getHelps()
	return self.tHelps;
end

--是否有可以帮助的，用于一键帮助
function DataCountryHelp:haveHelps()
	--没开放不可提供帮助
	if not getIsReachOpenCon(3, false) then
		return false
	end

	for i=1,#self.tHelps do
		if not self.tHelps[i]:isHelpFull() and not self.tHelps[i]:isHelp() then
			return true
		end
	end
	return false
end

function DataCountryHelp:getCountryHelpRed()
	local nRedNum = 0
	if self:haveHelps() then
		nRedNum = 1
	end
	return nRedNum
end

return DataCountryHelp