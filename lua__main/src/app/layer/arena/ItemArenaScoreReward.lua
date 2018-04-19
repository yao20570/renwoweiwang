-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-3-26 10:05:40 星期一
-- Description: 竞技场积分奖励项
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local ItemArenaScoreReward = class("ItemArenaScoreReward", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemArenaScoreReward:ctor()
	-- body	
	self:myInit()	

	parseView("item_arena_score_reward", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemArenaScoreReward:myInit()
	-- body		

end

--解析布局回调事件
function ItemArenaScoreReward:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemArenaScoreReward",handler(self, self.onDestroy))
end

--初始化控件
function ItemArenaScoreReward:setupViews( )
	-- body
	self.pLayRoot = self:findViewByName("lay_default")
	self.pImgLine = self:findViewByName("img_line")	

	self.pLayBar = self:findViewByName("lay_bar")
	self.pLbScore = self:findViewByName("lb_score")
	self.pLayReward = self:findViewByName("lay_rewards")
	self.pLayBtn = self:findViewByName("lay_btn")
	self.pImgFlag = self:findViewByName("img_flag")	

	self.pBtn = getCommonButtonOfContainer(self.pLayBtn,TypeCommonBtn.M_YELLOW,getConvertedStr(6,10189))	    
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnGetClicked))
	--display.TOP_TO_BOTTOM
	self.pBar = MUI.MSlider.new(display.LEFT_TO_RIGHT, 
		    {
		    	bar="ui/daitu.png",
		   	 	button="ui/daitu.png",
		    	barfg="ui/bar/v2_bar_blue_jjc.png"
		    }, 
		    {
		    	scale9 = true, 
		    	touchInButton=false
		    })
		    :setSliderSize(125, 22)
		    :align(display.LEFT_BOTTOM)
    self.pBar:setViewTouched(false)
    self.pBar:setRotation(90)
    self.pLayBar:addView(self.pBar)
    self.pBar:setPosition(0, 120)
    self.pBar:setSliderValue(0)

end

-- 修改控件内容或者是刷新控件数据
function ItemArenaScoreReward:updateViews( )
	-- body
	local pData = self.tCurData
	if not pData then
		return
	end
	self.pBar:setSliderValue(pData.nPer)
	self.pLbScore:setString(pData.i, false)
	if pData.nStatus == en_get_state_type.cannotget then--未达成
		self.pBtn:setBtnVisible(false)
		self.pImgFlag:setVisible(true)
		self.pImgFlag:setCurrentImage("#v2_fonts_weidadao.png")
	elseif pData.nStatus == en_get_state_type.haveget then--已经领取
		self.pBtn:setBtnVisible(false)
		self.pImgFlag:setVisible(true)
		self.pImgFlag:setCurrentImage("#v2_fonts_yilingqu.png")
	elseif pData.nStatus == en_get_state_type.canget then--可以领取		
		self.pBtn:setBtnVisible(true)
		self.pImgFlag:setVisible(false)
	end
	--奖励
	gRefreshHorizontalList(self.pLayReward, pData.tGoods)
end

--领取
function ItemArenaScoreReward:onBtnGetClicked( _pView )
	-- body	
	local pData = self.tCurData
	if not pData then
		return
	end	
	if pData.nStatus == en_get_state_type.canget then		
		SocketManager:sendMsg("reqArenaScoreAward", {pData.i}) --刷新竞技场幸运列表
	end			
end

-- 析构方法
function ItemArenaScoreReward:onDestroy( )
	-- body
end

function ItemArenaScoreReward:setCurData( _data )
	-- body	
	self.tCurData = _data
	self:updateViews()
end

return ItemArenaScoreReward