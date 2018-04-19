-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-10-14 14:14:40 星期六
-- Description: 好友
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local MImgLabel = require("app.common.button.MImgLabel")
local ItemFriend = class("ItemFriend", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemFriend:ctor(  )
	-- body
	self:myInit()
	parseView("item_friend", handler(self, self.onParseViewCallback))
	
end

--初始化成员变量
function ItemFriend:myInit(  )
	-- body
	self.nShowType 			= 	1                   --好友信息界面
	self.tCurData 			= 	nil 				--当前数据	

	self.bIsEnc = false--鼓舞
	self.bIsGet = false--领取体力
	self.bIsDel = false--移除
end

--解析布局回调事件
function ItemFriend:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemFriend",handler(self, self.onItemFriendDestroy))
end

--初始化控件
function ItemFriend:setupViews( )
	-- body
	self.pLayRoot 	= self:findViewByName("root_item_friend")

	self.pLayIcon 	= self:findViewByName("lay_icon") --玩家头像层
	self.pLbParam1 	= self:findViewByName("lb_pram_1")--玩家名字等级	
	self.pLbParam2 	= self:findViewByName("lb_pram_2")--玩家战力
	self.pLbParam3 	= self:findViewByName("lb_pram_3")--国家势力
	self.pLayBtn1 	= self:findViewByName("lay_btn_1")--
	self.pLayBtn2 	= self:findViewByName("lay_btn_2")
	self.pBtn1 = getCommonButtonOfContainer(self.pLayBtn1, TypeCommonBtn.M_BLUE, getConvertedStr(6, 10549), false)--聊天
	self.pBtn2 = getCommonButtonOfContainer(self.pLayBtn2, TypeCommonBtn.M_YELLOW, getConvertedStr(6, 10550), false)--鼓舞	

	self.pImgLabel = MImgLabel.new({text="", size=20, parent=self.pLayBtn2})
	self.pImgLabel:setImg("#v2_img_zjm_tili.png", 1, "left")
	local tStr = {
		--{color=_cc.pwhite, text=getConvertedStr(1, 10062)},
		{color=_cc.white, text=getChatInitParam("sendPowerOnce")},	
	}
	self.pImgLabel:setString(tStr)
	self.pImgLabel:followPos("left", self.pLayBtn2:getContentSize().width/2-self.pImgLabel:getWidth()/2, self.pLayBtn2:getContentSize().height + 20, 10)		
end

-- 修改控件内容或者是刷新控件数据
function ItemFriend:updateViews( )
	-- body
	if not self.tCurData then
		--print("玩家数据异常！")
		return
	end
	--dump(self.tCurData, "self.tCurData",10)	
	if not self.pIcon then
		self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconHero.NORMAL,type_icongoods_show.header, self.tCurData, TypeIconHeroSize.L)
		self.pIcon:setIconClickedCallBack(function (  )
			-- body
				
			if self.tCurData.bIsRb then   --机器人的话走另一套协议
			
				SocketManager:sendMsg("playWithRobot", {self.tCurData.sTid, 6}, function ( __msg ,__oldMsg)
					-- body
					if __msg.head.state == SocketErrorType.success	then
						--查看玩家数据
						local SPlayerData = require("app.layer.rank.SPlayerData")
						if __msg.body.pm then
							local temp = SPlayerData.new()
							__msg.body.pm.rb = 1    --自己给他加上机器人标志
							temp:refreshDatasByService(__msg.body.pm)
							--刷新聊天头像数据				
							if not b_open_ios_shenpi then
								local tObj = {}
								tObj.tplayerinfo = temp
								-- tObj.tChatData = self.pData
								showRankPlayerInfo(tObj)						
							end
						end
					else		
						TOAST(SocketManager:getErrorStr(__msg.head.state))
					end			
				end)
			else
				local pMsgObj = {}
				pMsgObj.nplayerId = self.tCurData.sTid
				pMsgObj.bToChat = false
				--发送获取其他玩家信息的消息
				sendMsg(ghd_get_playerinfo_msg, pMsgObj)	
			end		
		end)
	else
		self.pIcon:setCurData(self.tCurData)
	end
	--玩家名字等级
	local sName = self.tCurData.sName or ""
	self.pLbParam1:setString(sName..getLvString(self.tCurData.nLv, true), false)
	setTextCCColor(self.pLbParam1, getColorByQuality(self.tCurData.nQuality))

	--战力
	local tStr2 = {
		{color=_cc.pwhite, text=getConvertedStr(3, 10233)},
		{color=_cc.white, text=formatCountToStr(self.tCurData.nPower)},
	}
	self.pLbParam2:setString(tStr2, false)
	--国家
	local tStr3 = {
		{color=_cc.pwhite, text=getConvertedStr(6, 10241)},
		{color=_cc.white, text=getCountryShortName(self.tCurData.nInfluence, false)},
	}
	self.pLbParam3:setString(tStr3, false)

	self.pBtn2:setBtnEnable(true)
	self.pBtn2:onCommonBtnDisabledClicked(nil)
	if self.nShowType == 1 then--好友列表
		self.pLayBtn1:setVisible(true)
		self.pLayBtn2:setVisible(true)
		self.pLayBtn1:setPositionY(70)
		self.pLayBtn2:setPositionY(10)		
		self.pBtn1:setButton(TypeCommonBtn.M_BLUE, getConvertedStr(6, 10549))--聊天
		self.pBtn1:onCommonBtnClicked(handler(self, self.onChatCallBack))
		self.pBtn2:setButton(TypeCommonBtn.M_YELLOW, getConvertedStr(6, 10550))--鼓舞	
		self.pBtn2:onCommonBtnClicked(handler(self, self.onEncourageCallBack))

		self.pImgLabel:hideImg()
		self.pImgLabel:setVisible(false)

		if self.tCurData.nCanGet == 1 then
			--不能鼓舞
			self.pBtn2:setBtnEnable(false)
			self.pBtn2:onCommonBtnDisabledClicked(function ( ... )
				-- body
				TOAST(getConvertedStr(6,10558))
			end)
		end
	elseif self.nShowType == 2 then--获取体力
		self.pLayBtn1:setVisible(false)
		self.pLayBtn2:setVisible(true)
		if self.tCurData.nGive == 1 then

			self.pLayBtn2:setPositionY(25)
							
			self.pBtn2:onCommonBtnClicked(handler(self, self.onGetEnergyCallBack))
			
			self.pImgLabel:showImg()
			self.pImgLabel:setVisible(true)				
			if self.tCurData.nGetEnergy == 1 then--已经领取
				self.pBtn2:setButton(TypeCommonBtn.M_YELLOW, getConvertedStr(6, 10357))--获取体力		
				self.pBtn2:setBtnEnable(false)
			else
				self.pBtn2:setButton(TypeCommonBtn.M_YELLOW, getConvertedStr(6, 10397))--领取	
				self.pBtn2:setBtnEnable(true)
			end
		else--未赠送体力
			self.pLayBtn1:setVisible(false)
			self.pLayBtn2:setVisible(false)
		end
	elseif self.nShowType == 3 then--屏蔽列表
		self.pLayBtn1:setVisible(false)
		self.pLayBtn2:setVisible(true)
		self.pLayBtn2:setPositionY(40)
		self.pBtn2:setButton(TypeCommonBtn.M_RED, getConvertedStr(6, 10551))--解除					
		self.pBtn2:onCommonBtnClicked(handler(self, self.onRelieveBlackCallBack))

		self.pImgLabel:hideImg()
		self.pImgLabel:setVisible(false)
	end
