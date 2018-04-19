-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-07-04 17:53:04 星期二
-- Description: 基地建筑点击操作按钮展示层
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ItemBuildAction = require("app.layer.build.ItemBuildAction")

local BuildActionLayer = class("BuildActionLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function BuildActionLayer:ctor(  )
	-- body
	self:myInit()
	parseView("layout_action_for_build", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function BuildActionLayer:myInit(  )
	-- body
	self.tBuildDatas 			= 	nil 		--建筑数据
	self.tBtnLists 			 	= 	nil 		--按钮列表
	self.nMaxSize 				= 	4 			--按钮最大个数
	self.nFromWhat 				= 	0 			--是否是从左边对联升级 1：普通建造 2：黄金建造
	self.bItemSpeedTx 			= 	false       --是否有物品加速特效
end

--解析布局回调事件
function BuildActionLayer:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView, 10)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("BuildActionLayer",handler(self, self.onBuildActionLayerDestroy))
end

--初始化控件
function BuildActionLayer:setupViews( )
	-- body

	self.pImgYH = self:findViewByName("img_yuanhuan")
end

function BuildActionLayer:getYHImg(  )
	-- body
	return self.pImgYH
end

--显示特效
function BuildActionLayer:showTx()
	self.pImgYH:setOpacity(0)
	self.pImgYH:setScale(0.7)
	local tAction_1 = cc.Spawn:create(cc.ScaleTo:create(0.15, 1.02), cc.FadeIn:create(0.2))
	local tAction_2 = cc.ScaleTo:create(0.3,1)
	self.pImgYH:runAction(cc.Sequence:create(tAction_1, tAction_2))

	if not self.tBtnLists and table.nums(self.tBtnLists) == 0 then
		return
	end
	self.nShowConf = table.nums(self.tBtnLists)
	local nNum = 0
	local function showCb()
		nNum = nNum + 1
		if self.nShowConf >= nNum then
			local btn = self:findViewByName("build_action_index_" .. nNum)
			if  btn then
				btn:setVisible(true)
				btn:showTx()
				self:runAction(cc.Sequence:create(cc.DelayTime:create(0.04), cc.CallFunc:create(showCb)))
			end
		end
	end
	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(showCb)))
end

-- 修改控件内容或者是刷新控件数据
function BuildActionLayer:updateViews(  )
	-- body
	if self.tBuildDatas and self.tBtnLists then
		--新手引导重置按钮
		self.pLvUpItem = nil
		--新手引导重置按钮
		self.pEnterItem = nil
		--新手引导重置加速按钮
		self.pSpeedItem = nil
		--加速按钮重置
		self.pCurUpdateItem = nil

		--按钮个数
		local nRealSize = table.nums(self.tBtnLists)
		local nIndex = 1
		for i = 1, nRealSize do
			local pItemBtn = self:findViewByName("build_action_index_" .. i)
			if not pItemBtn then
				pItemBtn = ItemBuildAction.new()
				pItemBtn:setName("build_action_index_" .. i)
				pItemBtn:setItemClickedCallBack(handler(self, self.onActionItemClicked))
				self:addView(pItemBtn, 10)
			end
			pItemBtn:setVisible(false)
			local nX,nY = self:getPositionBySizeAndIndex(nRealSize,i)
			--设置位置
			pItemBtn:setPosition(nX - pItemBtn:getWidth() / 2, nY - pItemBtn:getHeight() / 2)
			nIndex = nIndex + 1
			pItemBtn:setBtnMsg(self.tBtnLists[i],self.tBuildDatas)
			if tonumber(self.tBtnLists[i]) == 4 then --加速，需要开启计时线程
				self.pCurUpdateItem = pItemBtn
				self:startUpdateHandler()
			end
			--新手引导记录按钮
			if tonumber(self.tBtnLists[i]) == 1 then --升级
				self.pLvUpItem = pItemBtn
			elseif tonumber(self.tBtnLists[i]) == 2 or tonumber(self.tBtnLists[i]) == 5 then --进入
				self.pEnterItem = pItemBtn
			end

			if tonumber(self.tBtnLists[i]) == 3 then --加速
				self.pSpeedItem = pItemBtn
			end
		end

		--隐藏多余的按钮控件
		for i = nIndex, self.nMaxSize do
			local pItemBtn = self:findViewByName("build_action_index_" .. i)
			if pItemBtn then
				pItemBtn:setVisible(false)
			end
		end
	end
