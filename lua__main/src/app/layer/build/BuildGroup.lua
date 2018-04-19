-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-25 19:42:16 星期二
-- Description: 基地建筑
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local BuildMoreMsgLayer = require("app.layer.build.BuildMoreMsgLayer")
local BuildBubbleLayer = require("app.layer.build.BuildBubbleLayer")
local BuildLv = require("app.layer.build.BuildLv")

--冒泡类型
e_type_bubble = {
	sjmf 			= 		1, 			--升级免费
	zmwg 			= 		2, 			--招募文官
	kjtb 			= 		3, 			--科技图标
	bbmb 			= 		4, 			--步兵募兵
	qbmb 			= 		5, 			--骑兵募兵
	gbmb 			= 		6, 			--弓兵募兵
	mjzs 			= 		7, 			--民居征收
	mczs 			= 		8, 			--木场征收
	ntzs 			= 		9, 			--农田征收
	tkzs 			= 		10, 		--铁矿征收
	tjptb 			= 		11, 		--铁匠铺图标
	zbgfp 			= 		12, 		--珍宝阁翻牌图标
	bjtzm 			= 		13, 		--拜将台免费招募图标
	xlpmfxl         =       14,         --洗炼铺免费洗炼
	gatebc          =       15,         --城门补充城防
	ateliertb       =       16,         --工坊材料图标
	tjpspeedfree    =       17,         --铁匠铺雇佣了铁匠时的免费加速图标
	kjyspeedfree    =       18,         --科技院雇佣了学者时的免费加速图标
	mjjzcj			= 		19,			--民居建筑重建
	mcjzcj			= 		20,			--木材建筑重建
	ntjzcj			= 		21,			--农田建筑重建
	tkjzcj			= 		22,			--铁矿建筑重建
	tnolyspeed		= 		23,			--乱军科研加速
	campspeed		= 		24,			--乱军募兵加速
	buildspeed		= 		25,			--乱军建筑升级加速
	herotravel		= 		26,			--武将游历
	recruit 		= 		27, 		--兵营招募
	tsfactivate 	= 		28, 		--统帅府御兵术激活
	jzkx 			= 		29,			--建筑空闲
	ybssj       	= 		30, 		--御兵术升级
	jjctz 			= 		31, 		--竞技场挑战
	zydh 			= 		32, 		--仓库资源兑换冒泡
	zzdt 			= 		33, 		--战争大厅
	mbfjz 			= 		34, 		--募兵府可建造冒泡提示
	gjqz		 	= 		35, 		--国家求助
}

local BuildGroup = class("BuildGroup", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_tBuildInfo：建筑数据
function BuildGroup:ctor( _tBuildInfo )
	-- body
	self:myInit()
	if not _tBuildInfo then
		print("_tBuildInfo建筑数据不能为nil")
		return
	end
	self.tBuildInfo = _tBuildInfo
	self.nCellIndex = self.tBuildInfo.nCellIndex
	-- 初始化相关的参数
	if(self.tBuildInfo) then
		self.tShowData = getBuildGroupShowDataByCell(self.tBuildInfo.nCellIndex,self.tBuildInfo.sTid)
		self.tBuildInfo.tShowData = self.tShowData
	end

	parseView("build_group", handler(self, self.onParseViewCallback))

end

--初始化成员变量
function BuildGroup:myInit(  )
	-- body
	self.tBuildInfo 		= 		nil 		--建筑数据
	self.tShowData 			= 		nil 		--建筑展示相关数据
	self.nCellIndex 		= 		nil 		--建筑格子下标

	self.pLayTopMsg 		= 		nil 		--di顶部信息层

    self.bBubbleState       =       true        --气泡数据状态

end

--解析布局回调事件
function BuildGroup:onParseViewCallback( pView )
	-- body
	self:addView(pView,200)
	self.pLayTopMsg = pView

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("BuildGroup",handler(self, self.onBuildGroupDestroy))
end

--初始化控件
function BuildGroup:setupViews( )
	-- body

	if self.tShowData then
		self:setLayoutSize(self.tShowData.w, self.tShowData.h)
		-- self:setBackgroundImage("#v1_bg_1.png")

		--创建一个建筑图片
		self.pImgBuild = MUI.MImage.new(self.tShowData.img)
		--设置缩放比例
		self.pImgBuild:setScale(self.tShowData.fGroupScale)
		self:addView(self.pImgBuild, 10)
		centerInView(self,self.pImgBuild)
		self.pLayBUildFinger = MUI.MLayer.new()
		self.pLayBUildFinger:setLayoutSize(self.pImgBuild:getWidth(), self.pImgBuild:getHeight())		
		self:addView(self.pLayBUildFinger, 222)
		centerInView(self,self.pLayBUildFinger)
		--设置点击事件
		-- self:setViewTouched(true)
		-- self:setIsPressedNeedScale(false)
		-- self:onMViewClicked(handler(self, self.onBuildClicked))
		
		--名字
		self.pLayName 			= 	self:findViewByName("lay_name")
		self.pLbName 			= 	self:findViewByName("lb_name")
		setTextCCColor(self.pLbName, _cc.myellow)
		--等级
		self.pLayLv 			= 	self:findViewByName("lay_lv")
		self.pLbLv 				= 	self:findViewByName("lb_lv")
		setTextCCColor(self.pLbLv, _cc.myellow)
		--是否可升级
		self.pImgUp 			= 	self:findViewByName("img_up")
		self.pImgUp:setVisible(false)

		--设置顶部信息层的位置
		if self.tBuildInfo.nCellIndex > n_start_suburb_cell then  	--资源田
			if not b_open_scroll_hide_suburb then --不开启，展示
				self.pLayName:setVisible(false)
			else
				self.pLayName:setVisible(true)
			end
		else 														--城内建筑
			self.pLayName:setVisible(true)
		end
		local nPosX = self.tShowData.w * self.tShowData.fBtRw - self.pLayTopMsg:getWidth() / 2 - 35
		local nPosY = self.tShowData.h * self.tShowData.fBtRh - 10

		--位置计算
		if  self.tBuildInfo.sTid == e_build_ids.palace then --王宫
			nPosX = nPosX + 30
			nPosY = nPosY + 15
		elseif  self.tBuildInfo.sTid == e_build_ids.store then --仓库
			nPosX = nPosX + 15
			nPosY = nPosY + 11
		elseif  self.tBuildInfo.sTid == e_build_ids.tnoly then --科学院
			nPosX = nPosX + 15
		elseif  self.tBuildInfo.sTid == e_build_ids.infantry then --步兵营
		elseif  self.tBuildInfo.sTid == e_build_ids.sowar then --骑兵营
			nPosX = nPosX - 20
			nPosY = nPosY - 20
		elseif  self.tBuildInfo.sTid == e_build_ids.archer then --弓兵营
			nPosY = nPosY - 20
		elseif  self.tBuildInfo.sTid == e_build_ids.atelier then --作坊
			nPosX = nPosX + 25
		elseif  self.tBuildInfo.sTid == e_build_ids.tjp then --铁匠铺
			nPosX = nPosX + 15
		elseif  self.tBuildInfo.sTid == e_build_ids.ylp then --冶炼铺
			nPosX = nPosX + 30
			nPosY = nPosY + 10
		elseif  self.tBuildInfo.sTid == e_build_ids.jxg then --将军府
			nPosX = nPosX + 13
			nPosY = nPosY + 10
		elseif  self.tBuildInfo.sTid == e_build_ids.jbp then --珍宝阁
			nPosX = nPosX + 20
			nPosY = nPosY + 10
		elseif  self.tBuildInfo.sTid == e_build_ids.bjt then --拜将台
			nPosX = nPosX + 15
		elseif  self.tBuildInfo.sTid == e_build_ids.house then --民居
			nPosX = nPosX + 60
			nPosY = nPosY + 10
		elseif  self.tBuildInfo.sTid == e_build_ids.wood then --木场
			nPosX = nPosX + 70
			nPosY = nPosY
		elseif  self.tBuildInfo.sTid == e_build_ids.farm then --农田
			nPosX = nPosX + 58
			nPosY = nPosY + 10
		elseif  self.tBuildInfo.sTid == e_build_ids.iron then --铁矿
			nPosX = nPosX + 65
			nPosY = nPosY + 10
		elseif self.tBuildInfo.sTid == e_build_ids.gate then --如果是城门，需要再低一点
			nPosX = nPosX + 25
			nPosY = nPosY + 20
		elseif  self.tBuildInfo.sTid == e_build_ids.tcf then --将军府
			nPosX = nPosX + 13
			nPosY = nPosY + 10
		elseif  self.tBuildInfo.sTid == e_build_ids.arena then --竞技场
			nPosX = nPosX + 50
			nPosY = nPosY - 20				
		elseif  self.tBuildInfo.sTid == e_build_ids.mbf then --募兵府
			nPosY = nPosY - 10			
		end

		self.pLayTopMsg:setPosition(nPosX, nPosY)

		--教你玩引导
		Player:getGirlGuideMgr():registeredBuildSelfEnter(self.pLayBUildFinger, self.tBuildInfo)
		
	end
end

-- 修改控件内容或者是刷新控件数据
function BuildGroup:updateViews(  )
	-- body
	if self.tBuildInfo then
		--名字
		if self.tBuildInfo.nCanUp == 1 then --可以升级
			if self.tBuildInfo.sTid == e_build_ids.tnoly 
				or self.tBuildInfo.sTid == e_build_ids.infantry
				or self.tBuildInfo.sTid == e_build_ids.sowar
				or self.tBuildInfo.sTid == e_build_ids.archer
				or self.tBuildInfo.sTid == e_build_ids.mbf then
				self.pLbName:setString(self.tBuildInfo.sName)
				self.pLbName:setPosition(self.pLayName:getWidth() / 2 + 8, self.pLayName:getHeight() / 2)
			else
				self.pLbName:setString(self.tBuildInfo.sName)
			end
			
			self.pLbLv:setString(self.tBuildInfo.nLv)

			--判断是否可升级
			if self.tBuildInfo.nState == e_build_state.uping then
				self.pImgUp:setVisible(false)
			else
				local bCanUp = self.tBuildInfo:isBuildCanUp(2)
				self.pImgUp:setVisible(bCanUp)

			end
			
		else 								--不可以升级
			self.pLbName:setString(self.tBuildInfo.sName)
			--调整建筑名称的位置
			self.pLbName:setPosition(self.pLayName:getWidth() / 2,self.pLayName:getHeight() / 2)
			self.pLayLv:setVisible(false)
			self.pLbLv:setVisible(false)
		end
		
		--上锁状态显示或隐藏
		local bLocked = self:updateLock()

		if not bLocked then
			--刷新当前状态
			self:updateCurState()
			--刷新资源田征收状态
			self:updateSubColState()
			self.pImgBuild:setOpacity(255)
		else
			
			self.pImgBuild:setOpacity(255*0.8)
			
		end
		--刷新建筑图片处理
		self:updateBuildImg(bLocked)
	end
end

-- 析构方法
function BuildGroup:onBuildGroupDestroy(  )
	-- body
	self:onPause()
	--移除常态建筑特效
	self:removeBuildNormalTx()
end

-- 注册消息
function BuildGroup:regMsgs( )
	-- body

	if self.tBuildInfo then
		--建筑特有的消息刷新
		if self.tBuildInfo.nCellIndex == e_build_cell.tjp then --铁匠铺
			-- 注册打造装备刷新的消息
			regMsg(self, gud_equip_makevo_refresh_msg, handler(self, self.refreshEquipMake))
			-- 注册打造装备发生变化的消息
			regMsg(self, gud_equip_makevo_change_msg, handler(self, self.refreshEquipMake))
			--注册雇用铁匠信息刷新
			regMsg(self, gud_equip_smith_hire_msg, handler(self, self.refreshEquipMake))
		elseif self.tBuildInfo.nCellIndex == e_build_cell.palace then --王宫
			--注册成功雇用文官事件
			regMsg(self, ghd_refresh_palacecivil, handler(self, self.refreshPalaceOffical))
		elseif self.tBuildInfo.nCellIndex == e_build_cell.tnoly then --科技园
			-- 注册科技数据变化消息
			regMsg(self, gud_refresh_tnoly_lists_msg, handler(self, self.refreshTnolyDatas))
			-- 注册雇佣研究员新消息
			regMsg(self, ghd_refresh_researcher_msg, handler(self, self.refreshResercherDatas))
		elseif self.tBuildInfo.nCellIndex == e_build_cell.atelier then --工坊
			-- 注册工坊队列刷新消息
			regMsg(self, ghd_refresh_atelier_msg, handler(self, self.refreshAtelierDatas))
		elseif self.tBuildInfo.nCellIndex == e_build_cell.jbp then --珍宝阁
			-- 注册珍宝阁翻牌CD消息
			-- regMsg(self, ghd_treasure_shop_flip_card_cdchange_msg, handler(self, self.refreshFlipCardDatas))
		elseif self.tBuildInfo.nCellIndex == e_build_cell.bjt then --拜将台
			-- 注册拜将台免费招募消息
			regMsg(self, gud_refresh_buy_hero, handler(self, self.refreshBuyHeroDatas))
		elseif self.tBuildInfo.nCellIndex == e_build_cell.ylp then --洗练铺
			-- 注册洗炼铺免费次数消息
			regMsg(self, ghd_equip_refine_times_change, handler(self, self.refreshRefineTimeDatas))
		elseif self.tBuildInfo.nCellIndex == e_build_cell.gate then --城门
			-- 注册城门CD刷新消息
			regMsg(self, ghd_gate_cdchange_msg, handler(self, self.refreshGateDatas))
		elseif self.tBuildInfo.nCellIndex == e_build_cell.infantry 
			or self.tBuildInfo.nCellIndex == e_build_cell.sowar
			or self.tBuildInfo.nCellIndex == e_build_cell.archer
			or self.tBuildInfo.nCellIndex == e_build_cell.mbf then --步兵营，骑兵营，弓兵营，募兵府
			-- 注册兵营士兵招募队列刷新消息
			regMsg(self, ghd_refresh_camp_recruit_msg, handler(self, self.refreshRecuitDatas))
		elseif self.tBuildInfo.nCellIndex == e_build_cell.tcf then --统帅府
			-- 注册统帅府数据刷新
			regMsg(self, ghd_refresh_chiefhouse_msg, handler(self, self.refreshTSFDatas))
		elseif self.tBuildInfo.nCellIndex == e_build_cell.arena then --竞技场
			-- 竞技场数据刷新
			regMsg(self, ghd_refresh_arena_view_msg, handler(self, self.refreshArenaData))
		elseif self.tBuildInfo.nCellIndex == e_build_cell.store then --仓库
			--刷新资源兑换
			regMsg(self, gud_refresh_merchants, handler(self, self.refreshResChangeData))
        elseif self.tBuildInfo.nCellIndex == e_build_cell.warhall then --战争大厅
			--刷新战争大厅
			regMsg(self, gud_war_hall_refresh, handler(self, self.refreshWarHallChangeData))            
		end

		if self.tBuildInfo.nCellIndex < n_start_suburb_cell then --城内建筑
			-- 注册解锁状态
			regMsg(self, ghd_build_group_unlock_msg, handler(self, self.refreshUnLock))
		else 													 --资源田
			-- 注册资源田征收状态变化的消息
			regMsg(self, ghd_refresh_suburb_state_mulit_msg, handler(self, self.refreshSubColState))
			-- 注册任务刷新解锁可以征收
			regMsg(self, ghd_unlock_one_collect_all, handler(self, self.updateBubbleState))
			-- 注册刷新主城郊外资源建筑有图纸掉落的消息
			regMsg(self, gud_refresh_suburb_draws, handler(self, self.updateBubbleState))
		end
		-- 注册可以触发引导免费加速点击后的消息
		regMsg(self, gud_finish_speed_btn_click, handler(self, self.finishSpeedLvup))
		--注册活动加速后刷新冒泡消息
		regMsg(self, gud_refresh_build_bubble, handler(self, self.updateBubbleState))
		--注册去掉活动加速冒泡的消息
		-- regMsg(self, ghd_update_speed_bubble, handler(self, self.removeSpeedBubble))

		--注册主城拖动的消息
		regMsg(self, ghd_base_moving, handler(self, self.hideBubbleWhenMoving))

		--注册气泡点击响应消息
		regMsg(self, ghd_build_bubble_clicktx_msg, handler(self, self.showBubbleClickTx))
		
	end
	-- 注册玩家信息变化消息
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateViews))
	-- 注册建筑升级完成展示特效的消息
	regMsg(self, ghd_show_buildup_tx_msg, handler(self, self.showUpCompletedTx))
	-- 注册建筑状态变化的消息
	regMsg(self, gud_build_state_change_msg, handler(self, self.changeBuildState))
