-----------------------------------------------------
-- author: luwenjing
-- updatetime:  2018-01-26:19:23 星期五
-- Description: 福星高照紅包全開
-----------------------------------------------------

local MDialog = require("app.common.dialog.MDialog")
local IconGoods = require("app.common.iconview.IconGoods")
local DlgLuckyStarOpenAll = class("DlgLuckyStarOpenAll", function()
	-- body
	return MDialog.new(e_dlg_index.dlgluckystaropenall)
end)

function DlgLuckyStarOpenAll:ctor(  )
	-- body
	self:myInit()
	parseView("dlg_lucky_star_open_all", handler(self, self.onParseViewCallback))
	self:setName(UIAction.TAG_SMALL_DLG)
end

function DlgLuckyStarOpenAll:myInit(  )
	-- body
	self.nCost = 0
	self.nLeft = 0

end

--解析布局回调事件
function DlgLuckyStarOpenAll:onParseViewCallback( pView )
	-- body
	self:setContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgLuckyStarOpenAll",handler(self, self.onDestroy))
end

--初始化控件
function DlgLuckyStarOpenAll:setupViews(  )
	--body	
	self.pLayIcon = self:findViewByName("lay_icon")

	self.pTxtMyPoint = self:findViewByName("txt_my_point")
	self.pTxtTip = self:findViewByName("txt_tip")

	self.pLayClose = self:findViewByName("lay_close")
	self.pLayClose:setViewTouched(true)
	self.pLayClose:onMViewClicked(handler(self, self.closeDlg))
	self.pLayClose:setIsPressedNeedScale(false)
	self.pLayClose:setIsPressedNeedColor(false)	


	self.pLayBtnLeft = self:findViewByName("lay_btn_left")--左边按钮
	self.pBtnLeft = getCommonButtonOfContainer(self.pLayBtnLeft, TypeCommonBtn.M_BLUE, getConvertedStr(9,10139))
	self.pBtnLeft:onCommonBtnClicked(handler(self, self.onBtnLeftClicked))

	self.pLayBtnRight = self:findViewByName("lay_btn_right")--左边按钮
	self.pBtnRight = getCommonButtonOfContainer(self.pLayBtnRight, TypeCommonBtn.M_YELLOW, getConvertedStr(9,10140))
	self.pBtnRight:onCommonBtnClicked(handler(self, self.onBtnRightClicked))

end

--控件刷新
function DlgLuckyStarOpenAll:updateViews(  )
	-- body	
	local tActData=Player:getActById(e_id_activity.luckystar)
	if not tActData then
		return
	end

	--我的物品数据
	local tMyItemData=Player:getBagInfo():getItemDataById(100178)
	local tItemData = getGoodsByTidFromDB(100178)
	if tItemData then
		if not self.pItemIcon then
			self.pItemIcon = IconGoods.new(TypeIconGoods.NORMAL)
			self.pLayIcon:addView(self.pItemIcon)
			-- centerInView(self.pLayIcon,self.pItemIcon)
		end
		self.pItemIcon:setCurData(tItemData)	
		if tMyItemData then
			self.pItemIcon:setNumber(tMyItemData.nCt or 0)
		else
			self.pItemIcon:setNumber(0)
		end
	end

	local tStr =string.format(getConvertedStr(9,10132),tActData.nF)
	self.pTxtMyPoint:setString(tStr)
	--拥有的数量超过88
	if tMyItemData and tMyItemData.nCt >=88 then
		self.nCost = 0
		local tStr2 =getTextColorByConfigure(getConvertedStr(9,10142))
		self.pTxtTip:setString(tStr2)
	else
		if tMyItemData then
			self.nLeft = 88 - tMyItemData.nCt
			
		else
			self.nLeft = 88 
		end
		self.nCost = self.nLeft * tActData.nRg
		local tStr2 =getTextColorByConfigure(string.format(getConvertedStr(9,10141),self.nCost))
		self.pTxtTip:setString(tStr2)
	end
end

function DlgLuckyStarOpenAll:onBtnLeftClicked( )
	-- body
	local tMyItemData=Player:getBagInfo():getItemDataById(100178)
	local nNum = 0
	if tMyItemData and tMyItemData.nCt > 0 then
		nNum = tMyItemData.nCt
		SocketManager:sendMsg("luckyStarOpenServeral", {nNum,0}, handler(self, self.onGetFunc)) 
	else
		local tItemData = getGoodsByTidFromDB(100178)
		local tActData=Player:getActById(e_id_activity.luckystar)
		if not tActData then
			return
		end
		local nCostMoney = tActData.nRg --需要消耗的黄金
		local strTips = {
		    {color=_cc.pwhite, text = string.format(getConvertedStr(7, 10273), tItemData.sName)},
		    {color=_cc.yellow, text = nCostMoney..getConvertedStr(7, 10036)},
		    {color=_cc.pwhite, text = string.format(getConvertedStr(9, 10143), 1, tItemData.sName)},
		}
		--展示购买对话框
		showBuyDlg(strTips, nCostMoney,function (  )
			SocketManager:sendMsg("luckyStarOpenServeral",{0,1},handler(self,self.onGetFunc))
		end, 1, true)

	end
	
