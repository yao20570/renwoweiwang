-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-03-14 11:57:23 星期三
-- Description: 纣王试炼主页奖励项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemZhouWangTrialPrize = class("ItemZhouWangTrialPrize", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_nType 1对应国家奖励 2对应积分奖励
function ItemZhouWangTrialPrize:ctor(_nType)
	-- body	
	self:myInit()
	self.nType = _nType or self.nType
	parseView("item_zhouwang_trial_prize", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function ItemZhouWangTrialPrize:onParseViewCallback( pView )
	-- body
	self:setContentSize(pView:getContentSize())
	self:addView(pView)

	self:setupViews()	
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("ItemZhouWangTrialPrize",handler(self, self.onDestroy))
end

-- --初始化参数
function ItemZhouWangTrialPrize:myInit()
	-- body
	self.nType = 2
	self.pData = nil
end

--初始化控件
function ItemZhouWangTrialPrize:setupViews( )
	-- body		
	self.pLayRoot       = 		self:findViewByName("lay_main")
	self.pLbTitle 		= 		self:findViewByName("lb_title")
	self.pLayPrizes 	= 		self:findViewByName("lay_prize_list")	
	self.pImgFlag 		= 		self:findViewByName("img_flag")
	self.pLayBtn  		= 		self:findViewByName("lay_btn")	
	self.pBtn  			=		getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.M_YELLOW, getConvertedStr(6, 10472))
	self.pBtn:onCommonBtnClicked(handler(self, self.onGetBtnCallBack))	
	self.pImgFlag:setVisible(false)
end

-- 修改控件内容或者是刷新控件数据
function ItemZhouWangTrialPrize:updateViews(  )
	-- body
	if not self.pData then
		return
	end
	if self.nType == 1 then
		self:updateCountryPrize()
	elseif self.nType == 2 then
		self:updateScorePrize()
	end
end

function ItemZhouWangTrialPrize:updateCountryPrize(  )
	-- body
	local pData = self.pData
	-- local nRank = pData:getCountryRank()
	self.pLbTitle:setString(getTextColorByConfigure(string.format(getConvertedStr(6, 10792), 1)), false)	
	gRefreshHorizontalList(self.pLayPrizes, pData.tCa, nil, nil, true)
	self:updatePrizeStauts(pData:getCountryPrizeStatus())	
end

function ItemZhouWangTrialPrize:updateScorePrize( )
	-- body
	local pData = self.pData
	self.pLbTitle:setString(getTextColorByConfigure(string.format(getConvertedStr(6, 10790), pData:getRankStr())), false)
	gRefreshHorizontalList(self.pLayPrizes, pData.tAs, nil, nil, true)	

	self:updatePrizeStauts(pData.nStatus)
end

--刷新奖品状态
function ItemZhouWangTrialPrize:updatePrizeStauts(nstatus)
	-- body
	if not nstatus then
		-- self.pLbTime:setVisible(false)		
		self:hideRewardStateImg()
		self.pBtn:setBtnVisible(false)
	end
	if nstatus == en_get_state_type.null then--未开始结算
		-- self.pLbTime:setVisible(true)		
		self:setRewardStateImg("#v2_fonts_weishangbang.png")
		self.pBtn:setBtnVisible(false)		
	elseif nstatus == en_get_state_type.cannotget then --不在奖励范围之内
		-- self.pLbTime:setVisible(false)		
		self:setRewardStateImg("#v2_fonts_weishangbang.png")
		self.pBtn:setBtnVisible(false)
	elseif nstatus == en_get_state_type.canget then--未领奖
		-- self.pLbTime:setVisible(false)		
		self:hideRewardStateImg()
		self.pBtn:setBtnVisible(true)
	elseif nstatus == en_get_state_type.haveget then--已经领奖
		-- self.pLbTime:setVisible(false)	
		self:setRewardStateImg("#v2_fonts_yilingqu.png")

		self.pBtn:setBtnVisible(false)
	end

end


--设置奖励状态图片
function ItemZhouWangTrialPrize:setRewardStateImg(_img)
	-- body
	self.pImgFlag:setCurrentImage(_img)
	self.pImgFlag:setVisible(true)
end
--设置奖励状态图片
function ItemZhouWangTrialPrize:hideRewardStateImg()
	-- body
	self.pImgFlag:setVisible(false)
end

function ItemZhouWangTrialPrize:setCurData( _tData )
	-- body
	self.pData = _tData or self.pData
	self:updateViews()
end

function ItemZhouWangTrialPrize:onGetBtnCallBack( pView )
	-- body
	local pData = self.pData	
	if not pData then
		return
	end
	if self.nType == 1 then--国家奖励
		if pData:getCountryPrizeStatus() == en_get_state_type.canget then
			SocketManager:sendMsg("reqZhouwangCountryPrize", {}, handler(self, self.onGetCallBack))
		end		
	elseif self.nType == 2 then--排行奖励
		if pData.nStatus == en_get_state_type.canget then
			SocketManager:sendMsg("reqZhouwangRankPrize", {pData.nId}, handler(self, self.onGetCallBack))
		end
	end	
	
end

function ItemZhouWangTrialPrize:onGetCallBack( __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if __msg.body and __msg.body.o then
			showGetAllItems(__msg.body.o)
		end		
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end	
end


--析构方法
function ItemZhouWangTrialPrize:onDestroy(  )
	self:onPause()
end

-- 注册消息
function ItemZhouWangTrialPrize:regMsgs( )
	-- body	   
end

-- 注销消息
function ItemZhouWangTrialPrize:unregMsgs(  )
	-- body

end
--暂停方法
function ItemZhouWangTrialPrize:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function ItemZhouWangTrialPrize:onResume( )
	-- body
	self:regMsgs()
	self:updateViews()
end

return ItemZhouWangTrialPrize