end
--刷新按钮默认的特效显示
function BuildActionLayer:updateBtnTx( )
	-- body
	--加速按钮的默认特效显示 如果有加速道具支持当前加速项 则显示特效
	if self.pSpeedItem then
		local bShowBtnTx = false	
		if self.tBuildDatas.nState == e_build_state.uping or self.tBuildDatas.nState == e_build_state.producing
			or self.tBuildDatas.nState == e_build_state.creating then 				--升级中
			--新手引导
			local tFastItems = luaSplit(getDisplayParam("speedUpItem") or "", ";")					
			local tProps = nil
			if tFastItems and table.nums(tFastItems) > 0 then
				tProps = {}
				for k, v in pairs (tFastItems) do
					local pItem = nil
					if tonumber(v) ~= e_item_ids.jbjs then --排除金币加速			
						--从玩家身上查找
						pItem = Player:getBagInfo():getItemDataById(tonumber(v))
					end
					if pItem then
						table.insert(tProps, pItem)
					end
				end
			end			
			if tProps and #tProps > 0 then			
				bShowBtnTx = true	
			end		
		end		
		self.bItemSpeedTx = bShowBtnTx
		if bShowBtnTx then						
			self:playYellowRing(self.pSpeedItem, e_buildbtn_type.speedup)
		end
	end
end
--启动线程
function BuildActionLayer:startUpdateHandler(  )
	-- body
	regUpdateControl(self, handler(self, self.onUpdate))
end

--关闭线程
function BuildActionLayer:stopUpdateHandler(  )
	-- body
	unregUpdateControl(self)
	self.pCurUpdateItem = nil
end

--设置状态
function BuildActionLayer:setVisibleState( _bState )
	-- body
	if not _bState then
		--设置状态前都默认关闭线程
		self:stopUpdateHandler()
		self:stopAllActions()
	else
		if self.pCurUpdateItem then
			self:startUpdateHandler()
		end
		self:showTx()
	end
	
	self:setVisible(_bState)
end

--获得状态
function BuildActionLayer:getVisibleState(  )
	-- body
	return self:isVisible()
end

--update时间线程
function BuildActionLayer:onUpdate(  )
	-- body
	--设置价格
	if self.pCurUpdateItem then
		local bNeedclosed = self.pCurUpdateItem:setCostValue()
		if bNeedclosed then --需要隐藏起来
			self:setVisibleState(false)
		end
	end
end

-- 析构方法
function BuildActionLayer:onBuildActionLayerDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function BuildActionLayer:regMsgs( )
	-- body
end

-- 注销消息
function BuildActionLayer:unregMsgs(  )
	-- body
end


--暂停方法
function BuildActionLayer:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function BuildActionLayer:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

--设置当前数据
function BuildActionLayer:setCurData( tDatas, tBtnLists, nFromWhat  )
	-- body
	--dump(tDatas, "tDatas", 100)
	self.tBuildDatas = tDatas
	self.tBtnLists = tBtnLists
	self.nFromWhat = nFromWhat or 0
	self:updateViews()--刷新按钮状态
	self:removeYellowRing()--清除旧的按钮特效
	self:updateBtnTx()
end

--获得当前数据
function BuildActionLayer:getCurData(  )
	-- body
	return self.tBuildDatas
end

