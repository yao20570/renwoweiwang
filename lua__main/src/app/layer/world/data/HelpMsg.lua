local HelpMsg = class("HelpMsg")
local HeroShowVo = require("app.layer.world.data.HeroShowVo")

--援助类
function HelpMsg:ctor( tData )
	self.nHeroLv = 0
	self.nTroopsMax = 0
	self.nCdMax = 0
	self:update(tData)
end

function HelpMsg:update( tData )
	if not tData then
		return
	end
	self.nLv = tData.lv --玩家等级
	self.sName = tData.n --玩家名字
	-- self.nAid = tData.aid --Integer	驻防玩家角色ID
	self.sTid = tData.tid --String	驻防任务ID(当驻防玩家是自己才有该字段)
	
	self.nHeroId = tData.hid --Integer	英雄模板ID --已不传！！！
	if tData.hv then
		self.tHSVo = HeroShowVo.new(tData.hv) --HeroShowVo 英雄
		self.nHeroId = self.tHSVo.nHeroId
	end
	self.nTroops = tData.l --Integer	英雄带兵
	self.nTroopsMax = tData.ml or self.nTroopsMax --Integer	英雄带兵上限
	self.nHeroLv = tData.hl or self.nHeroLv--Integer	英雄等级
	self.nCd = tData.cd
	self.nCdMax = tData.tcd or self.nCdMax --Long	城战总倒计时/秒
	--自定义数据
	self.bIsMine = self.sTid ~= nil -- 是否是我的武将

	if tData.cd then
		self.nCdSystemTime = getSystemTime()
	end
end

function HelpMsg:getCd( )
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

function HelpMsg:getCdMax( )
	return self.nCdMax or 0
end

--获取武将数据
function HelpMsg:getHeroData(  )
	if self.tHSVo then
		local tHero = getHeroDataById(self.tHSVo.nHeroId)
		if tHero then
			local tHeroClone = clone(tHero)
			tHeroClone.nIg = self.tHSVo.nIg
			return tHeroClone
		end
	end
	return nil
end


return HelpMsg