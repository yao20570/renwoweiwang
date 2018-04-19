-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-24 11:28:32 星期一
-- Description: 建筑升级对话框
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local ItemBuildLvUp = require("app.layer.build.ItemBuildLvUp")
local MBtnExText = require("app.common.button.MBtnExText")

local DlgBuildLvUp = class("DlgBuildLvUp", function()
	-- body
	return DlgBase.new(e_dlg_index.buildlvup)
end)

--_nBuildCell：建筑格子下标
function DlgBuildLvUp:ctor( _nBuildCell, _nFromWhat )
	-- body
	self:myInit()
	self:updateCell(_nBuildCell, _nFromWhat)
	parseView("dlg_build_lvup", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgBuildLvUp:myInit(  )
	-- body
	self.pBuildInfos 		= nil 			--建筑数据
	self.nCloseMsgType 		= 1 			--关闭界面消息类型 1：正常 2：跳转到王宫
	self.nFromWhat 			= 0  			--1 or 2 表示从左边对联点击的

	self.nBuildCell 		= nil
end

--解析布局回调事件
function DlgBuildLvUp:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgBuildLvUp",handler(self, self.onDlgBuildLvUpDestroy))
end

--初始化控件
function DlgBuildLvUp:setupViews( )
	-- body
	--背景设置为透明的
	self:setContentBgTransparent()
	--设置标题
	self:setTitle(getConvertedStr(1, 10084))
	--顶部层
	self.pLayTop 				= self:findViewByName("lay_up_banner")
	--等级名字
	self.pLbLvName 				= self:findViewByName("lb_lv")
	--下一等级
	self.pLbNextLv 				= self:findViewByName("lb_next_lv")
	--中间升级需求层
	self.pLayDetails 			= self:findViewByName("lay_up_details")
	--底部层
	self.pLayBottom 			= self:findViewByName("lay_up_bottom")

	--左右两个按钮
	self.pLayLeft 				= self:findViewByName("lay_btn_left")
	self.pLayRight 				= self:findViewByName("lay_btn_right") 
	self.pBtnLeft = getCommonButtonOfContainer(self.pLayLeft,TypeCommonBtn.L_YELLOW,getConvertedStr(1,10088))
	self.pBtnRight = getCommonButtonOfContainer(self.pLayRight,TypeCommonBtn.L_BLUE,getConvertedStr(1,10089))
	--按钮点击事件
	self.pBtnRight:onCommonBtnClicked(handler(self, self.onRightClicked))
	self.pBtnLeft:onCommonBtnClicked(handler(self, self.onLeftClicked))


	--金币消费提示
	local tBtnTable = {}
	--金币icon
	tBtnTable.img = "#v1_img_qianbi.png"
	--文本
	tBtnTable.tLabel = {{"1",getC3B(_cc.pwhite)}}
	self.pBtnLeftExText = self.pBtnLeft:setBtnExText(tBtnTable,false)

	--倒计时
	--按钮上的时间提示
	local tBtnTable = {}
	tBtnTable.parent = self.pBtnRight
	tBtnTable.img = "#v1_img_shizhong.png"
	--文本
	tBtnTable.tLabel = {
		{"00:00:00",getC3B(_cc.pwhite)},
	}
	self.pBtnExText = MBtnExText.new(tBtnTable,false)
	
	--建筑描述
	self.pLbDesc1 = MUI.MLabel.new({
	    text = "",
	    size = 20,
	    anchorpoint = cc.p(0, 0.5),
	    align = cc.ui.TEXT_ALIGNMENT_CENTER,
		valign = cc.ui.TEXT_VALIGN_TOP,
	    color = cc.c3b(255, 255, 255),
	    dimensions = cc.size(220, 0),
	    })
	self.pLayTop:addView(self.pLbDesc1)
	self.pLbDesc1:setPosition(360,130)

	self.pLbDesc2 = MUI.MLabel.new({
	    text = "",
	    size = 20,
	    anchorpoint = cc.p(0, 0.5),
	    align = cc.ui.TEXT_ALIGNMENT_CENTER,
		valign = cc.ui.TEXT_VALIGN_TOP,
	    color = cc.c3b(255, 255, 255),
	    dimensions = cc.size(255, 0),
	    })
	self.pLayTop:addView(self.pLbDesc2)
	self.pLbDesc2:setPosition(330,80)


	--国际化语言
	local pLbText 				= self:findViewByName("lb_next_tips")
	pLbText:setString(getConvertedStr(1, 10085))
	pLbText 					= self:findViewByName("lb_tips")
	pLbText:setString(getConvertedStr(1, 10086))
	pLbText 					= self:findViewByName("lb_tips2")
	pLbText:setString(getConvertedStr(1, 10087))
	setTextCCColor(pLbText,_cc.gray)

end

-- 修改控件内容或者是刷新控件数据
function DlgBuildLvUp:updateViews(  )
	-- body
	if self.pBuildInfos then
		-- 隐藏所有按钮的状态，后面的刷新会重新正常显示，减少从按钮到打勾图片的突兀性
		for i = 1, 7 do
			local pItem = self.pLayDetails:findViewByName("item_build_index_" .. i)
			if pItem and pItem.pLayAction then
				pItem.pLayAction:setVisible(false)
			end
		end
		gRefreshViewsAsync(self, 2, function ( _bEnd, _index )
			if(_index == 1) then
				--新手引导指引升级
				local nCurrStepId = Player:getNewGuideMgr():getCurrStepId()
				local tGuideData = getGuideData(nCurrStepId)
				if tGuideData and tGuideData.specialstep then
					local tSpecial = luaSplit(tGuideData.specialstep, ":")
					local nCurTaskId = Player:getPlayerTaskInfo():getCurAgencyTask().sTid
					if tonumber(tSpecial[1]) == e_special_type.build_lvup and
						self.pBuildInfos.nCellIndex == tonumber(tSpecial[2]) and
						self.pBuildInfos.nLv == (tonumber(tSpecial[3]) - 1) and 
						nCurTaskId == tonumber(tSpecial[4]) then
						self.pBtnRight:showLingTx()
					else
						self.pBtnRight:removeLingTx()
					end
				end
				--等级名字
				self.pLbLvName:setString(getLvString(self.pBuildInfos.nLv,false) .. " " .. self.pBuildInfos.sName)
				--描述1
				self.pLbDesc1:setString(getTextColorByConfigure(self.pBuildInfos.sDes))
				--下一等级
				if self.pBuildInfos:isBuildMaxLv() == false then
					self.pLbNextLv:setString(getLvString((self.pBuildInfos.nLv + 1),false))
					--描述2
					local tData = getBuildUpLimitsFromDB(self.pBuildInfos.sTid,self.pBuildInfos.nLv)
					if tData then
						if tData.desc and #tData.desc > 0 then
							self.pLbDesc2:setString(getTextColorByConfigure(tData.desc))
						else
							self.pLbDesc2:setString("")
						end
					else
						self.pLbDesc2:setString("")
					end
				else
					self.pLbDesc2:setString("")
				end
				--设置立即升级消耗金币
				local nCost = self.pBuildInfos:getBuildFinishValue()
				self.pBtnLeftExText:setLabelCnCr(1,nCost)
			elseif(_index == 2) then
				--第一条需求为建造队列（肯定是存在）
				self:refreshBuildingState()
				--升级所需的内容
				self.__tLimits = self.pBuildInfos:getBuildUpLimits()
				self.__mLimitIndex = 2
				local tLimits = self.__tLimits
				if tLimits then
					--升级时间
					local fBuildTime = self.pBuildInfos:getBuildUpLvTime()
					--获取建造buff
					local tBuildBuffVos = Player:getBuffData():getBuildBuffList()
					if table.nums(tBuildBuffVos) > 0 then
						for nId, vo in pairs(tBuildBuffVos) do
							local tBuffData = getBuffDataByIdFromDB(nId)
							for k, v in pairs(tBuffData.tEffects) do
								fBuildTime = (1 - tonumber(v[2])) * fBuildTime
							end
						end
					end

					self.pBtnExText:setLabelCnCr(1,formatTimeToHms(fBuildTime))
				end
				--工坊的独立处理
				if self.pBuildInfos.sTid == e_build_ids.atelier and
					self.pBuildInfos.nState ~= e_build_state.free then
			    	--数据初始化
			    	local tT = {}
			    	tT.nType = e_build_uplimit_key.unfree
			    	tT.nValue = getConvertedStr(6, 10638)
			    	--获得item
			    	local pItem = self:getLimitItemByIndex(self.__mLimitIndex)
			    	pItem:setCurData(tT)
			    	self.__mLimitIndex = self.__mLimitIndex + 1										
				end 

				local tLimits = self.__tLimits
				if(tLimits) then
				    --主公等级限制
				    if tonumber(tLimits.playerlv) > 0 then
				    	--数据初始化
				    	local tT = {}
				    	tT.nType = e_build_uplimit_key.playerLv
				    	tT.nValue = tonumber(tLimits.playerlv)
				    	--获得item
				    	local pItem = self:getLimitItemByIndex(self.__mLimitIndex)
				    	pItem:setCurData(tT)
				    	self.__mLimitIndex = self.__mLimitIndex + 1
				    end
				end
				local tLimits = self.__tLimits
				if(tLimits) then
				    --王宫等级限制
				    if tonumber(tLimits.palacelv) > 0 then
				    	--数据初始化
				    	local tT = {}
				    	tT.nType = e_build_uplimit_key.palaceLv
				    	tT.nValue = tonumber(tLimits.palacelv)
				    	--获得item
				    	local pItem = self:getLimitItemByIndex(self.__mLimitIndex)
				    	pItem:setCurData(tT)
				    	self.__mLimitIndex = self.__mLimitIndex + 1
				    end
				end
				local tLimits = self.__tLimits
				local tResList = {}
				local pTongItem = nil
				local pMuItem = nil
				if(tLimits) then
				    --铜
				    if tonumber(tLimits.coincost) > 0 then
				    	--数据初始化
				    	local tT = {}
				    	tT.nType = e_build_uplimit_key.tong
				    	tT.nValue = tonumber(tLimits.coincost)
				    	--获得item
				    	local pItem = self:getLimitItemByIndex(self.__mLimitIndex)
				    	pTongItem = pItem
				    	pItem:setCurData(tT)
				    	self.__mLimitIndex = self.__mLimitIndex + 1
				    end
-- 				    --资源id
				   	if tLimits.coincost then
				    	tResList[e_resdata_ids.yb] = tonumber(tLimits.coincost)
				    else
				    	tResList[e_resdata_ids.yb] = 0
				    end
				end
				local tLimits = self.__tLimits
				if(tLimits) then
				    --木
				    if tonumber(tLimits.woodcost) > 0 then
				    	--数据初始化
				    	local tT = {}
				    	tT.nType = e_build_uplimit_key.mu
				    	tT.nValue = tonumber(tLimits.woodcost)
				    	--获得item
				    	local pItem = self:getLimitItemByIndex(self.__mLimitIndex)
				    	pMuItem = pItem
				    	pItem:setCurData(tT)
				    	self.__mLimitIndex = self.__mLimitIndex + 1
				    end
				    if tLimits.woodcost then
				    	tResList[e_resdata_ids.mc] = tonumber(tLimits.woodcost)
				    else
				    	tResList[e_resdata_ids.mc] = 0
				    end
				end
				--添加需要值用来显示批量使用界面
				tResList[e_resdata_ids.lc] = 0
				tResList[e_resdata_ids.bt] = 0
				self.tResList = tResList
				if pTongItem and pTongItem.setResList then
					pTongItem:setResList(tResList)
				end
				if pMuItem and pMuItem.setResList then
					pMuItem:setResList(tResList)
				end
				--隐藏不需要的item
				for i = self.__mLimitIndex, 7 do
					local pItem = self.pLayDetails:findViewByName("item_build_index_" .. i)
					if pItem then
						pItem:setVisible(false)
					end
				end
			end
		end)
	end 

end

-- 析构方法
function DlgBuildLvUp:onDlgBuildLvUpDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgBuildLvUp:regMsgs( )
	-- body
	-- 注册关闭建筑升级对话框消息
	regMsg(self, ghd_close_buildup_dlg_msg, handler(self, self.onCloseByCellIndex))
	-- 注册建筑数据发生变化的消息
	regMsg(self, gud_build_data_refresh_msg, handler(self, self.onRefreshBuildDatas))
	-- 注册玩家数据变化的消息
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateViews))
	-- 注册建筑状态变化消息
	regMsg(self, gud_build_state_change_msg, handler(self, self.updateCurBuild))
