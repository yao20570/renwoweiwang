-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-06-9 11:57:24 星期五
-- Description: 国家开发
-----------------------------------------------------
local DlgCommon = require("app.common.dialog.DlgCommon")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")

local DlgCountryDevelop = class("DlgCountryDevelop", function()
	-- body
	return DlgCommon.new(e_dlg_index.dlgcountrydevelop)
end)

function DlgCountryDevelop:ctor(  )
	-- body
	self:myInit()
	parseView("dlg_country_develop", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgCountryDevelop:myInit(  )
	-- body
	self.bIsCanSend = true
	self.bTimeEnough = true
end

--解析布局回调事件
function DlgCountryDevelop:onParseViewCallback( pView )
	-- body
	self:addContentView(pView,true) --加入内容层
	
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgCountryDevelop",handler(self, self.onDlgCountryDevelopDestroy))
end

--初始化控件
function DlgCountryDevelop:setupViews( )
	-- body
	self:setTitle(getConvertedStr(6, 10213))
	self.pLayTop = self:findViewByName("lay_top")
	-- self.pImgQizhi = self:findViewByName("img_qizhi")	
	self.tLbTipGroup = {}	
	for i = 1, 4 do
		local plable = self:findViewByName("lb_tip_"..i)
		setTextCCColor(plable, _cc.pwhite)
		self.tLbTipGroup[i] = plable
	end
	self.tLbTipGroup[1]:setString(getConvertedStr(6, 10305), false)
	self.tLbTipGroup[2]:setString(getConvertedStr(6, 10383), false)
	self.tLbTipGroup[4]:setString(getConvertedStr(6, 10307), false)
	-- self.tLbTipGroup[5]:setString(getConvertedStr(6, 10384), false)

	-- self.pLbCountryExp = self:findViewByName("lb_country_exp")
	-- setTextCCColor(self.pLbCountryExp, _cc.green)
	-- self.pLbCountryExp:setString("0", false)

	-- self.pLbTargetExp = self:findViewByName("lb_target_exp")
	-- setTextCCColor(self.pLbTargetExp, _cc.pwhite)
	-- self.pLbTargetExp:setString("0", false)

	self.pLbLv = self:findViewByName("lb_lv")
	setTextCCColor(self.pLbLv, _cc.green)
	self.pLbLv:setString(getLvString(0), false)

	self.pLayBar = self:findViewByName("lay_bar_bg")
	self.pProgressBar = MCommonProgressBar.new({bar = "v1_bar_yellow_10.png",barWidth = 422, barHeight = 18})
	self.pLayBar:addView(self.pProgressBar, 10)
	centerInView(self.pLayBar, self.pProgressBar)

	self.pLayCenter = self:findViewByName("lay_center")
	-- self.pLayTitle1 = self:findViewByName("lat_title_1")
	self.pLbTitle1 = self:findViewByName("lb_title_1")
	self.pLbTitle1:setString(getConvertedStr(6, 10378))
	-- self.pLayTitle2 = self:findViewByName("lat_title_2")
	self.pLbTitle2 = self:findViewByName("lb_title_2")
	self.pLbTitle2:setString(getConvertedStr(6, 10379))

	self.tGroupRes = {}
	for i = 1, 4 do
		local img = self:findViewByName("img_res_"..i)
		img:setScale(0.3, 0.3)
		local curresnum = self:findViewByName("lb_res_num_"..i)
		local targetnum = self:findViewByName("lb_res_target_num_"..i)
		local ttable = {img, curresnum, targetnum}
		self.tGroupRes[i] = ttable
	end
--	dump(self.tGroupRes, "self.tGroupRes", 100)
	self.tGroupPrize = {}
	for i = 1, 2 do
		local imgprize = self:findViewByName("img_prize_"..i)
		imgprize:setScale(0.3, 0.3)
		local name = self:findViewByName("lb_prize_"..i)
		setTextCCColor(name, _cc.pwhite)		
		local ttable = {imgprize, name}
		self.tGroupPrize[i] = ttable
	end

	-- self.pLbCurdevelop = self:findViewByName("lb_curdevelop")
	-- self.pLbTotal = self:findViewByName("lb_totaldevelop")
	-- self.pLbTotal:setVisible(false)
	-- self.pLbCurdevelop:setVisible(false)
	--
	self:setOnlyConfirm(getConvertedStr(6, 10440))
	self.pBtn = self:getRightButton( )
	self:setOnlyConfirmBtn(TypeCommonBtn.L_BLUE)
	
	--文本
	local tLLabel = {
			{getConvertedStr(6, 10384),getC3B(_cc.pwhite)},
			{0,getC3B(_cc.blue)},
			{"/",getC3B(_cc.pwhite)},
			{1,getC3B(_cc.pwhite)},

		}
	local tBtnLTable = {}

	tBtnLTable.tLabel = tLLabel
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))
	self.pLExText =  self.pBtn:setBtnExText(tBtnLTable)


	-- self.pLbCurdevelop:setString(tCountryDatavo.nExploit, false)
	-- setTextCCColor(self.pLbCurdevelop, _cc.blue)
	-- self.pLbTotal:setString("/"..table.nums(tdevelop), false)