end


-- 注销消息
function BuildGroup:unregMsgs(  )
	-- body
	if self.tBuildInfo then
		--建筑特有的消息刷新
		if self.tBuildInfo.nCellIndex == e_build_cell.tjp then --铁匠铺
			-- 销毁打造装备刷新的消息
			unregMsg(self, gud_equip_makevo_refresh_msg)
			-- 销毁打造装备发生变化的消息
			unregMsg(self, gud_equip_makevo_change_msg)
			-- 销毁雇用铁匠信息的消息
			unregMsg(self, gud_equip_smith_hire_msg)
		elseif self.tBuildInfo.nCellIndex == e_build_cell.palace then --王宫
			--注销雇用文官事件
			unregMsg(self, ghd_refresh_palacecivil)	
		elseif self.tBuildInfo.nCellIndex == e_build_cell.tnoly then --科技园
			-- 销毁科技数据变化消息
			unregMsg(self, gud_refresh_tnoly_lists_msg)
			-- 销毁雇佣研究员新消息
			unregMsg(self, ghd_refresh_researcher_msg)
		elseif self.tBuildInfo.nCellIndex == e_build_cell.atelier then --工坊
			-- 销毁工坊队列刷新消息
			unregMsg(self, ghd_refresh_atelier_msg)
		elseif self.tBuildInfo.nCellIndex == e_build_cell.jbp then --珍宝阁
			-- 销毁珍宝阁翻牌CD消息
			-- unregMsg(self, ghd_treasure_shop_flip_card_cdchange_msg)
		elseif self.tBuildInfo.nCellIndex == e_build_cell.bjt then --拜将台
			-- 销毁拜将台免费招募消息
			unregMsg(self, gud_refresh_buy_hero)
		elseif self.tBuildInfo.nCellIndex == e_build_cell.ylp then --洗练铺
			-- 销毁洗炼铺免费次数消息
			unregMsg(self, ghd_equip_refine_times_change)
		elseif self.tBuildInfo.nCellIndex == e_build_cell.gate then --城门
			-- 注册城门CD刷新消息
			unregMsg(self, ghd_gate_cdchange_msg)
		elseif self.tBuildInfo.nCellIndex == e_build_cell.infantry 
			or self.tBuildInfo.nCellIndex == e_build_cell.sowar
			or self.tBuildInfo.nCellIndex == e_build_cell.archer then --步兵营，骑兵营，弓兵营
			-- 销毁兵营士兵招募队列刷新消息
			unregMsg(self, ghd_refresh_camp_recruit_msg)
		elseif self.tBuildInfo.nCellIndex == e_build_cell.tcf then --统帅府
			-- 销毁统帅府数据刷新
			unregMsg(self, ghd_refresh_chiefhouse_msg)
		elseif self.tBuildInfo.nCellIndex == e_build_cell.arena then --竞技场
			unregMsg(self, ghd_refresh_arena_view_msg)
		elseif self.tBuildInfo.nCellIndex == e_build_cell.store then --仓库
			-- 销毁仓库数据刷新
			unregMsg(self, gud_refresh_merchants)
        elseif self.tBuildInfo.nCellIndex == e_build_cell.warhall then --战争大厅
			--刷新战争大厅
			unregMsg(self, gud_war_hall_refresh)
		end

		if self.tBuildInfo.nCellIndex < n_start_suburb_cell then --城内建筑
			-- 销毁解锁状态
			unregMsg(self, ghd_build_group_unlock_msg)
		else 													 --资源田
			-- 销毁资源田征收状态变化的消息
			unregMsg(self, ghd_refresh_suburb_state_mulit_msg)
			-- 销毁任务刷新解锁可以征收
			unregMsg(self, ghd_unlock_one_collect_all)
			-- 销毁刷新主城郊外资源建筑有图纸掉落的消息
			unregMsg(self, gud_refresh_suburb_draws)
		end 
		--销毁触发引导免费加速点击后的消息
		unregMsg(self, gud_finish_speed_btn_click)
		--销毁活动加速后刷新冒泡消息
		unregMsg(self, gud_refresh_build_bubble)
		--销毁去掉活动加速冒泡的消息
		-- unregMsg(self, ghd_update_speed_bubble)
		unregMsg(self, ghd_base_moving)

		unregMsg(self, ghd_build_bubble_clicktx_msg)

	end
	-- 销毁玩家信息变化消息
	unregMsg(self, gud_refresh_playerinfo)
	-- 销毁建筑升级完成展示特效的消息
	unregMsg(self, ghd_show_buildup_tx_msg)
	-- 销毁建筑状态变化的消息
	unregMsg(self, gud_build_state_change_msg)
end


--暂停方法
function BuildGroup:onPause( )
	-- body
	self:unregMsgs()
end

--继续方法
function BuildGroup:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--移动屏幕时隐藏冒泡, 显示建筑等级
--bHideBubble: true为隐藏, false为显示
function BuildGroup:hideBubbleWhenMoving(sMsgName, pMsgObj)
	-- body
	if pMsgObj then
--		if pMsgObj.bHideBubble then
--			--强制把冒泡去掉
--			self:hideBubble()
--			--展示等级名字
--			self.pLayTopMsg:setVisible(true)
--		elseif pMsgObj.bHideBubble == false then
--			--刷新一下界面
--			self:updateViews()
--		end
        --优化主界面拖动卡顿问题,观察一段时间可替换上面代码
        self:setBubbleVisible(not pMsgObj.bHideBubble)
	end
end


--刷新当前数据
function BuildGroup:refreshCurDatas(  )
	-- body
	if self.nCellIndex then
		if self.nCellIndex > n_start_suburb_cell then
			self.tBuildInfo = Player:getBuildData():getSuburbByCell(self.nCellIndex)
		else
			self.tBuildInfo = Player:getBuildData():getBuildByCell(self.nCellIndex)
		end
	end
	-- --强制把冒泡去掉
	-- self:hideBubble()
	--刷新一下界面
	self:updateViews()
end

--显示或隐藏上锁状态
function BuildGroup:updateLock( )
	local bIsShow = false
	if self.tBuildInfo and self.tBuildInfo:getIsLocked() then
		bIsShow = true
	end
	if bIsShow then
		--上锁图片
		if not self.pImgLock then
			self.pImgLock = MUI.MImage.new("#v1_img_jzwjs_zjm.png")
			self:addView(self.pImgLock, 221)
			--位置
			if self.tShowData then
				local nPosX = self.tShowData.w * self.tShowData.fLockRw
				local nPosY = self.tShowData.h * self.tShowData.fLockRh
				self.pImgLock:setPosition(nPosX, nPosY)
			end
		else
			self.pImgLock:setVisible(true)
		end
		--移除特效
		self:removeBuildNormalTx()
	else
		if self.pImgLock then
			self.pImgLock:setVisible(false)
		end
		--展示建筑常态存在的特效
		self:showBuildNormnalTx()
	end
	return bIsShow
end

--获得当前建筑数据
function BuildGroup:getCurData(  )
	-- body
	return self.tBuildInfo
end


--判断是否点击选中
function BuildGroup:hasClicked( pointX, pointY )
	--是否点击操作
	if(bIsActingClicked or not self.tShowData) then
		return false
	end

	--获取底座X坐标
	local fX = self:getPosX() + self:getWidth()*self.tShowData.fDzRw
	--获取建筑图片Y轴的中心点坐标
	local fY = self:getPosY() + self:getHeight()/2
	--计算判断区域的宽和高
	local fFinalWidth = nil 
	local bIsRight = false --整个建筑是否偏右边
	if self.tShowData.fDzRw > 0.5 then
		bIsRight = true 
		fFinalWidth = self:getWidth()*(1 - self.tShowData.fDzRw)*2 
	else
		fFinalWidth = self:getWidth()*self.tShowData.fDzRw*2 
	end
	local fFinalHeight = self:getHeight() 

	local isTrue = false --是否选中
	if bIsRight then
		-- 定义一个矩形，首先判断是否在矩形内，提高验证效率
		local oX = self:getPosX() + self:getWidth() * (2 * self.tShowData.fDzRw - 1)
		local cRect = cc.rect(oX, self:getPosY(),
			fFinalWidth, fFinalHeight)
		isTrue = cc.rectContainsPoint(cRect, cc.p(pointX, pointY))
	else
		-- 定义一个矩形，首先判断是否在矩形内，提高验证效率
		local cRect = cc.rect(self:getPosX(), self:getPosY(),
			fFinalWidth, fFinalHeight)
		isTrue = cc.rectContainsPoint(cRect, cc.p(pointX, pointY))
	end
	
	if(isTrue == false) then
		return false
	end
	--判断
	isTrue = pointInHexagon(pointX, pointY, 
			fX, 
			fY, 
			fFinalWidth, 
			fFinalHeight, 
			self.tShowData.fLrm, 
			self.tShowData.fRrm, 
			self.tShowData.fTrm, 
			self.tShowData.fBrm,
			20)
	if(isTrue) then
		--点击音效
		Sounds.playEffect(Sounds.Effect.click)
		local pS1 = cc.TintTo:create(0.15, 70, 70, 70)
		local pS2 = cc.TintTo:create(0.15, 255, 255, 255)
		local pS3 = cc.Sequence:create(pS1, pS2)
		local pS4 = cc.Sequence:create(pS3, 
			cc.CallFunc:create(function (  )
				hideUnableTouchDlg()
				self:onBuildClicked()
				bIsActingClicked = false
			end))
		bIsActingClicked = true
		showUnableTouchDlg()
		self:runAction(pS4)
end
	return isTrue
end

--获得x坐标
function BuildGroup:getPosX(  )
	-- body
	if self.tShowData then
		return self.tShowData.x
	else
		return 500
	end
end

--获得y坐标
function BuildGroup:getPosY(  )
	-- body
	if self.tShowData then
		return self.tShowData.y
	else
		return 500
	end
end

--获取当胶数据
function BuildGroup:getBuildInfo( )
	if self.nCellIndex then
		if self.nCellIndex > n_start_suburb_cell then
			return Player:getBuildData():getSuburbByCell(self.nCellIndex)
		else
			return Player:getBuildData():getBuildByCell(self.nCellIndex)
		end
	end
	return nil
end

--刷新当前状态
function BuildGroup:updateCurState(  )
	-- body
	if not self.pLayMoreMsg then
		self.pLayMoreMsg = BuildMoreMsgLayer.new()
		self:addView(self.pLayMoreMsg, 100)
		--设置位置
		local nPosX = self.tShowData.w * self.tShowData.fBtRw - self.pLayMoreMsg:getWidth() / 2
		local nPosY = self.tShowData.h * self.tShowData.fDzRh -self.pLayMoreMsg:getHeight() / 2
		-- if self.tBuildInfo.sTid == e_build_ids.infantry
		-- 	or self.tBuildInfo.sTid == e_build_ids.sowar
		--  	or self.tBuildInfo.sTid == e_build_ids.archer then
		--  	nPosY = nPosY + 50
		-- end
		self.nLayMorePosX = nPosX
		if  self.tBuildInfo.sTid == e_build_ids.palace then --王宫
			nPosX = nPosX + 28
			nPosY = nPosY - 60
		elseif  self.tBuildInfo.sTid == e_build_ids.store then --仓库
			nPosY = nPosY - 40
		elseif  self.tBuildInfo.sTid == e_build_ids.tnoly then --科学院
			nPosY = nPosY - 50
			self.nLayMorePosY = nPosY
			--科技升级用的进度条层
			if not self.pLayTonlyUpingMoreMsg then
				self.pLayTonlyUpingMoreMsg = BuildMoreMsgLayer.new()
				self:addView(self.pLayTonlyUpingMoreMsg, 100)
				self.pLayTonlyUpingMoreMsg:setPosition(nPosX, nPosY)
			end
		elseif  self.tBuildInfo.sTid == e_build_ids.infantry then --步兵营
			nPosX = nPosX - 10
			nPosY = nPosY - 45
		elseif  self.tBuildInfo.sTid == e_build_ids.sowar then --骑兵营
			nPosX = nPosX - 20
			nPosY = nPosY - 45
		elseif  self.tBuildInfo.sTid == e_build_ids.archer then --弓兵营
			nPosX = nPosX - 10
			nPosY = nPosY - 45
		elseif  self.tBuildInfo.sTid == e_build_ids.atelier then --作坊
			nPosY = nPosY - 40
		elseif  self.tBuildInfo.sTid == e_build_ids.tjp then --铁匠铺
			nPosX = nPosX + 15
			nPosY = nPosY - 50
		elseif  self.tBuildInfo.sTid == e_build_ids.ylp then --冶炼铺
			nPosX = nPosX + 15
			nPosY = nPosY - 40
		elseif  self.tBuildInfo.sTid == e_build_ids.jxg then --将军府
			nPosX = nPosX + 5
			nPosY = nPosY - 40
		elseif  self.tBuildInfo.sTid == e_build_ids.jbp then --珍宝阁
			nPosY = nPosY - 40
		elseif  self.tBuildInfo.sTid == e_build_ids.bjt then --拜将台
			nPosY = nPosY - 35
		elseif  self.tBuildInfo.sTid == e_build_ids.house then --民居
			nPosY = nPosY - 45
		elseif  self.tBuildInfo.sTid == e_build_ids.wood then --木场
			nPosX = nPosX + 15
			nPosY = nPosY - 40
		elseif  self.tBuildInfo.sTid == e_build_ids.farm then --农田
			nPosY = nPosY - 40
		elseif  self.tBuildInfo.sTid == e_build_ids.iron then --铁矿
			nPosX = nPosX + 10
			nPosY = nPosY - 40
		elseif self.tBuildInfo.sTid == e_build_ids.gate then --如果是城门，需要再低一点
			nPosY = nPosY - 145
		elseif  self.tBuildInfo.sTid == e_build_ids.tcf then --统帅府
			nPosX = nPosX + 5
			nPosY = nPosY - 40	
		elseif  self.tBuildInfo.sTid == e_build_ids.arena then --竞技场
			nPosY = nPosY - 35		
		elseif  self.tBuildInfo.sTid == e_build_ids.warhall then --战争大厅
			nPosY = nPosY - 35					
		elseif  self.tBuildInfo.sTid == e_build_ids.mbf then --募兵府
			nPosX = nPosX - 10
			nPosY = nPosY - 45					
		end

		self.pLayMoreMsg:setPosition(nPosX, nPosY)
	end
	self.pLayMoreMsg:setCurData(self.tBuildInfo)
	if self.tBuildInfo.sTid == e_build_ids.tnoly then
		if self.tBuildInfo.nState == e_build_state.uping then
			self.pLayTonlyUpingMoreMsg:setPosition(self.nLayMorePosX, self.nLayMorePosY + 40)
		elseif self.tBuildInfo.nState == e_build_state.free then
			self.pLayTonlyUpingMoreMsg:setPosition(self.nLayMorePosX, self.nLayMorePosY)
		end
		if self.pLayTonlyUpingMoreMsg then
			self.pLayTonlyUpingMoreMsg:setCurData(self.tBuildInfo, e_build_ids.tnoly)
		end
	end

	--未激活状态下建筑置灰
	showGrayTx(self.pImgBuild, not self.tBuildInfo.bActivated)

	--冒泡情况
	self:updateBubbleState()

	--睡眠情况
	self:updateSleepingState()

end

