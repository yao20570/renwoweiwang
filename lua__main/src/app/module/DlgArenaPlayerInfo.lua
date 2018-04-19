
-- Author: maheng
-- Date: 2018-1-23 10:26:24
-- 竞技场玩家信息


local DlgCommon = require("app.common.dialog.DlgCommon")
local RankHeroInfo = require("app.layer.rank.RankHeroInfo")

local DlgArenaPlayerInfo = class("DlgArenaPlayerInfo", function ()
	return DlgCommon.new(e_dlg_index.arenaplayerinfo, nil, 230)
end)

--构造
--_nDefaultIndex：默认选择哪一项
function DlgArenaPlayerInfo:ctor( )	
	-- body	
	self:myInit()	
	parseView("layout_arena_playerinfo", handler(self, self.onParseViewCallback))
end

operat_type = {
	chat 	= 1,--私聊
	friend 	= 2,--好友操作 
	praise 	= 3,--点赞
	assess  = 4, --战力评估
	report 	= 5,--举报	
	shield  = 6,--屏蔽
	changeicon = 7,--设置头像
}

--初始化成员变量
function DlgArenaPlayerInfo:myInit()
	-- body	
	self.tCurData = nil
	self.tBtnGroup = {}

	self.bIsAdd = false
	self.bIsDel = false
	self.bIsPb = false
	self.bIsInPb = false
	self.bIsZan = false

	self.tOperations = {}
end
  
--解析布局回调事件
function DlgArenaPlayerInfo:onParseViewCallback( pView )
	-- body
	self:addContentView(pView,false)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgArenaPlayerInfo",handler(self, self.onDestroy))
end

--初始化控件
function DlgArenaPlayerInfo:setupViews()
	-- body
	--设置标题 玩家名字
	self:setTitle("")
	--信息曾
	self.pLayInfo = self:findViewByName("lay_info")
	self.pImgLine = self:findViewByName("img_line")
	--
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconHero.NORMAL, type_icongoods_show.header, nil, TypeIconGoodsSize.L)
	self.pIcon:setIconIsCanTouched(false)

	--VIP等级
	self.pLbVipLV = self:findViewByName("lb_vip_lv")
	setTextCCColor(self.pLbVipLV,  _cc.yellow)
	self.pImgZan = self:findViewByName("img_dianzan")	

	--点赞次数
	self.pLbZan = self:findViewByName("lb_zan")	
	--等级
	self.pLbLV = self:findViewByName("lb_lv")	
	--官职
	self.pLbPos = self:findViewByName("lb_name")--	
	--战力
	self.pLbFC = self:findViewByName("lb_fc")	

	--国旗
	self.pImgFlag = self:findViewByName("img_flag")
	--总战力
	self.pLbPower = self:findViewByName("lb_zhanli")

	----左边箭头
	self.pImgArrow1 = self:findViewByName("img_arrow_1")
	self.pImgArrow1:setFlippedX(true)

	--武将
	self.tHeros = {}
	for i = 1, 4 do
		local phero = RankHeroInfo.new()
		phero:setPosition(125*(i - 1),30)
		self.pLayInfo:addView(phero,10)
		self.tHeros[i] = phero
	end
	self.tPos = {cc.p(14, -92), cc.p(188, -92), cc.p(356, -92), cc.p(14, -178), cc.p(188, -178), cc.p(356, -178)}
end

