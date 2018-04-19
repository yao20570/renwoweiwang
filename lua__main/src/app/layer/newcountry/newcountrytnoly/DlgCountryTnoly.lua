-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-04-04 18:31:23 星期四
-- Description: 国家科技界面
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local StageItem = require("app.layer.newcountry.newcountrytnoly.StageItem")
local CountryTnolyItem = require("app.layer.newcountry.newcountrytnoly.CountryTnolyItem")

local DlgCountryTnoly = class("DlgCountryTnoly", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgcountrytnoly)
end)

function DlgCountryTnoly:ctor()
	-- body
	self:myInit()
	parseView("dlg_country_tnoly", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgCountryTnoly:myInit()
	-- body
	self.tCurData = nil	-- 当前的列表数据

	self.nSelectStage = 1 --当前所选择的
	self.tStageListItems = {} --存放阶段单项列表
	self.tTnolyItems = {} --存放科技单项列表
	self.nCurStage = Player:getCountryTnoly().nStage --当前开放的阶段
end

--解析布局回调事件
function DlgCountryTnoly:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgCountryTnoly",handler(self, self.onDlgCountryTnolyDestroy))
end

--初始化控件
function DlgCountryTnoly:setupViews()
	-- body
	self:addContentTopSpace()
	--设置标题
	self:setTitle(getConvertedStr(7, 10404))
	--顶部国家贡献层
	self.pLayTop = self:findViewByName("lay_top")
	local pLbContribution = self:findViewByName("lb_contribution")
	pLbContribution:setString(getConvertedStr(7, 10405)) --国家贡献：
	self.pImgRes 	= self:findViewByName("img_res")
	self.pLbResNum 	= self:findViewByName("lb_donate")
	setTextCCColor(self.pLbResNum, _cc.yellow)

	self.pLayContent = self:findViewByName("lay_con")

	--底部编辑层
	self.pLayEdit = self:findViewByName("lay_edit")
	self.pLayEdit:setViewTouched(true)
	self.pLayEdit:setIsPressedNeedScale(false)
	self.pLayEdit:onMViewClicked(handler(self, self.onEditClicked))
	self.pLayEdit:setVisible(false)

	self:updateContent()
	--默认打开最大阶段列表
	self:openMaxOpenedStage()
end

function DlgCountryTnoly:updateViews()
	-- body
	local pCountryTnolyData = Player:getCountryTnoly()
	self.pImgRes:setCurrentImage(getCostResImg(e_type_resdata.countrycoin))
	self.pImgRes:setScale(0.35)
	-- self.pLbResNum:setString(formatCountToStr(pCountryTnolyData.nGoldDonate))
	self.pLbResNum:setString(formatCountToStr(getMyGoodsCnt(e_resdata_ids.countrycoin)))

	--更新阶段展示列表
	if pCountryTnolyData.nStage ~= self.nCurStage then
		self.nCurStage = pCountryTnolyData.nStage
		self:updateContent()
	end

	if self.tTnolyItems and table.nums(self.tTnolyItems) > 0 then
		for k, view in pairs(self.tTnolyItems) do
			if view.updateViews then
				view:updateViews()
			end
		end
	end
	for k, view in pairs(self.tStageListItems) do
		if view.updateViews then
			view:updateViews()
		end
	end

	local tCountryDataVo = Player:getCountryData():getCountryDataVo()
	if tCountryDataVo then
		--是否是国王
		bIsKing = tCountryDataVo:isKing()
		if bIsKing then
			self.pLayEdit:setVisible(true)
		end
	end
end

--编辑按钮层点击事件
function DlgCountryTnoly:onEditClicked()
	--打开科技编辑推荐界面
	local tObject = {}
	tObject.nType = e_dlg_index.dlgtnolyedit --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)
end

--阶段层点击事件打开该阶段阶段科技列表
function DlgCountryTnoly:onItemClicked(pView, bJustShow)
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
function DlgCountryTnoly:addDataItem(pView)
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
	end
	--插入对应位置
	if self.nSelectStage > table.nums(self.tStageListItems) and not self.pTmpLayer then
		self.pScrollLayer:addView(self.pLayTnolyList)
	else
		self.pScrollLayer:insertView(self.pLayTnolyList,self.nSelectStage)
	end
end


--移除内容展开项
function DlgCountryTnoly:removeDataItem()
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
function DlgCountryTnoly:updateContent()
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
	--移除内容展开项
	-- self:removeDataItem()
	-- if self.tStageListItems then
	-- 	for k, v in pairs(self.tStageListItems) do
	-- 		self.pScrollLayer:removeView(v)
	-- 	end
	-- 	self.tStageListItems = nil
	-- end
	-- self.tStageListItems = {}

	--创建阶段列表
	for i = 1, self.nCurStage + 1 do
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
function DlgCountryTnoly:openMaxOpenedStage()
	local nOpened = Player:getCountryTnoly().nStage
	if self.tStageListItems[nOpened] then
		self:onItemClicked(self.tStageListItems[nOpened])
	end
end

-- 析构方法
function DlgCountryTnoly:onDlgCountryTnolyDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgCountryTnoly:regMsgs(  )
	-- body
	-- 注册国家科技刷新消息
	regMsg(self, gud_refresh_country_tnoly, handler(self, self.updateViews))
end
--注销消息
function DlgCountryTnoly:unregMsgs(  )
	-- body
	-- 销毁国家科技刷新消息
	unregMsg(self, gud_refresh_country_tnoly)
end

-- 暂停方法
function DlgCountryTnoly:onPause()
	self:unregMsgs()	
end

--继续方法
function DlgCountryTnoly:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

return DlgCountryTnoly