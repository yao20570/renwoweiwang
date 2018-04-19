-- DlgCountryTnolyDetail.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-04-08 10:13:23 星期日
-- Description: 国家科技详情
-----------------------------------------------------

local DlgCommon = require("app.common.dialog.DlgCommon")
local MImgLabel = require("app.common.button.MImgLabel")
-- local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local CountryTnolyProgress = require("app.layer.newcountry.newcountrytnoly.CountryTnolyProgress")

local DlgCountryTnolyDetail = class("DlgCountryTnolyDetail", function()
	-- body
	return DlgCommon.new(e_dlg_index.dlgcountrytnolydetail)
end)

--_bIsFull: 该科技是否已满级
function DlgCountryTnolyDetail:ctor(tData)
	-- body
	self.tData = tData
	self.bIsFull = self.tData:getIsMaxLv()
	if self.bIsFull then
		parseView("lay_coun_tnoly_info_max", handler(self, self.onParseViewCallback))
	else
		parseView("lay_coun_tnoly_info", handler(self, self.onParseViewCallback))
	end
end


--解析布局回调事件
function DlgCountryTnolyDetail:onParseViewCallback( pView )
	-- body
	self.pView = pView
	--如果科技已满, 重置窗口大小
	if self.bIsFull then
		self:setBottomHeight(70)
		self:addContentView(pView, false, 400) --加入内容层
	else
		self:setBottomHeight(180)
		-- self:setContentHeight(350)
		self:addContentView(pView, true) --加入内容层
	end

	--设置标题
	self:setTitle(self.tData.sName)

	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgCountryTnolyDetail",handler(self, self.onDlgCountryTnolyDetailDestroy))
end

--初始化控件
function DlgCountryTnolyDetail:setupViews()
	-- body
	--
	self.pLayMain = self:findViewByName("main")
	--科技图标层
	self.pLayIcon = self:findViewByName("lay_icon")
	--科技描述
	local pLbDesc = self:findViewByName("lb_desc")
	self.pLbDesc = MUI.MLabel.new(
		{
			text = "",
			size = 20,
			anchorpoint = cc.p(0, 0.5), 
			dimensions = cc.size(370, 0)
		}
	)
	self.pLayMain:addView(self.pLbDesc, 10)
	self.pLbDesc:setPosition(pLbDesc:getPosition())
	-- setTextCCColor(self.pLbDesc, _cc.pwhite)

	--科技效果层背景
	-- self.pImgBgEffect 	= self:findViewByName("img_effect_bg")

	-- --进度条层
	-- self.pLayBar = self:findViewByName("lay_bar")
	-- self.pBar = MCommonProgressBar.new({bg = "v1_bar_b1.png", bar = "v1_bar_blue_3a.png", barWidth = 212, barHeight = 20})
	-- self.pLayBar:addView(self.pBar)
	-- centerInView(self.pLayBar, self.pBar)
	-- --进度条文本
	-- self.pLbProgress = self:findViewByName("lb_progress")
	--当前等级效果
	self.pLbCurEff 	= self:findViewByName("lb_cur_effect")
	if not self.bIsFull then
		--下一等级效果
		self.pLbNextEff = self:findViewByName("lb_next_effect")
		--捐献获得奖励
		self.pLbDonate = self:findViewByName("lb_donate")
		self.pLbDonate:setString(getConvertedStr(7, 10424))
		setTextCCColor(self.pLbDonate, _cc.pwhite)

		self.pBtnL = self:getLeftButton()
		self.pBtnR = self:getRightButton()
		self.pLayLeft:setPositionY(30)
		self.pLayRight:setPositionY(30)
		self:setLeftBtnText(getConvertedStr(7, 10427)) --黄金捐献
		self:setRightBtnText(getConvertedStr(7, 10428)) --资源捐献
		self:setLeftBtnType(TypeCommonBtn.L_YELLOW)
		self:setLeftHandler(handler(self, self.onGoldDonate))
		self:setRightHandler(handler(self, self.onResDonate))

		local nNeedPalaceLv = tonumber(getCountryParam("goldOpen"))
		local pPalacedata = Player:getBuildData():getBuildById(e_build_ids.palace)--王宫数据
		local bIsOpen = pPalacedata.nLv >= nNeedPalaceLv
		self:setLeftBtnEnabled(bIsOpen)
		if not bIsOpen then
			self.pLbNotOpen = MUI.MLabel.new({text = string.format(getConvertedStr(7, 10429), nNeedPalaceLv),size = 18})
			self.pLayBottom:addView(self.pLbNotOpen, 10)
			self.pLbNotOpen:setPosition(self.pLayLeft:getPositionX()+self.pLayLeft:getWidth()/2, 30)
			setTextCCColor(self.pLbNotOpen, _cc.pwhite)
		end
		--捐献次数
		self.pLbDonateTimes = MUI.MLabel.new({text = "", size = 18})
		self.pLayBottom:addView(self.pLbDonateTimes, 10)
		self.pLbDonateTimes:setPosition(self.pLayRight:getPositionX()+self.pLayRight:getWidth()/2, 30)
		setTextCCColor(self.pLbDonateTimes, _cc.pwhite)
		--黄金消耗
		self.pImgLbLeft = MImgLabel.new({text="", size = 18, parent = self.pLayBottom})
		self.pImgLbLeft:setImg(getCostResImg(e_type_resdata.money), 1, "left")
		self.pImgLbLeft:followPos("center", self.pLayLeft:getPositionX()+self.pLayLeft:getWidth()/2, 
			self.pLayLeft:getPositionY()+self.pLayLeft:getHeight() + 5, 5)
		--资源消耗
		self.pImgLbRight = MImgLabel.new({text="", size = 18, parent = self.pLayBottom})
		self.pImgLbRight:setImg(getCostResImg(self.tData.nCostType), 1, "left")
		self.pImgLbRight:followPos("center", self.pLayRight:getPositionX()+self.pLayRight:getWidth()/2,
			self.pLayRight:getPositionY()+self.pLayRight:getHeight()+5, 5)
		setTextCCColor(self.pImgLbRight, _cc.blue)
		--恢复次数文本
		self.pLbRecover = MUI.MLabel.new({text = "", size = 18})
		self.pLayBottom:addView(self.pLbRecover, 10)
		self.pLbRecover:setPosition(self.pLayBottom:getWidth()/2, 160)
	end

	--升级进度信息层
	self.pLayProgress = CountryTnolyProgress.new()
	self.pLayMain:addView(self.pLayProgress, 10)
	if self.bIsFull then
		self.pLayProgress:setPosition(150, 88)
	else
		self.pLayProgress:setPosition(150, 157)
	end
