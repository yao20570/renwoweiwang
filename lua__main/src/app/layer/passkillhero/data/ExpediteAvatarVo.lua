-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-3-20 11:32:03 星期二
-- Description: 过关斩将 进攻方玩家信息/防守方玩家信息
-----------------------------------------------------

local ActorVo = require("app.layer.playerinfo.ActorVo")
local ExpediteAvatarVo = class("ExpediteAvatarVo")

function ExpediteAvatarVo:ctor( tData )
	-- body
	self:myInit()
	self:update(tData)
end

--
function ExpediteAvatarVo:myInit(  )
	self.nPlayerId 	= nil --战斗对方玩家信息
	self.sName  	= "" -- name	String	名字
	self.nLv 		= 0  -- lv	Integer	等级
	self.nCountry 	= nil -- c iInteger	国家
 	self.sIcon  	= "" -- icon	String	目标头像
 	self.sBox   	= "" -- box	String	目标头像框
 	self.sTit 		= nil --
 	self.pAvator 	= nil
end

--从服务端获取数据刷新
function ExpediteAvatarVo:update( tData )
	
	self.nLv 		= tData.lv or self.nLv            -- lv	Integer	等级
	self.sName  	= tData.name or self.sName        -- name	String	名字	
	self.nPlayerId  = tData.aid or self.nPlayerId    -- 玩家ID
	self.nCountry 	= tData.c or self.nCountry 		 -- c iInteger	国家 	

	self.sIcon  	= tData.icon or self.sIcon       -- icon	String	目标头像
 	self.sBox  	 	= tData.box or self.sBox         -- box	String	目标头像框
 	self.sTit 		= tData.tit or self.sTit         -- tit string 称号
end


--头像
function ExpediteAvatarVo:getActorVo( ... )
	-- body
	if not self.pAvator then 	
 		self.pAvator = ActorVo.new() 		
 	end
 	self.pAvator:initData(self.sIcon, self.sBox, self.sTit)
	return self.pAvator
end

function ExpediteAvatarVo:getFightTitle(  )
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

--设置兵力
function ExpediteAvatarVo:setCombat( _nCombat )
	-- body
	self.nCombat = _nCombat or self.nCombat
end
return ExpediteAvatarVo


