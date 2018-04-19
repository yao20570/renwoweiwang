----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-02-16 15:07:00
-- Description: 限时Boss连击结果界面
-----------------------------------------------------

-- 副本主界面DlgCommon
local DlgCommon = require("app.common.dialog.DlgCommon")
local TLBossHitResultTitle = require("app.layer.tlboss.TLBossHitResultTitle")
local TLBossHitResultGoods = require("app.layer.tlboss.TLBossHitResultGoods")
local ScrollViewEx = require("app.common.listview.ScrollViewEx")
local nArrowHight = 30 --箭头高度
local nCol = 4
local nSubHeight = 130
-- local tCheckData =  {
-- 		{
-- 			{k = 100001, v = 10},
-- 			{k = 100001, v = 10},
-- 			{k = 100001, v = 10},
-- 			{k = 100001, v = 10},
-- 			{k = 100001, v = 10},
-- 		},
-- 		{
-- 			{k = 100002, v = 10},
-- 			{k = 100002, v = 10},
-- 			{k = 100002, v = 10},
-- 			{k = 100002, v = 10},
-- 			{k = 100002, v = 10},
-- 			{k = 100002, v = 10},
-- 		},
-- 		{
-- 			{k = 100003, v = 10},
-- 			{k = 100003, v = 10},
-- 			{k = 100003, v = 10},
-- 		},
-- 		{
-- 			{k = 100004, v = 10},
-- 			{k = 100004, v = 10},
-- 			{k = 100004, v = 10},
-- 			{k = 100004, v = 10},
-- 		},
-- 		{
-- 			{k = 100005, v = 10},
-- 			{k = 100005, v = 10},
-- 			{k = 100005, v = 10},
-- 			{k = 100005, v = 10},
-- 			{k = 100005, v = 10},
-- 			{k = 100005, v = 10},
-- 		},
-- 	}

local DlgTLBossHitResult = class("DlgTLBossHitResult", function()
	return DlgCommon.new(e_dlg_index.tlbosshitresult)
end)

function DlgTLBossHitResult:ctor( tStormVos )
	self.tStormVos = tStormVos
	if #self.tStormVos == 1 then
		self._nContentH, self._nBottomH = 408 - 130, 130
		self.pLayBottom:setLocalZOrder(0)
		self.sTitle = getConvertedStr(3, 10843)
		parseView("dlg_tlboss_hit_result_one", handler(self, self.onParseViewCallback))
	else
		self._nContentH, self._nBottomH = 608 - 130, 130
		self.pLayBottom:setLocalZOrder(0)
		self.sTitle = getConvertedStr(3, 10804)
		parseView("dlg_tlboss_hit_result", handler(self, self.onParseViewCallback))
	end
end

--解析界面回调
function DlgTLBossHitResult:onParseViewCallback( pView )
	self:addContentView(pView, false)

	self:setTitle(self.sTitle)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgTLBossHitResult",handler(self, self.onDlgTLBossHitResultDestroy))
end

-- 析构方法
function DlgTLBossHitResult:onDlgTLBossHitResultDestroy(  )
    self:onPause()
end

function DlgTLBossHitResult:regMsgs(  )
end

function DlgTLBossHitResult:unregMsgs(  )
end

function DlgTLBossHitResult:onResume(  )		
	self:regMsgs()
	self:updateViews()
end

function DlgTLBossHitResult:onPause(  )
	self:unregMsgs()
end

function DlgTLBossHitResult:setupViews(  )
	local pLayReward = self:findViewByName("lay_reward")
	local pLayBtnSubmit = self:findViewByName("lay_btn_submit")

	--创建scrollView
	local nTotalHeight = 0
	self.pLayContent = MUI.MLayer.new()
	--ui集
	self.pUiList = {}
	for i=1,#self.tStormVos do --连击次数
		local bIsDouble = self.tStormVos[i]:getIsDouble()
		local pTitle = TLBossHitResultTitle.new(i, bIsDouble)
		pTitle:setVisible(false)

		local tGoodsList = self.tStormVos[i]:getGoodsList()
		local pGoods = TLBossHitResultGoods.new(tGoodsList)
		pGoods:setVisible(false)
		table.insert(self.pUiList, {pTitle = pTitle, pGoods = pGoods})		
		nTotalHeight = nTotalHeight + pTitle:getContentSize().height
		nTotalHeight = nTotalHeight + pGoods:getContentSize().height
	end
	--设置内容层尺寸
	local pSize = pLayReward:getContentSize()
	self.pLayContent = MUI.MLayer.new()
	self.pLayContent:setLayoutSize(pSize.width, nTotalHeight)
	--将ui集加入层
	local nTopY = nTotalHeight
	for i=1,#self.pUiList do
		--标题
		local pTitle = self.pUiList[i].pTitle
		nTopY = nTopY - pTitle:getHeight()
		pTitle:setPosition(0, nTopY)
		self.pLayContent:addView(pTitle)
		--物品
		local pGoods = self.pUiList[i].pGoods
		nTopY = nTopY - pGoods:getHeight()
		pGoods:setPosition(0, nTopY)
		self.pLayContent:addView(pGoods)
	end


	--滚动层
    self.pSView = ScrollViewEx.new( pSize.width, pSize.height)
	self.pSView:addView(self.pLayContent)
	self.pSView:setBounceable(false) --是否开启回弹功能
	pLayReward:addView(self.pSView)

	--每一帧设置显示
	gRefreshViewsAsync(self, #self.pUiList, function ( _bEnd, _index )
		if self.pUiList[_index] then
			self.pUiList[_index].pTitle:setVisible(true)
			self.pUiList[_index].pGoods:setData()
			self.pUiList[_index].pGoods:setVisible(true)
		end
    end)
    if #self.tStormVos > 1 then
	    --上下箭头    
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pSView:setUpAndDownArrow(pUpArrow, pDownArrow)	  
		self.pSView:scrollToBegin(false)
	end
	--确定按钮
	local pBtnSubmit = getCommonButtonOfContainer(pLayBtnSubmit, TypeCommonBtn.L_BLUE, getConvertedStr(3, 10381))
	pBtnSubmit:onCommonBtnClicked(handler(self, self.onCloseClicked))
end

function DlgTLBossHitResult:updateViews(  )
	
end

return DlgTLBossHitResult