end

-- 析构方法
function ItemFriend:onItemFriendDestroy(  )
	-- body
end

function ItemFriend:setCurData( _data, _nShowType )
	-- body	
	self.tCurData 		= 	_data or nil
	self.nShowType   	= 	_nShowType or self.nShowType  --item大小 
	self:updateViews()
end

function ItemFriend:getData(  )
	-- body
	return self.tCurData
end

--设置新品
function ItemFriend:setIconNew()
	-- body	
    local pIconGoods = self.pLayIcon:findViewByName("p_icon_goods_name")   
    if pIconGoods and self.tCurData then    
    	--dump(self.tCurData, "self.tCurData",100)
    	if self.tCurData:isNew() and self.nShowType == 1 then
    		pIconGoods:setDiscount(getConvertedStr(6, 10313))
    	else
    		pIconGoods:setDiscount()
    	end
    end
end
--聊天
function ItemFriend:onChatCallBack(  )
	--打开聊天界面加请求聊天信息
	if self.tCurData.bIsRb then
		if not Player:getFriendsData():isInBlackList(self.tCurData.sTid) then--不在屏蔽列表中 
			local tObject = {} 
				tObject.nType = e_dlg_index.dlgchat --dlg类型
				tObject.nChatType = e_lt_type.sl --聊天类型
				tObject.tPChatInfo = {
					nPlayerId = self.tCurData.sTid,
					sPlayerName = self.tCurData.sName,
				}
			Player:getFriendsData():addRecentRecord(self.tCurData.sTid, self.tCurData, 3, true)				
			sendMsg(ghd_show_dlg_by_type,tObject)
		end
	else
		local pMsgObj = {}

		pMsgObj.nplayerId = self.tCurData.sTid
		pMsgObj.bToChat = true
		pMsgObj.nCloseHandler = function ()
			-- body
			--关闭自己
			closeDlgByType(e_dlg_index.dlgfriends, false)
		end
		--发送获取其他玩家信息的消息
		sendMsg(ghd_get_playerinfo_msg, pMsgObj)
	end
