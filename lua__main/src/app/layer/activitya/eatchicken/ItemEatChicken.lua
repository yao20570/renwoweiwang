----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-10-19 10:18:58
-- Description: 吃鸡
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local ItemEatChicken = class("ItemEatChicken", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数 _nId
function ItemEatChicken:ctor(_nId)
	-- body
	self:myInit()


	parseView("dlg_eatchicken", handler(self, self.onParseViewCallback))


	--注册析构方法
	self:setDestroyHandler("ItemEatChicken",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemEatChicken:myInit()
	self.pData = {} --数据
	self.nCnType = 1 --内容版本
	self.pItemTime = nil --时间Item
	self.pMHandler = nil --中间按钮回调
	self.pImgAccount = nil --标题说明图片
end

--解析布局回调事件
function ItemEatChicken:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)


	self:setupViews()
	self:onResume()
end

-- 注册消息
function ItemEatChicken:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

-- 注销消息
function ItemEatChicken:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end


function ItemEatChicken:onResume(  )
	self:clearEatChickenFillRed()	
	self:regMsgs()
end

function ItemEatChicken:onPause(  )	
	self:unregMsgs()
end

--初始化控件
function ItemEatChicken:setupViews( )


	--ly         
	self.pLyTitle= self:findViewByName("ly_title")
	self.pLyBtnM = self:findViewByName("ly_btn_m")
	self.pLyCon = self:findViewByName("ly_con")
	
	--lb
	self.pLbSecTitle  = self:findViewByName("lb_sec_tile")
	-- self.pLayJianbian = self:findViewByName("lay_jianbian")
	self.pLbDescCn = MUI.MLabel.new({
		    text = "",
		    size = 20,
		    anchorpoint = cc.p(0, 1),
		    align = cc.ui.TEXT_ALIGN_LEFT,
    		valign = cc.ui.TEXT_VALIGN_TOP,
		    color = cc.c3b(255, 255, 255),
		    dimensions = cc.size(510, 0),
		})
	self.pLbDescCn:setPosition(13, 630)
	self.pLyCon:addView(self.pLbDescCn, 10)

	--img
	self.pLayBannerBg = self:findViewByName("lay_banner_bg")
	self.pImgChickenState = self:findViewByName("img_chicken_state")


	--
	self.pBtnM = getCommonButtonOfContainer(self.pLyBtnM, TypeCommonBtn.L_YELLOW, getConvertedStr(5, 10196))
	self.pBtnM:onCommonBtnClicked(handler(self, self.onMiddleClicked))
		
	local pTxtTimeTile = self:findViewByName("txt_time_title")
	pTxtTimeTile:setString(getConvertedStr(3, 10463))
	setTextCCColor(pTxtTimeTile, _cc.gray)
	self.pTxtEatTime1 = self:findViewByName("txt_time1")
	setTextCCColor(self.pTxtEatTime1, _cc.green)
	self.pTxtEatTime2 = self:findViewByName("txt_time2")
	setTextCCColor(self.pTxtEatTime2, _cc.green)
	-- self.pImgChicken = self:findViewByName("img_chicken")
	self.pTxtEatState = self:findViewByName("txt_eat_state")
	setTextCCColor(self.pTxtEatState, _cc.gray)
	self.pTxtBuyEnergy = self:findViewByName("txt_buy_energy")
	setTextCCColor(self.pTxtBuyEnergy, _cc.gray)
	
end

function ItemEatChicken:getIsEnergyMax( )
	local nEnergyMax = tonumber(getGlobleParam("maxEnergy"))
	if nEnergyMax and Player:getPlayerInfo().nEnergy >= nEnergyMax then
		return true
	end
	return false
end

--中间按钮回调
function ItemEatChicken:onMiddleClicked(pView)
	--容错
	if not self.pData then
		return
	end
	--吃鸡状态
	local nEatState = self.pData.nEatState
	if nEatState == e_eat_state.no or nEatState == e_eat_state.eated then
		openDlgBuyEnergy()
		
	elseif nEatState == e_eat_state.eat then
		if self:getIsEnergyMax() then
			TOAST(getConvertedStr(3, 10475))
			return
		end


		SocketManager:sendMsg("reqEatChicken", {}, function ( __msg )
			if  __msg.head.state == SocketErrorType.success then 
	            if __msg.head.type == MsgType.reqEatChicken.id then
	            	if __msg.body.o then
						--获取物品效果
						showGetAllItems(__msg.body.o)
					end
	            end
	        else
	            TOAST(SocketManager:getErrorStr(__msg.head.state))
	        end
		end)
	elseif nEatState == e_eat_state.fill then
		if self:getIsEnergyMax() then
			TOAST(getConvertedStr(3, 10475))
			return
		end

		--购买
		local nCost = self.pData.nFillCost
		local strTips = {
		    {color=_cc.pwhite, text=getConvertedStr(3, 10472)},--扩充招募队列
		    {color=_cc.yellow, text=tostring(self.pData.nEnergy)..getConvertedStr(3, 10473)},
		    {color=_cc.pwhite, text=getConvertedStr(3, 10474)},
		}
		--展示购买对话框
		showBuyDlg(strTips,nCost,function (  )
		    SocketManager:sendMsg("reqFillChicken", {}, function ( __msg )
				if  __msg.head.state == SocketErrorType.success then 
		            if __msg.head.type == MsgType.reqFillChicken.id then
		            	if __msg.body.o then
							--获取物品效果
							showGetAllItems(__msg.body.o)
						end
		            end
		        else
		            TOAST(SocketManager:getErrorStr(__msg.head.state))
		        end
			end)
		end, 0, true)
	end
end

-- 修改控件内容或者是刷新控件数据
function ItemEatChicken:updateViews()
	self:refreshView()
end

--刷新内容
function ItemEatChicken:refreshView()
	if not self.pData then
		return
	end

	if not self.pItemTime then
		self.pItemTime = createActTime(self.pLyTitle,self.pData,cc.p(0,170))
	end
	self.pItemTime:setCurData(self.pData)

	if self.pData.sTitle then
		self.pLbSecTitle:setString(self.pData.sTitle)
	end
	if self.pData.sDesc then
		self.pLbDescCn:setString(self.pData.sDesc)
		-- self.pLayJianbian:setContentSize(self.pLayJianbian:getWidth(), self.pLbDescCn:getHeight() + 10)		
		-- self.pLayJianbian:setBackgroundImage("#v1_img_blackjianbian.png",{scale9 = true,capInsets=cc.rect(134,32, 1, 1)})	
	end

	--banner
	self:setBannerImg(TypeBannerUsed.ac_mrcj)

	--
	--吃鸡时间
	local tEatTimeStr = self.pData.tEatTimeStr
	if tEatTimeStr then
		local sStr = tEatTimeStr[1]
		if sStr then
			self.pTxtEatTime1:setString(sStr)
		end
		local sStr = tEatTimeStr[2]
		if sStr then
			self.pTxtEatTime2:setString(sStr)
		end
	end

	--吃鸡状态
	local nEatState = self.pData.nEatState
	if nEatState == e_eat_state.no or nEatState == e_eat_state.eated then
		-- self.pImgChicken:setVisible(false)
		self.pImgChickenState:setCurrentImage("ui/big_img/v2_bg_jimeihao.jpg")
		self.pTxtEatState:setString(getConvertedStr(3, 10467)) 
		
		self.pBtnM:updateBtnText(getConvertedStr(6, 10080))
		-- self.pBtnM:setBtnEnable(false)
		self.pTxtBuyEnergy:setVisible(true)
		self.pTxtBuyEnergy:setString(getConvertedStr(9,10067))
		-- self.pBtnM:updateBtnText(getConvertedStr(3, 10470))
		-- self.pBtnM:updateBtnText(getConvertedStr(6, 10080))
		self.pTxtEatState:setPositionY(135)

	elseif nEatState == e_eat_state.eat then
		-- self.pImgChicken:setVisible(true)
		self.pImgChickenState:setCurrentImage("ui/big_img/v2_bg_jihaole.jpg")
		self.pTxtEatState:setString(getConvertedStr(3, 10466)) 

		self.pBtnM:updateBtnText(getConvertedStr(3, 10470))
		self.pBtnM:setBtnEnable(true)
		self.pTxtBuyEnergy:setVisible(false)
		self.pTxtEatState:setPositionY(112)
	elseif nEatState == e_eat_state.fill then
		-- self.pImgChicken:setVisible(true)
		self.pImgChickenState:setCurrentImage("ui/big_img/v2_bg_jihaole.jpg")
		self.pTxtEatState:setString(string.format(getConvertedStr(3, 10468), self.pData.nFillCost))

		self.pBtnM:updateBtnText(getConvertedStr(3, 10471))
		self.pBtnM:setBtnEnable(true)
		self.pTxtBuyEnergy:setVisible(false)
		self.pTxtEatState:setPositionY(112)
	end
end

--析构方法
function ItemEatChicken:onDestroy(  )
	self:onPause()
end

--设置数据 _data
function ItemEatChicken:setData( _tData )
	if not _tData then
		return
	end

	self.pData = _tData or {}

	self:refreshView()


end

--获取类型
function ItemEatChicken:getType()
	if self.nCnType then
		return self.nCnType 
	else
		return 0
	end
end

--设置banner图片 
function ItemEatChicken:setBannerImg(nType)
	if self.pLayBannerBg and nType then
		setMBannerImage(self.pLayBannerBg,nType)
	end
end

--添加说明图片
function ItemEatChicken:addAccountImg(_strImg)
	-- body
	--默认工坊加速的图片
	if not self.pImgAccount then
		self.pImgAccount = ItemActPlugAccount.new()
		self.pLyTitle:addView( self.pImgAccount, 2 )
		self.pImgAccount:setPosition(7,7)
	end

	if not _strImg then
		return
	end
	self.pImgAccount:setAccountImg(_strImg)

end


--设置时间
function ItemEatChicken:setActTime()
	if self.pData and self.pItemTime then
		self.pItemTime:setCurData(self.pData)
	end
end


--清理补鸡状态下的红点标签
function ItemEatChicken:clearEatChickenFillRed(  )
	-- body	
	local pActData = Player:getActById(e_id_activity.eatchicken)
	pActData:clearFillRed()
	-- if pActData and pActData.nEatState == e_eat_state.fill then
	-- 	--当前时间
	-- 	local time = os.date("*t", getSystemTime())
	-- 	local nCurDay = time.day
	-- 	saveLocalInfo("EatChicken"..Player:getPlayerInfo().pid,tostring(nCurDay).."-0")
	-- 	sendMsg(gud_refresh_activity) 
	-- end	
end

return ItemEatChicken