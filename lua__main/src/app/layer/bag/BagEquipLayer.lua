-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-04-24 15:12:23 星期一
-- Description: 背包界面的装备页面
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local BagEquip = require("app.layer.bag.BagEquip")

local BagEquipLayer = class("BagEquipLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function BagEquipLayer:ctor(_tSize)
	-- body
    self:setContentSize(_tSize)
	self:myInit()

	parseView("lay_bag_equip", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("BagEquipLayer",handler(self, self.onBagEquipLayerDestroy))
	
end

--初始化参数
function BagEquipLayer:myInit()
	-- body
	self.tEquipList = nil
end

--解析布局回调事件
function BagEquipLayer:onParseViewCallback( pView )
    pView:setContentSize(self:getContentSize())
    pView:requestLayout()
	self:addView(pView)
	centerInView(self, pView)
	self:setupViews()
	self:onResume()
	self:updateViews()
end

--初始化控件
function BagEquipLayer:setupViews( )
	-- --底层标注
	-- self.pLayBottom = self:findViewByName("lay_bottom")
	-- --容量
	-- self.pLbEquipbgStatus = self:findViewByName("lb_equipbg_status")
	-- self.pLbEquipbgStatus:setString(getConvertedStr(6, 10127))
	-- --装备数量
	-- self.pLbEquipnum = self:findViewByName("lb_equipnum")
	-- self.pLbEquipnum:setString("45")
	-- setTextCCColor(self.pLbEquipnum, _cc.blue)
	-- --背包容量
	-- self.pLbBagCapacity = self:findViewByName("lb_bag_capacity")
	-- self.pLbBagCapacity:setString("/90")
	-- setTextCCColor(self.pLbBagCapacity, _cc.pwhite)
	-- --扩容按钮
	-- self.pLayBtnExpand = self:findViewByName("lay_btn_expand")
	-- self.pBtnExpand = getCommonButtonOfContainer(self.pLayBtnExpand, TypeCommonBtn.M_YELLOW, getConvertedStr(6, 10134))
	-- setMCommonBtnScale(self.pLayBtnExpand, self.pBtnExpand, 0.8)
	-- self.pBtnExpand:onCommonBtnClicked(handler(self, self.onExpandBtnClicked))
	-- self.pBtnExpand:setVisible(true)
	-- --列表层
	-- self.pLayList = self:findViewByName("lay_listview")
	-- self.pListView = MUI.MListView.new {
	 --    	bgColor = cc.c4b(255, 255, 255, 250),
	 --    	viewRect = cc.rect(15, 0, 570, 700),
	 --    	direction = MUI.MScrollView.DIRECTION_VERTICAL,
	 --    	itemMargin = {left =  0,
	 --    	right =  0,
	 --    	top =  10,
	 --    	bottom =  0}}
	-- self.pListView:setBounceable(true)   
	-- self.pListView:setItemCallback(handler(self, self.onListViewItemCallBack))
	-- self.pLayList:addView(self.pListView, 10)
	-- centerInView(self.pLayList, self.pListView)	
end

-- 修改控件内容或者是刷新控件数据
function BagEquipLayer:updateViews(  )
	-- body
	self.tEquipList = Player:getEquipData():getIdleEquipVos()	
	--背包容量
	if not self.pLbBagCapacity then
		self.pLbBagCapacity = self:findViewByName("lb_bag_capacity")
	end
	--装备数量
	local nequipCnt = table.nums(self.tEquipList)
	local equipBagMax = Player:getEquipData():getEquipCapacityMax()			
	local sStr = {
		{color=_cc.white, text=getConvertedStr(6, 10127)},
		{color=_cc.blue, text=nequipCnt},
		{color=_cc.pwhite, text="/"..equipBagMax},
	}
	self.pLbBagCapacity:setString(sStr, false)	

	--扩容按钮
	if not self.pBtnExpand then
		self.pLayBtnExpand = self:findViewByName("lay_btn_expand")
		self.pBtnExpand = getCommonButtonOfContainer(self.pLayBtnExpand, TypeCommonBtn.M_YELLOW, getConvertedStr(6, 10134))
		setMCommonBtnScale(self.pLayBtnExpand, self.pBtnExpand, 0.8)
		self.pBtnExpand:onCommonBtnClicked(handler(self, self.onExpandBtnClicked))
		self.pBtnExpand:setVisible(true)
	end
	local value = getEquipInitParam("buyCapacityCost")
	local tcosttab = luaSplit(value, ";")
	--已购买次数少于总的可购买次数
	if Player:getEquipData().nBoughtCount < table.nums(tcosttab) then
		self.pBtnExpand:setVisible(true)
	else
		self.pBtnExpand:setVisible(false)
	end			

	if not self.pLayList then
		self.pLayList = self:findViewByName("lay_listview")
	end
	if not self.pListView and self.pLayList then
		self.pListView = MUI.MListView.new {
	    	bgColor = cc.c4b(255, 255, 255, 250),
	    	viewRect = cc.rect(20, 0, 600, 700),
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
		self.pListView:setItemCount(#self.tEquipList) 
		self.pListView:reload(true)
	else	
		self.pListView:notifyDataSetChange(true, #self.tEquipList)
	end		
end

--析构方法
function BagEquipLayer:onBagEquipLayerDestroy(  )
	self:onPause(  )
end

--注册消息
function BagEquipLayer:regMsgs(  )
	-- body
	--注册装备数据刷新消息
	regMsg(self, gud_equip_strength_msg, handler(self, self.updateViews))	
end
--注销消息
function BagEquipLayer:unregMsgs(  )
	-- body
	--注销装备数据刷新消息
	unregMsg(self, gud_equip_strength_msg)	
end

--暂停方法
function BagEquipLayer:onPause( )
	-- body	
	self:unregMsgs()	
end

--继续方法
function BagEquipLayer:onResume( )
	-- body
	self:regMsgs()
end

function BagEquipLayer:onListViewItemCallBack(  _index, _pView  )
		-- body
    local pTempView = _pView
    if pTempView == nil then
        pTempView = BagEquip.new()                        
        pTempView:setViewTouched(false)        
    end        
    pTempView:setCurData(self.tEquipList[_index])
    return pTempView

end

--扩容按钮回调
function BagEquipLayer:onExpandBtnClicked( pView )
	-- body
	--发送扩容请求
	local value = getEquipInitParam("buyCapacityCost")
	local tcosttab = luaSplit(value, ";")
	local ncost = 0
	if tcosttab[Player:getEquipData().nBoughtCount + 1] then
		ncost = tonumber(tcosttab[Player:getEquipData().nBoughtCount + 1])
	end
	local nadd = getEquipInitParam("buyOnceCapacity")
	local x = Player:getEquipData():getEquipCapacityMax() + nadd--扩容目标	
	local strTips = {
    	{color=_cc.white,text=getConvertedStr(6, 10143)},--扩充容量到
    	{color=_cc.blue,text=x},--立即完成建筑升级？
    }
	showBuyDlg(strTips, ncost, handler(self, self.sendExpandRequest), 0, true)
end
--向服务端发送扩容请求
function BagEquipLayer:sendExpandRequest( pView )
	-- body
	SocketManager:sendMsg("reqEquipCapacity", {}, handler(self, self.expandRequestCakkBack))
end
	
function BagEquipLayer:expandRequestCakkBack ( __msg )
	-- body
	if __msg.head.state == SocketErrorType.success	then				
		--扩展背包容量成功
		TOAST(getTipsByIndex(10065))
	else		
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end
--获取当前装备数量
function BagEquipLayer:getEquipCnt(  )
	-- body
	local nCnt = 0
	if self.pListView then
		nCnt = self.pListView:getItemCount()
	end
	return nCnt
end
return BagEquipLayer
