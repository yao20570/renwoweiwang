-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-08 19:28:23 星期一
-- Description: 工坊预约生产界面
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local ItemProductLine = require("app.layer.atelier.ItemProductLine")

local DlgAtelierBespeak = class("DlgAtelierBespeak", function()
	-- body
	return DlgBase.new(e_dlg_index.atelierbespeak)
end)

function DlgAtelierBespeak:ctor(  )
	-- body
	self:myInit()
	parseView("dlg_atelier_bespeak", handler(self, self.onParseViewCallback))
end

function DlgAtelierBespeak:myInit(  )
	-- body

end

--解析布局回调事件
function DlgAtelierBespeak:onParseViewCallback( pView )
	-- body
	--设置标题
	self:setTitle(getConvertedStr(6,10178))	
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace()
	--self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgAtelierBespeak",handler(self, self.onDlgDlgAtelierBespeakDestroy))
end

--初始化控件
function DlgAtelierBespeak:setupViews(  )
	-- body	
end

--控件刷新
function DlgAtelierBespeak:updateViews(  )
	-- body
	gRefreshViewsAsync(self, 3, function ( _bEnd, _index )
		if (_index == 1) then
			self.pLayInfo = self:findViewByName("lay_info")
			--提示1
			self.pLbTip1 = MUI.MLabel.new({
				    text = getTipsByIndex(10007),
				    size = 20,
				    anchorpoint = cc.p(0.5, 0.5),
				    align = cc.ui.TEXT_ALIGN_CENTER,
		    		valign = cc.ui.TEXT_ALIGN_CENTER,
				    color = cc.c3b(255, 255, 255),
				    dimensions = cc.size(500, 54),
				    })	
			self.pLayInfo:addView(self.pLbTip1, 10)
			centerInView(self.pLayInfo, self.pLbTip1)
			local pBannerImage 			= 		self:findViewByName("lay_top")
			setMBannerImage(pBannerImage,TypeBannerUsed.gf)
		elseif (_index == 2) then
			--预生产队列数据
			local nItemCnt = 0
			local atelierData = Player:getBuildData():getBuildById(e_build_ids.atelier)
			if atelierData then
				local nbuyProductLine = getNextProductLineCost(atelierData.nBuyQueue)
				nItemCnt = atelierData.nQueue
				if nbuyProductLine then--可以继续购买队列的情况下
					nItemCnt = nItemCnt + 1
				end
			end		

			--列表层
			if not self.pListView then
				self.pLayList = self:findViewByName("lay_list")
				self.pListView = MUI.MListView.new {
			    	bgColor = cc.c4b(255, 255, 255, 250),
			    	viewRect = cc.rect(20, 0, 600, self.pLayList:getHeight()),
			    	direction = MUI.MScrollView.DIRECTION_VERTICAL,
			    	itemMargin = {left =  0,
			    	right =  0,
			    	top =  10,
			    	bottom =  0}}
				self.pListView:setBounceable(true)  
				--上下箭头
				local pUpArrow, pDownArrow = getUpAndDownArrow()
				self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)					 
				self.pListView:setItemCallback(handler(self, self.onListViewItemCallBack))
				self.pLayList:addView(self.pListView, 10)
				centerInView(self.pLayList, self.pListView)
				self.pListView:setItemCount(nItemCnt)
				self.pListView:reload(false)
			else
				self.pListView:notifyDataSetChange(false, nItemCnt)
			end	
		end	
	end)		
end

--析构方法
function DlgAtelierBespeak:onDlgDlgAtelierBespeakDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgAtelierBespeak:regMsgs(  )
	-- body
	--注册工坊数据刷信息消息
	regMsg(self, ghd_refresh_atelier_msg, handler(self, self.updateViews))	
	--注册王宫数据刷新消息
	regMsg(self, ghd_refresh_palace_msg, handler(self, self.updateViews))
end
--注销消息
function DlgAtelierBespeak:unregMsgs(  )
	-- body
	--注销工坊数据刷信息消息
	unregMsg(self, ghd_refresh_atelier_msg)
	--注销王宫数据刷新消息
	unregMsg(self, ghd_refresh_palace_msg)	
end

--暂停方法
function DlgAtelierBespeak:onPause( )
	-- body
	self:unregMsgs()	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgAtelierBespeak:onResume( _bReshow )
	-- body	
	if _bReshow and self.pListView then
		-- 如果是重新显示，定位到顶部
		self.pListView:scrollToBegin()		
	end
	self:updateViews()
	self:regMsgs()
end

function DlgAtelierBespeak:onListViewItemCallBack(_index, _pView)
	-- body	
    local pTempView = _pView
    if pTempView == nil then
        pTempView = ItemProductLine.new(_index, false)                        
        pTempView:setViewTouched(false)
    end
    pTempView:setIndex(_index)
    return pTempView
end
return DlgAtelierBespeak