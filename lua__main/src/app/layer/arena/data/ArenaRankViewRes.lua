-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-1-19 15:53:03 星期五
-- Description: 竞技场玩家信息
-----------------------------------------------------

local ActorVo = require("app.layer.playerinfo.ActorVo")
local ArenaRankViewRes = class("ArenaRankViewRes")

function ArenaRankViewRes:ctor(  )
	-- body
	self:myInit()
end

--
function ArenaRankViewRes:myInit(  )
	self.nId = nil 	 -- id	long	id
    self.nRank = 0   -- rank	int	排名
    self.sName = "" --name	String	名字
    self.nLevel = 0 -- level	int	等级
    self.nScore = 0 -- score	long	战斗力
    self.nInfluence = 0 --country	Integer	国家

    self.nIsNpc = 0  -- isnpc	Integer	是否是机器人 0不是1是

 	self.sIcon  = nil -- icon	String	目标头像
 	self.sBox   = nil -- box	String	目标头像框
 	self.sTit   = nil -- tit   string 称号
    self.tHeroVos = {}	--List<HeroVo>	竞技场阵容

    self.bLucky = false --是否在幸运排名

end

--从服务端获取数据刷新
function ArenaRankViewRes:refreshDatasByService( tData, _bLucky )
	--dump(tData,"竞技场视图数据",100)
	self.nId = tData.id or self.nId 	 -- id	long	id
    self.nRank = tData.rank or self.nRank   -- rank	int	排名
    self.sName = tData.name or self.sName --name	String	名字
    self.nLevel = tData.level or self.nLevel -- level	int	等级
    self.nScore = tData.score or self.nScore -- score	long	战斗力

    self.nInfluence = tData.country or self.nInfluence --country	Integer	国家

    self.nIsNpc = tData.isnpc or self.nIsNpc -- isnpc	Integer	是否是机器人 0不是1是

 	self.sIcon  = tData.icon or self.sIcon -- icon	String	目标头像
 	self.sBox   = tData.box or self.sBox -- box	String	目标头像框
 	self.sTit 	= tData.tit or self.sTit -- tit   string 称号
 	self.bLucky = _bLucky or self.bLucky
	--刷新竞技场阵容
	self:updateArenaLineUp(tData.ba)-- ba	List<HeroVo>	竞技场阵容

end
--头像
function ArenaRankViewRes:getActorVo( ... )
	-- body
	if not self.pAvator then 	
 		self.pAvator = ActorVo.new() 		
 	end
 	self.pAvator:initData(self.sIcon, self.sBox, self.sTit)
	return self.pAvator
end

-- 刷新英雄数据
function ArenaRankViewRes:updateArenaLineUp( _tData )
	if (not _tData) or (#_tData <= 0) then
		return 
	end
	self.tHeroVos = {}
	-- 获取英雄数据
	for k, v in pairs(_tData) do
		if v.npc then
			local pNpc =getNPCData(v.npc)
			table.insert(self.tHeroVos, pNpc) --新增一个Npc
		elseif v.h then
			local pHero = getHeroDataById(v.h)
			pHero:refreshDatasByService(v)
			table.insert(self.tHeroVos, pHero) --新增一个英雄
		end 
	end	
end

return ArenaRankViewRes