end

-- 注销消息
function DlgBuildLvUp:unregMsgs(  )
	-- body
	-- 销毁关闭建筑升级对话框消息
	unregMsg(self, ghd_close_buildup_dlg_msg)
	-- 销毁建筑数据发生变化的消息
	unregMsg(self, gud_build_data_refresh_msg)
	-- 销毁玩家数据变化的消息
	unregMsg(self, gud_refresh_playerinfo)
	-- 注销建筑状态变化消息
	unregMsg(self, gud_build_state_change_msg)	

end


--暂停方法
function DlgBuildLvUp:onPause( )
	-- body
	self:unregMsgs()
	--发送消息缩小基地
	local tOb = {}
	tOb.nType = 2
	tOb.nChildType = self.nCloseMsgType
	sendMsg(ghd_scale_for_buildup_dlg_msg,tOb)

	--发送hometop界面调整消息
	local tmsgObj = {}
	tmsgObj.nType = 2
	sendMsg(ghd_home_change_for_buildup_msg, tmsgObj)
end

--继续方法
function DlgBuildLvUp:onResume( )
	-- body
	self.nCloseMsgType = 1
	self:updateViews()
	self:regMsgs()
	
end

--设置关闭当前对话框消息类型
function DlgBuildLvUp:setCloseMsgType( nType )
	-- body
	self.nCloseMsgType = nType
