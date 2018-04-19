-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-11-28 14:13:23 星期二
-- Description: 红包打开
-----------------------------------------------------

local MDialog = require("app.common.dialog.MDialog")

local DlgRedPocketOpen = class("DlgRedPocketOpen", function()
	-- body
	return MDialog.new(e_dlg_index.dlgredpocketopen)
end)

function DlgRedPocketOpen:ctor( _pData )
	-- body	
	self:myInit(_pData)
	parseView("lay_red_pocket_open", handler(self, self.onParseViewCallback))
	self:setName(UIAction.TAG_SMALL_DLG)
end

function DlgRedPocketOpen:myInit( _pData )
	-- body
	--dump(_pData, "_pData", 100)
	self.pRedID = _pData.nRpId or nil
	self.pData = _pData.pData or nil
	self.nChatID = _pData.nChatID or nil	
	self.tChatData = _pData.tChatData or nil
end

--解析布局回调事件
function DlgRedPocketOpen:onParseViewCallback( pView )
	-- body
	self:setContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgRedPocketOpen",handler(self, self.onDestroy))
end

--初始化控件
function DlgRedPocketOpen:setupViews(  )	
	--body	
	self.pLayRoot 		= 		self:findViewByName("lay_default")
	self.pLbNum = self:findViewByName("lb_num")
	setTextCCColor(self.pLbNum, _cc.yellow)	
	self.pLayClose 		= 		self:findViewByName("lay_btn_close")
	self.pLayClose:setViewTouched(true)
	self.pLayClose:setIsPressedNeedScale(false)
	self.pLayClose:onMViewClicked(function (  )
		-- body
		self:closeDlg()
	end)
	self.pImgArrL = self:findViewByName("img_arrow_l")
	self.pImgArrR = self:findViewByName("img_arrow_r")
	self.pImgArrR:setFlippedX(true)


	local pInfo = self.pData.info
	self.pLayIcon = self:findViewByName("lay_icon_1")
	local pIconData = Player:getChatAvatorById(self.nChatID)
	if not self.pIcon then
	 	self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.header, pIconData, TypeIconGoodsSize.M)
	 	self.pIcon:setIconIsCanTouched(false)
	else
		self.pIcon:setCurData(pIconData)
	end


	self.pLbDesc1 = self:findViewByName("lb_par_1")
	self.pLbDesc1:setString(pInfo.bname, false)

	if self.tChatData.sSenderNameIcon and self.tChatData.nTmsg == e_chat_type.sysRedPocket then   --系统红包的头像和名字走配表
		self.pIcon:setIconImg(self.tChatData.sSenderNameIcon)
		self.pLbDesc1:setString(self.tChatData.sSenderNameDb, false)
		
	end
	
	setTextCCColor(self.pLbDesc1, _cc.yellow)
	self.pLbDesc2 = self:findViewByName("lb_par_2")
	self.pLbDesc2:setString(getConvertedStr(6, 10615), false)
	setTextCCColor(self.pLbDesc2, _cc.yellow)

	self.pBtnOpen = self:findViewByName("img_btn_open")
	self.pBtnOpen:setViewTouched(true)
	self.pBtnOpen:setIsPressedNeedScale(false)
	self.pBtnOpen:onMViewClicked(handler(self, self.checkRedPocket))	

	self.pLbTip = self:findViewByName("lb_tip") 
	setTextCCColor(self.pLbTip, _cc.yellow)
	self.pLbTip:setString(getConvertedStr(6, 10616), false)
	local tData = getRedPocketData(pInfo.itemId)
	-- dump(tData, "tData", 100)
	
	if tData then
		-- print("----------------1--------------")
		self.pLbNum:setString(tonumber(tData.money or 0), false)
	else
		-- print("----------------2--------------")
		self.pLbNum:setString("", false)
	end
	self.pImgQB = self:findViewByName("img_qianbi")
	local nXOff = (self.pLbTip:getWidth() - self.pLbNum:getWidth() - self.pImgQB:getWidth())/2
	local nX = self.pLayRoot:getWidth()/2 + nXOff
	self.pLbTip:setPositionX(nX)
	self.pImgQB:setPositionX(nX)
	self.pLbNum:setPositionX(nX + self.pLbNum:getWidth()/2 + self.pImgQB:getWidth())
	-- print("self.pLbNum:getPositionX--", self.pLbNum:getPositionX())
