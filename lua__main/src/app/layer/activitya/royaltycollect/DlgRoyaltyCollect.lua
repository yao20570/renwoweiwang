-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-12-15 10:19:23 星期五
-- Description: 王权征收
-----------------------------------------------------

local MDialog = require("app.common.dialog.MDialog")
local RichText = require("app.common.richview.RichText")
local DlgRoyaltyCollect = class("DlgRoyaltyCollect", function()
	-- body
	return MDialog.new(e_dlg_index.dlgroyaltycollect)
end)

function DlgRoyaltyCollect:ctor(  )
	-- body
	self:myInit()
	parseView("dlg_royalty_collect", handler(self, self.onParseViewCallback))
	self:setName(UIAction.TAG_SMALL_DLG)
end

function DlgRoyaltyCollect:myInit(  )
	-- body
	self.tActData = nil
	self.nDayIdx = -1
	self.tDayBtns = {}
	self.tPrizeItems = {}
	self.tPrizesDatas = {}
	self.pLayRedS={}	
end

--解析布局回调事件
function DlgRoyaltyCollect:onParseViewCallback( pView )
	-- body
	self:setContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgRoyaltyCollect",handler(self, self.onDestroy))
end

--初始化控件
function DlgRoyaltyCollect:setupViews(  )
	--body	
	self.pLayRoot = self:findViewByName("lay_def")

	self.pLayTop = self:findViewByName("lay_top")

	self.pLayClose = self:findViewByName("lay_close")
	self.pLayClose:setViewTouched(true)
	self.pLayClose:onMViewClicked(handler(self, self.closeDlg))
	self.pLayClose:setIsPressedNeedScale(false)
	self.pLayClose:setIsPressedNeedColor(false)	

	self.pImgBox = self:findViewByName("img_baoxiang")
	self.pLayJump = self:findViewByName("lay_btn_get")
	self.pBtnJump = getCommonButtonOfContainer(self.pLayJump, TypeCommonBtn.M_YELLOW, getConvertedStr(6,10645))
	self.pBtnJump:onCommonBtnClicked(handler(self, self.onJumpClicked))

	self.pLayDesc = self:findViewByName("lay_desc")
	self.pLbDesc = self:findViewByName("lb_desc")--活动说明

    self.pRichArea = RichText.new()
    self.pRichArea:ignoreContentAdaptWithSize( false )
    self.pRichArea:setContentSize( cc.size(330, 200) )    
    self.pRichArea:setVerticalSpace( 20 )
    self.pRichArea:setPosition(self.pLbDesc:getPositionX(), self.pLbDesc:getPositionY() - self.pLbDesc:getHeight())
    self.pLayDesc:addView( self.pRichArea, 1 )

    centerInView(self.pLayDesc, self.pRichArea)
    local tActData = Player:getRoyaltyCollectData()
	if  tActData then
		self.pRichArea:setString(tActData.sDesc)
	end
    
	self.pLayPrize = self:findViewByName("lay_prize")

	self.pLayRoot = self:findViewByName("lay_bot")
	self.pLayBtn = self:findViewByName("lay_btn")--征收
	self.pBtnGet = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.L_YELLOW, getConvertedStr(6,10644))
	--征收按钮点击事件
	self.pBtnGet:onCommonBtnClicked(handler(self, self.onGetClicked))

	local nY = 225
	local nScale = 0.8
	for i = 1, 5 do
		if not self.tDayBtns[i] then
			local playBtn = self:findViewByName("lay_btn_"..i)
			local pLbTitle = self:findViewByName("lb_title_"..i)
			pLbTitle:setString(string.format(getConvertedStr(6, 10646), tostring(i)))
			self.tDayBtns[i] = self:findViewByName("img_btn_bg_"..i)	
			playBtn:setViewTouched(true)
			playBtn:setIsPressedNeedScale(false)
			playBtn:onMViewClicked(function ()
				self:onDayBtnClicked(i)
			end)

			if not self.pLayRedS[i] then
				local pLayRed = MUI.MLayer.new(true)
				pLayRed:setLayoutSize(26, 26)		
				local nX=playBtn:getWidth()-20
				local nY=playBtn:getHeight()-20
				pLayRed:setPosition(nX,nY)
				playBtn:addView(pLayRed, 100)
				self.pLayRedS[i] = pLayRed
			end	
		end		
	end
	self:onDayBtnClicked(1)
end

--控件刷新
function DlgRoyaltyCollect:updateViews(  )
	-- body	
	-- print("DlgRoyaltyCollect 100")
	local tActData = Player:getRoyaltyCollectData()
	if not tActData then
		return
	end
	-- dump(tActData, "王权征收", 100)
	if tActData:isHavePrize() == true then

		--红点
		for i=1, 5 do 
			if tActData:isCanGetPrize(i) == true and tActData:isHaveGetPrize(i) == false then
				showRedTips(self.pLayRedS[i], 0,1)
			else
				showRedTips(self.pLayRedS[i], 0,0)
			end
		end
	else 		--另外奖励的时候刷新
		for i=1, 5 do 
			showRedTips(self.pLayRedS[i], 0,0)
		end
	end

	if not self.pActTime then
		--活动时间
		self.pActTime = createActTime(self.pLayTop,tActData,cc.p(21,475))
	else
		self.pActTime:setCurData(tActData)
	end

	self:refreshShowInfo()
