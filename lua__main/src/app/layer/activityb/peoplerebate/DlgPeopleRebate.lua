----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-07-04 21:21:52
-- Description: 全民返利
-----------------------------------------------------
local DlgBase = require("app.common.dialog.DlgBase")
local CountryRecharge  = require("app.layer.activityb.peoplerebate.CountryRecharge")
local ItemPeopleRebateGetReward  = require("app.layer.activityb.peoplerebate.ItemPeopleRebateGetReward")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local DlgPeopleRebate = class("DlgPeopleRebate", function()
	return DlgBase.new(e_dlg_index.peoplerebate)
end)

function DlgPeopleRebate:ctor(  )
	parseView("dlg_people_rebate", handler(self, self.onParseViewCallback))
end

--解析布局回调事件
function DlgPeopleRebate:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace()
	
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgPeopleRebate",handler(self, self.onDlgPeopleRebateDestroy))
end

--初始化控件
function DlgPeopleRebate:setupViews()
	self.pLayTime = self:findViewByName("lay_time")

	local pLayCountry1 = self:findViewByName("lay_country1")
	local pCountryRecharge1 = CountryRecharge.new(1)
	pLayCountry1:addView(pCountryRecharge1)

	local pLayCountry2 = self:findViewByName("lay_country2")
	local pCountryRecharge2 = CountryRecharge.new(2)
	pLayCountry2:addView(pCountryRecharge2)

	local pLayCountry3 = self:findViewByName("lay_country3")
	local pCountryRecharge3 = CountryRecharge.new(3)
	pLayCountry3:addView(pCountryRecharge3)
	self.pCountryRecharges = {
		pCountryRecharge1,
		pCountryRecharge2,
		pCountryRecharge3,
	}

	self.pLayIcon = self:findViewByName("lay_icon")
	self.txtGiftName = self:findViewByName("txt_gift_name")

	self.pLayDesc = self:findViewByName("lay_desc")

	self.pTxtDesc = self:findViewByName("txt_desc")

	local pImgEffect = self:findViewByName("img_effect")
	pImgEffect:setFlippedY(true)

	--去充值
	local pLayBtnRecharge = self:findViewByName("lay_btn_recharge")
	local pBtnRecharge = getCommonButtonOfContainer(pLayBtnRecharge, TypeCommonBtn.M_YELLOW, getConvertedStr(3, 10375))
	pBtnRecharge:onCommonBtnClicked(handler(self, self.onRechargeClicked))

	--进度条
	local pLayBar = self:findViewByName("lay_bar")
	self.pLayBar = pLayBar
	local pSize = pLayBar:getContentSize()
	self.nBarWidth = pSize.width - 10
	self.pRechargeBar = MCommonProgressBar.new({bar = "v1_bar_yellow_11.png", barWidth = self.nBarWidth, barHeight = pSize.height})
	centerInView(self.pLayBar, self.pRechargeBar)
	pLayBar:addView(self.pRechargeBar)
	self.pImgBarLines = {}
	self.pTxtBarGolds = {}

	--banner
	self.pLayBannerBg = self:findViewByName("lay_banner_bg")
	local pMBanner = setMBannerImage(self.pLayBannerBg,TypeBannerUsed.fl_qmfl)
	pMBanner:setMBannerOpacity(100)

	--列表
	-- self.pLayContent = self:findViewByName("lay_items")
	-- local pSize = self.pLayContent:getContentSize()
	-- self.pListView = MUI.MListView.new {
	-- 	viewRect   = cc.rect(0, 0, pSize.width, pSize.height - 10),
	-- 	direction  = MUI.MScrollView.DIRECTION_VERTICAL,
	-- 	itemMargin = {left =  0,
 --             right =  0,
 --             top =  0,
 --             bottom =  10},
 --    }
 --    self.pLayContent:addView(self.pListView)
	-- self.pListView:setItemCallback(function ( _index, _pView ) 
	--     local pTempView = _pView
	--     if pTempView == nil then
	--     	pTempView   = ItemPeopleRebateGetReward.new()
	-- 	end
	-- 	pTempView:setData(self.tMissions[_index])
	--     return pTempView
	-- end)
	-- self.pListView:setItemCount(0)
	-- self.pListView:reload()
	self.tMissions = {}
end

--控件刷新
function DlgPeopleRebate:updateViews()
	local tData = Player:getActById(e_id_activity.peoplerebate)
	if not tData then
		self:closeDlg(false)
		return	
	end
	if tData then
		--设置标题
		self:setTitle(tData.sName)

		--活动时间
		if not self.pActTime then
			self.pActTime = createActTime(self.pLayTime, tData, cc.p(0,0))
		else
			self.pActTime:setCurData(tData)
		end

		--礼包显示
		local nGiftId = tData:getCountryGiftId()
		if nGiftId then
			local tGoods = getGoodsByTidFromDB(nGiftId)
			if tGoods then
				getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.item, tGoods, TypeIconGoodsSize.M)
				self.txtGiftName:setString(tGoods.sName)
			end
		end

		--描述
		self.pTxtDesc:setString(tData.sDesc)
	end

	--更新国家充值
	self:updateCountry()
	--更新进度条
	self:updateBar()
	--更新列表
	self:updateTargetList()
end

