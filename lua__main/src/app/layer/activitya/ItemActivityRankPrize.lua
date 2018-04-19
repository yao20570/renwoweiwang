--
-- Author: maheng
-- Date: 2017-06-29 11:30:29
-- 活动排行奖励行

local MCommonView = require("app.common.MCommonView")
local IconGoods = require("app.common.iconview.IconGoods")

local ItemActivityRankPrize = class("ItemActivityRankPrize", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function ItemActivityRankPrize:ctor()
	-- body
	self:myInit()

	parseView("item_activity_rank_prize", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemActivityRankPrize",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemActivityRankPrize:myInit()
	self.pData = nil --数据

	self.nHandlerGetPrize = nil
end

--解析布局回调事件
function ItemActivityRankPrize:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemActivityRankPrize:setupViews( )
	--ly 
	self.pLayRoot = self:findViewByName("root")
	self.pLayTitle = self:findViewByName("lay_title")
	self.pLbTitle = self:findViewByName("lb_title")
	self.pLayScroll = self:findViewByName("lay_scroll")

	-- self.pListView = MUI.MListView.new {
 --        viewRect   = cc.rect(0, 0, 340, 150),
 --        direction  = MUI.MScrollView.DIRECTION_HORIZONTAL,
 --        itemMargin = {left =  6,
 --             right =  -15,
 --             top =  5,
 --             bottom =  5},
 --    }
 --    self.pLayScroll:addView(self.pListView)
 --    centerInView(self.pLayScroll, self.pListView )
 --    --self.pListView:setItemCount(0) 
	-- self.pListView:setItemCallback(handler(self, self.onListViewItemCallBack))
	-- --self.pListView:reload()

	self.pLayBtn = self:findViewByName("lay_btn")
	self.pBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.M_YELLOW, getConvertedStr(6, 10217))
	self.pBtn:onCommonBtnClicked(handler(self, self.onGetPrizeBtnClick))
	--已领取
	self.pLatRight = self:findViewByName("lay_right")
	self.pImgGet = self:findViewByName("img_get")

	--结算时间
	-- self.pLbTime = self:findViewByName("lb_time")

	self.pLbTime = MUI.MLabel.new({
	    text = "",
	    size = _nFontSize or 20,
	    anchorpoint = _anchorPoint or cc.p(0, 0.5),
	    align = cc.ui.TEXT_ALIGN_LEFT,
		valign = cc.ui.TEXT_VALIGN_CENTER,
	    color = getC3B(_sColor),
	    dimensions = cc.size(130, 0),
	})
	self.pLbTime:setPosition(380, 80)
	self.pLayRoot:addView(self.pLbTime, 10)

	self.pLbTime:setVisible(false)	
	self.pImgGet:setVisible(false)
	self.pBtn:setVisible(false)

end

-- 修改控件内容或者是刷新控件数据
function ItemActivityRankPrize:updateViews(  )
	-- body
	if self.pData then
		--dump(self.pData, "self.pData", 100)
		local sTitle = ""
		if self.pData.nL == self.pData.nR then
			sTitle = string.format(getConvertedStr(6, 10455), tostring(self.pData.nL))
		else
			sTitle = string.format(getConvertedStr(6, 10454), tostring(self.pData.nL), tostring(self.pData.nR))
		end
		self.pLbTitle:setString(sTitle, false)
		self:updatePrizeStauts(self.pData.nStatus)
		-- if self.pData.tAs then  
		-- 	local curCnt = #self.pData.tAs
		-- 	local nPre = self.pListView:setItemCount()
		-- 	if nPre == 0 then
		-- 		self.pListView:setItemCount(curCnt)	
		-- 		self.pListView:reload(true)			
		-- 	else
		-- 		self.pListView:notifyDataSetChange(true, curCnt)
		-- 	end			
		-- end		
		gRefreshHorizontalList(self.pLayScroll, self.pData.tAs)		
	end
end

--析构方法
function ItemActivityRankPrize:onDestroy(  )
	-- body
end

--设置数据 _data
function ItemActivityRankPrize:setCurData(_tData)
	if not _tData then
		return
	end
	--dump(_tData, "_tData",100)
	self.pData = _tData or self.pData
	self:updateViews()
end

--刷新奖品状态
function ItemActivityRankPrize:updatePrizeStauts(nstatus)
	-- body
	if not nstatus then
		self.pLbTime:setVisible(false)		
		self:hideRewardStateImg()
		self.pBtn:setVisible(false)
	end
	if nstatus == en_get_state_type.null then--未开始结算
		self.pLbTime:setVisible(true)		
		self:hideRewardStateImg()
		self.pBtn:setVisible(false)		
	elseif nstatus == en_get_state_type.cannotget then --不在奖励范围之内
		self.pLbTime:setVisible(false)		
		self:setRewardStateImg("#v2_fonts_weishangbang.png")
		self.pBtn:setVisible(false)
	elseif nstatus == en_get_state_type.canget then--未领奖
		self.pLbTime:setVisible(false)		
		self:hideRewardStateImg()
		self.pBtn:setVisible(true)
	elseif nstatus == en_get_state_type.haveget then--已经领奖
		self.pLbTime:setVisible(false)	
		self:setRewardStateImg("#v2_fonts_yilingqu.png")

		self.pBtn:setVisible(false)
	end

end

--设置奖励状态图片
function ItemActivityRankPrize:setRewardStateImg(_img)
	-- body
	self.pImgGet:setCurrentImage(_img)
	self.pImgGet:setVisible(true)
end
--设置奖励状态图片
function ItemActivityRankPrize:hideRewardStateImg()
	-- body
	self.pImgGet:setVisible(false)
end

function ItemActivityRankPrize:onGetPrizeBtnClick( pView )
	-- body	
	if self.nHandlerGetPrize then
		self.nHandlerGetPrize(self.pData)
	end
end

function ItemActivityRankPrize:onListViewItemCallBack(  _index, _pView  )
	-- body
    local pTempView = _pView
    if pTempView == nil then
		pTempView = IconGoods.new(TypeIconGoods.NORAML)--HADMORE
		--pTempView:setIconScale(0.8)
		pTempView:setIconIsCanTouched(true)
    end
    local tTempData = self.pData.tAs[_index]
    pTempView:setCurData(tTempData) 
	pTempView:setMoreTextColor(getColorByQuality(tTempData.nQuality))
	pTempView:setNumber(tTempData.nCt)
    return pTempView	
end

function ItemActivityRankPrize:setGetPrizeHandler( _handler )
	-- body
	self.nHandlerGetPrize = _handler
end

--设置结算时间
function ItemActivityRankPrize:setBalanceTime( sStr )
	-- body
	if sStr then		
		self.pLbTime:setString(sStr, false)
	end
end
return ItemActivityRankPrize