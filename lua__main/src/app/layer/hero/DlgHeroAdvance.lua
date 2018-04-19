-----------------------------------------------------
-- author: xiesite
-- Date: 2017-10-28 11:37:23
-- Description: 英雄进阶
-----------------------------------------------------

local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemHeroInfoLb = require("app.layer.hero.ItemHeroInfoLb")
local MRichLabel = require("app.common.richview.MRichLabel")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local ItemHeroInfo = require("app.layer.hero.ItemHeroInfo")

local DlgHeroAdvance = class("DlgHeroAdvance", function()
	-- body
	return DlgCommon.new(e_dlg_index.nheroadvance,740-170,170)
end)

function DlgHeroAdvance:ctor(_tData)
	-- body
	self:myInit()
	self.tHeroData = _tData
	if self.tHeroData.recordAdvanceRedNum then
		self.tHeroData:recordAdvanceRedNum()
	end
	self.curAp = self.tHeroData:getAp()
	self.nT = _tData.nT
	self.tHeroT = self.tHeroData.nT;
	self:setTitle(getConvertedStr(5, 10018))
	parseView("dlg_hero_advance", handler(self, self.onParseViewCallback))
	-- self:setNeedBottomBg(false)
	getHeroAdvanceDataByKind(1)
end

--初始化成员变量
function DlgHeroAdvance:myInit(  )
	-- body
	self.tHeroData = nil --英雄数据
	self.tHeroListIcon = nil --英雄队列icon
	self.bSelect = false --是否选中自动进阶
	self.bIsFinish = true --是否完成一次进阶
	self.bInEff	= false --是否特效表演中
	self.nAutoRefineTimes = 0
	self.curAp = 0 --记录进度值
	self.bFirst = true --用来判断是否首次打开
end

function DlgHeroAdvance:setupViews(  )
	-- 英雄信息层
	self.pLyHero_1 = self:findViewByName("ly_hero_1")
	self.pLyHero_2 = self:findViewByName("ly_hero_2")
	self.pImgArrow = self:findViewByName("img_arrow")

	-- 进阶提示层
	self.pLyTips_1 = self:findViewByName("ly_tips_1")
	self.pLyBarInfo = self:findViewByName("ly_bar_info")
	self.pLbAdvance = self:findViewByName("lb_advance")
	self.pLbAdvance:setString(getConvertedStr(1, 10280));
	self.pLbAdvanceValue = self:findViewByName("lb_advance_value")
	self.pLbAdvanceTips = self:findViewByName("lb_advance_tips")
	self.pAdvanceBar = MCommonProgressBar.new({bar = "v1_bar_blue_4.png",barWidth = 296, barHeight = 15})
	self.pTx = createSliderTx(self.pAdvanceBar)
	self.pLyBarInfo:addView(self.pAdvanceBar, 10)
	centerInView(self.pLyBarInfo, self.pAdvanceBar)

	self.pLyTips_2 = self:findViewByName("ly_tips_2")
	--条件1
	self.pLyCondition_1 = self:findViewByName("ly_condition_1")
	self.pImgGou_1 = self:findViewByName("img_gou_1")
	self.pLbCondition_1 = self:findViewByName("lb_condition_1")
	--条件2
	self.pLyCondition_2 = self:findViewByName("ly_condition_2")
	self.pImgGou_2 = self:findViewByName("img_gou_2")
	self.pLbCondition_2 = self:findViewByName("lb_condition_2")

	--完成进阶
	self.pLyTips_3 = self:findViewByName("ly_tips_3")
	self.pLbFinish = self:findViewByName("lb_finish")
	self.pLbFinish:setString(getConvertedStr(1,10302))
	setTextCCColor(self.pLbFinish, _cc.blue)

	--最底层
	self.pLyBottom = self:findViewByName("ly_bottom")
	self.pLbNeed = self:findViewByName("lb_need")
	self.pLbCost = self:findViewByName("lb_cost")
	self.pLbCost:setString(getConvertedStr(1,10285))
	self.pLbCostValue = self:findViewByName("lb_cost_value")
	self.pLyBtn = self:findViewByName("ly_btn")
	self.pLyNeed = self:findViewByName("ly_need")
	self.pLbCostTips = self:findViewByName("lb_cost_tips")
	self.pLbCostTips:setString(getTipsByIndex(20062))
	self.pLbCostTips:setVisible(false)


	--自动进阶次数文本层
	self.pLayAutoRefineLb = self:findViewByName("lay_autorefinelb")
	self.pLayAutoRefineLb:setVisible(false)
	self.pTextAutoTimes =  MUI.MLabel.new({text = "", size = 26})
	self.pLayAutoRefineLb:addView(self.pTextAutoTimes, 10)
	centerInView(self.pLayAutoRefineLb, self.pTextAutoTimes)

	--复选按钮层
	self.pLayCheckBox = self:findViewByName("lay_checkbox")
	self.pCheckBox = MUI.MCheckBoxButton.new(
        {on="#v2_img_gouxuan.png", off="#v2_img_gouxuankuang.png"})
	self.pCheckBox:setButtonSelected(false)
	self.pLayCheckBox:addView(self.pCheckBox)
	centerInView(self.pLayCheckBox, self.pCheckBox)
	self.pCheckBox:onButtonStateChanged(function ( bChecked )
		-- body
		self.bSelect = bChecked
		self:updateBtnText()
	end)
	--复选说明
	self.pLbCheckText = self:findViewByName("lb_checktext")
	self.pLbCheckText:setString(getConvertedStr(1, 10315))
	setTextCCColor(self.pLbCheckText, _cc.pwhite)


	
	self.pBtn = getCommonButtonOfContainer(self.pLyBtn, TypeCommonBtn.L_BLUE, getConvertedStr(1, 10284))
	self.pBtn:onCommonBtnClicked(handler(self, self.onAdvanceClicked))
	-- self.pBtn:getButton():onMViewPressed(handler(self, self.onUpgradePressed))
	-- self.pBtn:getButton():onMViewRelease(handler(self, self.onUpgradeRelease))
	-- self.pBtn:getButton():onMViewCanceled(handler(self, self.onUpgradeCanceled))

	self:setCloseHandler(function() 
							self:showLeaveTips()
						 end)
