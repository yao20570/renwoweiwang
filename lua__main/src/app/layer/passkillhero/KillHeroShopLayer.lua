-- KillHeroShopLayer.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-3-14 14:43:06 星期三
-- Description: 过关斩将 商店分页
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local DlgAlert = require("app.common.dialog.DlgAlert")
local ItemArenaShop = require("app.layer.arena.ItemArenaShop")
local KillHeroShopLayer = class("KillHeroShopLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)


function KillHeroShopLayer:ctor(_tSize)
	-- body
	self:setContentSize(_tSize)
	self:myInit()
	parseView("lay_kill_hero_shop", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function KillHeroShopLayer:onParseViewCallback( pView )
	-- body
	self:addView(pView)
	self:setupViews()	
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("KillHeroShopLayer",handler(self, self.onDestroy))
end

-- --初始化参数
function KillHeroShopLayer:myInit()
	-- body
end

--初始化控件
function KillHeroShopLayer:setupViews( )
	-- body	
	self.pImgRes 	= self:findViewByName("img_res")	
	self.pImgRes:setCurrentImage(getCostResImg(e_type_resdata.killheroexp))
	self.pImgRes:setScale(0.5)
	self.pLbTip1 	= self:findViewByName("lb_tip_1")
	setTextCCColor(self.pLbTip1, _cc.pwhite)
	self.pLbTip1:setString(getConvertedStr(6, 10683), false)
	self.pLbTip2 	= self:findViewByName("lb_tip_2")
	self.pLbTip2:setString(getTipsByIndex(20131))
	self.pImgRes:setPositionX(self.pLbTip1:getPositionX() + self.pLbTip1:getWidth() + 5)
	self.pLbResNum 	= self:findViewByName("lb_res_num")
	self.pLbResNum:setPositionX(180)
	-- self.pLbResNum:setPositionX(self.pImgRes:getPositionX() + self.pImgRes:getWidth() + 5)

	self.pLbRefresh =   self:findViewByName("lb_num_refresh")
	self.pLayBtnRefresh = self:findViewByName("lay_refresh") 

	self.pImgCost = self:findViewByName("img_cost")
	self.pBtnRefresh = getCommonButtonOfContainer(self.pLayBtnRefresh,TypeCommonBtn.M_BLUE,getConvertedStr(6,10729))	
	self.pBtnRefresh:onCommonBtnClicked(handler(self, self.onBtnRefreshClicked))	
end

-- 修改控件内容或者是刷新控件数据
function KillHeroShopLayer:updateViews(  )
	-- body
	-- 刷新资源数据
	self.pLbResNum:setString(formatCountToStr(getMyGoodsCnt(e_resdata_ids.killheroexp)))	
	local pDataKillHero = Player:getPassKillHeroData()
	if not pDataKillHero then
		return
	end

	local tCost = pDataKillHero:getShopRefrshCost()
	local nCost = tCost.nCost or 0
	if nCost == 0 then
		self.pBtnRefresh:setButton(TypeCommonBtn.M_BLUE, getConvertedStr(5, 10262))--免费刷新
	else
		self.pBtnRefresh:setButton(TypeCommonBtn.M_BLUE, getConvertedStr(6, 10729))--免费刷新
		self.pLbRefresh:setString(nCost, false)
		self.pImgCost:setPositionX(self.pLbRefresh:getPositionX() - self.pLbRefresh:getWidth() - 5)
	end
	self.pImgCost:setVisible(nCost > 0)
	self.pLbRefresh:setVisible(nCost > 0)

	self.tShopItems = pDataKillHero:getShopItems()
	local nItemCnt = #self.tShopItems
	if not self.pListView then
		self.pLayList = self:findViewByName("lay_list")
	    self.pListView = MUI.MListView.new {
            bgColor = cc.c4b(255, 255, 255, 250),
            viewRect = cc.rect(0, 0, 600, self.pLayList:getHeight()),
            itemMargin = {left = 0,
            right = 0,
            top = 0,
            bottom = 11 },
            direction = MUI.MScrollView.DIRECTION_VERTICAL ,--listView方向
        }
        self.pListView:setBounceable(true) --是否回弹
        self.pListView:setPosition((self.pLayList:getWidth() - self.pListView:getWidth())/2, 0)
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

function KillHeroShopLayer:onEveryCallback( _index, _pView ) 
    local pView = _pView
	if not pView then
		pView = ItemArenaShop.new(_index)
	end
	local pData = self.tShopItems[_index]
	pView:setCurData(pData)	
	pView:setCostTip(pData.nRes, pData.nCost)
	pView:setBuyHandler(function()
		self:onBuyItem(pData)
	end)
	return pView
end

--购买物品
function KillHeroShopLayer:onBuyItem(pData)
	local nResId = pData.nRes
	local nCost = pData.nCost
	if nCost > getMyGoodsCnt(nResId) then
		local pDlg, bNew = getDlgByType(e_dlg_index.alert)
	    if(not pDlg) then
	        pDlg = DlgAlert.new(e_dlg_index.alert)
	    end
	    pDlg:setTitle(getConvertedStr(3, 10091))
	    pDlg:setContent(getConvertedStr(7, 10376))
	    local btn = pDlg:getRightButton()
	    btn:updateBtnText(getConvertedStr(6, 10216))
	    btn:updateBtnType(TypeCommonBtn.L_BLUE)
	    pDlg:setRightHandler(function (  )            
	        local tObject = {}
	        tObject.nType = e_dlg_index.dlgpasskillhero --dlg类型
	        tObject.nPagIndex = 1
	        sendMsg(ghd_show_dlg_by_type,tObject)   
	        closeDlgByType(e_dlg_index.alert, false)  
	    end)
	    pDlg:showDlg(bNew)   
	    return pDlg   
	else
		SocketManager:sendMsg("reqBuyPassGoods", {pData.nIndex}) 			
	end
end

function KillHeroShopLayer:onBtnRefreshClicked( pView )
	-- body
	local pData = Player:getPassKillHeroData()
	if not pData then
		return
	end

	local tCost = pData:getShopRefrshCost()
	local nCost = tCost.nCost
	if nCost == 0 then --免费
		SocketManager:sendMsg("reqResetPassShop", {}, function ( __msg) 
			if __msg.head.state == SocketErrorType.success then		
				TOAST(getConvertedStr(6, 10734))										
			end
		end)		
	else		
		local strTips = {
		    {color=_cc.pwhite,text=getConvertedStr(6, 10732)},
		    {color=_cc.gray,text=getConvertedStr(6, 10733)},
		}
		showBuyDlg(strTips, nCost, function (  )	   	
			--展示购买对话框
			SocketManager:sendMsg("reqResetPassShop", {}, function ( __msg) 
				if __msg.head.state == SocketErrorType.success then		
					TOAST(getConvertedStr(6, 10734))										
				end
			end)
		end, 0, true)		
	end
end

--析构方法
function KillHeroShopLayer:onDestroy(  )
	self:onPause()
end

-- 注册消息
function KillHeroShopLayer:regMsgs( )
	-- body
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateViews))	
end

-- 注销消息
function KillHeroShopLayer:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_playerinfo)	
end
--暂停方法
function KillHeroShopLayer:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function KillHeroShopLayer:onResume( )
	-- body
	self:regMsgs()
end

return KillHeroShopLayer
