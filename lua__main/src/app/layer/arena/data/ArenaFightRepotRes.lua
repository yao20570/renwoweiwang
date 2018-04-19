-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-1-19 17:04:03 星期五
-- Description: 竞技场战斗记录
-----------------------------------------------------	

local ActorVo = require("app.layer.playerinfo.ActorVo")
local ArenaPlayerVo = require("app.layer.arena.data.ArenaPlayerVo")
local ArenaHero = require("app.layer.arena.data.ArenaHero")
local ArenaFightRepotRes = class("ArenaFightRepotRes")

function ArenaFightRepotRes:ctor( tData, _bNew )
	-- body
	self:myInit()
	self:updateByService(tData, _bNew)
end

--
function ArenaFightRepotRes:myInit(  )
	self.nWin 	= 0  -- win	Integer	进攻方是否胜利 0:失败 1:胜利
	self.nType 	= 0  -- type	Integer	进攻还是防守 0是进攻方,1是防守方
	self.nNpcId = 0  -- npcId	Integer	目标是否是NPC 0代表不是npc
	self.nOt    = nil -- ot	Date	时间
	self.nReportId = nil -- rid	String	战报id

	self.tAInfo     = nil -- 进攻方玩家信息
	self.tDInfo     = nil -- 防守方玩家信息
	self.tAf 		= nil -- 进攻方战斗详情
	self.tDf 		= nil -- 防守方战斗详情

	self.bNew 		= false
end

--从服务端获取数据刷新
function ArenaFightRepotRes:updateByService( tData)
	-- dump(tData,"战斗记录",100)
	self.nWin 		= tData.win or self.nWin          -- win	Integer	进攻方是否胜利 0:失败 1:胜利
	self.nType 		= tData.type or self.nType        -- type	Integer	进攻还是防守 0是进攻方,1是防守方
	self.nNpcId 	= tData.npcId or self.nNpcId      -- npcId	Integer	目标是否是NPC 0代表不是npc
	self.nOt    	= tData.ot or self.nOt            -- ot	Date	时间
	self.nReportId 	= tData.rid or self.nReportId     -- rid	String	战报id
	self.tAInfo     = ArenaPlayerVo.new(tData.ainfo)  -- 进攻方玩家信息
	self.tDInfo     = ArenaPlayerVo.new(tData.dinfo)  -- 防守方玩家信息	
	self.tAf 		= self:createHerosInfo(tData.af)  -- 进攻方战斗详情
	self.tDf 		= self:createHerosInfo(tData.df)  -- 防守方战斗详情	

	self.bNew 		= tData.read == 0		

end

function ArenaFightRepotRes:createHerosInfo( _tData )
	-- body
	local tList = {}
	if _tData and #_tData then
		for k, v in pairs(_tData) do
			table.insert(tList, ArenaHero.new(v))
		end
	end
	return tList
end

--清楚新纪录标识
function ArenaFightRepotRes:clearNewMark(  )
	-- body
	self.bNew = false	
end

function ArenaFightRepotRes:getShareData(  )
	-- body
	return {ac=self.tAInfo.nCountry,
	an=self.tAInfo.sName,
	al=self.tAInfo.nLv,
	dc=self.tDInfo.nCountry,
	dn=self.tDInfo.sName,
	dl=self.tDInfo.nLv}
end

--
function ArenaFightRepotRes:getMailTypeDes(  )
	-- body
	local sStr = getConvertedStr(6, 10816)
	if self.tAInfo and self.tDInfo then
		return string.format(sStr, self.tAInfo:getMailStr(), self.tDInfo:getMailStr())
	end
	return ""	
end

--获取战力
function ArenaFightRepotRes:getCombat( _nType )
	-- body
	local tList = {}
	if _nType == 1 then--攻击方
		tList = self.tAf
	else  				--防守方
		tList = self.tDf
	end
	local nCombat = 0
	for k, v in pairs(tList) do
		nCombat = nCombat + v.nTrp
	end
	return nCombat
end

function ArenaFightRepotRes:getLost( _nType )
	-- body
	local tList = {}
	if _nType == 1 then--攻击方
		tList = self.tAf
	else  				--防守方
		tList = self.tDf
	end
	local nLost = 0
	for k, v in pairs(tList) do
		nLost = nLost + v.nLost
	end
	return nLost	
end

function ArenaFightRepotRes:getReportType( )
	-- body
	if self.nType == 0 then--进攻方
		if self.nWin == 0 then
			--失败
			return 3
		else
			--胜利
			return 1
		end
	else    				--防守方
		if self.nWin == 0 then
			--胜利
			return 4
		else
			--失败
			return 2
		end
	end	
end

function ArenaFightRepotRes:isWin( )
	-- body
	local nType = self:getReportType()
	if nType == 1 or nType == 4 then
		return true
	else
		return false
	end
end

function ArenaFightRepotRes:isAttacker(  )
	-- body
	return self.nType == 0
end

--获取竞技对方玩家信息
function ArenaFightRepotRes:getOtherPlayerInfo( )
	-- body
	if self.nType == 0 then--当前玩家是进攻方
		return self.tDInfo
	else
		return self.tAInfo		
	end
end
--获取我的竞技场对阵数据
function ArenaFightRepotRes:getMyArenaInfo(  )
	-- body
	if self.nType == 0 then--当前玩家是进攻方
		return self.tAInfo		
	else
		return self.tDInfo
	end	
end
--头像
function ArenaFightRepotRes:getActorVo( ... )
	-- body
	if not self.pAvator then 	
 		self.pAvator = ActorVo.new() 		
 	end
 	self.pAvator:initData(self.sIcon, self.sBox, nil)
	return self.pAvator
end

return ArenaFightRepotRes


