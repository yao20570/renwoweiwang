-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-03-14 17:04:03 星期三
-- Description: 过关斩将进攻方和防守方数据
-----------------------------------------------------

local HeroShowVo = require("app.layer.world.data.HeroShowVo")
local AernaFighterVo = class("AernaFighterVo")

function AernaFighterVo:ctor( tData )
	-- body
	self:myInit()
	self:update(tData)
end

--
function AernaFighterVo:myInit(  )
	self.nHeroId 	= nil --武将id
	self.tHvo 		= nil --武将详细信息
	self.nKill 		= 0  --	Integer	总杀敌数
	self.nLost 		= 0  --	Integer	总损兵数
	self.nTrp 	 	= 0  -- iInteger 兵力
	self.nLv 		= 0  -- Integer	等级
end

--从服务端获取数据刷新
function AernaFighterVo:update( tData )
	self.nHeroId 	 	= tData.hid or self.nHeroId  	 -- 武将id
	self.nKill 			= tData.kill or self.nKill 		 --	Integer	总杀敌数
	self.nLost 			= tData.lost or self.nLost 		 --	Integer	总损兵数
	self.nTrp 			= tData.trp or self.nTrp 		 --	Integer	兵力
	self.nLv 			= tData.lv or self.nLv           -- lv	Integer	等级

	if tData.hvo then 									 -- HeroShowVo 武将详细信息
		self.tHvo 		= nil
		self.tHvo 		= HeroShowVo.new(tData.hvo)
	end
end

function AernaFighterVo:getHeroData(  )--用于显示头像，等级等相关信息读取ArenaHero里的数据
	-- body
	local therobasedata = nil
	if self.tHvo then--为了兼容旧数据
		therobasedata = getGoodsByTidFromDB(self.tHvo.nHeroId)
		if therobasedata then
			if therobasedata.refreshDatasByService then
				therobasedata:refreshDatasByService(self.tHvo)
			end
		end
	else
		therobasedata = getGoodsByTidFromDB(self.nHeroId)
	end
	return therobasedata
end


return AernaFighterVo