--根据数量和下标获取位置
function BuildActionLayer:getPositionBySizeAndIndex( _nSize, _nIndex )
	-- body
	if not _nSize or not _nIndex then
		return
	end 
	if _nSize > self.nMaxSize then
		print("error ==============> btn size maxsize = " .. self.nMaxSize)
	end
	local nX = 0
	local nY = 0
	if _nSize == 1 then
		if _nIndex == 1 then
			nX = self:getWidth() / 2
			nY = 20
		end
	elseif _nSize == 2 then
		if _nIndex == 1 then
			nX = self:getWidth() / 4 - 25
			nY = self:getHeight() / 4 - 15
		elseif _nIndex == 2 then
			nX = self:getWidth() / 4 * 3 + 25
			nY = self:getHeight() / 4 - 15
		end
	elseif _nSize == 3 then
		if _nIndex == 1 then
			nX = self:getWidth() / 5 - 80
			nY = self:getHeight() / 2 - 45
		elseif _nIndex == 2 then
			nX = self:getWidth() / 2
			nY = 20
		elseif _nIndex == 3 then
			nX = self:getWidth() / 5 * 4 + 80
			nY = self:getHeight() / 2 - 45
		end
	elseif _nSize == 4 then
		if _nIndex == 1 then
			nX = self:getWidth() / 5 - 120
			nY = self:getHeight() / 3 * 2 - 40
		elseif _nIndex == 2 then
			nX = self:getWidth() / 4 - 10
			nY = self:getHeight() / 4 - 15
		elseif _nIndex == 3 then
			nX = self:getWidth() / 4 * 3 + 10
			nY = self:getHeight() / 4 - 15
		elseif _nIndex == 4 then
			nX = self:getWidth() / 5 * 4 + 120
			nY = self:getHeight() / 3 * 2 - 40
		end
	end
	return nX, nY
end

--点击事件回调
--_nType：事件类型
function BuildActionLayer:onActionItemClicked( _nType )
	-- body
	if _nType == 1 then     --升级
		self:onUpClicked()
	elseif _nType == 2 then --进入
		self:onEnterClicked()
	elseif _nType == 3 then --加速
		self:onFastClicked()
	elseif _nType == 4 then --立即完成
		self:onFinishClicked()
	elseif _nType == 5 then --募兵
		self:onGetArmyClicked()
	elseif _nType == 6 then --改建
		self:onReConstructClicked()
	end
end

--升级点击事件
function BuildActionLayer:onUpClicked(  )
	-- body
	if self.tBuildDatas then
		--如果是科技院正在研究且购买了vip礼包但是没雇佣紫色研究员
		if self.tBuildDatas.nCellIndex == e_build_cell.tnoly then
			local tCurTonly = Player:getTnolyData():getUpingTnoly()
			if tCurTonly and tCurTonly:getUpingFinalLeftTime() > 0 then --生产状态中
				local nvip = getArmyVipLvLimit(e_id_item.kjky)
				local bBoughtVip = Player:getPlayerInfo():getIsBoughtVipGift(nvip)
				if bBoughtVip and (not getIsCanTnolyUpingWithTecnologying()) then
					local tObject = {}
					tObject.nType = e_dlg_index.dlgemploytip --dlg类型
					tObject.nTipIdx = 10083 --提示语下标
					sendMsg(ghd_show_dlg_by_type, tObject)
					return
				end
			end
		end
		--新手引导
		if self.pLvUpItem then
			if B_GUIDE_LOG then
				print("B_GUIDE_LOG BuildActionLayer 升级按钮点击回调")
			end
			Player:getNewGuideMgr():onClickedNewGuideFinger(self.pLvUpItem)
		end

		local tObject = {}
		tObject.nType = e_dlg_index.buildlvup --dlg类型
		tObject.nFromWhat = self.nFromWhat or 0 --1,2表示从左对联进来的
		tObject.nCell = self.tBuildDatas.nCellIndex
		sendMsg(ghd_show_dlg_by_type,tObject)
		--发送消息放大基地
		local tOb = {}
		tOb.nType = 1
		tOb.nCell = self.tBuildDatas.nCellIndex
		sendMsg(ghd_scale_for_buildup_dlg_msg,tOb)
		--发送hometop界面调整消息
		local tmsgObj = {}
		tmsgObj.nType = 1
		sendMsg(ghd_home_change_for_buildup_msg, tmsgObj)
		--关闭操作按钮
		sendMsg(ghd_close_build_actionbtn_msg)
	end
