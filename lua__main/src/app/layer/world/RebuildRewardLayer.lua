----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-07-07 13:45:10
-- Description: 重建城池奖励
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local MDialog = require("app.common.dialog.MDialog")
local RebuildRewardLayer = class("RebuildRewardLayer", function()
	return MDialog.new()
end)

function RebuildRewardLayer:ctor(  )
	self:myInit()
	parseView("dlg_rebuild_reward", handler(self, self.onParseViewCallback))
end

function RebuildRewardLayer:myInit(  )
	self.tReward = Player:getWorldData():getRebuildReward()
	--清空防止二次加入
	Player:getWorldData():clearRebuildReward()
end

function RebuildRewardLayer:onCloseClicked()	
	showGetAllItems(self.tReward)
	closeDlgByType(e_dlg_index.rebuildreward, false)	
end

--解析布局回调事件
function RebuildRewardLayer:onParseViewCallback( pView )
	self.eDlgType = e_dlg_index.rebuildreward
	self:setContentView(pView)

	--基本设置
	self:setupViews()
	self:onResume()

	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:setIsPressedNeedColor(false)
	self:onMViewClicked(handler(self, self.onCloseClicked))
	
	--注册析构方法
	self:setDestroyHandler("RebuildRewardLayer",handler(self, self.onRebuildRewardLayerDestroy))
end

--析构方法
function RebuildRewardLayer:onRebuildRewardLayerDestroy( )
	self:onPause()
	showNextSequenceFunc(e_show_seq.rebuildreward)
end

--暂停方法
function RebuildRewardLayer:onPause( )
	self:unregMsgs()	
end

--继续方法
function RebuildRewardLayer:onResume( )
	self:regMsgs()
	self:updateViews()
end

--更新
function RebuildRewardLayer:regMsgs( )
	regMsg(self, ghd_world_rebuild_reward_show, handler(self, self.onRebuildRewardUpdate))
end

--注销方法
function RebuildRewardLayer:unregMsgs( )
	unregMsg(self, ghd_world_rebuild_reward_show)
end

function RebuildRewardLayer:setupViews(  )
	self.pLbTitle = self:findViewByName("lb_title")--对话框标题
	--标题
	self.pTxtTitle = self:findViewByName("txt_title")--奖励说明	

	self.pTxtReward = self:findViewByName("reward_title")
	setTextCCColor(self.pTxtReward, _cc.yellow)

	local pImgClose = self:findViewByName("img_close")
	pImgClose:onMViewClicked(handler(self, self.onCloseClicked))
	pImgClose:setIsPressedNeedScale(false)
	pImgClose:setIsPressedNeedColor(false)	
	pImgClose:setViewTouched(true)

	local pLayBtnSubmit = self:findViewByName("lay_btn_submit")
	local pBtnSubmit = getCommonButtonOfContainer(pLayBtnSubmit, TypeCommonBtn.M_BLUE, getConvertedStr(3, 10381))
	pBtnSubmit:onCommonBtnClicked(handler(self, self.onCloseClicked))

	local pLayGoods = self:findViewByName("lay_goods")
	self.pLayGoods = pLayGoods
	self.nLayGoodsWidth = pLayGoods:getContentSize().width
	self.nLayGoodsHeight = pLayGoods:getContentSize().height
	self:createNewListView()
end

--创建新的滚动控件
function RebuildRewardLayer:createNewListView( )
	if self.pListView then
		self.pListView:removeFromParent(true)
		self.pListView = nil
	end
	local pLayGoods = self.pLayGoods
	self.pListView = MUI.MListView.new {
	    viewRect   = cc.rect(0, 0, self.nLayGoodsWidth, self.nLayGoodsHeight),
	    direction  = MUI.MScrollView.DIRECTION_HORIZONTAL,
	    itemMargin = {left =  0,
	         right =  0,
	         top =  5,
	         bottom =  5},
	}
	pLayGoods:addView(self.pListView)
	self.pListView:setItemCount(0) 
	self.pListView:setItemCallback(handler(self, self.onListViewItemCallBack))
	centerInView(pLayGoods, self.pListView )
end


--控件刷新
function RebuildRewardLayer:updateViews(  )
	--因为要居中显示，所以当数量不同时就进行reload
	--当小于4个时且数据发生变化就重新创建
	local tReward =  resNormalSort(self.tReward)
	if tReward and #tReward > 0 then
		self.tReward = clone(tReward) --复制数据马上删除数据，以免服务器推送删除
		if self.pListView:getItemCount() ~= #self.tReward then
			self.pListView:setItemCount(#self.tReward)
			self.pListView:reload(true)
		else
			self.pListView:setItemCount(#self.tReward)
			self.pListView:notifyDataSetChange(true)
		end
		--是否高级重建
		local bIsSuperReBuild = Player:getWorldData():getIsSuperReBuild()
		if bIsSuperReBuild then
			self.pLbTitle:setString(getConvertedStr(3, 10379), false)
			self.pTxtTitle:setString(getTextColorByConfigure(getTipsByIndex(10043)), false)
			self.pTxtReward:setString(getConvertedStr(3, 10380), false)
		else
			self.pLbTitle:setString(getConvertedStr(3, 10383), false)
			self.pTxtTitle:setString(getTextColorByConfigure(getTipsByIndex(20026)), false)
			self.pTxtReward:setString(getConvertedStr(3, 10448), false)
		end
	end
end

--重建奖励更新
function RebuildRewardLayer:onRebuildRewardUpdate()
	self.tReward = Player:getWorldData():getRebuildReward()
	--清空防止二次加入
	Player:getWorldData():clearRebuildReward()
	--更新
	local tReward = resNormalSort(self.tReward)
	if tReward and #tReward > 0 then
		--如果之前的小于4，且现在的大于4
		--如果之前的大于4，且现在的大于4
		local nChangeNum = 4
		local nPrev = self.pListView:getItemCount()
		local nCurr = #tReward
		local bIsNeedCreate = false
		if nPrev < nChangeNum and nCurr >= nChangeNum then
			bIsNeedCreate = true
		end
		if nPrev >= nChangeNum and nCurr < nChangeNum then
			bIsNeedCreate = true
		end
		if bIsNeedCreate then
			self:createNewListView()
		end
		self:updateViews()
	end
end

--列表项回调
function RebuildRewardLayer:onListViewItemCallBack( _index, _pView)
	-- body	
    local pTempView = _pView
    if pTempView == nil then
        pTempView = MUI.MLayer.new()
        local nWidth = math.max(self.nLayGoodsWidth/#self.tReward, self.nLayGoodsWidth/4.5)
    	pTempView:setContentSize(nWidth, self.nLayGoodsHeight)
    end
    local nId = self.tReward[_index].k
    local nNum = self.tReward[_index].v
    local tGoods = getGoodsByTidFromDB(nId)
    if tGoods then
    	local pGoods = getIconGoodsByType(pTempView, TypeIconGoods.HADMORE, type_icongoods_show.item, tGoods, TypeIconGoodsSize.M)
    	centerInView(pTempView, pGoods)
    	pGoods:setPositionY(5)
    	pGoods:setNumber(nNum)
    end
    return pTempView
end


return RebuildRewardLayer