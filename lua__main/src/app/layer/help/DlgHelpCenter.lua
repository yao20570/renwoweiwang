-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-05-23 16:01:23 星期二
-- Description: 帮助中心
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local ItemServerTab = require("app.layer.serverlist.ItemServerTab")
local HelpItem = require("app.layer.help.HelpItem")

local DlgHelpCenter = class("DlgHelpCenter", function()
	-- body
	return DlgBase.new(e_dlg_index.dlghelpcenter)
end)

function DlgHelpCenter:ctor( _nOpenDlgType, _nDlgSecType )
	-- body
	self:myInit(_nOpenDlgType, _nDlgSecType)
	parseView("dlg_help_center", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgHelpCenter:myInit(_nOpenDlgType, _nDlgSecType)
	-- body
	self.tCurData = nil	-- 当前的列表数据

	self.tSec = false   -- 是否是二级列表
	self.nSelectTab = 1 --当前所选择的
	self.nSelRow = -1   --选中的行 -1表示没选择
	--跳转
	if _nOpenDlgType then
		self.nId = getHelpIdByDlgType(_nOpenDlgType, _nDlgSecType)
	end
	if self.nId then
		self.tHelpData = getHelpDataById(self.nId)
		if self.tHelpData then
			self.nSelectTab = self.tHelpData.system
			self.nSelRow = self.tHelpData.second
		end
	end
end

--解析布局回调事件
function DlgHelpCenter:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgHelpCenter",handler(self, self.onDlgHelpDestroy))
end

--左侧按钮列表点击事件
function DlgHelpCenter:clickLeftTabItem(_pIndex)
	if _pIndex then
		if self.nSelectTab ~= _pIndex then
			self.nSelectTab = _pIndex
			--重新获取服务器列表数据
	    	self.pLeftList:notifyDataSetChange(false)
	     	--创建内容层
	        self:createContent()
	        self.pScrollLayer:scrollToBegin(false)
		end
	end
end

--初始化控件
function DlgHelpCenter:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(7, 10001))
	--列表层
	self.tHelpSystem = getHelpSystemTable()
	local nItemCount = table.nums(self.tHelpSystem)
	local pImgDown = self:findViewByName("img_down")
	pImgDown:setFlippedY(true)

	self.pLayContent = self:findViewByName("lay_content")

	--左侧一级分类列表
	self.pLayLeftList = self:findViewByName("lay_list")

	gRefreshViewsAsync(self, 3, function ( _bEnd, _index )
		if(_index == 1) then
			if not self.pLeftList then
				self.pLeftList = createNewListView(self.pLayLeftList, nil, nil, nil, 0, 3, 0, 0)
				self.pLeftList:setItemCount(nItemCount)
				self.pLeftList:setItemCallback(function ( _index, _pView )
			        local pView = _pView
			    	if pView == nil then
			    		if self.tHelpSystem[_index] then
							pView = ItemServerTab.new()
			    		end
			        end
			        -- 必须在这里执行，不能在创建的时候执行，不然_index的值会是错误的
					pView:setHandler(handler(self, self.clickLeftTabItem))

			        if _index and self.tHelpSystem[_index] then
			    		pView:setCurData(self.tHelpSystem[_index], _index, self.nSelectTab)
			    	end

			        return pView
			    end)
		    	self.pLeftList:reload()
			end
		elseif(_index == 2) then
    		--创建内容层
	       	self:createContent()
		elseif(_index == 3) then
			self.pScrollLayer:scrollToBegin(false)
		end
		if _bEnd then
			self:clickCurSelected()
		end

	end)

end

function DlgHelpCenter:updateViews()
	-- body
end

function DlgHelpCenter:onItemClicked(pView, bJustShow)
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

	if self.tSelItem and self.nSelRow ~= -1 then
		--移除特殊项
		self.pScrollLayer:removeView(self.nSelRow)
		self.pLayData = nil
	end

	--存在选中项
	if self.tSelItem then
		self.tSelItem:setSelectedState(false)
		self.tSelItem = nil
	end


	--记录行
	self.nSelRow = pView.nIndex + 1
	--记录选中项
	self.tSelItem = self.tSecListItem[pView.nIndex]

	--添加内容展开项
	self:addDataItem(pView)
	self.tSelItem:setSelectedState(true)

end

