----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-19 17:41:19
-- Description: 采集资源界面 玩家占领
-----------------------------------------------------
-- 采集资源界面
local MCommonView = require("app.common.MCommonView")
local CollectResourceOccupy = class("CollectResourceOccupy", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function CollectResourceOccupy:ctor( pDlgCollectResource )
	self.pDlgCollectResource = pDlgCollectResource
	parseView("layout_collect_resource_occupy", handler(self, self.onParseViewCallback))
end

--解析界面回调
function CollectResourceOccupy:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("CollectResourceOccupy",handler(self, self.onCollectResourceOccupyDestroy))
end

-- 析构方法
function CollectResourceOccupy:onCollectResourceOccupyDestroy(  )
    self:onPause()
end

function CollectResourceOccupy:regMsgs(  )
end

function CollectResourceOccupy:unregMsgs(  )
end

function CollectResourceOccupy:onResume(  )
	self:regMsgs()
	regUpdateControl(self, handler(self, self.updateCd))
end

function CollectResourceOccupy:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function CollectResourceOccupy:setupViews(  )
	self.pTxtName = self:findViewByName("txt_player_name")
	setTextCCColor(self.pTxtName, _cc.blue)
	self.pImgFlag = self:findViewByName("img_flag")
	self.pLayHeroIcon = self:findViewByName("lay_hero_icon")
	local pTxtPlayerNameTitle = self:findViewByName("txt_player_name_title")
	pTxtPlayerNameTitle:setString(getConvertedStr(3, 10317))
	self.pTxtHeroName = self:findViewByName("txt_hero_name")
	self.pTxtHeroLv = self:findViewByName("txt_hero_lv")
	setTextCCColor(self.pTxtHeroLv, _cc.blue)
	local pTxtTroopsTitle = self:findViewByName("txt_troops_title")
	pTxtTroopsTitle:setString(getConvertedStr(3, 10124))
	local pLayRichtextTroops = self:findViewByName("lay_richtext_troops")
	local tStr = {
		{color=_cc.blue,text="0"},
		{color=_cc.pwhite,text="/0"},
	}
	self.pRichtextTroops = getRichLabelOfContainer(pLayRichtextTroops,tStr)

	local pTxtRemainCollectCdTitle = self:findViewByName("txt_remain_collect_cd_title")
	pTxtRemainCollectCdTitle:setString(getConvertedStr(3, 10187))
	self.pTxtRemainCollectCd = self:findViewByName("txt_remain_collect_cd")
	setTextCCColor(self.pTxtRemainCollectCd, _cc.green)

	local pLayBtnCancel = self:findViewByName("lay_btn_cancel")
	local pBtnCancel = getCommonButtonOfContainer(pLayBtnCancel,TypeCommonBtn.L_RED)
	pBtnCancel:onCommonBtnClicked(handler(self, self.onBtnCancelClicked))
	pBtnCancel:updateBtnText(getConvertedStr(3, 10015))

	local pLayBtn1 = self:findViewByName("lay_btn_collect")
	self.pBtn1 = getCommonButtonOfContainer(pLayBtn1,TypeCommonBtn.L_BLUE, getConvertedStr(3, 10057))

	self.pImgCai = self:findViewByName("img_cai")
end

function CollectResourceOccupy:updateViews(  )
	if not self.tData then
		return
	end
	if not self.tMine then
		return
	end
	--是否是自己占领
	if self.tData.bIsMeOccupy then
		--采集时间
		local nCanTime = 0
		local nHeroId = self.tData.nOccupyerTemplate or self.tData.nOccupyerHeroId
		local tHeroData = getHeroDataById(nHeroId)
		if tHeroData then
			if self.tData.nOccupyerIg then
				tHeroData.nIg = self.tData.nOccupyerIg
			end
			local pTxtCollectTime = self.pDlgCollectResource:getTxtCollectTime()
			if pTxtCollectTime then
				local tCollectTime = getWorldInitData("collectTime")
				local nTime = tCollectTime[tHeroData.nQuality] or 0 --秒 武将所能采集的最大时间
				local nRemainTime = self.tData.nRemainRes/self.tMine.crop * 3600 --秒 剩余资源的最大时间
				--剩余资源/采集速度最大值
				nCanTime = math.min(nRemainTime, nTime)
				local tStr = {
			    	{color=_cc.white,text=getConvertedStr(3, 10122)},
			    	{color=_cc.green,text=formatTimeToHms(nCanTime)},
			    }

				pTxtCollectTime:setString(tStr)
			end
			-- --采集队列显示
			-- local tMyHero = Player:getHeroInfo():getHero(nHeroId)
			-- if tMyHero and tMyHero:getIsCollectQueue() then
			-- 	self.pImgCai:setVisible(true)
			-- else
			-- 	self.pImgCai:setVisible(false)
			-- end
		end
		--预计收获
		local pTxtPreview = self.pDlgCollectResource:getTxtPreview()
		if pTxtPreview then
			-- local nPreview = WorldFunc.getCollectPreview(nHeroId, self.tMine.id)
			--基础值
			local nPreview = WorldFunc.getCollectPreviewBase(self.tMine.id, nCanTime/3600)
			local nCanGet = math.min(self.tData.nRemainRes, nPreview)

			local tStr = {
		    	{color=_cc.white,text=getConvertedStr(3, 10123)},
		    	{color=_cc.blue,text=getResourcesStr(nCanGet)},
		    }
		     --额外加成
		    local nExtral = WorldFunc.getCollectPreviewEx(self.tMine.id, nCanGet)
		    if nExtral > 0 then
			 	local sExtralStr=string.format(getConvertedStr(9,10021),getResourcesStr(nExtral))
			    table.insert(tStr,{color=_cc.blue,text=sExtralStr})				
		    end
		    pTxtPreview:setString(tStr)
		end
		--按钮
		self.pBtn1:setButton(TypeCommonBtn.L_BLUE, getConvertedStr(3, 10058))
		self.pBtn1:onCommonBtnClicked(handler(self, self.onBtnCallClicked))
	else
		--采集时间
		local pTxtCollectTime = self.pDlgCollectResource:getTxtCollectTime()
		if pTxtCollectTime then
			local tStr = {
		    	{color=_cc.white,text=getConvertedStr(3, 10122)},
		    	{color=_cc.green,text="--"},
		    }
			pTxtCollectTime:setString(tStr)
		end
		--预计收获
		local pTxtPreview = self.pDlgCollectResource:getTxtPreview()
		if pTxtPreview then
			local tStr = {
		    	{color=_cc.white,text=getConvertedStr(3, 10123)},
		    	{color=_cc.blue,text="--"},
		    }

		    pTxtPreview:setString(tStr)
		end
		--按钮
		self.pBtn1:setButton(TypeCommonBtn.L_YELLOW, getConvertedStr(3, 10059))
		self.pBtn1:onCommonBtnClicked(handler(self, self.onBtnCollectClicked))
	end
	self.pImgCai:setVisible(self.tData.bOccupyerCHero)
	--国家旗子
	WorldFunc.setImgCountryFlag(self.pImgFlag, self.tData.nOccupyerCountry)
	--玩家名字和玩家等级
	self.pTxtName:setString(self.tData.sOccupyerName.. getLvString(self.tData.nOccupyerLv))


	--占领的英雄数据
	local nHeroId = self.tData.nOccupyerTemplate or self.tData.nOccupyerHeroId
	local tHeroData = getHeroDataById(nHeroId)
	if tHeroData then
		if self.tData.nOccupyerIg then
			tHeroData.nIg = self.tData.nOccupyerIg
 		end
		self.pTxtHeroName:setString(tHeroData.sName)
		setTextCCColor(self.pTxtHeroName, getColorByQuality(tHeroData.nQuality))
		self.pIconHero = getIconHeroByType(self.pLayHeroIcon, TypeIconHero.NORMAL, tHeroData, TypeIconHeroSize.L)
		if self.pIconHero then
			self.pIconHero:setHeroType()
		end
	end
	
	--英雄等级
	self.pTxtHeroLv:setString(getLvString(self.tData.nOccupyerHeroLv))
	--英雄兵力/兵力上限
	self.pRichtextTroops:updateLbByNum(1, tostring(self.tData.nOccupyerTroops))
	self.pRichtextTroops:updateLbByNum(2, "/"..tostring(self.tData.nOccupyerTroopsMax)) 

	--更新cd时间
	self:updateCd()
end

--更新cd时间
function CollectResourceOccupy:updateCd(  )
	if not self.tData then
		return
	end
	--是否是自己占领
	if self.tData.bIsMeOccupy then
		local nCd = self.tData:getOccupyerCdSystemTime()
		self.pTxtRemainCollectCd:setString(formatTimeToHms(nCd))
		if nCd <= 0 then
			unregUpdateControl(self)
		end
	else
		self.pTxtRemainCollectCd:setString("--")
		unregUpdateControl(self)
	end
end

--tData:tViewDotMsg
function CollectResourceOccupy:setData( tData)
	self.tData = tData
	self.tMine = getWorldMineData(self.tData.nMineID)
	self:updateViews()
end

function CollectResourceOccupy:onBtnCancelClicked(  )
	self.pDlgCollectResource:onCloseClicked()
end

function CollectResourceOccupy:onBtnCollectClicked(  )
	self.pDlgCollectResource:setBottomType(2)
end

function CollectResourceOccupy:onBtnCallClicked(  )
	local tTaskMsgList = Player:getWorldData():getTaskMsgByTPos(e_type_task.collection, self.tData.nX, self.tData.nY)
	local tTaskMsg = tTaskMsgList[1] --资源图只有一个
	if tTaskMsg then
		SocketManager:sendMsg("reqWorldTaskInput", {tTaskMsg.sUuid, e_type_task_input.call, nil})
	end
	self:onBtnCancelClicked()
end

return CollectResourceOccupy