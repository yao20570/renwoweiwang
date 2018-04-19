----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-07-10 15:07:17
-- Description: 世界目标打乱军
-----------------------------------------------------

local DlgCommon = require("app.common.dialog.DlgCommon")
local DlgWorldTargetWildArmy = class("DlgWorldTargetWildArmy", function()
	return DlgCommon.new(e_dlg_index.worldtargetarmy,750-130,130)
end)

function DlgWorldTargetWildArmy:ctor(  )
	parseView("dlg_world_target_base", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgWorldTargetWildArmy:onParseViewCallback( pView )
	self:addContentView(pView, true) --加入内容层

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgWorldTargetWildArmy",handler(self, self.onDlgWorldTargetWildArmyDestroy))
end

-- 析构方法
function DlgWorldTargetWildArmy:onDlgWorldTargetWildArmyDestroy(  )
    self:onPause()
end

function DlgWorldTargetWildArmy:regMsgs(  )
	regMsg(self, gud_world_target_wild_amry_kill_refresh, handler(self, self.udpateBottomBtn))
end

function DlgWorldTargetWildArmy:unregMsgs(  )
	unregMsg(self, gud_world_target_wild_amry_kill_refresh)
end

function DlgWorldTargetWildArmy:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function DlgWorldTargetWildArmy:onPause(  )
	self:unregMsgs()
end

function DlgWorldTargetWildArmy:setupViews(  )
	local pLayView = self:findViewByName("view")
	local pLayBorder = self:findViewByName("lay_border")
	local pTxtBanner = self:findViewByName("txt_banner")
	pTxtBanner:setString(getConvertedStr(3, 10385))
	self.pLayGoods = self:findViewByName("lay_goods")
	self.pTxtTip = self:findViewByName("txt_tip")

	local pLayBtn = self:findViewByName("lay_btn")
	self.pLayBtn=pLayBtn
	self.pBottomBtn = getCommonButtonOfContainer(pLayBtn ,TypeCommonBtn.L_BLUE, getConvertedStr(3, 10162))
	self.pBottomBtn:onCommonBtnClicked(handler(self, self.onBottomClicked))

	local tConTable = {}
	--文本
	local tLabel = {
		{getConvertedStr(3, 10462),getC3B(_cc.white)},
		{"1: ",getC3B(_cc.green)},
		{"1: ",getC3B(_cc.white)},
	}
	tConTable.tLabel = tLabel
	self.pBottomBtn:setBtnExText(tConTable)
		self.pLayBtn:setPositionY(0)
	

	--背景
	local pImgBg = MUI.MImage.new("ui/bg_world/v1_bg_tdpl.jpg")
	pLayView:addView(pImgBg)
	local nX, nY = pLayBorder:getPosition()
	pImgBg:setPosition(nX + pImgBg:getContentSize().width/2, nY + pImgBg:getContentSize().height/2)

	--布局中默认的按钮隐藏
	local pBtn = self:getOnlyConfirmButton()
	pBtn:setVisible(false)
	if self.pLayContent then
		self.pLayContent:setZOrder(10)
	end
end

function DlgWorldTargetWildArmy:updateViews(  )
	local nMyTargetId = Player:getWorldData():getMyWorldTargetId()
	if not nMyTargetId then
		return
	end
	self.nMyTargetId = nMyTargetId

	local tWorldTargetData = getWorldTargetData(nMyTargetId)
	if not tWorldTargetData then
		return
	end

	--标题
	self:setTitle(tWorldTargetData.desc)

	--介绍
	print("info--",tWorldTargetData.info)
	self.pTxtTip:setString(tWorldTargetData.info)

	--奖励物品
	if tWorldTargetData.award then
		local tGoodsList = getDropById(tWorldTargetData.award)
		gRefreshHorizontalList(self.pLayGoods, tGoodsList)
	end

	--击杀人数
	if tWorldTargetData.nTargetValue then
		local nCurrKill = Player:getWorldData():getWildArmyKill()
		local nNeedKill = tWorldTargetData.nTargetValue
		self.pBottomBtn:setExTextLbCnCr(2, tostring(nCurrKill))
		self.pBottomBtn:setExTextLbCnCr(3, "/"..tostring(nNeedKill))
	end

	--更新底部按钮
	self:udpateBottomBtn()
end

--更新底部按钮
function DlgWorldTargetWildArmy:udpateBottomBtn( )
	--前往或领奖按钮
	self.bIsGet = Player:getWorldData():getIsCanGetWTWildArmyReward()
	if self.bIsGet then
		self.pBottomBtn:updateBtnText(getConvertedStr(3, 10386)) 
		self.pBottomBtn:updateBtnType(TypeCommonBtn.L_YELLOW) 
		-- self.pLayBtn:setPositionY(20)
	else
		self.pBottomBtn:updateBtnText(getConvertedStr(3, 10162)) 
		self.pBottomBtn:updateBtnType(TypeCommonBtn.L_BLUE) 
	end
end

function DlgWorldTargetWildArmy:onBottomClicked( pView )
	if self.bIsGet then
		--领取奖励
		if self.nMyTargetId then
			SocketManager:sendMsg("regWorldTargetReward",{self.nMyTargetId})
		end
	else
		-- 定位
	    sendMsg(ghd_world_dot_near_my_city, {nDotType = e_type_builddot.wildArmy})
	end
	closeDlgByType(e_dlg_index.worldtargetarmy, false)
	--如果从聊天界面跳过去的要关掉聊天界面
	closeDlgByType(e_dlg_index.dlgchat)
end



return DlgWorldTargetWildArmy