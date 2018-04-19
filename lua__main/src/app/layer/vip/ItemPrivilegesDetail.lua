-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-02-28 15:12:23 星期三
-- Description: vip特权项说明
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemPrivilegesDetail = class("ItemPrivilegesDetail", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)


function ItemPrivilegesDetail:ctor(_tSize)
	-- body	
	self:myInit()

	parseView("item_privileges_detail", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemPrivilegesDetail",handler(self, self.onDestroy))	
end

--初始化参数
function ItemPrivilegesDetail:myInit()
	-- body
	self.pCurData = nil
end

--解析布局回调事件
function ItemPrivilegesDetail:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemPrivilegesDetail:setupViews( )
	--body	
	self.pLayRoot = self:findViewByName("lay_root")
	self.pImgFlag = self:findViewByName("img_flag")
	self.pLbDesc = self:findViewByName("lb_desc")		
end

-- 修改控件内容或者是刷新控件数据
function ItemPrivilegesDetail:updateViews(  )
	-- body	
	if not self.pCurData then
		return
	end		
	--dump(self.pCurData, "self.pCurData", 10)
	local tData = luaSplit(self.pCurData, "#")
	if not tData then
		return
	end
	local nCnt = #tData
	local tStr = "" 
	local sImgPath = "ui/daitu.png"
	if nCnt == 1 then
		tStr = getTextColorByConfigure(tData[1])
	elseif nCnt == 2 then
		sImgPath = "#"..tData[1]..".png"
		tStr = getTextColorByConfigure(tData[2])				
	end
	self.pImgFlag:setCurrentImage(sImgPath)
	self.pLbDesc:setString(tStr, false)
	self.pLbDesc:setPositionX(self.pImgFlag:getPositionX() + self.pImgFlag:getWidth()/2 + 5)
end

--析构方法
function ItemPrivilegesDetail:onDestroy(  )
	-- body
end


--设置数据
function ItemPrivilegesDetail:setCurData( _data )
	-- body
	if _data then
		self.pCurData = _data		
	else
		self.pCurData = nil
	end
	self:updateViews()
end

return ItemPrivilegesDetail