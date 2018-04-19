-- KillHeroReportLayer.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-3-14 14:29:06 星期三
-- Description: 过关斩将 战报分页
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemReport = require("app.layer.passkillhero.ItemReport")
local KillHeroReportLayer = class("KillHeroReportLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)


function KillHeroReportLayer:ctor(_tSize)
	-- body
	self:setContentSize(_tSize)
	self:myInit()
	parseView("lay_fight_report", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function KillHeroReportLayer:onParseViewCallback( pView )
	-- body
	self:addView(pView)
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("KillHeroReportLayer",handler(self, self.onDestroy))
end

-- --初始化参数
function KillHeroReportLayer:myInit()
	-- body

end

--初始化控件
function KillHeroReportLayer:setupViews( )
	-- body	
	self.pLayList 		= 		self:findViewByName("lay_rep_list")

	--没有数据提示
	local tLabel = {
	    str = getConvertedStr(3, 10220),
	}
	local pNullUi = getLayNullUiImgAndTxt(tLabel)
	pNullUi:setIgnoreOtherHeight(true)
	self.pLayList:addView(pNullUi)
	centerInView(self.pLayList, pNullUi)
	self.pNullUi = pNullUi
	self.pNullUi:setVisible(false)
end

-- 修改控件内容或者是刷新控件数据
function KillHeroReportLayer:updateViews(  )
	-- body
	local pData = Player:getPassKillHeroData()	
	if not pData then
		return
	end
	self:updateListView()
end

--刷新列表
function KillHeroReportLayer:updateListView()
	-- body
	self.tDataList = Player:getPassKillHeroData().tRp
	
	local nItemCnt = #self.tDataList
	if not self.pListView then
		self.pListView = createNewListView(self.pLayList,nil,nil,nil,nil,nil,20)
		--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
		self.pListView:setItemCount(nItemCnt)
		self.pListView:setItemCallback(function ( _index, _pView ) 
		    local pView = _pView
			if not pView then
				if self.tDataList[_index] then
					pView = ItemReport.new(_index, self.tDataList[_index])
				end
			end
			if _index and self.tDataList[_index] then
				pView:setData(_index, self.tDataList[_index])	
			end
			return pView
		end)
		self.pListView:reload(false)
	else
		self.pListView:notifyDataSetChange(false, nItemCnt)
	end
	self.pListView:setVisible(nItemCnt ~= 0)
	self.pNullUi:setVisible(nItemCnt == 0)
end


-- 左边按钮点击响应 战斗记录
function KillHeroReportLayer:onBotBtnClicked( )
	-- body
end

--析构方法
function KillHeroReportLayer:onDestroy(  )
	self:onPause()
end

-- 注册消息
function KillHeroReportLayer:regMsgs( )
	-- body
end

-- 注销消息
function KillHeroReportLayer:unregMsgs(  )
	-- body
end
--暂停方法
function KillHeroReportLayer:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function KillHeroReportLayer:onResume( )
	-- body
	self:regMsgs()
end

return KillHeroReportLayer
