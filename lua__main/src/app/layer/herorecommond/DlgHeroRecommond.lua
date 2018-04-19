----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-11-17 16:31:22
-- Description: 武将推荐
-----------------------------------------------------
local MDialog = require("app.common.dialog.MDialog")
local DlgHeroRecommond = class("DlgHeroRecommond", function()
	return MDialog.new()
end)


function DlgHeroRecommond:ctor( )
	self.eDlgType = e_dlg_index.herorecommend
	self:myInit()
	parseView("dlg_hero_recommend", handler(self, self.onParseViewCallback))
	self:setName(UIAction.TAG_SMALL_DLG)
end

function DlgHeroRecommond:myInit( )
	self.tDataInfo = {
		[1] = {
			sTabStr = getConvertedStr(3, 10518),
			sImgBg = "ui/v2_bg_huamulan.jpg",	
			sTabSelBg = "#v2_btn_wujianglanse.png",
			nVipGift = 3,
			tSelBgPos = cc.p(-2, -7),
			tTabTextCenterPos = cc.p(289, 22),
			nHeroId = 200111,
		},
		[2] = {
			sTabStr = getConvertedStr(3, 10519),
			sImgBg = "ui/v2_bg_baiqi.jpg",	
			sTabSelBg = "#v2_btn_wujiangzise.png",
			nVipGift = 6,
			tSelBgPos = cc.p(133, -7),
			tTabTextCenterPos = cc.p(262, 22),
			nHeroId = 200321,
		},
		[3] = {
			sTabStr = getConvertedStr(3, 10520),
			sImgBg = "ui/v2_bg_hanxin.jpg",	
			sTabSelBg = "#v2_btn_wujianghblue.png",
			nVipGift = 9,
			tSelBgPos = cc.p(270, -7),
			tTabTextCenterPos = cc.p(236, 22),
			nHeroId = 200621,
		},
	}
end

--解析布局回调事件
function DlgHeroRecommond:onParseViewCallback( pView )
	-- body
	self.pComDlgView = pView
	self:setContentView(self.pComDlgView)
	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("DlgHeroRecommond",handler(self, self.onDlgHeroRecommondDestroy))
end

--初始化控件
function DlgHeroRecommond:setupViews(  )
	self.pImgBg = self:findViewByName("img_bg")
	local pImgLineLeft = self:findViewByName("img_line_left")
	pImgLineLeft:setFlippedX(true)

	self.pLayCurrTab  = self:findViewByName("lay_curr_tab")
	self.pTxtCurrTab = self:findViewByName("txt_curr_tab")
	self.pTxtTabLeft = self:findViewByName("txt_tab_left")
	self.pTxtTabCenter = self:findViewByName("txt_tab_center")
	self.pTxtTabRight = self:findViewByName("txt_tab_right")
	self.pImgBtnClose = self:findViewByName("img_btn_close")
	self.pImgBtnGo = self:findViewByName("img_btn_go")
	self.pImgBtnGo:setViewTouched(true)
	-- self.pImgBtnGo:setIsPressedNeedScale(false)
	self.pImgBtnGo:setIsPressedNeedColor(false)
	self.pImgBtnGo:onMViewClicked(handler(self, self.onGoVipGift))

	local pLayBtnLeft = self:findViewByName("lay_btn_left")
	pLayBtnLeft:setViewTouched(true)
	pLayBtnLeft:setIsPressedNeedScale(false)
	pLayBtnLeft:setIsPressedNeedColor(false)
	pLayBtnLeft:onMViewClicked(handler(self, self.onClickIndex1))

	local pLayBtnCenter = self:findViewByName("lay_btn_center")
	pLayBtnCenter:setViewTouched(true)
	pLayBtnCenter:setIsPressedNeedScale(false)
	pLayBtnCenter:setIsPressedNeedColor(false)
	pLayBtnCenter:onMViewClicked(handler(self, self.onClickIndex2))

	local pLayBtnRight = self:findViewByName("lay_btn_right")
	pLayBtnRight:setViewTouched(true)
	pLayBtnRight:setIsPressedNeedScale(false)
	pLayBtnRight:setIsPressedNeedColor(false)
	pLayBtnRight:onMViewClicked(handler(self, self.onClickIndex3))

	local pImgBtnClose = self:findViewByName("img_btn_close")
	pImgBtnClose:setViewTouched(true)
	pImgBtnClose:setIsPressedNeedScale(false)
	pImgBtnClose:setIsPressedNeedColor(false)
	pImgBtnClose:onMViewClicked(handler(self, self.onClickClose))

	self.pTxtTabLeft:setString(self.tDataInfo[1].sTabStr)
	self.pTxtTabCenter:setString(self.tDataInfo[2].sTabStr)
	self.pTxtTabRight:setString(self.tDataInfo[3].sTabStr)

	local pLayBtnReward=self:findViewByName("lay_btn_reward")
	pLayBtnReward:setViewTouched(true)
	pLayBtnReward:setIsPressedNeedScale(false)
	pLayBtnReward:setIsPressedNeedColor(false)
	pLayBtnReward:onMViewClicked(handler(self, self.onGoVipGift))

	local pLayBtnHero=self:findViewByName("lay_btn_hero")
	pLayBtnHero:setViewTouched(true)
	pLayBtnHero:setIsPressedNeedScale(false)
	pLayBtnHero:setIsPressedNeedColor(false)
	pLayBtnHero:onMViewClicked(handler(self, self.onHeroDetailClicked))
