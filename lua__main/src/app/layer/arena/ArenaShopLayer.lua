-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-12-15 15:00:23 星期一
-- Description: 竞技场商店
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local DlgAlert = require("app.common.dialog.DlgAlert")
local ItemArenaShop = require("app.layer.arena.ItemArenaShop")
local ArenaShopLayer = class("ArenaShopLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)


function ArenaShopLayer:ctor(_tSize)
	-- body
	self:setContentSize(_tSize)
	self:myInit()
	parseView("lay_arena_shop", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function ArenaShopLayer:onParseViewCallback( pView )
	-- body
	
	self:addView(pView)
	self:setupViews()	
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("ArenaShopLayer",handler(self, self.onDestroy))
end

-- --初始化参数
function ArenaShopLayer:myInit()
	-- body
end

--初始化控件
function ArenaShopLayer:setupViews( )
	-- body	
	self.pLayTopInfo = self:findViewByName("lay_top_info")	
	self.pImgRes 	= self:findViewByName("img_res")	
	self.pLbTip1 	= self:findViewByName("lb_tip_1")
	self.pLbResNum 	= self:findViewByName("lb_res_num")
	self.pLayBtnRefresh = self:findViewByName("lay_refresh") 
	self.pLbTip2 	= self:findViewByName("lb_tip_2")
	self.pLayList = self:findViewByName("lay_list")

	self.pImgRes:setCurrentImage(getCostResImg(e_type_resdata.medal))

	setTextCCColor(self.pLbTip1, _cc.pwhite)
	self.pLbTip1:setString(getConvertedStr(6, 10683), false)	
	
	self.pLbTip2:setString(getTipsByIndex(20131))

	self.pBtnRefresh = getCommonButtonOfContainer(self.pLayBtnRefresh,TypeCommonBtn.L_BLUE,getConvertedStr(6,10729), false)	
	self.pBtnRefresh:onCommonBtnClicked(handler(self, self.onBtnRefreshClicked))

	local tBtnTable = {}		
	tBtnTable.img = getCostResImg(e_type_resdata.money)
	--文本
	tBtnTable.tLabel = {
		{"",getC3B(_cc.green)}
	}
	tBtnTable.awayH = 2
	self.pBtnExTxt = self.pBtnRefresh:setBtnExText(tBtnTable)
end

-- 修改控件内容或者是刷新控件数据
function ArenaShopLayer:updateViews(  )
	-- body
	-- 刷新资源数据
	self.pLbResNum:setString(formatCountToStr(getMyGoodsCnt(e_resdata_ids.medal)), false)	
	local nStartX = (self.pLayTopInfo:getWidth() - self.pLbTip1:getWidth() - self.pImgRes:getWidth() - self.pLbResNum:getWidth())/2
	self.pLbTip1:setPositionX(nStartX)
	self.pImgRes:setPositionX(nStartX + self.pLbTip1:getWidth())
	self.pLbResNum:setPositionX(nStartX + self.pLbTip1:getWidth() + self.pImgRes:getWidth())
	--刷新竞技场数据
	local pDataArena = Player:getArenaData()
	if not pDataArena then
		return
	end

	local tCost = pDataArena:getShopRefrshCost()
	local nCost = tCost.nCost or 0
	if nCost == 0 then
		self.pBtnExTxt:setVisible(false)
		self.pBtnRefresh:setButton(TypeCommonBtn.L_BLUE, getConvertedStr(5, 10262))--免费刷新
	else
		self.pBtnExTxt:setVisible(true)
		self.pBtnRefresh:setButton(TypeCommonBtn.L_YELLOW, getConvertedStr(6, 10729))--刷新列表
		self.pBtnRefresh:setExTextLbCnCr(1, nCost, getC3B(_cc.pwhite))
	end

	self.tShopItems = pDataArena:getArenaShopItems()
	local nItemCnt = #self.tShopItems
	if not self.pListView then		
	    self.pListView = MUI.MListView.new {
            bgColor = cc.c4b(255, 255, 255, 250),
            viewRect = cc.rect(0, 0, 600, self.pLayList:getHeight()),
            itemMargin = {left = 0,
            right = 0,
            top = 10 ,
            bottom = 5 },
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

function ArenaShopLayer:onEveryCallback( _index, _pView ) 
    local pView = _pView
	if not pView then
		pView = ItemArenaShop.new()
	end
	local pData = self.tShopItems[_index]
	pView:setCurData(pData)	
	pView:setCostTip(pData.nRes, pData.nCost)
	return pView
end

function ArenaShopLayer:onBtnRefreshClicked( pView )
	-- body
	print("刷新商店")
	local pData = Player:getArenaData()
	if not pData then
		return
	end
	-- local nLeft, nTotal = pData:getArenaShopRefreshNum()
	-- if nLeft <= 0 then--刷新次数不足
	-- 	TOAST(getConvertedStr(6, 10735))
	-- 	return
	-- end
	local tCost = pData:getShopRefrshCost()
	local nCost = tCost.nCost
	local strTips = {
	    {color=_cc.pwhite,text=getConvertedStr(6, 10732)},
	    {color=_cc.gray,text=getConvertedStr(6, 10733)},
	}
	if nCost == 0 then --免费
		SocketManager:sendMsg("reqRefreshArenaShop", {}, function ( __msg) 
			if __msg.head.state == SocketErrorType.success then		
				TOAST(getConvertedStr(6, 10734))										
			end
		end)		
	else		
		showBuyDlg(strTips, nCost, function (  )	   	
			--展示购买对话框
			SocketManager:sendMsg("reqRefreshArenaShop", {}, function ( __msg) 
				if __msg.head.state == SocketErrorType.success then		
					TOAST(getConvertedStr(6, 10734))										
				end
			end)
		end, 0, true)		
	end
end

--析构方法
function ArenaShopLayer:onDestroy(  )
	self:onPause()
end

-- 注册消息
function ArenaShopLayer:regMsgs( )
	-- body
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateViews))	
	regMsg(self, gud_refresh_arena_msg, handler(self, self.updateViews))	
	
end

-- 注销消息
function ArenaShopLayer:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_playerinfo)	
	unregMsg(self, gud_refresh_arena_msg)	
end
--暂停方法
function ArenaShopLayer:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function ArenaShopLayer:onResume( )
	-- body
	self:regMsgs()
	self:updateViews()
end

return ArenaShopLayer
