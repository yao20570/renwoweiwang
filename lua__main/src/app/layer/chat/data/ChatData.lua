----------------------------------------------------- 
-- author: liangzhaowei
-- Date: 2017-06-01 14:54:32
-- Description: 聊天的数据
-----------------------------------------------------
local MailFunc = require("app.layer.mail.MailFunc")
local ChatData = class("ChatData")
local ActorVo = require("app.layer.playerinfo.ActorVo")


function ChatData:ctor(  )
	-- body
	self:myInit()
end

function ChatData:myInit(  )

	self.nRollTime   = 0  
	self.nGapTime 	 = nil		--滚动次数大于1的，每间隔5分钟滚动一次
	self.sAn	     = ""   	-- 接收者名字
	self.nIe	     = nil   	-- 发送信息的国家
	self.nId	     = 0    	-- 聊天记录的id
	self.nSid	     = 0   	    -- 发送者的id
	self.nBt	     = 0   	    -- 官职
	self.sSn	     = ""   	-- 昵称(发送者名字)
	self.nVip	     = 0   	    -- vip等级
	self.tAid	     = {}       -- 接受者列表(1世界;2国家;3私聊)
	self.sCnt	     = ""   	-- 消息内容
	self.nSt	     = 0   	    -- 消息时间
	self.nTmsg       = 0  	    -- 信息类型 1玩家,2系统信息 3世界喇叭
	self.nWay	     = 0        -- 跳转到的id
	self.sPos	     = ""       -- 发送者地理位置
	self.nS	         = nil      -- 游戏所在地区
	self.sIcon       = "ui/daitu.png"
	self.sBox        = "#v1_img_touxiangkuanglan.png"
	self.tFl	     = nil      -- List<String>	填充内容列表
	self.nNid	     = nil      -- Long	个人分享的模板
	self.sPa	     = nil      -- String	个人分享参数
	self.nMode	     = nil      -- mode	Integer	跳转的类型
	self.nQt	     = nil      -- qt	Integer	分享对象的id(装备id,英雄id,神兵id)
	self.tPoint	     = nil      -- point	PointVO	坐标
	self.nMap        = 0        -- 存在多条相同信息的关联id
	self.nASid       = nil      -- 接收者的id

	self.nCLv=0 			--城池或boss等级
	self.nCc = 0 			--所属国家

	self.nCTid =0 			--国战城池id

	self.nCns=0 			--召唤总数
	self.nJs=0 				--召唤参与人数
	self.tHs=nil 			--武将的神将补充

	--前端添加字段
	self.strUrl	     = nil      -- 跳转网址
	self.nAccperId   = 0 --接受者类型(1世界;2国家;3私聊;4滚屏)

	self.nIsChatCard	 =nil 	--是否是卡片
	self.sChatCardBg	 =nil 	--卡片背景
	self.sChatCardTitle	 =nil 	--卡片标题图片
	self.sChatCardDetail	 =nil 	--卡片描述文字
	self.sShareContent=nil 		--卡片的第一行内容
	self.sShareContent2=nil 		--卡片的第二行内容

	self.nAc=nil 		--发送者的国家
	self.nDc =nil 		--被分享者的国家

	self.nShareType =nil 		--分享的类型

	self.tPa =nil 			--分享内容（经解析）

	
	--self.pActorVo 	 = 			ActorVo.new()
	self.nRpId 		 = 0 		--红包ID
	self.nRpt 		 = 0 		--红包状态 0正常1抢过2抢光了
	self.bIsRb = nil
	self.nJumpTab = 0