end

--vip等级不足跳转
function DlgHeroAdvance:showLeaveTips()
	--满阶不用提醒
	if self.tHeroData.nQuality == 6 or self.tHeroData:getAp() <= 0 then
		self:closeCommonDlg()
		return
	end

	--没进入进阶不用提醒
	local tLv, tHeroLv = self.tHeroData:getAdvanceCondition()
	if not tLv[2] or  not tHeroLv[2] then
		self:closeCommonDlg()
		return
	end


	local DlgAlert = require("app.common.dialog.DlgAlert")
    local pDlg, bNew = getDlgByType(e_dlg_index.alert)
    if(not pDlg) then
        pDlg = DlgAlert.new(e_dlg_index.alert)
    end
    pDlg:setTitle(getConvertedStr(1, 10218))
    pDlg:setContent(getTipsByIndex(10078))
    pDlg:setLeftBtnText(getConvertedStr(1,10316))
    pDlg:setRightBtnText(getConvertedStr(1,10317))
 	pDlg:setLeftHandler(function (  )            
		self:closeCommonDlg()
        closeDlgByType(e_dlg_index.alert, false)  
    end)
    pDlg:showDlg(bNew) 
end

-- getHeroDataById
function DlgHeroAdvance:showHeroInfo()
	if not self.tHeroData then
		return false
	end

	self.tNextHeroData = nil
	if self.tHeroData.nId and self.tHeroData.nQuality < 6 then
		self.nNextId =  self.tHeroData.nT + 1
		self.tNextHeroData = getHeroDataById(self.nNextId) --copyTab(getHeroDataById(self.nNextId))
	end

	if self.tHeroData then
		if not self.pCurView then
			self.pCurView = ItemHeroInfo.new(self.tHeroData)
			self.pLyHero_1:addView(self.pCurView)
		else
			self.pCurView:updateViews()
		end
	end

	if self.tNextHeroData then
		self.tNextHeroData.tSoulStar = copyTab(self.tHeroData.tSoulStar)   --星魂的等级进阶后保留，给右边显示用
		--计算和初始资质差
		local exData = {}
		table.insert(exData,self.tHeroData:getExAtkTalent())
		table.insert(exData,self.tHeroData:getExDefTalent())
		table.insert(exData,self.tHeroData:getExTrpTalent())

		local data = {}
		table.insert(data,self.tNextHeroData:getTotalBaseTalent() - self.tHeroData:getTotalBaseTalent())
		table.insert(data,self.tNextHeroData:getBTTalentAtk() - self.tHeroData:getBTTalentAtk())
		table.insert(data,self.tNextHeroData:getBTTalentDef() - self.tHeroData:getBTTalentDef())
		table.insert(data,self.tNextHeroData:getBTTalentTrp() - self.tHeroData:getBTTalentTrp())
		if not self.pNextView then
			self.pNextView = ItemHeroInfo.new(self.tNextHeroData,exData)
			self.pNextView:showAddArrow(data)
			self.pLyHero_2:addView(self.pNextView)
			if self.pAbandonView then
				self.pNextView:setOpacity(0)
			end
		else
			self.pNextView:setCurData(self.tNextHeroData,exData)
			self.pNextView:updateViews()
			self.pNextView:showAddArrow(data)
		end
	end
