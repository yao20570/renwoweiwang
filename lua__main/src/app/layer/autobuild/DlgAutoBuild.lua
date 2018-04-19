-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-03-06 11:01:58 星期二
-- Description: 自动建造
-----------------------------------------------------
local DlgBase = require("app.common.dialog.DlgBase")
local ItemAutoBuild = require("app.layer.autobuild.ItemAutoBuild")
local AutoBuildTips = require("app.layer.autobuild.AutoBuildTips")
local ShopFunc = require("app.layer.shop.ShopFunc")
local DlgAutoBuild = class("DlgAutoBuild", function()
	-- body
	return DlgBase.new(e_dlg_index.autobuild)
end)

--_nBuidlId：兵营id
--_bNewGuide:是否是新手任务
function DlgAutoBuild:ctor()
	-- body
	self:myInit()
	parseView("dlg_auto_build_mgr", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgAutoBuild:myInit(  )
	-- body

end

--解析布局回调事件
function DlgAutoBuild:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgAutoBuild",handler(self, self.onDestroy))
end

--初始化控件
function DlgAutoBuild:setupViews( )
	-- body
	self:setTitle(getConvertedStr(6, 10771))

	self.pLayRoot 		= 	self:findViewByName("lay_root")
	--顶部层
	self.pLayTop 		= 	self:findViewByName("lay_top")
	self.pLayOrder 		= 	self:findViewByName("lay_btn_list")
	self.pLbOrder 		= 	self:findViewByName("lb_order")
	self.pImgSanJiao	= 	self:findViewByName("img_sanjiao")
	self.pLbTip 		= 	self:findViewByName("lb_tip")
	self.pLaySwitch 	=   self:findViewByName("lay_switch")	
	--底部层
	self.pLayBot 		= 	self:findViewByName("lay_bot")
	self.pLayIcon 		= 	self:findViewByName("lay_icon")
	self.pItemName 		= 	self:findViewByName("lb_item_name")
	self.pLbDesc 		= 	self:findViewByName("lb_desc")
	self.pLayBtnLeft 	= 	self:findViewByName("lay_left_btn")
	self.pLayBtnRight  	= 	self:findViewByName("lay_right_btn")

	--中间层
	self.pLayCenter 	= 	self:findViewByName("lay_center")

	self.pLbTip:setString(getConvertedStr(6, 10772))
	setTextCCColor(self.pLbTip, _cc.white)	

	self.pLaySwitch:setPositionX(self.pLbTip:getPositionX() - self.pLbTip:getWidth() - self.pLaySwitch:getWidth() - 10)
	local nStatus = Player:getBuildData():getOpenLowLvFirst()				
	self.pOvalSw =  getOvalSwOfContainer(self.pLaySwitch,
		handler(self, self.onOvalSw),nStatus)

	self.pImgSanJiao:setFlippedY(true)

	self.pBtnAction = getCommonButtonOfContainer(self.pLayBtnLeft, TypeCommonBtn.M_RED, getConvertedStr(6, 10776))--开启
	self.pBtnAction:onCommonBtnClicked(handler(self, self.onOpenAutoBuild))
	local tActionTable = {}
	--文本
	tActionTable.tLabel = {{"已开启",getC3B(_cc.pwhite)}}
	self.pActionExText = self.pBtnAction:setBtnExText(tActionTable)


	self.pBtnBuy = getCommonButtonOfContainer(self.pLayBtnRight, TypeCommonBtn.M_YELLOW, getConvertedStr(6, 10296))--购买	
	self.pBtnBuy:onCommonBtnClicked(handler(self, self.onBuyAutoBuild))
	-- local tBuyTable = {}
	-- --文本
	-- tBuyTable.img = getCostResImg(e_type_resdata.money)
	-- tBuyTable.tLabel = {{"0",getC3B(_cc.pwhite)}}
	-- self.pBtnBuy:setBtnExText(tBuyTable)

	self.pLayOrder:setViewTouched(true)
	self.pLayOrder:onMViewClicked(handler(self, self.onSelectedSortType))
	self.pOrderBuild = AutoBuildTips.new()
	self.pOrderBuild:setVisible(false)
	local nX = self.pLayOrder:getPositionX() - (self.pOrderBuild:getWidth() - self.pLayOrder:getWidth())/2
	local nY = self.pLayOrder:getPositionY() - self.pOrderBuild:getHeight() - 5
	self.pOrderBuild:setPosition(nX, nY)
	self.pLayTop:addView(self.pOrderBuild, 10)
end

-- 修改控件内容或者是刷新控件数据
function DlgAutoBuild:updateViews(  )
	-- body
	local pData = Player:getBuildData()
	if not pData then
		return
	end
	local nType = pData.nAbt
	if nType == 0 then
		self.pLbOrder:setString(getConvertedStr(6, 10773), false)
	elseif nType == 1 then
		self.pLbOrder:setString(getConvertedStr(6, 10774), false)
	elseif nType == 2 then
		self.pLbOrder:setString(getConvertedStr(6, 10775), false)
	end
	
	local data = getBaseItemDataByID(e_item_ids.zdjz)
	if(not self.pIcon) then
		self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.item, data, TypeIconGoodsSize.L)
		self.pIcon:setScale(0.6)
	else
		self.pIcon:setCurData(data)
	end	
	self.pItemName:setString(data.sName..getSpaceStr(3)..getConvertedStr(6, 10135)..pData.nAutoUpTimes)
	setTextCCColor(self.pItemName, _cc.blue)

	self.pLbDesc:setString(data.sDes, false)
	setTextCCColor(self.pLbDesc, _cc.white)
	-- 自动建造开启状态
	if pData.bAutoUpOpen then--是否开启自动建造
		self.pBtnAction:setButton(TypeCommonBtn.M_RED, getConvertedStr(6, 10776))
		self.pActionExText:setLabelCnCr(1, getConvertedStr(6, 10778), getC3B(_cc.pwhite))
	else
		self.pBtnAction:setButton(TypeCommonBtn.M_BLUE, getConvertedStr(6, 10777))
		self.pActionExText:setLabelCnCr(1, getConvertedStr(6, 10779), getC3B(_cc.red))
	end

	self:refreshSanjiao()

	self.tListData = pData:getAutoBuildList()
	local nCnt = #self.tListData
	if not self.pListView then
		local pSize = self.pLayCenter:getContentSize()
		self.pListView = MUI.MListView.new {
			viewRect   = cc.rect(20, 0, pSize.width - 40, pSize.height),
			direction  = MUI.MScrollView.DIRECTION_VERTICAL,
			itemMargin = {left =  0,
	             right =  0,
	             top =  10,
	             bottom =  5},
	    }
	    self.pLayCenter:addView(self.pListView)
		self.pListView:setItemCallback(function ( _index, _pView ) 
		    local pTempView = _pView
		    if pTempView == nil then
		    	pTempView   = ItemAutoBuild.new()
			end
			pTempView:setData(self.tListData[_index], _index)
		    return pTempView
		end)
		self.pListView:setItemCount(nCnt)
		--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
		self.pListView:reload(false)
	else
		self.pListView:setItemCount(nCnt) 
		self.pListView:notifyDataSetChange(false)
	end
