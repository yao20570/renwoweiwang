
-- Author: maheng
-- Date: 2017-06-17 11:56:24
-- 装备分解详情提示对话框


local DlgCommon = require("app.common.dialog.DlgCommon")
local EquipDropLayer = require("app.layer.bag.EquipDropLayer")
local EquipDropListLayer = require("app.layer.bag.EquipDropListLayer")

local DlgEquipDecomTip = class("DlgEquipDecomTip", function ()
	return DlgCommon.new(e_dlg_index.dlgequipdecomtip)
end)

--构造
function DlgEquipDecomTip:ctor( )
	-- body
	self:myInit()	
	parseView("dlg_equip_decom_tip", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgEquipDecomTip:myInit()
	-- body
	self.pCurData = nil
	self.tItemGroup = nil
	self.pEquipVo = nil
end
  
--解析布局回调事件
function DlgEquipDecomTip:onParseViewCallback( pView )
	-- body
	self:addContentView(pView, true)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgEquipDecomTip",handler(self, self.onDlgEquipDecomTipDestroy))
end

--初始化控件
function DlgEquipDecomTip:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(6,10427))
	self.pLayRoot = self:findViewByName("root")
	self.pLayBg = self:findViewByName("lay_bg")

	self.pLayRichTitle = self:findViewByName("lay_rich_title")

	self.pLayList = self:findViewByName("lay_list")

	self.pLayItems = self:findViewByName("lay_items")
	local x = 10 
	local y = self.pLayItems:getHeight()
	self.tItemGroup = {}
	for i = 1, 6 do
		local itemlayer = EquipDropLayer.new()
		local cul = i%3
		if cul == 0 then
			cul = 3
		end
		itemlayer:setPosition(x + (cul - 1)*itemlayer:getWidth(), y - math.ceil(i/3)*itemlayer:getHeight())
		self.pLayItems:addView(itemlayer, 10)
		self.tItemGroup[i] = itemlayer
	end	
	self.nDropWidth = self.tItemGroup[1]:getContentSize().width
	self.nDropHeight = self.tItemGroup[1]:getContentSize().height
end