end

-- 修改控件内容或者是刷新控件数据
function DlgCountryDevelop:updateViews(  )
	-- body
	-- self.pImgQizhi:setCurrentImage(getBigCountryFlagImg2(Player:getPlayerInfo().nInfluence))
	local tCountryDatavo = Player:getCountryData():getCountryDataVo()
	self.pLbLv:setString(tCountryDatavo.nCLv, false)
	local tCountryExp = getCountryExpFromDB()
	local tExpData = tCountryExp[tCountryDatavo.nCLv]
	local str4 = {
		{color=_cc.pwhite,text=getConvertedStr(6, 10307)},
		{color=_cc.pwhite,text=tCountryDatavo.nCExp},
		{color=_cc.pwhite,text="/"..tExpData.exp},
	}
	self.tLbTipGroup[4]:setString(str4, false)
	-- self.pLbCountryExp:setString(tCountryDatavo.nCExp, false)
	-- self.pLbCountryExp:setPositionX(self.tLbTipGroup[4]:getPositionX() + self.tLbTipGroup[4]:getWidth())
	
	--self.pLbTargetExp:setString(, false)		
	--self.pLbTargetExp:setPositionX(self.pLbCountryExp:getPositionX() + self.pLbCountryExp:getWidth())
	if tCountryDatavo.nCLv < #tCountryExp then
		self.tLbTipGroup[2]:setVisible(true)
		self.tLbTipGroup[2]:setString(getConvertedStr(6, 10383))
		self.tLbTipGroup[3]:setVisible(true)
		self.tLbTipGroup[3]:setString(tCountryExp[tCountryDatavo.nCLv+1].info, false)	
		self.tLbTipGroup[4]:setVisible(true)
		self.pLayBar:setVisible(true)				
	else
		self.tLbTipGroup[2]:setVisible(true)
		self.tLbTipGroup[2]:setString(getConvertedStr(6, 10446))
		self.tLbTipGroup[3]:setVisible(false)
		self.tLbTipGroup[4]:setVisible(false)				
		self.pLayBar:setVisible(false)
	end
	local prece = (tonumber(tCountryDatavo.nCExp)/tonumber(tCountryExp[tCountryDatavo.nCLv].exp))*100
	self.pProgressBar:setPercent(prece)

	local tdevelop = getCountryDevelop()
	if tCountryDatavo.nExploit < table.nums(tdevelop) then
		self.bTimeEnough = true
		self.pBtn:setBtnEnable(true)
	else
		--今日国家开发次数已经用完
		TOAST(getConvertedStr(6, 10444))
		self.bTimeEnough = false
		self.pBtn:setBtnEnable(false)
		closeDlgByType(e_dlg_index.dlgcountrydevelop)
		return
	end
	local tcost = luaSplit(tdevelop[tCountryDatavo.nExploit + 1].cost,";")	
	self.bIsCanSend = true
	for i = 1, 4 do
		if tcost[i] then
			self.tGroupRes[i][1]:setVisible(true)
			self.tGroupRes[i][2]:setVisible(true)
			self.tGroupRes[i][3]:setVisible(true)
			local ttmp = luaSplit(tcost[i], ":")
			--dump(ttmp, "ttmp", 10)
			local id = tonumber(ttmp[1])		
			local num = tonumber(ttmp[2])			
			local tgood = getGoodsByTidFromDB(id)
			self.tGroupRes[i][1]:setCurrentImage(tgood.sIcon)
			if num > 0 then
				self.tGroupRes[i][3]:setString("/"..formatCountToStr(num), false)
				self.tGroupRes[i][2]:setString(formatCountToStr(getMyGoodsCnt(id)), false)
			else
				self.tGroupRes[i][3]:setString(getConvertedStr(6, 10319), false)
				self.tGroupRes[i][2]:setString("", false)
			end
			self.tGroupRes[i][2]:setPositionX(self.tGroupRes[i][1]:getPositionX() +self.tGroupRes[i][1]:getWidth()/2)
			self.tGroupRes[i][3]:setPositionX(self.tGroupRes[i][2]:getPositionX() +self.tGroupRes[i][2]:getWidth())
			if num < getMyGoodsCnt(id) then
				setTextCCColor(self.tGroupRes[i][2], _cc.green)
				setTextCCColor(self.tGroupRes[i][3], _cc.pwhite)
			else				
				setTextCCColor(self.tGroupRes[i][2], _cc.red)
				setTextCCColor(self.tGroupRes[i][3], _cc.pwhite)
				self.bIsCanSend = false
			end
		else			
			self.tGroupRes[i][1]:setVisible(false)
			self.tGroupRes[i][2]:setVisible(false)
			self.tGroupRes[i][3]:setVisible(false)
		end
	end	
	--国家经验
	--dump(tdevelop, "tdevelop", 100)
	local pexp  = getGoodsByTidFromDB(e_type_resdata.exp)
	self.tGroupPrize[1][1]:setCurrentImage(pexp.sIcon)
	local str1 = {
		{color = _cc.pwhite, text= getConvertedStr(6, 10381)},
		{color = _cc.blue, text= "*"..formatCountToStr(tdevelop[tCountryDatavo.nExploit + 1].exp)}
	}
	self.tGroupPrize[1][2]:setString(str1, false)
	-- self.tGroupPrize[1][2]:setString(pexp.sName, false)
	-- self.tGroupPrize[1][3]:setString("*"..formatCountToStr(tdevelop[tCountryDatavo.nExploit + 1].exp), false)
	--主公威望	
	local tobtain = luaSplit(tdevelop[tCountryDatavo.nExploit + 1].obtain, ":")
	--dump(tobtain, "tobtain", 100)
	local pRes = getGoodsByTidFromDB(tobtain[1])
	self.tGroupPrize[2][1]:setCurrentImage(pRes.sIcon)
	local str1 = {
		{color = _cc.pwhite, text= pRes.sName},
		{color = _cc.blue, text="*"..tobtain[2]}
	}
	self.tGroupPrize[2][2]:setString(str1, false)
	-- self.tGroupPrize[2][2]:setString(pRes.sName, false)
	-- self.tGroupPrize[2][3]:setString("*"..tobtain[2], false)
	-- self.pLbCurdevelop:setString(tCountryDatavo.nExploit, false)
	-- setTextCCColor(self.pLbCurdevelop, _cc.blue)
	-- self.pLbTotal:setString("/"..table.nums(tdevelop), false)
	-- self.pLbTotal:setPositionX(self.pLbCurdevelop:getPositionX() + self.pLbCurdevelop:getWidth())
	
	self.pLExText:setLabelCnCr(2,tCountryDatavo.nExploit)
	self.pLExText:setLabelCnCr(4,table.nums(tdevelop))
