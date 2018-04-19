-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-25 10:28:40 星期四
-- Description: 游戏设置层
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local ItemSettingLayer = class("ItemSettingLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemSettingLayer:ctor( _key )
	-- body
	self:myInit(_key)
	parseView("item_setting_layer", handler(self, self.onParseViewCallback))	
end

--初始化成员变量
function ItemSettingLayer:myInit( _key )
	-- body
	self.sKey = _key or ""
	self.nValue = getSettingInfo(self.sKey)
end

--解析布局回调事件
function ItemSettingLayer:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	--self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemSettingLayer",handler(self, self.onItemSettingLayerDestroy))
end

--初始化控件
function ItemSettingLayer:setupViews( )
	-- body

end

-- 修改控件内容或者是刷新控件数据
function ItemSettingLayer:updateViews( )
	-- body
	if not self.pLbParam1 then
		self.pLbParam1 = self:findViewByName("lb_param_1")
		setTextCCColor(self.pLbParam1, _cc.pwhite)
	end	
	self.pLbParam1:setString(getSettingItemName(self.sKey), false)
	
	if not self.pLbParam2 then
		self.pLbParam2 = self:findViewByName("lb_param_2")
		self.pLbParam2:setPositionX(self.pLbParam1:getPositionX() + self.pLbParam1:getWidth())	
	end
	
	if not self.pLayBtn then
		self.pLayBtn = self:findViewByName("lay_btn")
		if self.sKey == "NoDisturb" then
			self.pBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.M_BLUE, getConvertedStr(1, 10210), false)--MUI.MImage.new("#v1_youjiantou.png", {scale9=false})		
			-- self.pLayBtn:addView(self.pBtn, 10)
			centerInView(self.pLayBtn, self.pBtn)
			self.pLayBtn:setViewTouched(true)
			self.pLayBtn:onMViewClicked(handler(self, self.onBtnClicked))		
			self.pLbParam2:setVisible(true)
		else
			self.pLbParam2:setVisible(false)
			--根据现在开启的补兵状态设置按钮状态
			self.pBtn =  getOvalSwOfContainer(self.pLayBtn,
				handler(self, self.onBtnClicked),tonumber(self.nValue or 0))
			centerInView(self.pLayBtn, self.pBtn)
		end		
		if self.sKey == "ShowChatArea" then
			SocketManager:sendMsg("chatPosSw", {0},handler(self, self.onGetDataFunc))		
		end
	end
	
	--dump(self.nValue,"self.nValue")
	if self.nValue == "1" then --
		if self.sKey == "NoDisturb" then
			local str = getNoDisturbTimeStr(getLocalInfo("No_Disturb_Start", "22"), getLocalInfo("No_Disturb_End", "8"))
			self.pLbParam2:setString(str)
			setTextCCColor(self.pLbParam2, _cc.yellow)			
		else
			self.pLbParam2:setString(getConvertedStr(6, 10286))
			setTextCCColor(self.pLbParam2, _cc.green)		
		end
	else
		self.pLbParam2:setString(getConvertedStr(6, 10287))
		setTextCCColor(self.pLbParam2, _cc.red)
	end	

end

-- 析构方法
function ItemSettingLayer:onItemSettingLayerDestroy(  )
	-- body
end

function ItemSettingLayer:showUnderLine( _isshow )
	-- body
	local isshow = true
	if not _isshow then
		isshow = false
	end
	if not self.pImgLine then
		self.pImgLine = self:findViewByName("img_line")
	end
	self.pImgLine:setVisible(isshow)
end

--按钮消息回调
function ItemSettingLayer:onBtnClicked( pview )
	-- body	
	if self.sKey == "NoDisturb" then
		local tObject = {}
		tObject.nType = e_dlg_index.dlgnodisturbsetting --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)	
	elseif self.sKey == "ShowChatArea" then --如果是聊天地区设置
		if self.nValue == "1" then
	    	SocketManager:sendMsg("chatPosSw", {1},handler(self, self.onGetDataFunc))
	    else
			SocketManager:sendMsg("chatPosSw", {2},handler(self, self.onGetDataFunc))
		end
	else
		if self.nValue == "1" then		
			self.nValue = "0"
		else		
			self.nValue = "1"
		end
		setSettingInfo(self.sKey, self.nValue)
		self.pBtn:setState(tonumber(self.nValue))
		self:updateViews()
	end
end

--接收服务端发回的登录回调
function ItemSettingLayer:onGetDataFunc( __msg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.chatPosSw.id then
        	if __msg.body.btn and self.sKey == "ShowChatArea" then
        		local bfresh = false
        		if __msg.body.btn == 1 then--关闭
        		   self.nValue = "0"
        		elseif __msg.body.btn == 2 then--开启
        			self.nValue = "1"
        		end
        		if (self.pBtn.nState == 0 and __msg.body.btn == 1) or
        			(self.pBtn.nState == 1 and __msg.body.btn == 2) then
        			bfresh = false
        		else
        			bfresh = true
        		end
        		if bfresh then
	        		setSettingInfo(self.sKey, self.nValue)
	       			self:updateSetting()        		
	        		self.pBtn:setState(tonumber(self.nValue))
        		end
        	end    	
        end          
    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end

--来自外部的刷新
function ItemSettingLayer:updateSetting(  )
	-- body
	self.nValue = getSettingInfo(self.sKey)
	self:updateViews()
end

-- --获取设置状态
-- function ItemSettingLayer:getSettingInfo( _sKey )
-- 	-- body
-- 	if not _sKey then
-- 		return
-- 	end
-- 	if _sKey == gameSetting_eachButtonKey[2] or _sKey == gameSetting_eachButtonKey[3] then
-- 		return getLocalInfo(_sKey, "1")
-- 	else
-- 		return getLocalInfo(_sKey..Player:getPlayerInfo().pid, "1")
-- 	end
-- end

-- function ItemSettingLayer:setSettingInfo( _sKey, _nValue )
-- 	-- body
-- 	if not _sKey then
-- 		return
-- 	end
-- 	if _sKey == gameSetting_eachButtonKey[2] or _sKey == gameSetting_eachButtonKey[3] then
-- 		return saveLocalInfo(_sKey, _nValue)
-- 	else
-- 		return saveLocalInfo(_sKey..Player:getPlayerInfo().pid, _nValue)
-- 	end
-- end
return ItemSettingLayer