----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-18 20:10:00
-- Description: 城池驻防
-----------------------------------------------------
local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemCityGarrison = require("app.layer.world.ItemCityGarrison")
local DlgCityGarrison = class("DlgCityGarrison", function()
	return DlgCommon.new(e_dlg_index.citygarrison, 800 - 60 - 130, 130)
end)

function DlgCityGarrison:ctor(  )
	self.nGarrisonHeroMax = 0 --驻防武将上限
	parseView("dlg_city_garrison", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgCityGarrison:onParseViewCallback( pView )
	self.pView = pView
	self:addContentView(pView) --加入内容层

	self:setTitle(getConvertedStr(3, 10047))

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgCityGarrison",handler(self, self.onDlgCityGarrisonDestroy))
end

-- 析构方法
function DlgCityGarrison:onDlgCityGarrisonDestroy(  )
    self:onPause()
end

function DlgCityGarrison:regMsgs(  )
	regMsg(self, ghd_world_city_garrison_call_msg, handler(self, self.onCityGarrisonCall))
	regMsg(self, gud_city_garrisonInfo_req, handler(self, self.reqWorldGarrisonInfo))
end

function DlgCityGarrison:unregMsgs(  )
	unregMsg(self, ghd_world_city_garrison_call_msg)
	unregMsg(self, gud_city_garrisonInfo_req)
end

function DlgCityGarrison:onResume(  )
	self:regMsgs()
end

function DlgCityGarrison:onPause(  )
	self:unregMsgs()
end

function DlgCityGarrison:setupViews(  )
	--ui位置更新
	local tUiPos = {
		{sUiName = "lay_info", nTopSpac = 12},
		{sUiName = "lay_banner", nTopSpac = 10},
		{sUiName = "lay_content", nTopSpac = 0},
		{sUiName = "lay_btn_garrison", nBottomSpac = 20},
		{sUiName = "lay_richtext_tip", nBottomSpac = 5},
	}
	restUiPosByData(tUiPos, self.pView)
	--ui位置更新

	--渐变背景
	local pLayInfo = self:findViewByName("lay_info")
	setGradientBackground(pLayInfo)

	self.pLayIcon = self:findViewByName("lay_icon")
	self.pTxtName = self:findViewByName("txt_name")
	setTextCCColor(self.pTxtName, _cc.blue)
	self.pTxtPos = self:findViewByName("txt_pos")
	self.pTxtMoveTime = self:findViewByName("txt_move_time")
	setTextCCColor(self.pTxtMoveTime, _cc.green)
	local pTxtHeroCountTitle = self:findViewByName("txt_hero_count_title")
	pTxtHeroCountTitle:setString(getConvertedStr(3, 10178))
	self.pLayRichtextHeroCount = self:findViewByName("lay_richtext_hero_count")
	self.pTxtTroops = self:findViewByName("txt_troops")
	self.pImgFlag = self:findViewByName("img_flag")
	local pBannerTitle1 = self:findViewByName("txt_banner_title1")
	pBannerTitle1:setString(getConvertedStr(3, 10180))
	local pBannerTitle2 = self:findViewByName("txt_banner_title2")
	pBannerTitle2:setString(getConvertedStr(3, 10181))
	local pBannerTitle3 = self:findViewByName("txt_banner_title3")
	pBannerTitle3:setString(getConvertedStr(3, 10182))
	local pBannerTitle4 = self:findViewByName("txt_banner_title4")
	pBannerTitle4:setString(getConvertedStr(3, 10183))
	local pBannerTitle5 = self:findViewByName("txt_banner_title5")
	pBannerTitle5:setString(getConvertedStr(3, 10184))
	local pLayRichtextTip = self:findViewByName("lay_richtext_tip")
	local sStr = string.format(getTipsByIndex(10034), getBuildParam("guardLv"))
	local tStr = getTextColorByConfigure(sStr)
	self.pRichtextTip = getRichLabelOfContainer(pLayRichtextTip, tStr)

	--列表
	self.tHelpMsgList = {}
	local pLayContent = self:findViewByName("lay_content")
	self.pLayContent = pLayContent

    --人数显示
	local tStr = {
		{color=_cc.blue,text="0"},
		{color=_cc.white,text="/0"},
	}
	self.pRichtextHeroCount = getRichLabelOfContainer(self.pLayRichtextHeroCount, tStr)

    --驻防按钮
    local pLayBtnGarrison = self:findViewByName("lay_btn_garrison")
	self.pLayBtnGarrison = getCommonButtonOfContainer(pLayBtnGarrison,TypeCommonBtn.L_BLUE, getConvertedStr(3, 10049))
	self.pLayBtnGarrison:onCommonBtnClicked(handler(self, self.onBtnGarrisonClicked))
end

function DlgCityGarrison:updateViews(  )
	if not self.tData then
		return
	end
	self.pTxtName:setString(string.format("%s %s", self.tData.sName, getLvString(self.tData.nLevel)))
	self.pTxtPos:setString(getConvertedStr(3, 10109)  .. getWorldPosString(self.tData.nX, self.tData.nY))
	local nMoveTime = WorldFunc.getMyArmyMoveTime(self.tData.nX, self.tData.nY)
	self.pTxtMoveTime:setString(getConvertedStr(3, 10019) .. formatTimeToMs(nMoveTime))
	WorldFunc.setImgCountryFlag(self.pImgFlag, self.tData.nDotCountry)

	--图标
	WorldFunc.getCityIconOfContainer(self.pLayIcon, self.tData.nCountry, self.tData.nLevel, true)
end

function DlgCityGarrison:updateListView(  )
	--创建列表
	if not self.pListView then
	    self:createListView(#self.tHelpMsgList)
	else
	    self.pListView:notifyDataSetChange(true, #self.tHelpMsgList)
	end

	--人数显示
	local nCount = #self.tHelpMsgList
	self.pRichtextHeroCount:updateLbByNum(1, tostring(nCount))
	self.pRichtextHeroCount:updateLbByNum(2, "/"..tostring(self.nGarrisonHeroMax))

	--兵力数
	local nTroops = 0
	for i=1,#self.tHelpMsgList do
		nTroops = nTroops + self.tHelpMsgList[i].nTroops
	end
	self.pTxtTroops:setString(getConvertedStr(3, 10179) .. tostring(nTroops))

	--最低可以驻军等级
	if self.nGarrisonHeroMax > 0 then
		self.pRichtextTip:setVisible(false)
		self.pLayBtnGarrison:setBtnEnable(true)
	else
		self.pRichtextTip:setVisible(true)
		self.pLayBtnGarrison:setBtnEnable(false)
	end
end
--创建listView
function DlgCityGarrison:createListView( nCount )
	local pLayContent = self.pLayContent
	self.pListView = MUI.MListView.new {
		viewRect   = cc.rect(0, 0, pLayContent:getContentSize().width, pLayContent:getContentSize().height),
		direction  = MUI.MScrollView.DIRECTION_VERTICAL,
    }
    pLayContent:addView(self.pListView)
    centerInView(pLayContent, self.pListView )
    self.pListView:setItemCallback(function ( _index, _pView ) 
    	local pItemData = self.tHelpMsgList[_index]
        local pTempView = _pView
        if pTempView == nil then
        	pTempView   = ItemCityGarrison.new(true)
    	end
    	pTempView:setData(pItemData)
        return pTempView
	end)

	--列表数据
    self.pListView:setItemCount(nCount)
	-- 载入所有展示的item
	self.pListView:reload()
end

--tData:tViewDotMsg
function DlgCityGarrison:setData( tData )
	self.tData = tData
	self:updateViews()

	--请求数据
	self:reqWorldGarrisonInfo()
end

function DlgCityGarrison:onBtnGarrisonClicked( pView )
	--当前已驻守的人数
	local nGarrsionedNum = #self.tHelpMsgList
	--判断是否已经有该地点有已驻守的人数
	--当前前往驻守的人数
	local nGoGarrsionNum = 0
	local tTaskMsgList = Player:getWorldData():getTaskMsgByTPos(e_type_task.garrison, self.tData.nX, self.tData.nY)
	for i=1,#tTaskMsgList do
		local tTaskMsg = tTaskMsgList[i]
		if tTaskMsg.nType == e_type_task.garrison then
			if tTaskMsg.nState == e_type_task_state.go then
				nGoGarrsionNum = nGoGarrsionNum + tTaskMsg:getArmyNums()
			end
		end
	end

	--可以上限人数
	local nCanGarrisonNum = self.nGarrisonHeroMax - nGarrsionedNum - nGoGarrsionNum

	--发送消息打开dlg
	local tObject = {
	    nType = e_dlg_index.battlehero, --dlg类型
	    nIndex = 2,--前往驻军
	    tViewDotMsg = self.tData,
	    nCanGarrisonNum = nCanGarrisonNum
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

--重新请求本地数据
function DlgCityGarrison:reqWorldGarrisonInfo()
	if self.tData then
		SocketManager:sendMsg("reqWorldGarrisonInfo", {self.tData.nX, self.tData.nY}, handler(self, self.onWorldGarrisonInfo))
	end
end

--查看驻防返回
function DlgCityGarrison:onWorldGarrisonInfo( __msg  )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqWorldGarrisonInfo.id then
        	self.nGarrisonHeroMax = __msg.body.g
        	--驻守返回
        	local tHelpMsgList = Player:getWorldData():createHelpMsgList(__msg.body.h)
			self.tHelpMsgList = tHelpMsgList or {}
			self:updateListView()
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end

--遣返友军驻防成功
function DlgCityGarrison:onCityGarrisonCall( sMsgName, pMsgObj)
	if pMsgObj then
		local sTid = pMsgObj
		for i=1,#self.tHelpMsgList do
			if self.tHelpMsgList[i].sTid == sTid then
				table.remove(self.tHelpMsgList, i)
				break
			end
		end
		self:updateListView()
	end
end


return DlgCityGarrison