-----------------------------------------------------
-- author: liangzhaowei
-- Date: 2017-06-12 20:25:21
-- Description: 拜将台
-----------------------------------------------------
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local DlgBase = require("app.common.dialog.DlgBase")
local MCommonView = require("app.common.MCommonView")

local DlgBuyHero = class("DlgBuyHero", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function DlgBuyHero:ctor( _tSize )
	self:setContentSize(_tSize)
	self:myInit()
	-- self:setTitle(getConvertedStr(1, 10161))
	parseView("dlg_buy_hero", handler(self, self.onParseViewCallback))
	

	--解析道具购买相关信息
	self:analysisLiangPrice()
	self:analysisShenPrice()

	self:refreshData()

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgBuyHero",handler(self, self.onDestroy))
end

--初始化成员变量
function DlgBuyHero:myInit()
	-- body
	self.tExText = {} --按钮上扩展按钮文字
	self.pData = {} --推演数据
	self.pHeroData = {} --英雄数据

	self.liangOnePrice = 0 --良将一次价格 
	self.liangTenPrice = 0 --良将十次价格
	self.liangItem = {} --良将将令
	self.liangCoin = {} --良将金币
	self.shenOnePrice = 0 --神将一次价格 
	self.shenTenPrice = 0 --神将十次价格
	self.shenItem = {}     --神将将令
	self.shenCoin = {}     --神将金币
	self.liangOneItemNums = 0 --良将一次将令使用个数
	self.liangTenItemNums = 0 --良将十次将令使用个数
	self.shenOneItemNums = 0 --推演一次使用神将令个数
	self.shenTenItemNums = 0  --推演十次使用神将令个数

	self.nLiangItemId = 0 --良将令id
	self.nShenItemId  = 0 --神将令id

	self.nBuyType = 0 --推演类型 为了回调时使用
end

--更新数据
function DlgBuyHero:refreshData()
	self.pData = Player:getHeroInfo():getBuyHeroData()
	self.pHeroData = Player:getHeroInfo()

	if self.nLiangItemId then
		local pItem  = Player:getBagInfo():getItemDataById(self.nLiangItemId)
		if pItem then
			if self.liangItem and self.liangItem.nCt  then
				self.liangItem.nCt = pItem.nCt
			end	
		else
			self.liangItem.nCt = 0
		end
	end
	if self.nShenItemId then
		local pItem  = Player:getBagInfo():getItemDataById(self.nShenItemId)
		if pItem then
			if self.shenItem and self.shenItem.nCt then
				self.shenItem.nCt = pItem.nCt
			end
		else
			self.shenItem.nCt = 0
		end
	end

end

--解析布局回调事件
function DlgBuyHero:onParseViewCallback( pView )
	-- body
	self.pView = pView
	--pView:setContentSize(self:getContentSize())
    --pView:requestLayout()
	self:addView(pView)
	centerInView(self, pView)

end

--初始化控件
function DlgBuyHero:setupViews( )
	--ly
	self.pLyBtnPreview     		= 		self:findViewByName("btn_preview") --预览按钮



	self.pLyBtnUpL     			= 		self:findViewByName("ly_btn_up_l")
	self.pLyBtnUpR     			= 		self:findViewByName("ly_btn_up_r")
	self.pLyLiang     			= 		self:findViewByName("ly_liang")


	self.pLyShen     			= 		self:findViewByName("ly_shen")
	self.pLyPercent     	    = 		self:findViewByName("ly_percent")
	self.pLyBtn     			= 		self:findViewByName("ly_btn")
	self.pLyBtnDnL     			= 		self:findViewByName("ly_btn_dn_l")
	self.pLyBtnDnR     			= 		self:findViewByName("ly_btn_dn_r")


	--8.16没有足够的原画屏蔽
	self.pLyBtnPreview:setVisible(true)
	self.pLyShen:setVisible(true)
	--8.16没有足够的原画屏蔽

	

	--进度条层
	self.pLayBar = self:findViewByName("ly_bar")
	self.pProgressBar = MCommonProgressBar.new({bar = "v1_bar_blue_6.png",barWidth = 560, barHeight = 14})
	self.pLayBar:addView(self.pProgressBar, 10)
	centerInView(self.pLayBar, self.pProgressBar)	

	--img
	self.pImgLiangItem     =       self:findViewByName("img_liang_item")
	if self.liangItem and self.liangItem.sIcon then
		self.pImgLiangItem:setCurrentImage(self.liangItem.sIcon)
	end
	
	self.pImgShenItem      =       self:findViewByName("img_shen_item")
	self.pImgShenItem:setZOrder(1)

	--lb
	self.tLbUp = {}
	for i=1,4 do
		self.tLbUp[i] = self:findViewByName("lb_up_"..i)
		self.tLbUp[i]:setString(getConvertedStr(5, 10148+i-1))
		if i==1 then
			setTextCCColor(self.tLbUp[i], _cc.purple)
		elseif i== 2 then
			self.tLbUp[i]:setString(string.format(getConvertedStr(5, 10148+i-1),10))
		end
	end

	self.tLbDn = {}
	for i=1,4 do
		self.tLbDn[i] = self:findViewByName("lb_dn_"..i)
		self.tLbDn[i]:setString(getConvertedStr(5, 10152+i-1))
		if i==1 then
			setTextCCColor(self.tLbDn[i], _cc.yellow)
		elseif i== 2 then
			self.tLbUp[i]:setString(string.format(getConvertedStr(5, 10148+i-1),10))
		end
	end
	

	--按钮
	self.pBtnPreView = getCommonButtonOfContainer(self.pLyBtnPreview, TypeCommonBtn.L_BLUE, getConvertedStr(5, 10162))
	self.pBtnPreView:onCommonBtnClicked(handler(self, self.onPreViewClicked))

	self.pBtnUpL = getCommonButtonOfContainer(self.pLyBtnUpL, TypeCommonBtn.XL_BLUE, getConvertedStr(5, 10168))
	self.pBtnUpL:onCommonBtnClicked(handler(self, self.onBtnUpLClicked))
	sendMsg(ghd_guide_finger_show_or_hide, true)
	Player:getNewGuideMgr():setNewGuideFinger(self.pBtnUpL, e_guide_finer.buyhero_normal)


	self.pBtnUpR = getCommonButtonOfContainer(self.pLyBtnUpR, TypeCommonBtn.XL_YELLOW, getConvertedStr(5, 10169))
	self.pBtnUpR:onCommonBtnClicked(handler(self, self.onBtnUpRClicked))


	self.pBtnDnL = getCommonButtonOfContainer(self.pLyBtnDnL, TypeCommonBtn.XL_BLUE, getConvertedStr(5, 10168))
	self.pBtnDnL:onCommonBtnClicked(handler(self, self.onBtnDnLClicked))
	self.pBtnDnR = getCommonButtonOfContainer(self.pLyBtnDnR, TypeCommonBtn.XL_YELLOW, getConvertedStr(5, 10169))
	self.pBtnDnR:onCommonBtnClicked(handler(self, self.onBtnDnRClicked))

	-----扩展按钮文字-----
	self:initExBtnText()

	--添加神将推演进度提示
	self:initShenTipsText()


	local tConTable = {}
	--文本
	local tLb= {
		{"",getC3B(_cc.red)},
		{"",getC3B(_cc.yellow)},
	}
	tConTable.tLabel = tLb
	self.pShenText =  createGroupText(tConTable)
	self.pShenText:setAnchorPoint(cc.p(0,0))
	self.pShenText:setPosition(20, 387)
	self.pLyShen:addView(self.pShenText,10)
	
	self:updateCd()
end

--初始化按钮上的文字
function DlgBuyHero:initExBtnText()
	for i=1,4 do
		local tBtnTable = {}
		tBtnTable.img = "#i100091.png"
		--文本
		local tLabel = {
			{"",getC3B(_cc.white)},
			{"",getC3B(_cc.white)},
			{"",getC3B(_cc.red)},
		}
		tBtnTable.tLabel = tLabel
		tBtnTable.fontSize=20
		if i == 1 then
			self.tExText[i] = self.pBtnUpL:setBtnExText(tBtnTable)
		elseif i == 2 then
			self.tExText[i] = self.pBtnUpR:setBtnExText(tBtnTable)
		elseif i == 3 then
			self.tExText[i] = self.pBtnDnL:setBtnExText(tBtnTable)
		elseif i == 4 then
			self.tExText[i] = self.pBtnDnR:setBtnExText(tBtnTable)
		end
		self.tExText[i]:setZOrder(99)
	end
end

--初始化神将推演进度提示
function DlgBuyHero:initShenTipsText()
	--文本
	local tLb= {
		{text = getConvertedStr(5, 10157), color = _cc.yellow},
		{text = getConvertedStr(5, 10158), color = _cc.pwhite},
		{text = getConvertedStr(5, 10159), color = _cc.yellow},
		{text = getConvertedStr(5, 10160), color = _cc.pwhite},
	}
	self.pText = MUI.MLabel.new({text = "", size = 24})
	self.pText:setString(tLb)
	self.pText:setAnchorPoint(cc.p(0.5,0.5))
	self.pLyPercent:addView(self.pText,10)
	self.pText:setPosition(300, 60)
end


-- 修改控件内容或者是刷新控件数据
function DlgBuyHero:updateViews(  )
	if not self.pData then
       return
	end

--良将部分
	--良将剩余推演次数
	if self.pData.fc then
		local nTime = 10-self.pData.fc%10
		self.tLbUp[2]:setString(string.format(getConvertedStr(5, 10149),nTime))
	end



	if self.pHeroData:getFreeBuyLiangCd() <= 0 then --免费

		--良将左边按钮扩展文字
		self.tExText[1]:setImg()--不显示图片
		self.tExText[1]:setLabelCnCr(1,getConvertedStr(5, 10170),getC3B(_cc.white))
		self.tExText[1]:setLabelCnCr(2,"")
		self.tExText[1]:setLabelCnCr(3,"")

		--有道具时提示
		self.pImgLiangItem:setVisible(false)
		self.tLbUp[3]:setVisible(false)
		self.pBtnUpL:setButton(TypeCommonBtn.XL_BLUE)

		if self.liangItem.nCt >= self.liangTenItemNums then --大于十次推演需要将令
			self.tExText[2]:setImg(self.liangItem.sIcon)--显示图片
			self.tExText[2]:setLabelCnCr(1,self.liangItem.nCt,getC3B(_cc.blue))
			self.tExText[2]:setLabelCnCr(2,"/"..self.liangTenItemNums,getC3B(_cc.white))
		else
			--良将推演十次价格
			self.tExText[2]:setImg(getCostResImg(e_type_resdata.money))--显示图片
			-- print("hhhhhh",self.liangCoin.sIcon)
			self.tExText[2]:setLabelCnCr(1,self.liangTenPrice,getC3B(_cc.white))
			self.tExText[2]:setLabelCnCr(2,"")
		end


	else
		self.pBtnUpL:setButton(TypeCommonBtn.XL_YELLOW)
		--如果拥有将令 大于次推演需要将令个数
		if self.liangItem and self.liangItem.nCt then
			if self.liangItem.nCt >= self.liangOneItemNums  then
				self.pImgLiangItem:setVisible(true)
				self.tLbUp[3]:setVisible(true)

				self.tExText[1]:setImg(self.liangItem.sIcon)--显示图片
				self.tExText[1]:setLabelCnCr(1,self.liangItem.nCt,getC3B(_cc.blue))
				self.tExText[1]:setLabelCnCr(2,"/"..self.liangOneItemNums,getC3B(_cc.white))

				if self.liangItem.nCt >= self.liangTenItemNums then --大于十次推演需要将令
					self.tExText[2]:setImg(self.liangItem.sIcon)--显示图片

					self.tExText[2]:setLabelCnCr(1,self.liangItem.nCt,getC3B(_cc.blue))
					self.tExText[2]:setLabelCnCr(2,"/"..self.liangTenItemNums,getC3B(_cc.white))
				else
					--良将推演十次价格
					self.tExText[2]:setImg(getCostResImg(e_type_resdata.money))--显示图片

					self.tExText[2]:setLabelCnCr(1,self.liangTenPrice,getC3B(_cc.white))
					self.tExText[2]:setLabelCnCr(2,"")
				end
			else
				self.pImgLiangItem:setVisible(false)
				self.tLbUp[3]:setVisible(false)

				--良将推演一次价格
				self.tExText[1]:setImg(getCostResImg(e_type_resdata.money))--显示图片

				self.tExText[1]:setLabelCnCr(1,self.liangOnePrice,getC3B(_cc.white))
				self.tExText[1]:setLabelCnCr(2,"")				

				--良将推演十次价格
				self.tExText[2]:setImg(getCostResImg(e_type_resdata.money))--显示图片

				self.tExText[2]:setLabelCnCr(1,self.liangTenPrice,getC3B(_cc.white))
				self.tExText[2]:setLabelCnCr(2,"")

			end

		end

	end


--神将部分	

	if self.pData.gop == 1 then --神将推演是否开启  开启
		self.pLyPercent:setVisible(false)
		self.pLyBtn:setVisible(true)   
		self.pBtnDnL:setBtnEnable(true)
		self.pBtnDnR:setBtnEnable(true) 

		--神将推演次数
		if self.pData.gc then
			local nTime = 10-self.pData.gc%10
			self.tLbDn[2]:setString(string.format(getConvertedStr(5, 10153),nTime))
		end	
	else --神将推演是否开启  关闭 
		--推演进度
		if self.pData.prg then
			self.pProgressBar:setPercent(self.pData.prg)
			self.pProgressBar:setProgressBarText(self.pData.prg.."%")
		end

		--未开封
		self.tLbDn[2]:setString(getConvertedStr(5, 10156))

		self.pLyPercent:setVisible(true)
		self.pLyBtn:setVisible(false)
		self.pBtnDnL:setBtnEnable(false)
		self.pBtnDnR:setBtnEnable(false) 		
	end

	if self.pData.gf == 1 then --免费
		--神将左边按钮扩展文字
		self.tExText[3]:setImg()--不显示图片
		self.tExText[3]:setLabelCnCr(1,getConvertedStr(5, 10170),getC3B(_cc.white))
		self.tExText[3]:setLabelCnCr(2,"")
		self.tExText[3]:setLabelCnCr(3,"")

		--有道具时提示
		self.pImgShenItem:setVisible(false)
		self.tLbDn[3]:setVisible(false)
		self.pBtnDnL:setButton(TypeCommonBtn.XL_BLUE)

		if self.shenItem.nCt >= self.shenTenItemNums then --大于十次推演需要将令
			self.tExText[4]:setImg(self.shenItem.sIcon)--显示图片

			self.tExText[4]:setLabelCnCr(1,self.shenItem.nCt,getC3B(_cc.blue))
			self.tExText[4]:setLabelCnCr(2,"/"..self.shenTenItemNums,getC3B(_cc.white))
		else
			--神将推演十次价格
			self.tExText[4]:setImg(getCostResImg(e_type_resdata.money))--显示图片
			self.tExText[4]:setLabelCnCr(1,self.shenTenPrice,getC3B(_cc.white))
			self.tExText[4]:setLabelCnCr(2,"")
		end


	else
		self.pBtnDnL:setButton(TypeCommonBtn.XL_YELLOW)

		--如果拥有将令 大于次推演需要将令个数
		if self.shenItem and self.shenItem.nCt then
			if self.shenItem.nCt >= self.shenOneItemNums  then
				self.pImgShenItem:setVisible(true)
				self.tLbDn[3]:setVisible(true)

				self.tExText[3]:setImg(self.shenItem.sIcon)--显示图片

				self.tExText[3]:setLabelCnCr(1,self.shenItem.nCt,getC3B(_cc.blue))
				self.tExText[3]:setLabelCnCr(2,"/"..self.shenOneItemNums,getC3B(_cc.white))

				if self.shenItem.nCt >= self.shenTenItemNums then --大于十次推演需要将令
					self.tExText[4]:setImg(self.shenItem.sIcon)--显示图片
					self.tExText[4]:setLabelCnCr(1,self.shenItem.nCt,getC3B(_cc.blue))
					self.tExText[4]:setLabelCnCr(2,"/"..self.shenTenItemNums,getC3B(_cc.white))
				else
					--神将推演十次价格
					self.tExText[4]:setImg(getCostResImg(e_type_resdata.money))--显示图片

					self.tExText[4]:setLabelCnCr(1,self.shenTenPrice,getC3B(_cc.white))
					self.tExText[4]:setLabelCnCr(2,"")
				end
			else
				self.pImgShenItem:setVisible(false)
				self.tLbDn[3]:setVisible(false)

				--神将推演一次价格
				self.tExText[3]:setImg(getCostResImg(e_type_resdata.money))--显示图片

				self.tExText[3]:setLabelCnCr(1,self.shenOnePrice,getC3B(_cc.white))
				self.tExText[3]:setLabelCnCr(2,"")				

				--神将推演十次价格
				self.tExText[4]:setImg(getCostResImg(e_type_resdata.money))--显示图片

				self.tExText[4]:setLabelCnCr(1,self.shenTenPrice,getC3B(_cc.white))
				self.tExText[4]:setLabelCnCr(2,"")

			end
		end
	end

end

--推演预览按钮
function DlgBuyHero:onPreViewClicked(pView)
	-- print("preview")
	local tObject = {} 
	tObject.nType = e_dlg_index.buyheropreview --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)
