-- ItemOnlineWelfare.lua
---------------------------------------------
-- Author: xiesite
-- Date: 2017-12-11 11:52:00
-- 在线福利
---------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ItemActNanBeiWarContent = require("app.layer.activitya.ItemActNanBeiWarContent")
local ItemOWGetReward =  require("app.layer.activitya.onlinewelfare.ItemOWGetReward")
local ItemOnlineWelfare = class("ItemOnlineWelfare", function()
	return ItemActNanBeiWarContent.new()
end)

--创建函数
function ItemOnlineWelfare:ctor()
	self.tConfLogList = {}
	self:setupViews()
	self:updateViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemOnlineWelfare",handler(self, self.onItemSevenDayLogDestroy))	
end

--初始化控件
function ItemOnlineWelfare:setupViews( )
	self.pLayDesc:setVisible(true)
end

--更新
function ItemOnlineWelfare:updateViews( )
	if not self.pData then
		return
	end

	if not self.pItemTime then
		self.pItemTime = createActTime(self.pLyTitle,self.pData,cc.p(0,170))
	else
		self.pItemTime:setCurData(self.pData)
	end

	self:setDesc(self.pData.sDesc)
	--if self.pData.sDesc then
	--	self.pLbDescCn:setString(self.pData.sDesc)
	--end
	if self.pData.sTitle then
		self.pLbSecTitle:setString(self.pData.sTitle)
	end
	self.pData:resetSort()
	self.tConfLogList = self.pData.tConfLogList or self.tConfLogList

	--更新列表数据
	if not self.pListView then
		--列表
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
		local nCount = table.nums(self.tConfLogList)
		self.pListView:setItemCount(nCount)
		self.pListView:setItemCallback(function ( _index, _pView ) 
		    local pTempView = _pView
		    if pTempView == nil then
		    	pTempView   = ItemOWGetReward.new()
			end
			pTempView:setItemData(self.tConfLogList[_index], self.pData.nStartST)
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

--析构方法
function ItemOnlineWelfare:onItemSevenDayLogDestroy(  )
end

-- 注册消息
function ItemOnlineWelfare:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

-- 注销消息
function ItemOnlineWelfare:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end


function ItemOnlineWelfare:onResume(  )
	self:regMsgs()
end

function ItemOnlineWelfare:onPause(  )
	self:unregMsgs()
end

--设置数据 _data
function ItemOnlineWelfare:setData(_tData)
	if not _tData then
		return
	end
	self:setCurData(_tData)
	self:updateViews()
end


return ItemOnlineWelfare