end
-- 通过服务器数据刷新本地数据
function ChatData:refreshByService( tData )
	self.nAccperId   =  tData.nAccperId      or self.nAccperId  --接受者类型(1世界;2国家;3私聊;4滚屏)


	self.nId	     =  tData.id	         or self.nId	   	-- 聊天记录的id
	self.nSid	     =  tonumber(tData.sid)	 or self.nSid	   	-- 发送者的id
	self.sAn	     =  tData.an	         or self.sAn	   	-- 接收者名字
	self.nIe	     =  tData.ie	         or self.nIe	   	-- 发送信息的国家
	self.nBt	     =  tData.bt	         or self.nBt	   	-- 官职
	self.sSn	     =  tData.sn	         or self.sSn	   	-- 昵称(发送者名字)
	self.nVip	     =  tData.vip	         or self.nVip	   	-- vip等级
	self.tAid	     =  tData.aid	         or self.tAid	   	-- 接受者列表(1世界;2国家;3私聊)
	self.sCnt	     =  tData.cnt	         or self.sCnt	   	-- 消息内容
	if self.sCnt and type(self.sCnt) == "string" then
		self.sCnt = string.gsub(self.sCnt,"%[0x.-%]","*")
	end
	self.nSt	     =  tonumber(tData.st)	 or self.nSt	   	-- 消息时间
	self.nTmsg       =  tData.tmsg           or self.nTmsg   	-- 信息类型 1玩家,2系统信息 3世界喇叭,4玩家红包分享 5 系统红包分享
	self.nWay	     =  tonumber(tData.way)	 or self.nWay	    -- 跳转到id
	self.sPos	     =  tData.pos	         or self.sPos	    -- 发送者地理位置
	self.nS	         =  tData.s	             or self.nS	        -- 游戏所在地区

	self.nRollTime   =  tData.co 			 or self.nRollTime   
	self.tFl	     =  tData.fl	         or self.tFl	        -- List<String>	填充内容列表
	self.nNid	     =  tonumber(tData.nid)  or self.nNid	        -- Long	个人分享的模板id
	self.sPa	     =  tData.pa	         or self.sPa	        -- String	个人分享参数

	self.nMode	     =  tData.mode	         or self.nMode	        -- mode	Integer	跳转的类型
	self.nQt	     =  tData.qt	         or self.nQt		        -- qt	Integer	分享对象的id(装备id,英雄id,神兵id)
	self.tPoint	     =  tData.point	         or self.tPoint	        -- point	PointVO	坐标
	self.nMap        =  tData.map            or self.nMap           -- 存在多条相同信息的关联id

	--滚屏独有
	self.nGapTime	 =  tData.gt	           or self.nGapTime	        --滚动次数大于1的，每间隔5分钟滚动一次
	
	self.nASid       =  tonumber(tData.ad)             or self.nASid     -- 接收者的id

	self.nCLv		 =	tData.clv			--城池或boss等级
	self.nCc 		 =	tData.cc 			--所属国家

	self.nCTid 		 =	tData.ctId 			--国战城池id

	self.nCns 		=	tData.cns 			--召唤总人数
	self.nJs 		=	tData.js 			--召唤参与人数
	self.tHs        =   tData.hs 			--武将的属性补充
	if tData.rb then
		self.bIsRb 		= 	tData.rb == 1 		--是否是机器人 0 不是，1 是
	end
	--截取url网址
	self:anSyUrl()

	-- 聊天头像
	if tData.ac then
		if getAvatarIcon(tData.ac) and getAvatarIcon(tData.ac).sIcon then
			self.sIcon = getAvatarIcon(tData.ac).sIcon
		end
	end

	--玩家等级
	self.nLv = tData.lv or nil	


	--红包ID	
	self.nRpId 	= tData.rpId or self.nRpId	
	self.nRpt 	= tData.rpt or self.nRpt

	-- 聊天头像背景框
	if tData.box then
		if getAvatarBoxIcon(tData.box) and getAvatarBoxIcon(tData.box).sIcon then
			self.sBox = getAvatarBoxIcon(tData.box).sIcon
		end
	end
	
	--self.pActorVo:initData(tData.ac, tData.box, nil)

	--解析系统配置内容
	self:anSystemCn()

	--如果没有转换成table格式的都转换一下
	if type(self.sCnt) ~= "table" then
		self.sCnt = getTextColorByConfigure(self.sCnt)
	end


end


