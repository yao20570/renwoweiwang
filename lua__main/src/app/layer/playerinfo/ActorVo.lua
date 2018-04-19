-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-11-9 14:14:43 星期四
-- Description: 玩家形象
-----------------------------------------------------


local ActorVo = class("ActorVo")

function ActorVo:ctor(  )
	self:myInit()
end

function ActorVo:myInit(  )
	-- body
	--基础信息
	self.sI 		= 	"" 						--头像ID
	self.sB 		=   ""						--头像框ID
	self.sT 		= 	nil 						--t	String	当前的称号
	self.sIcon 		= 	"ui/daitu.png"--getPlayerIconStr() 		--i	String	当前头像 初始化默认头像
	self.sIconBg 	= 	"#v2_img_kapaiygwc.png" --getPlayerIconBg() 		--b	String	当前的头像框
	
	self.sTitle 	=   nil

end

-- 根据服务端信息调整数据
function ActorVo:refreshDatasByService( tData )
	--基础信息
	if not tData then
		return
	end
	self.sI 		= 	tData.i or self.sI
	self.sB 		=   tData.b or self.sB
	self.sT 		= 	tData.t or self.sT 		
	--dump(tData, "tData", 100)
	if tData.i then
		self.sIcon 	= 	getPlayerIconStr(tData.i)		--i	String	当前头像
	end
	if tData.b then
		self.sIconBg 	= 	getPlayerIconBg(tData.b)
	end
	if tData.t then
		self.sTitle = 	getPlayerTitle(tData.t)
	end

	--发送聊天头像变化消息
	sendMsg(ghd_chat_icon_refresh_msg, Player.baseInfos.pid)
end

--
function ActorVo:initData( sIcon, sIconBg, sDes )
	-- body
	self.sI 		= 	sIcon or self.sI
	self.sB 		=   sIconBg or self.sB
	self.sT 		= 	sDes or self.sT 		
	--dump(tData, "tData", 100)
	self.sIcon 		= 	getPlayerIconStr(sIcon)		--i	String	当前头像
	self.sIconBg 	= 	getPlayerIconBg(sIconBg)
	self.sTitle  = 	getPlayerTitle(sDes)
end

function ActorVo:setIcon( sIcon ) 
	self.sIcon = sIcon
end

function ActorVo:setIconBg( sIconBg )
	self.sIconBg = sIconBg
end

function ActorVo:setNpcData( tData)
	self.tNpc = tData
end

function ActorVo:getNpcData(  )
	return self.tNpc
end

return ActorVo
