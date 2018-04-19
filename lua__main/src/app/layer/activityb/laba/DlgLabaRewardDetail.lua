-----------------------------------------------------
-- author: luwenjing
-- updatetime:  2018-01-15 9:38:19 星期一
-- Description: 拉霸奖励详情对话框
-----------------------------------------------------
local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemLabaReward = require("app.layer.activityb.laba.ItemLabaReward")

local DlgLabaRewardDetail = class("DlgLabaRewardDetail", function ()
	-- body
	return DlgCommon.new(e_dlg_index.labarewarddetail,676,70)
end)

function DlgLabaRewardDetail:ctor( _nType)
	-- body
	
	self:myInit()
end

--初始化成员变量
function DlgLabaRewardDetail:myInit(  )
	self:setupViews()
	self:onResume()
	self:setDestroyHandler("DlgLabaRewardDetail",handler(self, self.onDlgLabaRewardDetailDestroy))
end
function DlgLabaRewardDetail:setupViews( )
	-- body
	self:setTitle(getConvertedStr(9, 10098))
	
	self.pContent=MUI.MLayer.new()

	self.pContent:setLayoutSize(530,676)
	self:addContentView(self.pContent, false) --加入内容层

end

function DlgLabaRewardDetail:updateViews( )
	-- body
	--获得滚动的图标
	local  tActData = Player:getActById(e_id_activity.laba)
	local tData ={}
	if tActData then
		tData = luaSplit(tActData.sRule, "#")
	end
	if not tData then
		return
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
		    	pTempView = ItemLabaReward.new()
			end
			pTempView:setData(tData[_index])
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

function DlgLabaRewardDetail:onResume(  )
	self:updateViews()
end

function DlgLabaRewardDetail:onDlgLabaRewardDetailDestroy( )
	-- body
end

return DlgLabaRewardDetail