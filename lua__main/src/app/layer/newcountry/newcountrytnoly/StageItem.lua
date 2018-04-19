-- StageItem.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-03-30 11:40:23 星期五
-- Description: 国家科技阶段单项层
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local StageItem = class("StageItem", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function StageItem:ctor(_index)
	-- body	
	self:myInit(_index)	
	parseView("item_stage", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function StageItem:myInit(_index)
	-- body		
	self.tCurStage 			= 	_index 				--当前阶段	
	self.tCurData 			= 	nil 				--当前数据
end

--解析布局回调事件
function StageItem:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("StageItem",handler(self, self.onStageItemDestroy))
end

--初始化控件
function StageItem:setupViews()
	-- body
	self.pLayRoot = self:findViewByName("default")
	--内容层
	self.pLayContent = self:findViewByName("lay_con")
	--未解锁层
	self.pLayLocked = self:findViewByName("lay_lock")
	--解锁提示文本
	self.pLbLockTip = self:findViewByName("lb_lock_tip")
	self.pLbLockTip:setString(string.format(getConvertedStr(7, 10417), getConvertedStr(7, 10405+self.tCurStage)))
	--箭头
	self.pImgArrow = self:findViewByName("img_arrow")
	self.pImgArrow:setFlippedX(true)
	self:setIsPressedNeedScale(false)
	-- self:setIsPressedNeedColor(false)
	-- self:createLabels()

	local pLbStage = self:findViewByName("lb_stage")
	--阶段数艺术字
	self.pLbStage = MUI.MLabelAtlas.new({text="1", 
	    png="ui/atlas/v2_img_jieduan_shuzi.png", pngw=22, pngh=41, scm=49})
	self.pLbStage:setPosition(pLbStage:getPosition())
	self.pLayContent:addView(self.pLbStage, 5)
	self.pLbStage:setString(self.tCurStage)
end



--设置选中状态
function StageItem:setSelectedState(_bState)
	if _bState then
		self.pImgArrow:setRotation(90)
	else
		self.pImgArrow:setRotation(0)
	end
	self.bOpenState = _bState
end

function StageItem:getSelectedState()
	return self.bOpenState 
end

-- 修改控件内容或者是刷新控件数据
function StageItem:updateViews()
	--是否开启
	local pCountryTnolyData = Player:getCountryTnoly()
	local bOpen = self.tCurStage <= pCountryTnolyData.nStage
	if bOpen then
		self:setToGray(false)
		self:setViewTouchEnable(true)
		self.pLayLocked:setVisible(false)
	else
		self:setToGray(true)
		self:setViewTouchEnable(false)
		self.pLayLocked:setVisible(true)
	end

end

-- 析构方法
function StageItem:onStageItemDestroy()
	-- body
end

function StageItem:setItemData(_data)
	self.tCurData = _data
	self:updateViews()
end

function StageItem:getItemData()
	return self.tCurData
end

-- function StageItem:createLabels()
-- 	-- body
-- 	local pLabel = MUI.MLabel.new({
--     text = "",
--     size = 22,
--     anchorpoint = cc.p(0, 0.5)})
--     pLabel:setPosition(20, self.pLayContent:getHeight()/2)
--     setTextCCColor(pLabel, _cc.white)
--     self.pLayContent:addView(pLabel)    
--     self.tLabel = pLabel
-- end

return StageItem