end

function DlgAutoBuild:onOpenAutoBuild( )
	-- body
	local pData = Player:getBuildData()
	if not pData then
		return
	end

	local nState = 0
	if pData.bAutoUpOpen then   --开启中
		nState = 0
	else 										--关闭中
		nState = 1
	end
	--自动建造次数
	local nAutoBuildCt = pData.nAutoUpTimes
	if nAutoBuildCt and nAutoBuildCt > 0 then
		SocketManager:sendMsg("autoBuilding", {nState}, handler(self, self.autoBuildingResponse))
	else
		--没有次数就跳转到商店界面并定位到自动建造物品
		self:openBuyVipShop(e_item_ids.zdjz)
	end

end
--购买自动建造
function DlgAutoBuild:onBuyAutoBuild(  )
	-- body
	self:openBuyVipShop(e_item_ids.zdjz)
end

--自动升级请求界面回调刷新
function DlgAutoBuild:autoBuildingResponse( __msg, __oldMsg )
	-- body
	if __msg.head.type == MsgType.autoBuilding.id then 			--建筑升级
		if __msg.head.state == SocketErrorType.success then
			if __msg.body.openAuto then
				TOAST(getTipsByIndex(10080))
			else
				TOAST(getTipsByIndex(10081))
			end			
		else
		    TOAST(SocketManager:getErrorStr(__msg.head.state))
        end
    end
	
end

--直接打开购买vip商店的物品
function DlgAutoBuild:openBuyVipShop( _nGoodId )
	-- body
	local tShopBase = getShopDataById( _nGoodId )
	local bNeedVipGift, bHadVipGift, tStr = ShopFunc.getGoodVipGiftInfo( _nGoodId )
	if (bNeedVipGift == true and bHadVipGift == false) then
		local tObject = {
			nType = e_dlg_index.vipgitfgoodtip, --dlg类型
			tShopBase = tShopBase,
		}
		sendMsg(ghd_show_dlg_by_type, tObject)	
	else
		local tObject = {
			nType = e_dlg_index.shopbatchbuy, --dlg类型
			tShopBase = tShopBase,
		}
		sendMsg(ghd_show_dlg_by_type, tObject)	
	end
end

function DlgAutoBuild:onSelectedSortType( )
	-- body
	self.pOrderBuild:setVisible(not self.pOrderBuild:isVisible())
	self:refreshSanjiao()
end

function DlgAutoBuild:refreshSanjiao( ... )
	-- body
	if self.pOrderBuild:isVisible() then
		self.pImgSanJiao:setFlippedY(false)
	else
		self.pImgSanJiao:setFlippedY(true)
	end	
end

--椭圆形开关
function DlgAutoBuild:onOvalSw()
	local pData = Player:getBuildData()
	if not pData then
		return
	end 
	local nType = 0
	if pData.nLp == 0 then
		nType = 1
	elseif pData.nLp == 1 then
		nType = 0
	end

	SocketManager:sendMsg("reqLowGradePriority", {nType}, handler(self, self.onGetDataFunc))
end

--接收服务端发回的登录回调
function DlgAutoBuild:onGetDataFunc( __msg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqLowGradePriority.id then
        	if not tolua.isnull(self.pOvalSw) then
        		local nStatus = Player:getBuildData():getOpenLowLvFirst()	
        		self.pOvalSw:setState(nStatus)        	
        	end
        end
    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end
-- 析构方法
function DlgAutoBuild:onDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgAutoBuild:regMsgs( )
	-- body
	-- 注册自动建造数据刷新消息
	regMsg(self, ghd_auto_build_mgr_msg, handler(self, self.updateViews))
end

-- 注销消息
function DlgAutoBuild:unregMsgs(  )
	-- body
	-- 注销自动建造数据刷新消息
	unregMsg(self, ghd_auto_build_mgr_msg)
end


--暂停方法
function DlgAutoBuild:onPause( )
	-- body
	self:unregMsgs()	
end

--继续方法
function DlgAutoBuild:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()	
end

return DlgAutoBuild