end

-- 左边按钮事件
function DlgBuildLvUp:onLeftClicked(pView)
	--工坊的独立处理
	if not self:isAtelierCanLvUp() then
		return
	end
	local bCan = self:checkIfCanUp(2)
	if bCan then
		local nCost = self.pBuildInfos:getBuildFinishValue()
		if nCost == 0 then --普通升级立即完成
			self:upBuildFast()
		else
		    local strTips ={
		    	{color=_cc.pwhite,text=getConvertedStr(1, 10111)},--立即完成建筑升级？
		    }
		    --展示购买对话框
			showBuyDlg(strTips,nCost,function (  )
				-- body
				self:upBuildFast()
			end)
		end
	end
end

-- 请求立即完成升级
function DlgBuildLvUp:upBuildFast(  )
	-- body
	local tObject = {}
	tObject.nType = -2 --普通升级立即完成
	tObject.nBuildId = self.pBuildInfos.sTid --建筑id
	tObject.nCell = self.pBuildInfos.nCellIndex --建筑格子下标
	sendMsg(ghd_up_build_msg,tObject)

	--新手引导
	Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.invisible_finger)
end

-- 右边按钮事件
function DlgBuildLvUp:onRightClicked(pView)
	--工坊的独立处理
	if not self:isAtelierCanLvUp() then
		return
	end
	local bCan = self:checkIfCanUp(1)
	if bCan then
		local tObject = {}
		tObject.nType = -1 --普通升级
		tObject.nBuildId = self.pBuildInfos.sTid --建筑id
		tObject.nFromWhat = self.nFromWhat or 0 --1,2表示从左边对联进来的
		tObject.nCell = self.pBuildInfos.nCellIndex --建筑格子下标
		sendMsg(ghd_up_build_msg,tObject)

		--新手引导
		Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.invisible_finger)
	end