--刷新资源田是否可征收
function BuildGroup:updateSubColState(  )
	-- body
	if self.tBuildInfo.nCellIndex > n_start_suburb_cell then  --是资源田
		--判断是否有一键征收快捷入口
		local bShow = isShowItemHomeCollectFast(2,e_index_itemrl.l_yjzs)
		if Player:getBuildData():getColState() == 1 then
			--这里是个处理减少消息发送
			if not bShow then --需要展示
				--发送消息刷新对联
				local tObj = {}
				tObj.nType = 2
				sendMsg(ghd_refresh_homeitem_msg, tObj)
			end
		else
			--发送消息刷新对联
			local tObj = {}
			tObj.nType = 2
			sendMsg(ghd_refresh_homeitem_msg, tObj)
		end
	end
end

--设置冒泡情况
function BuildGroup:updateBubbleState(  )
	--新手引导加速
	Player:getNewGuideMgr():registeredBuildQuickUi(self.pBubbleLayer, self.tBuildInfo, false)
	--新手引导征收
	Player:getNewGuideMgr():registeredBuildCollectUi(self.pBubbleLayer, self.tBuildInfo, false)
	-- body
	local bShow = false
	local bIsLock = self.tBuildInfo:getIsLocked() --是否上锁
	if self.tBuildInfo.sTid == e_build_ids.palace then --王宫
		--1.判断是否可以升级免费加速
		bShow = self:isFreeForBuilding()
		if bShow and not bIsLock then
			self:showBubble(1,e_type_bubble.sjmf)
			--新手引导加速
			Player:getNewGuideMgr():registeredBuildQuickUi(self.pBubbleLayer, self.tBuildInfo, true)
			return
		end
		--2.是否有活动加速(建筑升级加速)
		bShow = self:isHasActSpeedBuff(e_item_ids.jzjs, e_speed_effect_type.build_speed)
		if bShow then
			self:showBubble(1,e_type_bubble.buildspeed)
			return
		end

		--是否求助
		if self:isCanAskHelp() then
			self:showBubble(1,e_type_bubble.gjqz)
			return
		end

		--3.判断是否可以招募文官
		bShow = self:isCanEmployOffical()
		if bShow and not bIsLock then
			self:showBubble(1,e_type_bubble.zmwg)
			return
		end
	elseif self.tBuildInfo.sTid == e_build_ids.tnoly then --科技园		
		--1.判断是否可以升级免费加速
		bShow = self:isFreeForBuilding()
		if bShow and not bIsLock then
			self:showBubble(1,e_type_bubble.sjmf)
			return
		end
		--2.判断是否可以免费学者加速
		bShow = self:isTnolyCanSpeedFree()
		if bShow and not bIsLock then
			self:showBubble(1, e_type_bubble.kjyspeedfree)
			return
		end
		--3.是否有活动加速(建筑升级加速)
		bShow = self:isHasActSpeedBuff(e_item_ids.jzjs, e_speed_effect_type.build_speed)
		if bShow then
			self:showBubble(1,e_type_bubble.buildspeed)
			return
		end
		--4.是否有活动加速(科研加速)
		bShow = self:isHasActSpeedBuff(e_item_ids.kyjs, e_speed_effect_type.tnoly_speed)
		if bShow then
			self:showBubble(1,e_type_bubble.tnolyspeed)
			return
		end
		--5.是否求助
		if self:isCanAskHelp() then
			self:showBubble(1,e_type_bubble.gjqz)
			return
		end
		--6.判断是否有已经研究完的科技
		bShow, sTip = self:isTnolyOK()
		if bShow and not bIsLock then
			self:showBubble(2,e_type_bubble.kjtb)
			--新手引导领取科技
			Player:getNewGuideMgr():setNewGuideFinger(self.pBubbleLayer, e_guide_finer.tnoly_build_bubble)

			if not self.bTnolyHasTiped then
				self.bTnolyHasTiped = true
				--总览文字冒泡提示
				local tObject = {}
				tObject.sTip = sTip
				sendMsg(ghd_show_overview_tip,tObject)
			end
			return
		else
			self.bTnolyHasTiped = false
			Player:getNewGuideMgr():setNewGuideFinger(nil, e_guide_finer.tnoly_build_bubble)
		end
		--6.科技园空闲
		--屏蔽空闲状态
		-- bShow = self:isTnolySpare()
		-- if bShow and not bIsLock then
		-- 	self:showBubble(1, e_type_bubble.jzkx)--显示空闲气泡
		-- 	return
		-- end	
	elseif self.tBuildInfo.sTid == e_build_ids.atelier then --工坊
		--1.判断是否可以升级免费加速
		bShow = self:isFreeForBuilding()
		if bShow and not bIsLock then
			self:showBubble(1,e_type_bubble.sjmf)
			return
		end
		--2.是否有活动加速(建筑升级加速)
		bShow = self:isHasActSpeedBuff(e_item_ids.jzjs, e_speed_effect_type.build_speed)
		if bShow then
			self:showBubble(1,e_type_bubble.buildspeed)
			return
		end
		--3.是否求助
		if self:isCanAskHelp() then
			self:showBubble(1,e_type_bubble.gjqz)
			return
		end
		--4.判断是否有完成的材料
		bShow = self:isAtelierOK()
		if bShow and not bIsLock then
			self:showBubble(2,e_type_bubble.ateliertb)
			if not self.bAtelierHasTiped then
				self.bAtelierHasTiped = true
				local tGoods = self.tBuildInfo:getFirstFinshQueueItem()
				--总览文字冒泡提示
				local tObject = {}
				local sTip = string.format(getConvertedStr(7, 10185), getGoodsByTidFromDB(tGoods.tGs.k).sName)
				tObject.sTip = sTip
				sendMsg(ghd_show_overview_tip,tObject)
			end
			return
		else
			self.bAtelierHasTiped = false
		end
	    --5.工坊空闲
	    --屏蔽空闲状态
		-- bShow = self:isAteilerHadFreeQuence()
		-- if bShow and not bIsLock then
		-- 	self:showBubble(1, e_type_bubble.jzkx)--显示空闲气泡
		-- 	return
		-- end	
	elseif self.tBuildInfo.sTid == e_build_ids.infantry
		or self.tBuildInfo.sTid == e_build_ids.sowar
		or self.tBuildInfo.sTid == e_build_ids.archer then --兵营
		--1.判断是否可以升级免费加速
		bShow = self:isFreeForBuilding()
		if bShow and not bIsLock then
			self:showBubble(1,e_type_bubble.sjmf)
			Player:getNewGuideMgr():registeredBuildQuickUi(self.pBubbleLayer, self.tBuildInfo, true)
			return
		end
		--2.是否有活动加速(建筑升级加速)
		bShow = self:isHasActSpeedBuff(e_item_ids.jzjs, e_speed_effect_type.build_speed)
		if bShow then
			self:showBubble(1,e_type_bubble.buildspeed)
			return
		end
		--3.是否有活动加速(募兵加速)
		bShow = self:isHasActSpeedBuff(e_item_ids.mbjs, e_speed_effect_type.camp_speed)
		if bShow then
			self:showBubble(1,e_type_bubble.campspeed)
			return
		end
		--4.是否求助
		if self:isCanAskHelp() then
			self:showBubble(1,e_type_bubble.gjqz)
			return
		end
		--5.判断是否招募完成
		bShow = self:isCampRecruitOK()
		if bShow and not bIsLock then
			local nT = e_type_bubble.bbmb
			local sTip
			if self.tBuildInfo.sTid == e_build_ids.infantry then --步兵
				nT = e_type_bubble.bbmb
				sTip = getConvertedStr(7, 10181)
				if not self.bInfantryHasTiped then
					self.bInfantryHasTiped = true
					--总览文字冒泡提示
					local tObject = {}
					tObject.sTip = sTip
					sendMsg(ghd_show_overview_tip,tObject)
				end
			elseif self.tBuildInfo.sTid == e_build_ids.sowar then --骑兵
				nT = e_type_bubble.qbmb
				sTip = getConvertedStr(7, 10182)
				if not self.bSowarHasTiped then
					self.bSowarHasTiped = true
					--总览文字冒泡提示
					local tObject = {}
					tObject.sTip = sTip
					sendMsg(ghd_show_overview_tip,tObject)
				end
			elseif self.tBuildInfo.sTid == e_build_ids.archer then --弓兵
				nT = e_type_bubble.gbmb
				sTip = getConvertedStr(7, 10183)
				if not self.bArcherHasTiped then
					self.bArcherHasTiped = true
					--总览文字冒泡提示
					local tObject = {}
					tObject.sTip = sTip
					sendMsg(ghd_show_overview_tip,tObject)
				end
			end
			self:showBubble(2,nT)
			return
		else
			--屏蔽招募气泡
			-- bShow=self:isCanRecruit()
			-- if bShow then
				-- self:showBubble(1,e_type_bubble.recruit)
				-- return
			-- else
				if self.tBuildInfo.sTid == e_build_ids.infantry then --步兵
					self.bInfantryHasTiped = false
				elseif self.tBuildInfo.sTid == e_build_ids.sowar then --步兵
					self.bSowarHasTiped = false
				elseif self.tBuildInfo.sTid == e_build_ids.archer then --步兵
					self.bArcherHasTiped = false
				end
			-- end
		end
	elseif self.tBuildInfo.sTid == e_build_ids.mbf then
		--1.是否可建造(已解锁但是未建造任何类型的兵府)
		if not bIsLock and self.tBuildInfo.nRecruitTp == nil then
			self:showBubble(2, e_type_bubble.mbfjz)
			return
		end
		--2.判断是否可以升级免费加速
		bShow = self:isFreeForBuilding()
		if bShow and not bIsLock then
			self:showBubble(1,e_type_bubble.sjmf)
			Player:getNewGuideMgr():registeredBuildQuickUi(self.pBubbleLayer, self.tBuildInfo, true)
			return
		end
		--3.是否有活动加速(建筑升级加速)
		bShow = self:isHasActSpeedBuff(e_item_ids.jzjs, e_speed_effect_type.build_speed)
		if bShow then
			self:showBubble(1,e_type_bubble.buildspeed)
			return
		end

		--4.是否求助
		if self:isCanAskHelp() then
			self:showBubble(1,e_type_bubble.gjqz)
			return
		end

		--5.是否有活动加速(募兵加速)
		bShow = self:isHasActSpeedBuff(e_item_ids.mbjs, e_speed_effect_type.camp_speed)
		if bShow then
			self:showBubble(1,e_type_bubble.campspeed)
			return
		end
		--6.判断是否招募完成
		bShow = self:isCampHouseRecruitOK()
		if bShow and not bIsLock then
			local nT = e_type_bubble.bbmb
			if self.tBuildInfo.nRecruitTp == e_mbf_camp_type.infantry then --步兵
				nT = e_type_bubble.bbmb
			elseif self.tBuildInfo.nRecruitTp == e_mbf_camp_type.sowar then --骑兵
				nT = e_type_bubble.qbmb
			elseif self.tBuildInfo.nRecruitTp == e_mbf_camp_type.archer then --弓兵
				nT = e_type_bubble.gbmb
			end
			self:showBubble(2, nT)
			return
		end
	elseif self.tBuildInfo.sTid == e_build_ids.house
		or self.tBuildInfo.sTid == e_build_ids.farm
		or self.tBuildInfo.sTid == e_build_ids.iron
		or self.tBuildInfo.sTid == e_build_ids.wood then --郊外资源
		--根据建筑是否激活显示状态
		showGrayTx(self.pImgBuild, not self.tBuildInfo.bActivated)		
		if self.tBuildInfo.bActivated == true then
			--1.判断是否可以升级或改建免费加速
			bShow = self:isFreeForBuilding()
			if bShow then
				self:showBubble(1,e_type_bubble.sjmf)
				--新手引导加速
				Player:getNewGuideMgr():registeredBuildQuickUi(self.pBubbleLayer, self.tBuildInfo, true)
				return
			end
			--2.是否有活动加速(建筑升级加速)
			bShow = self:isHasActSpeedBuff(e_item_ids.jzjs, e_speed_effect_type.build_speed)
			if bShow then
				self:showBubble(1,e_type_bubble.buildspeed)
				return
			end
			--3.是否求助
			if self:isCanAskHelp() then
				self:showBubble(1,e_type_bubble.gjqz)
				return
			end
			--4.判断是否可征收
			local nMan = nil --可征收的类型 1：可征收 2：满征收
			bShow, nMan = self:isCanColledted()
			if bShow then
				local nT = e_type_bubble.mjzs
				if self.tBuildInfo.sTid == e_build_ids.house then
					nT = e_type_bubble.mjzs
				elseif self.tBuildInfo.sTid == e_build_ids.farm then
					nT = e_type_bubble.ntzs
				elseif self.tBuildInfo.sTid == e_build_ids.wood then
					nT = e_type_bubble.mczs
				elseif self.tBuildInfo.sTid == e_build_ids.iron then
					nT = e_type_bubble.tkzs
				end
				if nMan == 1 then
					self:showBubble(3,nT)
				elseif nMan == 2 then
					self:showBubble(2,nT)
				end
				--新手引导征收
				Player:getNewGuideMgr():registeredBuildCollectUi(self.pBubbleLayer, self.tBuildInfo, true)
				return
			end
		else						
			local nT = 0
			if self.tBuildInfo.sTid == e_build_ids.house then
				nT = e_type_bubble.mjjzcj
			elseif self.tBuildInfo.sTid == e_build_ids.farm then
				nT = e_type_bubble.ntjzcj
			elseif self.tBuildInfo.sTid == e_build_ids.wood then
				nT = e_type_bubble.mcjzcj
			elseif self.tBuildInfo.sTid == e_build_ids.iron then
				nT = e_type_bubble.tkjzcj
			end
			--资源田是否可激活
			bShow = self:isCanActivated()
			if bShow then
				self:showBubble(2, nT)
			else
				self:showBubble(3, nT)
			end
			return	
		end
	elseif self.tBuildInfo.sTid == e_build_ids.tjp then --铁匠铺
		--1.是否有已完成装备
		bShow = self:isTjpHadIcon()
		if bShow and not bIsLock then
			self:showBubble(2, e_type_bubble.tjptb)
			--新手引导领取装备
			Player:getNewGuideMgr():setNewGuideFinger(self.pBubbleLayer, e_guide_finer.smithshop_bubble)
			if not self.bTjpHasTiped then
				self.bTjpHasTiped = true
				--总览文字冒泡提示
				local tMakeVo = Player:getEquipData():getMakeVo()
				local sTip = string.format(getConvertedStr(7, 10184), getGoodsByTidFromDB(tMakeVo.nId).sName)
				local tObject = {}
				tObject.sTip = sTip
				sendMsg(ghd_show_overview_tip,tObject)
			end
			return
		else
			self.bTjpHasTiped = false
			Player:getNewGuideMgr():setNewGuideFinger(nil, e_guide_finer.smithshop_bubble)
		end
		--2.是否有免费加速(加速打造装备)
		bShow = self:isTjpHasSpeedFree()
		if bShow and not bIsLock then
			--新手引导加速打造冒泡
			self:showBubble(1, e_type_bubble.tjpspeedfree)
			-- Player:getNewGuideMgr():setNewGuideFinger(self.pBubbleLayer, e_guide_finer.tjp_equip_speed)
			return
		-- else
		-- 	Player:getNewGuideMgr():setNewGuideFinger(nil, e_guide_finer.tjp_equip_speed)
		end
		--3.是否属于空闲状态
		--屏蔽空闲状态	
		-- bShow = Player:getEquipData():getCurrMakingId() == nil
		-- if bShow and not bIsLock then
		-- 	self:showBubble(1, e_type_bubble.jzkx)--显示空闲气泡
		-- 	return
		-- end	
		--4.是否可以免费洗炼
		--洗炼功能是否开启
		local bOpen = getIsReachOpenCon(21, false)
		if bOpen then
			--武将身上是否有绿色以上装备
			local bHasGoodQualityEquip = self:isHeroHasGoodQualityEquip()
			--洗炼铺的免费洗炼次数是否已满
			local bFullTimes = Player:getEquipData():getIsFreenTrainFull()
			if bFullTimes and bHasGoodQualityEquip then
				self:showBubble(1, e_type_bubble.xlpmfxl)
				return
			end
		end	
	elseif self.tBuildInfo.sTid == e_build_ids.jbp then --珍宝阁
		--是否有免费翻牌
		bShow = self:isFlipForFree()
		if bShow and not bIsLock then --有翻盘
			if self.tNTx and self.tNTx[1] then
				self.tNTx[1]:getAnimation():play("Animation1", 1)
			end
			self:showBubble(1, e_type_bubble.zbgfp)
			return
		else
			--未上锁
			if not bIsLock then
				if self.tNTx and self.tNTx[1] then
					self.tNTx[1]:getAnimation():play("Animation1_Copy1", 1)
				end
			end
		end
	elseif self.tBuildInfo.sTid == e_build_ids.bjt then --拜将台
		--拜将台是否有免费招募
		local bFreeTimes = Player:getHeroInfo():getBuyHeroFree()
		--招募开启条件迁到open表
		if bFreeTimes and getIsReachOpenCon(18, false) then
			self:showBubble(1, e_type_bubble.bjtzm)
			return
		end
	elseif self.tBuildInfo.sTid == e_build_ids.ylp then --洗炼铺
		--洗炼功能是否开启
		-- local bOpen = getIsReachOpenCon(21, false)
		-- if bOpen then
		-- 	--武将身上是否有绿色以上装备
		-- 	local bHasGoodQualityEquip = self:isHeroHasGoodQualityEquip()
		-- 	--洗炼铺的免费洗炼次数是否已满
		-- 	local bFullTimes = Player:getEquipData():getIsFreenTrainFull()
		-- 	if bFullTimes and bHasGoodQualityEquip then
		-- 		self:showBubble(1, e_type_bubble.xlpmfxl)
		-- 		return
		-- 	end
		-- end
	elseif self.tBuildInfo.sTid == e_build_ids.gate then --城门
		bShow = self:isFreeForBuilding()
		if bShow and not bIsLock then
			self:showBubble(1,e_type_bubble.sjmf)
			return
		end
		--2.是否有活动加速(建筑升级加速)
		bShow = self:isHasActSpeedBuff(e_item_ids.jzjs, e_speed_effect_type.build_speed)
		if bShow then
			self:showBubble(1,e_type_bubble.buildspeed)
			return
		end
		--3.是否求助
		if self:isCanAskHelp() then
			self:showBubble(1,e_type_bubble.gjqz)
			return
		end

		--城墙CD允许增加城防军
		local bShow = self.tBuildInfo:showRecruitTip()
		if bShow and not bIsLock then
			self:showBubble(1, e_type_bubble.gatebc)
			return
		end
	elseif self.tBuildInfo.sTid == e_build_ids.tcf then
		--判断是否可以升级免费加速
		bShow = self:isFreeForBuilding()
		if bShow and not bIsLock then
			self:showBubble(1,e_type_bubble.sjmf)
			return
		end
		--2.是否有活动加速(建筑升级加速)
		bShow = self:isHasActSpeedBuff(e_item_ids.jzjs, e_speed_effect_type.build_speed)
		if bShow then
			self:showBubble(1,e_type_bubble.buildspeed)
			return
		end
		--是否求助
		if self:isCanAskHelp() then
			self:showBubble(1,e_type_bubble.gjqz)
			return
		end

		--3.是否有高级御兵术可激活
		bShow = self:isTSFCanActivate()
		if bShow then
			self:showBubble(2,e_type_bubble.tsfactivate)
			return
		end
		--4.是否御兵术升级气泡
		bShow = self:isTroopCanLvUp()
		if bShow then
			self:showBubble(3, e_type_bubble.ybssj)
			return
		end
	elseif self.tBuildInfo.sTid == e_build_ids.arena then --竞技场
		--1.是否可以挑战
		bShow = self:isCanArenaChallenge()
		if bShow and not bIsLock then
			self:showBubble(3, e_type_bubble.jjctz)
			return
		end
	elseif self.tBuildInfo.sTid == e_build_ids.store then --仓库
		--1.判断是否可以升级免费加速
		bShow = self:isFreeForBuilding()
		if bShow and not bIsLock then
			self:showBubble(1,e_type_bubble.sjmf)
			return
		end
		--2.是否有活动加速(建筑升级加速)
		bShow = self:isHasActSpeedBuff(e_item_ids.jzjs, e_speed_effect_type.build_speed)
		if bShow then
			self:showBubble(1,e_type_bubble.buildspeed)
			return
		end
		--3.是否求助
		if self:isCanAskHelp() then
			self:showBubble(1,e_type_bubble.gjqz)
			return
		end
		--4.是否有资源兑换次数
		bShow = self:isCanChangeResource()
		if bShow and not bIsLock then
			self:showBubble(1, e_type_bubble.zydh)
			return	
		end		
	elseif self.tBuildInfo.sTid == e_build_ids.warhall then
        if bIsLock then
            return
        end
        -- 战争大厅的活动列表
        local tWarHallData = Player:getWarHall()
        local warHallList = tWarHallData:newListByType(1)  
        -- 显示气泡优先级排序
        table.sort(warHallList, function(a, b) 
            if a.nPriority == b.nPriority then
                return a.nId < b.nId
            end
            return a.nPriority < b.nPriority
        end)
        -- 按优先等级取第一个气泡
        for k, v in pairs(warHallList) do
            if v:isShowBuildingBubble() == true then
                --print("v:isShowBuildingBubble()", 3, e_type_bubble.zzdt, v.nDlgIndex, v.nBubbleEffect, v.sBbbleFon)
                self:showBubble(3, e_type_bubble.zzdt, v.nDlgIndex, v.nBubbleEffect, v.sBbbleFont)                
                return	
            end
        end			
	else
		--判断是否可以升级免费加速
		bShow = self:isFreeForBuilding()
		if bShow and not bIsLock then
			self:showBubble(1,e_type_bubble.sjmf)
			Player:getNewGuideMgr():registeredBuildQuickUi(self.pBubbleLayer, self.tBuildInfo, true)
			return
		end
		--2.是否有活动加速(建筑升级加速)
		bShow = self:isHasActSpeedBuff(e_item_ids.jzjs, e_speed_effect_type.build_speed)
		if bShow then
			self:showBubble(1,e_type_bubble.buildspeed)
			return
		end
		--是否求助
		if self:isCanAskHelp() then
			self:showBubble(1,e_type_bubble.gjqz)
			return
		end
	end

	--隐藏冒泡
	self:hideBubble()
	