--添加内容展开项
function DlgHelpCenter:addDataItem(pView)
	local tData = pView:getItemData()
	--展开内容层
	self.pLayData = MUI.MLayer.new()
	local pLbData = MUI.MLabel.new({
		text = tData.content,
		size = 20,
		anchorpoint = cc.p(0, 1),
	    dimensions = cc.size(450, 0)})
	self.pLayData:setLayoutSize(484, pLbData:getHeight() + 20)
	pLbData:setPosition(20, self.pLayData:getHeight())
	self.pLayData:addView(pLbData)

	--插入对应位置
	if self.nSelRow > table.nums(self.tSecListItem) and not self.pTmpLayer then
		self.pScrollLayer:addView(self.pLayData)
	else
		self.pScrollLayer:insertView(self.pLayData,self.nSelRow)
	end
end

--移除内容展开项
function DlgHelpCenter:removeDataItem()
	-- body
	--存在选中项
	if self.tSelItem then
		self.tSelItem:setSelectedState(false)
		self.tSelItem = nil
	-- end
	-- if self.nSelRow ~= -1 then
		--移除特殊项
		self.pScrollLayer:removeView(self.nSelRow)
		self.nSelRow = -1
		self.pLayData = nil
	end
end

function DlgHelpCenter:clickCurSelected()
	-- body
	--如果有选中的触发点击
	if self.tSecListItem and table.nums(self.tSecListItem) > 0 and self.nSelRow > 0 then

		for k, v in pairs(self.tSecListItem) do
			if k == self.nSelRow then
				--记录选中项
				self.tSelItem = v
				--记录行
				self.nSelRow = k + 1
				--移动到某行
				self.pScrollLayer:scrollToPosition(k, false)
				--添加内容展开项
				self:addDataItem(self.tSelItem)
				self.tSelItem:setSelectedState(true)
				break
			end
		end

	end
end

-- 创建右边内容
function DlgHelpCenter:createContent()
	--新建一个SCrollLayer
	local tSize = self.pLayContent:getContentSize()
	if not self.pScrollLayer then
		self.pScrollLayer = MUI.MScrollLayer.new({viewRect=cc.rect(0, 0, tSize.width, tSize.height),
		    touchOnContent = false,
		    direction=MUI.MScrollLayer.DIRECTION_VERTICAL})
		self.pScrollLayer:setBounceable(true)
		self.pLayContent:addView(self.pScrollLayer, 10)
	end
	if self.pTmpLayer then
		self.pScrollLayer:removeView(self.pTmpLayer)
		self.pTmpLayer = nil
	end
	--移除内容展开项
	self:removeDataItem()
	if self.tSecListItem then
		for k, v in pairs(self.tSecListItem) do
			self.pScrollLayer:removeView(v)
		end
		self.tSecListItem = nil
	end
	self.tSecListItem = {}
	
	if self.tLabelContent then
		self.pScrollLayer:removeView(self.tLabelContent)
		self.tLabelContent = nil
	end


	local tSecList = getHelpSecData(self.nSelectTab)
	--大于1则有二级条目, 创建列表项
	if table.nums(tSecList) > 1 then
		for k, v in pairs(tSecList) do
			local pItemView = HelpItem.new(k)
			pItemView:setItemData(tSecList[k])
			self.pScrollLayer:addView(pItemView)
			self.tSecListItem[k] = pItemView
			pItemView.nIndex = k
			pItemView:setViewTouchEnable(true)
			pItemView:onMViewClicked(handler(self, self.onItemClicked))
		end
	else
		--直接显示帮助内容
		self.tLabelContent = MUI.MLabel.new({
	        text = tSecList[1].content,
	        size = 22,
	        anchorpoint = cc.p(0, 1),
	        dimensions = cc.size(450, 0)
	    })
	    setTextCCColor(self.tLabelContent, _cc.white)
	    self.tLabelContent:setViewTouched(false)
	    self.pScrollLayer:addView(self.tLabelContent)
	    self.tLabelContent:setPosition(0, self.pScrollLayer:getHeight())
	end

	local size = self.pScrollLayer:getScrollNode():getContentSize()
	local nContentHeight = self.pLayContent:getContentSize().height
	if size.height < nContentHeight then
		self.pTmpLayer = MUI.MLayer.new()
		self.pTmpLayer:setLayoutSize(size.width, nContentHeight - size.height)
		self.pScrollLayer:addView(self.pTmpLayer, 10)
	end
end

-- 析构方法
function DlgHelpCenter:onDlgHelpDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgHelpCenter:regMsgs(  )
	-- body
end
--注销消息
function DlgHelpCenter:unregMsgs(  )
	-- body	
end

-- 暂停方法
function DlgHelpCenter:onPause()
	self:unregMsgs()	
end

--继续方法
function DlgHelpCenter:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

return DlgHelpCenter