end
--工坊的独立处理
function DlgBuildLvUp:isAtelierCanLvUp(  )
	-- body
	if self.pBuildInfos.sTid == e_build_ids.atelier and
		self.pBuildInfos.nState ~= e_build_state.free then
		TOAST(getConvertedStr(6, 10639))
		return false
	end	
	return true
end
--是否可以升级建筑
--nType: 是否需要坚持队列是否满足 1：需要 2：不需要
function DlgBuildLvUp:checkIfCanUp( nType )
	-- body
	if self.pBuildInfos then
		local bCan, tTips, resid = self.pBuildInfos:isBuildCanUp(nType)
		if not bCan then
			if tTips and table.nums(tTips) > 0 then
				-- for k, v in pairs (tTips) do
					-- doDelayForSomething(self,function (  )
					-- 	-- body
					-- 	TOAST(v .. "")
					-- end,((k - 1) * 1.0))
				-- end
				if tTips[1] == getConvertedStr(1,10104) then --主公等级不足
					TOAST(tTips[1] .. "")
				elseif tTips[1] == getConvertedStr(1,10105) then --王宫等级不足
					TOAST(tTips[1] .. "")
				elseif tTips[1] == getConvertedStr(1,10103) then --建筑队列不足
					TOAST(tTips[1] .. "")
					-- --判断是否已经开启
					-- local nHad = Player:getBuildData().nHadSecondQue
					-- if nHad == 1 then
						
					-- else
					-- 	TOAST(getConvertedStr(1, 10266))
					-- end
				else --资源不足
					goToBuyRes(resid,self.tResList)
				end
			end
		end
		return bCan
	else
		return false
	end