end

--刷新睡眠状态
function BuildGroup:updateSleepingState(  )
	-- body
	local bDoing = false
	--是否有冒泡图标
	local bShow = false
	 --是否上锁
	local bIsLock = self.tBuildInfo:getIsLocked()
	--新手引导
	Player:getNewGuideMgr():registeredBuildSelfEnter(self.pLayBUildFinger, self.tBuildInfo)


	if self.tBuildInfo.sTid == e_build_ids.infantry
		or self.tBuildInfo.sTid == e_build_ids.sowar
		or self.tBuildInfo.sTid == e_build_ids.archer then --兵营
		if self.tBuildInfo.nState ~= e_build_state.uping then
			--1.判断是否募兵已满
			local bFull = self.tBuildInfo:getIsFull(self.tBuildInfo.sTid)
			--2.空闲队列
			local tFreeTeams = self.tBuildInfo:getFreeTeams(1)
			-- bShow = self:isCampRecruitOK()
			if not bIsLock and not bFull and #tFreeTeams > 0 then
				self:showSleeping()
				return	
			end
		end
	elseif self.tBuildInfo.sTid == e_build_ids.mbf then --募兵府
		if self.tBuildInfo.nRecruitTp ~= nil then --如果已建造兵营
			if self.tBuildInfo.nState ~= e_build_state.uping and self.tBuildInfo.nState ~= e_build_state.creating then
				--1.判断是否募兵已满
				local bFull = self.tBuildInfo:getIsFull()
				--2.空闲队列
				local tFreeTeams = self.tBuildInfo:getFreeTeams(1)
				if not bIsLock and not bFull and #tFreeTeams > 0 then
					self:showSleeping()
					return	
				end
			end
		end
	elseif self.tBuildInfo.sTid == e_build_ids.atelier then --工坊
		if self.tBuildInfo.nState == e_build_state.free then
			if not bIsLock then
				self:showSleeping()
				return
			end
		end
		--是否有空闲生产队列
		local bHadFree = self:isAteilerHadFreeQuence()
		if bHadFree then
			self:showSleeping()
			return
		end
	elseif self.tBuildInfo.sTid == e_build_ids.tjp then --铁匠铺
		--是否有正在打造的装备
		local bDoing = Player:getEquipData():getMakeVo()
		-- bShow = self:isTjpHadIcon()
		local bFinish = Player:getEquipData():getIsFinishMakeEquip()
		--如果没有正在打造的装备或者有已打造完成的装备仍显示睡眠状态
		if (not bDoing or bFinish) and (not bIsLock) then
			self:showSleeping()
			return
		end
	elseif self.tBuildInfo.sTid == e_build_ids.tnoly then --科技院
		--1.判断是否有正在研究的科技
		local tUpingTnoly = Player:getTnolyData():getUpingTnoly()
		--2.判断是否有已经研究完的科技
		bShow = self:isTnolyOK()
		--3.判断是否有可升级的科技(科技列表大于0)
		local tCanUpLists = Player:getTnolyData():getCanUpTnolyLists()
		if self.tBuildInfo.nState == e_build_state.free then
			if tUpingTnoly then
				if bShow and #tCanUpLists > 0 then
					self:showSleeping()
					return
				end
			else
				if not bIsLock and #tCanUpLists > 0 then
					self:showSleeping()
					return
				end
			end
		elseif self.tBuildInfo.nState == e_build_state.uping then
			--科技院在玩家购买对应vip礼包后，雇佣紫色研究员时，可以在升级科技院的同时研究科技
			if getIsCanTnolyUpingWithTecnologying() then
				if tUpingTnoly then
					if bShow and #tCanUpLists > 0 then
						self:showSleeping()
						return
					end
				else
					if #tCanUpLists > 0 then
						self:showSleeping()
						return
					end
				end
			end
		end
	end

	--移除睡眠特效
	self:hideSleeping()
end

--工坊是否有完成的材料
function BuildGroup:isAtelierOK()
	-- body
	local tGoods = self.tBuildInfo:getFirstFinshQueueItem()
	if tGoods then
		return true
	else
		return false
	end
end

function BuildGroup:isAteilerHadFreeQuence(  )
	-- body
	--dump(self.tBuildInfo, "self.tBuildInfo", 100)	
	local nNum = self.tBuildInfo:getProQueueNum()
	local nQuence = self.tBuildInfo.nQueue or 0
	local isLving = self.tBuildInfo.nState == e_build_state.uping
	if isLving then
		return false
	else
		return nNum < nQuence 
	end
	
end
--铁匠铺是否图标
function BuildGroup:isTjpHadIcon(  )
	-- body
	if Player:getEquipData():getIsFinishMakeEquip() then
		return true
	else
		return false
	end
end

--铁匠铺是否有免费加速
function BuildGroup:isTjpHasSpeedFree()
	-- body
	if Player:getEquipData():getIsCanSpeed() then
		return true
	else
		return false
	end
end

--珍宝阁是否有免费翻牌
function BuildGroup:isFlipForFree()
	-- body
	local tShopData = Player:getShopData()
	--是否已购买
	local bBought = tShopData:getIsBoughtTreasure()
	if bBought then
		return false
	end
	--已翻牌队列
	local tList = tShopData:getFTreasureIdList()
	--是否在CD时间之内
	local nCd = tShopData:getFlipCardCd()
	if nCd == 0 and #tList < 8 then
		return true
	else
		return false
	end
end

--升级建筑是否有免费加速(包括郊外资源建筑改建免费加速)
function BuildGroup:isFreeForBuilding()
	-- body
	if (self.tBuildInfo.nState == e_build_state.uping or self.tBuildInfo.nState == e_build_state.creating)
		and self.tBuildInfo.fRssTime > 0 then
		return true
	else
		return false
	end
end

--是否有加速buff(掉落的加速buff)
--_type:加速类型
function BuildGroup:isHasActSpeedBuff(_itemid, _type)
	if not _itemid or not _type then
		return false
	end
	
	local pGood = Player:getBagInfo():getItemDataById(_itemid)
	if pGood == nil then
		return false
	end 
	if pGood.nEffectType == _type and pGood.nCt > 0 then
		if _type == e_speed_effect_type.tnoly_speed then --科研加速
			local tUpingTnoly = Player:getTnolyData():getUpingTnoly()
			if tUpingTnoly and tUpingTnoly:getUpingFinalLeftTime() > 0 then
				return true
			end
		elseif _type == e_speed_effect_type.camp_speed then   --募兵加速
			--获取兵营正在募兵中队列需要时间最短的兵营
			local pBuild = Player:getBuildData():getShortestCampBuild()
			if pBuild then
				if self.nCellIndex ~= pBuild.nCellIndex then
					return false
				else
					return true
				end
			end
		elseif _type == e_speed_effect_type.build_speed then  --建筑升级加速
			--正在升级
			if self.tBuildInfo.nState == e_build_state.uping then
				--获取正在升级中的需要时间最短的建筑
				local pBuild = Player:getBuildData():getShortestUpingBuild()
				if pBuild and pBuild.nCellIndex == self.nCellIndex then
					return true
				else
					return false
				end
			end
		end
	end
	return false
end

--是否可雇佣文官
function BuildGroup:isCanEmployOffical(  )
	-- body
	--先判断是否文官开启雇佣
	local bCan = false
	if self.tBuildInfo.nLv >= getOfficiclLimit() then
		local tLeftTime = self.tBuildInfo:getOfficalLeftCD()
		if tLeftTime <= 0 then
			bCan = true
		end
	end
	return bCan
end

--是否科技研究结果
function BuildGroup:isTnolyOK(  )
	-- body
	--正在研究的科技
	local tUpingTnoly = Player:getTnolyData():getUpingTnoly()
	if tUpingTnoly then
		if tUpingTnoly:getUpingFinalLeftTime() <= 0 then
			-- local tip = tUpingTnoly:getUpTnolyTips()
			local tip = getConvertedStr(7, 10180)
			return true, tip
		else
			return false
		end
	else
		return false
	end
end
--科技院是否空闲
function BuildGroup:isTnolySpare(  )
	-- body	
	local tUpingTnoly = Player:getTnolyData():getUpingTnoly()--没有正在升级的科技
	if (self.tBuildInfo.nState == e_build_state.uping) then--升级中
		--小朋友说写死
		if Player:getPlayerInfo():getIsBoughtVipGift(5) == true then--已经购买VIP5
			local pResearchData =  Player:getTnolyData():getResearcherBaseData()
			if pResearchData and pResearchData.nQuality > 1 then--已经雇用紫色研究员				
				return tUpingTnoly == nil
			end
		end
	else
		return tUpingTnoly == nil
	end
	return false
end
--科技院是否有免费加速(学者加速)
function BuildGroup:isTnolyCanSpeedFree()
	-- body
	local bIsCan = Player:getTnolyData():isCanFreeUp()
	return bIsCan
end

--是否有募兵完成
function BuildGroup:isCampRecruitOK(  )
	-- body
	local tRecuitOk = self.tBuildInfo:getRecruitedQue()
	if tRecuitOk then
		return true
	else
		return false
	end
end

--募兵府是否有募兵完成
function BuildGroup:isCampHouseRecruitOK(  )
	-- body
	local tRecuitOk = self.tBuildInfo:getRecruitedQue()
	if tRecuitOk then
		return true
	else
		return false
	end
end

--是否有募兵队列
function BuildGroup:isCampRecruiting(  )
	-- body
	local tQue = self.tBuildInfo:getRecruitingQue()
	if tQue then
		return true
	else
		return false
	end
end

--是否可征收
function BuildGroup:isCanColledted(  )
	--指定任务开启时不可以征收
	if Player:getPlayerTaskInfo():getLevyResTaskIsUnLock() then
		if Player:getBuildData():getColState() == 1 then --可征收
			return true, 1
		elseif Player:getBuildData():getColState() == 2 then --满征收
			return true, 2
		else
			return false
		end
	end
	return false