end

--黄金捐献
function DlgCountryTnolyDetail:onGoldDonate(pView)
	-- body
	if Player:getPlayerInfo().nMoney < self.nNeedCostGold then
		local tObject = {}
		tObject.nType = e_dlg_index.dlgrechargetip --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)
		return
	end
	--请求捐献
	SocketManager:sendMsg("reqTnolyDonate", {self.tData.nId, 1})
end

--资源捐献
function DlgCountryTnolyDetail:onResDonate(pView)
	-- body
	local nLeftDonate = Player:getCountryTnoly().nLeftDonate
	if nLeftDonate <= 0 then
		return
	end
	if self.nCostRes > getMyGoodsCnt(self.tData.nCostType) then
		TOAST(getConvertedStr(7, 10432))
		-- goToBuyRes(self.tData.nCostType)
		return
	end
	--请求捐献
	SocketManager:sendMsg("reqTnolyDonate", {self.tData.nId, 0}, function()
		-- body
		unregUpdateControl(self)
		regUpdateControl(self, handler(self, self.updateCd))
	end)
end

function DlgCountryTnolyDetail:updateViews()
	-- body
	self.bIsFull = self.tData:getIsMaxLv()
	if not self.pIcon then
		local tData = self.tData
		self.pIcon = getIconGoodsByType(self.pLayIcon,TypeIconGoods.NORMAL,type_icongoods_show.item,tData)
		--隐藏品质特效
		self.pIcon:setIsShowBgQualityTx(false)
	end
	--描述
	self.pLbDesc:setString(self.tData.sDesc)

	--刷新升级进度
	self.pLayProgress:updateData(self.tData)
	
	if self.bIsFull then
		-- self.pImgBgEffect:setVisible(false)
		if self.pImgLabel then
			self.pImgLabel:setString("")
			self.pImgLabel:hideImg()
		end
		-- self.pLbDonate:setVisible(false)
		-- self.pLbProgress:setString(getConvertedStr(7, 10349))
		-- setTextCCColor(self.pLbProgress, _cc.white)
		-- self.pBar:setPercent(100)
		--下一等级效果
		-- self.pLbNextEff:setString("")
	else
		if not self.pImgLabel then
			self.pImgLabel = MImgLabel.new({text="", size = 20, parent = self.pLayMain})
			self.pImgLabel:setImg(getCostResImg(e_type_resdata.countrycoin), 0.35, "left")
			self.pImgLabel:followPos("left", self.pLbDonate:getPositionX()+self.pLbDonate:getWidth()+20, self.pLbDonate:getPositionY(), 5)
			setTextCCColor(self.pImgLabel, _cc.yellow)
		end
		self.pImgLabel:showImg()
		self.pLbDonate:setVisible(true)
		--获取捐献消耗量和获得的贡献量
		local nCost, nGot = Player:getCountryTnoly():getDonateCostAndAwards()
		self.pImgLabel:setString(formatCountToStr(nGot))
		self.nCostRes = nCost

		-- local nTotalExp = self.tData:getNextLvNeedExp()
		-- local str = {
		-- 	{text = self.tData.nExp, color = _cc.yellow},
		-- 	{text = "/"..nTotalExp, color = _cc.white}
		-- }
		-- self.pLbProgress:setString(str)
		-- self.pBar:setPercent((self.tData.nExp/nTotalExp)*100)
		local tBuffData = self.tData:getBuffByLv(self.tData.nLevel, self.tData.nSection+1)
		if tBuffData then
			local str = {
				{text = getConvertedStr(7, 10426), color = _cc.pwhite}, --下一等级效果：
				{text = tBuffData.sDesc, color = _cc.white},
			}
			self.pLbNextEff:setString(str)
		end
		--捐献次数
		local nDonateLimit = tonumber(getCountryParam("donateLimit"))
		local nLeftDonate = Player:getCountryTnoly().nLeftDonate
		if self.pLbDonateTimes then
			local str = {
				{text = getConvertedStr(7, 10430)},
				{text = nLeftDonate},
				{text = "/"..nDonateLimit}
			}
			self.pLbDonateTimes:setString(str)
		end
		self:setRightBtnEnabled(nLeftDonate > 0)
		--黄金捐献
		local nCostGold = tonumber(getCountryParam("goldNum"))
		self.nNeedCostGold = (Player:getCountryTnoly().nGoldDonate + 1)*nCostGold
		self.pImgLbLeft:setString(self.nNeedCostGold)
		if Player:getPlayerInfo().nMoney < self.nNeedCostGold then
			setTextCCColor(self.pImgLbLeft, _cc.red)
		else
			setTextCCColor(self.pImgLbLeft, _cc.blue)
		end
		--资源捐献
		self.pImgLbRight:setString(formatCountToStr(self.nCostRes))
		if getMyGoodsCnt(self.tData.nCostType) < self.nCostRes then
			setTextCCColor(self.pImgLbRight, _cc.red)
		else
			setTextCCColor(self.pImgLbRight, _cc.blue)
		end
	end
	--当前等级效果
	local sCurDesc = getConvertedStr(7, 10453) --无
	local sColor = _cc.pwhite
	local tBuffData = self.tData:getBuffByLv(self.tData.nLevel, self.tData.nSection)
	if tBuffData then
		sCurDesc = tBuffData.sDesc
		sColor = _cc.green
	end
	local str = {
		{text = getConvertedStr(7, 10425), color = _cc.pwhite}, --当前等级效果：
		{text = sCurDesc, color = sColor},
	}
	self.pLbCurEff:setString(str)