end

--进入点击事件
function BuildActionLayer:onEnterClicked( )
	-- body
	if self.tBuildDatas then
		local tObject = {}
		if self.tBuildDatas.sTid == e_build_ids.palace then --王宫
			tObject.nType = e_dlg_index.palace --dlg类型
		elseif self.tBuildDatas.sTid == e_build_ids.store then --仓库
			tObject.nType = e_dlg_index.warehouse --dlg类型
		elseif self.tBuildDatas.sTid == e_build_ids.infantry 
			or self.tBuildDatas.sTid == e_build_ids.sowar 
			or self.tBuildDatas.sTid == e_build_ids.archer then --步兵营，骑兵营，弓兵营
				tObject.nType = e_dlg_index.camp --dlg类型
				tObject.nBuildId = self.tBuildDatas.sTid

		elseif self.tBuildDatas.sTid == e_build_ids.tnoly then --科学院
			--新手引导
			Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.tnoly_enter_btn)
			
			tObject.nType = e_dlg_index.technology --dlg类型
		elseif self.tBuildDatas.sTid == e_build_ids.jxg then --将军府
			tObject.nType = e_dlg_index.shogunlayer --dlg类型
		elseif self.tBuildDatas.sTid == e_build_ids.atelier then --工坊
			--新手引导
			Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.atelier_enter_btn)
			
			tObject.nType = e_dlg_index.atelier --dlg类型		
		elseif self.tBuildDatas.sTid == e_build_ids.gate then --城墙
			tObject.nType = e_dlg_index.wall --dlg类型
		elseif self.tBuildDatas.sTid == e_build_ids.tjp then --铁匠铺
			tObject.nType = e_dlg_index.smithshop --dlg类型
			tObject.nFuncIdx = n_smith_func_type.build
		elseif self.tBuildDatas.sTid == e_build_ids.ylp then --洗炼铺
			-- tObject.nType = e_dlg_index.refineshop --dlg类型
		elseif self.tBuildDatas.sTid == e_build_ids.jbp then --聚宝盆
			tObject.nType = e_dlg_index.treasureshop --dlg类型
		elseif self.tBuildDatas.sTid == e_build_ids.bjt then--拜将台
			tObject.nType = e_dlg_index.buyhero --dlg类型
		elseif self.tBuildDatas.sTid == e_build_ids.tcf then--统帅府
			tObject.nType = e_dlg_index.dlgchiefhouse --dlg类型	

			--新手引导
			Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.tcf_enter_btn)
		elseif self.tBuildDatas.sTid == e_build_ids.arena then --聚宝盆
			tObject.nType = e_dlg_index.dlgarena --dlg类型					
		elseif self.tBuildDatas.sTid == e_build_ids.mbf then --募兵府
			tObject.nType = e_dlg_index.dlgrecruitsodiers --dlg类型	
		end

		sendMsg(ghd_show_dlg_by_type,tObject)

		--关闭操作按钮
		sendMsg(ghd_close_build_actionbtn_msg)
	end
end