end

--控件刷新
function DlgRedPocketOpen:updateViews(  )
	-- body

end

--析构方法
function DlgRedPocketOpen:onDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgRedPocketOpen:regMsgs(  )
	-- body

end
--注销消息
function DlgRedPocketOpen:unregMsgs(  )
	-- body

end

--暂停方法
function DlgRedPocketOpen:onPause( )
	-- body
	self:unregMsgs()	
end

--继续方法
function DlgRedPocketOpen:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

function DlgRedPocketOpen:checkRedPocket(  )
	-- body
	if self.pData and self.pRedID then
		local nRpId = self.pRedID
		local nRpT = self.pData.get 
		if nRpT == 0 then--可以领取
			--SocketManager:sendMsg("catchredpocket", {nRpId, self.nChatID, self.nId}, handler(self, self.onGetCallBack))	
			SocketManager:sendMsg("catchredpocket", {nRpId, self.nChatID, self.tChatData})	
		end		
	end	
end

-- function DlgRedPocketOpen:onGetCallBack( __msg, __oldMsg )
-- 	-- body
-- 	if __msg.head.type == MsgType.catchredpocket.id then 		--查看红包
-- 		if __msg.head.state == SocketErrorType.success then	
-- 			--dump(__msg.body, "__msg.body", 100)
-- 			local pRPData = {}	
-- 			pRPData.nRpId = __oldMsg[1]
-- 			pRPData.pData = __msg.body	
-- 			pRPData.nChatID = self.nChatID
-- 			pRPData.nId = self.nId
-- 			local tObj = {}
-- 			tObj.nType = e_dlg_index.dlgredpocketcheck
-- 			tObj.pData = pRPData		
-- 			sendMsg(ghd_show_dlg_by_type,tObj)	
-- 			--获得特效
-- 			if __msg.body.ob then
-- 				showGetAllItems(__msg.body.ob)
-- 			end
-- 			Player:updateRedPocketById(self.nId, __msg.body.get) 
-- 			self:closeDlg()   
-- 		else		    
-- 			self:getNewInfo()
--         end
--     end	     
-- end

-- function DlgRedPocketOpen:getNewInfo(  )
-- 	-- body
-- 	if self.pData and self.pRedID then
-- 		local nRpId = self.pRedID
-- 		SocketManager:sendMsg("checkredpocket", {nRpId}, handler(self, self.showRedPocket))			
-- 	end	
-- end
-- function DlgRedPocketOpen:showRedPocket( __msg, __oldMsg  )
-- 	-- body
-- 	if __msg.head.type == MsgType.checkredpocket.id then 		--查看红包
-- 		if __msg.head.state == SocketErrorType.success then	
-- 			--dump(__msg.body, "__msg.body", 100)
-- 			local pRPData = {}	
-- 			pRPData.nRpId = __oldMsg[1]
-- 			pRPData.pData = __msg.body	
-- 			pRPData.nChatID = self.nChatID
-- 			pRPData.nId = self.nId
-- 			local tObj = {}
-- 			tObj.nType = e_dlg_index.dlgredpocketcheck
-- 			tObj.pData = pRPData		
-- 			sendMsg(ghd_show_dlg_by_type,tObj)			
-- 			Player:updateRedPocketById(self.nId, __msg.body.get) 
-- 		else		    
-- 			TOAST(SocketManager:getErrorStr(__msg.head.state))
--         end
--     end
--     self:closeDlg()	 	
-- end
return DlgRedPocketOpen