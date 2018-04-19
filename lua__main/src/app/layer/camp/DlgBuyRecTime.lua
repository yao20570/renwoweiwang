-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-05-08 10:04:17 星期一
-- Description: 募兵加时购买对话框
-----------------------------------------------------
local DlgAlert = require("app.common.dialog.DlgAlert")
local MBtnExText = require("app.common.button.MBtnExText")


local DlgBuyRecTime = class("DlgBuyRecTime", function ()
	return DlgAlert.new(e_dlg_index.buyrectime)
end)

--构造
function DlgBuyRecTime:ctor()
	-- body
	self:myInit()
	parseView("dlg_buy_rec_time", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgBuyRecTime:myInit()
	-- body
	self.tCurData = nil --当前数据
end
  
--解析布局回调事件
function DlgBuyRecTime:onParseViewCallback( pView )
	-- body
	
	self:addContentView(pView, true)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgBuyRecTime",handler(self, self.onDlgBuyRecTimeDestroy))
end

--初始化控件
function DlgBuyRecTime:setupViews()
	-- body
	--设置背景透明
	self:setContentBgTransparent()
	--设置标题
	self:setTitle(getConvertedStr(1,10150))

	--初始值
	self.pLbSParam1 		= 		self:findViewByName("lb_s_p1")
	setTextCCColor(self.pLbSParam1, _cc.blue)
	self.pLbSParam2 		= 		self:findViewByName("lb_s_p2")
	setTextCCColor(self.pLbSParam2, _cc.blue)

	--扩展后
	self.pLbEParam1 		= 		self:findViewByName("lb_e_p1")
	setTextCCColor(self.pLbEParam1, _cc.green)
	self.pLbEParam2 		= 		self:findViewByName("lb_e_p2")
	setTextCCColor(self.pLbEParam2, _cc.green)

	--几级解锁
	self.pLbUnLock 				= 		self:findViewByName("lb_tips")
	setTextCCColor( self.pLbUnLock, _cc.red)

	--国际化文字
	local pLbText 			= 		self:findViewByName("lb_s_tips1")
	setTextCCColor( pLbText, _cc.pwhite)
	pLbText:setString(getConvertedStr(1, 10154))
	pLbText 				= 		self:findViewByName("lb_s_tips2")
	setTextCCColor( pLbText, _cc.pwhite)
	pLbText:setString(getConvertedStr(1, 10155))
	pLbText 				= 		self:findViewByName("lb_tips_main")
	setTextCCColor( pLbText, _cc.pwhite)
	pLbText:setString(getConvertedStr(1, 10152))


	--设置只有一个按钮
	self:setOnlyConfirm(getConvertedStr(1, 10151))
	self:setOnlyConfirmBtn(TypeCommonBtn.L_YELLOW)

	--额外信息
	local tBtnTable = {}
	tBtnTable.parent = self.pBtnRight
	tBtnTable.img = "#v1_img_tongqian.png"
	--文本
	tBtnTable.tLabel = {
		{"0",getC3B(_cc.blue)},
		{"/",getC3B(_cc.pwhite)},
		{0,getC3B(_cc.pwhite)}
	}
	tBtnTable.awayH = 0
	self.pBtnExTextGold = MBtnExText.new(tBtnTable)

	
end

-- 修改控件内容或者是刷新控件数据
function DlgBuyRecTime:updateViews()
	-- body

	if self.tCurData then
		local nSpeed = tonumber(getBuildParam("baseRecruitSpeed"))
		--原始
		local nH,nM = self:getHourAndMinutes(self.tCurData.nRecruitMaxTime)
		if nH > 0 then
			if  nM > 0 then
				self.pLbSParam1:setString(nH .. getConvertedStr(8, 10018)..nM.. getConvertedStr(1, 10156))
			else
				self.pLbSParam1:setString(nH .. getConvertedStr(8, 10018))
			end
			
		else
			self.pLbSParam1:setString(self.tCurData.nRecruitMaxTime .. getConvertedStr(1, 10156))
		end
		
		local nNum = self.tCurData:getRefreshNumByBuffPush(self.tCurData.nRecruitMaxTime * nSpeed)
		self.pLbSParam2:setString("" .. nNum)
		--上升后
		local tNaxt = getRecruitByQueueFromDB(self.tCurData.nRecruitMore + 1)
		local nCost = 0 

		if tNaxt then
			local nNaxtNum =self.tCurData:getRefreshNumByBuffPush(tonumber(tNaxt.recruittime) * nSpeed) 
			local nH,nM = self:getHourAndMinutes(tNaxt.recruittime)
			
			if nH > 0 then
				
				if  nM > 0 then
					self.pLbEParam1:setString(nH .. getConvertedStr(8, 10018)..nM.. getConvertedStr(1, 10156))
				else
					self.pLbEParam1:setString(nH .. getConvertedStr(8, 10018))
				end
			else
				self.pLbEParam1:setString(tNaxt.recruittime .. getConvertedStr(1, 10156))
			end
			
			self.pLbEParam2:setString(nNaxtNum)			
			nCost = tonumber(tNaxt.coin or 0)
		end

		--是否可以延长
		if Player:getPlayerInfo().nLv >= tonumber(getBuildParam("recruitLevel")) then
			self:getRightButton():setBtnEnable(true)
			local tStr =luaSplit(getTipsByIndex(20041), ":")			
			self.pLbUnLock:setString(tStr[1] or "")
			setTextCCColor(self.pLbUnLock, tStr[2] or _cc.red)		
		else
			self:getRightButton():setBtnEnable(false)	
			self.pLbUnLock:setString(string.format(getConvertedStr(1, 10153),getBuildParam("recruitLevel")))		
			setTextCCColor(self.pLbUnLock, _cc.red)		
		end		

		--设置铜币消耗
		if tonumber(nCost) > Player:getPlayerInfo().nCoin then
			self.pBtnExTextGold:setLabelCnCr(3,getResourcesStr(nCost))
			self.pBtnExTextGold:setLabelCnCr(1,getResourcesStr(Player:getPlayerInfo().nCoin),getC3B(_cc.red))
		else
			self.pBtnExTextGold:setLabelCnCr(3,getResourcesStr(nCost))
			self.pBtnExTextGold:setLabelCnCr(1,getResourcesStr(Player:getPlayerInfo().nCoin),getC3B(_cc.yellow))
			
		end
		
	end
end



function DlgBuyRecTime:getHourAndMinutes( _nTime  )
	if not _nTime then
		return 0,0
	end
	local nHour = math.floor(_nTime / 60)
	local nMinus = 0
	if nHour >0 then
		nMinus = _nTime - nHour*60  
	else
		nHour = 0
		nMinus = _nTime
	end
	return nHour,nMinus
	
end

--析构方法
function DlgBuyRecTime:onDlgBuyRecTimeDestroy()
	
end

-- 注册消息
function DlgBuyRecTime:regMsgs( )
	-- body
	-- 注册玩家信息变化消息
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateViews))

end

-- 注销消息
function DlgBuyRecTime:unregMsgs(  )
	-- body
	-- 销毁玩家信息变化消息
	unregMsg(self, gud_refresh_playerinfo)
end


--暂停方法
function DlgBuyRecTime:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgBuyRecTime:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

function DlgBuyRecTime:setCurData( _tData )
	-- body
	self.tCurData = _tData
	self:updateViews()
end



return DlgBuyRecTime