--加速点击事件
function BuildActionLayer:onFastClicked(  )
	-- body	
	if self.tBuildDatas.sTid == e_build_ids.tnoly then --科技院--特别处理		
		if self.tBuildDatas.nState == e_build_state.uping then 				--升级中
			local tObject = {}
			tObject.nFunType = 1
			tObject.nType = e_dlg_index.buildprop --dlg类型
			tObject.nCell = self.tBuildDatas.nCellIndex
			sendMsg(ghd_show_dlg_by_type,tObject)
		else
			-- print("111111111111111111111111111111111111")
			local tUpingTnoly = Player:getTnolyData():getUpingTnoly()
			if tUpingTnoly then
				local tObject = {}
				tObject.nFunType = 3
				tObject.nType = e_dlg_index.buildprop --dlg类型	
				sendMsg(ghd_show_dlg_by_type,tObject)					
			end			
		end
	else
		if self.tBuildDatas.nState == e_build_state.uping then 				--升级中
			--新手引导
			if self.pSpeedItem then
				if B_GUIDE_LOG then
					print("B_GUIDE_LOG BuildActionLayer 加速按钮点击回调")
				end
				Player:getNewGuideMgr():onClickedNewGuideFinger(self.pSpeedItem)
			end
			
			local tObject = {}
			tObject.nFunType = 1
			tObject.nType = e_dlg_index.buildprop --dlg类型
			tObject.nCell = self.tBuildDatas.nCellIndex
			sendMsg(ghd_show_dlg_by_type,tObject)
		elseif self.tBuildDatas.nState == e_build_state.creating then 				--改建中
			--新手引导
			if self.pSpeedItem then
				Player:getNewGuideMgr():onClickedNewGuideFinger(self.pSpeedItem)
			end
			
			local tObject = {}
			tObject.nFunType = 5
			tObject.nType = e_dlg_index.buildprop --dlg类型
			tObject.nCell = self.tBuildDatas.nCellIndex
			sendMsg(ghd_show_dlg_by_type,tObject)
		elseif self.tBuildDatas.nState == e_build_state.producing then 			--生产中
			if self.tBuildDatas.sTid == e_build_ids.infantry 
				or self.tBuildDatas.sTid == e_build_ids.sowar 
				or self.tBuildDatas.sTid == e_build_ids.archer --步兵营，骑兵营，弓兵营
				or self.tBuildDatas.sTid == e_build_ids.mbf then --募兵府
				local tRecruitTeams = self.tBuildDatas.tRecruitTeams
				local _data = nil
				for k, v in pairs(tRecruitTeams) do
					if v.nType == e_camp_item.ing then
						_data = v
					end
				end
				if _data then
					if _data.nFree == 1 then
						--发送消息募兵操作
						local tObject = {}
						tObject.nBuildId = self.tBuildDatas.sTid
						tObject.nType = 7
						tObject.sId = _data.nId
						sendMsg(ghd_recruit_action_msg,tObject)
					else
						local tObject = {}
						tObject.nFunType = 2
						tObject.nType = e_dlg_index.buildprop --dlg类型
						tObject.nCell = self.tBuildDatas.nCellIndex
						sendMsg(ghd_show_dlg_by_type,tObject)
					end
				end
			end
		end
	end	
	--关闭操作按钮
	sendMsg(ghd_close_build_actionbtn_msg)
end

