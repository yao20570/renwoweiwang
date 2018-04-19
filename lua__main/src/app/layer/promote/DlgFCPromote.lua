----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-14 17:08:51
-- Description: 战斗力提升途径界面
-----------------------------------------------------

-- 战斗力提升途径界面
local DlgBase = require("app.common.dialog.DlgBase")
local ItemFCPromote = require("app.layer.promote.ItemFCPromote")
local DlgFCPromote = class("DlgFCPromote", function()
	return DlgBase.new(e_dlg_index.fcpromote)
end)

function DlgFCPromote:ctor(  )
	parseView("dlg_fc_promote", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgFCPromote:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层

	self:setTitle(getConvertedStr(3, 10299))

	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgFCPromote",handler(self, self.onDlgFCPromoteDestroy))
end

-- 析构方法
function DlgFCPromote:onDlgFCPromoteDestroy(  )
    self:onPause()
end

function DlgFCPromote:regMsgs(  )
	regMsg(self, gud_fc_promote_my_rank_info, handler(self, self.onMyRankInfo))
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updatePlayerInfo))
end

function DlgFCPromote:unregMsgs(  )
	unregMsg(self, gud_fc_promote_my_rank_info)
	unregMsg(self, gud_refresh_playerinfo)
end
-- _bReshow(bool): 是否是在后台切回来而已
function DlgFCPromote:onResume( _bReshow )
	-- 再次进入界面，定位到顶部
	if(_bReshow and self.pListView) then
		self.pListView:scrollToBegin()
	end
	self:updateViews()
	self:regMsgs()
end

