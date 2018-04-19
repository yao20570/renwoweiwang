-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-04-11 14:49:23 星期三
-- Description: 发展礼包
-----------------------------------------------------
local DlgBase = require("app.common.dialog.DlgBase")
local ItemDevelopGift = require("app.layer.activityb.developgift.ItemDevelopGift")
local DlgDevelopGift = class("DlgDevelopGift", function()
	return DlgBase.new(e_dlg_index.dlgdevelopgift)
end)

function DlgDevelopGift:ctor(  )
	-- body
	self:myInit()
	
	parseView("dlg_developgift", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgDevelopGift:myInit()
	self.tActData = nil
end

--解析布局回调事件
function DlgDevelopGift:onParseViewCallback( pView )
	-- body
	self.pView = pView
	self:addContentView(pView) --加入内容层
	self:setTitle()
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgDevelopGift",handler(self, self.onDestroy))
end

--初始化控件
function DlgDevelopGift:setupViews( )
	--ly
	self.pLayRoot = self:findViewByName("lay_default")
	self.pLayView = self:findViewByName("lay_view")
	self.pLayTop = self:findViewByName("lay_top")
	self.pLayBanner = self:findViewByName("lay_banner_bg")
	self.pImgFnt = self:findViewByName("img_font")
	self.pLayList = self:findViewByName("lay_list")

	setMBannerImage(self.pLayBanner, TypeBannerUsed.ac_fzlb)
end

-- 修改控件内容或者是刷新控件数据
function DlgDevelopGift:updateViews()
	local tActData = Player:getActById(e_id_activity.developgift)
	if not tActData then
		self:closeDlg(false)
		return
	end

    if tActData.sName then
		self:setTitle(tActData.sName)
    end

	if not self.pActTime then
		--活动时间
		self.pActTime = createActTime(self.pLayTop,tActData,cc.p(28,162))
	else
		self.pActTime:setCurData(tActData)
	end
	self.tDataList = tActData:getDevelopGifts()
	local nItemCnt = #self.tDataList
	--列表层
	if not self.pListView then
		self.pListView = MUI.MListView.new {
	    	bgColor = cc.c4b(255, 255, 255, 250),
	    	viewRect = cc.rect(20, 0, 600, self.pLayList:getHeight()),
	    	direction = MUI.MScrollView.DIRECTION_VERTICAL,
	    	itemMargin = {left =  0,
	    	right =  0,
	    	top =  0,
	    	bottom = 10}}
		self.pListView:setBounceable(true)  
		--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)					 
		self.pListView:setItemCallback(handler(self, self.onItemCallBack))
		self.pLayList:addView(self.pListView, 10)
		centerInView(self.pLayList, self.pListView)
		self.pListView:setItemCount(nItemCnt)
		self.pListView:reload(false)
	else
		self.pListView:notifyDataSetChange(false, nItemCnt)
	end
end

function DlgDevelopGift:onItemCallBack(_index, _pView)
	-- body
    local pTempView = _pView
    if pTempView == nil then
        pTempView = ItemDevelopGift.new()                        
        pTempView:setViewTouched(false)
    end
    pTempView:setCurData(self.tDataList[_index])
    return pTempView	
end

--继续方法
function DlgDevelopGift:onResume()
	-- body
	self:regMsgs()
	self:updateViews()	
end

-- 注册消息
function DlgDevelopGift:regMsgs( )
	-- body
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end



-- 注销消息
function DlgDevelopGift:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_activity)
end


--暂停方法
function DlgDevelopGift:onPause( )
	-- body
	self:unregMsgs()
	
end

-- 析构方法
function DlgDevelopGift:onDestroy(  )
	-- body
	self:onPause()
end
return DlgDevelopGift