--更新国家充值
function DlgPeopleRebate:updateCountry( )
	local tData = Player:getActById(e_id_activity.peoplerebate)
	if not tData then
		return
	end
	local tCGolds = tData:getCountryRecharges()
	for i=1,#tCGolds do
		if self.pCountryRecharges[i] then
			self.pCountryRecharges[i]:setData(tCGolds[i])
		end
	end
end

--更新横条
function DlgPeopleRebate:updateBar()
	local tData = Player:getActById(e_id_activity.peoplerebate)
	if not tData then
		return
	end

	local pSize = self.pLayBar:getContentSize()
	--创建横条ui
	local function createBarUi( nGold, nIndex, nX, bIsLast)
		local bIsUp = nIndex%2 == 0 
		--最后一个不显示线
		if not bIsLast then
			--图片
			local pImg = self.pImgBarLines[nIndex]
			if not pImg then
				pImg = MUI.MImage.new("#v1_line_blue3.png")
				self.pImgBarLines[nIndex] = pImg
				if bIsUp then --上
					pImg:setAnchorPoint(0.5, 0)
				else --下
					pImg:setAnchorPoint(0.5, 1)
				end
				pImg:setScaleY(3)
				self.pLayBar:addView(pImg, 99)
			end
			pImg:setVisible(true)
			--位置
			local nY = pSize.height
			if bIsUp then
				nY = 0
			end
			pImg:setPosition(nX, nY)
		end

		--文字
		local sStr = string.format("(%s)", nGold)
		local pTxt = self.pTxtBarGolds[nIndex]
		if not pTxt then
			pTxt = MUI.MLabel.new({text = sStr, size = 16})
			self.pTxtBarGolds[nIndex] = pTxt
			if bIsUp then --上
				pTxt:setAnchorPoint(0.5, 0)
			else --下
				pTxt:setAnchorPoint(0.5, 1)
			end
			self.pLayBar:addView(pTxt, 99)
		end
		pTxt:setString(sStr, false)
		pTxt:setVisible(true)
		if tData.nAGold >= nGold then
			setTextCCColor(pTxt,_cc.yellow)
		end
		--位置
		local nY = 0
		if bIsUp then
			nY = 30
		else
			nY = -20
		end
		--位置修正
		local nRightX = (nX + pTxt:getContentSize().width/2)
		local nOffsetX = 0
		if nRightX > pSize.width then
			nOffsetX = pSize.width - nRightX
		end
		pTxt:setPosition(nX + nOffsetX, nY)
	end
	
	--先隐藏全部
	for k,v in pairs(self.pImgBarLines) do
		v:setVisible(false)
	end
	for k,v in pairs(self.pTxtBarGolds) do
		v:setVisible(false)
	end
	--设置累积横条
	-- 下，上，下，上
	local tGoldList = tData:getRechargeGolds()
	local nWidth = self.nBarWidth
	local nSubWidth = nWidth/#tGoldList
	local nBeginX = nSubWidth
	for i=1,#tGoldList do
		local bIsLast = i == #tGoldList
		local nGold = tGoldList[i]
		createBarUi(nGold, i, nBeginX, bIsLast)
		nBeginX = nBeginX + nSubWidth
	end
	--横条设置进度
	self.pRechargeBar:setPercent(tData:getScoreBoxPercent())
end

--更新目标列表
function DlgPeopleRebate:updateTargetList( )
	local tData = Player:getActById(e_id_activity.peoplerebate)
	if not tData then
		return
	end

	local tMissions = tData:getCulGoldAwardConf()
	local nCurrCount = #tMissions
	self.tMissions = tMissions
	--列表
	if not self.pLayContent then
		self.pLayContent = self:findViewByName("lay_items")
		local pSize = self.pLayContent:getContentSize()
		self.pListView = MUI.MListView.new {
			viewRect   = cc.rect(0, 0, pSize.width, pSize.height - 10),
			direction  = MUI.MScrollView.DIRECTION_VERTICAL,
			itemMargin = {left =  0,
	             right =  0,
	             top =  0,
	             bottom =  10},
	    }
	    self.pLayContent:addView(self.pListView)
		self.pListView:setItemCallback(function ( _index, _pView ) 
		    local pTempView = _pView
		    if pTempView == nil then
		    	pTempView   = ItemPeopleRebateGetReward.new()
			end
			pTempView:setData(self.tMissions[_index])
		    return pTempView
		end)
		self.pListView:setItemCount(nCurrCount)
		--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
		self.pListView:reload(true)
	else
		self.pListView:notifyDataSetChange(true, nCurrCount)
	end
end

--析构方法
function DlgPeopleRebate:onDlgPeopleRebateDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgPeopleRebate:regMsgs(  )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end
--注销消息
function DlgPeopleRebate:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end

--暂停方法
function DlgPeopleRebate:onPause( )
	self:unregMsgs()	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgPeopleRebate:onResume( _bReshow )
	if _bReshow and self.pListView then
		-- 如果是重新显示，定位到顶部
		self.pListView:scrollToBegin()					
	end
	self:updateViews()
	self:regMsgs()
end

--前往充值界面
function DlgPeopleRebate:onRechargeClicked( pView )
	local tObject = {}
	tObject.nType = e_dlg_index.dlgrecharge --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)   
end


return DlgPeopleRebate