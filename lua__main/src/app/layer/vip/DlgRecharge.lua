-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-27 10:28:23 星期六
-- Description: 游戏充值界面
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local VipLevelLayer = require("app.layer.vip.VipLevelLayer")
local ItemRechargeLayer = require("app.layer.vip.ItemRechargeLayer")

local DlgRecharge = class("DlgRecharge", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgrecharge)
end)

function DlgRecharge:ctor(  )
	-- body
	self:myInit()	
	parseView("dlg_recharge", handler(self, self.onParseViewCallback))
end

function DlgRecharge:myInit(  )
	-- body
	--
end

function DlgRecharge:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgRecharge",handler(self, self.onDestroy))	
end

--初始化控件
function DlgRecharge:setupViews(  )
	-- body	
	--设置标题
	self:setTitle(getConvertedStr(6,10291))	
	self.pLayTop = self:findViewByName("lay_top")

	self.pVipLevelLayer = VipLevelLayer.new(true)	
	self.pLayTop:addView(self.pVipLevelLayer, 10)
	centerInView(self.pLayTop, self.pVipLevelLayer)

	--说明按钮
	self.pMouthCardBtn = self.pVipLevelLayer:getBtnRight()	
	self.pMouthCardBtn:updateBtnType(TypeCommonBtn.O_BLUE)
	self.pMouthCardBtn:updateBtnText(getConvertedStr(6, 10770))
	self.pMouthCardBtn:onCommonBtnClicked(handler(self, self.onMouthCardBtnClicked))
	--VIP特权
	self.pShopBtn = self.pVipLevelLayer:getBtnLeft()
	self.pShopBtn:updateBtnType(TypeCommonBtn.O_YELLOW)
	self.pShopBtn:updateBtnText(getConvertedStr(6, 10290))
	self.pShopBtn:onCommonBtnClicked(handler(self, self.onVipBtnClicked))

end

--控件刷新
function DlgRecharge:updateViews(  )
	-- body	
	if self.pVipLevelLayer then
		self.pVipLevelLayer:updateViews()
	end
	self.tRechargeTable = getRechargeDlgData()	
	local nItemCnt = #self.tRechargeTable
	if not self.pListView then
		self.pLayList = self:findViewByName("lay_center_list")
	    self.pListView = MUI.MListView.new {
            bgColor = cc.c4b(255, 255, 255, 250),
            viewRect = cc.rect(0, 0, 640, self.pLayList:getHeight()),
            itemMargin = {left = 0,
            right = 0,
            top = 10 ,
            bottom = 5 },
            direction = MUI.MScrollView.DIRECTION_VERTICAL ,--listView方向
        }
        self.pListView:setBounceable(true) --是否回弹        
        self.pLayList:addView(self.pListView, 10)
        --上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
		self.pListView:setItemCount(nItemCnt)
		self.pListView:setItemCallback(handler(self, self.onEveryCallback))
		self.pListView:reload(false)	
	else		
		self.pListView:notifyDataSetChange(false, nItemCnt)
	end			
end

function DlgRecharge:onEveryCallback( _index, _pView )
	-- body
    local pView = _pView
	if not pView then
		pView = ItemRechargeLayer.new()
		pView:setViewTouched(true)
		pView:setIsPressedNeedScale(false)					
	end
	pView:setCurData(self.tRechargeTable[_index])	
	return pView	
end

--析构方法
function DlgRecharge:onDestroy()
	-- body
	self:onPause()
end

--注册消息
function DlgRecharge:regMsgs(  )
	-- body
	--注册玩家数据刷新消息
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateViews))	
end
--注销消息
function DlgRecharge:unregMsgs( )
	-- body
	--注销玩家数据刷新消息
	unregMsg(self, gud_refresh_playerinfo)	
end

--暂停方法
function DlgRecharge:onPause( )
	-- body	
	self:unregMsgs()	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgRecharge:onResume( _bReshow )
	-- body	
	self:updateViews()
	self:regMsgs()
end

--VIP特权按钮回调
function DlgRecharge:onVipBtnClicked(  )
	-- body
	local tObject = {}
	tObject.nType = e_dlg_index.dlgvipprivileges --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)		
end

--月卡按钮回调
function DlgRecharge:onMouthCardBtnClicked()
	local tData = Player:getActById(e_id_activity.monthweekcard)
	if not tData then
		TOAST(getConvertedStr(1,10375))
		return
	end

	local tObject = {}
	tObject.nType = e_dlg_index.monthweekcard --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)
	Player:removeFirstRedNums(tData)--移除第一次登录红点
	tData:setNewLocal() --移除新的标识
end

return DlgRecharge