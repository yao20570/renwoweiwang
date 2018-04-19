-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-03-14 20:14:03 星期三
-- Description: 过关斩将战报记录
-----------------------------------------------------	

local AernaFighterVo = require("app.layer.passkillhero.data.AernaFighterVo")
local ExpediteAvatarVo = require("app.layer.passkillhero.data.ExpediteAvatarVo")
local ExpediteReportRes = class("ExpediteReportRes")

function ExpediteReportRes:ctor( tData, _bNew )
	-- body
	self:myInit()
	self:updateByService(tData, _bNew)
end

--初始化数据
function ExpediteReportRes:myInit(  )
	self.nWin 			= 0 		 -- win	Integer	进攻方是否胜利 0:失败 1:胜利
	self.nOt  			= nil 		 -- ot	Date	时间
	self.nReportId 		= nil 		 -- rid	String	战报id
	self.tAInfo     	= nil 		 -- 进攻方玩家信息
	self.tDInfo     	= nil 		 -- 防守方玩家信息
	self.tAf     		= nil 		 -- 进攻方战斗详情
	self.tDf     		= nil 		 -- 防守方战斗详情
	self.nOid 			= nil 		 -- 第几关
	self.bIsReaded 		= false 	 -- 是否已读

	self.bNew 			= false
end

--从服务端获取数据刷新
function ExpediteReportRes:updateByService( tData, _bNew )
	if tData == nil then return end
	-- dump(tData,"战斗记录",100)
	self.nWin 		= tData.win or self.nWin         	 -- win	Integer	进攻方是否胜利 0:失败 1:胜利
	self.nOt    	= tData.ot or self.nOt           	 -- ot	Date	时间
	self.nReportId 	= tData.reportId or self.nReportId   -- rid	String	战报id
	if tData.avo then
		self.tAInfo     = ExpediteAvatarVo.new(tData.avo) 	 -- 进攻方玩家信息
	end
	if tData.dvo then
		self.tDInfo     = ExpediteAvatarVo.new(tData.dvo) 	 -- 防守方玩家信息
	end
	self.tAf 		= self:createHerosInfo(tData.ai) 	 -- 进攻方战斗详情
	self.tDf 		= self:createHerosInfo(tData.di) 	 -- 防守方战斗详情
	self.nOid    	= tData.oid or self.nOid           	 -- 第几关
	self.bIsReaded  = tData.read == 1 or self.bIsReaded  -- 是否已读:0未读, 1已读

	self.bNew = _bNew or false		

end

function ExpediteReportRes:createHerosInfo( _tData )
	-- body
	local tList = {}
	if _tData and #_tData > 0 then
		for k, v in pairs(_tData) do
			table.insert(tList, AernaFighterVo.new(v))
		end
	end
	return tList
end


--清楚新纪录标识
function ExpediteReportRes:clearNewMark(  )
	-- body
	self.bNew = false	
end

--获取防守方信息
function ExpediteReportRes:getDefInfo()
	-- body
	return self.tDInfo
end

function ExpediteReportRes:getShareData(  )
	-- body
	return {
		ac=self.tAInfo.nCountry,
		an=self.tAInfo.sName,
		al=self.tAInfo.nLv,
		dc=self.tDInfo.nCountry,
		dn=self.tDInfo.sName,
		dl=self.tDInfo.nLv
	}
end


--获取战力
function ExpediteReportRes:getCombat( _nType )
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

function ExpediteReportRes:getLost( _nType )
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

-- function ExpediteReportRes:getReportType( )
-- 	-- body
-- 	if self.nType == 0 then--进攻方
-- 		if self.nWin == 0 then
-- 			--失败
-- 			return 3
-- 		else
-- 			--胜利
-- 			return 1
-- 		end
-- 	else    				--防守方
-- 		if self.nWin == 0 then
-- 			--胜利
-- 			return 4
-- 		else
-- 			--失败
-- 			return 2
-- 		end
-- 	end	
-- end


--获取对方玩家信息
function ExpediteReportRes:getOtherPlayerInfo( )
	-- body
	return self.tDInfo
end
--获取我的数据
function ExpediteReportRes:getMyArenaInfo(  )
	-- body
	return self.tAInfo		
end


return ExpediteReportRes


