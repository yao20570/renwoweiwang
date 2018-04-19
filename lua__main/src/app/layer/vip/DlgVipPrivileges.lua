-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-27 10:39:23 星期六
-- Description: vip特权
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local VipLevelLayer = require("app.layer.vip.VipLevelLayer")
local PrivilegesIntroduce = require("app.layer.vip.PrivilegesIntroduce")
local LayPrivilegesGift = require("app.layer.vip.LayPrivilegesGift")
local FCommonTabHost = require("app.common.tabhost.FCommonTabHost")
local DlgVipPrivileges = class("DlgVipPrivileges", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgvipprivileges)
end)

function DlgVipPrivileges:ctor( nDefIdx )
	-- body
	self:myInit(nDefIdx)
	parseView("dlg_vip_privileges", handler(self, self.onParseViewCallback))
end

function DlgVipPrivileges:myInit( nDefIdx )
	-- body	
	self.nDefualtIdx = nDefIdx	
	self.tPagGroup = {}
	self.nPrevPage = 0
	self.nVipNums = 0		
end

--解析布局回调事件
function DlgVipPrivileges:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgVipPrivileges",handler(self, self.onDestroy))
end

--初始化控件
function DlgVipPrivileges:setupViews(  )
	-- body	
	--设置标题
	self:setTitle(getConvertedStr(6,10290))

	self.pLayTop = self:findViewByName("lay_top")
	--Vip等级信息显示
	self.pVipLevelLayer = VipLevelLayer.new(false)--特权	
	self.pLayTop:addView(self.pVipLevelLayer)
	--充值按钮
	self.pRechargeBtn = self.pVipLevelLayer:getBtnLeft()
	self.pRechargeBtn:updateBtnType(TypeCommonBtn.O_YELLOW)
	self.pRechargeBtn:updateBtnText(getConvertedStr(6, 10301))
	self.pRechargeBtn:onCommonBtnClicked(handler(self, self.onRechargeBtnClicked))
	--商店按钮
	-- self.pShopBtn = self.pVipLevelLayer:getBtnRight()
	-- self.pShopBtn:updateBtnType(TypeCommonBtn.O_BLUE)
	-- self.pShopBtn:updateBtnText(getConvertedStr(6, 10302))
	-- self.pShopBtn:onCommonBtnClicked(handler(self, self.onShopBtnClicked))	

	self.pLayTab = self:findViewByName("lay_center")	
	local tTitles = {getConvertedStr(6, 10762), getConvertedStr(6, 10763)}
	self.pTabHost = FCommonTabHost.new(self.pLayTab,1,1,tTitles,handler(self, self.getLayerByKey), 1)
	self.pTabHost:setLayoutSize(self.pLayTab:getLayoutSize())
	self.pTabHost:removeLayTmp1()
	self.pTabHost:removeLayTmp2()
	self.pTabHost:setTabChangedHandler(handler(self, self.onTabChanged))
	self.pLayTab:addView(self.pTabHost,10)
	self.pTabMgr = self.pTabHost.pTabManager
	self.pTabMgr:setImgBag("#v1_btn_selected_biaoqian2.png", "#v1_btn_biaoqian2.png")
	self.pTabHost:setDefaultIndex(1)
	self.tTabItems = self.pTabHost:getTabItems()
end

--控件刷新
function DlgVipPrivileges:updateViews(  )
	-- body	
	if self.pVipLevelLayer then
		self.pVipLevelLayer:updateViews()
	end
	local pItemTab = self.tTabItems[2]
	if pItemTab then
		showRedTips(pItemTab:getRedNumLayer(), 0, Player:getPlayerInfo():getVipGiftRedNum(), 2)
	end	
end

function DlgVipPrivileges:onTurnPage( sMsgName, pMsgObj )
	-- body
	local nTargetLv = pMsgObj
	if self.pVipLevelLayer then
		self.pVipLevelLayer:setVipTarget(nTargetLv)
	end
end

function DlgVipPrivileges:getLayerByKey( _sKey, _tKeyTabLt )
	-- body
	local pLayer = nil	
	local tSize = self.pTabHost:getCurContentSize()
	if( _sKey == _tKeyTabLt[1] ) then
		pLayer = PrivilegesIntroduce.new(tSize, self.nDefualtIdx)			
		self.tPagGroup[1] = pLayer		
	elseif (_sKey == _tKeyTabLt[2] ) then
		pLayer = LayPrivilegesGift.new(tSize)	
		self.tPagGroup[2] = pLayer		
	end
	return pLayer
end

function DlgVipPrivileges:onTabChanged( _sKey, _nType )
	local pLayer = nil
	if _sKey == "tabhost_key_1" then
		
	elseif _sKey == "tabhost_key_2" then
		Player:getPlayerInfo():clearVipGiftRedNum()
		self:updateViews()	
	end
end

--析构方法
function DlgVipPrivileges:onDestroy()
	-- body
	self:onPause()
end

--注册消息
function DlgVipPrivileges:regMsgs(  )
	-- body
	--注册玩家数据刷新消息
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateViews))	
	--vip礼包购买刷新
	regMsg(self, gud_vip_gift_bought_update_msg, handler(self, self.updateViews))	
	--翻页消息
	regMsg(self, ghd_vip_turnpage_msg, handler(self, self.onTurnPage))
end
--注销消息
function DlgVipPrivileges:unregMsgs( )
	-- body
	--注销玩家数据刷新消息
	unregMsg(self, gud_refresh_playerinfo)	
	unregMsg(self, gud_vip_gift_bought_update_msg)	
	unregMsg(self, ghd_vip_turnpage_msg)	
end

--暂停方法
function DlgVipPrivileges:onPause( )
	-- body
	self:unregMsgs()	
end

--继续方法
function DlgVipPrivileges:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--充值按钮
function DlgVipPrivileges:onRechargeBtnClicked(  )
	-- body
	local tObject = {}
	tObject.nType = e_dlg_index.dlgrecharge --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)	
end

--商店
function DlgVipPrivileges:onShopBtnClicked(  )
	-- body	
	local tObject = {}
	tObject.nType = e_dlg_index.shop --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)	
end
return DlgVipPrivileges