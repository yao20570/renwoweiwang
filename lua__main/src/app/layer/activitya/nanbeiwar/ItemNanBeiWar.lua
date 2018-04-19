----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-29 21:38:04
-- Description: 南征北战界面
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemActNanBeiWarContent = require("app.layer.activitya.ItemActNanBeiWarContent")
local ItemNanBeiGetReward =  require("app.layer.activitya.nanbeiwar.ItemNanBeiGetReward")
local ItemNanBeiWar = class("ItemNanBeiWar", function()
	return ItemActNanBeiWarContent.new()
end)

--创建函数
function ItemNanBeiWar:ctor()
	self:setupViews()
	--self:updateViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemNanBeiWar",handler(self, self.onItemNanBeiWarDestroy))	
end

--初始化控件
function ItemNanBeiWar:setupViews( )
	--列表
	self.pLayDesc:setVisible(true)
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
	    	pTempView   = ItemNanBeiGetReward.new()
		end
		pTempView:setData(self.tMissions[_index], self.tMissions[_index]:getDesc())
	    return pTempView
	end)
	self.pListView:setItemCount(0)
	--上下箭头
	local pUpArrow, pDownArrow = getUpAndDownArrow()
	self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
	self.pListView:reload()
	self.tMissions = {}
end

--更新
function ItemNanBeiWar:updateViews( )
	if not self.pData then
		return
	end

	if not self.pItemTime then
		self.pItemTime = createActTime(self.pLyTitle,self.pData,cc.p(0,170))
	end
	self.pItemTime:setCurData(self.pData)

    self:setDesc(self.pData.sDesc)
--	if self.pData.sDesc then
--		self.pLbDescCn:setString(self.pData.sDesc)
--	end
	if self.pData.sTitle then
		self.pLbSecTitle:setString(self.pData.sTitle)
	end

	--更新列表数据
	if not self.pData.getMissions then
		return
	end
	local tMissions = self.pData:getMissions()
	local nPrevCount = #self.tMissions
	local nCurrCount = #tMissions
	self.tMissions = tMissions
	if nPrevCount ~= nCurrCount then
		if self.pListView:getItemCount() > 0 then
		    self.pListView:removeAllItems()
		end
		if self.tMissions then
		    self.pListView:setItemCount(nCurrCount) 
		    self.pListView:reload()
		end
	else
		self.pListView:notifyDataSetChange(true)
	end
end

--析构方法
function ItemNanBeiWar:onItemNanBeiWarDestroy(  )
	if not self.pData then
		return
	end
	-- --全部领取后
	-- if self.pData:getIsGotAllReward() then
	-- 	Player:removeActById(e_id_activity.nanbeiwar)
	-- end
end

-- 注册消息
function ItemNanBeiWar:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

-- 注销消息
function ItemNanBeiWar:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end


function ItemNanBeiWar:onResume(  )
	self:regMsgs()
end

function ItemNanBeiWar:onPause(  )
	self:unregMsgs()
end

--设置数据 _data
function ItemNanBeiWar:setData(_tData)
	if not _tData then
		return
	end
	self:setCurData(_tData)
	self:updateViews()
end


return ItemNanBeiWar