end

--鼓舞
function ItemFriend:onEncourageCallBack(  )
	-- body

	if self.tCurData then
		if self.bIsEnc then
			return
		end
		self.bIsEnc = true
		if self.tCurData.bIsRb then
			SocketManager:sendMsg("playWithRobot", {self.tCurData.sTid, 8}, handler(self,self.onGetDataFunc))
		else
			SocketManager:sendMsg("giveFriendVit", {self.tCurData.sTid}, handler(self, self.onGetDataFunc))--添加好友	
		end
	end
end

--获取体力
function ItemFriend:onGetEnergyCallBack(  )
	-- body
	
	if Player:getFriendsData():isGetVitFull() then
		TOAST(getConvertedStr(6, 10581))
		return
	end	
	local nVit = tonumber(getChatInitParam("sendPowerOnce") or 0)
	if getIsOverMaxEnergy(nVit) then
		return
	end
	if self.tCurData then
		if self.bIsGet then
			return
		end
		self.bIsGet = true
		SocketManager:sendMsg("getFriendVit", {self.tCurData.sTid}, handler(self, self.onGetDataFunc))--添加好友
	end
end

--解除黑名单
function ItemFriend:onRelieveBlackCallBack(  )
	-- body
	if self.tCurData then
		if self.bIsDel then
			return
		end
		self.bIsDel = true
		if self.tCurData.bIsRb then
			SocketManager:sendMsg("playWithRobot", {self.tCurData.sTid, 5}, handler(self,self.onGetDataFunc))
		else
			SocketManager:sendMsg("removeshieldFriend", {self.tCurData.sTid}, handler(self, self.onGetDataFunc))--解除屏蔽
		end
	end
end

--接收服务端发回的登录回调
function ItemFriend:onGetDataFunc( __msg ,__oldMsg)
    if  __msg.head.state == SocketErrorType.success then 
    	if __msg.head.type == MsgType.removeshieldFriend.id then--添加好友
    		
		elseif __msg.head.type == MsgType.getFriendVit.id then--已经领取体力
			
       	elseif __msg.head.type == MsgType.giveFriendVit.id then--一键鼓舞
       		TOAST(getConvertedStr(6, 10583))
       	elseif __msg.head.type == MsgType.playWithRobot.id then--机器人
       		if __oldMsg[2] == 5 then
       		local pFriendVo = Player:getFriendsData():getBlackFriend(self.tCurData.sTid)
				if pFriendVo then--解除屏蔽
					Player:getFriendsData():removeBlackFriend(__msg.body.lock.aid)
					sendMsg(gud_refresh_friends_msg)
					--解除屏蔽成功
					TOAST(getConvertedStr(6, 10588)) 
				end
			elseif __oldMsg[2] == 8 then
				self.tCurData.nCanGet = 1
				self:updateViews()
			end
       		
        end
    else
        --弹出错误提示语
        --TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
    if self.bIsDel then
	    self.bIsDel = false
	end
	if self.bIsGet then	
	    self.bIsGet = false
	end
	if self.bIsEnc then
	    self.bIsEnc = false
	end
end
return ItemFriend