end

--资源田是否可激活
function BuildGroup:isCanActivated()
	--如果已拥有图纸大于等于激活需求图纸数
	local tBSuburb = getSubBDatasFromDBByCell(self.tBuildInfo.nCellIndex)
	if self.tBuildInfo.nDraws and self.tBuildInfo.nDraws >= tBSuburb.num then
		return true
	else
		return false
	end
end

--建筑是否可以求助
function BuildGroup:isCanAskHelp()
	if not getIsReachOpenCon(3, false) then
		return false
	end
	if self.tBuildInfo.nState == e_build_state.uping then
		if self.tBuildInfo.nHelp == 0 then
			return true
		end
	end
	return false
end

--武将身上是否有绿色以上装备
function BuildGroup:isHeroHasGoodQualityEquip()
	local bHasGoodQualityEquip = false
	local tHeroOnlineList = Player:getHeroInfo():getOnlineHeroList() --上阵队列
	for _, hero in pairs(tHeroOnlineList) do
		local tEquipVos = Player:getEquipData():getEquipVosByHero(hero.sTid)
		for _, vo in pairs(tEquipVos) do
			local equip = vo:getConfigData()
			--绿色以上装备
			if equip.nQuality > 1 then
				bHasGoodQualityEquip = true
				break
			end
		end
		if bHasGoodQualityEquip then
			break
		end
	end 
	return bHasGoodQualityEquip
end

function BuildGroup:setBubbleVisible(bIsShow)
    bIsShow = self.bBubbleState and bIsShow
    if self.pBubbleLayer then
        self.pBubbleLayer:setVisible(bIsShow)
    end

    if self.pLayTopMsg then
        local isShow = not bIsShow
        if self.pBubbleLayer == nil then
            isShow = true
        end
        self.pLayTopMsg:setVisible(isShow)
    end
end

--展示冒泡
-- tParamEx:(table) 扩展参数
function BuildGroup:showBubble( _nType, _nChildType, _nDlgIndex, _nTxIndex, _sImgName )	
	-- local bSpecial = false 
	-- --三个兵营和科技院图标的特殊处理
	-- if self.tBuildInfo.sTid == e_build_ids.tnoly or 
	-- 	self.tBuildInfo.sTid == e_build_ids.infantry or 
	-- 	self.tBuildInfo.sTid == e_build_ids.sowar or
	-- 	self.tBuildInfo.sTid == e_build_ids.archer  then
		
	-- 	bSpecial = true
	-- end
	-- if  self.pBubbleLayer and  self.pBubbleLayer.bSpecial ~=  bSpecial then
	-- 	self.pBubbleLayer = nil 
	-- end
	if not self.pBubbleLayer then

		--self.pBubbleLayer = BuildBubbleLayer.new(bSpecial)
		self.pBubbleLayer = BuildBubbleLayer.new(false)
		
		self:addView(self.pBubbleLayer, 101)
		--设置位置
		local nPosX = self.tShowData.w * self.tShowData.fBtRw - self.pBubbleLayer:getWidth() / 2
		local nPosY = self.tShowData.h * self.tShowData.fBtRh - 10
		
		self.pBubbleLayer:setPosition(nPosX, nPosY)
		self.pBubbleLayer:setClickedCallBack(handler(self, self.onBubbleClicked))
	end
	--募兵府上的气泡位置调整
	if self.tBuildInfo.sTid == e_build_ids.mbf then
		local nPosX = self.tShowData.w * self.tShowData.fBtRw - self.pBubbleLayer:getWidth() / 2
		if self.tBuildInfo.nRecruitTp == nil then
			nPosX = nPosX + 10
		end
		local nPosY = self.tShowData.h * self.tShowData.fBtRh - 10
		self.pBubbleLayer:setPosition(nPosX, nPosY)
	end
	--展示冒泡
	self.pBubbleLayer:setVisible(true)
    self.bBubbleState = true
	--隐藏等级名字(城内建筑)
	-- if self.tBuildInfo.nCellIndex < n_start_suburb_cell then
		self.pLayTopMsg:setVisible(false)
	-- end
	self.pBubbleLayer:setCurData(_nType, _nChildType, _nDlgIndex, _nTxIndex, _sImgName )
end

--隐藏冒泡
function BuildGroup:hideBubble(  )
	-- body
	if self.pBubbleLayer then
		self.pBubbleLayer:hideBubbleSelf(function ( ... )
			-- body
            self.bBubbleState = false
			self.pLayTopMsg:setVisible(true)
		end)
		-- --隐藏冒泡
		-- self.pBubbleLayer:setVisible(false)
		-- --如果存在黄色光圈，移除
		-- self.pBubbleLayer:removeYellowRing()
		-- --移除左右摇摆效果
		-- self.pBubbleLayer:removeQiPaoRstTx()
		-- --移除缩放效果
		-- self.pBubbleLayer:removeQiPaoRRsTx()
	else
		self.pLayTopMsg:setVisible(true)
	end
	--展示等级名字
	-- if self.tBuildInfo and self.tBuildInfo.nCellIndex < n_start_suburb_cell then
		-- self.pLayTopMsg:setVisible(true)
	-- end
end

--设置名字等级是否展示
function BuildGroup:setTopLayVisible( _bShow )
	-- body
	self.pLayTopMsg:setVisible(_bShow)
end

--展示睡眠
function BuildGroup:showSleeping(  )
	-- body
	if not self.pTxSleep then
		self.pTxSleep = getSleepTx()
		self:addView(self.pTxSleep,100)
		--设置位置
		local nPosX = self.tShowData.w * self.tShowData.fBtRw - self.pTxSleep:getWidth() / 2
		local nPosY = self.tShowData.h * 0.5 - self.pTxSleep:getHeight() / 2
		self.pTxSleep:setPosition(nPosX, nPosY)
		self.pTxSleep:setScale(1.5)
	end

	--移除生产中建筑的特效
	self:removeTxForBuildAtMaking()
end

--隐藏睡眠
function BuildGroup:hideSleeping(  )
	-- body
	if self.pTxSleep then
		self.pTxSleep:stopAllActions()
		self.pTxSleep:removeSelf()
		self.pTxSleep = nil
	end

	--展示那些生产中的特效
	self:showTxForBuildAtMaking()
end

--冒泡点击事件
function BuildGroup:onBubbleClicked( _nChildType, _nDlgIndex, _nFunc)
	-- body
	--判定在执行气泡特效的时候不执行点击响应
	if self.pBubbleLayer and not self.pBubbleLayer:isCanDoItemClick() then
		return
	end

	if _nChildType == e_type_bubble.ntzs 
		or _nChildType == e_type_bubble.mjzs
		or _nChildType == e_type_bubble.mczs
		or _nChildType == e_type_bubble.tkzs then --征收
		-- self:onSubColClicked()
		local tObject = {}
		tObject.nType = e_dlg_index.rescollect --dlg类型
		sendMsg(ghd_show_dlg_by_type, tObject)

		Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.food1_res_bubble)

	elseif _nChildType == e_type_bubble.tjptb then --铁匠铺生产完成
		local bIsWillFull = Player:getEquipData():isEquipWillFull(1)
		if bIsWillFull then
			sendMsg(ghd_equipBag_fulled_msg)
			return
		end
		SocketManager:sendMsg("reqEquipGet", {},function ( __msg )
			-- body
			if __msg.head.state == SocketErrorType.success then
				--气泡点击响应
				local tOb = {}
				tOb.nCell = e_build_cell.tjp
				sendMsg(ghd_build_bubble_clicktx_msg, tOb)
				--播放音效
				Sounds.playEffect(Sounds.Effect.make)
			end
		end)
		Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.smithshop_bubble)
	elseif _nChildType == e_type_bubble.sjmf then --升级免费加速
		local tObject = {}
		tObject.nType = 1 --免费加速
		tObject.nBuildId = self.tBuildInfo.sTid --建筑id
		tObject.nCell = self.tBuildInfo.nCellIndex --建筑格子下标
		sendMsg(ghd_up_build_msg,tObject)

		--新手引导免费加速点击
		if B_GUIDE_LOG then
			print("B_GUIDE_LOG BuildGroup 免费加速点击回调")
		end
		-- Player:getNewGuideMgr():onClickedNewGuideFinger(self.pBubbleLayer)
	elseif _nChildType == e_type_bubble.gjqz then --求助
		-- 建筑求助
		SocketManager:sendMsg("buildupinghelp", {self.tBuildInfo.nCellIndex})
	elseif _nChildType == e_type_bubble.tnolyspeed then --科研活动加速
		--请求科研加速
		SocketManager:sendMsg("reqEnemySpeed", {e_item_ids.kyjs})
	elseif _nChildType == e_type_bubble.buildspeed then     --建筑升级活动加速
		SocketManager:sendMsg("reqEnemySpeed", {e_item_ids.jzjs, self.nCellIndex})
	elseif _nChildType == e_type_bubble.campspeed then     --募兵加速
		SocketManager:sendMsg("reqEnemySpeed", {e_item_ids.mbjs, self.nCellIndex})
	elseif _nChildType == e_type_bubble.kjtb then --科技图标
		--获得已经升级好的科技数据
		local tUpingTnoly = Player:getTnolyData():getUpingTnoly()
		if tUpingTnoly then
			if tUpingTnoly:getUpingFinalLeftTime() <= 0 then
				local tObject = {}
				tObject.nType = 3
				sendMsg(ghd_action_tnoly_msg, tObject)
			end
		end
		Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.tnoly_build_bubble)
	elseif _nChildType == e_type_bubble.zmwg then --招募文官
		--显示雇用气泡的时候进入雇用界面
		local tObject = {}
		tObject.nType = e_dlg_index.civilemploy --dlg类型
		tObject.nEmployType = e_hire_type.official	
		sendMsg(ghd_show_dlg_by_type,tObject)
	elseif _nChildType == e_type_bubble.ateliertb then --工坊图标
		--领取材料
		SocketManager:sendMsg("getProduction", {})
	elseif _nChildType == e_type_bubble.zbgfp then   --珍宝阁
		--直接进入珍宝阁界面		
		local tObject = {}
		tObject.nType = e_dlg_index.treasureshop --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)
		Player:getNewGuideMgr():onClickedNewGuideFinger(self.pLayBUildFinger)
	elseif _nChildType == e_type_bubble.bjtzm then   --拜将台
		--直接进入拜将台界面		
		local tObject = {}
		tObject.nType = e_dlg_index.buyhero --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)
		--新手教程
		Player:getNewGuideMgr():onClickedNewGuideFinger(self.pLayBUildFinger)
	elseif _nChildType == e_type_bubble.xlpmfxl then    --洗炼铺
		--直接进入洗炼铺界面		
		local tObject = {}
		tObject.nType = e_dlg_index.smithshop --dlg类型
		tObject.nFuncIdx = n_smith_func_type.train   --跳到洗炼功能
		sendMsg(ghd_show_dlg_by_type,tObject)
	elseif _nChildType == e_type_bubble.gatebc then     --城门
		--直接进入城防界面		
		local tObject = {}
		tObject.nType = e_dlg_index.wall --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)
	elseif (_nChildType == e_type_bubble.bbmb --兵营
		or _nChildType == e_type_bubble.qbmb 
		or _nChildType == e_type_bubble.gbmb ) and 
		(self:isCampRecruitOK() or self:isCampHouseRecruitOK()) then
		-- 领取募兵
		local tRecuitOk = self.tBuildInfo:getRecruitedQue()
		local tObject = {}
		tObject.nBuildId = self.tBuildInfo.sTid
		tObject.nType = 8
		tObject.sId = tRecuitOk.nId
		sendMsg(ghd_recruit_action_msg,tObject)
	elseif _nChildType == e_type_bubble.tjpspeedfree then  --铁匠铺免费加速
		SocketManager:sendMsg("reqMakeQuick", {}, function(__msg)
			-- body
			if __msg.head.state == SocketErrorType.success then
				TOAST(getConvertedStr(7, 10122))
			end
			--新手引导加速点后
			Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.tjp_equip_speed)
		end)
	elseif _nChildType == e_type_bubble.kjyspeedfree then  --科技院免费学者加速
		local tObject = {}
		tObject.nType = 1
		sendMsg(ghd_action_tnoly_msg, tObject)
	elseif _nChildType == e_type_bubble.mjjzcj or 
		_nChildType == e_type_bubble.mcjzcj or 
		_nChildType == e_type_bubble.ntjzcj or
		_nChildType == e_type_bubble.tkjzcj then
		local tOb = {}
		tOb.nType = e_dlg_index.dlgbuildsuburb
		tOb.tData = self.tBuildInfo
		sendMsg(ghd_show_dlg_by_type, tOb)
	elseif _nChildType == e_type_bubble.recruit then    --兵营
		--直接进入洗炼铺界面		
		local tObject = {}
		tObject.nType = e_dlg_index.camp --dlg类型
		tObject.nBuildId = self.tBuildInfo.sTid
		sendMsg(ghd_show_dlg_by_type,tObject)
	elseif _nChildType == e_type_bubble.tsfactivate then --统帅府有御兵术可激活
		self:onTsfTroopActivite()
	elseif _nChildType == e_type_bubble.jzkx then
		self:onEnterClicked()	
	elseif _nChildType == e_type_bubble.ybssj then
		local tObject = {}
	    tObject.nType = e_dlg_index.troopsdetail --dlg类型
	    sendMsg(ghd_show_dlg_by_type,tObject)	
	elseif _nChildType == e_type_bubble.jjctz then	    
	   	local tObject = {}
		tObject.nType = e_dlg_index.dlgarena --dlg类型
		tObject.nFPage = 1
		sendMsg(ghd_show_dlg_by_type,tObject)
	elseif _nChildType == e_type_bubble.zydh then	    
	   	local tObject = {}
		tObject.nType = e_dlg_index.warehouse --dlg类型
		tObject.nPagIndex = 2 				 --去资源打包分页
		sendMsg(ghd_show_dlg_by_type,tObject)
	elseif _nChildType == e_type_bubble.zzdt then	--战争大厅            
	   	local tObject = {}
		--tObject.nType = _nDlgIndex --dlg类型	
        tObject.nType = e_dlg_index.dlgwarhall	 				 
		sendMsg(ghd_show_dlg_by_type,tObject)
		--新手教程
		Player:getNewGuideMgr():onClickedNewGuideFinger(self.pLayBUildFinger)
	elseif _nChildType == e_type_bubble.mbfjz then	--募兵府建造
		local tObject = {}
		tObject.nType = e_dlg_index.restructrecruit --dlg类型
		tObject.nRecruitTp = nil
		sendMsg(ghd_show_dlg_by_type, tObject)           
	end
	if _nFunc then
		_nFunc()
end
end

--建筑升级完成消息毁掉（展示特效）
function BuildGroup:showUpCompletedTx( sMsgName, pMsgObj  )
	-- body
	if pMsgObj then
		local nCell = pMsgObj.nCell
		if nCell and self.tBuildInfo and self.tBuildInfo.nCellIndex == nCell then
			--刷新当前状态
			if not self.bHasShowTx then
				self:showBuildUpingTx(nCell, self.tBuildInfo.sTid)
			end
		end
	end
end

