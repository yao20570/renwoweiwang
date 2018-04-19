local ComingHelpVO = class("ComingHelpVO")
local HeroShowVo = require("app.layer.world.data.HeroShowVo")

function ComingHelpVO:ctor( tData )
	self.nCdMax = 0
	self:update(tData)
end

function ComingHelpVO:update( tData )
	self.sUuid = tData.uuid--	String	帮助的UUID
	self.nType = tData.t--	Integer	类型 1:驻防 2:城战协防
	self.sName = tData.n--	String	名字
	self.nLv = tData.lv	--Integer	等级
	self.tHeros = tData.hs	--Set<Integer>	武将ID --已经不专
	if tData.hvos then --List<HeroShowVo>
		self.tHeros = {}
		self.tHSVoList = {}
		for i=1,#tData.hvos do
			local tHv = HeroShowVo.new(tData.hvos[i]) --HeroShowVo 英雄	
			table.insert(self.tHSVoList, tHv)
			table.insert(self.tHeros, tHv.nHeroId)
		end
	end
	
	self.nCd    = tData.cd --Long	倒计时/秒
	self.nCdMax = tData.tcd or self.nCdMax --Long	城战总倒计时/秒
	self.nHeroLv = tData.hlv -- Integer	武将等级[驻防独有]
	self.nTroops = tData.trp	--Integer	驻防兵力[驻防独有]
	self.nX = tData.x	--Integer	X坐标[城战协防独有]
	self.nY = tData.y	--Integer	Y坐标[城战协防独有]
	self.sWarId = tData.wid	--String	城战ID[城战协防独有]

	if tData.cd then
		self.nCdSystemTime = getSystemTime()
	end
end

function ComingHelpVO:getCd( )
	--等待城战中
	if self:getIsWaitHelpCityWar() then
		local tCityWarMsg = Player:getWorldData():getMyCityWarByUuid(self.sWarId)
		if tCityWarMsg then
			return tCityWarMsg:getCd()
		end
		return 0
	else
		return self:__getCd()
	end
end

function ComingHelpVO:getCdMax( )
	--等待城战中
	if self:getIsWaitHelpCityWar() then
		local tCityWarMsg = Player:getWorldData():getMyCityWarByUuid(self.sWarId)
		if tCityWarMsg then
			return tCityWarMsg.nCdMax or 0
		end
		return 0
	else
		return self.nCdMax or 0
	end
end

function ComingHelpVO:__getCd( )
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

--城战协防 是协防状态还是城战等待状态
function ComingHelpVO:getIsWaitHelpCityWar( )
	if self.nType == 2 then
		return self:__getCd() <= 0
	end
	return false
end

--获取武将数据
function ComingHelpVO:getHeroDataByIndex( nIndex )
	if self.tHSVoList then
		local tHSVo = self.tHSVoList[nIndex]
		if tHSVo then
			local tHero = getHeroDataById(tHSVo.nHeroId)
			if tHero then
				local tHeroClone = clone(tHero)
				tHeroClone.nIg = tHSVo.nIg
				return tHeroClone
			end
		end
	end
	return nil
end


return ComingHelpVO