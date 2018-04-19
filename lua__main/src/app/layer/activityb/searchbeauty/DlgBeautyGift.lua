-----------------------------------------------------
-- author: luwenjing
-- updatetime:  2018-01-15 9:38:19 星期一
-- Description: 拉霸奖励详情对话框
-----------------------------------------------------
local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemBeautyGift = require("app.layer.activityb.searchbeauty.ItemBeautyGift")

local DlgBeautyGift = class("DlgBeautyGift", function ()
	-- body
	return DlgCommon.new(e_dlg_index.beautygift)
end)

function DlgBeautyGift:ctor( tData)
	-- body
	self:myInit()
	self.tData = tData

	parseView("dlg_beauty_gift", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgBeautyGift:myInit(  )
end

--解析布局回调事件
function DlgBeautyGift:onParseViewCallback( pView )
	self.pView = pView
	-- body
	self:addContentView(pView) --加入内容层
	
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgBeautyGift",handler(self, self.onDlgBeautyDestroy))
end

function DlgBeautyGift:setupViews( )
	-- body
	self:setTitle(getConvertedStr(9, 10098))
	
	self.pContent =  self.pView:findViewByName("ly_giftList")
	self:setOnlyConfirm()
end

function DlgBeautyGift:updateViews( )
 	
 	local tData = {}
 	sortGoodsList(self.tData)
	for i=1, #self.tData do
		local nIndex = math.ceil(i/5)
		if not tData[nIndex] then
			tData[nIndex] = {}
		end
		table.insert(tData[nIndex], copyTab(self.tData[i]))
	end
	
	-- --更新列表数据
	if not self.pListView then
		--列表
		local pSize = self.pContent:getContentSize()
		self.pListView = MUI.MListView.new {
			viewRect   = cc.rect(0, 0, pSize.width, pSize.height-20),
			direction  = MUI.MScrollView.DIRECTION_VERTICAL,
			itemMargin = {
				left   = 0,
	            right  = 0,
	            top    = 15, 
	            bottom = -15}
	    }
	    self.pListView:setPositionY(10)
	    self.pContent:addView(self.pListView)
		local nCount = table.nums(tData)
		self.pListView:setItemCount(nCount)
		self.pListView:setItemCallback(function ( _index, _pView ) 
		    local pTempView = _pView
		    if pTempView == nil then
		    	pTempView = ItemBeautyGift.new()
			end
			pTempView:setCurData(tData[_index])
		    return pTempView
		end)
		--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)	
		self.pListView:reload()
	else
		self.pListView:notifyDataSetChange(true)
	end
end

function DlgBeautyGift:onResume(  )
	self:updateViews()
end

function DlgBeautyGift:onDlgBeautyDestroy( )
	-- body
end

return DlgBeautyGift