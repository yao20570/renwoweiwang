----------------------------------------------------- 
-- author: maheng
-- updatetime: 2018-02-28 19:38:04
-- Description: 攻城拔寨
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemActNanBeiWarContent = require("app.layer.activitya.ItemActNanBeiWarContent")
local ItemAttackVillageAward =  require("app.layer.activitya.attackvillage.ItemAttackVillageAward")
local ItemAttackVillage = class("ItemAttackVillage", function()
	return ItemActNanBeiWarContent.new()
end)

--创建函数
function ItemAttackVillage:ctor()
	self:setupViews()
	--self:updateViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemAttackVillage",handler(self, self.onDestroy))	
end

--初始化控件
function ItemAttackVillage:setupViews( )
	--列表
	self.pLayDesc:setVisible(true)
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
	    	pTempView   = ItemAttackVillageAward.new()
		end
		pTempView:setData(self.tConfs[_index])
	    return pTempView
	end)
	self.pListView:setItemCount(0)
	--上下箭头
	local pUpArrow, pDownArrow = getUpAndDownArrow()
	self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
	self.pListView:reload()
	self.tConfs = {}
end

--更新
function ItemAttackVillage:updateViews( )
	if not self.pData then
		return
	end
	
	if not self.pItemTime then
		self.pItemTime = createActTime(self.pLyTitle,self.pData,cc.p(0,170))
	end
	self.pItemTime:setCurData(self.pData)

	self:setDesc(self.pData.sDesc)
	--if self.pData.sDesc then
	--	self.pLbDescCn:setString(self.pData.sDesc)
	--end
	if self.pData.sTitle then
		self.pLbSecTitle:setString(self.pData.sTitle)
	end

	--更新列表数据
	local nCurrCount = #self.pData.tConfs
	self.tConfs = self.pData.tConfs
	self.pListView:notifyDataSetChange(true, nCurrCount)
end

--析构方法
function ItemAttackVillage:onDestroy(  )
	if not self.pData then
		return
	end

end

-- 注册消息
function ItemAttackVillage:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

-- 注销消息
function ItemAttackVillage:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end


function ItemAttackVillage:onResume(  )
	self:regMsgs()
end

function ItemAttackVillage:onPause(  )
	self:unregMsgs()
end

--设置数据 _data
function ItemAttackVillage:setData(_tData)
	if not _tData then
		return
	end
	self:setCurData(_tData)
	self:updateViews()
end


return ItemAttackVillage