--展示建筑生产中的特效
function BuildGroup:showTxForBuildAtMaking(  )
	-- body
	-- if self.tBuildInfo.sTid == e_build_ids.atelier and self.tBuildInfo.nState == e_build_state.producing then --作坊生产中
	-- 	if self.tTx == nil or table.nums(self.tTx) <= 0 then
	-- 		self.tTx = {}
	-- 		local pArm = MArmatureUtils:createMArmature(
	-- 			tNormalCusArmDatas["13"], 
	-- 			self, 
	-- 			100, 
	-- 			cc.p(self:getWidth() / 2,self:getHeight() / 2),
	-- 		    function ( _pArm )
	-- 		    	-- _pArm:removeSelf()
	-- 		    	-- _pArm = nil
	-- 		    end, Scene_arm_type.base)
	-- 		table.insert(self.tTx, pArm)
	-- 		if pArm then
	-- 			pArm:play(-1)
	-- 		end
	-- 	end
	-- elseif self.tBuildInfo.sTid == e_build_ids.tjp then --铁匠铺生产中（这里不需要判断了，进入该方法之前已经判断好了）
	-- 	if self.tTx == nil or table.nums(self.tTx) <= 0 then
	-- 		self.tTx = {}
	-- 		doDelayForSomething(self,function (  )
	-- 			-- body
	-- 			for i = 1, 4 do
	-- 				local pArm = MArmatureUtils:createMArmature(
	-- 					tNormalCusArmDatas["14_" .. i], 
	-- 					self, 
	-- 					100, 
	-- 					cc.p(self:getWidth() / 2,self:getHeight() / 2),
	-- 				    function ( _pArm )
	-- 				    	-- _pArm:removeSelf()
	-- 				    	-- _pArm = nil
	-- 				    end, Scene_arm_type.base)
	-- 				table.insert(self.tTx, pArm)
	-- 				if pArm then
	-- 					pArm:play(-1)
	-- 				end
	-- 			end
	-- 		end,0.2)
	-- 	end
	-- elseif self.tBuildInfo.sTid == e_build_ids.tnoly then --科技院
	-- 	if self.tTx == nil or table.nums(self.tTx) <= 0 then
	-- 		self.tTx = {}
	-- 		doDelayForSomething(self,function (  )
	-- 			-- body
	-- 			for i = 1, 5 do
	-- 				local nZorder = 100
	-- 				if i == 5 then
	-- 					nZorder = 5
	-- 				end
	-- 				local pArm = MArmatureUtils:createMArmature(
	-- 					tNormalCusArmDatas["17_" .. i], 
	-- 					self, 
	-- 					nZorder, 
	-- 					cc.p(self:getWidth() / 2,self:getHeight() / 2),
	-- 				    function ( _pArm )
	-- 				    	-- _pArm:removeSelf()
	-- 				    	-- _pArm = nil
	-- 				    end, Scene_arm_type.base)
	-- 				table.insert(self.tTx, pArm)
	-- 				if pArm then
	-- 					pArm:play(-1)
	-- 				end
	-- 			end
	-- 			--粒子效果
	-- 			local pParitcle = createParitcle("tx/other/lizi_zjm_kjy_001.plist")
	-- 			pParitcle:setPosition(250 ,195)
	-- 			self:addView(pParitcle,100)
	-- 		end,0.1)
	-- 	end
	-- elseif self.tBuildInfo.sTid == e_build_ids.infantry then --步兵营
	-- 	if self.tTx == nil or table.nums(self.tTx) <= 0 then
	-- 		self.tTx = {}
	-- 		-- 展示特效
	-- 		--待机->敲盾->普攻->强攻->普攻->待机->待机
	-- 		self:showBbCampTx(1, "18_" , 1)
	-- 		--敲盾->强攻->普攻->强攻->待机->待机->待机
	-- 		self:showBbCampTx(2, "19_" , 1)
	-- 	end
	-- elseif self.tBuildInfo.sTid == e_build_ids.archer then --弓兵营
	-- 	if self.tTx == nil or table.nums(self.tTx) <= 0 then
	-- 		self.tTx = {}
	-- 		-- 展示特效
	-- 		--玩弓->强攻->普攻->待机->玩弓->普攻->待机->待机
	-- 		self:showGbCampTx(1, "20_" , 1)
	-- 		--普攻->待机->玩弓->普攻->待机->待机->玩弓->强攻
	-- 		self:showGbCampTx(2, "21_" , 1)
	-- 		--玩弓->普攻->待机->待机->玩弓->强攻->普攻->待机
	-- 		self:showGbCampTx(3, "22_" , 1)
	-- 	end
	-- end
end

--播放步兵营建筑募兵中的特效
function BuildGroup:showBbCampTx( _nType, _sKey, _nIndex )
	-- body
	if not _nIndex or not _sKey then return end
	if self.tTx == nil then
		self.tTx = {}
	end
	if self.tTx[_nType] == nil then
		local pArm = MArmatureUtils:createMArmature(
			tNormalCusArmDatas[_sKey .. _nIndex], 
			self, 
			100, 
			cc.p(self:getWidth() / 2,self:getHeight() / 2),
		    function ( _pArm )
		    	-- _nIndex = _nIndex + 1
		    	-- if _nIndex > 7 then
		    	-- 	_nIndex = 1
		    	-- end
		    	-- self:showBbCampTx(_nType, _sKey,_nIndex)
		    end, Scene_arm_type.base)
		self.tTx[_nType] = pArm
	else
		self.tTx[_nType]:setData(tNormalCusArmDatas[_sKey .. _nIndex])
	end
	--播放特效
	if self.tTx[_nType] then
		self.tTx[_nType]:play(-1)
	end
end

--播放弓兵营建筑募兵中特效
function BuildGroup:showGbCampTx( _nType, _sKey, _nIndex )
	-- body
	if not _nIndex or not _sKey then return end
	if self.tTx == nil then
		self.tTx = {}
	end
	if self.tTx[_nType] == nil then
		local pArm = MArmatureUtils:createMArmature(
			tNormalCusArmDatas[_sKey .. _nIndex], 
			self, 
			100, 
			cc.p(self:getWidth() / 2,self:getHeight() / 2),
		    function ( _pArm )
		    	_nIndex = _nIndex + 1
		    	if _nIndex > 8 then
		    		_nIndex = 1
		    	end
		    	self:showGbCampTx(_nType, _sKey,_nIndex)
		    end, Scene_arm_type.base)
		self.tTx[_nType] = pArm
	else
		self.tTx[_nType]:setData(tNormalCusArmDatas[_sKey .. _nIndex])
	end
	--播放特效
	if self.tTx[_nType] then
		self.tTx[_nType]:setFrameEventCallFunc(function ( _nCur )
			if _nCur == 16 then --第6帧回调，表现射箭效果
				if _nType == 1 then --弓兵1在2,3,6是攻击动作
					if _nIndex == 2 or _nIndex == 3 or _nIndex == 6 then
						--射箭
						self:showArrawForGbCamp("20_9")
					end
				elseif _nType == 2 then --弓兵2在1,4,8是攻击动作
					if _nIndex == 1 or _nIndex == 4 or _nIndex == 8 then
						--射箭
						self:showArrawForGbCamp("21_9")
					end
				elseif _nType == 3 then --弓兵3在2,6,7是攻击动作
					if _nIndex == 2 or _nIndex == 6 or _nIndex == 7 then
						--射箭
						self:showArrawForGbCamp("22_9")
					end
				end
			end
		end)
		self.tTx[_nType]:play(1)
	end
end

--播放骑兵营特效
function BuildGroup:showQbCampTx(  )
	-- body
	if self.tTx == nil then
		self.tTx = {}
		local pArm = MArmatureUtils:createMArmature(
			tNormalCusArmDatas["23"], 
			self, 
			100, 
			cc.p(self:getWidth() / 2,self:getHeight() / 2),
		    function ( _pArm )
		    	-- _pArm:removeSelf()
		    	-- _pArm = nil
		    end, Scene_arm_type.base)
		table.insert(self.tTx, pArm)
		if pArm then
			pArm:play(-1)
		end
	end
end

--播放工兵营射箭
function BuildGroup:showArrawForGbCamp( _sKey )
	-- body
	local pArm = MArmatureUtils:createMArmature(
		tNormalCusArmDatas[_sKey], 
		self, 
		100, 
		cc.p(self:getWidth() / 2,self:getHeight() / 2),
	    function ( _pArm )
	    	_pArm:removeSelf()
	    	_pArm = nil
	    end, Scene_arm_type.base) 
	if pArm then
		pArm:play(1)
	end
end

--移除建筑生产状态中的特效
function BuildGroup:removeTxForBuildAtMaking(  )
	-- body
	-- if self.tBuildInfo.sTid == e_build_ids.atelier then --作坊
	-- 	self:removeBuildTx(self.tTx)
	-- elseif self.tBuildInfo.sTid == e_build_ids.tjp then --铁匠铺
	-- 	self:removeBuildTx(self.tTx)
	-- elseif self.tBuildInfo.sTid == e_build_ids.tnoly then --科学院
	-- 	self:removeBuildTx(self.tTx)
	-- elseif self.tBuildInfo.sTid == e_build_ids.infantry then --步兵营
	-- 	self:removeBuildTx(self.tTx)
	-- elseif self.tBuildInfo.sTid == e_build_ids.archer then --弓兵营
	-- 	self:removeBuildTx(self.tTx)
	-- end
end

--展示建筑常态特效
function BuildGroup:showBuildNormnalTx(  )
	-- body
	if self.tBuildInfo.sTid == e_build_ids.farm then --农场
		if self.tNTx == nil or table.nums(self.tNTx) <= 0 then
			self.tNTx = {}
			local pArm = MArmatureUtils:createMArmature(
				tNormalCusArmDatas["15"], 
				self, 
				50, 
				cc.p(self:getWidth() / 2,self:getHeight() / 2),
			    function ( _pArm )
			    	-- _pArm:removeSelf()
			    	-- _pArm = nil
			    end, Scene_arm_type.base)
			table.insert(self.tNTx, pArm)
			if pArm then
				pArm:play(-1)
			end
		end
	elseif self.tBuildInfo.sTid == e_build_ids.jxg then --将军府
		if self.tNTx == nil or table.nums(self.tNTx) <= 0 then
			self.tNTx = {}
			-- doDelayForSomething(self,function (  )
			-- 	-- body
			-- 	for i = 1, 3 do
			-- 		local pArm = MArmatureUtils:createMArmature(
			-- 			tNormalCusArmDatas["16_" .. i], 
			-- 			self, 
			-- 			100, 
			-- 			cc.p(self:getWidth() / 2,self:getHeight() / 2),
			-- 		    function ( _pArm )
			-- 		    	-- _pArm:removeSelf()
			-- 		    	-- _pArm = nil
			-- 		    end, Scene_arm_type.base)
			-- 		table.insert(self.tNTx, pArm)
			-- 		if pArm then
			-- 			pArm:play(-1)
			-- 		end
			-- 	end
			-- end,0.2)
			local sName = createAnimationBackName("tx/exportjson/", "sg_zbg_dl_s_001_2")
		    local pArm = ccs.Armature:create(sName)
		    pArm:setPosition(self:getWidth() / 2,self:getHeight() / 2)
		    self:addChild(pArm,100)
		    pArm:getAnimation():play("Animation1", 1)
			table.insert(self.tNTx, pArm)
		end
	elseif self.tBuildInfo.sTid == e_build_ids.tcf then --统帅府
		if self.tNTx == nil or table.nums(self.tNTx) <= 0 then
			self.tNTx = {}
			-- doDelayForSomething(self,function (  )
			-- 	-- body
			-- 	for i = 1, 3 do
			-- 		local pArm = MArmatureUtils:createMArmature(
			-- 			tNormalCusArmDatas["16_" .. i], 
			-- 			self, 
			-- 			100, 
			-- 			cc.p(self:getWidth() / 2,self:getHeight() / 2),
			-- 		    function ( _pArm )
			-- 		    	-- _pArm:removeSelf()
			-- 		    	-- _pArm = nil
			-- 		    end, Scene_arm_type.base)
			-- 		table.insert(self.tNTx, pArm)
			-- 		if pArm then
			-- 			pArm:play(-1)
			-- 		end
			-- 	end
			-- end,0.2)
			local sName = createAnimationBackName("tx/exportjson/", "sg_zbg_dl_s_001_2")
		    local pArm = ccs.Armature:create(sName)
		    pArm:setPosition(self:getWidth() / 2,self:getHeight() / 2)
		    self:addChild(pArm,100)
		    pArm:getAnimation():play("Animation1", 1)
			table.insert(self.tNTx, pArm)
		end		
	elseif self.tBuildInfo.sTid == e_build_ids.jbp then --珍宝阁
		if self.tNTx == nil or table.nums(self.tNTx) <= 0 then
			self.tNTx = {}
			local sName = createAnimationBackName("tx/exportjson/", "sg_zbg_dl_s_001_2")
		    local pArm = ccs.Armature:create(sName)
		    -- pArm:getAnimation():play("Animation1", 1)
		    -- pArm:getAnimation():play("Animation1_Copy1", -1)
		    pArm:setPosition(self:getWidth() / 2,self:getHeight() / 2)
		    self:addChild(pArm,100)
		    --设置摄像机高于世界远近视角，这样才能显示出来
			-- pArm:setCameraMask(MUI.CAMERA_FLAG.USER2)
			table.insert(self.tNTx, pArm)

			local pParitcle = createParitcle("tx/other/lizi_zjm_zbg_003.plist")
			pParitcle:setPosition(self:getWidth() / 2 + 12,self:getHeight() / 2 + 8)
			pParitcle:setScale(0.9)
			self:addView(pParitcle,110)

		end
	elseif self.tBuildInfo.sTid == e_build_ids.arena then --竞技场
		if self.tTx == nil or table.nums(self.tTx) <= 0 then			
			self.tTx = {}
			doDelayForSomething(self,function (  )
				-- body						
				local pArm = MArmatureUtils:createMArmature(
					tNormalCusArmDatas["52" ], 
					self, 
					100, 
					cc.p(self:getWidth() / 2,self:getHeight() / 2),
				    function ( _pArm )
				    	-- _pArm:removeSelf()
				    	-- _pArm = nil
				    end, Scene_arm_type.base)
				table.insert(self.tTx, pArm)
				if pArm then
					pArm:play(-1)
				end			
			end,0.2)
		end
	elseif self.tBuildInfo.sTid == e_build_ids.atelier then --作坊
		if self.tTx == nil or table.nums(self.tTx) <= 0 then
			self.tTx = {}
			doDelayForSomething(self,function (  )
				-- body
				for i = 1, 4 do
					local pArm = MArmatureUtils:createMArmature(
						tNormalCusArmDatas["13_" .. i], 
						self, 
						100, 
						cc.p(self:getWidth() / 2,self:getHeight() / 2),
					    function ( _pArm )
					    	-- _pArm:removeSelf()
					    	-- _pArm = nil
					    end, Scene_arm_type.base)
					table.insert(self.tTx, pArm)
					if pArm then
						pArm:play(-1)
					end
				end
			end,0.2)
		end
	elseif self.tBuildInfo.sTid == e_build_ids.tjp then --铁匠铺
		if self.tTx == nil or table.nums(self.tTx) <= 0 then
			self.tTx = {}
			doDelayForSomething(self,function (  )
				-- body
				for i = 1, 6 do
					local pArm = MArmatureUtils:createMArmature(
						tNormalCusArmDatas["14_" .. i], 
						self, 
						99, 
						cc.p(self:getWidth() / 2,self:getHeight() / 2),
					    function ( _pArm )
					    	-- _pArm:removeSelf()
					    	-- _pArm = nil
					    end, Scene_arm_type.base)
					table.insert(self.tTx, pArm)
					if pArm then
						pArm:play(-1)
					end
				end
			end,0.2)
		end
	elseif self.tBuildInfo.sTid == e_build_ids.tnoly then --科技院
		if self.tTx == nil or table.nums(self.tTx) <= 0 then
			self.tTx = {}
			doDelayForSomething(self,function (  )
				-- body
				for i = 1, 6 do
					local nZorder = 99
					
					if i == 6 then
						nZorder = 5
					end
					local pArm = MArmatureUtils:createMArmature(
						tNormalCusArmDatas["17_" .. i], 
						self, 
						nZorder, 
						cc.p(self:getWidth() / 2,self:getHeight() / 2),
					    function ( _pArm )
					    	-- _pArm:removeSelf()
					    	-- _pArm = nil
					    end, Scene_arm_type.base)
					table.insert(self.tTx, pArm)
					if pArm then
						pArm:play(-1)
					end
				end
				--粒子效果
				local pParitcle = createParitcle("tx/other/lizi_zjm_kjy_001.plist")
				pParitcle:setPosition(250 ,195)
				self:addView(pParitcle,100)

			end,0.1)


		end
	elseif self.tBuildInfo.sTid == e_build_ids.infantry then --步兵营
		if self.tTx == nil or table.nums(self.tTx) <= 0 then
			self.tTx = {}
			-- 展示特效
			--待机->敲盾->普攻->强攻->普攻->待机->待机
			self:showBbCampTx(1, "18_" , 1)
			--敲盾->强攻->普攻->强攻->待机->待机->待机
			-- self:showBbCampTx(2, "19_" , 1)
		end
	elseif self.tBuildInfo.sTid == e_build_ids.archer then --弓兵营
		if self.tTx == nil or table.nums(self.tTx) <= 0 then
			self.tTx = {}
			-- 展示特效
			--玩弓->强攻->普攻->待机->玩弓->普攻->待机->待机
			self:showGbCampTx(1, "20_" , 1)
			--普攻->待机->玩弓->普攻->待机->待机->玩弓->强攻
			self:showGbCampTx(2, "21_" , 1)
			--玩弓->普攻->待机->待机->玩弓->强攻->普攻->待机
			self:showGbCampTx(3, "22_" , 1)
		end
	elseif self.tBuildInfo.sTid == e_build_ids.sowar then --骑兵营
		-- 展示特效
		self:showQbCampTx()
	end