end

-- 析构方法
function DlgCountryDevelop:onDlgCountryDevelopDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgCountryDevelop:regMsgs( )
	-- body
	regMsg(self, gud_refresh_country_msg, handler(self, self.updateViews))	
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateViews))
end

-- 注销消息
function DlgCountryDevelop:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_country_msg)
	unregMsg(self, gud_refresh_playerinfo)
end


--暂停方法
function DlgCountryDevelop:onPause( )
	-- body
	self:unregMsgs()
end

--继续方法
function DlgCountryDevelop:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--按钮回调
function DlgCountryDevelop:onBtnClicked( pview )
	-- body	
	if self.bTimeEnough == true then
		SocketManager:sendMsg("stateDevelopmen", {},handler(self, self.onStateDevelopmen))	
	else
		if self.bIsCanSend == false then
			--TOAST(getConvertedStr(6, 10441))--资源不足		
		end
		if self.bTimeEnough == false then
			TOAST(getConvertedStr(6, 10442))--国家开发次数不足
		end		
	end
end

function DlgCountryDevelop:onStateDevelopmen(__msg )
	-- body
		-- body
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.stateDevelopmen.id then
        	TOAST(getConvertedStr(6, 10443))--开发成功
        end
    else
    	local nResID = nil
		if __msg.head.state == 233 then --银币不足
			nResID = e_resdata_ids.yb
		elseif __msg.head.state == 231 then--木材不足
			nResID = e_resdata_ids.mc
		elseif __msg.head.state == 232 then--粮草不足
			nResID = e_resdata_ids.lc
		elseif __msg.head.state == 230 then--铁矿不足			
			nResID = e_resdata_ids.bt
		else
			TOAST(SocketManager:getErrorStr(__msg.head.state))	
			return	
		end
		if nResID then
			goToBuyRes(nResID)
		end
    end	
end
return DlgCountryDevelop