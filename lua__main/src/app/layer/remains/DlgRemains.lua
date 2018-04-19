-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-3-2 11:55:23 星期五
-- Description: 韬光养晦
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local ItemRemainsTask = require("app.layer.remains.ItemRemainsTask")
local DlgRemains = class("DlgRemains", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgremains)
end)

function DlgRemains:ctor(  )
	-- body
	self:myInit()
	parseView("dlg_remains", handler(self, self.onParseViewCallback))
	
end

function DlgRemains:myInit(  )
	-- body	
	self.pItemTime = nil --时间Item
end

--解析布局回调事件
function DlgRemains:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层	
	--设置标题
	self:setTitle(getConvertedStr(6,10767))
	self:setupView()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgRemains",handler(self, self.onDestroy))
end

function DlgRemains:setupView( )
	-- body
	self.pLayTop = self:findViewByName("lay_top")
	self.pLayList = self:findViewByName("lay_list")	
	self.pLayBannerBg = self:findViewByName("lay_banner_bg")
	self.pLayFreeBtn = self:findViewByName("lay_get_btn")
	self.pLayFreeRewards = self:findViewByName("lay_free_rewards")
	self.pLayDesc = self:findViewByName("lay_desc")	
	self.pLbDesc = self:findViewByName("lb_desc")
	--免费奖励领取
	self.pFreeBtn = getCommonButtonOfContainer(self.pLayFreeBtn, TypeCommonBtn.M_YELLOW, getConvertedStr(6, 10189))
	self.pFreeBtn:onCommonBtnClicked(handler(self, self.onGetFreeRewards))
	setMCommonBtnScale(self.pLayFreeBtn, self.pFreeBtn, 0.8)


	local pSize = self.pLayList:getContentSize()
	self.pListView = MUI.MListView.new {
		viewRect   = cc.rect(20, 0, pSize.width - 40, pSize.height),
		direction  = MUI.MScrollView.DIRECTION_VERTICAL,
		itemMargin = {left =  0,
             right =  0,
             top =  10,
             bottom =  5},
    }
    self.pLayList:addView(self.pListView)
	self.pListView:setItemCallback(function ( _index, _pView ) 
	    local pTempView = _pView
	    if pTempView == nil then
	    	pTempView   = ItemRemainsTask.new()
		end
		pTempView:setData(self.tMissions[_index])
	    return pTempView
	end)
	self.pListView:setItemCount(0)
	--上下箭头
	local pUpArrow, pDownArrow = getUpAndDownArrow()
	self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
	self.pListView:reload()
	self.tMissions = {}

	local nCountry = Player.baseInfos.nInfluence
	if nCountry == e_type_country.shuguo then--汉
		self:setBannerImg(TypeBannerUsed.ac_remaim_han)        	
    elseif nCountry == e_type_country.weiguo then--秦
        self:setBannerImg(TypeBannerUsed.ac_remaim_qin) 
    elseif nCountry == e_type_country.wuguo then--楚
    	self:setBannerImg(TypeBannerUsed.ac_remaim_chu) 
    end
end

--控件刷新
function DlgRemains:updateViews(  )
	local pData = Player:getRemainsData()
	if not pData then
		return
	end
	if not self.pItemTime then
		self.pItemTime = createActTime(self.pLayTop, pData, cc.p(0,240))
	else
		self.pItemTime:setCurData(pData)	
	end
	self.pLbDesc:setString(getTextColorByConfigure(getTipsByIndex(20138)), false)
	
	if pData.nFg == 0 then--可领取
		self.pFreeBtn:updateBtnText(getConvertedStr(6, 10189))
		self.pFreeBtn:setBtnEnable(true)
	else--已领取
		self.pFreeBtn:updateBtnText(getConvertedStr(6, 10357))
		self.pFreeBtn:setBtnEnable(false)
	end
	local tReWards = pData:getFreeRewards()
	-- dump(tReWards, "tReWards", 100)
	local pFreeList = gRefreshHorizontalList(self.pLayFreeRewards, tReWards)
	pFreeList:setIsCanScroll(false)
	-- 
	self.tMissions = pData:getTaskDatasByStage()
	table.sort(self.tMissions, function ( a,  b )
		-- body
		return a.nId < b.nId
	end)
	local nItemCnt = #self.tMissions
    self.pListView:setItemCount(nItemCnt) 
    self.pListView:notifyDataSetChange(false)

end

--设置banner图片 
function DlgRemains:setBannerImg(nType)
	if self.pLayBannerBg and nType then
		setMBannerImage(self.pLayBannerBg,nType)
	end
end
--领取免费按钮
function DlgRemains:onGetFreeRewards(  )
	-- body
	local pData = Player:getRemainsData()
	if not pData then
		return
	end	
	if pData.nFg == 0 then
		SocketManager:sendMsg("reqTGYHFreeReward", {}, function(__msg, __oldMsg)
			if __msg.body then
				--奖励动画展示
				showGetAllItems(__msg.body.ob, 1)
			end
		end)
	end	
end

--析构方法
function DlgRemains:onDestroy()
	-- body
	self:onPause()
end

--注册消息
function DlgRemains:regMsgs(  )
	-- body
	--注册竞技场视图数据刷新消息
	regMsg(self, ghd_remains_refresh_msg, handler(self, self.updateViews))		

end
--注销消息
function DlgRemains:unregMsgs( )
	-- body
	--注销竞技场视图数据刷新消息
	unregMsg(self, ghd_remains_refresh_msg)
end

--暂停方法
function DlgRemains:onPause( )
	-- body		
	self:unregMsgs()	

end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgRemains:onResume( _bReshow )
	-- body		
	self:regMsgs()	
	self:updateViews()
end

return DlgRemains