end

--移除建筑常态特效
function BuildGroup:removeBuildNormalTx(  )
	-- body
	if self.tBuildInfo.sTid == e_build_ids.farm then --农场
		self:removeBuildTx(self.tNTx)
	elseif self.tBuildInfo.sTid == e_build_ids.jxg then --将军府
		self:removeBuildTx(self.tNTx)
	elseif self.tBuildInfo.sTid == e_build_ids.tcf then --统帅府
		self:removeBuildTx(self.tNTx)		
	elseif self.tBuildInfo.sTid == e_build_ids.jbp then --珍宝阁
		self:removeBuildTx(self.tNTx)
	elseif self.tBuildInfo.sTid == e_build_ids.arena then --竞技场
		self:removeBuildTx(self.tTx)		
	elseif self.tBuildInfo.sTid == e_build_ids.atelier then --作坊
		self:removeBuildTx(self.tTx)
	elseif self.tBuildInfo.sTid == e_build_ids.tjp then --铁匠铺
		self:removeBuildTx(self.tTx)
	elseif self.tBuildInfo.sTid == e_build_ids.tnoly then --科学院
		self:removeBuildTx(self.tTx)
	elseif self.tBuildInfo.sTid == e_build_ids.infantry then --步兵营
		self:removeBuildTx(self.tTx)
	elseif self.tBuildInfo.sTid == e_build_ids.archer then --弓兵营
		self:removeBuildTx(self.tTx)
	elseif self.tBuildInfo.sTid == e_build_ids.sowar then --骑兵营
		self:removeBuildTx(self.tTx)
	end
end

--移除建筑特效
function BuildGroup:removeBuildTx( _tTx )
	-- body
	if _tTx and table.nums(_tTx) > 0 then
		local nSize = table.nums(_tTx)
		for i = nSize, 1, -1 do
			_tTx[i]:removeSelf()
			_tTx[i] = nil
		end
		_tTx = nil
	end
end

--显示主界面 活动加速按钮 点击反馈效果
function BuildGroup:showBubbleClickTx( sMsgName, pMsgObj )
	-- body	
	local nBuildCell = pMsgObj.nCell
	if not nBuildCell then
		return
	end

	if self.tBuildInfo.nCellIndex ~= nBuildCell then --资源田
		return
	end
	-- dump(pMsgObj, "showBubbleClickTx", 100)
	-- dump(self.bHasShowTx, "self.bHasShowTx", 100)
	--如果正在播放升级特效
	if self.bHasShowTx then
		return
	end	
	if self.bHasBubbleClickTx then--如果正在执行效果
		return
	end	
	self.bHasBubbleClickTx = true
	local nScale = 2	
	--获取底座x位置和图片对应y中点
	local nPosX = self.tShowData.w * self.tShowData.fBtRw 
	local nPosY = self.tShowData.h * self.tShowData.fDzRh
	
	if self.tBuildInfo.sTid == e_build_ids.palace then  --王宫升级的位置特殊处理
		nPosX = nPosX + 90
		nPosY = nPosY + 115 + 13
		nScale = 3
	elseif self.tBuildInfo.sTid == e_build_ids.gate then --城门升级的位置特殊处理
		nPosX = nPosX + 35
		nPosY = nPosY - 21
		nScale = 2.5
	elseif self.tBuildInfo.sTid == e_build_ids.store then --仓库	
		nPosX = nPosX + 5
		nPosY = nPosY + 40
	elseif self.tBuildInfo.sTid == e_build_ids.tjp then --铁匠铺
		nPosX = nPosX + 10
		nPosY = nPosY + 40			
	elseif self.tBuildInfo.sTid == e_build_ids.atelier then --工坊
		nPosX = nPosX + 7
		nPosY = nPosY + 30 + 5
	elseif self.tBuildInfo.sTid == e_build_ids.sowar or --兵营
		self.tBuildInfo.sTid == e_build_ids.archer or 
		self.tBuildInfo.sTid == e_build_ids.infantry then			
		nPosX = nPosX + 20
		nPosY = nPosY + 40 + 5
	elseif self.tBuildInfo.sTid == e_build_ids.tnoly then --科技院
		nPosX = nPosX - 5				
		nPosY = nPosY + 35 + 16	
	elseif self.tBuildInfo.sTid == e_build_ids.house
		or self.tBuildInfo.sTid == e_build_ids.wood
		or self.tBuildInfo.sTid == e_build_ids.farm
		or self.tBuildInfo.sTid == e_build_ids.iron then --资源田
		nScale = 1.5	
		nPosY = nPosY + 37 - 5 - 10
	elseif self.tBuildInfo.sTid == e_build_ids.mbf then --募兵府
		nPosX = nPosX + 20
		nPosY = nPosY + 30
	else
		nPosY = nPosY + 30
	end
	
	for i = 1, 2 do			
		local pArm = MArmatureUtils:createMArmature(
			tNormalCusArmDatas["52_" .. i], 
			self, 
			99, 
			cc.p(nPosX, nPosY),
		    function ( _pArm )
		    	if i == 1 then
		    		self.bHasBubbleClickTx = false		    		
		    	end
		    	_pArm:removeSelf()
		    	_pArm = nil
		    end, Scene_arm_type.base)
		pArm:setScale(nScale*i)
		if pArm then
			pArm:play(1)
		end			
	end	

end


--展示升级特效
function BuildGroup:showBuildUpingTx( _buildCell, _buildId )
	-- body
	self.bHasShowTx = true


	local fScale = 1.0
	if self.tBuildInfo.sTid == 11008
		or self.tBuildInfo.sTid == 11009
		or self.tBuildInfo.sTid == 11010
		or self.tBuildInfo.sTid == 11011 then --资源田
		fScale = 0.8
	end



	--获取底座x位置和图片对应y中点
	local nPosX = self.tShowData.w * self.tShowData.fBtRw 
	local nPosY = self.tShowData.h * self.tShowData.fDzRh

	
	if self.tBuildInfo.sTid == 11000 then  --王宫升级的位置特殊处理
		nPosX = nPosX + 10 + 50 + 50 
		nPosY = nPosY + 55
		fScale = 1.5
	end


	if self.tBuildInfo.sTid == 11006 then  --城门升级的位置特殊处理
		nPosX = nPosX + 10
		nPosY = nPosY - 55
		fScale = 1.3
	end

	

	local sName = createAnimationBackName("tx/exportjson/", "sg_jzsj_dh_1_001",2,nil,nil,1,{"sg_jzsj_dh_1_0011"})
    local pArm = ccs.Armature:create(sName)
    pArm:setPosition(nPosX,nPosY)
    pArm:setScale(fScale)
    self:addChild(pArm,10)
    local anima = pArm:getAnimation()
    anima:setMovementEventCallFunc( function(arm, eventType, movmentID)
        -- 判断帧事件类型
        if eventType == ccs.MovementEventType.start then
            
        elseif eventType == ccs.MovementEventType.complete then
            pArm:removeSelf()
        elseif eventType == ccs.MovementEventType.loopComplete then
            
        end
    end )
    anima:play("Animation1", 1)


    --创建一个建筑图片
    local pImgBuild = MUI.MImage.new(self.tShowData.img)
    --设置缩放比例
    pImgBuild:setScale(self.tShowData.fGroupScale)
    self:addView(pImgBuild, 100)
    centerInView(self,pImgBuild)
    pImgBuild:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)

    local action1 = cc.FadeTo:create(0.21, 0.5 * 255)
    local action2 = cc.FadeTo:create(0.69, 0)
    local actionEnd = cc.CallFunc:create(function (  )
    	
		-- body
		pImgBuild:removeSelf()
		--新手引导免费加速点击后(在播放升级特效后加点击完成是因为在点击免费冒泡后会打开两次二级菜单)
		local pT = {}
		pT.nBuildCell = _buildCell
		pT.nBuildId = _buildId
		self:finishSpeedLvup(1, pT)
	end)
	local func = cc.CallFunc:create(function()
		--播放建筑获得经验特效
		self:showBuildLvUpExpTx()
		--延迟1秒后再设置为特效可播状态
        self:performWithDelay(function ()
			self.bHasShowTx = false
		end, 1)
    end)
  
	local allActions = cc.Sequence:create(action1,action2,actionEnd,func)
	pImgBuild:runAction(allActions)

	--播放升级或者升级完成音效
	Sounds.playEffect(Sounds.Effect.building)

end

--播放建筑升级后获得经验特效
function BuildGroup:showBuildLvUpExpTx()
	if not self.tBuildInfo then
		return 
	end
	
	local tBuild = getBuildUpLimitsFromDB(self.tBuildInfo.sTid,self.tBuildInfo.nLv)
	if tBuild and tBuild.exp and tonumber(tBuild.exp) > 0  then
		local tItem = {}
		 tItem[#tItem + 1] = {k = e_type_resdata.exp , v = tonumber(tBuild.exp)}
		 showGetAllItems(tItem)
	end

end

--移除升级特效
function BuildGroup:removeBuildUpingTx(  )
	-- body
end

--新手可以点击完成加速后的操作了
function BuildGroup:finishSpeedLvup(sMsgName, pMsgObj)
	-- body
	if pMsgObj then
		Player:getNewGuideMgr():onBuildSpeedBtnClicked(pMsgObj.nBuildCell, pMsgObj.nBuildId)
	end
end


--点击事件
function BuildGroup:onBuildClicked( pView )
	--有锁就提出提示
	if self.tBuildInfo.sTid == e_build_ids.ylp then
	end
	if self.tBuildInfo:getIsLocked() then
		local tBuildData = getBuildDatasByTid(self.tBuildInfo.sTid)
		if tBuildData then
			TOAST(tBuildData.notopen)
		end
		return
	end

	-- body
	--如果升级中，并且免费时间大于0，则执行免费加速
	if self.tBuildInfo.nState == e_build_state.uping and self.tBuildInfo.fRssTime > 0 then
		local tObject = {}
		tObject.nType = 1 --免费加速
		tObject.nBuildId = self.tBuildInfo.sTid --建筑id
		tObject.nCell = self.tBuildInfo.nCellIndex --建筑格子下标
		sendMsg(ghd_up_build_msg,tObject)

		--新手引导 如果是免费升级点击自身也相当于点击了冒泡
		Player:getNewGuideMgr():onClickedNewGuideFinger(self.pBubbleLayer)
	--如果改建中，并且免费时间大于0，则执行免费加速
	elseif self.tBuildInfo.nState == e_build_state.creating and self.tBuildInfo.fRssTime > 0 then
		local tObject = {}
		tObject.nType = 1 --免费加速
		tObject.nBuildId = self.tBuildInfo.sTid --建筑id
		tObject.nCell = self.tBuildInfo.nCellIndex --建筑格子下标
		sendMsg(ghd_up_build_msg,tObject)

	elseif self.tBuildInfo.sTid == e_build_ids.tnoly and self:isTnolyOK() then --科技院有已完成科技
		--领取科技
		local tObject = {}
		tObject.nType = 3
		sendMsg(ghd_action_tnoly_msg, tObject)

		--新手引导
		Player:getNewGuideMgr():onClickedNewGuideFinger(self.pLayBUildFinger)
		--教你玩引导
		Player:getGirlGuideMgr():onClickedGirlGuideFinger(self.pLayBUildFinger)

	elseif (self.tBuildInfo.sTid == e_build_ids.infantry
		or self.tBuildInfo.sTid == e_build_ids.sowar
		or self.tBuildInfo.sTid == e_build_ids.archer) and self:isCampRecruitOK() then --兵营已招募完成
			-- 领取募兵
			local tRecuitOk = self.tBuildInfo:getRecruitedQue()
			local tObject = {}
			tObject.nBuildId = self.tBuildInfo.sTid
			tObject.nType = 8
			tObject.sId = tRecuitOk.nId
			sendMsg(ghd_recruit_action_msg,tObject)
			if self.tBuildInfo.sTid == e_build_ids.infantry then
				--教你玩引导
				Player:getGirlGuideMgr():onClickedGirlGuideFinger(self.pLayBUildFinger)
			end
	elseif self.tBuildInfo.sTid == e_build_ids.mbf and self:isCampHouseRecruitOK() then --募兵府已招募完成
		local tRecuitOk = self.tBuildInfo:getRecruitedQue()
		local tObject = {}
		tObject.nBuildId = self.tBuildInfo.sTid
		tObject.nType = 8
		tObject.sId = tRecuitOk.nId
		sendMsg(ghd_recruit_action_msg,tObject)
	elseif self.tBuildInfo.sTid == e_build_ids.house
		or self.tBuildInfo.sTid == e_build_ids.farm
		or self.tBuildInfo.sTid == e_build_ids.iron
		or self.tBuildInfo.sTid == e_build_ids.wood then --郊外资源可征收
		if self.tBuildInfo.bActivated then
			-- if self:isCanColledted() then
				-- 请求征收资源
				-- local bOpenSelf = true
				-- self:onSubColClicked(bOpenSelf)
			-- else
				--发送消息关闭除了自身以外有打开的操作按钮，并且打开自身
				local tObject = {}
				tObject.nCell = self.tBuildInfo.nCellIndex
				tObject.bHadChecked = true
				print("ghd_show_build_actionbtn_msg  11111111111111111111")
				sendMsg(ghd_show_build_actionbtn_msg,tObject)
			-- end		
		else
			local tOb = {}
			tOb.nType = e_dlg_index.dlgbuildsuburb
			tOb.tData = self.tBuildInfo
			sendMsg(ghd_show_dlg_by_type, tOb)
		end
	elseif self.tBuildInfo.sTid == e_build_ids.tjp and self:isTjpHadIcon() then --铁匠铺有装备打造完成
		--领取装备
		SocketManager:sendMsg("reqEquipGet", {},function ( __msg )
			-- body
			if __msg.head.state == SocketErrorType.success then
				--播放音效
				Sounds.playEffect(Sounds.Effect.make)
			end
		end)
		--新手引导
		Player:getNewGuideMgr():onClickedNewGuideFinger(self.pLayBUildFinger)
		-- Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.smithshop_bubble)

	elseif self.tBuildInfo.sTid == e_build_ids.atelier and self:isAtelierOK() then --工坊有材料生产完成
		--领取材料
		SocketManager:sendMsg("getProduction", {})
	elseif self.tBuildInfo.sTid == e_build_ids.tcf and self:isTSFCanActivate() then --统帅府有御兵术可激活
		self:onTsfTroopActivite()
	elseif self.tBuildInfo.sTid == e_build_ids.arena then --竞技场
		local tObject = {}
		tObject.nType = e_dlg_index.dlgarena --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)
		--教你玩引导
		Player:getGirlGuideMgr():onClickedGirlGuideFinger(self.pLayBUildFinger)
	elseif self.tBuildInfo.sTid == e_build_ids.warhall then --战争大厅
		local tObject = {}
		tObject.nType = e_dlg_index.dlgwarhall --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)
		--新手教程
		Player:getNewGuideMgr():onClickedNewGuideFinger(self.pLayBUildFinger)
	else
		--新手引导
		local bIsJump = Player:getNewGuideMgr():onClickedNewGuideFinger(self.pLayBUildFinger)
		if not bIsJump then
			--发送消息关闭除了自身以外有打开的操作按钮，并且打开自身
			local tObject = {}
			tObject.nCell = self.tBuildInfo.nCellIndex
			tObject.bHadChecked = true
			sendMsg(ghd_show_build_actionbtn_msg,tObject)		
		end
		
		--教你玩引导
		Player:getGirlGuideMgr():onClickedGirlGuideFinger(self.pLayBUildFinger)
	end
