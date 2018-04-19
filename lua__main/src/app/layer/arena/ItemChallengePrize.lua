-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-1-18 11:05:40 星期四
-- Description: 竞技场 挑战奖励
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ItemChallengePrize = class("ItemChallengePrize", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemChallengePrize:ctor(  )
	-- body
	self:myInit()
	parseView("item_challenge_prize", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemChallengePrize:myInit(  )
	-- body
	self.tCurData 			= 	nil 				--当前数据	
	self.bIsIconCanTouched 	= 	false		
end

--解析布局回调事件
function ItemChallengePrize:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemChallengePrize",handler(self, self.onDestroy))
end

--初始化控件
function ItemChallengePrize:setupViews( )
	-- body
	self.pLbTitle = self:findViewByName("lb_title")

	self.pImgGet = self:findViewByName("img_get")
	self.pLayScrall = self:findViewByName("lay_scroll")
	self.pLbNum = self:findViewByName("lb_num")
	self.pLayBtn = self:findViewByName("lay_btn")
	self.pBtn = getCommonButtonOfContainer(self.pLayBtn,TypeCommonBtn.M_YELLOW,getConvertedStr(6,10189))	
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))	
end

-- 修改控件内容或者是刷新控件数据
function ItemChallengePrize:updateViews( )
	-- body
	if not self.tCurData then
		return
	end
	self.pLbTitle:setString(string.format(getConvertedStr(6, 10705), self.tCurData.i), false)
	self.pLbNum:setString(Player:getArenaData().nScore.."/"..self.tCurData.i)
	gRefreshHorizontalList(self.pLayScrall, self.tCurData.tGoods)	
	local nStatus = self.tCurData.nStatus
	if nStatus == en_get_state_type.cannotget then    --未达成
		self.pLayBtn:setVisible(false)
		self.pLbNum:setVisible(true)
		self.pImgGet:setVisible(true)
		self.pImgGet:setCurrentImage("#v2_fonts_weidadao.png")
	elseif nStatus == en_get_state_type.haveget then  --已经领取
		self.pLayBtn:setVisible(false)
		self.pLbNum:setVisible(false)
		self.pImgGet:setVisible(true)
		self.pImgGet:setCurrentImage("#v2_fonts_yilingqu.png")
	elseif nStatus == en_get_state_type.canget then   --可以领取
		self.pLayBtn:setVisible(true)
		self.pLbNum:setVisible(true)
		self.pImgGet:setVisible(false)
	end
end

-- 析构方法
function ItemChallengePrize:onDestroy(  )
	-- body
end

function ItemChallengePrize:setCurData( _tData )
	-- body
	self.tCurData = _tData
	self:updateViews()
end

--按钮点击回调 领取按钮
function ItemChallengePrize:onBtnClicked( pView )
	-- body
	if self.tCurData then
		SocketManager:sendMsg("reqArenaScoreAward", {self.tCurData.i}) --刷新竞技场幸运列表
	end	
end


return ItemChallengePrize