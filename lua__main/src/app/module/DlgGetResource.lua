
-- Author: maheng
-- Date: 2017-04-21 11:56:24
-- 获取资源对话框


local DlgCommon = require("app.common.dialog.DlgCommon")
local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")
local ItemInfo = require("app.module.ItemInfo")
local ItemHomeRes = require("app.layer.home.ItemHomeRes")
local ItemVipShopGoods = require("app.layer.shop.ItemVipShopGoods")
local DlgGetResource = class("DlgGetResource", function ()
	return DlgCommon.new(e_dlg_index.getresource)
end)

--构造
--_nDefaultIndex：默认选择哪一项
function DlgGetResource:ctor( _nDefaultIndex, _tNeedValue)
	-- body
	self:myInit()
	self.nDefaultIndex = _nDefaultIndex or self.nDefaultIndex
	self.tNeedValue = _tNeedValue or nil
	parseView("dlg_getresource", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgGetResource:myInit()
	-- body
	self.tTitles = {getConvertedStr(1,10091),getConvertedStr(1,10092),getConvertedStr(1,10093),getConvertedStr(1,10094)}
	self.tCurLists = {} --资源数据
	self.nCurIndex = 0  --当前选项	
	self.nDefaultIndex = 1 --默认选择哪一项
end
  
--解析布局回调事件
function DlgGetResource:onParseViewCallback( pView )
	-- body
	self:addContentView(pView,false)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgGetResource",handler(self, self.onDlgGetResourceDestroy))
end

--初始化控件
function DlgGetResource:setupViews()
	-- body	
	--设置标题
	self:setTitle(getConvertedStr(6,10108))
	self.pLayRoot = self:findViewByName("root")
	--内容层
	self.pLayContent 			= 		self:findViewByName("lay_content")
	self.pTComTabHost = TCommonTabHost.new(self.pLayContent,1,1,self.tTitles,handler(self, self.onIndexSelected))
	self.pTComTabHost:removeLayTmp1()
	self.pLayContent:addView(self.pTComTabHost,10)

	--默认选中第一项
	self.pTComTabHost:setDefaultIndex(self.nDefaultIndex)	

	local nwidth = self.pTComTabHost.nTopTabWidth
	local x = self.pTComTabHost:getPositionX()
	local y = self.pLayContent:getHeight() + 8
	--粮食		
	self.pItemFood 				= 		ItemHomeRes.new(1)
	self.pLayContent:addView(self.pItemFood, 10)
	self.pItemFood:setPosition(x + (nwidth - self.pItemFood:getWidth())/2, y)
	--木头
	self.pItemWood 				= 		ItemHomeRes.new(2)
	self.pLayContent:addView(self.pItemWood, 10)
	self.pItemWood:setPosition(x + nwidth*1 + (nwidth - self.pItemWood:getWidth())/2, y)
	--铁
	self.pItemIron 				= 		ItemHomeRes.new(3)
	self.pLayContent:addView(self.pItemIron, 10)
	self.pItemIron:setPosition(x + nwidth*2 + (nwidth - self.pItemWood:getWidth())/2, y)
	--铜币
	self.pItemCoin 				= 		ItemHomeRes.new(4)
	self.pLayContent:addView(self.pItemCoin, 10)
	self.pItemCoin:setPosition(x + nwidth*3 + (nwidth - self.pItemWood:getWidth())/2, y)

end

-- 修改控件内容或者是刷新控件数据
function DlgGetResource:updateViews()
	-- body
	self:onRefreshData()
end

--析构方法
function DlgGetResource:onDlgGetResourceDestroy()
	self:onPause()
end

-- 注册消息
function DlgGetResource:regMsgs( )
	-- body
	-- 注册背包物品变化消息
	regMsg(self, gud_refresh_baginfo, handler(self, self.onRefreshData))
	-- 注册玩家数据变化的消息
	regMsg(self, gud_refresh_playerinfo, handler(self, self.onRefreshData))
end

-- 注销消息
function DlgGetResource:unregMsgs(  )
	-- body
	-- 销毁背包物品变化消息
	unregMsg(self, gud_refresh_baginfo)
	-- 销毁玩家数据变化的消息
	unregMsg(self, gud_refresh_playerinfo)
end


--暂停方法
function DlgGetResource:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgGetResource:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--背包数据刷新回调
function DlgGetResource:onRefreshData(  )
	-- body
	self:refreshLvItem()
	--粮食
	self.pItemFood:updateViews()
	--木头
	self.pItemWood:updateViews()
	--铁
	self.pItemIron:updateViews()
	--铜币
	self.pItemCoin:updateViews()
end

--下表选择回调事件
function DlgGetResource:onIndexSelected( _index )
	-- body
	if self.nCurIndex == _index then
		return
	end
	self.nCurIndex = _index
	self:refreshLvItem()
end

--刷新列表
function DlgGetResource:refreshLvItem(  )
	-- body
	local nResId = e_resdata_ids.lc
	if self.nCurIndex == 1 then 		 --银币
		nResId = e_resdata_ids.yb
		nRedExId = e_exchange_id.coin
	elseif self.nCurIndex == 2 then 	 --木材
		nResId = e_resdata_ids.mc
		nRedExId = e_exchange_id.wood
	elseif self.nCurIndex == 3 then 	 --粮食
		nResId = e_resdata_ids.lc
		nRedExId = e_exchange_id.food
	elseif self.nCurIndex == 4 then 	 --铁矿	 
		nResId = e_resdata_ids.bt
		nRedExId = e_exchange_id.iron
	end
	self.nResId = nResId
	self.tResGood = getShopBaseData(nRedExId)
	if self.tCurLists and table.nums(self.tCurLists) > 0 then
		self.tCurLists = nil
	end
	self.tCurLists = getAddResItemLists(nResId)
	local nCt = table.nums(self.tCurLists)

	if self.pListView == nil then
	    self.pListView = MUI.MListView.new {
	    	viewRect = cc.rect(0, 0, 532, self.pLayContent:getHeight() - 60),
	    	direction = MUI.MScrollView.DIRECTION_VERTICAL,
	    	itemMargin = {left = 0,
	    	right = 0,
	    	top = 10,
	    	bottom = 0}}	
		self.pListView:setItemCount(nCt)
		self.pListView:setBounceable(true)   
		self.pListView:setItemCallback(handler(self, self.onListViewItemCallBack))
		self.pTComTabHost:setContentLayer(self.pListView)
		centerInView(self.pTComTabHost:getContentLayer(), self.pListView)	
		self.pListView:reload(false)
	else
		self.pListView:notifyDataSetChange(false, nCt)
	end
	self:refreshTopItem()
end

--刷新队列数据
function DlgGetResource:refreshTopItem(  )
	-- body
	--如果有正在研究的科技
	if self.tResGood then
		self:addTopView()
	else
		self:removeTopView()
	end
end

--添加1h资源购买
function DlgGetResource:addTopView(  )
	-- body
	if not self.pTopView then
		self.pTopView = ItemVipShopGoods.new(true)
		self.pListView:addHeaderView(self.pTopView)
	end
	self.pTopView:setData(self.tResGood, self.tNeedValue, self.nResId)
end

--删除1h资源购买
function DlgGetResource:removeTopView(  )
	-- body
	self.pListView:removeHeaderView()
	self.pTopView = nil
end

--列表项回调
function DlgGetResource:onListViewItemCallBack( _index, _pView )
	-- body
	local tTempData = self.tCurLists[_index]
    local pTempView = _pView
    if pTempView == nil then
        pTempView = ItemInfo.new(TypeItemInfoSize.M)  
    end
    pTempView:setClickCallBack(handler(self, self.onActionClicked))
    pTempView:setCurData(tTempData)
    if tTempData then
    	if tTempData.nCt == 0 then
    		pTempView:changeExToGold()
    	else
    		pTempView:changeExToHad()
    	end
    end
    return pTempView
end

--操作按钮点击事件
function DlgGetResource:onActionClicked( _tItemInfo )
	-- body
	if _tItemInfo.nCt == 0 then

		local nCost = _tItemInfo.nPrice
	    local strTips = {
	    	{color=_cc.pwhite,text=getConvertedStr(1, 10146)},--购买并使用
	    	{color=_cc.yellow,text=_tItemInfo.sName},--名字
	    	{color=_cc.pwhite,text="?"},
	    }
	    --展示购买对话框
		showBuyDlg(strTips,nCost,function (  )
			-- body
			--发送使用物品消息
			local tObject = {}
			tObject.useId = _tItemInfo.sTid
			tObject.useNum = 1
			tObject.type = 2--购买并使用
			sendMsg(ghd_useItems_msg,tObject)
		end)
	else
		showUseItemDlg(_tItemInfo.sTid, self.tNeedValue, self.nResId)
	end
end

return DlgGetResource