-- 修改控件内容或者是刷新控件数据
function DlgArenaPlayerInfo:updateViews()
	-- body
	--玩家信息显示
	if self.tCurData then
		--dump(self.tCurData, "self.tCurData", 100)
		--名字
		self:setTitle(self.tCurData.sName)
		--头像
		if self.tCurData.nID ~= Player.baseInfos.pid then
			self.pIcon:setCurData(self.tCurData)
			self.pIcon:setIconTitleImg(self.tCurData.sTitle) 
		else
			local pActorVo = Player:getPlayerInfo():getActorVo()
			self.pIcon:setCurData(pActorVo)
			self.pIcon:setIconTitleImg(pActorVo.sTitle) 
		end
		--建筑
		local sCityImg = getPlayerCityIcon(self.tCurData.nPLv, self.tCurData.nInfluence)
		if not self.pImgCityIcon then
			self.pImgCityIcon = MUI.MImage.new(sCityImg, {scale9=false})
			self.pLayInfo:addView(self.pImgCityIcon, 5)		
		else
			self.pImgCityIcon:setCurrentImage(sCityImg)
		end
		self.pImgCityIcon:setPosition(self.pLayInfo:getWidth() - (self.pImgCityIcon:getWidth()/2) - 15, 330)		
		
		--玩家等级
		local tStrLv = {
			{color=_cc.pwhite, text=getConvertedStr(6, 10250)},
			{color=_cc.white, text=self.tCurData.nLv},
		}
		self.pLbLV:setString(tStrLv, false)
		--vip等级
		self.pLbVipLV:setString(getVipLvString(self.tCurData.nVipLV), false)
		--官职		
		local tofficial = getNationTransport(self.tCurData.nOfficial)
		local soff = ""
		if tofficial then			
			soff = tofficial.name
		else
			soff = getConvertedStr(3, 10139)
		end
		local tStrOff = {
			{color=_cc.pwhite, text=getConvertedStr(6, 10245)},
			{color=_cc.white, text=soff},			
		}
		self.pLbPos:setString(tStrOff, false)
		--战力
		local tStrFC = {
			{color=_cc.pwhite, text=getConvertedStr(6, 10246)},
			{color=_cc.white, text=self.tCurData.nCombat},			
		}
		self.pLbFC:setString(tStrFC, false)
		--点赞次数	
		local strZan = {
			{color=_cc.pwhite, text=getConvertedStr(6, 10248)},
			{color=_cc.white, text=self.tCurData.nZan},
		}
		self.pLbZan:setString(strZan, false)
		--国旗
		self.pImgFlag:setCurrentImage(WorldFunc.getCountryFlagImg(self.tCurData.nInfluence))

		local sStrPower = {
			{color=_cc.pwhite, text=getConvertedStr(6, 10711)},
			{color=_cc.white, text=self.tCurData.nPower}
		}
		self.pLbPower:setString(sStrPower, false)

		--武将信息
		for i, v in pairs(self.tHeros) do
			v:setCurData(self.tCurData.tHeroList[i])
		end

		self:updateBtnOperations()			
	end	
end

--析构方法
function DlgArenaPlayerInfo:onDestroy()
	self:onPause()
end

-- 注册消息
function DlgArenaPlayerInfo:regMsgs( )
	-- body
	--注册好友信息刷新消息
	regMsg(self, gud_refresh_friends_msg, handler(self, self.updateViews))
	--注册玩家信息刷新消息
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateViews))	
end

-- 注销消息
function DlgArenaPlayerInfo:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_friends_msg)	
	unregMsg(self, gud_refresh_playerinfo)	
end


--暂停方法
function DlgArenaPlayerInfo:onPause( )
	-- body
	self:unregMsgs()
end

--继续方法
function DlgArenaPlayerInfo:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--设置玩家数据
function DlgArenaPlayerInfo:setCurData( _data )
	-- body
	--dump(_data, "_data=", 100)
	self.tCurData = _data
	self.tChatData = nil --聊天信息
	self:updateViews()
end