end

local nDistanceTime = 500 --按钮延时响应(单位毫秒)

--是否在短时间内已经点过一次
function DlgBuyHero:getIsClicking()
	-- body
	if self.nLastClickTime then
		local nCurTime = getSystemTime(false)
		if (nCurTime - self.nLastClickTime) < nDistanceTime then
			return true
		end
	end

	self.nLastClickTime = getSystemTime(false)
	return false
end

--良将推演1次
function DlgBuyHero:onBtnUpLClicked(pView)
	if self:getIsClicking() then
		return
	end
	local nType = 0
	local nItemId = -1 -- 0为"|"左边配置的东西 1"|"右边配置的东西
	if self.pHeroData:getFreeBuyLiangCd()  > 0 then
		nType = 2
		if self.liangItem and self.liangItem.nCt then
			if self.liangItem.nCt >= self.liangOneItemNums  then
				nItemId = 0 --物品
			else
				nItemId = 1 --金币
			end
		else
			nItemId = 1 --金币
		end

	else
		nType = 1  --免费
		nItemId = 1
	end

	if (nType == 0) or (nItemId == -1) then
		return
	end


	if nType == 2 and (nItemId == 1) and (self.pHeroData:getFreeBuyLiangCd() > 0) then
		if Player:getPlayerInfo().nMoney < self.liangOnePrice  then
			self:gotoRecharge()
			return
		end
	end

	-- dump(nType,"nType")
	-- dump(nItemId,"nItemId")
	self.nBuyType = 1
	SocketManager:sendMsg("buyHero", {nType,nItemId,self.nBuyType},handler(self, self.onGetDataFunc))

	Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.buyhero_normal)