end

--解析布局回调事件
function DlgHeroAdvance:onParseViewCallback( pView )
	-- body
	self.pView = pView
	self:addContentView(pView,false) --加入内容层

	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgHeroAdvance",handler(self, self.onDestroy))
end


-- 修改控件内容或者是刷新控件数据
function DlgHeroAdvance:updateViews()
	if not self.tHeroData then
       return
	end	
	-- dump(self.tHeroData)
	self:showHeroInfo()
	self:updateCondition()
	self:updateBottom()
end

function DlgHeroAdvance:updateBottom()
	local nGoodsId = tonumber(getHeroInitData("transId"))
	local tIconData = getGoodsByTidFromDB(nGoodsId)
	local pIcon = getIconGoodsByType(self.pLyNeed, TypeIconGoods.NORMAL, type_icongoods_show.item, tIconData, TypeIconGoodsSize.L)
	self.pLbNeed:setString(tIconData.sName)

	local nCt = getMyGoodsCnt(nGoodsId)
	local nNeed = self.tHeroData.getAdvanceNeed()
	self.nHasNum = nCt
	self.nNeedCost = nNeed
	if nNeed > nCt then
		nNeed = "<font color='#d72322'>"..nNeed.."</font>"
		self:onUpgradeRelease()
		self.pBtn:setToGray(true)
	else 
		nNeed = "<font color='#77d4fd'>"..nNeed.."</font>"
		self.pBtn:setToGray(false)
	end
	self.pLbCostValue:setString(nNeed.."/"..nCt)

	self:updateBtnText()
end

function DlgHeroAdvance:updateBtnText()
	--自动进阶时候并不需要修改text
	if not self.nUpgradeHandler then
		if self.bSelect then
			self.pBtn:updateBtnText(getConvertedStr(1,10315))
		elseif self.tHeroData.nQuality > 2 and self.tHeroData.nQuality <= 4 then
			self.pBtn:updateBtnText(getConvertedStr(1,10283))
		elseif self.tHeroData.nQuality <= 5 then
			self.pBtn:updateBtnText(getConvertedStr(1,10284))
		else 
			self.pBtn:updateBtnText(getConvertedStr(1,10283))
			self.pBtn:setToGray(true)
		end
	end
end


