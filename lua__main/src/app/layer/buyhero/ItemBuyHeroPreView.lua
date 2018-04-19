-- Author: liangzhaowei
-- Date: 2017-06-14 10:47:34
-- 英雄属性item

local MCommonView = require("app.common.MCommonView")
local ItemBuyHeroIcon = require("app.layer.buyhero.ItemBuyHeroIcon")
local ItemBuyHeroPreView = class("ItemBuyHeroPreView", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function ItemBuyHeroPreView:ctor()
	-- body
	self:myInit()

	parseView("item_buy_hero_preview", handler(self, self.onParseViewCallback))


	--注册析构方法
	self:setDestroyHandler("ItemBuyHeroPreView",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemBuyHeroPreView:myInit()
	self.pData = {} --数据
	self.tShowData = {} --显示列表
	for i=1,2 do
		self.tShowData[i] = {}
	end
end

--解析布局回调事件
function ItemBuyHeroPreView:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	--ly      
	self.pLyUpList = self:findViewByName("ly_up_list")
	self.pLyDownList = self:findViewByName("ly_down_list")
	self.pLyUp = self:findViewByName("ly_up")


	--lb
	self.pLbTitle = self:findViewByName("lb_title")
	self.pLbTitle:setString(getConvertedStr(5, 10179))
	

	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemBuyHeroPreView:setupViews( )


	local tConTable = {}
	--文本
	local tLb= {
		{getConvertedStr(5, 10175),getC3B(_cc.pwhite)},
		{getConvertedStr(5, 10177),getC3B(_cc.blue)},
	}
	tConTable.tLabel = tLb
	self.pText =  createGroupText(tConTable)
	self.pLyUp:addView(self.pText,10)
	self.pText:setPosition(300, 500)
	self.pText:setAnchorPoint(cc.p(0.5,0.5))
	-- 以下为刷新内容
	-- self.pText:setLabelCnCr(1,"changeLb") 

end

-- 修改控件内容或者是刷新控件数据
function ItemBuyHeroPreView:updateViews(  )
	-- body
end

--析构方法
function ItemBuyHeroPreView:onDestroy(  )
	-- body
end

--设置数据 _data
function ItemBuyHeroPreView:setCurData(_tData,_nType)
	if not _tData then
		return
	end

	if _nType and self.nType and self.nType == _nType then
		return
	end

	self.pData = _tData
	self.nType = _nType

	if self.nType == 1 then
		self.pText:setLabelCnCr(1,getConvertedStr(5, 10175))
		self.pText:setLabelCnCr(2,getConvertedStr(5, 10177))
	else
		self.pText:setLabelCnCr(1,getConvertedStr(5, 10176))
		self.pText:setLabelCnCr(2,getConvertedStr(5, 10178))
	end


	--初始化显示数据
	for i=1,2 do
		self.tShowData[i] = {}
	end


	for k,v in pairs(self.pData) do
		if bJudgeHeroData(v)  then -- 根据id来区分类型
			table.insert(self.tShowData[1],v)
		else
		 	table.insert(self.tShowData[2],v)
		end
	end

	-- for k,v in pairs(self.tShowData) do
	-- 	v = separateTable(v,4) --以四个为单位切分数组
	-- end
	if self.tShowData[1] and table.nums(self.tShowData[1]) > 0 then
		self.tShowData[1] = separateTable(self.tShowData[1],4)
	end

	if self.tShowData[2] and table.nums(self.tShowData[2]) > 0 then
		self.tShowData[2] = separateTable(self.tShowData[2],4)
	end

	
	--上面物品展示
	if not self.pUpListView then
		self.pUpListView = createNewListView(self.pLyUpList)
		if table.nums(self.tShowData[1])> 0  then
			self.pUpListView:setItemCount(table.nums(self.tShowData[1]))
			self.pUpListView:setItemCallback(handler(self, self.everyUpCallback))
			
			self.pUpListView:reload()

		end
	else
		if self.pUpListView:getItemCount() > 0 then
			self.pUpListView:removeAllItems()
		end
		if self.tShowData[1] then
			self.pUpListView:setItemCount(table.nums(self.tShowData[1]) or 0) 
			self.pUpListView:reload()
		end
	end

	--下面物品展示
	if not self.pDnListView then
		self.pDnListView = createNewListView(self.pLyDownList)
		if table.nums(self.tShowData[2])> 0  then
			self.pDnListView:setItemCount(table.nums(self.tShowData[2]))
			self.pDnListView:setItemCallback(handler(self, self.everyDnCallback))

			self.pDnListView:reload()

		end
	else
		if self.pDnListView:getItemCount() then
			if self.pDnListView:getItemCount() > 0 then
				self.pDnListView:removeAllItems()
			end
			if self.tShowData[2] then
				self.pDnListView:setItemCount(table.nums(self.tShowData[2]) or 0) 
				self.pDnListView:reload()
			end
		end
	end



end

-- 没帧回调 _index 下标 _pView 视图
function ItemBuyHeroPreView:everyUpCallback( _index, _pView )
	local pView = _pView
	if not pView then
		if self.tShowData[1][_index] then
			pView = ItemBuyHeroIcon.new()
		end
	end

	if _index and self.tShowData[1][_index] then
		pView:setCurData(self.tShowData[1][_index])	
	end

	return pView
end

-- 没帧回调 _index 下标 _pView 视图
function ItemBuyHeroPreView:everyDnCallback( _index, _pView )
	local pView = _pView
	if not pView then
		if self.tShowData[2][_index] then
			pView = ItemBuyHeroIcon.new()
		end
	end

	if _index and self.tShowData[2][_index] then
		pView:setCurData(self.tShowData[2][_index])	
	end

	return pView
end






return ItemBuyHeroPreView