end

--每秒进来一次 
function DlgCountryTnolyDetail:updateCd(  )
	--剩余恢复时间
	local nCd = Player:getCountryTnoly():getRecoverDonateLeftTime()
	if nCd and nCd > 0 then
		if self.pLbRecover then
			self.pLbRecover:setString(formatTimeToHms(nCd)..getConvertedStr(7, 10431))
			self.pLbRecover:setVisible(true)
		end
	else
		if self.pLbRecover then
			self.pLbRecover:setVisible(false)
		end
	end
end

function DlgCountryTnolyDetail:refreshView()
	local bIsFull = self.tData:getIsMaxLv()
	if bIsFull then
		local tObject = {}
		tObject.nType = e_dlg_index.dlgcountrytnolydetail --dlg类型
		tObject.tData = getCountryTnoly(self.tData.nId)
		self:closeCommonDlg()
		sendMsg(ghd_show_dlg_by_type,tObject)
	else
		self:updateViews()
	end
end

-- 析构方法
function DlgCountryTnolyDetail:onDlgCountryTnolyDetailDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgCountryTnolyDetail:regMsgs(  )
	-- body
	regUpdateControl(self, handler(self, self.updateCd))
	-- 注册国家科技刷新消息
	regMsg(self, gud_refresh_country_tnoly, handler(self, self.refreshView))
end
--注销消息
function DlgCountryTnolyDetail:unregMsgs(  )
	-- body
	unregUpdateControl(self)
	-- 销毁国家科技刷新消息
	unregMsg(self, gud_refresh_country_tnoly)
end

-- 暂停方法
function DlgCountryTnolyDetail:onPause()
	self:unregMsgs()	
end

--继续方法
function DlgCountryTnolyDetail:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

return DlgCountryTnolyDetail