end

--统帅府激活御兵术
function BuildGroup:onTsfTroopActivite()
	-- body
	local pBaseTroop = getTroopsVoById(self.tBuildInfo.nStage)
	if pBaseTroop then
		SocketManager:sendMsg("reqTroopActivite", {pBaseTroop.type}, function(__msg)
			-- body
			if __msg.head.state == SocketErrorType.success then
				if __msg.body then
					TOAST(string.format(getConvertedStr(7, 10282), pBaseTroop.name, pBaseTroop.lv))
				end
			end
		end)			
	end
end


--进入点击事件
function BuildGroup:onEnterClicked( pView )
	-- body
	if self.tBuildInfo then
		--dump(self.tBuildInfo, "self.tBuildInfo", 100)
		local tObject = {}
		if self.tBuildInfo.sTid == e_build_ids.palace then --王宫
			tObject.nType = e_dlg_index.palace --dlg类型
		elseif self.tBuildInfo.sTid == e_build_ids.store then --仓库
			tObject.nType = e_dlg_index.warehouse --dlg类型
		elseif self.tBuildInfo.sTid == e_build_ids.infantry 
			or self.tBuildInfo.sTid == e_build_ids.sowar 
			or self.tBuildInfo.sTid == e_build_ids.archer then --步兵营，骑兵营，弓兵营
				tObject.nType = e_dlg_index.camp --dlg类型
				tObject.nBuildId = self.tBuildInfo.sTid
		elseif self.tBuildInfo.sTid == e_build_ids.tnoly then --科学院
			tObject.nType = e_dlg_index.technology --dlg类型
		elseif self.tBuildInfo.sTid == e_build_ids.jxg then --将军府
			tObject.nType = e_dlg_index.shogunlayer --dlg类型
		elseif self.tBuildInfo.sTid == e_build_ids.atelier then --工坊
			tObject.nType = e_dlg_index.atelier --dlg类型		
		elseif self.tBuildInfo.sTid == e_build_ids.gate then --城墙
			tObject.nType = e_dlg_index.wall --dlg类型
		elseif self.tBuildInfo.sTid == e_build_ids.tjp then --铁匠铺
			tObject.nType = e_dlg_index.smithshop --dlg类型
			tObject.nFuncIdx = n_smith_func_type.build
		elseif self.tBuildInfo.sTid == e_build_ids.ylp then --洗炼铺
			-- tObject.nType = e_dlg_index.refineshop --dlg类型
		elseif self.tBuildInfo.sTid == e_build_ids.jbp then --聚宝盆
			tObject.nType = e_dlg_index.treasureshop --dlg类型
		elseif self.tBuildInfo.sTid == e_build_ids.bjt then--拜将台
			tObject.nType = e_dlg_index.buyhero --dlg类型
		elseif self.tBuildInfo.sTid == e_build_ids.tcf then--统帅府
			tObject.nType = e_dlg_index.dlgchiefhouse --dlg类型	
		elseif self.tBuildInfo.sTid == e_build_ids.arena then--竞技场
			tObject.nType = e_dlg_index.dlgarena --dlg类型								
		elseif self.tBuildInfo.sTid == e_build_ids.mbf then--募兵府
			tObject.nType = e_dlg_index.dlgrecruitsodiers --dlg类型								
		end

		sendMsg(ghd_show_dlg_by_type,tObject)
	end
end

--征收点击事件
function BuildGroup:onSubColClicked( bOpenSelf )
	-- body
	SocketManager:sendMsg("collectRes", {self.tBuildInfo.nCellIndex,1,bOpenSelf}, handler(self, self.onCollectResponse))
end

--征收资源界面回调
function BuildGroup:onCollectResponse( __msg, __oldMsg )
	-- body
	if __msg.head.type == MsgType.collectRes.id then 			--征收
		if __msg.head.state == SocketErrorType.success then
			self:updateViews()
			if __msg.body.o then
				print("获得物品表现")
			end
			--新手引导征收完毕
			-- Player:getNewGuideMgr():onClickedNewGuideFinger(self.pBubbleLayer)
		else
		    TOAST(SocketManager:getErrorStr(__msg.head.state))
        end
    end
end

--建筑状态发生变化
function BuildGroup:changeBuildState( sMsgName, pMsgObj )
	-- body
	if pMsgObj then
		local nCell = pMsgObj.nCell
		local nType = pMsgObj.nType
		local nBuildId = pMsgObj.nBuildId
		if nCell and self.tBuildInfo and self.tBuildInfo.nCellIndex == nCell then
			self:refreshCurDatas()
			--刷新当前状态
			-- self:updateViews()
			if nType == 3 and nBuildId then  --改建后重置建筑图片
				self.tBuildInfo.tShowData = getBuildGroupShowDataByCell(nCell, nBuildId)
				self.tShowData = self.tBuildInfo.tShowData
				self.pImgBuild:setCurrentImage(self.tShowData.img)
				if self.tBuildInfo.nCellIndex == e_build_cell.mbf then
					self:setPosition(self:getPosX(), self:getPosY())
					self:setLayoutSize(self.tShowData.w, self.tShowData.h)
					centerInView(self,self.pImgBuild)
					-- if self.tBuildInfo.nLv > 0
					local nPosX = self.tShowData.w * self.tShowData.fBtRw - self.pLayTopMsg:getWidth() / 2 - 35
					local nPosY = self.tShowData.h * self.tShowData.fBtRh - 20
					self.pLayTopMsg:setPosition(nPosX, nPosY)
					local nPosX = self.tShowData.w * self.tShowData.fBtRw - self.pLayMoreMsg:getWidth() / 2 - 10
					local nPosY = self.tShowData.h * self.tShowData.fDzRh -self.pLayMoreMsg:getHeight() / 2 - 45
					self.pLayMoreMsg:setPosition(nPosX, nPosY)
				end

				--先移除原来的建筑上的特效, 再根据需要添加特效
				self:removeBuildTx(self.tNTx)
				self:showBuildNormnalTx()
			end
		end
	end
end

--资源田征收状态刷新消息回调
function BuildGroup:refreshSubColState( sMsgName, pMsgObj, bPlayMusic)
	-- body
	if pMsgObj then
		-- local nCell = pMsgObj.nCell
		if self.tBuildInfo and self.tBuildInfo.nCellIndex > n_start_suburb_cell then
			-- local nT = getSystemTime(false)
			-- if pMsgObj.nLevyResNum then
			-- 	if pMsgObj.nLevyResNum <= 0 then
			-- 		self.tBuildInfo.nColState = 0 --强制把资源征收的冒泡干掉
			-- 	end
			-- end

			--刷新状态
			-- self:updateSubColState()
			self:updateViews()

			-- local nT2 = getSystemTime(false)
			-- print("nCell,nT2 - nT=",nCell, nT2 - nT)

			--一段时间执行动画
			-- if pMsgObj.nLevyResNum and pMsgObj.nLevyResNum > 0 then
			-- 	local function func(  )
			-- 		--播放征收建筑高亮
			-- 		self:playLevyedAnim()
			-- 		--播放征收动画
			-- 		local nResId = self.tBuildInfo:getLevyResType()
			-- 		showLevyRes(self, nResId, pMsgObj.nResFlyNum)
			-- 		--播放征收音效(默认播放音乐)
			-- 		if bPlayMusic == nil or bPlayMusic == true then
			-- 			--播放动画字段
			-- 			if nResId == e_type_resdata.coin then
			-- 				--播放音效
			-- 			    Sounds.playEffect(Sounds.Effect.yinbi)
			-- 			elseif nResId == e_type_resdata.wood then
			-- 				--播放音效
			-- 			    Sounds.playEffect(Sounds.Effect.mutou)
			-- 			elseif nResId == e_type_resdata.food then
			-- 				--播放音效
			-- 			    Sounds.playEffect(Sounds.Effect.liangcao)
			-- 			elseif nResId == e_type_resdata.iron then
			-- 				--播放音效
			-- 			    Sounds.playEffect(Sounds.Effect.tiekuang)
			-- 			end
			-- 		end
			-- 		--播放跳字动画
			-- 		local pLayArm = showNumJump(pMsgObj.nLevyResNum)
			-- 		if pLayArm then
			-- 			self:addView(pLayArm, 99)
			-- 			local pSize = self:getContentSize()
			-- 			pLayArm:setPosition(pSize.width/2, pSize.height/2)
			-- 		end
			-- 	end
			-- 	if pMsgObj.nDelayAnimTime == 0 then
			-- 		func()
			-- 	else
			-- 		doDelayForSomething(self, func, pMsgObj.nDelayAnimTime)
			-- 	end
			-- end
		end
	end
	
end

--文官刷新
function BuildGroup:refreshPalaceOffical( sMsgName, pMsgObj )
	-- body
	--刷新状态
	if self.tBuildInfo.sTid == e_build_ids.palace then --王宫
		self:updateBubbleState()
	end
end

--科技刷新
function BuildGroup:refreshTnolyDatas( sMsgName, pMsgObj )
	-- body
	--刷新状态
	if self.tBuildInfo.sTid == e_build_ids.tnoly then --科技园
		self:updateViews()
	end
end

--募兵刷新
function BuildGroup:refreshRecuitDatas( sMsgName, pMsgObj )
	-- body
	if pMsgObj then
		local nBuildId = pMsgObj.nBuildId
		if nBuildId and self.tBuildInfo and self.tBuildInfo.sTid == nBuildId then
			self:updateViews()
		end
	end
end

--打造装备刷新
function BuildGroup:refreshEquipMake()
	if self.tBuildInfo.nCellIndex == e_build_cell.tjp then
		self:updateViews()
	end
end

--工坊数据刷新
function BuildGroup:refreshAtelierDatas()
	if self.tBuildInfo.nCellIndex == e_build_cell.atelier then
		self:updateViews()
	end
end

--研究员数据刷新
function BuildGroup:refreshResercherDatas()
	if self.tBuildInfo.nCellIndex == e_build_cell.tnoly then
		self:updateViews()
	end
end

--翻牌CD变化刷新
function BuildGroup:refreshFlipCardDatas()
	-- body
	if self.tBuildInfo.nCellIndex == e_build_cell.jbp then
		self:updateBubbleState()
	end
end

-- 拜将台免费招募次数刷新
function BuildGroup:refreshBuyHeroDatas()
	-- body
	if self.tBuildInfo.nCellIndex == e_build_cell.bjt then
		self:updateBubbleState()
	end
end

--洗炼铺免费洗炼次数刷新
function BuildGroup:refreshRefineTimeDatas()
	-- body
	if self.tBuildInfo.nCellIndex == e_build_cell.ylp then
		self:updateBubbleState()
	end
end

--城门是否可增加城防军
function BuildGroup:refreshGateDatas()
	-- body
	if self.tBuildInfo.nCellIndex == e_build_cell.gate then
		self:updateBubbleState()
	end
end

--统帅府刷新
function BuildGroup:refreshTSFDatas()
	-- body
	if self.tBuildInfo.nCellIndex == e_build_cell.tcf then
		self:updateBubbleState()
	end
end

function BuildGroup:refreshArenaData( )
	-- body
	if self.tBuildInfo.nCellIndex == e_build_cell.arena then
		self:updateBubbleState()
	end	
end

--仓库资源兑换次数刷新
function BuildGroup:refreshResChangeData( )
	-- body
	if self.tBuildInfo.nCellIndex == e_build_cell.store then
		self:updateBubbleState()
	end	
end

--战争大厅数据刷新
function BuildGroup:refreshWarHallChangeData( )	
	if self.tBuildInfo.nCellIndex == e_build_cell.warhall then
		self:updateBubbleState()
	end	
end

--城内建筑解锁
function BuildGroup:refreshUnLock( sMsgName, pMsgObj)
	if self.tBuildInfo then
		if self.tBuildInfo.sTid == pMsgObj then
			self:updateViews()
		end
	end
end

--建筑播放增收加亮特效
function BuildGroup:playLevyedAnim(  )
	if not self.tShowData then
		return
	end
	if not self.pImgBuild then
		return
	end
	local nTag = 201708021754
	local pImgLBuild = self.pImgBuild:getChildByTag(nTag)
	if not pImgLBuild then
		pImgLBuild = MUI.MImage.new(self.tShowData.img)
		self.pImgBuild:setScale(self.tShowData.fGroupScale)
		local fX = pImgLBuild:getContentSize().width/2
		local fY = pImgLBuild:getContentSize().height/2
		pImgLBuild:setPosition(fX, fY)
		pImgLBuild:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pImgBuild:addChild(pImgLBuild)
		pImgLBuild:setTag(nTag)
	end

	--时间      透明度       
	--0秒        0%
	--0.33秒     25%
	--1秒        0%
	pImgLBuild:stopAllActions()
	pImgLBuild:setOpacity(0)
	local pSeqAct = cc.Sequence:create({
			cc.FadeTo:create(0.33, 0.25 * 255),
			cc.FadeOut:create(1),
    	})
	pImgLBuild:runAction(pSeqAct)
end

function BuildGroup:updateBuildImg( _bLocked )
	-- body
	local bLocked = _bLocked or false
	if bLocked and self.tBuildInfo.sTid == e_build_ids.atelier then--工坊
		--工坊补充
		if not self.pImgAtelier then
			self.pImgAtelier = MUI.MImage.new("#zjm_wkq_jztp_001.png")
			self:addView(self.pImgAtelier, 11)
			self.pImgAtelier:setOpacity(255*0.8)
			centerInView(self, self.pImgAtelier)
		end
	else
		if self.pImgAtelier then
			self.pImgAtelier:removeSelf()
			self.pImgAtelier = nil
		end
	end	
end

function BuildGroup:isCanRecruit(  )
	-- body

	local tFreeQue=self.tBuildInfo:getFreeTeams(2)	
	local nArmy = 0
	local nCpy = self.tBuildInfo.nCpy
		--兵力已满判断
	if self.tBuildInfo.sTid == e_build_ids.infantry then   --步兵
		nArmy = Player:getPlayerInfo().nInfantry
	elseif self.tBuildInfo.sTid == e_build_ids.sowar then  --骑兵
		nArmy = Player:getPlayerInfo().nSowar
	elseif self.tBuildInfo.sTid == e_build_ids.archer then --弓兵
		nArmy = Player:getPlayerInfo().nArcher
	end	
	--dump(self.tBuildInfo, "self.tBuildInfo", 100)
	if tFreeQue and #tFreeQue > 0 and nArmy < nCpy and self.tBuildInfo.nState ~= e_build_state.uping then
		return true
	end
	return false

end

--统帅府是否有御兵术可激活
function BuildGroup:isTSFCanActivate()
	-- body
	return self.tBuildInfo:isShowActivate()
end

--是否显示御兵术升级气泡
function BuildGroup:isTroopCanLvUp()
	-- body
	return self.tBuildInfo:isTroopCanLvUp()
end

--竞技场挑战
function BuildGroup:isCanArenaChallenge()
	-- body
	local bCan = false
	if self.tBuildInfo.sTid == e_build_ids.arena then   --步兵	
		local pData = Player:getArenaData()
		if pData then
			local isSetted = pData:isHaveSetArenaLineUp()
			if isSetted then--已经设置了竞技场阵容
				bCan = pData:isCanArenaChallenge()
			else--
				bCan = true
			end							
		end		
	end
	return bCan	
end

--是否有资源兑换次数
function BuildGroup:isCanChangeResource()
	local bOpen = getIsReachOpenCon(27, false)
	if bOpen then
		local nCnt = Player:getShopData():getResChangeLeftCnt()
		if nCnt > 0 then
			return true
		end
	end
	return false
end


return BuildGroup