--解析系统配置内容
function ChatData:anSystemCn()

	if not self.nNid then
		return
	end

	--聊天内容
	local strChatCn = ""
	local tSharePa = ""

	local nPosX = nil--分享坐标中的x
	local nPosY = nil--分享坐标中的y

	local nAcountry =nil --分享者的国家
	local nDcountry =nil --被分享者的国家
	local nShareType=nil

	self.nGuide	= nil --引导id
	local pShareData = nil
	if self.nNid > 0 and self.nNid < 2000 then--分享模板内容
		pShareData = getChatCommonNotice(self.nNid)
		if self.sPa then
			tSharePa = json.decode(self.sPa)
			if type(tSharePa) == "table" then
				for k,v in pairs(tSharePa) do
					if k == "dx" then --跳转坐标x
						nPosX = v
					end
					if k =="dy" then--跳转坐标y
						nPosY = v
					end

					if k=="ac" then
						nAcountry=v
					end
					if k=="dc" then
						nDcountry=v
					end

					if k=="dt" then
						nShareType=v
					end

				end
			end
		end
	elseif  self.nNid > 2000 then --系统模板
		pShareData = getChatActivityNotice(self.nNid)
		if self.tFl and table.nums(self.tFl)> 0 then
			-- dump(self.tFl)
			tSharePa = self.tFl
		end
	end

	self.tPa=tSharePa
	--解析分享坐标
	if not self.tPoint then
		if nPosX and nPosY then
			self.tPoint = {}
			self.tPoint.x = nPosX
			self.tPoint.y = nPosY
		end
	end

	--解析分享内容
	if pShareData and pShareData.noticecontent then
		
		local nType = 1 --默认为1的解析方式
		if pShareData.fill then
			nType = pShareData.fill
		end
		strChatCn = MailFunc.getTranslateStr( pShareData.noticecontent, tSharePa, nType, self.tHs)
		self.nGuide = pShareData.guide
		self.nJumpNum = pShareData.jumpnumber
	end

	if strChatCn and  strChatCn ~= "" then
		self.sCnt = strChatCn
	end

	if nAcountry then
		self.nAc=nAcountry
	end
	if nDcountry  then
		self.nDc=nDcountry
	end

	if nShareType then
		self.nShareType=nShareType
	end
	if pShareData.cardchat and (pShareData.cardchat==1 or pShareData.cardchat==2) then 	--卡片
		local nType = 1 --默认为1的解析方式
		if pShareData.fill then
			nType = pShareData.fill
		end
		if pShareData.sharecontent then
			local sTemp= MailFunc.getTranslateStr( pShareData.sharecontent, tSharePa, nType)

			if sTemp then
				self.sShareContent = sTemp 
			end
		end
		if pShareData.sharecontent2 then
		local sTemp= MailFunc.getTranslateStr( pShareData.sharecontent2, tSharePa, nType)

			if sTemp then
				self.sShareContent2 = sTemp 
			end
		end

		self.nIsChatCard=pShareData.cardchat
		self.sChatCardBg= "#"..pShareData.chatpicture..".png"
		self.sChatCardTitle= "#"..pShareData.picture..".png"
		self.sChatCardDetail= pShareData.notice
		
	end
	self.sSenderNameDb = pShareData.sendname    --配置里的名字
	if pShareData.icon and pShareData ~= "" then
		self.sSenderNameIcon ="#".. pShareData.icon ..".png"   --配置里的头像
	end

	if pShareData.jumptap then
		self.nJumpTab = pShareData.jumptap
	end

end

--解析跳转网址
function ChatData:anSyUrl()
	local tCnt = luaSplit(self.sCnt,"|`'")
	if tCnt and table.nums(tCnt)> 1 then
		self.sCnt = tCnt[1]
		self.strUrl = tCnt[2]
	end
end

--获取私聊目标id
function ChatData:getPChatPlayerId( )
	if self.nAccperId == e_lt_type.sl then
		if self.nSid == Player:getPlayerInfo().pid then
			return self.nASid
		end
		return self.nSid
	end
	return nil
end

--获取私聊目标名字
function ChatData:getPChatPlayerName( )
	if self.nAccperId == e_lt_type.sl then
		if self.nSid == Player:getPlayerInfo().pid then
			return self.sAn
		end
		return self.sSn
	end
	return nil
end
--刷新时间
function ChatData:updateRedPock( _nRpt )
	-- body
	self.nRpt 	= _nRpt or self.nRpt
end

--是否是红包
function ChatData:getIsRedPacket( )
	return self.nIsChatCard == 2
end

--是否是抢红包记录
function ChatData:getIsRPRecord( )
	--是否是抢红包记录
	return self.bRP
end

--是否是卡牌
function ChatData:getIsCard( )
	return self.nIsChatCard == 1
end

--获取是否是普通聊天
function ChatData:getIsChat( )
	if self:getIsRedPacket() or self:getIsRPRecord() or self:getIsCard() then
		return false
	end
	return true
end

return ChatData

