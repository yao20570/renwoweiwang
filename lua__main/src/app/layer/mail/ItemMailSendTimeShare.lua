----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2017-11-20 14:19:21
-- Description: 邮件战斗攻打的信息
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ItemMailSendTimeShare = class("ItemMailSendTimeShare", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemMailSendTimeShare:ctor( _tInfo )
	--解析文件

	self.tInfo=_tInfo
	parseView("item_mail_send_time_share", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemMailSendTimeShare:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemMailSendTimeShare",handler(self, self.onMailDetailAtkDefBannerDestroy))
end

-- 析构方法
function ItemMailSendTimeShare:onMailDetailAtkDefBannerDestroy(  )
    self:onPause()
end

function ItemMailSendTimeShare:regMsgs(  )
end

function ItemMailSendTimeShare:unregMsgs(  )
end

function ItemMailSendTimeShare:onResume(  )
	self:regMsgs()
end

function ItemMailSendTimeShare:onPause(  )
	self:unregMsgs()
end

function ItemMailSendTimeShare:setupViews(  )
	self.pLayTime=self:findViewByName("lay_time")
	self.pLayShareBtn=self:findViewByName("lay_share_btn")
	self.pLaySaveBtn=self:findViewByName("lay_save_btn")
	self.pLayBg=self:findViewByName("lay_bg")
	-- self.pBtnShare = getCommonButtonOfContainer(self.pLayShareBtn,TypeCommonBtn.M_BLUE,getConvertedStr(3,10003))
	-- --分享按钮点击事件
	-- self.pBtnShare:onCommonBtnClicked(handler(self, self.onShareClicked))

	-- setMCommonBtnScale(self.pLayShareBtn, self.pBtnShare, 0.8)

	-- self.pBtnSave = getCommonButtonOfContainer(self.pLaySaveBtn,TypeCommonBtn.M_BLUE,getConvertedStr(3,10218))
	-- --保存按钮点击事件
	-- self.pBtnSave:onCommonBtnClicked(handler(self, self.onSaveClicked))

	-- setMCommonBtnScale(self.pLaySaveBtn, self.pBtnSave, 0.8)
end

--隐藏分享按钮
function ItemMailSendTimeShare:hideShareBtn()
	-- body
	self.pLayShareBtn:setVisible(false)
	self.pLaySaveBtn:setVisible(false)
end

function ItemMailSendTimeShare:updateViews(  )
	--居中显示

	local nPosX=20
	local nHeight=self:getHeight()
	if self.tInfo then
		for i, v in pairs(self.tInfo) do
			local pTxt=MUI.MLabel.new({text = v.sStr or "", size = v.nFontSize})
			pTxt:setColor(getC3B(v.sColor) or getC3B(_cc.white))
			-- pTxt:updateTexture()
			pTxt:setAnchorPoint(0,0)
			local nPosY=(nHeight-pTxt:getHeight())/2+2
			pTxt:setPosition(nPosX,nPosY)

			nPosX=nPosX+pTxt:getWidth()+5
			self.pLayTime:addView(pTxt,10)
		end
	end

end

function ItemMailSendTimeShare:getLayShareBtn(  )
	-- body
	return self.pLayShareBtn
end
function ItemMailSendTimeShare:getLaySaveBtn(  )
	-- body
	return self.pLaySaveBtn
end

function ItemMailSendTimeShare:scaleBtn( _pLayBtn,_pBtn )
	-- body
	if _pBtn and _pLayBtn then
		_pBtn:updateBtnType(TypeCommonBtn.M_BLUE)
		setMCommonBtnScale(_pLayBtn, _pBtn, 0.6)
		_pBtn:updateBtnTextSize(28)
	end
end

function ItemMailSendTimeShare:setShareHandler( _handler )
	-- body
	if not _handler then
		return
	else
		self.shareHandler=_handler
	end
end
function ItemMailSendTimeShare:setSaveHandler( _handler )
	-- body
	if not _handler then
		return
	else
		self.saveHandler=_handler
	end
end

function ItemMailSendTimeShare:onShareClicked( )
	-- body
	if self.shareHandler then
		self.shareHandler(self.pBtnShare)
	end
end
function ItemMailSendTimeShare:onSaveClicked( )
	-- body
	if self.saveHandler then
		self.saveHandler()
	end
end

return ItemMailSendTimeShare