--立即完成点击事件
function BuildActionLayer:onFinishClicked( pView )
	-- body	
	--print("立即完成点击事件")
	--dump(self.tBuildDatas, "self.tBuildDatas", 100)
	if self.tBuildDatas.sTid == e_build_ids.atelier then --作坊
		local nCost = self.tBuildDatas:getSpeedProQueueCost()
		local str = {
			{color=_cc.pwhite,text=getConvertedStr(6, 10488)},
		}
		showBuyDlg(str, nCost, function (  )
			-- body			
			sendMsg(ghd_atelier_gold_finish_msg)
		end)
	elseif self.tBuildDatas.sTid == e_build_ids.tnoly then --科技院
		local tCurTonly = Player:getTnolyData():getUpingTnoly()
		if tCurTonly then
			-- local nCost = tCurTonly:getTnolyCurrentFinishValue()
		 --    local strTips = {
		 --    	{color=_cc.pwhite,text=getConvertedStr(1, 10182)},--立即完成研究？
		 --    }
		 --    --展示购买对话框
			-- showBuyDlg(strTips,nCost,function (  )
			-- 	-- body
			-- 	local tObject = {}
			-- 	tObject.nType = 2
			-- 	tObject.nLoc = 1 --用来区分是在建筑加速还是在科技院里面加速 1.表示建筑加速 2.表示科技院里面加速或则在建筑外收取科技
			-- 	sendMsg(ghd_action_tnoly_msg, tObject)
			-- end)
			local tObject = {}
			tObject.nFunType = 3
			tObject.nType = e_dlg_index.buildprop --dlg类型
			tObject.nLoc = 1	
			sendMsg(ghd_show_dlg_by_type,tObject)				
		end
	elseif self.tBuildDatas.sTid == e_build_ids.tjp then --铁匠铺
		local tMakeVo = Player:getEquipData():getMakeVo()
		--正在打造装备
		if tMakeVo then
			--如果可以免费加速
			if Player:getEquipData():getIsCanSpeed() then
				SocketManager:sendMsg("reqMakeQuick", {}, function(__msg)
					-- body
					if __msg.head.state == SocketErrorType.success then
						TOAST(getConvertedStr(7, 10122))
					end
				end)
			--立即完成
			else
				--打造cd
				local nCd = tMakeVo:getCd()
				--立即完成黄金扣除
				local nCost =  math.ceil(nCd/60) * tonumber(getBuildParam("makeTimeSpeed"))
				local tStr = {
			    	{color = _cc.pwhite, text = getConvertedStr(3, 10296)},
			    }
			    --购买对话框
				showBuyDlg(tStr, nCost, function()
					-- body
					SocketManager:sendMsg("reqMakeQuickByCoin")
				end)
			end
		end
	end
	
	--关闭操作按钮
	sendMsg(ghd_close_build_actionbtn_msg)
end

--募兵点击事件
function BuildActionLayer:onGetArmyClicked( pView )
	-- body
	-- print("新手引导 募兵 ~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	--新手引导
	local bIsJump = Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.camp_enter_btn)
	if bIsJump then
	else
		if self.tBuildDatas.sTid == e_build_ids.mbf then
			local tObject = {}
			tObject.nType = e_dlg_index.dlgrecruitsodiers --dlg类型
			sendMsg(ghd_show_dlg_by_type,tObject)
		else
			local tObject = {}
			tObject.nType = e_dlg_index.camp --dlg类型
			tObject.nBuildId = self.tBuildDatas.sTid
			sendMsg(ghd_show_dlg_by_type,tObject)
		end
	end

	--关闭操作按钮
	sendMsg(ghd_close_build_actionbtn_msg)
end

--拆除点击事件
function BuildActionLayer:onRemoveClicked( pView )
	-- body
	--判断科技“土地重建”是否解锁
	local tTnoly = Player:getTnolyData():getTnolyByIdFromAll(e_tnoly_ids.tdcj)
	if tTnoly then
		local bLocked = tTnoly:checkisLocked()
		if bLocked then
			TOAST(getConvertedStr(7, 10440))
		else
			--获得建造队列具体情况
			-- local nState, pBuild = Player:getBuildData():getBuildingQueState()
			-- if nState == 0 then --有空闲队列
				--建筑更多操作消息
				local tObj = {}
				tObj.nCell = self.tBuildDatas.nCellIndex
				tObj.nBuildId = self.tBuildDatas.sTid
				tObj.nType = 1
				sendMsg(ghd_more_action_build_msg, tObj) 
		-- 	elseif nState == 1 then --可购买队列
		-- 		TOAST(getConvertedStr(1, 10256) .. getConvertedStr(1, 10257))
		-- 	elseif nState == 2 then --没有空闲队列
		-- 		TOAST(getConvertedStr(1, 10256))
		-- 	end
		end
	end

	--关闭操作按钮
	sendMsg(ghd_close_build_actionbtn_msg)
end

