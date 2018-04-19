--国家互助数据
local BCountryHelp = class("BCountryHelp")

function BCountryHelp:ctor(  )
	--body
	self:myInit()
end

function BCountryHelp:myInit( )
	-- body
	--配置
	self.nId 		= 	nil 	--帮助数据唯一id
	self.tAva 		= 	nil 	--玩家数据
	self.tHn 	 	= 	nil 	--已经协助的玩家列表
	self.nType  	= 	nil	    --类型 1建筑,2科技,3装备
	self.nQid 	    = 	nil 	--加速建筑id/科技id/装备id
end
 
--从服务器刷新数据
function BCountryHelp:updateInfo(_tData)
	if not _tData then
		return
	end
	-- body
	self.nId 		= 	_tData.id or self.nId
	self.tAva 		= 	_tData.ava or self.tAva
	self.tHn 		= 	_tData.hn or self.tHn
	self.nType 		= 	_tData.type or self.nType
	self.nQid 		=   _tData.qid or self.nQid
end


function BCountryHelp:getName()
	if self.tAva then
		return self.tAva.n
	end
	return ""
end

function BCountryHelp:getLv()
	if self.tAva then
		return self.tAva.l
	end
	return 0
end

function BCountryHelp:getDes()
	if not self.nType or not self.nQid then 	--加速建筑id/科技id/装备id
		return ""
	end
	-- self.nType  	= 	nil	    --类型 1建筑,2科技,3装备
	-- self.nQid 	    = 	nil 	--加速建筑id/科技id/装备id
	local sBaseStr = getConvertedStr(1,10426)
	if self.nType == 1 then --1建筑
		local tBuildData = getBuildDatasByTid(self.nQid)
		if tBuildData then
			sBaseStr = string.format(sBaseStr, getConvertedStr(1,10100), tBuildData.name)
		else
			return ""
		end
	elseif self.nType == 2 then --2科技
		local tScienceData = getTnolyByIdFromDB(self.nQid)
		if tScienceData then
			sBaseStr = string.format(sBaseStr, getConvertedStr(1,10100), tScienceData.sName)
		else
			return ""
		end
	elseif self.nType == 3 then --3装备
		local tEquipData = getBaseEquipDataByID(self.nQid)
		if tEquipData then
			sBaseStr = string.format(sBaseStr, getConvertedStr(7,10402), tEquipData.sName)
		else
			return ""
		end
	end
	return sBaseStr
end

function BCountryHelp:getHelpNum()
	if not self.tHn then
		return 0
	end
	if type(self.tHn) == "table" then
		return #self.tHn
	end
	return 0
end

function BCountryHelp:getHelpNumMax()
	local add = Player:getBuffData():getBuffPercentAdds(e_buff_key.countryhelp_count_add)
	return getCountryParam("helpNum") + add
end

function BCountryHelp:getHelpId()
	return self.nId;
end
--是否已经帮助过
function BCountryHelp:isHelp()
	local pid = Player:getPlayerInfo().pid
	for i=1, #self.tHn do
		if self.tHn[i] == pid then
			return true
		end
	end
	return false
end

--帮助次数已经满
function BCountryHelp:isHelpFull()
	local nHelpNum = self:getHelpNum()
	local nHelpMax = self:getHelpNumMax()
	if nHelpNum >= tonumber(nHelpMax) then
		return true
	else
		return false
	end
end

--获取头像信息
function BCountryHelp:getAo()
	if self.tAva and self.tAva.ao then
		return self.tAva.ao
	else
		return {i="130000",b="140000"}
	end
end

function BCountryHelp:release(  )

end

return BCountryHelp


