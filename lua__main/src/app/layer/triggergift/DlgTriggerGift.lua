----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-11-20 13:49:41
-- Description: 触发式礼包
-----------------------------------------------------
local DlgCommon = require("app.common.dialog.DlgCommon")
local MDialog = require("app.common.dialog.MDialog")
local ItemTriggerGiftPageView = require("app.layer.triggergift.ItemTriggerGiftPageView")
local MImgLabel = require("app.common.button.MImgLabel")
local e_cost_type = {
	rmb = 1,
	gold = 2,
}
local DlgTriggerGift = class("DlgTriggerGift", function()
	return MDialog.new(e_dlg_index.triggergift)
end)

function DlgTriggerGift:ctor()
	self.nCurrPage = 1
	self.tPageDot = {}
	self.pBannerList = {}
	self.pIdleBannerList = {}
	self.nGiftNum = 0
	self.pLayContentList = {}
	parseView("dlg_trigger_gift", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgTriggerGift:onParseViewCallback( pView )
	self:setContentView(pView) --设置内容层

	self:setupViews()
	self:onResume()

	-- 注册关闭对话框的消息
	regMsg(self, ghd_msg_close_dlg_by_type, handler(self, self.onCloseDlg))

	--注册析构方法
	self:setDestroyHandler("DlgTriggerGift",handler(self, self.onDlgTriggerGiftDestroy))
end

-- 析构方法
function DlgTriggerGift:onDlgTriggerGiftDestroy(  )
	self:clearIdleBanner()
    self:onPause()
    showNextSequenceFunc(e_show_seq.triggergift)
    -- removeTextureFromCache("ui/p2_banner2",3)
end

function DlgTriggerGift:regMsgs(  )
	--更新列表刷新
	regMsg(self, gud_trigger_gift_list_refresh, handler(self, self.onGiftListRefrsh))
end

function DlgTriggerGift:unregMsgs(  )
	unregMsg(self, gud_trigger_gift_list_refresh)
end

function DlgTriggerGift:onResume(  )
	self:regMsgs()
	self:updateViews()
	regUpdateControl(self, handler(self, self.updateCd))
end

function DlgTriggerGift:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function DlgTriggerGift:setupViews(  )
	self.pLayRoot = self:findViewByName("view")
	--关闭点击事件
	self.pLayCClose 		= 	self:findViewByName("lay_close")
	self.pLayCClose:setViewTouched(true)
	self.pLayCClose:setIsPressedNeedScale(false)
	self.pLayCClose:onMViewClicked(handler(self, self.onCloseClicked))

	self.pLayPageView = self:findViewByName("lay_pageview")
	self.pImgLeftArrow = self:findViewByName("img_left_arrow")
	self.pImgLeftArrow:setViewTouched(true)
	self.pImgLeftArrow:setIsPressedNeedScale(false)
	self.pImgLeftArrow:setIsPressedNeedColor(false)
	self.pImgLeftArrow:onMViewClicked(function ( _pView )
		if self.bIsMove then
			return
		end
		
		if self.pPageView then
			if self.nCurrPage > 1 then
				self.bIsMove = true
	    		self.pPageView:gotoPage(self.nCurrPage - 1,true)
	    	end
	    end
	end)
	self.pImgLeftArrow:setFlippedX(true)

	self.pImgRightArrow = self:findViewByName("img_right_arrow")
	self.pImgRightArrow:setViewTouched(true)
	self.pImgRightArrow:setIsPressedNeedScale(false)
	self.pImgRightArrow:setIsPressedNeedColor(false)
	self.pImgRightArrow:onMViewClicked(function ( _pView )
		if self.bIsMove then
			return
		end
		
	    if self.pPageView then
			if self.nCurrPage < self.nGiftNum then
				self.bIsMove = true
	    		self.pPageView:gotoPage(self.nCurrPage + 1,true)
	    	end
	    end
	end)
	-- self.pImgRightArrow:setFlippedX(true)

	
	self.pLayBtnBuy = self:findViewByName("lay_btn_buy")
	self.pLayCostPrev = self:findViewByName("lay_cost_prev")
	self.pLayBanner = self:findViewByName("lay_banner")

	--购买礼包按钮
	self.pBtnBuy = getCommonButtonOfContainer(self.pLayBtnBuy, TypeCommonBtn.L_YELLOW, "")
	self.pBtnBuy:onCommonBtnClicked(handler(self, self.onBuyBtnClicked))

	
	--购买礼包按钮上面的文字左边
	self.pCostLabelLeft = MImgLabel.new({text="", size = 20, parent = self.pLayBtnBuy})
	-- self.pCostLabelLeft:setImg(getCostResImg(e_type_resdata.money), 1, "right")
	self.pCostLabelLeft:followPos("center", self.pLayBtnBuy:getContentSize().width/2+2, self.pLayBtnBuy:getContentSize().height, 10)

end

function DlgTriggerGift:updateViews(  )
end

-- 关闭点击
function DlgTriggerGift:onCloseClicked(pView)
	-- if self._nCloseHandler then
	-- 	self._nCloseHandler()
	-- 	return
	-- end
    -- 关闭对话框
    self:closeDlg(false)
end

-- 关闭对话框
function DlgTriggerGift:onCloseDlg( sMsgName, pMsgObj )
	if (pMsgObj and pMsgObj.eDlgType == self.eDlgType) then
		self:closeDlg(false)
	end
end


--重置banner
function DlgTriggerGift:resetBanner( )
	if not self.nCurrPage then
		return
	end

	--隐藏礼包页数
	for i=1,#self.tPageDot do
		self.tPageDot[i]:setVisible(false)
	end
	--隐藏左右箭头
	self.pImgLeftArrow:setVisible(false)
	self.pImgRightArrow:setVisible(false)

	--回收Banner图
	self:pushToIdleBanner()

	--界面不同，删除滚动，再创造
	if self.pPageView then
		self.pPageView:removeFromParent(true)
		self.pPageView = nil
		self.pLayContentList = {}
	end

	--主要数据
	local tTriGiftList = Player:getTriggerGiftData():getTpackListInCd1()
	local nGiftNum = #tTriGiftList
	self.nGiftNum = nGiftNum
	--生成礼包数量
	if self.nGiftNum > 1 then
		self.bIsMove = false
		--显示页数
		local nOffsetX = 40
		local nBeginX = self.pLayPageView:getWidth()/2 - ((self.nGiftNum - 1) * nOffsetX)/2
		for i = 1, self.nGiftNum do
			if i > #self.tPageDot then
				local pLayPage = MUI.MLayer.new()
				self.pLayRoot:addView(pLayPage, 4)
				local pImgDot = MUI.MImage.new("#v1_img_huanyedian1a.png", {scale9=false})
				pLayPage:addView(pImgDot)
				pLayPage.pImgDot = pImgDot
				local pTxtPage = MUI.MLabel.new({text = tostring(i), size = 18})
				pLayPage:addView(pTxtPage)
				pTxtPage:setPosition(0, 0.5)
				table.insert(self.tPageDot, pLayPage)
			else
				self.tPageDot[i]:setVisible(true)
			end
			self.tPageDot[i]:setPosition(nBeginX, -15)
			nBeginX = nBeginX + nOffsetX
		end

		--滚动列表
		self.pPageView  = MUI.MPageView.new{viewRect = cc.rect(0, 0, self.pLayPageView:getWidth(), self.pLayPageView:getHeight())}
		for i=1, self.nGiftNum do
	        local pItem = self.pPageView:newItem()
	        --先加载空层，复用控件
	        local pLayContent = MUI.MLayer.new()
			pLayContent:setLayoutSize(536, 553)
			pItem:addView(pLayContent)
			-- centerInView(pItem, pLayContent)
	        self.pPageView:addItem(pItem)
	        table.insert(self.pLayContentList, pLayContent) 
	    end
	    self.pPageView:reload()
		self.pLayPageView:addView(self.pPageView)

		--跳转指定
		if self.nCurrPage > self.nGiftNum then
			self.nCurrPage = self.nGiftNum
		end
		self.pPageView:gotoPage(self.nCurrPage, false)
		self:updatePageDot(self.nCurrPage)
		self.pPageView:onTouch(function ( event )
	            if event.name == "pageChange" then
	            	self:updatePageDot(event.pageIdx)
	            	self.bIsMove = false
	           	end
	        end)

	elseif self.nGiftNum > 0 then --只有一个的情况
		self.nCurrPage = 1
		local tTriGift = tTriGiftList[self.nCurrPage]
		local pLayContent = self:getBannerFromIdle()
		pLayContent:setData(tTriGift.nPid, tTriGift.nGid)
		self.pLayPageView:addView(pLayContent)
		-- centerInView(self.pLayPageView, pLayContent)

		self:updateBottomBtn()
	end
end

--添入空闲列表
function DlgTriggerGift:pushToIdleBanner( )
	for k,v in pairs(self.pBannerList) do
		v:removeFromParent()
		table.insert(self.pIdleBannerList, v)
	end
	self.pBannerList = {}
end

--添入空闲列表
function DlgTriggerGift:pushToIdleBannerOne( pUi )
	for i=1,#self.pBannerList do
		if pUi == self.pBannerList[i] then
			pUi:removeFromParent()
			table.remove(self.pBannerList, i)
			table.insert(self.pIdleBannerList, pUi)
			break
		end
	end
end

--从空闲列表获取对象
function DlgTriggerGift:getBannerFromIdle( )
	local pBanner = nil
	local nCount = #self.pIdleBannerList
	if nCount > 0 then
		pBanner = self.pIdleBannerList[nCount]
		table.remove(self.pIdleBannerList, nCount)
	end
	if not pBanner then
		pBanner = ItemTriggerGiftPageView.new()
		pBanner:retain()
	end
	table.insert(self.pBannerList, pBanner)
	return pBanner
end

--强制删除对像
function DlgTriggerGift:clearIdleBanner( )
	if self.pIdleBannerList then
		for i=1,#self.pIdleBannerList do
			local pBanner = self.pIdleBannerList[i]
			if not tolua.isnull(pBanner) then
				pBanner:release()
			end
		end
		self.pIdleBannerList = nil
	end
end



function DlgTriggerGift:updatePageDot( _index )
	if _index > 1 then
		self.pImgLeftArrow:setVisible(true)
	else
		self.pImgLeftArrow:setVisible(false)
	end
	if _index < self.nGiftNum then
		self.pImgRightArrow:setVisible(true)
	else
		self.pImgRightArrow:setVisible(false)
	end
	self.nCurrPage = _index

	-- print("_index================", _index)
	for i = 1, #self.tPageDot do
		if i == _index then
			self.tPageDot[i].pImgDot:setCurrentImage("#v1_img_huanyedian1b.png")
		else
			self.tPageDot[i].pImgDot:setCurrentImage("#v1_img_huanyedian1a.png")
		end
	end
	self:updateBottomBtn()

	--将不在三个之中的从放回闲置
	for i=1,#self.pLayContentList do
		if i < _index - 1 or i > _index + 1 then
			local pLayContent = self.pLayContentList[i]
			if pLayContent then
				local pUi = pLayContent:findViewByName("item_triggergift_pageview")
				if not tolua.isnull(pUi) then
					self:pushToIdleBannerOne(pUi)
				end
			end
		end
	end
	--
	--刷新左，中，右的数据
	local tTriGiftList = Player:getTriggerGiftData():getTpackListInCd1()
	for i=1,#self.pLayContentList do
		if i >= _index - 1 and i <= _index + 1 then
			local tTriGift = tTriGiftList[i]
			if tTriGift then
				local pLayContent = self.pLayContentList[i]
				if pLayContent then
					local pUi = pLayContent:findViewByName("item_triggergift_pageview")
					if tolua.isnull(pUi) then
						pUi = self:getBannerFromIdle()
						pUi:setName("item_triggergift_pageview")
						pLayContent:addView(pUi)
					end
					local _nPid, _nGid = pUi:getPidGid()
					if tTriGift.nPid ~= _nPid or tTriGift.nGid ~= _nGid then
						pUi:setData(tTriGift.nPid, tTriGift.nGid)
					end
				end
			end
		end
	end
end

function DlgTriggerGift:updateBottomBtn( )
	if not self.nCurrPage then
		return
	end

	local tTriGiftList = Player:getTriggerGiftData():getTpackListInCd1()
	local tTriGift = tTriGiftList[self.nCurrPage]
	if not tTriGift then
		return
	end

	self.nCurrPid = tTriGift.nPid --礼包id
	self.nCurrGid = tTriGift.nGid --礼品id

	local tConf = getTpackData(self.nCurrPid, self.nCurrGid)
	if not tConf then
		return
	end

	--按钮文字
	local tStr = {
    	{color=_cc.white, text="￥" .. tostring(tConf.disprice)..getConvertedStr(3, 10312)},
    }
	self.pBtnBuy:updateBtnText(tStr)
	--原价
	self.pCostLabelLeft:hideImg()
	local tStr = {
    	{color=_cc.gray, text = getConvertedStr(7, 10113)},
    	{color=_cc.yellow, text = "￥" .. tostring(tConf.orgprice)},
    }
    self.pCostLabelLeft:setString(tStr)
    -- self.pCostLabelRight:setVisible(false)
    local nLen = self.pCostLabelLeft:getContentSize().width
    -- self.pCostLabelLeft:followPos("center", self.pLayBtnBuy:getContentSize().width/2, self.pLayBtnBuy:getContentSize().height + 5, 10)
    --红线
	local fScale = (nLen + 10)/17
	self.pCostLabelLeft:showRedLine(true, fScale)   	
end

function DlgTriggerGift:updateCd() --更新结束cd时间
	for i=1,#self.pBannerList do
		self.pBannerList[i]:updateCd()
	end
end

function DlgTriggerGift:setData( nPid, nGid )
	self.nCurrPage = 1
	if nPid and nGid then
		local tTriGiftList = Player:getTriggerGiftData():getTpackListInCd1()
		for i=1, #tTriGiftList do
			if tTriGiftList[i].nPid == nPid and tTriGiftList[i].nGid == nGid then
				self.nCurrPage = i
				break
			end
		end
	end
	self:resetBanner()
end

function DlgTriggerGift:onBuyBtnClicked( )
	if not self.nCurrPid or not self.nCurrGid then
		return
	end

	local tConf = getTpackData(self.nCurrPid, self.nCurrGid)
	if not tConf then
		return
	end
	local tData = getRechargeDataByKey(tConf.rechargeid)
	if tData then
		reqRecharge(tData)
	end
end

--监听刷新
function DlgTriggerGift:onGiftListRefrsh( )
	-- print("gud_trigger_gift_list_refresh")
	local tTriGiftList = Player:getTriggerGiftData():getTpackListInCd1()
	if #tTriGiftList > 0 then
		self:resetBanner()
	else
		self:closeDlg(false)
	end
end


return DlgTriggerGift