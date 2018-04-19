-----------------------------------------------------
-- author: luwenjing
-- updatetime:  2018-01-16 14:06:15 星期二
-- Description: 纣王预告活动
-----------------------------------------------------

local MDialog = require("app.common.dialog.MDialog")

local DlgWuWangForcast = class("DlgWuWangForcast", function()
	-- body
	return MDialog.new()
end)

function DlgWuWangForcast:ctor( _eDlgType )
	-- body
	self.eDlgType = _eDlgType or e_dlg_index.wuwangforcast
	self:myInit()
	parseView("dlg_new_first_recharge", handler(self, self.onParseViewCallback))
	self:setName(UIAction.TAG_SMALL_DLG)
end

function DlgWuWangForcast:myInit(  )
	-- body
	self.tItemIcons = {}
	self.tActData  = nil --活动数据
	
end


--解析布局回调事件
function DlgWuWangForcast:onParseViewCallback( pView )
	-- body
	self.pComDlgView = pView
	self:setContentView(self.pComDlgView)
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgWuWangForcast",handler(self, self.onDestroy))
end

--初始化控件
function DlgWuWangForcast:setupViews(  )
	-- body
	--设置标题

	--ly
	self.pLyMain = self:findViewByName("default")

	--背景图
	self.pImgBg = self:findViewByName("lay_bg")
	self.pImgBg:setBackgroundImage("ui/v2_bg_zhouwnag.jpg")
	--底部按钮
	self.pImgBtnBuy = self:findViewByName("img_btn_buy")
	self.pImgBtnBuy:setVisible(false)

	--右上角关闭按钮
	local pLayBtnClose = self:findViewByName("lay_btn_close")
	pLayBtnClose:setViewTouched(true)
	pLayBtnClose:setIsPressedNeedScale(false)
	pLayBtnClose:setIsPressedNeedColor(false)
	pLayBtnClose:onMViewClicked(handler(self, self.onClickClose))

	self.tItemId={10,2011,200641,12}

	self.pBtnInfo = MUI.MImage.new("#v2_btn_wj_xiangqing.png")
	self.pBtnInfo:setPosition(self.pImgBg:getWidth()/2 + 70, self.pImgBg:getHeight()/2 - 38)
	self.pImgBg:addChild(self.pBtnInfo,120)

	self.pBtnInfo:setViewTouched(true)
	self.pBtnInfo:setIsPressedNeedScale(true)
	self.pBtnInfo:setIsPressedNeedColor(true)
	self.pBtnInfo:onMViewClicked(handler(self, self.onClickInfo))
	
end

--控件刷新
function DlgWuWangForcast:updateViews()
	
	self.tActData = Player:getActById(e_id_activity.wuwangforcast)
	if not self.tActData then
		self:closeDlg(false)
		return
	end

	if not self.pTxtTime then
		self.pTxtTime = MUI.MLabel.new({text = "", size = 20})
		self.pTxtTime:setPosition(self.pImgBg:getWidth()/2,80)
		self.pImgBg:addChild(self.pTxtTime,5)
	end

	if not self.pTxtTip then
		self.pTxtTip = MUI.MLabel.new({text = "", size = 20})
		self.pTxtTip:setPosition(self.pImgBg:getWidth()/2,55)
		self.pImgBg:addChild(self.pTxtTip,5)
	end
	self.pTxtTip:setString(getConvertedStr(9, 10103))
	local nLeft  = self.tActData:getOpenTime()
	local tCDStr = {
			{color=_cc.white,text=getConvertedStr(9, 10102)},
			{color=_cc.yellow,text=formatTimeToHms(nLeft)},
		}
	self.pTxtTime:setString(tCDStr)

	regUpdateControl(self, function ( ... )
		--刷新倒计时
		local nLeft  = self.tActData:getOpenTime()
		if nLeft > 0 then
			local tCDStr = {
				{color=_cc.white,text=getConvertedStr(9, 10102)},
				{color=_cc.yellow,text=formatTimeToHms(nLeft)},
			}
			self.pTxtTime:setString(tCDStr, false)
		else
			unregUpdateControl(self)
		end
	end)

	for i=1, 4 do
		local pLayer = MUI.MLayer.new()
		pLayer:setLayoutSize(120, 130)
		pLayer:setName("item".. i)
		-- pLayer:setBackgroundImage("#v1_img_guojia_renwubaoxiang2.png")
		pLayer:setPosition(10 +(i-1)*(pLayer:getWidth() + 15), 100)

		pLayer:setViewTouched(true)
		pLayer:setIsPressedNeedScale(false)
		pLayer:setIsPressedNeedColor(true)
		pLayer:onMViewClicked(handler(self, self.onItemClicked))

		self.pImgBg:addChild(pLayer,5)
	end


end
function DlgWuWangForcast:onItemClicked( _pView )
	-- body
	local nIndex = 0
	if _pView:getName() == "item1" then
		nId = 1
	elseif _pView:getName() == "item2" then
		nId = 2
	elseif _pView:getName() == "item3" then
		nId = 3
	elseif _pView:getName() == "item4" then
		nId = 4
	end

	local tGood = getGoodsByTidFromDB(self.tItemId[nId])
	if tGood then
		if tGood.nGtype == e_type_goods.type_hero then
			local tObject = {}
			tObject.nType = e_dlg_index.heroinfo --dlg类型
			tObject.tData = tGood
			tObject.bShowBaseData = true
			sendMsg(ghd_show_dlg_by_type,tObject)
		else
			openIconInfoDlg(_pView,tGood)
		end
	end

end
--关闭界面
function DlgWuWangForcast:onClickClose( )
	self:closeDlg(false)
end

function DlgWuWangForcast:onClickInfo(  )
	-- body
	local tData =getHeroDataById(200641)
	if tData then
		local tObject = {}
		tObject.nType = e_dlg_index.heroinfo --dlg类型
		tObject.tData = tData
		sendMsg(ghd_show_dlg_by_type,tObject)
		self:closeDlg()
	end

end



--析构方法
function DlgWuWangForcast:onDestroy(  )
	-- body
	self:onPause()
	
	if self.tActData  and self.tActData:getOpenTime() <=0 then --倒计时已到
		Player:removeActById(e_id_activity.wuwangforcast)
	end
	
	
end

--注册消息
function DlgWuWangForcast:regMsgs(  )
	-- body
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))


end
--注销消息
function DlgWuWangForcast:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_activity)

end
--暂停方法
function DlgWuWangForcast:onPause( )
	-- body	
	self:unregMsgs()
	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgWuWangForcast:onResume( _bReshow )
	-- body	
	self:updateViews()
	self:regMsgs()
end


return DlgWuWangForcast