--改建点击事件
function BuildActionLayer:onReConstructClicked(pView)
	-- body
	--判断科技“土地重建”是否解锁
	local tTnoly = Player:getTnolyData():getTnolyByIdFromAll(e_tnoly_ids.tdcj)
	if tTnoly then
		local bLocked = tTnoly:checkisLocked()
		if bLocked then
			TOAST(getConvertedStr(7, 10440))
		else
			--打开改建提示
			local DlgAlert = require("app.common.dialog.DlgAlert")
		    local pDlg, bNew = getDlgByType(e_dlg_index.alert)
		    if(not pDlg) then
		        pDlg = DlgAlert.new(e_dlg_index.alert)
		    end
		    pDlg:setTitle(getConvertedStr(3, 10091))
		    if self.tBuildDatas.nCellIndex == e_build_cell.mbf then --重建募兵府
		    	pDlg:setContentLetter(getTipsByIndex(20083))
		    else
		    	pDlg:setContentLetter(getTipsByIndex(20059))
		    end
		    pDlg:setRightHandler(function()
		    	if self.tBuildDatas.nCellIndex == e_build_cell.mbf then --重建募兵府
		    		local tObject = {}
					tObject.nType = e_dlg_index.restructrecruit --dlg类型
					tObject.nRecruitTp = self.tBuildDatas.nRecruitTp --当前募兵类型(1步,2骑,3弓)
					sendMsg(ghd_show_dlg_by_type, tObject)
		    	else      --重建资源田
			        local tObject = {}
					tObject.nType = e_dlg_index.restructsuburb --dlg类型
					tObject.nCell = self.tBuildDatas.nCellIndex
					sendMsg(ghd_show_dlg_by_type, tObject)
				end
		        closeDlgByType(e_dlg_index.alert, false)
		    end)
		    pDlg:showDlg(bNew)
			--关闭操作按钮
			sendMsg(ghd_close_build_actionbtn_msg)
		end
	end
end

--新手手指ID绑定
function BuildActionLayer:bingNewGuideFinger( bIsShow )
	if B_GUIDE_LOG then
		print("BuildActionLayer:bingNewGuideFinger bIsShow", bIsShow)
	end
	
	if bIsShow then
		-- body
		if self.tBuildDatas then
			--新手引导记录
			if self.pLvUpItem then
				Player:getNewGuideMgr():registeredBuildLvUi(self.pLvUpItem, self.tBuildDatas, true)
			else
				Player:getNewGuideMgr():registeredBuildLvUi(nil, self.tBuildDatas, false)
			end
			--新手引导建筑进入按钮 
			if self.pEnterItem then
				Player:getNewGuideMgr():registeredBuildEnterUi(self.pEnterItem, self.tBuildDatas, true)
			else
				Player:getNewGuideMgr():registeredBuildEnterUi(nil, self.tBuildDatas, false)
			end
			--新手引导加速
			if self.pSpeedItem then
				Player:getNewGuideMgr():registeredBuildSpeedUi(self.pSpeedItem, self.tBuildDatas, true)
				local tCurTask = Player:getPlayerTaskInfo():getCurAgencyTask()
				--新手特殊步骤显示特效
				if tCurTask and tCurTask.sTid == e_special_task_id.palace_lv_five then
					if self.bItemSpeedTx == false then
						self:playYellowRing(self.pSpeedItem, e_buildbtn_type.speedup)
					end					
				else
					if self.bItemSpeedTx == false then
						self:removeYellowRing()
					end
				end		
			else
				Player:getNewGuideMgr():registeredBuildSpeedUi(nil, self.tBuildDatas, false)
			end
		end
	else
		if self.tBuildDatas then
			Player:getNewGuideMgr():registeredBuildEnterUi(nil, self.tBuildDatas, false)
			Player:getNewGuideMgr():registeredBuildLvUi(nil, self.tBuildDatas, false)
			Player:getNewGuideMgr():registeredBuildSpeedUi(nil, self.tBuildDatas, false)
			if self.pSpeedItem and self.bItemSpeedTx == false then
				self:removeYellowRing()
			end
		end
	end
end