end
--良将推演10次
function DlgBuyHero:onBtnUpRClicked(pView)
	if self:getIsClicking() then
		return
	end
	if self.pHeroData:getFreeBuyLiangCd() == 0 then
		TOAST(getConvertedStr(5, 10173))
		return
	end

	local nItemId = -1 -- 0为"|"左边配置的东西 1"|"右边配置的东西


	if self.liangItem and self.liangItem.nCt then
		if self.liangItem.nCt >= self.liangTenItemNums  then
			nItemId = 0 --物品
		else
			nItemId = 1 --金币
		end
	else
		nItemId = 1 --金币
	end	

	if nItemId == 1 then
	    local strTips = {
	    	{color=_cc.pwhite,text=getConvertedStr(5, 10214)},--进行十连推演？
	    }
	    --展示购买对话框
		local pDlg = showBuyDlg(strTips,self.liangTenPrice,function (  )
		    self.nBuyType = 2
			SocketManager:sendMsg("buyHero", {3,nItemId,self.nBuyType},handler(self, self.onGetDataFunc))
		end)
		if pDlg then
			pDlg:setRightBtnText(getConvertedStr(5, 10215))
		end
		return
	end

    if (nItemId == -1) or (not nItemId) then
    	return
    end

    -- dump(nItemId,"nItemId")
    self.nBuyType = 2
	SocketManager:sendMsg("buyHero", {3,nItemId,self.nBuyType},handler(self, self.onGetDataFunc))
	-- print("良将推演10次")
