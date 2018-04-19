--官员
local CountryCityVo = class("CountryCityVo")

function CountryCityVo:ctor(  )
	--body
	self:myInit()
end

function CountryCityVo:myInit(  )
	-- body
	self.nID	= nil
	self.nCityLV = nil
	self.sMName = nil
	self.nMLv = nil
	self.nMID = nil
	self.nLeft = nil
	self.nMax = nil
	self.nAsking = nil 

	self.nRedNum = 0
	self.bRefresh = false
end

function CountryCityVo:refreshDataByService(_data )
	-- body	
	self.nID		= _data.t or self.nMID --t	Long	城池ID 
	self.nCityLV 	= _data.q or self.nCityLV --q	Integer	城池等级
	self.sMName 	= _data.l or self.sCMName --l	String	城主名字
	self.nMLv 		= _data.lv or self.sCMName --lv	Integer	城主等级
	self.nMID 		= _data.ld or self.nMID	--城主ID 为0时候城池为空城
	self.nLeft 		= _data.r or self.nLeft --r	Integer	剩余城防兵力
	self.nMax 		= _data.m or self.nMax --m	Integer	最大城防兵力
	self.nAsking 	= _data.ap or self.nAsking --是否正在申请城池
	self.bHasPaper  = _data.cp == 1 --是否有图纸

	self.bRefresh = true
end
--刷新红点
function CountryCityVo:refreshRedNum(  )
	-- body
	if not self.bRefresh then
		return
	end
	--当前玩家非城主可以申请
	if self:isCityEmpty() and not Player:getCountryData():isPlayerBeCityMaster() then
		self.nRedNum = self.nRedNum + 1
	else
		if self:isCanSupply() then--补充城防
			self.nRedNum = self.nRedNum + 1
		end		
	end
	self.bRefresh = false	
end

function CountryCityVo:getCityRedNum( )
	-- body
	return self.nRedNum
end

function CountryCityVo:clearRedRecord( ... )
	-- body
	self.nRedNum = 0
end
--判断当前城池
function CountryCityVo:isCityEmpty()
	-- body
	if not self.nMID or self.nMID == 0 then
		return true
	end
	return false
end

--判断当前玩家是否是城主
function CountryCityVo:isMineCity( )
	-- body
	if not self.nMID then
		return false
	end
	if self.nMID == Player:getPlayerInfo().pid then
		return true
	else
		return false
	end	
end
--是否可以补充城防
function CountryCityVo:isCanSupply( ... )
	-- body
	if self:isCityEmpty() == true then
		return false
	end
	if self.nLeft < self.nMax then
		return true
	end
	return false
end
--是否申请城池中
function CountryCityVo:isAskingForCityMaster()
	if not self.nAsking or self.nAsking == 0 then
		return false
	else
		return true
	end
end

function CountryCityVo:getId(  )
	return self.nID
end

function CountryCityVo:getCityLv(  )
	return self.nCityLV
end

function CountryCityVo:getMName(  )
	return self.sMName
end

function CountryCityVo:getRemainTroops(  )
	return self.nLeft
end

function CountryCityVo:getTroopsMax(  )
	return self.nMax
end

function CountryCityVo:getHasPaper(  )
	return self.bHasPaper
end

function CountryCityVo:release(  )

end
return CountryCityVo