-- operat_type = {
-- 	chat 	= 1,--私聊
-- 	friend 	= 2,--好友操作
-- 	praise 	= 3,--点赞
-- 	report 	= 4,--举报
-- 	assess  = 5, --战力评估
-- 	shield  = 6,--屏蔽
-- 	changeicon = 7,--设置头像
-- }
function DlgArenaPlayerInfo:updateBtnOperations(  )
	-- body
	self.tOperations = {}
	for v = 1, 7 do
		local tOperate = nil
		if v == operat_type.chat then--私聊
			tOperate = {}
			tOperate.bEnable = true
			tOperate.nBtnType = TypeCommonBtn.M_BLUE
			tOperate.sTitle = getConvertedStr(5, 10125)
			tOperate.nHandler = handler(self, function ( ... )
				-- body
				if not Player:getFriendsData():isInBlackList(self.tCurData.nID) then--不在屏蔽列表中 
					local tObject = {} 
					tObject.nType = e_dlg_index.dlgchat --dlg类型
					tObject.nChatType = e_lt_type.sl --聊天类型
					tObject.tPChatInfo = {
						nPlayerId = self.tCurData.nID,
						sPlayerName = self.tCurData.sName,
					}
					Player:getFriendsData():addRecentRecord(self.tCurData.nID, self.tCurData, 1, true)				
					sendMsg(ghd_show_dlg_by_type,tObject)
					--半闭自己
					closeDlgByType(e_dlg_index.dlgrankplayerinfo, false)
				else
					TOAST(getConvertedStr(6, 10630))
				end
			end)
		elseif v == operat_type.friend then--好友操作
			if self.tCurData.nID ~= Player.baseInfos.pid then
				tOperate = {}
				tOperate.bEnable = true
				local pFriendVo = Player:getFriendsData():getFriendById(self.tCurData.nID)
				if pFriendVo then --已经添加好友 --删除好友
					tOperate.nBtnType = TypeCommonBtn.M_RED
					tOperate.sTitle = getConvertedStr(6, 10568)
					tOperate.nHandler = handler(self, function ( ... )
						-- body
						if self.bIsDel then
							return
						end		
						self.bIsDel = true
						SocketManager:sendMsg("deleteFriend", {self.tCurData.nID}, handler(self, self.onGetDataFunc))	--删除好友								
					end)
				else --添加好友
					tOperate.nBtnType = TypeCommonBtn.M_BLUE
					tOperate.sTitle = getConvertedStr(6, 10546)	
					tOperate.nHandler = handler(self, function ( ... )
						if self.bIsAdd then
							return
						end
						self.bIsAdd = true
						SocketManager:sendMsg("reqAddFriend", {nil, self.tCurData.sName}, handler(self, self.onGetDataFunc))--添加好友									
					end)							
				end					
			end		
		elseif v == operat_type.praise then--点赞
			tOperate = {}
			tOperate.nBtnType = TypeCommonBtn.M_BLUE
			tOperate.sTitle = getConvertedStr(5, 10142)
			if self.tCurData and self.tCurData.nHadZan and self.tCurData.nHadZan == 1 then--已经点赞
				tOperate.bEnable = false
			else
				tOperate.bEnable = true
			end
			tOperate.nHandler = handler(self, function ( ... )
				-- body
				if self.bIsZan then
					return
				end
				self.bIsZan = true
				SocketManager:sendMsg("thumbupFriend", {self.tCurData.nID}, handler(self, self.onGetDataFunc))	--点赞好友	
			end)
		elseif v == operat_type.report then--举报
			if self.tChatData ~= nil then
				tOperate = {}
				tOperate.bEnable = true
				tOperate.nBtnType = TypeCommonBtn.M_RED
				tOperate.sTitle = getConvertedStr(5, 10143)
				tOperate.nHandler = handler(self, function ( ... )
					-- body
					local tObject = {}
					tObject.nType = e_dlg_index.dlgfriendreport --dlg类型 举报
					tObject.tData = self.tChatData
					sendMsg(ghd_show_dlg_by_type,tObject)   
				end)
			end
		elseif v == operat_type.assess then --战力评估
			tOperate = {}
			tOperate.bEnable = true
			tOperate.nBtnType = TypeCommonBtn.M_BLUE
			if self.tCurData.nID == Player.baseInfos.pid then--战力评估
				tOperate.sTitle = getConvertedStr(7, 10304)
				tOperate.nHandler = handler(self, function ( ... )
					local tObject = {
					    nType = e_dlg_index.dlgpowermark, --dlg类型
					    nPlayerId = self.tCurData.nID, --玩家id
					    sName = self.tCurData.sName,
					    nLv = self.tCurData.nLv,
					}
					sendMsg(ghd_show_dlg_by_type, tObject)	  
				end)
			else--战力对比
				tOperate.sTitle = getConvertedStr(6, 10745)
				tOperate.nHandler = handler(self, function ( ... )
					local tObject = {
					    nType = e_dlg_index.dlgpowerbalance, --dlg类型
					    nPlayerId = self.tCurData.nID, --玩家id
					    sName = self.tCurData.sName,
					    nLv = self.tCurData.nLv,
					}
					sendMsg(ghd_show_dlg_by_type, tObject)	  
				end)
			end
		elseif v == operat_type.shield then--屏蔽
			if self.tCurData.nID ~= Player.baseInfos.pid then
				tOperate = {}
				tOperate.bEnable = true
				local pFriendVo = Player:getFriendsData():getBlackFriend(self.tCurData.nID)
				if pFriendVo then--解除屏蔽 
					tOperate.nBtnType = TypeCommonBtn.M_RED
					tOperate.sTitle = getConvertedStr(6, 10569)
					tOperate.nHandler = handler(self, function ( ... )
						-- body
						if self.bIsInPb then
							return
						end		
						self.bIsInPb = true	
						SocketManager:sendMsg("removeshieldFriend", {self.tCurData.nID}, handler(self, self.onGetDataFunc))--解除屏蔽
					end)						
				else--屏蔽
					tOperate.nBtnType = TypeCommonBtn.M_RED
					tOperate.sTitle = getConvertedStr(5, 10144)
					tOperate.nHandler = handler(self, function ( ... )
						if self.bIsPb then
							return
						end
						self.bIsPb = true
						SocketManager:sendMsg("shieldFriend", {self.tCurData.nID, self.tCurData.sName}, handler(self, self.onGetDataFunc))--屏蔽玩家
					end)					
				end			
			end			
		elseif v == operat_type.changeicon then--设置头像
			if self.tCurData.nID == Player.baseInfos.pid then
				tOperate = {}
				tOperate.bEnable = true
				tOperate.nBtnType = TypeCommonBtn.M_BLUE
				tOperate.sTitle = getConvertedStr(6, 10628)	
				tOperate.nHandler = handler(self, function (  )
					local tObject = {}
					tObject.nType = e_dlg_index.dlgiconsetting --dlg类型
					sendMsg(ghd_show_dlg_by_type,tObject)						
				end)							
			end				
		end		
		if tOperate then
			table.insert(self.tOperations, tOperate)
		end		 
	end
	-- dump(self.tOperations, "self.tOperations", 100)
	for i = 1, 6 do
		local tOperate = self.tOperations[i]
		local playbtn = self:findViewByName("lay_btn_"..i)
		if not self.tBtnGroup[i] and tOperate then				
			local pBtn = getCommonButtonOfContainer(playbtn, tOperate.nBtnType, tOperate.sTitle, false)			
			self.tBtnGroup[i] = pBtn		
		end
		if self.tBtnGroup[i] then
			if tOperate then
				self.tBtnGroup[i]:setVisible(true)
				self.tBtnGroup[i]:setBtnEnable(tOperate.bEnable)
				self.tBtnGroup[i]:setButton(tOperate.nBtnType, tOperate.sTitle)--删除好友
				self.tBtnGroup[i]:onCommonBtnClicked(tOperate.nHandler) 
			else
				self.tBtnGroup[i]:setVisible(false)
			end
		end
	end	
end

--接收服务端发回的登录回调
function DlgArenaPlayerInfo:onGetDataFunc( __msg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.deleteFriend.id then--删除好友       		

       	elseif __msg.head.type == MsgType.reqAddFriend.id then--添加好友

		elseif __msg.head.type == MsgType.thumbupFriend.id then--点赞玩家
			if __msg.body then
				if self.tCurData then
					self.tCurData:refreshZan(__msg.body)
					self:updateViews()
				end
			end
       	elseif __msg.head.type == MsgType.removeshieldFriend.id then--解除屏蔽

       	elseif __msg.head.type == MsgType.shieldFriend.id then--屏蔽玩家

        end
    else
        --弹出错误提示语
        --TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
    if self.bIsAdd then
    	self.bIsAdd = false
    end
    if self.bIsDel then
    	self.bIsDel = false
    end
    if self.bIsZan then
    	self.bIsZan = false
    end
    if self.bIsPb then
    	self.bIsPb = false
    end
    if self.bIsInPb then
    	self.bIsInPb = false
    end
end
return DlgArenaPlayerInfo
