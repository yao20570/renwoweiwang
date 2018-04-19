-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-06-24 14:16:19 星期六
-- Description: 主界面对联 item
-----------------------------------------------------
local ShopFunc = require("app.layer.shop.ShopFunc")
local MCommonView = require("app.common.MCommonView")
e_index_itemrl = {
	r_hd 			= 		101, 			--活动
	r_fl 			= 		102, 			--福利
	r_sd 			= 		103, 			--商店
	r_gg 			= 		104, 			--公告

	r_bx 			= 		205, 			--免费宝箱
	r_mc 			= 		206, 			--特价卖场
	r_hc            =       207,            --武将推荐
	r_fc            =       208,            --首充好礼
	r_tg            =       209,            --触发礼包
	r_wq            =       210,            --王权征收	

	l_pydl 			= 		1, 				--普通对列
	l_hjdl			= 		2, 				--黄金队列
	l_zdjz 			= 		3, 				--自动建造
	l_sjbc 			= 		4, 				--守军补充
	l_yjzs 			= 		5, 				--一键征收
	l_jnw 			= 		6, 				--教你玩
	-- l_gjbk  		= 		8,				--国家宝库

	d_l_wwtf		=		301,			--武王讨伐
	d_l_gcld		=		302,			--攻城掠地
	d_l_tlboss      =       303,            --限时Boss
	d_l_mjrq		=		304,			--冥界入侵
	d_l_epw         =       305,            --皇城战
	d_l_gjbk 		= 		306,			--王者秘藏
	d_l_zwsl 		= 		307,			--纣王试炼
}
local nDistanceTime = 500
local ItemHomeLR = class("ItemHomeLR", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemHomeLR:ctor( _nType, _nIndex )
	-- body
	self:myInit()
	self.nType = _nType or self.nType
	self.tCurData = _nIndex
	parseView("item_home_lr", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemHomeLR:myInit(  )
	-- body
	self.nType 		=	1 			--1右边 2 左边 3右上角  4左下角
	self.tCurData 	= 	nil 		--左边对联item数据
end

--解析布局回调事件
function ItemHomeLR:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView, 10)

	self:setupViews()
	self:updateViews()
	self:regMsgs()

	--注册析构方法
	self:setDestroyHandler("ItemHomeLR",handler(self, self.onItemHomeLRDestroy))
end

--初始化控件
function ItemHomeLR:setupViews( )
	-- body
	--背景层
	self.pItem 			= 		self:findViewByName("default")
	self.pItem:setViewTouched(true)
	self.pItem:setIsPressedNeedScale(false)
	self.pItem:onMViewClicked(handler(self, self.onItemClicked))
	--红点层
	self.pLyRed         =       self:findViewByName("ly_red")
	--名字
	self.pLayName 		= 		self:findViewByName("lay_name")
	self.pLbName 		= 		self:findViewByName("lb_name")
	--icon
	self.pImgIcon 		= 		self:findViewByName("img")

	if self.nType == 1 then --右边
		self.pLayName:setLayoutSize(66, self.pLayName:getHeight())
		self.pLbName:setPositionX(self.pLayName:getWidth() / 2)
	else
		self.pLayName:setLayoutSize(self.tCurData.nNameWidth, self.pLayName:getHeight())
	end
	--设置位置
	self.pLayName:setPositionX((self:getWidth() - self.pLayName:getWidth()) / 2)

	
end

-- 修改控件内容或者是刷新控件数据
function ItemHomeLR:updateViews(  )
	-- body
	if self.tCurData then
		
		self.pImgIcon:setCurrentImage(self.tCurData.sIcon)
		--设置内容
		self:setMsgOrActionByType(1)
		--初始化红点层
		self:initRedNum()
		--增加各类图标特效
		self:addBxAndSaleTx()
		
		if self.tCurData.nIconScale then
			self.pImgIcon:setScale(self.tCurData.nIconScale)
		end
		if self.tCurData.sBgImg then
			self.pItem:setBackgroundImage(self.tCurData.sBgImg)
		end
	end
end

-- 注册消息
function ItemHomeLR:regMsgs( )
	-- body
	-- 注册建筑状态变化的消息
	regMsg(self, gud_build_state_change_msg, handler(self, self.changeBuildState))
	-- 注册建筑数据发生变化的消息
	regMsg(self, gud_build_data_refresh_msg, handler(self, self.onRefreshBuildDatas))
	-- 注册对联红点回调
	regMsg(self, gud_refresh_homelr_red, handler(self, self.refreshRedNums))
	-- 注册免费宝箱推送回调
	regMsg(self, ghd_daily_gift_push, handler(self, self.refreshBxByPush))

	regMsg(self, gud_refresh_activity, handler(self, self.refreshRedTip))

	regMsg(self, gud_refresh_act_red, handler(self, self.refreshRedTip))

	--武王讨伐零点推送的时候要刷新红点
	regMsg(self, ghd_zero_act_push, handler(self, self.refreshWwState))

    regMsg(self, gud_refresh_baginfo, handler(self, self.refreshWwState))

    regMsg(self, ghd_auto_build_mgr_msg, handler(self, self.refreshZDJZ))

    regMsg(self, gud_tlboss_data_refresh, handler(self, self.refreshTLBossRedNum))

    regMsg(self, ghd_national_treasure_update, handler(self, self.refreshNationalTreasureRedNum))

    regMsg(self, gud_refresh_playerinfo, handler(self, self.refreshPlayerInfo))

    regMsg(self, ghd_kingzhou_num_change_msg, handler(self, self.refreshKingZhouRedNum))

    regMsg(self, ghd_refresh_epw_award_state, handler(self, self.refreshEpwRedNum))
end



-- 注销消息
function ItemHomeLR:unregMsgs(  )
	-- body
	-- 销毁建筑状态变化的消息
	unregMsg(self, gud_build_state_change_msg)
	-- 销毁建筑数据发生变化的消息
	unregMsg(self, gud_build_data_refresh_msg)
	-- 注销对联红点回调
	unregMsg(self, gud_refresh_homelr_red)	

	-- 注册免费宝箱推送回调
	unregMsg(self, ghd_daily_gift_push)

	unregMsg(self, gud_refresh_activity)

    unregMsg(self, gud_refresh_baginfo)	
    
    unregMsg(self, ghd_zero_act_push)	

    unregMsg(self, ghd_auto_build_mgr_msg)

    unregMsg(self, gud_tlboss_data_refresh)

    unregMsg(self, gud_refresh_act_red)
    --国家宝藏
    unregMsg(self, ghd_national_treasure_update)

    unregMsg(self, gud_refresh_playerinfo)

    unregMsg(self, ghd_kingzhou_num_change_msg)

    unregMsg(self, ghd_refresh_epw_award_state)
end

local LeftTimeBubleLayer = require("app.layer.home.LeftTimeBubleLayer")
function ItemHomeLR:showLeftTimeBuble()
	if self.bShowLeftBuble then
		return
	end
	if not self.pLeftBubleLayer then
		self.bShowLeftBuble = true
		self.pLeftBubleLayer = LeftTimeBubleLayer.new()
		if self:getParent()  then
			self:getParent():addView(self.pLeftBubleLayer)
			-- self.pLeftBubleLayer:setPosition(self:getPositionX() + self:getContentSize().width + 20,self:getPositionY() + 10)
			-- self.pLeftBubleLayer:setVisible(true)
			
		
		end
	end
	self.bShowLeftBuble = true
	self.pLeftBubleLayer:setPosition(self:getPositionX() + self:getContentSize().width + 20,self:getPositionY() + 10)
	self.pLeftBubleLayer:setVisible(true)
	doDelayForSomething(self,function (  )
		if self.pLeftBubleLayer then
			self.bShowLeftBuble = false 
			self.pLeftBubleLayer:setVisible(false)
		end
			
	end,2)

end

--根据类型设置内容或者执行点击动作
--_nMode：1：设置内容 2：动作响应
function ItemHomeLR:setMsgOrActionByType( _nMode )
	-- body
	self:setNameBgAndCircleBg(2)
	if self.tCurData.nId  == e_index_itemrl.l_pydl then --普通队列
		unregUpdateControl(self)--停止计时刷新
		--刷新状态
		self:refreshBuildQueState(1,_nMode)
		self:setNameBgAndCircleBg(1)
	elseif self.tCurData.nId  == e_index_itemrl.l_hjdl then --黄金队列

		
		unregUpdateControl(self)--停止计时刷新
		--获取是否有雇佣队列
		local nLeftTime = Player:getBuildData():getBuildBuyFinalLeftTime()
		local nState, pCurBuild = Player:getBuildData():getBuildingQueStateByType(2)
		-- print("nLeftTime, nState ======================= ", nLeftTime, nState)
		if nLeftTime > 0 or nState == 1 then --雇佣中
			--刷新状态
			self:refreshBuildQueState(2,_nMode)
		else			
			if _nMode == 1 then --设置内容				
				self:removeBuildingTx()		
				self:removeSleepTx()
				--图标置灰
				showGrayTx(self.pImgIcon, true)
				--未雇佣特效
				self:showUnBuyTx()
				self.pLbName:setString(getConvertedStr(1, 10251),false) --未雇佣
				setTextCCColor(self.pLbName, _cc.red)
				--动态设置位置
				self:updateNameLayer()
				unregUpdateControl(self)--停止计时刷新
			else
				local tObject = {}
				tObject.nType = e_dlg_index.buildbuyteam --dlg类型
				sendMsg(ghd_show_dlg_by_type,tObject)
			end
		end
	elseif self.tCurData.nId  == e_index_itemrl.l_yjzs then --一键征收
		if _nMode == 1 then --设置内容
			self.pLbName:setString(self.tCurData.sName,false)
			--动态设置位置
			self:updateNameLayer()
			--去掉相关动画特效
			self:removeBuildingTx()
		else
			SocketManager:sendMsg("collectRes", {nil,2}, handler(self, self.collectFastResponse))
		end
	elseif self.tCurData.nId  == e_index_itemrl.l_zdjz then --自动建造
		if _nMode == 1 then --设置内容
			self.pLbName:setString(self.tCurData.sName,false)
			--动态设置位置
			self:updateNameLayer()
			if Player:getBuildData().bAutoUpOpen then   --开启中
				self:showBuildingTx()
			else 										--关闭中
				self:removeBuildingTx()
			end
		else
			local tObject = {}
			tObject.nType = e_dlg_index.autobuild --dlg类型
			sendMsg(ghd_show_dlg_by_type,tObject)
			-- local nState = 0
			-- if Player:getBuildData().bAutoUpOpen then   --开启中
			-- 	nState = 0
			-- else 										--关闭中
			-- 	nState = 1
			-- end
			-- --自动建造次数
			-- local nAutoBuildCt = Player:getBuildData().nAutoUpTimes
			-- if nAutoBuildCt and nAutoBuildCt > 0 then
			-- 	SocketManager:sendMsg("autoBuilding", {nState}, handler(self, self.autoBuildingResponse))
			-- else
			-- 	--没有次数就跳转到商店界面并定位到自动建造物品
			-- 	self:openBuyVipShop(e_item_ids.zdjz)

			-- 	-- local tOb = {}
   --  -- 			tOb.nType = e_dlg_index.shop
   --  -- 			tOb.nGoodsId = e_item_ids.zdjz
   --  -- 			sendMsg(ghd_show_dlg_by_type, tOb) 
			-- end
		end
		
	elseif self.tCurData.nId  == e_index_itemrl.l_sjbc then --补充城防
		local nAutoRecruitCt = Player:getBuildData().nAutoRecruit
		if _nMode == 1 then --设置内容
			self.pLbName:setString(self.tCurData.sName,false)
			--动态设置位置
			self:updateNameLayer()
			--获得城门数据
			local pGateBuild = Player:getBuildData():getBuildByCell(e_build_cell.gate) 
			if pGateBuild then
				--获得是否开启状态
				if pGateBuild.ns == 1 and nAutoRecruitCt and nAutoRecruitCt > 0 then --开启中
					self:showBuildingTx()
				else 					   --关闭中
					self:removeBuildingTx()
				end
			else
				self:removeBuildingTx()
			end
		else
			--获得城门数据
			local pGateBuild = Player:getBuildData():getBuildByCell(e_build_cell.gate) 
			if pGateBuild then
				--获得是否开启状态
				local nState = 0
				if pGateBuild.ns == 1 then --开启中
					nState = 0
				else 					   --关闭中
					nState = 1
				end
				if nAutoRecruitCt and nAutoRecruitCt > 0 then
					SocketManager:sendMsg("wallAutoDefSw", {nState}, handler(self, self.autoDefSwResponse))
				else
					--没有次数就跳转到商店界面并定位到自动建造物品
					self:openBuyVipShop(e_item_ids.bccf)

					-- local tOb = {}
	    -- 			tOb.nType = e_dlg_index.shop
	    -- 			tOb.nGoodsId = e_item_ids.bccf
	    -- 			sendMsg(ghd_show_dlg_by_type, tOb)
				end
			end
		end
	elseif self.tCurData.nId  == e_index_itemrl.l_jnw then --教你玩
		if _nMode == 1 then --设置内容
			-- self.pLayName:setVisible(false)
			self.pLbName:setString(self.tCurData.sName,false)
			self:updateNameLayer()
			self.pImgIcon:setPositionY(self.pImgIcon:getPositionY())
		else --动作响应
			local tOb = {}
	    	tOb.nType = e_dlg_index.dlgteachplay
	    	sendMsg(ghd_show_dlg_by_type, tOb)
		end
	-- elseif self.tCurData.nId  == e_index_itemrl.l_gjbk then --国家宝库
	-- 	if _nMode == 1 then --设置内容
	-- 		self.pLbName:setString(self.tCurData.sName,false)
	-- 		self:updateNameLayer()
	-- 	else --动作响应
	-- 		local tOb = {}
	--     	tOb.nType = e_dlg_index.nationaltreasure
	--     	sendMsg(ghd_show_dlg_by_type, tOb)
	-- 	end
	elseif self.tCurData.nId  == e_index_itemrl.r_bx then

		if _nMode==1 then 		--设置内容
			self:refreshBxState()
		end

	elseif self.tCurData.nId  == e_index_itemrl.d_l_wwtf then
		
		if _nMode==1 then 		--设置内容
			self:setNameBgAndCircleBg(4)
			self.pLbName:setString(self.tCurData.sName,false)
			self:updateNameLayer()

			-- self:playWwRewardEffect()
		end

		self:refreshWwState()
		self:playWwRewardEffect()

	elseif self.tCurData.nId == e_index_itemrl.r_tg then
		if _nMode==1 then 		--设置内容
			regUpdateControl(self, handler(self, self.onUpdateTime))		--注册更新倒计时
		end
	elseif self.tCurData.nId  == e_index_itemrl.d_l_gcld then

		if _nMode==1 then 		--设置内容
			self:setNameBgAndCircleBg(4)
			self.pLbName:setString(self.tCurData.sName,false)
			-- regUpdateControl(self, handler(self, self.onUpdateTime))		--注册更新倒计时
			self:updateNameLayer()

			-- self:playWwRewardEffect()
		end

		self:refreshWwState()
		self:playWwRewardEffect()
	elseif self.tCurData.nId  == e_index_itemrl.d_l_mjrq then 		--冥界入侵

		if _nMode==1 then 		--设置内容
			self:setNameBgAndCircleBg(4)
			self.pLbName:setString(self.tCurData.sName,false)
			-- regUpdateControl(self, handler(self, self.onUpdateTime))		--注册更新倒计时
			self:updateNameLayer()

			-- self:playWwRewardEffect()
		end

		self:refreshWwState()
		self:playWwRewardEffect()
	else
		self.pLbName:setString(self.tCurData.sName,false)
		--动态设置位置
		self:updateNameLayer()
	end
end



--展示建筑队列详情
-- _nType：1.默认队列 2.购买队列
-- _nMode：1：设置内容 2：动作响应
function ItemHomeLR:refreshBuildQueState( _nType, _nMode )

	if _nType == 2 and _nMode == 2 then
		local nHjLeftTime = Player:getBuildData():getBuildBuyFinalLeftTime()
		if  nHjLeftTime > 0 then

			self:showLeftTimeBuble()
		end
	end
	-- body
	--获得队列情况
	local nState, pCurBuild = Player:getBuildData():getBuildingQueStateByType(_nType)	
	if nState == 0 then --空闲
		if _nMode == 1 then --设置内容
			if _nType == 2 then
				--移除未雇佣效果
				self:removeUnBuyTx()
			end
			--移除建造中效果
			self:removeBuildingTx()
			self.pLbName:setString(getConvertedStr(1, 10249),false)
			setTextCCColor(self.pLbName, _cc.green)
			--动态设置位置
			self:updateNameLayer()
			self.pImgIcon:setCurrentImage(self.tCurData.sIcon)
			--图标呼吸效果
			showBreathTx(self.pImgIcon)
			--Zzz 睡眠效果
			self:showSleepTx()
		else                --点击响应
			if self.nLastClickTime then
				local nCurTime = getSystemTime(false)
				if (nCurTime - self.nLastClickTime) < nDistanceTime then
					return
				end
			end
			self.nLastClickTime = getSystemTime(false)

			--判断第二个建造队开启提示
			if _nType == 2 then
				local bIsOpen = getIsReachOpenCon(7)
				if not bIsOpen then
					return
				end
			end

			local tAllBuilds = Player:getBuildData():getCanUpBuildLists()

			if tAllBuilds and table.nums(tAllBuilds) > 0 then
				if #tClickedUpBuildList >= #tAllBuilds then
					tClickedUpBuildList = {}
				end
				-- dump(tClickedUpBuildList, "已追踪建筑格子列表 ====== ")
				local tChoiceBuild = tAllBuilds[1] --默认选取第一个为目标建筑
				for i = 1, #tAllBuilds do
					local nFind = 0
					for k, nCellIdx in pairs(tClickedUpBuildList) do
						if tAllBuilds[i].nCellIndex == nCellIdx then
							break
						end
						nFind = nFind + 1
					end
					if nFind >= #tClickedUpBuildList then
						tChoiceBuild = tAllBuilds[i]
						break
					end
				end

				table.insert(tClickedUpBuildList, tChoiceBuild.nCellIndex)
				if tChoiceBuild then
					--移动到屏幕中点
					local tOb = {}
					tOb.nCell = tChoiceBuild.nCellIndex
					tOb.nFunc = function (  )
						-- body
						--如果科技院、兵营、工坊有可领取的时候不打开操作按钮
						local nCell = tChoiceBuild.nCellIndex
						if nCell == e_build_cell.tnoly then
							if Player:getTnolyData():isTnolyOK() then
								return
							end
						elseif nCell == e_build_cell.infantry or nCell == e_build_cell.sowar or
							nCell == e_build_cell.archer then
							if tChoiceBuild:getRecruitedQue() then
								return
							end
						elseif nCell == e_build_cell.atelier then
							if tChoiceBuild:getFirstFinshQueueItem() then
								return
							end
						end
						--模拟执行一次点击行为
						--发送消息关闭除了自身以外有打开的操作按钮，并且打开自身
						local tObject = {}
						tObject.nCell = tChoiceBuild.nCellIndex
						tObject.nFromWhat = _nType --标志从左对联进来的
						sendMsg(ghd_show_build_actionbtn_msg,tObject)
					end
					sendMsg(ghd_move_to_build_dlg_msg, tOb)
					
				end
			else
				tClickedUpBuildList = {}
				TOAST(getConvertedStr(1, 10263))
			end
		end
	elseif nState == 1 then --建造中
		if _nType == 2 then
			--移除未雇佣效果
			self:removeUnBuyTx()
			
		end
		--移除睡眠效果
		self:removeSleepTx()
		--图标摇摆效果
		showRockTx(self.pImgIcon)


		regUpdateControl(self, handler(self, self.onUpdateTime))


		if pCurBuild then --判断是否存在建造队列和是否免费加速
			if pCurBuild.fRssTime > 0 then --有免费加载
				if _nMode == 1 then --设置内容
					--建造中效果
					self:showBuildingTx()
					--获取剩余时间
					local nLeftTime = pCurBuild:getBuildingFinalLeftTime()
					self.pLbName:setString(formatTimeToHms(nLeftTime),false)
					setTextCCColor(self.pLbName, _cc.pwhite)
					--动态设置位置
					self:updateNameLayer()
					self.pImgIcon:setCurrentImage("#v1_fonts_mfl.png")
				else
					local tObject = {}
					tObject.nType = 1 --免费加速
					tObject.nBuildId = pCurBuild.sTid --建筑id
					tObject.nCell = pCurBuild.nCellIndex --建筑格子下标
					sendMsg(ghd_up_build_msg,tObject)
				end
			else 							--没有免费加速
				if _nMode == 1 then --设置内容
					--建造中效果
					self:showBuildingTx()
					local nLeftTime = pCurBuild:getBuildingFinalLeftTime()
					self.pLbName:setString(formatTimeToHms(nLeftTime),false)
					setTextCCColor(self.pLbName, _cc.pwhite)
					--动态设置位置
					self:updateNameLayer()
					self.pImgIcon:setCurrentImage(self.tCurData.sIcon)
				else
					
					
					--移动到屏幕中点
					local tOb = {}
					tOb.nCell = pCurBuild.nCellIndex
					tOb.nFunc = function (  )
						-- body
						--模拟执行一次点击行为
						--发送消息关闭除了自身以外有打开的操作按钮，并且打开自身
						local tObject = {}
						tObject.nCell = pCurBuild.nCellIndex
						sendMsg(ghd_show_build_actionbtn_msg,tObject)
					end
					sendMsg(ghd_move_to_build_dlg_msg, tOb)
					
				end
			end
		end
	end
end

--展示睡眠效果
function ItemHomeLR:showSleepTx(  )
	-- body
	if not self.pTxSleep then
		self.pTxSleep = getSleepTx()
		self.pItem:addView(self.pTxSleep,100)
		centerInView(self.pItem,self.pTxSleep)
	end
end

--移除睡眠效果
function ItemHomeLR:removeSleepTx(  )
	-- body
	if self.pTxSleep then
		self.pTxSleep:stopAllActions()
		self.pTxSleep:removeSelf()
		self.pTxSleep = nil
	end
end

--展示未雇佣效果
function ItemHomeLR:showUnBuyTx(  )
	-- body
	--光圈扩散效果
	if not self.pTxCircle then
		self.pTxCircle = getCircleLightRing()
		self.pItem:addView(self.pTxCircle,10)
		centerInView(self.pItem,self.pTxCircle)
	end

	--红圈加亮
	if not self.pRedImg then
		self.pRedImg = MUI.MImage.new("#sg_zjm_kaiqizt_hs_001.png")
		self.pItem:addView(self.pRedImg,10)
		centerInView(self.pItem,self.pRedImg)
		self.pRedImg:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	end

	--粒子效果
	if not self.pParitcleA then
		self.pParitcleA = createParitcle("tx/other/lizi_gmzt_zjm_001.plist")
		self.pParitcleA:setPosition(self.pItem:getWidth() / 2 ,self.pItem:getHeight() / 2)
		self.pItem:addView(self.pParitcleA,80)
		centerInView(self.pItem,self.pParitcleA)
	end
end

--移除未雇佣效果
function ItemHomeLR:removeUnBuyTx(  )
	-- body
	--光圈扩散效果
	if self.pTxCircle then
		self.pTxCircle:stopAllActions()
		self.pTxCircle:removeSelf()
		self.pTxCircle = nil
	end

	--红圈加亮
	if self.pRedImg then
		self.pRedImg:removeSelf()
		self.pRedImg = nil
	end

	--粒子效果
	if self.pParitcleA then
		self.pParitcleA:removeSelf()
		self.pParitcleA = nil
	end
end

--展示建造中效果
function ItemHomeLR:showBuildingTx(  )
	-- body
	--光圈扩散效果
	if not self.pTxBuildingCircle then
		self.pTxBuildingCircle = getCircleLightRing()
		self.pItem:addView(self.pTxBuildingCircle,10)
		centerInView(self.pItem,self.pTxBuildingCircle)
	end
	--蓝圈加亮
	if not self.pBlueImg then
		self.pBlueImg = MUI.MImage.new("#sg_zjm_wkaiqizt_hs_001.png")
		self.pItem:addView(self.pBlueImg,10)
		centerInView(self.pItem,self.pBlueImg)
		self.pBlueImg:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	end
	--粒子效果
	if not self.pParitcleB then
		self.pParitcleB = createParitcle("tx/other/lizi_zjm_kqtx_sa_001.plist")
		self.pParitcleB:setPosition(self.pItem:getWidth() / 2 ,self.pItem:getHeight() / 2)
		self.pItem:addView(self.pParitcleB,30)
		centerInView(self.pItem,self.pParitcleB)
	end
end

--移除建造中效果
function ItemHomeLR:removeBuildingTx(  )
	-- body
	--光圈扩散效果
	if self.pTxBuildingCircle then
		self.pTxBuildingCircle:stopAllActions()
		self.pTxBuildingCircle:removeSelf()
		self.pTxBuildingCircle = nil
	end

	--蓝圈加亮
	if self.pBlueImg then
		self.pBlueImg:removeSelf()
		self.pBlueImg = nil
	end

	--粒子效果
	if self.pParitcleB then
		self.pParitcleB:removeSelf()
		self.pParitcleB = nil
	end
end

--移除所有的特效
function ItemHomeLR:removeAllTx(  )
	-- body
	self:removeBuildingTx()
	self:removeUnBuyTx()
	self:removeSleepTx()
	self:removeWwTx()
end

--增加宝箱和卖场图标特效
function ItemHomeLR:addBxAndSaleTx()
	--宝箱特效
	if self.tCurData.nId  == e_index_itemrl.r_bx then
		-- self:showMfbxTx()
	end
	--特价卖场特效
	if self.tCurData.nId  == e_index_itemrl.r_mc then
		self:showSpecialSaleIconTx()
	end
	--首充好礼特效
	if self.tCurData.nId  == e_index_itemrl.r_fc then
		self:showRechargeGiftTx()
	end
	--名将推荐特效
	if self.tCurData.nId == e_index_itemrl.r_hc then
		self:showHeroRecommendTx()
	end
	--王权征收特效
	if self.tCurData.nId == e_index_itemrl.r_wq then
		local tData = Player:getRoyaltyCollectData()
		if tData:isHavePrize() then
			self:showMfbxTx()
		else			--倒计时未到，不能领取奖励
			self:stopMfbxRockAction()
		end
	end
	--教你玩特效
	if self.tCurData.nId == e_index_itemrl.l_jnw then
		self:showTeachPlayGirlTx()
	end
end

--重新设置名字
function ItemHomeLR:resetName(_sName)
	-- body
	self.pLbName:setString(_sName,false)
end

--宝箱特效
function ItemHomeLR:showMfbxTx()
	-- body
	--黄色光圈特效
	if not self.pYellowTx then
		local pos = {0, -7} --偏移位置
		self.pYellowTx = showYellowRing(self.pItem, 3, nil, 0.88, pos)
	end
	--宝箱动画1
	if not self.pBxAction1 then
		showRockTx2(self.pImgIcon)
		self.pBxAction1 = true
	end
	--宝箱动画2
	if not self.pImgBxTx then
		self.pImgBxTx = MUI.MImage.new(self.tCurData.sIcon)
		self.pItem:addView(self.pImgBxTx, 51)
		centerInView(self.pItem,self.pImgBxTx)
		self.pImgBxTx:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pImgBxTx:setOpacity(255*0.3)
		self.pImgBxTx:setScale(self.tCurData.nIconScale)
		showRockTx2(self.pImgBxTx)
	end
	--粒子效果
	if not self.pParitcleD then
		self.pParitcleD = createParitcle("tx/other/lizi_zjmhdbx_zjm_01.plist")
		self.pParitcleD:setPosition(self.pItem:getWidth() / 2 ,self.pItem:getHeight() / 2)
		self.pItem:addView(self.pParitcleD, 99)
		centerInView(self.pItem,self.pParitcleD)
	end
end

--首充好礼常态特效
function ItemHomeLR:showRechargeGiftTx()
	-- body
	--箱子动画1
	if not self.pRGBXAction then
		showFloatTx(self.pImgIcon, 1.2)
		self.pRGBXAction = true
	end
	--箱子动画2
	if not self.pImgFcBx then
		self.pImgFcBx = MUI.MImage.new(self.tCurData.sIcon)
		self.pItem:addView(self.pImgFcBx, 51)
		centerInView(self.pItem,self.pImgFcBx)
		self.pImgFcBx:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pImgFcBx:setOpacity(0)
		self.pImgFcBx:setScale(self.tCurData.nIconScale)
		showFloatTx(self.pImgFcBx, 1.2, 255*0.3)
	end
	--粒子效果
	if not self.pParitcleD then
		self.pParitcleD = createParitcle("tx/other/lizi_zjmhdbx_zjm_01.plist")
		self.pParitcleD:setPosition(self.pItem:getWidth() / 2 ,self.pItem:getHeight() / 2)
		self.pItem:addView(self.pParitcleD, 99)
		centerInView(self.pItem,self.pParitcleD)
	end
end

--名将推荐特效
function ItemHomeLR:showHeroRecommendTx()
	-- body
	--动画1
	if not self.pHcAction then
		showFloatTx(self.pImgIcon)
		self.pHcAction = true
	end
	--动画2
	if not self.pImgHcBx then
		self.pImgHcBx = MUI.MImage.new(self.tCurData.sIcon)
		self.pItem:addView(self.pImgHcBx, 51)
		centerInView(self.pItem,self.pImgHcBx)
		self.pImgHcBx:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pImgHcBx:setOpacity(0)
		self.pImgHcBx:setScale(self.tCurData.nIconScale)
		local action0_1 = cc.FadeTo:create(0, 0)
		local action0_2 = cc.ScaleTo:create(0, self.tCurData.nIconScale)
		local action0   = cc.Spawn:create(action0_1, action0_2)
		local action1_1 = cc.FadeTo:create(0.5, 255*0.25)
		local action1_2 = cc.ScaleTo:create(0.5, self.tCurData.nIconScale*1.09)
		local action1   = cc.Spawn:create(action1_1, action1_2)
		local action2_1 = cc.FadeTo:create(0.5, 0)
		local action2_2 = cc.ScaleTo:create(0.5, self.tCurData.nIconScale*1.18)
		local action2   = cc.Spawn:create(action2_1, action2_2)
		local action3 = cc.DelayTime:create(0.6)
		self.pImgHcBx:runAction(cc.RepeatForever:create(cc.Sequence:create(action0, action1, action2, action3)))
	end
	--动画3
	if not self.pImgHcBx_2 then
		self.pImgHcBx_2 = MUI.MImage.new("#v1_img_v2_btn_wujiangtuijian_001.png")
		self.pItem:addView(self.pImgHcBx_2, 52)
		centerInView(self.pItem,self.pImgHcBx_2)
		self.pImgHcBx_2:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pImgHcBx_2:setOpacity(0)
		showFloatTx2(self.pImgHcBx_2)
	end
end

--停止宝箱上下浮动动画
function ItemHomeLR:stopFcBxAction()
	-- body
	self.pRGBXAction = false
	if self.pImgFcBx then
		self.pImgFcBx:stopAllActions()
		self.pImgFcBx:removeSelf()
		self.pImgFcBx = nil
	end
end

--停止摇摆动作
function ItemHomeLR:stopMfbxRockAction( ... )
	-- body
	self.pImgIcon:stopAllActions()
	self.pImgIcon:setRotation(0)
	if self.pImgBxTx then
		self.pImgBxTx:stopAllActions()
		self.pImgBxTx:removeSelf()
		self.pImgBxTx = nil
	end

    self.pBxAction1 = false

	if self.pYellowTx then
		if self.pYellowTx and table.nums(self.pYellowTx) > 0 then
			local nSize = table.nums(self.pYellowTx)
			for i = nSize, 1, -1 do
				self.pYellowTx[i]:removeSelf()
				self.pYellowTx[i] = nil
			end
		end
		self.pYellowTx = nil
	end
	if self.pParitcleD then
		self.pParitcleD:removeSelf()
		self.pParitcleD=nil
	end

	

end

--特价卖场图标特效
function ItemHomeLR:showSpecialSaleIconTx()
	-- body
	--蓝底加亮
	if not self.pImgBlueLight then
		self.pImgBlueLight = MUI.MImage.new("#zjm_tjmc_hdtx_dt_01.png")
		self.pItem:addView(self.pImgBlueLight, 10)
		self.pImgBlueLight:setScale(2)
		centerInView(self.pItem,self.pImgBlueLight)
		self.pImgBlueLight:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	end
	--图标动画
	local scaleTo1  = cc.ScaleTo:create(0.7, 0.75)
	local scaleTo2  = cc.ScaleTo:create(0.7, 0.7)
	local actions = cc.RepeatForever:create(cc.Sequence:create(scaleTo1, scaleTo2))
	self.pImgIcon:runAction(actions)
	--粒子效果
	if not self.pParitcleC then
		self.pParitcleC = createParitcle("tx/other/lizi_tjmc2_001.plist")
		self.pParitcleC:setPosition(self.pItem:getWidth() / 2 ,self.pItem:getHeight() / 2)
		self.pItem:addView(self.pParitcleC, 99)
		centerInView(self.pItem,self.pParitcleC)
	end
end

--教你玩美女图标特效
function ItemHomeLR:showTeachPlayGirlTx()
	-- body
	if not self.pGirlTx then
		local scaleTo1  = cc.ScaleTo:create(0, 1)
		local scaleTo2  = cc.ScaleTo:create(0.5, 0.9)
		local scaleTo3  = cc.ScaleTo:create(0.5, 1)

		self.pItem:runAction(cc.RepeatForever:create(cc.Sequence:create(scaleTo1, scaleTo2, scaleTo3)))
		self.pGirlTx = true
	end
end

-- --王权征收特效
-- function ItemHomeLR:showWQCollectTx()
-- 	--蓝底加亮
-- 	if not self.pImgBlueLight then
-- 		self.pImgBlueLight = MUI.MImage.new("#zjm_tjmc_hdtx_dt_01.png")
-- 		self.pItem:addView(self.pImgBlueLight, 10)
-- 		self.pImgBlueLight:setScale(2)
-- 		centerInView(self.pItem,self.pImgBlueLight)
-- 		self.pImgBlueLight:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
-- 	end
-- 	--图标动画
-- 	local scaleTo1  = cc.ScaleTo:create(0.7, 0.75)
-- 	local scaleTo2  = cc.ScaleTo:create(0.7, 0.7)
-- 	local actions = cc.RepeatForever:create(cc.Sequence:create(scaleTo1, scaleTo2))
-- 	self.pImgIcon:runAction(actions)
-- 	--粒子效果
-- 	if not self.pParitcleC then
-- 		self.pParitcleC = createParitcle("tx/other/lizi_tjmc2_001.plist")
-- 		self.pParitcleC:setPosition(self.pItem:getWidth() / 2 ,self.pItem:getHeight() / 2)
-- 		self.pItem:addView(self.pParitcleC, 99)
-- 		centerInView(self.pItem,self.pParitcleC)
-- 	end
-- end

-- --移除王权征收特效
-- function ItemHomeLR:removeWQCollectTx()
-- 	--蓝底加亮
-- 	if self.pImgBlueLight then
-- 		self.pImgBlueLight:removeSelf()
-- 		self.pImgBlueLight = nil
-- 	end
-- 	--图标动画
-- 	self.pImgIcon:stopAllActions()
-- 	--粒子效果
-- 	if self.pParitcleC then
-- 		self.pParitcleC:removeSelf()
-- 		self.pParitcleC = nil
-- 	end
-- end

--计时刷新
function ItemHomeLR:onUpdateTime()
	-- body
	if self.tCurData.nId  == e_index_itemrl.l_hjdl or self.tCurData.nId  == e_index_itemrl.l_pydl then --黄金队列、普通队列
		local _nType = 1
		if self.tCurData.nId  == e_index_itemrl.l_hjdl then
			_nType = 2
		end
		
		local nState, pCurBuild = Player:getBuildData():getBuildingQueStateByType(_nType)
		if pCurBuild then
			
			--获取是否有雇佣队列
			local nLeftTime = pCurBuild:getBuildingFinalLeftTime()
			if nLeftTime > 0 then
				
				self.pLbName:setString(formatTimeToHms(nLeftTime),false)
			else
				unregUpdateControl(self)--停止计时刷新
				self.pLbName:setString(formatTimeToHms(0),false)
			end
		else
			unregUpdateControl(self)--停止计时刷新
		end
	elseif self.tCurData.nId  == e_index_itemrl.r_bx then

		local nLeftTime = Player:getDailyGiftData():getNextRewardTime()
		if nLeftTime then
			if nLeftTime==0 then
				unregUpdateControl(self)--停止计时刷新
				self.pLbName:setString(getConvertedStr(6,10472),false)
				self:showMfbxTx()
			else

				self.pLbName:setString(formatTimeToHms(nLeftTime),false)

			end
		end
		
	elseif self.tCurData.nId  == e_index_itemrl.r_tg then
		local tTriGiftList = Player:getTriggerGiftData():getTpackListInCd1()
		if #tTriGiftList > 0 then
			local nLeftTime = tTriGiftList[#tTriGiftList]:getCd()
			if nLeftTime then
				self.pLbName:setString(formatTimeToHms(nLeftTime),false)
			end
		end
	elseif self.tCurData.nId  == e_index_itemrl.d_l_gcld then   --攻城掠地倒计时
		local tActData=Player:getActById(e_id_activity.attackcity)
		if not tActData then
			return
		end
		local sTime = tActData:getOnlyTimeStr()
		self.pLbName:setString(sTime)
		self:updateNameLayer()	
	-- elseif self.tCurData.nId  == e_index_itemrl.d_l_mjrq then   --冥界入侵倒计时
	-- 	local tActData=Player:getActById(e_id_activity.mingjie)
	-- 	if not tActData then
	-- 		return
	-- 	end
	-- 	local nLeftTime =tActData:getStageLeftTime()
	-- 	if nLeftTime == 0 then
	-- 		unregUpdateControl(self)--停止计时刷新
	-- 		self.pLbName:setString(getConvertedStr(9,10149),false)
	-- 	else

	-- 		self.pLbName:setString(formatTimeToHms(nLeftTime),false)

	-- 	end
	-- 	self:updateNameLayer()
	end
end

--建筑状态发生变化
function ItemHomeLR:changeBuildState( sMsgName, pMsgObj )
	-- body
	if self.nType == 2 then --左边对联才处理
		if self.tCurData.nId  == e_index_itemrl.l_pydl 
			or self.tCurData.nId  == e_index_itemrl.l_hjdl then --如果是普通队列 黄金队列 才执行对应的刷新操作
			--刷新数据
			self:setMsgOrActionByType(1)
		end
	end
	
end

--建筑数据发生变化
function ItemHomeLR:onRefreshBuildDatas( sMsgName, pMsgObj )
	-- body
	if self.nType == 2 then --左边对联才处理
		if self.tCurData.nId  == e_index_itemrl.l_hjdl then --如果是黄金队列 才执行对应的刷新操作
			--刷新数据
			self:setMsgOrActionByType(1)
		elseif self.tCurData.nId  == e_index_itemrl.l_sjbc then --如果是城墙 才执行对应的刷新操作
			--刷新数据
			self:setMsgOrActionByType(1)
		end
	end
end

-- 析构方法
function ItemHomeLR:onItemHomeLRDestroy(  )
	-- body
	self:unregMsgs()
	unregUpdateControl(self)--停止计时刷新
end

--动态设置对联按钮位置
function ItemHomeLR:updateNameLayer(  )
	-- body
	if self.nType == 2 or self.nType == 3 or self.nType==4 then --左边

		if self.pLbName:getWidth() == self.pLayName:getWidth() then
			return
		end
		if string.getUTF8Length(self.pLbName:getString()) == 2 then
			self.pLayName:setLayoutSize(66, self.pLayName:getHeight())
		elseif string.getUTF8Length(self.pLbName:getString()) == 4 or string.getUTF8Length(self.pLbName:getString()) == 3 then
			
			self.pLayName:setLayoutSize(96, self.pLayName:getHeight())
		else
			self.pLayName:setLayoutSize(106, self.pLayName:getHeight())
		end
		
		self.pLbName:setPositionX(self.pLayName:getWidth() / 2)
		--设置位置
		self.pLayName:setPositionX((self:getWidth() - self.pLayName:getWidth()) / 2)
	end
	
end

--_nType 1:蓝色图 2.黄色图  4:武王伐纣
function ItemHomeLR:setNameBgAndCircleBg(_nType)
	_nType = _nType or 2 
	if _nType == 1 or _nType == 3 then
		self.pItem:setBackgroundImage("#v1_img_zjm_wpkdl.png")
		self.pLayName:setBackgroundImage("#v1_img_tubiaowzdl.png")
	elseif _nType==4 then 
		self.pItem:removeBackground()
		-- self.pLayName:setBackgroundImage("#v1_img_tubiaowzdh.png")
		-- self.pImgIcon:removeBackgroundImage()
	elseif _nType == 2  then
		self.pItem:setBackgroundImage("#v1_img_zjm_wpkdh.png")
		self.pLayName:setBackgroundImage("#v1_img_tubiaowzdh.png")
	end
	
end

--设置当前数据
function ItemHomeLR:setCurData( _data)
	-- body
	self.tCurData = _data
	self:updateViews()
end

--获取当前数据
function ItemHomeLR:getCurData(  )
	-- body
	return self.tCurData
end

--点击事件
function ItemHomeLR:onItemClicked( pView )
	-- body
	if self.nType == 1 then  --右边
		if self.tCurData then
			local tObject = {} 
			if self.tCurData.nId  == e_index_itemrl.r_hd then --活动
				tObject.nType = e_dlg_index.actmodela --dlg类型
			elseif self.tCurData.nId  == e_index_itemrl.r_fl then --福利
				tObject.nType = e_dlg_index.actmodelb --dlg类型
			elseif self.tCurData.nId  == e_index_itemrl.r_sd then --商店
				tObject.nType = e_dlg_index.shop --dlg类型
			elseif self.tCurData.nId  == e_index_itemrl.r_gg then --公告
				tObject.nType = e_dlg_index.dlgnoticemain --dlg类型
			end
			sendMsg(ghd_show_dlg_by_type,tObject)
		end
	elseif self.nType == 3 then
		if self.tCurData.nId  == e_index_itemrl.r_mc then --特价卖场
			local tObject = {} 
			tObject.nType = e_dlg_index.dlgspecialsale --dlg类型
			sendMsg(ghd_show_dlg_by_type,tObject)
		elseif self.tCurData.nId  == e_index_itemrl.r_bx then --免费宝箱
			-- local  nLeftTime = Player:getDailyGiftData():getNextRewardTime()
			-- if nLeftTime then
			-- 	if nLeftTime==0 then
			-- 		SocketManager:sendMsg("getDailyGiftRes", {}, handler(self, self.getDailyGiftCallback))
			-- 	else
			-- 		TOAST(string.format(getConvertedStr(6,10580),getTimeFormatCn(nLeftTime)))
			-- 	end

			-- end
			local tObject = {} 
			tObject.nType = e_dlg_index.dlgdailygift --dlg类型
			sendMsg(ghd_show_dlg_by_type,tObject)
		elseif self.tCurData.nId == e_index_itemrl.r_hc then --名将推荐
			local tObject = {} 
			tObject.nType = e_dlg_index.herorecommend --dlg类型
			sendMsg(ghd_show_dlg_by_type,tObject)
		elseif self.tCurData.nId == e_index_itemrl.r_fc then --首充好礼
			local tActData = Player:getActById(e_id_activity.newfirstrecharge)		--首充好礼
			local tObject = {} 
			if tActData and tActData.nT ~= 2 then
				tObject.nType = e_dlg_index.dlgnewfirstrecharge --dlg类型
			else
				tObject.nType = e_dlg_index.dlgseveralrecharge --dlg类型
			end
			

			sendMsg(ghd_show_dlg_by_type,tObject)
		elseif self.tCurData.nId == e_index_itemrl.r_tg then --触发礼包
			local tObject = {
			    nType = e_dlg_index.triggergift, --dlg类型
			}
			sendMsg(ghd_show_dlg_by_type, tObject)
		elseif self.tCurData.nId == e_index_itemrl.r_wq then --王权征收
			local tObject = {
			    nType = e_dlg_index.dlgroyaltycollect, --dlg类型
			}
			sendMsg(ghd_show_dlg_by_type, tObject)			
		end
	elseif self.nType==4 then
		if self.tCurData.nId == e_index_itemrl.d_l_wwtf then 		--武王伐纣
			local tWuWangForcast = Player:getActById(e_id_activity.wuwangforcast)
			local tObject = {} 
			tObject.nType = e_dlg_index.wuwang --dlg类型
			
			if tWuWangForcast and tWuWangForcast:getOpenTime() > 0 and tWuWangForcast:isOpen() then
				tObject.nType = e_dlg_index.wuwangforcast --dlg类型
			end
			sendMsg(ghd_show_dlg_by_type,tObject)

		elseif self.tCurData.nId == e_index_itemrl.d_l_gcld then 		--攻城掠地
			-- local tData = Player:getActById(e_id_activity.wuwangforcast)
			local tObject = {} 
			tObject.nType = e_dlg_index.attkcity --dlg类型
			
			-- if tWuWangForcast and tWuWangForcast:getOpenTime() > 0 and tWuWangForcast:isOpen() then
			-- 	tObject.nType = e_dlg_index.wuwangforcast --dlg类型
			-- end
			sendMsg(ghd_show_dlg_by_type,tObject)
			
		elseif self.tCurData.nId == e_index_itemrl.d_l_tlboss then --限时Boss
			local tObject = {} 
			tObject.nType = e_dlg_index.tlboss --dlg类型
			sendMsg(ghd_show_dlg_by_type,tObject)
		elseif self.tCurData.nId == e_index_itemrl.d_l_mjrq then 		--冥界入侵
			local tObject = {} 
			tObject.nType = e_dlg_index.mingjie --dlg类型
			
			sendMsg(ghd_show_dlg_by_type,tObject)
		elseif self.tCurData.nId == e_index_itemrl.d_l_epw then 		--决战皇城
			local tObject = {} 
			tObject.nType = e_dlg_index.eqw --dlg类型
			sendMsg(ghd_show_dlg_by_type,tObject)
		elseif self.tCurData.nId == e_index_itemrl.d_l_gjbk then 		--王者宝藏
			local state = getLocalInfo("nationaltreasurerednums"..Player:getPlayerInfo().pid,"false")
			if state == "false" then
				saveLocalInfo("nationaltreasurerednums"..Player:getPlayerInfo().pid,"true")
				self:refreshNationalTreasureRedNum()
			end
			local tOb = {}
	    	tOb.nType = e_dlg_index.nationaltreasure
	    	sendMsg(ghd_show_dlg_by_type, tOb)
	    elseif self.tCurData.nId == e_index_itemrl.d_l_zwsl then
			local tObject = {} 
			tObject.nType = e_dlg_index.dlgzhouwangdots --dlg类型
			sendMsg(ghd_show_dlg_by_type,tObject)	    	
		end
	else  					 --左边
		--设置点击响应
		self:setMsgOrActionByType(2)
	end
end
function ItemHomeLR:refreshRedTip(  )
	-- body
	self:initRedNum()
	self:refreshWwState()
end

--初始化红点
function ItemHomeLR:initRedNum()
	local nRedType = 0
	local nRedNums = 0

	if self.nType == 1 then --右对联
		local nActANums,nActBNums = Player:getActRedNums()

		if self.tCurData.nId  == e_index_itemrl.r_hd then --活动
			nRedNums = nActANums
		elseif self.tCurData.nId  == e_index_itemrl.r_fl then --福利
			nRedNums = nActBNums
		elseif self.tCurData.nId  == e_index_itemrl.r_sd then --商店
			nRedNums = Player:getPlayerInfo():getVipGiftRedNum()
		elseif self.tCurData.nId  == e_index_itemrl.r_gg then --公告
			nRedNums = Player:getNoticeData():getNoticeRedNums()
		end
	elseif self.nType == 2 then --左对联
		if self.tCurData.nId  == e_index_itemrl.l_zdjz then --自动建造
			nRedType = 1
			nRedNums = Player:getBuildData().nAutoUpTimes or 0
		elseif self.tCurData.nId  == e_index_itemrl.l_sjbc then --守军补充
			nRedType = 1
			nRedNums = Player:getBuildData().nAutoRecruit or 0
		elseif self.tCurData.nId  == e_index_itemrl.l_yjzs then --一键征收
			--目前策划说不需要红点提示
			-- nRedType = 0
			-- nRedNums = 1 
		-- elseif  self.tCurData.nId  == e_index_itemrl.l_gjbk then --国家宝库
		-- 	nRedType = 0
		-- 	nRedNums = Player:getNationalTreasureData():getRedNums()
		end
	end

	showRedTips(self.pLyRed,nRedType,nRedNums)
	self:refreshTLBossRedNum()
	self:refreshKingZhouRedNum()
	self:refreshNationalTreasureRedNum()
	self:refreshEpwRedNum()
end

--限时Boss红点刷新
function ItemHomeLR:refreshTLBossRedNum( )
	if not self.tCurData then
		return
	end

	if not self.tCurData.nId  then
		return
	end
	if self.tCurData.nId == e_index_itemrl.d_l_tlboss then
		local nState = Player:getTLBossData():getTh()
		local nState2 = Player:getTLBossData():getTf()
		local nState3 = Player:getTLBossData():getTh()
		local nRedNum = 0
		if nState == e_tlboss_award.get or nState2 == e_tlboss_award.get or nState3 == e_tlboss_award.get then
			nRedNum = 1
		end
		showRedTips(self.pLyRed, 0, nRedNum)
	end
end

function ItemHomeLR:refreshKingZhouRedNum( ... )
	-- body
	if not self.tCurData then
		return
	end

	if not self.tCurData.nId  then
		return
	end
	if self.tCurData.nId == e_index_itemrl.d_l_zwsl then
		local nRedType = 1
		local nRedNum = 0
		local pActivity=Player:getActById(e_id_activity.zhouwangtrial)
		if pActivity then
			nRedNum = pActivity:getCurKingZhouNum()
		end			
		showRedTips(self.pLyRed, nRedType, nRedNum)	
	end	
end

--刷新皇城战红点
function ItemHomeLR:refreshEpwRedNum( )
	if not self.tCurData then
		return
	end

	if not self.tCurData.nId  then
		return
	end
	if self.tCurData.nId == e_index_itemrl.d_l_epw then
		local nRedNum = 0
		local bCan1 = Player:getImperWarData():getIsRankAward()
		local bCan2 = Player:getImperWarData():getIsStageAward()
		if bCan1 or bCan2 then
			nRedNum = 1
		end
		showRedTips(self.pLyRed, 0, nRedNum)
	end
end



--限时Boss红点刷新
function ItemHomeLR:refreshNationalTreasureRedNum( )
	if not self.tCurData then
		return
	end

	if not self.tCurData.nId  then
		return
	end
	if self.tCurData.nId == e_index_itemrl.d_l_gjbk then
		local nRedNum = Player:getNationalTreasureData():getRedNums()
		showRedTips(self.pLyRed, 0, nRedNum)
	end
end

function ItemHomeLR:refreshPlayerInfo()
	if not self.tCurData then
		return
	end

	if not self.tCurData.nId  then
		return
	end
	if self.tCurData.nId == e_index_itemrl.d_l_gjbk then
		self:refreshNationalTreasureRedNum()
	end
end

--红点刷新
function ItemHomeLR:refreshRedNums(msgName,pMsg)

	if not self.tCurData then
		return
	end

	if not self.tCurData.nId  then
		return
	end

	--nRedType(红点类型) nRedNums(红点个数)
	--print("refreshRedNums",pMsg.nType,self.tCurData.nId,pMsg.nRedNums)
	if pMsg and pMsg.nType and pMsg.nRedType and pMsg.nRedNums then
		if self.tCurData.nId  == e_index_itemrl.r_sd then --商店
			showRedTips(self.pLyRed,0,Player:getPlayerInfo():getVipGiftRedNum())
		else
			if pMsg.nType == self.tCurData.nId then
				showRedTips(self.pLyRed,pMsg.nRedType,pMsg.nRedNums)
			end
		end
	end
	-- if self.tCurData.nId  == e_index_itemrl.r_mc then
	-- 	local tAct = Player:getActById(e_id_activity.specialsale)
	-- 	if not tAct then
	-- 		self:setVisible(false)
	-- 	end
	-- end
	--特价卖场红点提示改在HomeCenterLayer执行
end

--一键征收界面回调
function ItemHomeLR:collectFastResponse( __msg, __oldMsg )
	-- body
	if __msg.head.type == MsgType.collectRes.id then 			--建筑升级
		if __msg.head.state == SocketErrorType.success then
			if __msg.body.o then
				print("获得物品表现")
			end
		else
		    TOAST(SocketManager:getErrorStr(__msg.head.state))
        end
    end
end

--自动升级请求界面回调刷新
function ItemHomeLR:autoBuildingResponse( __msg, __oldMsg )
	-- body
	if __msg.head.type == MsgType.autoBuilding.id then 			--建筑升级
		if __msg.head.state == SocketErrorType.success then
			if __msg.body.openAuto then
				TOAST(getTipsByIndex(10080))
			else
				TOAST(getTipsByIndex(10081))
			end
			--后面完善表现
			self:updateViews()
		else
		    TOAST(SocketManager:getErrorStr(__msg.head.state))
        end
    end
	
end

--自动升级请求界面回调刷新
function ItemHomeLR:autoDefSwResponse( __msg, __oldMsg )
	-- body
	if __msg.head.type == MsgType.wallAutoDefSw.id then 			--建筑升级
		if __msg.head.state == SocketErrorType.success then
			--后面完善表现
			self:updateViews()
		else
		    TOAST(SocketManager:getErrorStr(__msg.head.state))
        end
    end
end
--0点刷新宝箱
function ItemHomeLR:refreshBxByPush( )
	-- body
	if self.tCurData.nId  == e_index_itemrl.r_bx then
		unregUpdateControl(self)
		self:updateViews()
		-- print("ceshipush")
	end

end
--刷新宝箱状态
function ItemHomeLR:refreshBxState( )
	-- body
	local nLeftTime =Player:getDailyGiftData():getNextRewardTime()
	if nLeftTime then		--还有可领取次数
		if nLeftTime==0 then		--倒计时到达，可领取奖励
			self.pLbName:setString(getConvertedStr(6,10472),false)
			self:showMfbxTx()
			--动态设置位置
			self:updateNameLayer()
		else			--倒计时未到，不能领取奖励
			self:stopMfbxRockAction()
			self.pLbName:setString(formatTimeToHms(nLeftTime),false)
			
			-- print(getTimeFormatCn(nLeftTime))
			-- 动态设置位置
			self:updateNameLayer()
			regUpdateControl(self, handler(self, self.onUpdateTime))		--注册更新倒计时
			
		end
	else 			--今日次数已用完
		self.pLbName:setString(self.tCurData.sName,false)
		-- 动态设置位置
		self:updateNameLayer()
	end
	
end

--领取宝箱奖励回调
function ItemHomeLR:getDailyGiftCallback( __msg, __oldMsg )
	-- body
	if __msg.head.type == MsgType.getDailyGiftRes.id then 			--领取宝箱奖励
		if __msg.head.state == SocketErrorType.success then
			--后面完善表现
			self:updateViews()
		else
		    TOAST(SocketManager:getErrorStr(__msg.head.state))
        end
    end
end


--播放武王伐紂的特效
function ItemHomeLR:playWwRewardEffect( )
	--位置
	-- local nX, nY = 0, 0--self.pImgIcon:getPosition()
	-- --层次
	-- local nZorder = 1

	-- local pSeqAct = cc.Sequence:create({
	-- 	cc.ScaleTo:create(0, 0.93),
	-- 	cc.ScaleTo:create(0.7, 1),
	-- 	cc.ScaleTo:create(1.4 - 0.7, 0.93),
	-- })
	-- self.pImgIcon:runAction(cc.RepeatForever:create(pSeqAct))

	--粒子
	if self.pWwRewardParitcle then
		self.pWwRewardParitcle:setVisible(true)
	else
		local pWwRewardParitcle =  createParitcle("tx/other/lizi_remw_003.plist")
		self.pWwRewardParitcle = pWwRewardParitcle
		self.pItem:addView(self.pWwRewardParitcle, 99)
		centerInView(self.pItem,self.pWwRewardParitcle)
		
	end

	-- --旋转光（自循环）
	-- if not self.pWwRotateArm then
	-- 	addTextureToCache("tx/other/lizi_remw_003")
	-- 	local tArmData = {
	-- 		nFrame = 12, -- 总帧数
	-- 		pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	-- 		fScale = 1.25,-- 初始的缩放值
	-- 		nBlend = 1, -- 需要加亮
	-- 	   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
	-- 		tActions = {
	-- 			 {
	-- 				nType = 1, -- 序列帧播放
	-- 				sImgName = "lizi_remw_003_",
	-- 				nSFrame = 1, -- 开始帧下标
	-- 				nEFrame = 12, -- 结束帧下标
	-- 				tValues = nil, -- 参数列表
	-- 			},
	-- 		},
	-- 	}

	-- 	local pArmAction = MArmatureUtils:createMArmature(
	-- 	tArmData, 
	-- 	self.pImgIcon, 
	-- 	nZorder, 
	-- 	cc.p(nX, nY),
	--     nil, Scene_arm_type.normal)
	-- 	pArmAction:play(-1)
	-- 	self.pWwRotateArm = pArmAction
	-- else
	-- 	self.pWwRotateArm:setVisible(true)
	-- 	self.pWwRotateArm:play(-1)
	-- end

	-- --图片呼吸效果（自循环）
	-- local nMyTargetId = Player:getWorldData():getMyWorldTargetId()
	-- if nMyTargetId then
	-- 	local tWorldTargetData = getWorldTargetData(nMyTargetId)
	-- 	if tWorldTargetData then
	-- 		local tArmData  =  {
	-- 			nFrame = 24, -- 总帧数
	-- 			pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	-- 			fScale = 1,-- 初始的缩放值
	-- 			nBlend = 1, -- 需要加亮
	-- 		  	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
	-- 			tActions = {
	-- 				{
	-- 					nType = 2, -- 透明度
	-- 					sImgName = tWorldTargetData.icon,--"替换世界BOSS图标的图片例如文件中的“v1_btn_uddo”",
	-- 					nSFrame = 1,
	-- 					nEFrame = 12,
	-- 					tValues = {-- 参数列表
	-- 						{0, 80}, -- 开始, 结束透明度值
	-- 					}, 
	-- 				},
	-- 				{
	-- 					nType = 2, -- 透明度
	-- 					sImgName = tWorldTargetData.icon,--"替换世界BOSS图标的图片例如文件中的“v1_btn_uddo”",
	-- 					nSFrame = 13,
	-- 					nEFrame = 24,
	-- 					tValues = {-- 参数列表
	-- 						{80, 0}, -- 开始, 结束透明度值
	-- 					}, 
	-- 				},
	-- 			},
	-- 		}
	-- 		if not self.pBreahthArm then
	-- 			local pArmAction = MArmatureUtils:createMArmature(
	-- 			tArmData, 
	-- 			self.pLayArm, 
	-- 			nZorder, 
	-- 			cc.p(nX, nY),
	-- 		    nil, Scene_arm_type.normal)
	-- 			pArmAction:play(-1)
	-- 			self.pBreahthArm = pArmAction
	-- 		else
	-- 			self.pBreahthArm:setVisible(true)
	-- 			self.pBreahthArm:play(-1)
	-- 		end
	-- 	end
	-- end
end

function ItemHomeLR:removeWwTx( )
	-- body

	self.pImgIcon:stopAllActions()
	if self.pWwRewardParitcle then
		self.pWwRewardParitcle:removeSelf()
		self.pWwRewardParitcle=nil
	end

end

--刷新武王伐纣状态
function ItemHomeLR:refreshWwState( )
	-- body
	-- local nLeftTime =Player:getDailyGiftData():getNextRewardTime()
	if not self.pWwRed then
		self.pWwRed = MUI.MLayer.new(true)
		self.pWwRed:setLayoutSize(26, 26)		
		self.pWwRed:setPosition(self.pItem:getWidth()-35, self.pItem:getHeight()-25)
		self.pItem:addView(self.pWwRed, 100)
	end
	
	--获取活动数据
	if self.tCurData.nId == e_index_itemrl.d_l_wwtf then
		local tData = Player:getActById(e_id_activity.wuwang)
		if tData then
			showRedTips(self.pWwRed, 0,tData:getRedNums())
			-- if tData:getRedNums() >0 then
			-- 	-- self:playWwRewardEffect()

			-- else
			-- 	self:removeWwTx()
			-- end
		end
	elseif self.tCurData.nId == e_index_itemrl.r_wq then
		local tData = Player:getRoyaltyCollectData()
		if tData:isHavePrize() then
			self:showMfbxTx()
		else			--倒计时未到，不能领取奖励
			-- self.pLbName:setString(getToNextDayTime(nLeftTime))
			-- self:updateNameLayer()
			-- regUpdateControl(self, handler(self, self.onUpdateTime))		--注册更新倒计时
			self:stopMfbxRockAction()
		end
	--获取活动数据
	elseif self.tCurData.nId == e_index_itemrl.d_l_gcld then
		local tData = Player:getActById(e_id_activity.attackcity)
		if tData then
			showRedTips(self.pWwRed, 0,tData:getRedNums())
		end
	--获取活动数据
	elseif self.tCurData.nId == e_index_itemrl.d_l_mjrq then
		local tData = Player:getActById(e_id_activity.mingjie)
		if tData then
			showRedTips(self.pWwRed, 0,tData:getRedNums())
		end
	end
end

function ItemHomeLR:refreshZDJZ( )
	-- body
	if self.tCurData.nId == e_index_itemrl.l_zdjz then
		self:setMsgOrActionByType(1)		
	end
end

--获取id
function ItemHomeLR:getId( )
	if self.tCurData then
		return self.tCurData.nId
	end
	return nil
end

--直接打开购买vip商店的物品
function ItemHomeLR:openBuyVipShop( _nGoodId )
	-- body
	local tShopBase = getShopDataById( _nGoodId )


	local bNeedVipGift, bHadVipGift, tStr = ShopFunc.getGoodVipGiftInfo( _nGoodId )
	if (bNeedVipGift == true and bHadVipGift == false) then
		local tObject = {
			nType = e_dlg_index.vipgitfgoodtip, --dlg类型
			tShopBase = tShopBase,
		}
		sendMsg(ghd_show_dlg_by_type, tObject)	
	else
		local tObject = {
			nType = e_dlg_index.shopbatchbuy, --dlg类型
			tShopBase = tShopBase,
		}
		sendMsg(ghd_show_dlg_by_type, tObject)	
	end
end
return ItemHomeLR