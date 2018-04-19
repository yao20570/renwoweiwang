-- ItemSevenDayLog.lua
---------------------------------------------
-- Author: dshulan
-- Date: 2017-07-04 16:31:00
-- 七日登录
---------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ItemActNanBeiWarContent = require("app.layer.activitya.ItemActNanBeiWarContent")
local ItemSevDayGetReward =  require("app.layer.activitya.sevendaylog.ItemSevDayGetReward")
local ItemSevenDayLog = class("ItemSevenDayLog", function()
	return ItemActNanBeiWarContent.new()
end)

--创建函数
function ItemSevenDayLog:ctor()
	self.tConfLogList = {}
	-- self:setupViews()
	-- self:addAccountImg("#v1_fonts_qtqd.png")
	self:updateViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemSevenDayLog",handler(self, self.onItemSevenDayLogDestroy))	
end

--初始化控件
function ItemSevenDayLog:setupViews( )
	
end

--更新
function ItemSevenDayLog:updateViews( )
	if not self.pData then
		return
	end

	if not self.pItemTime then
		self.pItemTime = createActTime(self.pLyTitle,self.pData,cc.p(0,170))
	end
	self.pItemTime:setCurData(self.pData)

	
	if self.pData.sDesc then
		self.pLbSecTitle:setString(self.pData.sDesc)
	end
	self.pData:resetSort()
	self.tConfLogList = self.pData.tConfLogList or self.tConfLogList

	--更新列表数据
	if not self.pListView then
		--列表
		local pSize = self.pLayContent:getContentSize()
		self.pListView = MUI.MListView.new {
			viewRect   = cc.rect(0, 0, pSize.width, pSize.height - 20),
			direction  = MUI.MScrollView.DIRECTION_VERTICAL,
			itemMargin = {left =  0,
	            right =  0,
	            top =  0, 
	            bottom =  0},
	    }
	    self.pLayContent:addView(self.pListView)
		local nCount = table.nums(self.tConfLogList)
		self.pListView:setItemCount(nCount)
		self.pListView:setItemCallback(function ( _index, _pView ) 
		    local pTempView = _pView
		    if pTempView == nil then
		    	pTempView   = ItemSevDayGetReward.new()
			end
			pTempView:setItemSevenData(self.tConfLogList[_index])
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
function ItemSevenDayLog:onItemSevenDayLogDestroy(  )
end

-- 注册消息
function ItemSevenDayLog:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

-- 注销消息
function ItemSevenDayLog:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end


function ItemSevenDayLog:onResume(  )
	self:regMsgs()
end

function ItemSevenDayLog:onPause(  )
	self:unregMsgs()
end

--设置数据 _data
function ItemSevenDayLog:setData(_tData)
	if not _tData then
		return
	end
	self:setCurData(_tData)
	self:updateViews()
end


return ItemSevenDayLog