end

function DlgHeroRecommond:setData( _nQuality)
	-- >=9 未够3 显示3; >=9 已够3 已够2 显示1; >=9 已够3，已够1，显示2
	-- >=6 未够2 显示2; >=6 已够2 显示3
	-- 未够1 显示1 已够买1 显示2
	if _nQuality then
		print("quality",_nQuality)
		if _nQuality == 3 then
			self:setCurrTabIndex(1)
		elseif _nQuality == 4 then
			self:setCurrTabIndex(2)
		elseif _nQuality == 5 then
			self:setCurrTabIndex(3)
		end

	else
		local nVip = Player:getPlayerInfo().nVip
		local nVipGift = 9
		if nVip >= nVipGift then
			local bIsBought = Player:getPlayerInfo():getIsBoughtVipGift(nVipGift)
			if bIsBought then --已买
				local bIsBoughtVip3 = Player:getPlayerInfo():getIsBoughtVipGift(3)
				if bIsBoughtVip3 then
					self:setCurrTabIndex(2)
				else
					self:setCurrTabIndex(1)
				end
			else
				self:setCurrTabIndex(3)
			end
		else
			nVipGift = 6
			if nVip >= nVipGift then
				local bIsBought = Player:getPlayerInfo():getIsBoughtVipGift(nVipGift)
				if bIsBought then --已买
					self:setCurrTabIndex(3)
				else
					self:setCurrTabIndex(2)
				end
			else
				nVipGift = 3
				local bIsBought = Player:getPlayerInfo():getIsBoughtVipGift(nVipGift)
				if bIsBought then --已买
					self:setCurrTabIndex(2)
				else
					self:setCurrTabIndex(1)
				end
			end
		end

	end

	
end

--切换下标
function DlgHeroRecommond:setCurrTabIndex( nIndex )
	if self.nCurrTabIndex ~= nIndex then
		self.nCurrTabIndex = nIndex
		self:updateViews()
	end
end

--控件刷新
function DlgHeroRecommond:updateViews(  )
	if not self.nCurrTabIndex then
		return
	end

	local tData = self.tDataInfo[self.nCurrTabIndex]
	if not tData then
		return
	end

	self.pImgBg:setCurrentImage(tData.sImgBg)
	self.pLayCurrTab:setBackgroundImage(tData.sTabSelBg)
	self.pTxtCurrTab:setString(tData.sTabStr)
	self.pLayCurrTab:setPosition(tData.tSelBgPos)
	self.pTxtTabCenter:setPosition(tData.tTabTextCenterPos)
	
	local bIsBought = Player:getPlayerInfo():getIsBoughtVipGift(tData.nVipGift)
	if bIsBought then
		self.pImgBtnGo:setCurrentImage("#v2_btn_yigoumai.png")
	else
		self.pImgBtnGo:setCurrentImage("#v2_btn_goumai.png")
	end
end

--析构方法
function DlgHeroRecommond:onDlgHeroRecommondDestroy(  )
end

function DlgHeroRecommond:onClickIndex1( )
	self:setCurrTabIndex(1)
end

function DlgHeroRecommond:onClickIndex2( )
	self:setCurrTabIndex(2)
end

function DlgHeroRecommond:onClickIndex3( )
	self:setCurrTabIndex(3)
end

function DlgHeroRecommond:onGoVipGift( )
	if not self.nCurrTabIndex then
		return
	end

	local tData = self.tDataInfo[self.nCurrTabIndex]
	if not tData then
		return
	end

	--打开对话框
    local tObject = {}
	tObject.nType = e_dlg_index.dlgvipprivileges	
	tObject.nVipLv = tData.nVipGift
	sendMsg(ghd_show_dlg_by_type,tObject)  
	--关闭自己
	self:closeDlg(false)
end

function DlgHeroRecommond:onHeroDetailClicked(  )
	if not self.nCurrTabIndex then
		return
	end

	local tData = self.tDataInfo[self.nCurrTabIndex]
	if not tData then
		return
	end

	local tHeroData = getHeroDataById(tData.nHeroId)
	if tHeroData then
		local tObject = {}
		tObject.nType = e_dlg_index.heroinfo
		tObject.tData = tHeroData
		sendMsg(ghd_show_dlg_by_type, tObject)
	end

	--关闭自己
	self:closeDlg(false)
end

function DlgHeroRecommond:onClickClose( )
	self:closeDlg(false)
end

return DlgHeroRecommond