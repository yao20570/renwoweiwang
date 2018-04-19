----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-28 21:21:00
-- Description: 国家城池
-----------------------------------------------------
local FoldView = require("app.common.listview.FoldView")
local ItemCountryCityTab = require("app.layer.newcountry.countrycity.ItemCountryCityTab")
local DlgBase = require("app.common.dialog.DlgBase")
local DlgNCountryCity = class("DlgNCountryCity", function()
	return DlgBase.new(e_dlg_index.countrycity)
end)

function DlgNCountryCity:ctor(  )
	GLOBALDlgNCountryCity = self
	self.tCountryCityTabs = {}
	parseView("dlg_country_city", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgNCountryCity:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层

	self:setTitle(getConvertedStr(3, 10740))

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgNCountryCity",handler(self, self.onDlgNCountryCityDestroy))
end

-- 析构方法
function DlgNCountryCity:onDlgNCountryCityDestroy(  )
    self:onPause()
end

function DlgNCountryCity:regMsgs(  )
	regMsg(self, gud_countrycity_data_refresh, handler(self, self.updateViews))
end

function DlgNCountryCity:unregMsgs(  )
	unregMsg(self, gud_countrycity_data_refresh)
end

function DlgNCountryCity:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function DlgNCountryCity:onPause(  )
	self:unregMsgs()
end

function DlgNCountryCity:setupViews(  )
	local pLayScrollView = self:findViewByName("lay_scrollview")
	self.pFoldView = FoldView.new(pLayScrollView:getWidth(), pLayScrollView:getHeight())
	self.pFoldView:setAnchorPoint(0,0)
	pLayScrollView:addView(self.pFoldView)
	self.pFoldView:setTopAndBottomMargin(5, 5)
	self.pFoldView:setFoldCallBack(function ( _index, _pView )          
        local pTempView = _pView
        if pTempView == nil then
            pTempView = ItemCountryCityTab.new(self.pFoldView)  
            self.tCountryCityTabs[_index] = pTempView
        end   
        pTempView:setData(_index, self.tListData[_index])
        return pTempView
    end)

 --    --上下箭头
	-- local pUpArrow, pDownArrow = getUpAndDownArrow()
	-- self.pFoldView:setUpAndDownArrow(pUpArrow, pDownArrow)
end

function DlgNCountryCity:getTabIndexByBlockId( nBlockId )
	if not self.tListData then
		return nil
	end
	for i=1,#self.tListData do
		if self.tListData[i].nBlockId == nBlockId then
			return i
		end
	end
	return nil
end

function DlgNCountryCity:updateViews(  )
	--第一次是先请求数据
	if not self.bIsReqed then
		self.bIsReqed = true
		SocketManager:sendMsg("reqCountryCity",{})
		return
	end

	local tCountryCitys = {}
	local tData = Player:getCountryCityData():getMyCountryCitys()
	for k,v in pairs(tData) do
		table.insert(tCountryCitys, v)
	end
	--按皇宫>州>郡排列
	table.sort(tCountryCitys,function ( a, b )
		local tCityDataA = getWorldCityDataById(a:getId())
		local tCityDataB = getWorldCityDataById(a:getId())
		if tCityDataA and tCityDataB then
			return tCityDataA.kind > tCityDataB.kind
		end
		return false
	end)
	--区域表
	local tBlockDict = {}
	for i=1,#tCountryCitys do
		local tCountryCityVo = tCountryCitys[i]
		local tSysCityData = getWorldCityDataById(tCountryCityVo:getId())
		if tSysCityData then
			local nBlockId = tSysCityData.map
			if not tBlockDict[nBlockId] then
				tBlockDict[nBlockId] = {}
				tBlockDict[nBlockId].nBlockId = nBlockId
			end
			table.insert(tBlockDict[nBlockId], tCountryCityVo)
		end
	end
	local tBlockList = {}
	for k,v in pairs(tBlockDict) do
		table.insert(tBlockList, {nBlockId = v.nBlockId, nCount = #v, tCountryCityVoList = v})
	end
	table.sort(tBlockList, function ( a, b )
		return a.nBlockId > b.nBlockId
	end)
	--正式表 tBlockList
	--总表
	table.insert(tBlockList, 1, {nBlockId = 9999, nCount = #tCountryCitys, tCountryCityVoList = tCountryCitys})

	---------------------------------------------刷新
	local bIsReload = false --是否第一次加载
	local bTabNumChange = false --是否节点数据发生更改
	local bCityNumChange = false --是否节点里面的数量发生变化
	if self.tListData == nil then
		bIsReload = true
	elseif #self.tListData ~= #tBlockList then
		bTabNumChange = true
	else
		for i=1,#self.tListData do
			if self.tListData[i] and tBlockList[i] then
				if self.tListData[i].nCount ~= tBlockList[i].nCount then
					bCityNumChange = true
				end
			end
		end
	end


	if bIsReload then
		self.tListData = tBlockList
		self.pFoldView:setFoldCount(#self.tListData)
		self.pFoldView:reload()
		--打开第一个
		if self.tCountryCityTabs[1] then
			self.tCountryCityTabs[1]:onItemClicked()
		end
	elseif bTabNumChange then ---折叠点数量有改变
		--找开上一次记录的集合BlockId
		local tIndex = self.pFoldView:getOpenedIndex()
		local tOpenBlock = {}
		for i=1,#tIndex do
			local nIndex = tIndex[i]
			local nBlockId = self.tListData[nIndex].nBlockId
			if nBlockId then
				tOpenBlock[nBlockId] = true
			end
		end
		--记录上一次移动的位置
		local nY = self.pFoldView:getScrollPosY()
		--更新ListData表
		self.tListData = tBlockList
		self.pFoldView:setFoldCount(#self.tListData)
		self.tCountryCityTabs = {}
		self.pFoldView:reload()
		--打开之前关闭的
		for i=1,#self.tListData do
			local nBlockId = self.tListData[i].nBlockId
			if tOpenBlock[nBlockId] then
				if self.tCountryCityTabs[i] then
					self.tCountryCityTabs[i]:reOpenSubLayer()
				end
			end
		end
		--滚到之前的位置
		self.pFoldView:setScrollPosY(nY)
	elseif bCityNumChange then --城池数量发生改变
		--找开上一次记录的集合BlockId
		local tIndex = self.pFoldView:getOpenedIndex()
		local tOpenBlock = {}
		for i=1,#tIndex do
			local nIndex = tIndex[i]
			local nBlockId = self.tListData[nIndex].nBlockId
			local nCount = self.tListData[nIndex].nCount
			if nBlockId then
				tOpenBlock[nBlockId] = nCount
			end
		end
		--记录上一次移动的位置
		local nY = self.pFoldView:getScrollPosY()
		--更新ListData表
		self.tListData = tBlockList
		--打开之前关闭的
		for i=1,#self.tListData do
			if self.tCountryCityTabs[i] then
				self.tCountryCityTabs[i]:setData(i, self.tListData[i])

				local nBlockId = self.tListData[i].nBlockId
				local nCount = self.tListData[i].nCount
				if tOpenBlock[nBlockId] and tOpenBlock[nBlockId] ~= nCount then --数量不等于之前的都要进行更新
					self.tCountryCityTabs[i]:reOpenSubLayer()
				end
			end
		end
		--滚到之前的位置
		self.pFoldView:setScrollPosY(nY)
	else --城池数据发生改变
		--更新ListData表
		self.tListData = tBlockList
		for i=1,#self.tListData do
			if self.tCountryCityTabs[i] then
				self.tCountryCityTabs[i]:setData(i, self.tListData[i])
				self.tCountryCityTabs[i]:onUpdateSubLayer()
			end
		end
	end
end


return DlgNCountryCity