--刷新显示条件 
function DlgHeroAdvance:updateCondition()
	--已经升到当前最高级
	if not self.tNextHeroData then
		self.pLyTips_1:setVisible(false)
		self.pLyTips_2:setVisible(false)
		self.pLyTips_3:setVisible(true)
		self.pLyBottom:setVisible(false)
		
	else
		self.pLyTips_3:setVisible(false)
		local tLv, tHeroLv = self.tHeroData:getAdvanceCondition()
		--满足进阶等级条件
		if tLv[2] and tHeroLv[2] then
			self.pLyTips_1:setVisible(true)
			self.pLyTips_2:setVisible(false) 
			local nPercent = self.tHeroData:getAdvanceProgress()
			local nBePercent = self.pAdvanceBar:getPercent()
			if self.bFirst then
				self.bFirst = false
				self.pAdvanceBar:setPercent(nPercent)
			elseif nPercent ~= nBePercent then
				self:setProgressTx(nBePercent)
				self.pAdvanceBar:setPercent(nPercent)
				self.progressArm:setPosition(cc.p((nPercent*self.pAdvanceBar:getWidth()-3)/100, 7))
			end
			if nPercent >= 20 then
				setSliderTxVisible(self.pTx , true)
				for k, v in pairs(self.pTx.pArm) do
					v:setPosition(cc.p(nPercent*self.pAdvanceBar:getWidth()/100, self.pAdvanceBar:getContentSize().height/2))
				end
				self.pTx.pLizi:setPosition(nPercent*self.pAdvanceBar:getWidth()/100, self.pAdvanceBar:getContentSize().height/2)
			else
				setSliderTxVisible(self.pTx , false)
			end
			self:setAdvanceTips()

			self.pLbAdvanceValue:setString( "<font color='#77d4fd'>"..self.tHeroData:getAp().."</font>".."/"..self.tHeroData:getApMax())
			self.pLyBottom:setVisible(true)
		--不满足进阶等级条件
		else
			self.pLyBottom:setVisible(false)
			self.pLyTips_1:setVisible(false)
			self.pLyTips_2:setVisible(true)
			if tLv[2] then--玩家等级限制
				self.pImgGou_1:setCurrentImage("#v1_img_zycz.png")
				self.pLbCondition_1:setString( string.format(getConvertedStr(1,10281), tLv[1]))
				setTextCCColor(self.pLbCondition_1, _cc.blue)
			else
				self.pImgGou_1:setCurrentImage("#v1_img_zybz.png")
				self.pLbCondition_1:setString( string.format(getConvertedStr(1,10281), tLv[1]))
				setTextCCColor(self.pLbCondition_1, _cc.red)
			end
			
			local sStr = ""
			
			if tHeroLv[3] then
				--由蓝将和紫将进阶
				if(tonumber(tHeroLv[3]) == 1) or (tonumber(tHeroLv[3]) == 2) then
					sStr = getConvertedStr(1,10283)
				--由橙将进阶
				elseif tonumber(tHeroLv[3]) == 3 then
					sStr = getConvertedStr(1,10284)
				end
			end
			if tHeroLv[2] then--武将等级限制
				self.pImgGou_2:setCurrentImage("#v1_img_zycz.png")
				self.pLbCondition_2:setString( string.format(getConvertedStr(1,10282), tHeroLv[1])..sStr)
				setTextCCColor(self.pLbCondition_2, _cc.blue)
			else
				self.pImgGou_2:setCurrentImage("#v1_img_zybz.png")
				self.pLbCondition_2:setString( string.format(getConvertedStr(1,10282), tHeroLv[1])..sStr)
				setTextCCColor(self.pLbCondition_2, _cc.red)
			end
		end
	end
end

--设置数据
function DlgHeroAdvance:setCurData(_tData)
	-- body
	if not _tData then
		return 
	end
	self.tHeroData = _tData
	if self.tHeroData.recordAdvanceRedNum then
		self.tHeroData:recordAdvanceRedNum()
	end
	self:updateViews()
end

--点击回调
function DlgHeroAdvance:onAdvanceClicked(pView)
	--特效没播放完成不需要响应
	if self.bInEff then
		return
	end

	--在自动状态就解除自动状态
	if self.nUpgradeHandler then
		self:onUpgradeRelease()
		self:updateBottom()
		return
	end

	if self.bIsFinish then
		self.bIsFinish = false
		SocketManager:sendMsg("heroAdvance", {self.tHeroData.nId, 1}, handler(self, self.onGetDataFunc))
		if self.bSelect then
			self:onUpgradePressed()
		end
	end
end

--点击回调
function DlgHeroAdvance:onAdvanceAutoClicked(pView)
	if self.bInEff then
		return
	end

	if self.bIsFinish then
		self.bIsFinish = false
		SocketManager:sendMsg("heroAdvance", {self.tHeroData.nId, 1}, handler(self, self.onGetDataFunc))
	end