function DlgFCPromote:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function DlgFCPromote:updateViews(  )
	gRefreshViewsAsync(self, 3, function ( _bEnd, _index )
		if(_index == 1) then
			--战力
			self:updatePlayerInfo()
			if(not self.pLbTmp) then
				--头顶横条
				local pLayBanner = self:findViewByName("lay_banner_bg")
				setMBannerImage(pLayBanner, TypeBannerUsed.zltj)

				self.pLbTmp = self:findViewByName("txt_fc_title")
				self.pLbTmp:setString(getConvertedStr(3, 10300))
				self.pLbTmp = self:findViewByName("txt_world_rank_title")
				self.pLbTmp:setString(getConvertedStr(3, 10301))
				self.pLbTmp = self:findViewByName("txt_country_rank_title")
				self.pLbTmp:setString(getConvertedStr(3, 10302))
				local pTxtRankRefreshTip1 = self:findViewByName("txt_rank_refresh_tip1")
				pTxtRankRefreshTip1:setString(getConvertedStr(3, 10304))
				setTextCCColor(pTxtRankRefreshTip1, _cc.gray)
				local pTxtRankRefreshTip2 = self:findViewByName("txt_rank_refresh_tip2")
				pTxtRankRefreshTip2:setString(getConvertedStr(3, 10304))
				setTextCCColor(pTxtRankRefreshTip2, _cc.gray)
			end
			--查看排行按钮
			if(not self.pBtnRank) then
				local pLayBtnRank = self:findViewByName("lay_btn_rank")
				self.pBtnRank = getCommonButtonOfContainer(pLayBtnRank, TypeCommonBtn.M_BLUE, getConvertedStr(3, 10305))
				self.pBtnRank:onCommonBtnClicked(handler(self, self.onRankClicked))
			end
			--战力评分按钮
			if (not self.pBtnPower) then
				local pLayPower = self:findViewByName("lay_btn_power")
				self.pBtnPower = getCommonButtonOfContainer(pLayPower, TypeCommonBtn.M_BLUE, getConvertedStr(7, 10304))
				self.pBtnPower:onCommonBtnClicked(handler(self, self.onPowerClicked))
			end
			--世界排名
			if(not self.pTxtWorldRank) then
				self.pTxtWorldRank = self:findViewByName("txt_world_rank")
			end
			local nWorldRank = Player:getRankInfo():getWorldRank()
			if nWorldRank then
				if nWorldRank == -1 then
					self.pTxtWorldRank:setString(getConvertedStr(3, 10303))
					setTextCCColor(self.pTxtWorldRank, _cc.red)
				else
					self.pTxtWorldRank:setString(nWorldRank)
					setTextCCColor(self.pTxtWorldRank, _cc.blue)
				end
			end
			if(not self.pTxtCountryRank) then
				self.pTxtCountryRank = self:findViewByName("txt_country_rank")
			end
			--国内排名
			local nCountryRank = Player:getRankInfo():getCountryRank()
			if nCountryRank then
				if nCountryRank == -1 then
					self.pTxtCountryRank:setString(getConvertedStr(3, 10303))
					setTextCCColor(self.pTxtCountryRank, _cc.red)
				else
					self.pTxtCountryRank:setString(nCountryRank)
					setTextCCColor(self.pTxtCountryRank, _cc.blue)
				end
			end
		elseif(_index == 2) then
			if(not self.pListView) then
				local pLayListView = self:findViewByName("lay_listview")
			    self.pListView = MUI.MListView.new {
			        viewRect   = cc.rect(0, 0, pLayListView:getContentSize().width, pLayListView:getContentSize().height),
			        direction  = MUI.MScrollView.DIRECTION_VERTICAL,
			        itemMargin = {left =  0,
			             right =  0,
			             top =  5,
			             bottom =  10},
			    }
			    pLayListView:addView(self.pListView)
			    centerInView(pLayListView, self.pListView )
			    self.tCombatUpData = getAllCombatUpList()
			    self.pListView:setItemCount(#self.tCombatUpData)
			    self.pListView:setItemCallback(function ( _index, _pView ) 
			        local pItemData = self.tCombatUpData[_index]
			        local pTempView = _pView
			        if pTempView == nil then
			            pTempView = ItemFCPromote.new()
			        end
			        pTempView:setData(pItemData)
			        return pTempView
			    end)
			    -- 载入所有展示的item
			    self.pListView:reload(true)
			end
		end
		if(_bEnd) then
			self:regMsgs()
			regUpdateControl(self, handler(self, self.checkReq))
			--请求检测
			self:checkReq()
		end
	end)
end

function DlgFCPromote:updatePlayerInfo(  )
	--战力
	if(not self.pRichTextFc) then
		local pLayRichTextFc = self:findViewByName("lay_richtext_fc")
		self.pRichTextFc = MUI.MLabel.new({text="",size=20})
		self.pRichTextFc:setAnchorPoint(cc.p(0, 0))
		pLayRichTextFc:addView(self.pRichTextFc)
	end
	--多文本
	local tStr = {
	    {color=_cc.yellow,text=""},
	    {color=_cc.white,text=""},
	}
	local nScore = Player:getPlayerInfo().nScore
	tStr[2].text = nScore .. ""
	if getIsFormatCount(nScore) then
		tStr[2].text = string.format("(%s)", getResourcesStr(nScore))
	end
	self.pRichTextFc:setString(tStr)
end

function DlgFCPromote:onRankClicked( pView )
	--发送消息打开dlg
	local tObject = {
	    nType = e_dlg_index.dlgrank, --dlg类型
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

--点击战力评分
function DlgFCPromote:onPowerClicked( pView )
	-- body
	local nPlayerId = tonumber(Player:getPlayerInfo().pid) --玩家id
	local tObject = {}
	tObject.nPlayerId = nPlayerId
	if nPlayerId == Player.baseInfos.pid then          --战力评估
		tObject.nType = e_dlg_index.dlgpowermark       --dlg类型	
	else
		tObject.nType = e_dlg_index.dlgpowerbalance    --dlg类型
	end
	sendMsg(ghd_show_dlg_by_type, tObject)
end

--请求检测
function DlgFCPromote:checkReq()
	--发送请求终止自更新
	if Player:getRankInfo():getIsNeedReqMyRankInfo() then
		SocketManager:sendMsg("getMyRankInfo", {})
		unregUpdateControl(self)
	end
end

function DlgFCPromote:onMyRankInfo( )
	regUpdateControl(self, handler(self, self.checkReq))
	self:updateViews()
end

return DlgFCPromote