end


--获得资源需求item
--_nIndex：下标
function DlgBuildLvUp:getLimitItemByIndex( _nIndex )
	-- body
	local pItem = self.pLayDetails:findViewByName("item_build_index_" .. _nIndex)
	if not pItem then
		pItem = ItemBuildLvUp.new()
		pItem:setName("item_build_index_" .. _nIndex)
		pItem:setPositionY(self.pLayDetails:getHeight() - _nIndex * pItem:getHeight())
		self.pLayDetails:addView(pItem,10)
	end
	pItem:setVisible(true)
	pItem:setResList(nil)
	return pItem
end

--根据key获取对应的item项
function DlgBuildLvUp:getLimitItemByKey( _nKey )
	-- body
	local pCurItem = nil
	for i = 1, 7 do
		local pItem =  self.pLayDetails:findViewByName("item_build_index_" .. i)
		if pItem then
			local tCurData = pItem:getCurData()
			if tCurData and tCurData.nType == _nKey then
				pCurItem = pItem
				break
			end
		end
	end
	return pCurItem
end

--刷新建造队列情况
function DlgBuildLvUp:refreshBuildingState(  )
	-- body
	--数据初始化
	local tT = {}
	tT.nType = e_build_uplimit_key.team
	local nState, pBuild = Player:getBuildData():getBuildingQueState()
	tT.nValue = nState
	tT.pBuild = pBuild
	
	--获得item
	local pItem = self:getLimitItemByIndex(1)
	pItem:setCurData(tT)

end

--关闭当前界面回调事件
function DlgBuildLvUp:onCloseByCellIndex( sMsgName, pMsgObj )
	-- body
	if pMsgObj then
		local nCell = pMsgObj.nCell
		if self.pBuildInfos and nCell and nCell == self.pBuildInfos.nCellIndex then
			self:closeDlg(false)
		end
	end
end

--建筑数据变化回调
function DlgBuildLvUp:onRefreshBuildDatas( sMsgName, pMsgObj )
	-- body
	if pMsgObj then
		local nType = pMsgObj.nType
		if nType == 1 then 				--建造队列变化
			self:updateViews()
		end
	end
end
function DlgBuildLvUp:updateCell( _nBuildCell, _nFromWhat )
	
	if not _nBuildCell then
		print("建筑cellindex 不能为 nil")
	end
	self.nFromWhat = _nFromWhat or 0 --1 or 2 表示从左边对联点击的
	self.nBuildCell = _nBuildCell or 0
	if _nBuildCell > n_start_suburb_cell then
		self.pBuildInfos = Player:getBuildData():getSuburbByCell(_nBuildCell)
	else
		self.pBuildInfos = Player:getBuildData():getBuildByCell(_nBuildCell)
	end
	-- 由于updateView是分帧处理的，所以此处暂时不强制调用updateview，由外部去操作
end

function DlgBuildLvUp:updateCurBuild( sMsgName, pMsgObj )
	-- body
	local _nBuildCell = pMsgObj.nCell
	if not _nBuildCell then
		return
	end	
	if self.nBuildCell > n_start_suburb_cell then
		self.pBuildInfos = Player:getBuildData():getSuburbByCell(self.nBuildCell)
	else
		self.pBuildInfos = Player:getBuildData():getBuildByCell(self.nBuildCell)
	end		
	if self.nBuildCell ~= _nBuildCell then
		self:updateViews()
		return
	else
		if self.pBuildInfos then
			if self.pBuildInfos.nState == e_build_state.uping then--重连时候可能会出现的问题 --一般不会进入
				local tObject = {}
				tObject.nCell = self.nBuildCell
				sendMsg(ghd_close_buildup_dlg_msg,tObject)		
			else				
				self:updateViews()
			end
		end
	end
end
return DlgBuildLvUp