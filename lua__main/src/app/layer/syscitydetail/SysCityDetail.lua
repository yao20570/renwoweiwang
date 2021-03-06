----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-02-1 10:45:00
-- Description: 系统城池新详细界面 子界面
-----------------------------------------------------
local DlgAlert = require("app.common.dialog.DlgAlert")
local MRichLabel = require("app.common.richview.MRichLabel")
local MCommonView = require("app.common.MCommonView")
local SysCityCollections = require("app.layer.world.SysCityCollections")
local SysCityDetailTop = require("app.layer.syscitydetail.SysCityDetailTop")
local SysCityDetailTopMing = require("app.layer.syscitydetail.SysCityDetailTopMing")
local nGoodsCol = 4
local SysCityDetail = class("SysCityDetail", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--nSysCityId :world_city id
function SysCityDetail:ctor( nSysCityId )
	self.nSysCityId = nSysCityId
	parseView("layout_sys_city_detail", handler(self, self.onParseViewCallback))
end

--解析界面回调
function SysCityDetail:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("SysCityDetail", handler(self, self.onSysCityDetailDestroy))

end

-- 析构方法
function SysCityDetail:onSysCityDetailDestroy(  )
    self:onPause()
end

function SysCityDetail:regMsgs(  )
	regMsg(self,ghd_update_city_owner_apply,handler(self,self.updateViews))
end

function SysCityDetail:unregMsgs(  )
	unregMsg(self,ghd_update_city_owner_apply)

end

function SysCityDetail:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function SysCityDetail:onPause(  )
	self:unregMsgs()
end

function SysCityDetail:setupViews(  )
	self.pTxtProtectCd = self:findViewByName("txt_protect_cd")
	self.pTxtTip = self:findViewByName("txt_tip")

	self.pTxtTip:setString(getTipsByIndex(10026))

	local pTxtBannerTip = self:findViewByName("txt_banner_tip")
	pTxtBannerTip:setString(string.format(getConvertedStr(3, 10138), getCostResName(e_type_resdata.prestige)))
	
	local pLayBtn1 = self:findViewByName("lay_btn1")
	self.pBtn1 = getCommonButtonOfContainer(pLayBtn1, TypeCommonBtn.L_BLUE, "1")

	local pLayBtn2 = self:findViewByName("lay_btn2")
	self.pBtn2 = getCommonButtonOfContainer(pLayBtn2, TypeCommonBtn.L_BLUE, "2")

	local pLayBtn3 = self:findViewByName("lay_btn3")
	self.pBtn3 = getCommonButtonOfContainer(pLayBtn3, TypeCommonBtn.L_BLUE, "3")

	local tCityData = getWorldCityDataById(self.nSysCityId)
	if tCityData then
		local pLayInfo = self:findViewByName("lay_info")
		setGradientBackground(pLayInfo)
		--加载不同的上层信息
		if tCityData.kind == e_kind_city.mingcheng then --名城
			local pCityDetailTopMing = SysCityDetailTopMing.new(self.nSysCityId)
			pLayInfo:addView(pCityDetailTopMing)
			self.pCityDetailTopMing = pCityDetailTopMing
		--普通城
		else
			local pCityDetailTopSys = SysCityDetailTop.new(self.nSysCityId)
			pLayInfo:addView(pCityDetailTopSys)
			self.pCityDetailTopSys = pCityDetailTopSys
		end

		--奖励图纸
		self.pLayRewards = self:findViewByName("lay_rewards")
	    self.pListView = MUI.MListView.new {
	        viewRect   = cc.rect(0, 0, self.pLayRewards:getContentSize().width, self.pLayRewards:getContentSize().height),
	        direction  = MUI.MScrollView.DIRECTION_VERTICAL,
	        itemMargin = {left =  0,
	             right =  0,
	             top =  5,
	             bottom =  5},
	    }
	    self.pLayRewards:addView(self.pListView)
	    self.pListView:setItemCount(0) 
	    self.pListView:setItemCallback(handler(self, self.onListViewItemCallBack))
	end

	--添加活动便签
	local nActivityId=getIsShowActivityBtn(e_dlg_index.syscitydetail)
	self.pLayActBtn=self:findViewByName("lay_act_btn")
    if nActivityId>0 then
    	self.pActBtn = addActivityBtn(self.pLayActBtn,nActivityId)
    else
    	if self.pActBtn then
    		self.pActBtn:removeSelf()
    		self.pActBtn=nil
    	end
    end
end

--列表回调
function SysCityDetail:onListViewItemCallBack( _index, _pView)
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

function SysCityDetail:updateViews(  )
	if not self.nSysCityId then
		return
	end
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	if not tViewDotMsg then
		return
	end
	local tWorldCityData = getWorldCityDataById(self.nSysCityId)
	if tWorldCityData and tWorldCityData.kind == e_kind_city.mingcheng then
		self.pTxtTip:setString(getTipsByIndex(20085))
		self.pLayActBtn:setVisible(tViewDotMsg.nSysCountry ~= Player:getPlayerInfo().nInfluence)
	else
		self.pTxtTip:setString(getTipsByIndex(10026))

	end

	
	--群雄势力（没有城主)
	if tViewDotMsg.nSysCountry == e_type_country.qunxiong then
		self.pBtn1:setVisible(false)
		self.pBtn2:setVisible(false)
		self.pBtn3:setVisible(false)
	else
		--有城主
		if tViewDotMsg:getIsSysCityHasOwner() then
			--同势力有城主
			if tViewDotMsg.nSysCountry == Player:getPlayerInfo().nInfluence then
				--城主是自己
				if tViewDotMsg.nSysCityOwnerId == Player:getPlayerInfo().pid then
					self.pBtn1:setVisible(true)
					self:setBtnResign(self.pBtn1)

					self.pBtn2:setVisible(false)					
				else
					self.pBtn1:setVisible(true)
					self:setBtnTalk(self.pBtn1)

					self.pBtn2:setVisible(false)
				end	
				self.pBtn3:setVisible(true)
				self:setBtnFill(self.pBtn3)
			else
				--不同势力有城主
				self.pBtn1:setVisible(false)
				self.pBtn2:setVisible(false)
				self.pBtn3:setVisible(false)
			end
		else
			--同势力没有城主
			if tViewDotMsg.nSysCountry == Player:getPlayerInfo().nInfluence then
				self.pBtn1:setVisible(false)

				self.pBtn2:setVisible(true)
				self:setBtnReBuild(self.pBtn2)

				self.pBtn3:setVisible(false)
			else
				--不同势力没有城主
				self.pBtn1:setVisible(false)
				self.pBtn2:setVisible(false)
				self.pBtn3:setVisible(false)
			end
		end
	end

	--掉落数据
	--奖励图纸
	local tCityData = getWorldCityDataById(tViewDotMsg.nSystemCityId)
	if tCityData then
		local tDropList = getDropById(tCityData.drop)
		if tDropList then
			local bIsReload = true
			if self.tDropList then
				if math.ceil(#self.tDropList/nGoodsCol) == math.ceil(#tDropList/nGoodsCol) then
					bIsReload = false
				end
			end
			self.tDropList = tDropList
			if bIsReload then
				if self.pListView:getItemCount() > 0 then
				    self.pListView:removeAllItems()
				end
				self.pListView:setItemCount(math.ceil(#self.tDropList/nGoodsCol))
			    self.pListView:reload()
			else
				self.pListView:notifyDataSetChange(true)
			end
		end
	end
	
	--更新
	self:updateProtectCd()
end

--任务期结束关闭界面
function SysCityDetail:closeDlgByCdOver( )
	if not self.nSysCityId then
		return
	end
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	if not tViewDotMsg then
		return
	end

	local nCd = tViewDotMsg:getRetireTime()
	if nCd > 0 then
		self.bIsCdOverCheck = true
	end
	if nCd <= 0 then
		--如果之前是cd遇过大于0就关闭
		if self.bIsCdOverCheck then
			self.bIsCdOverCheck = false
			self:closeDlg(false)
		end
		-- unregUpdateControl(self)
	end
end

--更新保护cd
function SysCityDetail:updateProtectCd()
	if not self.nSysCityId then
		return
	end
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	if not tViewDotMsg then
		return
	end

	local nCd = tViewDotMsg:getProtectCd()
	if nCd > 0 then
		local tStr = {
		    {color=_cc.pwhite,text=getConvertedStr(3, 10434).." "},
		    {color=_cc.red,text=formatTimeToMs(nCd)},
		}
		self.pTxtProtectCd:setString(tStr)
	else
		local tStr = {
		    {color=_cc.pwhite,text=getConvertedStr(3, 10434).." "},
		    {color=_cc.red,text=getConvertedStr(3, 10139)},
		}
		self.pTxtProtectCd:setString(tStr)
	end
end

--更新cd
function SysCityDetail:updateCd()
	self:updateProtectCd()
	self:closeDlgByCdOver()
end

function SysCityDetail:onTalkClicked( pView )
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	if not tViewDotMsg then
		return 
	end
	--dump(tViewDotMsg, "tViewDotMsg", 100)
	-- local tObject = {} 
	-- tObject.nType = e_dlg_index.dlgchat --dlg类型
	-- tObject.nChatType = e_lt_type.sl --聊天类型
	-- tObject.tPChatInfo = {
	-- 	nPlayerId = tViewDotMsg.nsyscityowner,
	-- 	sPlayerName = tViewDotMsg.sLeader,
	-- }
	-- sendMsg(ghd_show_dlg_by_type,tObject)
	--dump(tViewDotMsg, "tViewDotMsg", 100)
	local pMsgObj = {}
	pMsgObj.nplayerId =tViewDotMsg.nSysCityOwnerId
	pMsgObj.bToChat = true
	pMsgObj.nCloseHandler = function ()
		-- body
		--关闭自己
		closeDlgByType(e_dlg_index.syscitydetail, false)
	end
	--发送获取其他玩家信息的消息
	sendMsg(ghd_get_playerinfo_msg, pMsgObj)			
end

--重建
function SysCityDetail:onReBuildClicked( pView )
	--是否满足级数
	local nNeedLv = getWorldInitData("leaderLvLimit")
	if Player:getPlayerInfo().nLv < nNeedLv then
		TOAST(string.format(getConvertedStr(3, 10447), nNeedLv))
		return
	end

	if not self.nSysCityId then
		return
	end
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	if not tViewDotMsg then
		return
	end
	--有城的情况下直接返回
	local bIsBe = Player:getCountryData():isPlayerBeCityMaster()
	if bIsBe then
		TOAST(getTipsByIndex(568))
		return
	end
	--判断是否已经申请中
	-- if tViewDotMsg.bIsApplyCityOwner then
		--申请候选人命令
		SocketManager:sendMsg("reqWorldCityCandidate", {self.nSysCityId, 0})
	-- else
		

	-- 	--打开申请界面
	-- 	local tObject = {
	-- 	    nType = e_dlg_index.cityownerapply, --dlg类型
	-- 	    nSysCityId = self.nSysCityId,
	-- 	}
	-- 	sendMsg(ghd_show_dlg_by_type, tObject)
	-- end
	--关闭自己
	-- closeDlgByType(e_dlg_index.syscitydetail)
end

--卸任
function SysCityDetail:onResignClicked( pView )
	if not self.nSysCityId then
		return
	end
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	if not tViewDotMsg then
		return
	end

	local pDlg, bNew = getDlgByType(e_dlg_index.alert)
    if(not pDlg) then
        pDlg = DlgAlert.new(e_dlg_index.alert)
    end
    pDlg:setTitle(getConvertedStr(3, 10091))

    local tStr = {
    	{color=_cc.white,text=getConvertedStr(3, 10196)},
	    {color=_cc.blue,text=tViewDotMsg:getDotName()},
	    {color=_cc.white,text=getConvertedStr(3, 10197)},
	}
	local pRichLabel = MRichLabel.new({str = tStr, fontSize = 20, rowWidth = 380})
    pDlg:addContentView(pRichLabel)
    pDlg:setRightHandler(function (  )
        SocketManager:sendMsg("reqWorldAbandonCityOwner", {self.nSysCityId}, function ( __msg, __oldMsg )
        	if  __msg.head.state == SocketErrorType.success then 
	            if __msg.head.type == MsgType.reqWorldAbandonCityOwner.id then
	            	--设置未申请过
	            	local nCityId = __oldMsg[1]
	            	local tViewDotMsg = Player:getWorldData():getSysCityDot(nCityId)
	            	if tViewDotMsg then
	            		tViewDotMsg:setIsApplyCityOwner(false)
	            	end
	            end
	        else
	            TOAST(SocketManager:getErrorStr(__msg.head.state))
	        end
        end)
        -- self:closeDlg(false) --关掉自己
        closeDlgByType(e_dlg_index.syscitydetail)
        pDlg:closeDlg(false) --关掉对话框
    end)
    pDlg:showDlg(bNew)
end

function SysCityDetail:onFillClicked( pView )
	if not self.nSysCityId then
		return
	end
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	if not tViewDotMsg then
		return
	end

	if tViewDotMsg:getIsCanFillCityDef() then
		WorldFunc.fillSysCityTroops(self.nSysCityId)
	else
		TOAST(getConvertedStr(3, 10371))
	end
end

function SysCityDetail:onDotChange( sMsgName, pMsgObj )
	--更新资源点更新
	local tViewDotMsg = pMsgObj
	if tViewDotMsg then
		if tViewDotMsg.nSystemCityId == self.nSysCityId then
			if self.pCityDetailTopMing then
				self.pCityDetailTopMing:onResume()
			end
			if self.pCityDetailTopSys then
				self.pCityDetailTopSys:onResume()
			end
			self:updateViews()
		end
	end
end

function SysCityDetail:updateName( )
	if self.pCityDetailTopMing then
		self.pCityDetailTopMing:updateName()
	end
	if self.pCityDetailTopSys then
		self.pCityDetailTopSys:updateName()
	end
end

--设置卸任
function SysCityDetail:setBtnResign( pBtn )
	if not pBtn then
		return
	end
	pBtn:setButton(TypeCommonBtn.L_BLUE, getConvertedStr(3, 10093))
	pBtn:onCommonBtnClicked(handler(self, self.onResignClicked))
end

--设置填充
function SysCityDetail:setBtnFill( pBtn )
	if not pBtn then
		return
	end
	pBtn:setButton(TypeCommonBtn.L_BLUE, getConvertedStr(3, 10094))
	pBtn:onCommonBtnClicked(handler(self, self.onFillClicked))
end

--设置聊天
function SysCityDetail:setBtnTalk( pBtn )
	if not pBtn then
		return
	end
	pBtn:updateBtnText(getConvertedStr(3, 10092))
	pBtn:onCommonBtnClicked(handler(self, self.onTalkClicked))
end

--设置重建
function SysCityDetail:setBtnReBuild( pBtn )
	if not pBtn then
		return
	end
	pBtn:updateBtnText(getConvertedStr(9, 10189))
	pBtn:onCommonBtnClicked(handler(self, self.onReBuildClicked))
end

return SysCityDetail