-- 修改控件内容或者是刷新控件数据
function DlgEquipDecomTip:updateViews()
	-- body
	-- dump(self.pEquipVo, "self.pEquipVo ====")
	if self.pCurData then
		local sStr = {
			{color=_cc.pwhite,text=getConvertedStr(6, 10429)},
			{color=_cc.yellow,text=self.pCurData.sName},
			{color=_cc.pwhite,text=getConvertedStr(6, 10430)},
		}
		if not self.pRichTitle then
			self.pRichTitle  = MUI.MLabel.new({
		        text="",
		        size=20,
		        anchorpoint=cc.p(0.5, 0.5),
		        dimensions = cc.size(400, 0),
		        })
			self.pLayRichTitle:addView(self.pRichTitle, 100)
			centerInView(self.pLayRichTitle, self.pRichTitle)
		end
		self.pRichTitle:setString(sStr, false)

		if not self.pBottomTip then
			self.pBottomTip = MUI.MLabel.new({
				text = getTipsByIndex(20015),
				size = 18,
				})
			self.pLayBottom:addView(self.pBottomTip, 100)
			self.pBottomTip:setPosition(self.pLayBottom:getWidth()/2, 
				self.pBtnRight:getPositionY()+self.pBtnRight:getHeight()+33)
		end
		local sStr = getTextColorByConfigure(getTipsByIndex(20015))
		self.pBottomTip:setString(sStr, false)

		--强化成功所消耗的资源
		local nCostNum = 0
		if self.pEquipVo then
			self.tStrenthCost =  self.pEquipVo.tStrenthCost
			nCostNum = table.nums(self.tStrenthCost)
		end

		self.tItems = getDropItemsShow(self.pCurData.nDecomDrop)
		local nCt =  table.nums(self.tItems) + nCostNum
		if nCostNum > 0 then
			--资源返还比例
			local nReturnPer1 = getEquipInitParam("streturn")
			--突破石返还比例
			local nReturnPer2 = getEquipInitParam("streturn2")
			for i = 1, nCostNum do
				local tItem = {}
				local nGoodId = self.tStrenthCost[i].k
				local tGood = getGoodsByTidFromDB(nGoodId)
				tItem.item = tGood
				if nGoodId == e_item_ids.strengthstone then
					tItem.max = math.floor(self.tStrenthCost[i].v*nReturnPer2)
				else
					tItem.max = math.floor(self.tStrenthCost[i].v*nReturnPer1)
				end
				tItem.min = tItem.max
				table.insert(self.tItems, tItem)
			end
		end
		-- dump(self.tItems, "self.tItems", 100)
		
		--分解得到的物品超过6个就做成列表, 不超过就跟原来一样处理
		if nCt <= 6 then
			self.pLayList:setVisible(false)
			self.pLayItems:setVisible(true)
			--居中对齐
			if nCt <= 3 then
				for i = 1, nCt do
					self.tItemGroup[i]:setPositionY(self.pLayItems:getHeight()/2 - self.nDropWidth/2 - 20)
				end

				local nNum = math.min(6, nCt)
				local nW = 500 / nNum
				local nH = 380 / nNum
				for i=1,nNum do
					local nX = (i - 1) * nW + nW / 2 - self.nDropWidth / 2
					if self.tItemGroup[i] then
						self.tItemGroup[i]:setPositionX(nX)
					end
				end
				self.pLayRichTitle:setPositionY(self.pLayRichTitle:getPositionY() - self.nDropHeight/2 + 20)
			end
			

			for i = 1, 6 do 
				if self.tItems[i] then
					self.tItemGroup[i]:setCurData(self.tItems[i])
					self.tItemGroup[i]:setVisible(true)
				else
					self.tItemGroup[i]:setVisible(false)
				end
			end
		else
			self.pLayItems:setVisible(false)
			self.pLayList:setVisible(true)
			self.tShowItems = self:getShowItemList()
			if not self.pListView then
				self.pListView = createNewListView(self.pLayList)
				self.pListView:setItemCount(table.nums(self.tShowItems))
				self.pListView:setItemCallback(handler(self, self.everyCallback))
				self.pListView:reload(true)
			else
				self.pListView:notifyDataSetChange(false, table.nums(self.tShowItems))
			end
		end
	end
end

--获得展示列表
function DlgEquipDecomTip:getShowItemList()
	local tList = {}
	local tData = self.tItems

	if tData then
		--将列表分成3个3个为一组的列表
		tList = separateTable(tData, 3) 
	end

	return tList
end

-- 每帧回调 _index 下标 _pView 视图
function DlgEquipDecomTip:everyCallback( _index, _pView )
	local pView = _pView
	if not pView then
		pView = EquipDropListLayer.new()
	end
	if _index and self.tShowItems[_index] then
		pView:setCurData(self.tShowItems[_index])	
	end

	return pView
end

--析构方法
function DlgEquipDecomTip:onDlgEquipDecomTipDestroy()
	self:onPause()
end

-- 注册消息
function DlgEquipDecomTip:regMsgs( )
	-- body

end

-- 注销消息
function DlgEquipDecomTip:unregMsgs(  )
	-- body

end


--暂停方法
function DlgEquipDecomTip:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgEquipDecomTip:onResume( )
	-- body
	-- self:updateViews()
	self:regMsgs()
end

--设置装备ID
function DlgEquipDecomTip:setEquipID( _nequipId, _sUuid )
	-- body
	self.pCurData = getBaseEquipDataByID(tonumber(_nequipId)) or self.pCurData
	self.pEquipVo = Player:getEquipData():getEquipVoByUuid(_sUuid)
	self:updateViews()
end
return DlgEquipDecomTip
