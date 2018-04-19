-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-03-14 18:05:17 星期三
-- Description: 副本信息
-----------------------------------------------------

local OutpostVo = class("OutpostVo")
local DataHero = require("app.layer.hero.data.DataHero")

function OutpostVo:ctor( tData )
	-- body
	self:myInit()
	self:update(tData)
end

--数据初始化
function OutpostVo:myInit(  )
	self.nOid 				= nil --oid 第几关
	self.nId  				= nil --id 玩家id 如果是npc,记录npc的id
	self.nCountry 			= nil -- country iInteger	国家
	self.nLv 				= 0   -- level	Integer	等级
	self.sName  			= ""  -- name	String	名字	
	self.tBattleArray 		= {}  -- battleArray list<HeroVo>	战队
	self.nNpc 				= 0   -- npc	Integer	玩家还是npc 1是0不是  	
end

--从服务端获取数据刷新
function OutpostVo:update( tData )
	self.nOid 				= tData.oid or self.nOid 			 --oid 第几关
	self.nId  				= tData.id or self.nId  			 -- 玩家ID,如果是npc,记录npc的id
	self.nCountry 			= tData.country or self.nCountry 	 -- c Integer	国家 	
	self.nLv 				= tData.level or self.nLv            -- lv	Integer	等级
	self.sName  			= tData.name or self.sName       	 -- name String	名字	
	self.nNpc 				= tData.npc or self.nNpc          	 -- npc	Integer	玩家还是npc 1是0不是 
	self.tBattleArray 		= tData.battleArray or self.tBattleArray -- battleArray list<HeroVo>	战队
	-- if tData.battleArray then
	-- 	--刷新英雄数据
	-- 	Player:getHeroInfo():refreshHeroListDatasByService(tData.battleArray)
	-- 	sendMsg(gud_refresh_hero) --通知刷新界面
	-- end
end

--获取敌方部队
function OutpostVo:getEnemy()
	-- body
	if not self.tBattleArray or table.nums(self.tBattleArray) == 0 then
		return
	end
	local tResultEnemy = {} --结果队列
	local tAliveEnemy = {} --活着的队列
	local tDeadEnemy = {} --死亡队列
	if self.nNpc == 1 then --npc
		tAliveEnemy = getNpcGropById(self.nId) or {}
		if table.nums(tAliveEnemy) > 0 then
			for i = 1, table.nums(tAliveEnemy) do
				for _, data in pairs(self.tBattleArray) do
					if tAliveEnemy[i].nId == data.npc then
						tAliveEnemy[i].nBlood = data.bloor
					end
				end
			end
			for i = table.nums(tAliveEnemy), 1, -1 do
				if tAliveEnemy[i].nBlood <= 0 then
					table.insert(tDeadEnemy, tAliveEnemy[i])
					table.remove(tAliveEnemy, i)
				end
			end
		end
	else --玩家
		local tBattleArray = self.tBattleArray
		for k, v in ipairs(tBattleArray) do
			local tHero = copyTab(getHeroDataById(v.t))
			tHero:refreshDatasByService(v)
			if tHero.nBlood > 0 then
				table.insert(tAliveEnemy, tHero)
			else
				table.insert(tDeadEnemy, tHero)
			end
		end
	end
	tResultEnemy = tAliveEnemy
	if #tDeadEnemy > 0 then
		for k, v in pairs(tDeadEnemy) do
			table.insert(tResultEnemy, v)
		end
	end
	
	return tResultEnemy
end



return OutpostVo