function BuildActionLayer:getBtnByType( _btnType )
	-- body
	if not _btnType then
		return nil
	end
	local nRealSize = table.nums(self.tBtnLists)
	for i = 1, self.nMaxSize do
		local pItemBtn = self:findViewByName("build_action_index_" .. i)
		if pItemBtn and pItemBtn.nType == _btnType then
			return pItemBtn
		end
	end
	return nil
end

function BuildActionLayer:showBtnEffect( _btnType )
	-- body
	local pView = self:getBtnByType(_btnType)
	if pView then
		self:playYellowRing(pView, _btnType)
	else	
		self:removeYellowRing()
	end
end


--播放黄色光圈
function BuildActionLayer:playYellowRing( pView, _btnType )
	-- body
	if not self.tAllYellowTx then 
		self.tAllYellowTx = {}
	end
	local sNameImg = nil --特效表现的内容图片
	local fScale = 1.0 --图片缩放值
	local pItem = pView
	if _btnType == 1 then --升级
		sNameImg = "v1_ing_zjm_shengji"
		fScale = 1
		fRScale = 1.6
	end
	if _btnType == 3 then --加速
		sNameImg = "v1_ing_zjm_jiasu"
		fScale = 1
		fRScale = 1.6
	end


	--判断是否需要创建特效
	if self.sYellowImgName then
		if self.sYellowImgName == sNameImg then --如果播放的正是当前特效，那么直接返回
			return 
		else
			--需要重新加载特效，先清除特效
			self:removeYellowRing()
			--重新加载
			self:playYellowRing(_btnType)
			return
		end
	end

	if sNameImg then

		--图片名字赋值
		self.sYellowImgName = sNameImg 
		local tAll = {} --复制表
		tAll[1] = copyTab(tNormalCusArmDatas["1"])
		tAll[1].fScale = fRScale
		--替换图片
		local tT1 = copyTab(tNormalCusArmDatas["2"])
		for k, v in pairs (tT1.tActions) do
			v.sImgName = sNameImg
		end
		tT1.fScale = fScale
		tAll[2] = copyTab(tT1)
		local tT2 = copyTab(tNormalCusArmDatas["3"])
		for k, v in pairs (tT2.tActions) do
			v.sImgName = sNameImg
		end
		tT2.fScale = fScale
		tAll[3] = copyTab(tT2)
		tAll[4] = copyTab(tNormalCusArmDatas["4"])
		tAll[4].fScale = fRScale
		for i = 1, 4 do
			local pArm = MArmatureUtils:createMArmature(
				tAll[i], 
				pItem, 
				100, 
				cc.p(pItem:getWidth() / 2, pItem:getHeight() / 2),
			    function ( _pArm )

			    end)
			if pArm then
				table.insert(self.tAllYellowTx, pArm)
				pArm:play(-1)
			end
		end
		--添加例子效果
		self:showQiPaoParitcle(pItem)
	end
end

--添加粒子效果
function BuildActionLayer:showQiPaoParitcle( pView )
	-- body
	if not self.pParitcle then
		self.pParitcle = createParitcle("tx/other/lizi_qipao_01.plist")
		self.pParitcle:setPosition(pView:getWidth() / 2 ,pView:getHeight() / 2)
		pView:addView(self.pParitcle,80)
		self.pParitcle:setScale(94/74)
		centerInView(pView,self.pParitcle)
	end
end

--移除黄色光圈
function BuildActionLayer:removeYellowRing(  )
	-- body
	if self.tAllYellowTx and table.nums(self.tAllYellowTx) > 0 then
		local nSize = table.nums(self.tAllYellowTx)
		for i = nSize, 1, -1 do
			self.tAllYellowTx[i]:removeSelf()
			self.tAllYellowTx[i] = nil
		end
	end
	self.tAllYellowTx = nil
	self.sYellowImgName = nil
	--移除粒子效果
	self:removeQiPaoParitcle()
end

--移除粒子效果
function BuildActionLayer:removeQiPaoParitcle(  )
	-- body
	if self.pParitcle then
		self.pParitcle:removeSelf()
		self.pParitcle = nil
	end
end
return BuildActionLayer