end

--进阶回调
function DlgHeroAdvance:onGetDataFunc(__msg)
	-- dump(__msg)
	if __msg.head.state == SocketErrorType.success then
		--dump(__msg,"onGetDataFunc")
		if __msg.head.type == MsgType.heroAdvance.id then

		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end

function DlgHeroAdvance:advanceCallback(_msgName ,_body)
	if not _body then
		return
	end
	self.bIsFinish = true
	local nPercent = self.tHeroData:getAdvanceProgress()
	-- doDelayForSomething(self, function ()
	-- self:setProgressTx(nPercent)
	-- end, 0.2)
	self:playAdvanceTimeAct()
	if _body.ho and _body.ho.t > self.nT then
		self:onUpgradeRelease()
		self.nT = _body.ho.t
		self.pAbandonView = self.pCurView
		self.pCurView = self.pNextView
		self.pNextView = nil
		local isEnd = false
		if self.tHeroData.nQuality == 6 then
			isEnd = true
		end
		self.pImgArrow:setVisible(false)
		self.bInEff = true
		self.curAp = 0
		self.pCurView:showAdvanceTX(self.pAbandonView,handler(self, self.txCallback), isEnd)
	end
	--进阶成功
	if self.tHeroData:getAp() - self.curAp > 0 then
		self:showNumJump(self.tHeroData:getAp() - self.curAp)
		self.curAp = self.tHeroData:getAp()
	end

end

function DlgHeroAdvance:txCallback(_isEnd)
	if self.pAbandonView then
		self.pAbandonView:removeFromParent(true)
		self.pAbandonView = nil
	end

	if self.pNextView then
		self.pNextView:fadeIn()
	end
	if self.tHeroData.nQuality ~= 6 and self.pImgArrow then
		self.pImgArrow:setVisible(true)
		self.pImgArrow:setPositionX(self.pImgArrow:getPositionX() - 20)
		self.pImgArrow:runAction(cc.MoveBy:create(0.6, cc.p(20, 0)))
	end
	self.bInEff = false
end

--设置提示语
function DlgHeroAdvance:setAdvanceTips()
	--进阶目标品质
	local sQuality = ""
	local sQColor = ""
	if self.tHeroData.nQuality == 3 or self.tHeroData.nQuality == 4 then
		sQuality = getConvertedStr(5, 10055)
		sQColor = "feba29"
	elseif self.tHeroData.nQuality == 5 then
		sQuality = getConvertedStr(5, 10054)
		sQColor = "d72322"
	end
	
	local sDesc = nil
	local tKindData = getHeroAdvanceDataByKind(self.tHeroData.nQuality-2)
	if tKindData == -1 then
		return
	end
	for k, v in ipairs(tKindData) do
		if(v.left == 1) then
			v.left = 0
		end
		if (v.left <= self.tHeroData.nAp) and (v.right >= self.tHeroData.nAp) then
			sDesc = v.desc
			break
		end
	end
	if sDesc then
		local sStr_1 = "<font color='#31d840'>"..getConvertedStr(1, 10280).."</font>"
		local sStr_2 = "<font color='#77d4fd'>"..sDesc.."</font>"
		local sStr_3 = "<font color='#"..sQColor.."'>"..sQuality.."</font>"

		self.pLbAdvanceTips:setString(string.format(getConvertedStr(1,10286),sStr_1,sStr_2,sStr_3))
	end
end

-- 析构方法
function DlgHeroAdvance:onDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgHeroAdvance:regMsgs( )
	-- 注册英雄界面刷新
	regMsg(self, gud_refresh_hero, handler(self, self.updateViews))
	-- 注册英雄进阶响应
	regMsg(self, ghd_hero_advance_success_msg, handler(self, self.advanceCallback))

end

-- 注销消息
function DlgHeroAdvance:unregMsgs(  )
	-- 注销英雄界面刷新
	unregMsg(self, gud_refresh_hero)
	-- 注销英雄进阶响应
	regMsg(self, ghd_hero_advance_success_msg)
end

