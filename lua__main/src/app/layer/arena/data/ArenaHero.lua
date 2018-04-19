-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-1-19 17:04:03 星期五
-- Description: 竞技场战斗记录
-----------------------------------------------------

local ArenaHero = class("ArenaHero")

function ArenaHero:ctor( tData )
	-- body
	self:myInit()
	self:update(tData)
end

--
function ArenaHero:myInit(  )
	self.nHeroId = nil --武将ID
	self.nKill 	 = 0 --杀敌数
	self.nLost 	 = 0 --损失兵力
	self.nTrp 	 = 0 --兵力
	self.nLv 	 = 0 --武将等级
	self.tHvo 		= nil --武将信息
end

--从服务端获取数据刷新
function ArenaHero:update( tData )
	self.nHeroId = tData.hid or self.nHeroId --武将ID
	self.nKill 	 = tData.kill or self.nKill --杀敌数
	self.nLost 	 = tData.lost or self.nLost --损失兵力
	self.nTrp 	 = tData.trp or self.nTrp --兵力
	self.nLv 	 = tData.lv or self.nLv --武将等级	
	self.tHvo    = tData.hvo or self.tHvo --武将信息 
end

function ArenaHero:getHeroData(  )--用于显示头像，等级等相关信息读取ArenaHero里的数据
	-- body
	local therobasedata = nil
	if self.tHvo then--为了兼容旧数据
		therobasedata = getGoodsByTidFromDB(self.tHvo.t)
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

return ArenaHero