end
-- 神将推演1次
function DlgBuyHero:onBtnDnLClicked(pView)
	if self:getIsClicking() then
		return
	end
	-- print("神将推演1次")

	-- dump(self.shenItem,"self.shenItem")
	local nType = 0
	local nItemId = -1 -- 0为"|"左边配置的东西 1"|"右边配置的东西
	if self.pData.gf == 0 then --不免费
		nType = 5
		if self.shenItem and self.shenItem.nCt then
			if self.shenItem.nCt >= self.shenOneItemNums  then
				nItemId = 0 --物品
			else
				nItemId = 1 --金币
			end
		else
			nItemId = 1 --金币
		end

	else --免费
		nType = 4
		nItemId = 1
	end

	if (nType == 0) or (nItemId == -1) then
		return
	end


	if nType == 5 and self.pData.gf == 0 and nItemId == 1 then
		if Player:getPlayerInfo().nMoney < self.shenOnePrice  then
			self:gotoRecharge()
			return
		end
	end


	-- dump(nType,"nType")
	-- dump(nItemId,"nItemId")
	self.nBuyType = 3
	SocketManager:sendMsg("buyHero", {nType,nItemId,self.nBuyType},handler(self, self.onGetDataFunc))	

end
-- 神将推演10次
function DlgBuyHero:onBtnDnRClicked(pView)
	if self:getIsClicking() then
		return
	end

	if self.pData.gf == 1 then
		TOAST(getConvertedStr(5, 10173))
		return
	end


	local nItemId = -1 -- 0为"|"左边配置的东西 1"|"右边配置的东西

	if self.shenItem and self.shenItem.nCt then
		if self.shenItem.nCt >= self.shenTenItemNums  then
			nItemId = 0
		else
			nItemId = 1
		end
	else
		nItemId = 1
	end	

	if nItemId == 1 then
		-- if Player:getPlayerInfo().nMoney < self.shenTenPrice  then
		-- 	self:gotoRecharge()
		-- 	return
		-- end
	    local strTips = {
	    	{color=_cc.pwhite,text=getConvertedStr(5, 10214)},--进行十连推演？
	    }
	    --展示购买对话框
		local pDlg = showBuyDlg(strTips,self.shenTenPrice,function (  )
		    self.nBuyType = 4
			SocketManager:sendMsg("buyHero", {6,nItemId,self.nBuyType},handler(self, self.onGetDataFunc))
		end)
		if pDlg then
			pDlg:setRightBtnText(getConvertedStr(5, 10215))
		end
		return
	end


	if  (nItemId == -1) or (not nItemId) then
		return
	end

	self.nBuyType = 4
	SocketManager:sendMsg("buyHero", {6,nItemId,self.nBuyType},handler(self, self.onGetDataFunc))	