end


function DlgLuckyStarOpenAll:onBtnRightClicked(  )
	-- body
	if self.nCost == 0 then
		SocketManager:sendMsg("luckyStarOpenServeral", {88,0}, handler(self, self.onGetFunc)) 
	else
		local tItemData = getGoodsByTidFromDB(100178)
		if tItemData then
			local strTips = {
			    {color=_cc.pwhite, text = string.format(getConvertedStr(7, 10273), tItemData.sName)},
			    {color=_cc.yellow, text = self.nCost..getConvertedStr(7, 10036)},
			    {color=_cc.pwhite, text = string.format(getConvertedStr(9, 10143), self.nLeft, tItemData.sName)},
			}
			local nMyOwn = 88 - self.nLeft
			--展示购买对话框
			showBuyDlg(strTips, self.nCost,function (  )
				SocketManager:sendMsg("luckyStarOpenServeral",{nMyOwn,self.nLeft},handler(self,self.onGetFunc))
			end, 1, true)
		end

	end
end

function DlgLuckyStarOpenAll:onGetFunc( __msg )
	-- body
	if  __msg.head.state == SocketErrorType.success then
		if __msg.body and __msg.body.o then
			--奖励领取表现(包含有武将的情况走获得武将流程)	
			self:showGetReward(__msg.body)	
		
		end
		local tActData = Player:getActById(e_id_activity.luckystar)
		tActData:refreshDatasByServer(__msg.body)
		sendMsg(gud_refresh_activity)

		self:closeDlg()
	end
end

--展示获得英雄
function DlgLuckyStarOpenAll:showGetReward(_tData)
	if not _tData then
		return
	end
	local nLuckyPoint = 0
	local tTemp = {}
	for k,v in pairs(_tData.o) do

		if v.k == e_type_resdata.luckypoint then
			nLuckyPoint = nLuckyPoint + v.v
		end

		if not tTemp[v.k] then
			tTemp[v.k] = v
		else
			tTemp[v.k].v =tTemp[v.k].v + v.v
		end
		
	end

	local tDataList = {}

	for k,v in pairs(tTemp) do
		local tReward = {}
		tReward.d = {}
		tReward.g = {}
		table.insert(tReward.d, copyTab(v))
		table.insert(tReward.g, copyTab(v))
		table.insert(tDataList,tReward)
	end

	--设置按钮数据
	local tRBtnData = {}
	tRBtnData.nBtnType = TypeCommonBtn.L_BLUE
	tRBtnData.sBtnStr =getConvertedStr(1, 10059)
	-- tRBtnData.nClickedFunc = function (  )
	-- 	-- body
	-- 	closeDlgByType(e_dlg_index.showheromansion, false)
	-- end
	local tLabel = {
		{getConvertedStr(9, 10144), getC3B(_cc.white)},
		{tostring(nLuckyPoint), getC3B(_cc.green)},
	}
	local tConTable = {}

	tConTable.tLabel=tLabel
	tRBtnData.tConTable=tConTable
	
	tRBtnData.bIsEnable = true

	--打开获得物品对话框对话框
    local tObject = {}
    tObject.nType = e_dlg_index.showheromansion --dlg类型
    tObject.tReward = tDataList
    tObject.tRBtnData = tRBtnData
    tObject.bHideGo = true
    tObject.sBottomTip = getConvertedStr(9,10101)
    sendMsg(ghd_show_dlg_by_type,tObject)
end



--析构方法
function DlgLuckyStarOpenAll:onDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgLuckyStarOpenAll:regMsgs(  )
	-- body
	--活动数据刷新
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))	
end
--注销消息
function DlgLuckyStarOpenAll:unregMsgs(  )
	-- body
	--注销活动数据刷新
	unregMsg(self, gud_refresh_activity)
end

--暂停方法
function DlgLuckyStarOpenAll:onPause( )
	-- body
	self:unregMsgs()	
end

--继续方法
function DlgLuckyStarOpenAll:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

return DlgLuckyStarOpenAll