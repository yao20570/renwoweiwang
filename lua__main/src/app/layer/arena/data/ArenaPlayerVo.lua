-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-1-19 17:04:03 星期五
-- Description: 竞技场战斗记录
-----------------------------------------------------

local ActorVo = require("app.layer.playerinfo.ActorVo")
local MailFunc = require("app.layer.mail.MailFunc")
local ArenaPlayerVo = class("ArenaPlayerVo")

function ArenaPlayerVo:ctor( tData )
	-- body
	self:myInit()
	self:update(tData)
end

--
function ArenaPlayerVo:myInit(  )
	self.nPlayerId 	= nil --战斗对方玩家信息
	self.sName  	= "" -- name	String	名字
	self.nLv 		= 0  -- lv	Integer	等级
	self.nCountry 	= nil -- c iInteger	国家
	self.nBr 		= 0  -- br	Integer	进攻方排名变化前
	self.nAr 		= 0  -- ar	Integer	进攻方排名变化后  	
 	self.sIcon  	= "" -- icon	String	目标头像
 	self.sBox   	= "" -- box	String	目标头像框
 	self.sTit 		= nil --
 	self.pAvator 	= nil
end

--从服务端获取数据刷新
function ArenaPlayerVo:update( tData )
	
	self.nLv 		= tData.level or self.nLv            -- lv	Integer	等级
	self.sName  	= tData.name or self.sName        -- name	String	名字	
	self.nPlayerId  = tData.tarId or self.nPlayerId   -- 玩家ID
	self.nCountry 	= tData.country or self.nCountry  -- c iInteger	国家 	
	self.nBr 		= tData.br or self.nBr            -- br	Integer	进攻方排名变化前
	self.nAr 		= tData.ar or self.nAr            -- ar	Integer	进攻方排名变化后 

	self.sIcon  	= tData.icon or self.sIcon       -- icon	String	目标头像
 	self.sBox  	 	= tData.box or self.sBox         -- box	String	目标头像框
 	self.sTit 		= tData.tit or self.sTit         -- tit string 称号
end


--头像
function ArenaPlayerVo:getActorVo( ... )
	-- body
	if not self.pAvator then 	
 		self.pAvator = ActorVo.new() 		
 	end
 	self.pAvator:initData(self.sIcon, self.sBox, self.sTit)
	return self.pAvator
end

function ArenaPlayerVo:getFightTitle(  )
	-- body	
	local sText = ""
	local sCountry = getCountryShortName(self.nCountry, true)
	if sCountry then
		sText = sText..sCountry
	end
	if self.sName then
		sText = sText..self.sName
	end
	if self.nLv then
		sText = sText..getLvString(self.nLv, false)
	end
	return sText
end
--
function ArenaPlayerVo:getMailStr()
	local sStr = ""
	sStr = string.format("%s:%s;%s:%s;",getCountryShortName(self.nCountry, true),
		getColorByCountry(self.nCountry),
		self.sName..getLvString(self.nLv, false),_cc.blue)		
	return sStr
end

--设置兵力
function ArenaPlayerVo:setCombat( _nCombat )
	-- body
	self.nCombat = _nCombat or self.nCombat
end

return ArenaPlayerVo


