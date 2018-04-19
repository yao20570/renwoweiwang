---------------------------------------------
-- Author: maheng
-- Date: 2017-11-23 10:33:32
-- 红包馈赠
---------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ItemActNanBeiWarContent = require("app.layer.activitya.ItemActNanBeiWarContent")
local ItemRedPacketReward =  require("app.layer.activitya.redpacket.ItemRedPacketReward")
local ItemRedPacket = class("ItemRedPacket", function()
	return ItemActNanBeiWarContent.new()
end)

--创建函数
function ItemRedPacket:ctor()
	self:addAccountImg("#v2_fonts_chongzhihonbao.png", cc.p(0,70))
	self:setupViews()
	self:updateViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemRedPacket",handler(self, self.onItemRedPacketDestroy))	
end

--初始化控件
function ItemRedPacket:setupViews( )
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
	self.pListView:setItemCallback(function ( _index, _pView ) 
	    local pTempView = _pView
	    if pTempView == nil then
	    	pTempView   = ItemRedPacketReward.new()
		end
		pTempView:setItemAwdInfo(self.tListData[_index])
	    return pTempView
	end)
	self.pListView:setItemCount(0)
	--上下箭头
	local pUpArrow, pDownArrow = getUpAndDownArrow()
	self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
	self.pListView:reload()
	self.tListData = {}
	setMBannerImage(self.pLayBannerBg,TypeBannerUsed.ac_hbkz)
end

--更新
function ItemRedPacket:updateViews( )
	if not self.pData then
		return
	end

	if not self.pItemTime then
		self.pItemTime = createActTime(self.pLyTitle,self.pData,cc.p(0,170))
	end
	self.pItemTime:setCurData(self.pData)

	--标题
	if self.pData.sTitle then
		self.pLbSecTitle:setString(self.pData.sTitle)
	end
	--活动说明
    self:setDesc(self.pData.sDesc)
--	if self.pData.sDesc then
--		self.pLayDesc:setVisible(true)
--		self.pLbDescCn:setString(self.pData.sDesc)
--	end

	--更新列表数据
	if not self.pData.tAllAwdInfo then
		return
	end
	local tListData = self.pData.tAllAwdInfo
	local nPrevCount = #self.tListData
	local nCurrCount = #tListData
	self.tListData = tListData
	if nPrevCount ~= nCurrCount then
		if self.pListView:getItemCount() > 0 then
		    self.pListView:removeAllItems()
		end
		if self.tListData then
		    self.pListView:setItemCount(nCurrCount) 
		    self.pListView:reload()
		end
	else
		self.pListView:notifyDataSetChange(true)
	end
end

--析构方法
function ItemRedPacket:onItemRedPacketDestroy(  )
	if not self.pData then
		return
	end
end

-- 注册消息
function ItemRedPacket:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

-- 注销消息
function ItemRedPacket:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end


function ItemRedPacket:onResume(  )
	self:regMsgs()
end

function ItemRedPacket:onPause(  )
	self:unregMsgs()
end

--设置数据 _data
function ItemRedPacket:setData(_tData)
	if not _tData then
		return
	end
	self:setCurData(_tData)
	self:updateViews()
end


return ItemRedPacket