-----------------------------------------------------
-- author: luwenjing
-- updatetime:  2018-03-13 14:56:17 星期二
-- Description: 冥界敌军详情子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local MImgLabel = require("app.common.button.MImgLabel")
local ItemGhostDetail = class("ItemGhostDetail", function ()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--构造
function ItemGhostDetail:ctor()
	-- body
	self:myInit()
	parseView("item_ghost_detail", handler(self, self.onParseViewCallback))
end
  
--解析布局回调事件
function ItemGhostDetail:onParseViewCallback( pView )
	-- body
	
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:setupViews()
	self:updateViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("ItemGhostDetail",handler(self, self.onDestroy))
end
function ItemGhostDetail:myInit(  )
	-- body
	self.tData = nil
end

--初始化控件
function ItemGhostDetail:setupViews()
	-- body
	self.pLbIndex = self:findViewByName("lb_index")
	self.pLbName = self:findViewByName("lb_name")
	self.pLbNum = self:findViewByName("lb_num")
	self.pImgType = self:findViewByName("img_type")
end

-- 修改控件内容或者是刷新控件数据
function ItemGhostDetail:updateViews()
	-- body
	if not self.tData then
		return
	end
	self.pLbIndex:setString(self.nIndex)
	self.pLbName:setString(self.tData.sName .. "Lv." .. self.tData.nLevel )
	setTextCCColor(self.pLbName,getColorByQuality(self.tData.nQuality))
	self.pLbNum:setString(self.tData.nTroops)
	self.pImgType:setCurrentImage(getSoldierTypeImg(self.tData.nKind,2))
	-- self:setRank(self.tData.x,self.pTxtRank)
	-- setTextCCColor(self.pTxtCountry, getColorByCountry(self.tData.c))
	-- self.pTxtCountry:setString(getCountryName(self.tData.c))
	-- self.pTxtName:setString(self.tData.n)
	-- self.pTxtPoint:setString(self.tData.f or 0)
end

function ItemGhostDetail:setData( _tData ,_nIndex)
	-- body
	self.nIndex = _nIndex
	self.tData = _tData or self.tData
	self:updateViews()
end

--析构方法
function ItemGhostDetail:onDestroy()
	self:onPause()
end


--暂停方法
function ItemGhostDetail:onPause( )
	-- body

end

--继续方法
function ItemGhostDetail:onResume( )
	-- body

end



return ItemGhostDetail
