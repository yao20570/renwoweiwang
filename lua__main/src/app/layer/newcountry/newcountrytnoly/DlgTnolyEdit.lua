-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-04-10 14:21:23 星期二
-- Description: 国家科技编辑推荐界面
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local StageItem = require("app.layer.newcountry.newcountrytnoly.StageItem")
local CountryTnolyItem = require("app.layer.newcountry.newcountrytnoly.CountryTnolyItem")

local DlgTnolyEdit = class("DlgTnolyEdit", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgtnolyedit)
end)

function DlgTnolyEdit:ctor()
	-- body
	self:myInit()
	parseView("dlg_tnoly_edit", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgTnolyEdit:myInit()
	-- body
	self.tCurData = nil	-- 当前的列表数据

	self.nSelectStage = 1 --当前所选择的
	self.tStageListItems = {} --存放阶段单项列表
	self.tTnolyItems = {} --存放科技单项列表
	self.nCurStage = Player:getCountryTnoly().nStage --当前开放的阶段
end

--解析布局回调事件
function DlgTnolyEdit:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgTnolyEdit",handler(self, self.onDlgTnolyEditDestroy))
end

--初始化控件
function DlgTnolyEdit:setupViews()
	-- body
	self:addContentTopSpace()
	--设置标题
	self:setTitle(getConvertedStr(7, 10444))
	self.pLbYituijian = self:findViewByName("lb_yituijian")
	self.pLbTuijianTip 	= self:findViewByName("lb_tuijian_tip")
	setTextCCColor(self.pLbTuijianTip, _cc.pwhite)
	self.pLbTuijianTip:setString(getConvertedStr(7, 10445))

	self.pLayContent = self:findViewByName("lay_con")

	self:updateContent()
	--默认打开最大阶段列表
	self:openMaxOpenedStage()
end

function DlgTnolyEdit:updateViews()
	-- body
	local pCountryTnolyData = Player:getCountryTnoly()
	--已推荐科技数量
	local nDidRecNum = pCountryTnolyData:getDidRecommendNum()
	local str = {
		{text = getConvertedStr(7, 10446), color = _cc.white}, --已推荐科技数量：
		{text = nDidRecNum, color = _cc.green}
	}
	self.pLbYituijian:setString(str)

	--更新阶段展示列表
	if pCountryTnolyData.nStage ~= self.nCurStage then
		self.nCurStage = pCountryTnolyData.nStage
		self:updateContent()
	end

	if self.tTnolyItems and table.nums(self.tTnolyItems) > 0 then
		for k, view in pairs(self.tTnolyItems) do
			view:updateViews()
		end
	end
	for k, view in pairs(self.tStageListItems) do
		view:updateViews()
	end
end


--阶段层点击事件打开该阶段阶段科技列表
function DlgTnolyEdit:onItemClicked(pView, bJustShow)
	-- body
	if bJustShow then
		bJustShow = false
	else
		--如果该项重复选择
		if self.tSelItem and self.tSelItem.nIndex == pView.nIndex then
			if self.tSelItem:getSelectedState() then
				--移除内容展开项
				self:removeDataItem()
			else
				--添加内容展开项
				self:addDataItem(pView)
				self.tSelItem:setSelectedState(true)
			end
			return
		end
	end

	if self.tSelItem then
		--移除特殊项
		self.pScrollLayer:removeView(self.nSelectStage)
		self.pLayTnolyList = nil
	end

	--存在选中项
	if self.tSelItem then
		self.tSelItem:setSelectedState(false)
		self.tSelItem = nil
	end

	--记录行
	self.nSelectStage = pView.nIndex + 1
	--记录选中项
	self.tSelItem = self.tStageListItems[pView.nIndex]

	--添加内容展开项
	self:addDataItem(pView)
	self.tSelItem:setSelectedState(true)

end

--展开相应阶段的科技列表
function DlgTnolyEdit:addDataItem(pView)
	--展开内容层
	self.pLayTnolyList = MUI.MLayer.new()
	self.tTnolyList = pView:getItemData() or {}

	local nListCount = table.nums(self.tTnolyList)
	local nTotalHeight = 141 * nListCount + 29
	self.pLayTnolyList:setLayoutSize(640, nTotalHeight)
	for i = 1, nListCount do
		local pTempView = CountryTnolyItem.new(i)
		local nHeight = pTempView:getHeight()
		pTempView:setItemData(self.tTnolyList[i])
		self.pLayTnolyList:addView(pTempView, 10)
		pTempView:setPosition(0, nTotalHeight - nHeight*i)
		self.tTnolyItems[i] = pTempView
		pTempView:setSelfClickHandler(handler(self, self.onTnolyClicked))
	end
	--插入对应位置
	if self.nSelectStage > table.nums(self.tStageListItems) and not self.pTmpLayer then
		self.pScrollLayer:addView(self.pLayTnolyList)
	else
		self.pScrollLayer:insertView(self.pLayTnolyList,self.nSelectStage)
	end
end

--科技项点击事件(请求推荐)
function DlgTnolyEdit:onTnolyClicked(_data)
	local tCurData = _data
	if tCurData == nil then
		return
	end
	local tCountryDataVo = Player:getCountryData():getCountryDataVo()
	if tCountryDataVo then
		--是否是国王
		bIsKing = tCountryDataVo:isKing()
		if bIsKing then
			if tCurData.nRecommend == 1 then
				--取消推荐
				SocketManager:sendMsg("reqRecommendTnoly", {tCurData.nId, 2})
			else
				if Player:getCountryTnoly():getIsCanRecommend() then
					--选为推荐
					SocketManager:sendMsg("reqRecommendTnoly", {tCurData.nId, 1})
				else
					TOAST(getConvertedStr(7, 10435))
				end
			end
		else
			TOAST(getConvertedStr(7, 10441))
		end
	end
end


--移除内容展开项
function DlgTnolyEdit:removeDataItem()
	-- body
	--存在选中项
	if self.tSelItem then
		self.tSelItem:setSelectedState(false)
		self.tSelItem = nil
		--移除特殊项
		self.pScrollLayer:removeView(self.nSelectStage)
		self.tTnolyItems = {}
		self.pLayTnolyList = nil
	end
end

-- 更新内容
function DlgTnolyEdit:updateContent()
	--新建一个SCrollLayer
	local tSize = self.pLayContent:getContentSize()
	if not self.pScrollLayer then
		self.pScrollLayer = MUI.MScrollLayer.new({viewRect=cc.rect(0, 0, tSize.width, tSize.height),
		    touchOnContent = false,
		    direction=MUI.MScrollLayer.DIRECTION_VERTICAL})
		self.pScrollLayer:setBounceable(true)
		self.pLayContent:addView(self.pScrollLayer, 10)

		local tAllTnolyData = getCountryTnolyData()
		local nAllStages = 0
		for k, v in pairs(tAllTnolyData) do
			if v.nStage and v.nStage ~= nAllStages then
				nAllStages = nAllStages + 1
			end
		end
		--所有阶段
		self.nAllStages = nAllStages
	end
	if self.pTmpLayer then
		self.pScrollLayer:removeView(self.pTmpLayer)
		self.pTmpLayer = nil
	end

	--创建阶段列表
	for i = 1, self.nCurStage do
		if not self.tStageListItems[i] and i <= self.nAllStages then
			local pItemView = StageItem.new(i)
			self.pScrollLayer:addView(pItemView)
			local tData = getCountryTnolysByStage(i)
			pItemView:setItemData(tData)
			self.tStageListItems[i] = pItemView
			pItemView.nIndex = i
			pItemView:onMViewClicked(handler(self, self.onItemClicked))
		end
	end

	local size = self.pScrollLayer:getScrollNode():getContentSize()
	local nContentHeight = self.pLayContent:getContentSize().height
	if size.height < nContentHeight then
		self.pTmpLayer = MUI.MLayer.new()
		self.pTmpLayer:setLayoutSize(size.width, nContentHeight - size.height)
		self.pScrollLayer:addView(self.pTmpLayer, 10)
	end
end

--默认打开最大阶段列表
function DlgTnolyEdit:openMaxOpenedStage()
	local nOpened = Player:getCountryTnoly().nStage
	self:onItemClicked(self.tStageListItems[nOpened])
end

-- 析构方法
function DlgTnolyEdit:onDlgTnolyEditDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgTnolyEdit:regMsgs(  )
	-- body
	-- 注册国家科技刷新消息
	regMsg(self, gud_refresh_country_tnoly, handler(self, self.updateViews))
end
--注销消息
function DlgTnolyEdit:unregMsgs(  )
	-- body
	-- 销毁国家科技刷新消息
	unregMsg(self, gud_refresh_country_tnoly)
end

-- 暂停方法
function DlgTnolyEdit:onPause()
	self:unregMsgs()	
end

--继续方法
function DlgTnolyEdit:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

return DlgTnolyEdit