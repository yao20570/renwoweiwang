-----------------------------------------------------
-- author: luwenjing
-- updatetime:  2018-03-13 14:07:19 星期二
-- Description: 冥界入侵敌军详情对话框
-----------------------------------------------------
local DlgCommon = require("app.common.dialog.DlgCommon")
local DlgAlert = require("app.common.dialog.DlgAlert")
local ItemGhostDetail = require("app.layer.world.ItemGhostDetail")
local DlgGhostdomAtkDetail = class("DlgGhostdomAtkDetail", function ()
	-- body
	return DlgCommon.new(e_dlg_index.ghostdomAtkDetail)
end)

function DlgGhostdomAtkDetail:ctor( _tData)
	-- body
	
	self.tData = _tData or self.tData
	self:myInit()
end

--初始化成员变量
function DlgGhostdomAtkDetail:myInit(  )
	self:setupViews()
	self:updateViews()
	self:setDestroyHandler("DlgGhostdomAtkDetail",handler(self, self.onDestroy))
end
function DlgGhostdomAtkDetail:setupViews( )
	-- body
	self:setTitle(getConvertedStr(9, 10176))

	self.pContent=MUI.MLayer.new()

	self.pContent:setLayoutSize(540,660)
	self:addContentView(self.pContent, true) --加入内容层
	
	self:setBottomBtnVisible(false)
	
end

function DlgGhostdomAtkDetail:updateViews( )
	-- body

	
	if not self.tData then
		self:closeDlg(false)
		return
	end
	-- --更新列表数据
	if not self.pListView then
		--列表
		local pSize = self.pContent:getContentSize()
		self.pListView = MUI.MListView.new {
			viewRect   = cc.rect(0, 0, pSize.width, pSize.height),
			direction  = MUI.MScrollView.DIRECTION_VERTICAL,
			itemMargin = {
				left   = 0,
	            right  = 0,
	            top    = 0, 
	            bottom = 10}
	    }
	    self.pContent:addView(self.pListView)
		local nCount = table.nums(self.tData)
		self.pListView:setItemCount(nCount)
		self.pListView:setItemCallback(function ( _index, _pView ) 
		    local pTempView = _pView
		    if pTempView == nil then
		    	pTempView = ItemGhostDetail.new()
			end
			pTempView:setData(self.tData[_index],_index)
		    return pTempView
		end)
		self.pListView:reload()
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
	else
		self.pListView:notifyDataSetChange(true)
	end
end


function DlgGhostdomAtkDetail:onDestroy( )
	-- body
end

return DlgGhostdomAtkDetail