end

function DlgRoyaltyCollect:onDayBtnClicked( _nDay )
	-- body
	if self.tDayBtns[self.nDayIdx] then
		self.tDayBtns[self.nDayIdx]:setCurrentImage("#v1_btn_biaoqian4.png")
	end
	if self.nDayIdx ~= _nDay then--切换新的天数
		self.nDayIdx = _nDay			
	end
	if self.tDayBtns[self.nDayIdx] then
		self.tDayBtns[self.nDayIdx]:setCurrentImage("#v1_btn_selected_biaoqian4.png")
	end	

	-- showRedTips(self.pLayRedS[self.nDayIdx], 0,0)

	self:refreshShowInfo()
end

function DlgRoyaltyCollect:refreshShowInfo(  )
	-- body
	self:refreshPrizeData()	
	self:updatePrizeList()
	local tActData = Player:getRoyaltyCollectData()
	if not tActData then
		return
	end	
	if (tActData.nId == e_id_activity.newroyaltycollect and tActData.nBy == 0) then
		self.pBtnGet:setBtnEnable(true)
		local tRecharge = getRechargeDataByKey("wangquan12")
		self.pBtnGet:updateBtnText(getRMBStr(tRecharge.price))
		return
	end
	local bGet = tActData:isHaveGetPrize(self.nDayIdx)
	if bGet then
		self.pBtnGet:setBtnEnable(false)
		self.pBtnGet:updateBtnText(getConvertedStr(6, 10647))
	else
		if tActData:isCanGetPrize(self.nDayIdx)  then
			self.pBtnGet:setBtnEnable(true)
			self.pBtnGet:updateBtnText(getConvertedStr(6, 10644))
		else
			self.pBtnGet:setBtnEnable(false)
			self.pBtnGet:updateBtnText(getConvertedStr(6, 10396))
		end
	end
	
end

function DlgRoyaltyCollect:refreshPrizeData(  )
	-- body
	local tActData = Player:getRoyaltyCollectData()
	local tList = {}
	for k, v in pairs(tActData.tConfs) do
		if v.day == self.nDayIdx then
			tList = v.aw
		end
	end
	self.tPrizesDatas = {}
	for k, v in pairs(tList) do
		local pData = getGoodsByTidFromDB(v.k)
		if pData then
			pData.nCt = v.v
			table.insert(self.tPrizesDatas, pData)
		end
	end
end

function DlgRoyaltyCollect:updatePrizeList(  )
	-- body
	local pData = nil
	for i = 1, 4 do 
		pData = self.tPrizesDatas[i]		
		if not self.tPrizeItems[i] then
			local pLayItem = self:findViewByName("lay_item_"..i)
			local pIcon = getIconGoodsByType(pLayItem, TypeIconGoods.HADMORE, type_icongoods_show.itemnum, pData, TypeIconGoodsSize.M)
			pIcon:setDiscount(getConvertedStr(6, 10657), 18)
			self.tPrizeItems[i] = pIcon
		else
			self.tPrizeItems[i]:setCurData(pData)
		end	
	end	
end

--析构方法
function DlgRoyaltyCollect:onDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgRoyaltyCollect:regMsgs(  )
	-- body
	--活动数据刷新
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))	
end
--注销消息
function DlgRoyaltyCollect:unregMsgs(  )
	-- body
	--注销活动数据刷新
	unregMsg(self, gud_refresh_activity)
end

--暂停方法
function DlgRoyaltyCollect:onPause( )
	-- body
	self:unregMsgs()	
end

--继续方法
function DlgRoyaltyCollect:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

function DlgRoyaltyCollect:onJumpClicked(  )
	-- body
	--前往充值界面
	local tObject = {
	    nType = e_dlg_index.dlgrecharge, --dlg类型
	}
	sendMsg(ghd_show_dlg_by_type, tObject)	
	self:closeDlg(false)
end

function DlgRoyaltyCollect:onGetClicked(  )
	-- body
	local tActData = Player:getRoyaltyCollectData()
	if (tActData.nId == e_id_activity.newroyaltycollect)then	--新征收没有购买的情况下	
		if tActData.nBy == 0 then
			local tRecharge = getRechargeDataByKey("wangquan12")	
			-- dump(tRecharge, "tRecharge", 100)	
			reqRecharge( tRecharge )
		else
			SocketManager:sendMsg("reqnewroyaltycollect", {self.nDayIdx}, handler(self, self.onGetFunc)) 		
		end
	else
		SocketManager:sendMsg("reqroyaltycollect", {self.nDayIdx}, handler(self, self.onGetFunc)) 	
	end	
end

function DlgRoyaltyCollect:onGetFunc( __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		showGetAllItems(__msg.body.ob)
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))		
	end	
end
return DlgRoyaltyCollect