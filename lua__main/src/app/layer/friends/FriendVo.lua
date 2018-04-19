-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-10-14 17:41:23 星期二
-- Description: 排行榜数据
-----------------------------------------------------
local Goods = require("app.data.Goods")
local FriendVo = class("FriendVo", Goods)
function FriendVo:ctor(  )
	FriendVo.super.ctor(self,e_type_goods.type_head)
	-- body
	self:myInit()
end

function FriendVo:myInit(  )
	-- body
	self.nQuality 		= 	3     -- 品质（int）	

	self.nInfluence 	= 	0 	-- 势力
	self.nPower 		= 	0 	-- 战力
	self.nSt 			= 	nil   --最近登录时间
	self.nCanGet    	= 	0   --是否能够接受鼓舞
	self.nGive      	= 	0   --好友是否赠送我体力 1是,0否
	self.nGetEnergy 	= 	0   --是否领取了体力
	self.nNr 			=   0   --未读信息红点
	self.nGt 			=   0 	--赠送体力的时间
	self.bNew 			= 	false   --新好友标志true是false否

	self.sIconBg 		=   nil	--头像框
	self.sIcon          =   nil --头像
	self.sTitle 		= 	nil
	self.sI 		= 	"" 						--头像ID
	self.sB 		=   ""						--头像框ID
	self.sT 		= 	"" 						--t	String	当前的称号
	self.bIsRb 		=   nil
end

-- 根据服务端信息调整数据
function FriendVo:refreshDatasByService( tData)
	-- body
	self.nGive 			=  	tData.get or self.nGive 		--Integer	好友是否赠送我体力 1是,0否
	self.nGetEnergy 	=  	tData.g or self.nGetEnergy 	--Integer	是否领取了体力 1领取0未领取
	self.nCanGet 		=  	tData.on or self.nCanGet		--Integer	好友是否还能接受鼓舞 0--能接受鼓舞 1--不能接受鼓舞
 	self.sTid 			=  	tData.aid or self.sTid 		--Long		玩家的id 
	self.sName 			=  	tData.sn or self.sName 		--String	玩家的名字

	self.sI = tData.ac or self.sI
	self.sB = tData.box or self.sB
	self.sT = tData.tit or self.sT
	if tData.ac then
		self.sIcon 		=  	getPlayerIconStr(tData.ac)  --String	玩家的头像
	end	
	if tData.box then
		self.sIconBg 	= 	getPlayerIconBg(tData.box)
	end
	if tData.tit then
		self.sTitle 	=  	getPlayerTitle(tData.tit) 
	end
	self.nLv 			=  	tData.lev or self.nLv 		--Integer	玩家的等级
	self.nInfluence 	=  	tData.c or self.nInfluence 	--Integer	玩家所属国家
	self.nPower 		=  	tData.sc or self.nPower 		--Long		玩家的战力
 	self.nSt 			=  	tData.st or self.nSt 		--Long		玩家最近登录时间
 	self.nNr  			= 	tData.nr or self.nNr 		--未读消息红点
 	self.nGt 			=   tData.gt or self.nGt 		--好友赠送体力的时间
 	if tData.rb then
	 	self.bIsRb 			= 	tData.rb == 1 		--是否是机器人 0 不是，1 是
	 end
end

function FriendVo:setIsNew( _bNew )
	-- body
	self.bNew = _bNew or false
end

function FriendVo:isNew(  )
	-- body
	return self.bNew 
end

function FriendVo:refreshByChatData( tData )
	-- body
	if not tData then
		return
	end
	self.sTid 			=  tonumber(tData.sid) or self.sTid
	if tData.ac then
		self.sIcon 			=  	getPlayerIconStr(tData.ac) --String	玩家的头像
 	end	
 	if tData.box then
 		self.sIconBg 		= 	getPlayerIconBg(tData.box)
 	end
	if tData.tit then
		self.sTitle 	=  	getPlayerTitle(tData.tit) 
	end 	
	self.sI = tData.ac or self.sI
	self.sB = tData.box or self.sB
	self.sT = tData.tit or self.sT

 	self.sName 			=  	tData.sn or self.sName 		--String	玩家的名字
 	self.nSt 			=  	tData.st or self.nSt 		--Long		玩家最近登录时间
 	self.nInfluence 	=  	tData.ie or self.nInfluence 	--Integer	玩家所属国家
	self.nLv 			=  	tData.lev or self.nLv 		--Integer	玩家的等级 	
	self.bIsRb 			= 	tData.bIsRb or self.bIsRb 		
	
end
--tData SPlayerData  
function FriendVo:refreshByChackPlayer( tData )
	-- body
	if not tData then
		return
	end

 	self.sTid 			=  	tData.nID or self.sTid 			--Long		玩家的id 
	self.sName 			=  	tData.sName or self.sName 		--String	玩家的名字
	self.sIcon 			=  	tData.sIcon or self.sIcon 		--String	玩家的头像
	self.sIconBg 		= 	tData.sIconBg or self.sIconBg
	self.nInfluence 	=  	tData.nInfluence or self.nInfluence 	--Integer	玩家所属国家	
	self.nLv 			=  	tData.nLv or self.nLv 		--Integer	玩家的等级	

	self.sIcon 			=  	tData.sIcon or self.sIcon 		--String	玩家的头像
	self.sIconBg 		= 	tData.sIconBg or self.sIconBg
	self.sTitle  		=   tData.sTitle or self.sTitle
	self.sI = tData.sI or self.sI
	self.sB = tData.sB or self.sB
	self.sT = tData.sT or self.sT
	self.bIsRb 			= 	tData.bIsRb or self.bIsRb 
end


function FriendVo:refreshByCityDot( _tData )
	-- body
	
end

function FriendVo:getTid( )
	return self.sTid
end

function FriendVo:getInfluence( )
	return self.nInfluence
end

return FriendVo