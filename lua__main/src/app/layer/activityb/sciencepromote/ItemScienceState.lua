----------------------------------------------------- 
-- author: xiesite
-- updatetime: 2018-03-06 10:33:31
-- Description: 状态item
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local IconGoods = require("app.common.iconview.IconGoods")
					
local ItemScienceState = class("ItemScienceState", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemScienceState:ctor( )
	-- body
	self:myInit()
	parseView("item_science_state", handler(self, self.onParseViewCallback))
end

--解析布局回调事件
function ItemScienceState:onParseViewCallback( pView )
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()
 

	--注册析构方法
	self:setDestroyHandler("ItemScienceState",handler(self, self.onDestroy))
end
--初始化成员变量
function ItemScienceState:myInit(  )
	self.nState = 0 --状态：0-未完成，1-完成未领取，2-完成已领取
	self.tHandler = nil
	self.nIndex = 0
	self.bTemRed = false
end

function ItemScienceState:setText(_text)
	local sText = _text or (self.nIndex - 1)
	if self.pLbNum then
		self.pLbNum:setString(sText)
	else
		self.pLbNum = MUI.MLabelAtlas.new({text=sText, 
			png="ui/atlas/v2_img_dax1d5.png", pngw=30, pngh=29, scm=48})
 		self.pLbNum:setPosition(cc.p(38,40))
 		self.pImgBg:addChild(self.pLbNum)
	end
end


function ItemScienceState:regMsgs(  )
end

function ItemScienceState:unregMsgs(  )
end

function ItemScienceState:onResume(  )
	self:regMsgs()
end

function ItemScienceState:onPause(  )
	self:unregMsgs()
end


function ItemScienceState:setupViews(  )

 	self.pImgBg  = self:findViewByName("img_bg")
	self.pImgBg:setViewTouched(true)
	self.pImgBg:setIsPressedNeedScale(false)
	self.pImgBg:onMViewClicked(handler(self, self.onClick))

	self.pImgFrame = self:findViewByName("img_frame")
 	self.pImgFrame:setVisible(false)

 	self.pImgRed = self:findViewByName("img_redpoint")
 	self.pImgRed:setVisible(false)
end

--析构方法
function ItemScienceState:onDestroy( )
	-- body
	self:onPause()
end

function ItemScienceState:updateViews(  )

	self:setText()
end

function ItemScienceState:setTemRed( )
	self.bTemRed = true
end

function ItemScienceState:showFrame()
	self.pImgFrame:setVisible(true)
end

function ItemScienceState:hideFrame()
	self.pImgFrame:setVisible(false)
end

function ItemScienceState:showRedPoint()
	self.pImgRed:setVisible(true)
	self.bTemRed = false
end

function ItemScienceState:hideRedPoint()
	self.pImgRed:setVisible(false)
end

function ItemScienceState:setClickCallBack(_handler)
	if _handler then
		self.tHandler = _handler
	end
end

function ItemScienceState:onClick()
	if self.tHandler then
		self.tHandler(self.nIndex)
	end
end

--_state 0-未完成，1-完成未领取，2-完成已领取
function ItemScienceState:setCurData( _index )
	self.nIndex = _index
	self:updateViews()
end


return ItemScienceState


