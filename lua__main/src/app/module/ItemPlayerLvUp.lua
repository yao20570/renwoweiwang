
-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-10 14:31:23 星期三
-- Description: 选择项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemPlayerLvUp = class("ItemPlayerLvUp", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

 
--_type 选中方式
function ItemPlayerLvUp:ctor()
	-- body
	self:myInit(_type)

	parseView("item_player_lvup", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemPlayerLvUp",handler(self, self.onItemPlayerLvUpDestroy))
	--
end

--初始化参数
function ItemPlayerLvUp:myInit(_type)
	-- body
	self.nSelectedType = _type or ItemPlayerLvUp.Bg
	self._isSelected = false
	self._defimgbg = "#v1_img_selected.png"
	self.tCurData = nil
end

--解析布局回调事件
function ItemPlayerLvUp:onParseViewCallback( pView )	
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)
	centerInView(self, pView)
	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemPlayerLvUp:setupViews( )
	-- body
	--root
	self.pLayRoot = self:findViewByName("root")
	self.pLayTop = self:findViewByName("lay_top")
	self.pLbTitle = self:findViewByName("lb_title")
	self.pImgFlag = self:findViewByName("img_flag")
end

-- 修改控件内容或者是刷新控件数据
function ItemPlayerLvUp:updateViews(  )
	-- body
	
end

function ItemPlayerLvUp:setItemTitle( sStr )
	-- body
	if sStr then
		self.pLbTitle:setString(sStr, false)
	end
end

function ItemPlayerLvUp:setImg( sImgPath )
	-- body
	if sImgPath then
		self.pImgFlag:setCurrentImage(sImgPath)
	end
end

--析构方法
function ItemPlayerLvUp:onItemPlayerLvUpDestroy(  )
	-- body
end

return ItemPlayerLvUp