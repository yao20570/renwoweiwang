-- ItemWelcomeBack.lua
---------------------------------------------
-- Author: dshulan
-- Date: 2018-04-12 17:39:00
-- 王者归来列表项
---------------------------------------------

local MCommonView = require("app.common.MCommonView")

local ItemWelcomeBack = class("ItemWelcomeBack", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemWelcomeBack:ctor()
	-- body	
	self:myInit(_index)	
	parseView("item_welcome_back", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemWelcomeBack:myInit()
	-- body
	self.tCurData  = nil 				--当前数据
	self.tItemList = {}
end

--解析布局回调事件
function ItemWelcomeBack:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemWelcomeBack",handler(self, self.onItemWelcomeBackDestroy))
end

--初始化控件
function ItemWelcomeBack:setupViews()
	-- body
	self.pLayRoot    = self:findViewByName("default")
	--lb
	self.pImgUp      = self:findViewByName("img_up")
	self.pImgUp:setFlippedY(true)

	--第几天
	self.pLbDay = self:findViewByName("lb_day")
	-- setTextCCColor(self.pLbDay, _cc.pwhite)
	--任务说明
	self.pLbTask = self:findViewByName("lb_task")
	--进度
	self.pLbProgress = self:findViewByName("lb_progress")

	--img
	self.pImgState = self:findViewByName("img_state")

	self.pLayBtn = self:findViewByName("lay_btn")
	--按钮
	self.pBuyBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.M_YELLOW, getConvertedStr(7, 10086))
	self.pBuyBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))

	--物品图标层
	self.pLayGoods   = self:findViewByName("lay_awards")
	
end

-- 修改控件内容或者是刷新控件数据
function ItemWelcomeBack:updateViews()
	if not self.nCurIdx then return end
	local tAc = Player:getActById(e_id_activity.welcomeback)
	if tAc == nil then
		return
	end
	self.tCurData = tAc.tConf[self.nCurIdx]
	if not self.tCurData then
		return
	end
	self.pLbDay:setString(string.format(getConvertedStr(7, 10450), self.tCurData.nDay))
	self.pLbTask:setString(getTextColorByConfigure(string.format(self.tCurData.sTask, self.tCurData.nNum)))

	self:setGoodsListViewData(self.tCurData.tAwards)

	if self.tCurData.nGot == e_get_state.canget then --可领
		self.pLayBtn:setVisible(true)
	else
		self.pLayBtn:setVisible(false)
		if self.tCurData.nGot == e_get_state.havegot then --已领取
			self.pImgState:setCurrentImage("#v2_fonts_yilingqu.png")
		else
			if self.tCurData.nDay > table.nums(tAc.tTaskReach) then --未开启
				self.pImgState:setCurrentImage("#v2_fonts_weikaiqi.png")
			else 													--未达到
				self.pImgState:setCurrentImage("#v2_fonts_weidadao.png")
			end
		end
	end
	--当前完成个数
	local nCurFinish = 0
	for k, v in pairs(tAc.tTaskReach) do
		if v.k == self.tCurData.nDay then
			nCurFinish = v.v
		end
	end
	if nCurFinish > self.tCurData.nNum then
		nCurFinish = self.tCurData.nNum
	end
	local str = {
		{text = nCurFinish, color = _cc.blue},
		{text = "/"..self.tCurData.nNum, color = _cc.pwhite},
	}
	self.pLbProgress:setString(str)
end

--设置数据
-- tItemList:List<Pair<Integer,Long>>
function ItemWelcomeBack:setGoodsListViewData(tItemList)
	if not tItemList then
		return
	end
	local tCurDatas = getRewardItemsFromSever(tItemList)

    gRefreshHorizontalList(self.pLayGoods, tCurDatas)
end

--领取奖励按钮回调
function ItemWelcomeBack:onBtnClicked( pView )
	-- body
	SocketManager:sendMsg("reqWelcomebackAwards", {self.tCurData.nDay}, handler(self, self.onGetCallBack))
end

--领取奖励回调
function ItemWelcomeBack:onGetCallBack( __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		if __msg.body and __msg.body.ob then
			showGetAllItems(__msg.body.ob)
		end		
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end	
end

-- 析构方法
function ItemWelcomeBack:onItemWelcomeBackDestroy()
	-- body
end

-- 设置单项数据
function ItemWelcomeBack:setItemData(_index)
  	self.nCurIdx = _index
	self:updateViews()
end



return ItemWelcomeBack