--暂停方法
function DlgHeroAdvance:onPause( )
	-- body
	self:unregMsgs()
	--取消自动进阶
	self:onUpgradeRelease()
end

--继续方法
function DlgHeroAdvance:onResume( )
	-- body
	self:setupViews()
	self:updateViews()
	self:regMsgs()
end

--设置按下事件回调
function DlgHeroAdvance:onUpgradePressed(_pView)
	--注册定时器，每隔interval秒发送一次升级请求
	if(not self.nUpgradeHandler) then
	    self.nUpgradeHandler = MUI.scheduler.scheduleGlobal(
	        handler(self, self.reqAdvanceHero), 1)
		self.pBtn:updateBtnText(getConvertedStr(1, 10318))
		self.pBtn:updateBtnType(TypeCommonBtn.L_RED)
	end
end

--设置释放回调
function DlgHeroAdvance:onUpgradeRelease(_pView)
	self.nAutoRefineTimes = 0
	self.pLayAutoRefineLb:setVisible(false)
	-- 取消定时刷新
    if self.nUpgradeHandler then
		MUI.scheduler.unscheduleGlobal(self.nUpgradeHandler)
    	self.nUpgradeHandler = nil
    	self.bIsLongClicked = false
		self.pBtn:updateBtnType(TypeCommonBtn.L_BLUE)
    end
end

--取消按钮按下状态
function DlgHeroAdvance:onUpgradeCanceled(_pView)
	self.nAutoRefineTimes = 0
	self.pLayAutoRefineLb:setVisible(false)
	if self.nUpgradeHandler then
		MUI.scheduler.unscheduleGlobal(self.nUpgradeHandler)
    	self.nUpgradeHandler = nil
    	self.bIsLongClicked = false
    	self.pBtn:updateBtnType(TypeCommonBtn.L_BLUE)
    end
end

--长按时发送英雄升阶请求
function DlgHeroAdvance:reqAdvanceHero()
	-- body
	self.bIsLongClicked = true
	self.bIsLongClicked = true
	if self.nHasNum >= self.nNeedCost then
		self:onAdvanceAutoClicked()
	else
		TOAST(getConvertedStr(1,10312))
		if self.nUpgradeHandler then
			MUI.scheduler.unscheduleGlobal(self.nUpgradeHandler)
	    	self.nUpgradeHandler = nil
	    	self.bIsLongClicked = false
	    end
    end
end

--如果是自动洗练播放自动洗练次数刷新
function DlgHeroAdvance:playAdvanceTimeAct()
	if self.nUpgradeHandler then
		self.nAutoRefineTimes = self.nAutoRefineTimes + 1
		local tStr = {
			{text=getConvertedStr(1, 10314), color=getC3B(_cc.pwhite)},
			{text=self.nAutoRefineTimes, color=getC3B(_cc.blue)},
			{text=getConvertedStr(7, 10120), color=getC3B(_cc.pwhite)},
		}
		self.pLayAutoRefineLb:setVisible(true)
		self.pTextAutoTimes:setString(tStr)
	end
end


function DlgHeroAdvance:setProgressTx(_nPrecent)
	_nPrecent = _nPrecent or 0
	if not self.progressArm then
		--addTextureToCache("tx/other/sg_wjjj_jdt")
		self.progressArm = MArmatureUtils:createMArmature(
			tNormalCusArmDatas["50"],
			self.pAdvanceBar,
			15,
			cc.p(0,0),
			function ( _pArm )
			end, Scene_arm_type.normal)
		if self.progressArm then
			self.progressArm:play(1)
		end
	else
		self.progressArm:play(1)
	end
	self.progressArm:setPosition(cc.p((_nPrecent*self.pAdvanceBar:getWidth()-3)/100, 7))
	
end

function DlgHeroAdvance:hideProgressTx()
	if self.progressArm then
		self.progressArm:setVisible(false)
	end
end

function DlgHeroAdvance:showNumJump(_num)
	local pLayArm = showNumJump(_num)
	if pLayArm then
		self.pLyTips_1:addView(pLayArm, 99)
		pLayArm:setPosition(438, 80)
	end	

end


return DlgHeroAdvance