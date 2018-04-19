----------------------------------------------------- 
-- author: maheng
-- updatetime: 2018-03-17 09:52:00
-- Description: 纣王试炼详细信息
-----------------------------------------------------

-- 乱军详情界面
local DlgCommon = require("app.common.dialog.DlgCommon")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local SysCityCollections = require("app.layer.world.SysCityCollections")

local nGoodsCol = 4

local DlgZhouwangTrialDetail = class("DlgZhouwangTrialDetail", function()
	return DlgCommon.new(e_dlg_index.zhouwangtrialdetail)
end)

function DlgZhouwangTrialDetail:ctor(  )
	parseView("layout_world_zhou_attrack", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgZhouwangTrialDetail:onParseViewCallback( pView )
	self.pView = pView
	self:addContentView(pView, true) --加入内容层

	self:setTitle(getConvertedStr(3, 10501))

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgZhouwangTrialDetail",handler(self, self.onDlgWildArmyDetailDestroy))
end

-- 析构方法
function DlgZhouwangTrialDetail:onDlgWildArmyDetailDestroy(  )
    self:onPause()
end

function DlgZhouwangTrialDetail:regMsgs(  )
end

function DlgZhouwangTrialDetail:unregMsgs(  )
end

function DlgZhouwangTrialDetail:onResume(  )
	self:regMsgs()
	regUpdateControl(self, handler(self, self.onUpdate))
end

function DlgZhouwangTrialDetail:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function DlgZhouwangTrialDetail:setupViews(  )
	--ui位置更新
	self.pLyRoot = self:findViewByName("lay_root")
	self.pLyTopInfo = self:findViewByName("lay_topinfo")
	self.pImgBoss = self:findViewByName("img_boss")
	self.pLbName = self:findViewByName("lb_name")
	self.pLayBar = self:findViewByName("lay_bar")
	self.pImgShare = self:findViewByName("img_share")
	self.pLbShare = self:findViewByName("lb_share")
	self.pTxtLeaveTime = self:findViewByName("lb_pos")
	self.pTxtMoveTime = self:findViewByName("lb_time")
	self.pLbTip = self:findViewByName("lb_tip")
	self.pLayPrize = self:findViewByName("lay_prize")
	
	setTextCCColor(self.pLbName, _cc.blue)
	setTextCCColor(self.pTxtMoveTime, _cc.green)
	setTextCCColor(self.pTxtLeaveTime, _cc.red)

	self.pLbTip:setString(getConvertedStr(6, 10820), false)

	self.pLbShare:setString(getConvertedStr(6, 10099), false)

	self.pProgressBar = MCommonProgressBar.new({bar = "v1_bar_yellow_3.png",barWidth = 247, barHeight = 16})	
	self.pLayBar:addView(self.pProgressBar, 10)
	self.pProgressBar:setPosition(125, 10)

	self.pImgShare:onMViewClicked(handler(self, self.onBtnShareCallBack))
	self.pImgShare:setViewTouched(true)

	self.pBtnAtt = self:getOnlyConfirmButton()
	self:setOnlyConfirmBtn(TypeCommonBtn.L_BLUE)
	self:setOnlyConfirm(getConvertedStr(3, 10502))
	self:setRightHandler(handler(self, self.onBtnAttackClicked))
	self:setRightDisabledHandler(handler(self, self.onBtnAttackClicked))

	--时间
	self.pLbNum = MUI.MLabel.new({
            text = "",
            size = 20,
        })	
	self.pLbNum:setPosition(self.pLayBottom:getWidth()/2, self.pLayBottom:getHeight()-30)	
	self.pLayBottom:addView(self.pLbNum, 999)

	--奖励
	self.tDropList = {}
	local tt =luaSplit(getKingZhouInitData("preview"), ",")
	for k, v in pairs(tt) do
		local pItem = getGoodsByTidFromDB(v)
		if pItem then
			table.insert(self.tDropList, pItem)			
		end						
	end
	table.sort(self.tDropList, function ( a, b )
		-- body
		return a.nQuality > b.nQuality
	end)	

	self.pListView = MUI.MListView.new {
	    viewRect   = cc.rect(0, 0, self.pLayPrize:getContentSize().width, self.pLayPrize:getContentSize().height),
	    direction  = MUI.MScrollView.DIRECTION_VERTICAL,
	    itemMargin = {left =  0,
	        right =  0,
	        top =  5,
	        bottom =  5},
	}
	self.pLayPrize:addView(self.pListView)
    --上下箭头
	local pUpArrow, pDownArrow = getUpAndDownArrow()
	self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)	
	self.pListView:setItemCount(math.ceil(#self.tDropList/nGoodsCol)) 
	self.pListView:setItemCallback(handler(self, self.onListViewItemCallBack))
	self.pListView:reload(false)
end

function DlgZhouwangTrialDetail:updateViews(  )
	if not self.tData then
		return
	end
	local pData = self.tData
	self.pLbName:setString(pData:getDotName()..getLvString(pData:getDotLv()), false)
	local nPrecent = roundOff(pData.nKzt/pData.nKztt*100, 0.1)
	self.pProgressBar:setPercent(nPrecent)
	self.pProgressBar:setProgressBarText(nPrecent.."%")

	self.nRatio = tonumber(getKingZhouInitData("marchQuickRate"))
	local nNeedTime = WorldFunc.getMyArmyMoveTime(pData.nX, pData.nY, self.nRatio)
	local sNeedTime = formatTimeToMs(nNeedTime)
	self.pTxtMoveTime:setString(getConvertedStr(3, 10019) .. sNeedTime)

	--
	local pActivity=Player:getActById(e_id_activity.zhouwangtrial)
	local nNum = 0 
	if pActivity then
		nNum = pActivity.nC
	end
	local nBoxLimit = tonumber(getKingZhouInitData("boxLimit")) or 0
	local sStr = {
		{text=getConvertedStr(6,10848), color=_cc.pwhite}, --今日已攻打乱军: 
		{text=nNum, color=_cc.blue},
		{text="/", color=_cc.pwhite},
		{text=nBoxLimit, color=_cc.pwhite}
	}
	self.pLbNum:setString(sStr, false)
    self.pTxtLeaveTime:setString(getConvertedStr(6, 10793)..formatTimeToMs(pData:getZhouWangLeaveCd()), false)
    --可以打
    self.bIsCanAtk = nNum <= nBoxLimit
    self.pBtnAtt:setBtnEnable(self.bIsCanAtk)
end

function DlgZhouwangTrialDetail:onUpdate( )
	-- body
	if self.tData and self.pTxtLeaveTime then
		local nLeft = self.tData:getZhouWangLeaveCd()
		if nLeft > 0 then
			self.pTxtLeaveTime:setString(getConvertedStr(6, 10793)..formatTimeToMs(nLeft), false)
		else
			closeDlgByType(e_dlg_index.zhouwangtrialdetail, false)
		end
	end	
end

--列表回调
function DlgZhouwangTrialDetail:onListViewItemCallBack( _index, _pView)
    local pTempView = _pView
    if pTempView == nil then
        pTempView = SysCityCollections.new()
    end
    local nBeginX, nBeginY, nOffsetX, nOffsetY = 40, 0, 160, 0
    local nIndex = (_index - 1) * nGoodsCol

    for i=1,nGoodsCol do
    	local tTempData = self.tDropList[nIndex + i]
    	if tTempData then
    		pTempView:setIcon(i, tTempData)
    	else
    		pTempView:setIcon(i, nil)
    	end
    end
    return pTempView
end

--tData:ViewDotMsg
function DlgZhouwangTrialDetail:setData( tData )
	self.tData = tData
	self:updateViews()
end

function DlgZhouwangTrialDetail:onBtnCancelClicked(  )
	self:closeDlg(false)
end

function DlgZhouwangTrialDetail:onBtnAttackClicked(  )
	--可以打
	if self.bIsCanAtk then
		--发送消息打开dlg
		local tObject = {
		    nType = e_dlg_index.battlehero, --dlg类型
		    nIndex = 8,--野军
		    tViewDotMsg = self.tData,
		}
		sendMsg(ghd_show_dlg_by_type, tObject)
		closeDlgByType(e_dlg_index.zhouwangtrialdetail, false)
	else
		TOAST(getTipsByIndex(802))
	end
end

function DlgZhouwangTrialDetail:onBtnShareCallBack( pView )
	-- body
	local tData = {
		dn = self.tData.sDotName,
		dx = self.tData.nX,
		dy = self.tData.nY,
	}
	openShare(pView, e_share_id.zhoutril_pos, tData)
end

return DlgZhouwangTrialDetail
