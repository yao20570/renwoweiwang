local CountryWarMsg = class("CountryWarMsg")
--	城战
function CountryWarMsg:ctor( tData )
	self.nLv = 0
	self.nCdMax = 0
	self:update(tData)
end

function CountryWarMsg:update( tData )
	if not tData then
		return
	end

	self.nId = tData.i or self.nId	--Integer	国战发生城池ID
	self.nLv = tData.cl or self.nLv --Integer   国战城池等级
	self.nAtkTroops = tData.aT or self.nAtkTroops	--Integer	发起者兵力
	self.nAtkCountry = tData.sC	or self.nAtkCountry--Integer	发起者国家
	self.nDefTroops = tData.dT or self.nDefTroops	--Integer	防守者兵力
	self.nDefCountry = tData.dC	or self.nDefCountry--Integer	防守者国家

	self.nDefName = tData.dn or self.nDefName	--string	防守者名字
	self.nDefLv = tData.dl	or self.nDefLv	--Integer	防守者等级
	self.nAtkName = tData.an or self.nAtkName--string	发起者名字
	self.nAtkLv = tData.al	or self.nAtkLv	--Integer	发起者等级
	self.nSupport = tData.st or self.nSupport	--Integer	已经请求支援的次数

	
	self.nCd = milliSecondToSecond(tData.cd or self.nCd*1000) 	--Integer	倒计时 /毫秒
	self.nCdMax = milliSecondToSecond(tData.tcd) or self.nCdMax --总倒计时 /毫秒
	if tData.cd then
		self.nCdSystemTime = getSystemTime()
	end
	--创建唯一的key
	if not self.sId then
		-- self.sId = string.format("%s_%s_%s",self.nId,self.nAtkCountry,self.nDefCountry)
		self.sId = string.format("%s_%s",self.nId,self.nAtkCountry)
	end

	self.nAtkNum = tData.ap or self.nAtkNum		--Integer 	总的参与进攻的人数
	self.nDefNum = tData.dp or self.nDefNum		--Integer 	总的参与防守的人数
end

function CountryWarMsg:getCd( )
	if self.nCd and self.nCd > 0 then
        local fCurTime = getSystemTime()
        local fLeft = self.nCd - (fCurTime - self.nCdSystemTime)
        if(fLeft < 0) then
            fLeft = 0
        end
        return fLeft
    else
        return 0
    end
end

function CountryWarMsg:getCdMax()
	return self.nCdMax
end

function CountryWarMsg:getIsMyCountryJoin( )
	local nMyCountry = Player:getPlayerInfo().nInfluence
	return self.nAtkCountry == nMyCountry or self.nDefCountry == nMyCountry
end
 
return CountryWarMsg