end

--黄金不足跳转
function DlgBuyHero:gotoRecharge()
	local DlgAlert = require("app.common.dialog.DlgAlert")
    local pDlg, bNew = getDlgByType(e_dlg_index.alert)
    if(not pDlg) then
        pDlg = DlgAlert.new(e_dlg_index.alert)
    end
    pDlg:setTitle(getConvertedStr(3, 10091))
    pDlg:setContent(getConvertedStr(6, 10081))
 	pDlg:setRightHandler(function (  )            
        local tObject = {}
        tObject.nType = e_dlg_index.dlgrecharge --dlg类型
        sendMsg(ghd_show_dlg_by_type,tObject)  
        closeDlgByType(e_dlg_index.alert, false)  
    end)
    pDlg:showDlg(bNew) 
end



--接收服务端发回的登录回调
function DlgBuyHero:onGetDataFunc( __msg, __oldMsg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.buyHero.id then
        	--播放音效
        	Sounds.playEffect(Sounds.Effect.summon)
        	self:refreshData()
        	self:updateViews()

    		--打开获得物品展示
   			if __msg.body.sds then
			    --打开对话框
			    local tObject = {}
			    tObject.nType = e_dlg_index.buyheroshowget --dlg类型
			    tObject.tReward = __msg.body.sds
			    tObject.nPrice = self:getBuyPrice()
			    local pItem
			    if self.nBuyType == 1 or self.nBuyType == 2 then
			    	pItem = Player:getBagInfo():getItemDataById(self.nLiangItemId)
			    elseif self.nBuyType == 3 or self.nBuyType == 4 then
			    	pItem = Player:getBagInfo():getItemDataById(self.nShenItemId)
			    end
			    tObject.nBuyType = __oldMsg[3] --推演类型(1、2是良将推演，3、4是神将推演)
			    tObject.pItem = pItem
			    tObject.nCostItem = self:getBuyItemNums()
			    tObject.pHandler = handler(self, self.onContinueBuy)
			    sendMsg(ghd_show_dlg_by_type,tObject)
   			end
        end
    else
        self.nBuyType = 0
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end


--继续推演回调
function DlgBuyHero:onContinueBuy()
	-- body
	closeDlgByType(e_dlg_index.buyheroshowget, false)

	if self.nBuyType == 1 then
		if self.onBtnUpLClicked then
			self:onBtnUpLClicked()
		end
	elseif self.nBuyType == 2 then
		if self.onBtnUpRClicked then
			self:onBtnUpRClicked()
		end
	elseif self.nBuyType == 3 then
		if self.onBtnDnLClicked then
			self:onBtnDnLClicked()
		end
	elseif self.nBuyType == 4 then
		if self.onBtnDnRClicked then
			self:onBtnDnRClicked()
		end
	end
end

--解析良将道具与购买价格
function DlgBuyHero:analysisLiangPrice()

	local t = luaSplit(getHeroInitData("fineOneCosts"), "|") 
	for k,v in pairs(t) do
		local ts = luaSplit(v, ":")
		if k == 1 then
			self.nLiangItemId = tonumber(ts[1])
			self.liangItem = getGoodsByTidFromDB(self.nLiangItemId) 
			local pItem  = Player:getBagInfo():getItemDataById(self.nLiangItemId)
			if pItem and self.liangItem and self.liangItem.nCt then
				self.liangItem.nCt = pItem.nCt
			end
			self.liangOneItemNums = tonumber(ts[2]) 
		elseif k == 2 then
		 	self.liangCoin = getGoodsByTidFromDB(ts[1]) 
		 	self.liangOnePrice = tonumber(ts[2])  or 0
		end 
	end

	local tTen = luaSplit(getHeroInitData("fineTenCosts"), "|") 
	for k,v in pairs(tTen) do
		local ts = luaSplit(v, ":")
		if k == 1 then
		    self.liangTenItemNums = tonumber(ts[2]) or 0 --良将十次将令使用个数
		elseif k == 2 then
		 	self.liangTenPrice = tonumber(ts[2])  or 0
		end 
	end

end

--解析神将道具与购买价格
function DlgBuyHero:analysisShenPrice()


	local t = luaSplit(getHeroInitData("godOneCosts"), "|") 
	for k,v in pairs(t) do
		local ts = luaSplit(v, ":")
		if k == 1 then
			self.nShenItemId = tonumber(ts[1]) or 0
			self.shenItem = getGoodsByTidFromDB(self.nShenItemId) 
			local pItem  = Player:getBagInfo():getItemDataById(self.nShenItemId)
			if pItem and self.shenItem and self.shenItem.nCt then
				self.shenItem.nCt = pItem.nCt
			end
			self.shenOneItemNums =  tonumber(ts[2]) 
		elseif k == 2 then
		 	self.shenCoin = getGoodsByTidFromDB(ts[1]) 
		 	self.shenOnePrice = tonumber(ts[2])  or 0
		end 
	end

	local tTen = luaSplit(getHeroInitData("godTenCosts"), "|") 
	for k,v in pairs(tTen) do
		local ts = luaSplit(v, ":")
		if k == 1 then
			self.shenTenItemNums = tonumber(ts[2]) 
		elseif k == 2 then
		 	self.shenTenPrice = tonumber(ts[2])  or 0
		end 
	end
end

--更新时间
function DlgBuyHero:updateCd()
	local nTime = self.pHeroData:getFreeBuyLiangCd()
	if nTime > 0 and self.tExText[1] then --免费 --formatTimeToHms(nTime)
		self.tExText[1]:setLabelCnCr(3,string.format(getConvertedStr(5, 10171),formatTimeToHms(nTime)))
	end

	local nLeftTime = self.pHeroData:getLeftCloseLiangCd()
	if nLeftTime > 0 and self.pShenText then
		--以下为刷新内容
		self.pShenText:setLabelCnCr(1,formatTimeToHms(nLeftTime)) 
		self.pShenText:setLabelCnCr(2,getConvertedStr(5, 10184)) 
	else
		self.pShenText:setLabelCnCr(1,"") 
		self.pShenText:setLabelCnCr(2,"") 
	end

end

--根据类型获取价格
function DlgBuyHero:getBuyPrice()
	-- body
	local nPrice = 0

	if self.nBuyType == 1 then
		nPrice = self.liangOnePrice
	elseif self.nBuyType ==2  then
		nPrice = self.liangTenPrice
	elseif self.nBuyType ==3  then
		nPrice = self.shenOnePrice
	elseif self.nBuyType ==4  then
		nPrice = self.shenTenPrice
	end

	return nPrice
end

--根据类型获取将令所需消耗个数
function DlgBuyHero:getBuyItemNums()
	-- body
	local nItemNum = 0

	if self.nBuyType == 1 then
		nItemNum = self.liangOneItemNums
	elseif self.nBuyType == 2  then
		nItemNum = self.liangTenItemNums
	elseif self.nBuyType == 3  then
		nItemNum = self.shenOneItemNums
	elseif self.nBuyType == 4  then
		nItemNum = self.shenTenItemNums
	end

	return nItemNum
end

--刷新界面
function DlgBuyHero:refreshLayer()
	-- body
	self:refreshData()
	self:updateViews()
end

-- 析构方法
function DlgBuyHero:onDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgBuyHero:regMsgs( )
	-- body
	--注册时间更新函数
	regUpdateControl(self, handler(self, self.updateCd))
	-- 注册拜将台免费招募消息
	regMsg(self, gud_refresh_buy_hero, handler(self, self.refreshLayer))

end

-- 注销消息
function DlgBuyHero:unregMsgs(  )
	-- body
	--注销时间更新函数
	unregUpdateControl(self)

	-- 销毁拜将台免费招募消息
	unregMsg(self, gud_refresh_buy_hero)	
end


--暂停方法
function DlgBuyHero:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgBuyHero:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

return DlgBuyHero