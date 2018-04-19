-- HelpItem.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-05-24 15:26:23 星期三
-- Description: 帮助单项层
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local HelpItem = class("HelpItem", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function HelpItem:ctor()
	-- body	
	self:myInit()	
	parseView("help_item", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function HelpItem:myInit()
	-- body		
	self.nIndex 			= 	nIndex or 1
	self.tCurData 			= 	nil 				--当前数据	
end

--解析布局回调事件
function HelpItem:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("HelpItem",handler(self, self.onHelpItemDestroy))
end

--初始化控件
function HelpItem:setupViews()
	-- body
	self.pLayRoot = self:findViewByName("default")
	self.pLayContent = self:findViewByName("lay_content")
	self.pImgArrow = self:findViewByName("img_arrow")
	self.pImgArrow:setFlippedX(true)
	self.pLayOpen = self:findViewByName("lay_open_content")
	self:setIsPressedNeedScale(false)
	-- self:setIsPressedNeedColor(false)
	self:createLabels()
end



--设置选中状态
function HelpItem:setSelectedState(_bState)
	if _bState then
		self.pImgArrow:setRotation(90)
	else
		self.pImgArrow:setRotation(0)
	end
	self.bOpenState = _bState
end

function HelpItem:getSelectedState()
	return self.bOpenState 
end


--展开内容
function HelpItem:onArrowClicked()

end

-- 修改控件内容或者是刷新控件数据
function HelpItem:updateViews()
	self.tLabel:setString(self.tCurData.desc)
end

-- 析构方法
function HelpItem:onHelpItemDestroy()
	-- body
end

function HelpItem:setItemData(_data)
	self.tCurData = _data
	self:updateViews()
end

function HelpItem:getItemData()
	return self.tCurData
end

function HelpItem:createLabels()
	-- body
	local pLabel = MUI.MLabel.new({
    text = "",
    size = 22,
    anchorpoint = cc.p(0, 0.5)})
    pLabel:setPosition(20, self.pLayContent:getHeight()/2)
    setTextCCColor(pLabel, _cc.white)
    self.pLayContent:addView(pLabel)    
    self.tLabel = pLabel
end

return HelpItem
