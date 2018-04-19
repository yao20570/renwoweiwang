-- ItemGiftRecharge.lua
---------------------------------------------
-- Author: dshulan
-- Date: 2017-06-29 15:00:00
-- 礼包兑换界面
---------------------------------------------

local MCommonView = require("app.common.MCommonView")

local ItemGiftRecharge = class("ItemGiftRecharge", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function ItemGiftRecharge:ctor()
	-- body
	self:myInit()
	parseView("dlg_gift_recharge", handler(self, self.onParseViewCallback))
end


--解析布局回调事件
function ItemGiftRecharge:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	-- self:updateViews()
	self:regMsgs()
	--注册析构方法
	self:setDestroyHandler("ItemGiftRecharge",handler(self, self.onDestroy))
end

--初始化参数
function ItemGiftRecharge:myInit()
	self.pData = {} --数据
	self.pItemTime = nil --时间Item
end


--初始化控件
function ItemGiftRecharge:setupViews( )
	self.pLyTitle         = self:findViewByName("ly_title")
	--设置图片
	self.pLayBannerBg = self:findViewByName("lay_banner_bg")

	--描述    
	self.pLbDec           = self:findViewByName("lb_dec")
	--输入框    
	self.pLayTextfield 	  = self:findViewByName("lay_textfield")
	self.pLbTextField     = self:findViewByName("lb_TextField")
	--兑换按钮
	self.pLyBtn           = self:findViewByName("lay_btn")

	self.pLyContent       = self:findViewByName("ly_show")

	self.pImgJianbian     = self:findViewByName("img_jianbian")
	self.pImgJianbian:setVisible(false)

	self.pBtn = getCommonButtonOfContainer(self.pLyBtn, TypeCommonBtn.XL_YELLOW, getConvertedStr(7, 10097))
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))

	-- self.pLbDec:setString(getConvertedStr(7, 10098))
	self.pLbTextField:setPlaceHolder(getConvertedStr(7, 10099)) --输入框默认内容
	self.pLbTextField:setText("")
end

--点击兑换回调
function ItemGiftRecharge:onBtnClicked()
	--请求兑换
	local sCdkey = self.pLbTextField:getText()
	if sCdkey == "" then
		TOAST(getConvertedStr(7, 10100))
		return
	end
	SocketManager:sendMsg("reqRechargeGift", {sCdkey}, function(__msg)
		-- body
		-- dump(__msg.body)
		if __msg.body and __msg.body.ob then
			--奖励动画展示
			showGetAllItems(__msg.body.ob, 1)
		end
	end)
end



-- 修改控件内容或者是刷新控件数据
function ItemGiftRecharge:updateViews(  )
	-- body
	if not self.pData then
		return
	end

	if not self.pLbDesc then
		self.pLbDesc = MUI.MLabel.new({
			text = "",
			size = 20,
			anchorpoint = cc.p(0, 1),
			dimensions = cc.size(400, 0)
		})
		self.pLyContent:addView(self.pLbDesc, 2)
		self.pLbDesc:setPosition(self.pLbDec:getPosition())
	end
	-- local sDesc = getTextColorByConfigure(self.pData.sDesc)

	self.pLbDesc:setString(self.pData.sDesc)
	-- print("self.pLbDesc:getHeight()=", self.pLbDesc:getHeight())

	local nY = self.pLayTextfield:getPositionY() + self.pLayTextfield:getHeight()
	self.pLbDesc:setPositionY(nY + self.pLbDesc:getHeight() + 35)
	if not self.pItemTime then
		self.pItemTime = createActTime(self.pLyTitle,self.pData,cc.p(0,170))
	end
	self.pItemTime:setCurData(self.pData)

	--设置banner图
	setMBannerImage(self.pLayBannerBg,TypeBannerUsed.ac_dhlb)
end

--析构方法
function ItemGiftRecharge:onDestroy(  )
	self:unregMsgs()
end


-- 注册消息
function ItemGiftRecharge:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

-- 注销消息
function ItemGiftRecharge:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end


--设置数据 _data
function ItemGiftRecharge:setData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}
	self:updateViews()

end


return ItemGiftRecharge

