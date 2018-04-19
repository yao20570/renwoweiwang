----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-03-22 14:49:05
-- Description: 世界地图
-----------------------------------------------------
local WarLine =  require("app.layer.world.WarLine")
local WorldMapBg = require("app.layer.world.WorldMapBg")
local DecorateDot = require("app.layer.world.DecorateDot")
local CityDot = require("app.layer.world.CityDot")
local SysCityDot = require("app.layer.world.SysCityDot")
local ResDot = require("app.layer.world.ResDot")
local WildArmyDot = require("app.layer.world.WildArmyDot")
local BossDot = require("app.layer.world.BossDot")
local TLBossDot = require("app.layer.world.TLBossDot")
local ImperialCityDot = require("app.layer.world.ImperialCityDot")
local FireTownDot = require("app.layer.world.FireTownDot")
local CityClickLayer = require("app.layer.world.CityClickLayer")
local GhostdomDot = require("app.layer.world.GhostdomDot")
local ZhouTrialDot = require("app.layer.world.ZhouTrialDot")
--层次
local nBgZorder = 1 --地表层
local nBgBorderZorder = 2 --红色边框层
local nImperialBorderZorder = 3 --阿房宫势力层
local nDecorateZorder = 4 --地表装饰层
local nSysCityNoCtrlZorder = 5 --系统城池不可动区域
local nBlockBorder = 9 --区域框
local nGridLightZorder = 9 --格子亮框
local nCityZorder = 10 --城池
local nWAFightZorder = 11 --乱军战斗动画层
local nLineZorder = 12 --线路
local nCitySysCityUiZorder = 13 --系统城池上的浮标
local nClickLayerBgZorder = 14 --点击层背景
local nClickLayerZorder = 15 --点击层
local nTLBossNoCtrlZorder = 5

local nImperialCityMapId = 1013 --皇城mapId
local nGridNum = 20 --皇城小区域格子数

--惯性滚动系数
local bIsInertia = false
local nFriction = 0.05

--znf测试全局
WorldLayerObj = nil

--[[
大地图菱形(不怎么标准，自己想像)
	  1，500
	  /\
	 /  \
1，1/    \500，500
    \    /
	 \  /
	  \/
	  500，1

方向,1,1为原点开始
/:dotX
\:dotY
--]]

--世界地图上下部分
local WORLD_TOP_HEGITH = nil
local WORLD_BOTTOM_HEIGHT = nil
local WORLD_BOTTOM_RECT = nil
local WORLD_TOP_RECT = nil
local WORLD_BG_HEIGHT_EX = nil--世界地图的高扩展

--世界地图类
local WorldLayer = class("WorldLayer",function ( pSize, pParent ,nBottomH, nTopH)
	--设置通用数据
	WORLD_TOP_HEGITH = nTopH
	WORLD_BOTTOM_HEIGHT = nBottomH + 180
	WORLD_BOTTOM_RECT = cc.rect(0, 0, WORLD_BG_WIDTH, WORLD_BOTTOM_HEIGHT)
	WORLD_TOP_RECT = cc.rect(0, WORLD_BOTTOM_RECT.height, WORLD_BG_WIDTH, WORLD_TOP_HEGITH)
	WORLD_BG_HEIGHT_EX = WORLD_BG_HEIGHT + WORLD_BOTTOM_HEIGHT + WORLD_TOP_HEGITH
	--实例化对像
	local pView = MUI.MScrollLayer.new({viewRect=cc.rect(0, 0, pSize.width, pSize.height),
    touchOnContent = false,
    direction=MUI.MScrollLayer.DIRECTION_BOTH,
    bothSize=cc.size(WORLD_BG_WIDTH, WORLD_BG_HEIGHT_EX),
    speed = {x = 0.01, y = 0.01},
    })
    pView:setBounceable(false)
    -- pView:setMultiTouch(true)
    return pView
end)

function WorldLayer:ctor( pSize, pTarget)
	WorldLayerObj = self
	self.pWorldPanel = pTarget
	self.nPrevCheckBlockId = 0
	--初始化
	self:myInit()

	--是否开启远近视角
	if b_open_far_and_near_view_forworld then
		--设置使用相机标志
		self:setUseMyCameraType(MUI.CAMERA_FLAG.USER1)
	end
	
	--监听onEnter和onExit
	self:addNodeEventListener(cc.NODE_EVENT, function(event)
        if event.name == "enter" then
            self:onEnter()
        elseif event.name == "exit" then
            self:onExit()
        end
    end)

 	-- 临时GM命令更改武将基本属性，只能在刘黄玮的服测
	-- local function onWorldTempBaseDataFunc( _, __msg)
	-- 	dump(__msg)
	-- end
	-- SocketManager:sendMsg("reqWorldTempBaseData", {"*nb 2"}, handler(self, onWorldTempBaseDataFunc),-1)	
end

function WorldLayer:resMsgs(  )
	--视图点消失
	-- regMsg(self, gud_world_dot_disappear_msg, handler(self, self.onDotDispear))
	--视图点改变
	-- regMsg(self, gud_world_dot_change_msg, handler(self, self.onDotRefresh))
	--搜索视图点
	regMsg(self, gud_world_search_around_msg, handler(self, self.onSearchAroundMsg))
	--跳转视点图坐标
	-- regMsg(self, ghd_world_location_mappos_msg, handler(self, self.onLocationMapPosMsg))
	--跳转世界坐标
	-- regMsg(self, ghd_world_location_dotpos_msg, handler(self, self.onLocationDotPosMsg))
	--我的城池坐标发生改变
	regMsg(self, gud_world_my_city_pos_change_msg, handler(self, self.onMigrateMsg))
	--隐藏城市点击层
	regMsg(self, ghd_world_hide_city_click_msg, handler(self, self.hideCityClickLayer))
	--定位自己城池附近的某个视图点
	-- regMsg(self, ghd_world_dot_near_my_city, handler(self, self.onLocationDotFinger))
	--新手定位隐藏手指
	regMsg(self, ghd_guide_finger_show_or_hide, handler(self, self.hideDotFinger))
	--视图点进击特效
	regMsg(self, ghd_world_dot_attack_effect, handler(self, self.updateAtkEffects))
	--乱军显示底座特效
	regMsg(self, ghd_wildarmy_circle_effect, handler(self, self.updateWildArmyCirEffect))
	--显示或隐藏系统城池ui
	regMsg(self, ghd_show_or_hide_syscity_dot_ui, handler(self, self.updateSysCityUiVisible))
	--显示或隐藏玩家城池ui
	regMsg(self, ghd_show_or_hide_city_dot_ui, handler(self, self.updateCityUiVisible))
	--更新我势力国战列表（会影响系统城池Ui)
	regMsg(self, gud_my_country_war_list_change, handler(self, self.updateCountryWar))
	--更新势力背景
	regMsg(self, gud_block_city_occupy_change_push_msg, handler(self, self.refreshImperialBorder))
	--更新势力背景
	regMsg(self, gud_world_block_dots_msg, handler(self, self.refreshImperialBorder))

	--我的城池数据发生改变
	regMsg(self, ghd_rename_success_msg, handler(self, self.onMyCityChange))
	regMsg(self, ghd_refresh_palace_lv_msg, handler(self, self.onMyCityChange))
	regMsg(self, ghd_refresh_playerinfo_country, handler(self, self.onMyCityChange))
	regMsg(self, gud_buff_update_msg, handler(self, self.updateMyProtectCd))
	regMsg(self, gud_world_my_callinfo_refresh, handler(self, self.udpateMyCallInfo))

	--重连城功
	regMsg(self, gud_reconnect_success, handler(self, self.onReconnectSuccess))

	--可击杀最高乱军等级
	regMsg(self, ghd_can_kill_wildarmy_lv_change, handler(self, self.onCanKillWildArmy))

	--世界Boss离开
	regMsg(self, ghd_world_boss_leave, handler(self, self.onBossLeaveUpdate))
    
    --世界纣王试炼离开
	regMsg(self, ghd_world_kingzhou_leave, handler(self, self.onKingzhouLeaveUpdate))

	--世界乱军战斗
	regMsg(self, gud_play_wild_army_fight, handler(self, self.playWildArmyFight))

	--限时Boss数据进行变动
	regMsg(self, gud_tlboss_data_refresh, handler(self, self.updateTLBoss))

	--进入前台数据进行刷新
	regMsg(self, ghd_real_enter_foreground, handler(self, self.updateTLBossHp))

	--世界战斗结束消息
	-- regMsg(self, ghd_battle_result, handler(self, self.showCountryWarResultTx))

	--监听TLBoss振屏
	regMsg(self, ghd_show_tlboss_shake, handler(self, self.onTLBossShake))

	regMsg(self, ghd_show_tlboss_atk_name, handler(self, self.onTLBossAtkName))

	regMsg(self, ghd_show_tlboss_hurt_num, handler(self, self.onTLBossHurt))

	regMsg(self, gud_tlboss_world_pos_refersh, handler(self, self.refreshItemDots))

	regMsg(self, ghd_show_tlboss_finger, handler(self, self.onTLBossFinger))

	regMsg(self, ghd_imperialwar_open_state, handler(self, self.onImperWarOpen))

	regMsg(self, ghd_hide_world_tlboss, handler(self, self.onHideTLBoss))
end

function WorldLayer:resMsgsFirst( )
	--跳转视点图坐标
	regMsg(self, ghd_world_location_mappos_msg, handler(self, self.onLocationMapPosMsg))
	--跳转世界坐标
	regMsg(self, ghd_world_location_dotpos_msg, handler(self, self.onLocationDotPosMsg))
	--定位自己城池附近的某个视图点
	regMsg(self, ghd_world_dot_near_my_city, handler(self, self.onLocationDotFinger))
	--跳转我主城位置
	regMsg(self, ghd_world_locaction_my_city_msg, handler(self, self.onLocationMyPosMsg))
	--跳转世界坐标
	regMsg(self, ghd_world_location_dotpos_gm_msg, handler(self, self.onLocationDotPosMsgGM))
end

function WorldLayer:unregMsgs(  )
	--视图点消失
	-- unregMsg(self, gud_world_dot_disappear_msg)
	--视图点改变
	-- unregMsg(self, gud_world_dot_change_msg)
	--搜索视图点
	unregMsg(self, gud_world_search_around_msg)
	--跳转视点图坐标
	unregMsg(self, ghd_world_location_mappos_msg)
	--跳转世界坐标
	unregMsg(self, ghd_world_location_dotpos_msg)
	--我的城池坐标发生改变
	unregMsg(self, gud_world_my_city_pos_change_msg)
	--跳转我主城位置
	unregMsg(self, ghd_world_locaction_my_city_msg)
	--隐藏城市点击层
	unregMsg(self, ghd_world_hide_city_click_msg)
	--定位自己城池附近的某个视图点
	unregMsg(self, ghd_world_dot_near_my_city)
	--新手定位隐藏手指
	unregMsg(self, ghd_guide_finger_show_or_hide)
	--视图点进击特效
	unregMsg(self, ghd_world_dot_attack_effect)
	--乱军显示底座特效
	unregMsg(self, ghd_wildarmy_circle_effect)
	--显示或隐藏系统城池ui
	unregMsg(self, ghd_show_or_hide_syscity_dot_ui)
	--显示或隐藏玩家城池ui
	unregMsg(self, ghd_show_or_hide_city_dot_ui)
	--更新我势力国战列表（会影响系统城池Ui)
	unregMsg(self, gud_my_country_war_list_change)
	--更新势力背景
	unregMsg(self, gud_block_city_occupy_change_push_msg)
	--更新势力背景
	unregMsg(self, gud_world_block_dots_msg)
	--我的城池数据发生改变
	unregMsg(self, ghd_rename_success_msg)
	unregMsg(self, ghd_refresh_palace_lv_msg)
	unregMsg(self, ghd_refresh_playerinfo_country)
	unregMsg(self, gud_buff_update_msg)
	unregMsg(self, gud_world_my_callinfo_refresh)

	--重连成功
	unregMsg(self, gud_reconnect_success)
	
	--可击杀最高乱军等级
	unregMsg(self, ghd_can_kill_wildarmy_lv_change)

	--世界Boss离开
	unregMsg(self, ghd_world_boss_leave)
	--纣王试炼离开
	unregMsg(self, ghd_world_kingzhou_leave)

	--世界乱军战斗
	unregMsg(self, gud_play_wild_army_fight)
	--世界战斗结束消息
	-- unregMsg(self, ghd_battle_result)
	--跳转世界坐标
	unregMsg(self, ghd_world_location_dotpos_gm_msg)
	--限时Boss数据
	unregMsg(self, gud_tlboss_data_refresh)
	--注销TLBoss振屏
	unregMsg(self, ghd_show_tlboss_shake)

	unregMsg(self, ghd_show_tlboss_atk_name)

	unregMsg(self, ghd_show_tlboss_hurt_num)

	unregMsg(self, ghd_show_tlboss_finger)

	unregMsg(self, gud_tlboss_world_pos_refersh)

	unregMsg(self, ghd_real_enter_foreground)

	unregMsg(self, ghd_imperialwar_open_state)

	unregMsg(self, ghd_hide_world_tlboss)
end

--初始化函数
function WorldLayer:myInit(  )
	self.t9WorldMapsUn 			= 	nil 			--9张草皮(没铺到正确位置上的)
	self.tWorldMaps 			= 	{} 				--已经在正确位置上的草皮
	self.pBatchNodeMap 			=   nil 			--批量渲染（草皮）
	self.tWorldEdgesUn 			= 	nil 			--世界边缘地皮未使用
	self.tWorldEdges   			=   {} 				--已经在正确位置上的边缘草皮
	self.pBatchNodeEdge 		= 	nil 			--批量渲染（边缘草皮）
	self.tItemDotsUn 			= 	nil 			--未使用的视图点item(可以使用的item)
	self.tItemDots 				= 	{} 				--已经在正确位置上的视图点item

	--地图viewGroup  
	self.pMapViewGroup 			= 	nil 

	--根据地图大小和草皮大小计算出最大的行跟列
	self.nMaxMapRow 			= 	math.ceil(WORLD_BG_WIDTH / IMAGE_MAP_WIDTH) + 1
	self.nMaxMapCol 			= 	math.ceil(WORLD_BG_HEIGHT / IMAGE_MAP_HEIGHT) + 1

	--视图左下角在滚动内容层的坐标
	self.fViewX = 0
	self.fViewY = 0
	--视图中心点在滚动内容层的坐标
	self.fViewCX = 0
	self.fViewCY = 0

	--地图可视范围的宽和高
	local pSize = self:getContentSize()
	self.nCanSeeWidth =	pSize.width
	self.nCanSeeHeight = pSize.height

	--地图可视范围的小格子的行列的最大数
	-- self.nCanSeeUnitOffset = math.max(math.ceil(self.nCanSeeWidth/UNIT_WIDTH),math.ceil(self.nCanSeeHeight/UNIT_HEIGHT))

	--搜索视图点数据
	self.nSearchX = getWorldInitData("searchX")/2
	self.nSearchY = getWorldInitData("searchY")/2

	--tlboss框size 
	self.tTLBossBorderSize = cc.size(UNIT_WIDTH*3 * 0.75,UNIT_HEIGHT*3 * 0.75)
	--惯性滑动点 
	self.tVecPot = {}

	--初始化玩家自身视图点数据
	self:initMyCityData()
end

function WorldLayer:onEnter(  )
	--控件初始化
	self:setupViews()
	self:updateViews()
	self:resMsgsFirst()

	-- --添加纹理
	-- addTextureToCache("tx/other/sg_sjdt_zdtx_sa", 1, true)
	-- --添加纹理
	-- addTextureToCache("tx/other/sg_sjdt_bhz", 1, true)
end

--析构函数
function WorldLayer:onExit(  )
	if self.nUpdateScheduler then
	    MUI.scheduler.unscheduleGlobal(self.nUpdateScheduler)
	    self.nUpdateScheduler = nil
	end
	if self.nAddcheduler then
		MUI.scheduler.unscheduleGlobal(self.nAddcheduler)
	    self.nAddcheduler = nil
	end
	self:unregMsgs()

	-- --移除纹理
	-- removeTextureFromCache("tx/other/sg_sjdt_zdtx_sa")
	-- --移除纹理
	-- removeTextureFromCache("tx/other/sg_sjdt_bhz")	
end

--初始化玩家自身视图点的数据
function WorldLayer:initMyCityData(  )
	local nX, nY = Player:getWorldData():getMyCityDotPos()
	--我的地图位置
	self.fMyPosX, self.fMyPosY = self:getMapPosByDotPos(nX, nY)
	-- WORLD_BOTTOM_HEIGHT修正
	self.fMyPosY = self.fMyPosY + WORLD_BOTTOM_HEIGHT
end

--视图初始化
function WorldLayer:setupViews(  )
	--创建滚动层
	local pScrollView = MUI.MLayer.new()
	pScrollView:setContentSize(cc.size(WORLD_BG_WIDTH, WORLD_BG_HEIGHT_EX))
	self.pScrollView = pScrollView
	self:addView(pScrollView)
	--设置点击需要音效
	self:setNeedClickSound(true)

	--创建地图层
	self.pMapViewGroup = MUI.MLayer.new()
	self.pMapViewGroup:setContentSize(cc.size(WORLD_BG_WIDTH, WORLD_BG_HEIGHT))
	self.pMapViewGroup:setPositionY(WORLD_BOTTOM_HEIGHT)
	pScrollView:addView(self.pMapViewGroup)

	--创建地表层
	self.pMapBgGroup = MUI.MLayer.new()
	self.pMapBgGroup:setContentSize(cc.size(WORLD_BG_WIDTH, WORLD_BG_HEIGHT))
	self.pMapViewGroup:addView(self.pMapBgGroup, nBgZorder)

	--创建地图边框层
	self.pMapBorderGroup = MUI.MLayer.new()
	self.pMapBorderGroup:setContentSize(cc.size(WORLD_BG_WIDTH, WORLD_BG_HEIGHT))
	self.pMapViewGroup:addView(self.pMapBorderGroup, nBgBorderZorder)

	-- 创建地图阿房宫边框层
	self.pImperialBorderGroup = MUI.MLayer.new()
	self.pImperialBorderGroup:setContentSize(cc.size(WORLD_BG_WIDTH, WORLD_BG_HEIGHT))
	self.pMapViewGroup:addView(self.pImperialBorderGroup, nImperialBorderZorder)

	--创建地表装饰层
	self.pMapDecorateGroup = MUI.MLayer.new()
	self.pMapDecorateGroup:setContentSize(cc.size(WORLD_BG_WIDTH, WORLD_BG_HEIGHT))
	self.pMapViewGroup:addView(self.pMapDecorateGroup, nDecorateZorder)

	--创建地图视图点层
	self.pMapDotGroup = MUI.MLayer.new()
	self.pMapDotGroup:setContentSize(cc.size(WORLD_BG_WIDTH, WORLD_BG_HEIGHT))
	self.pMapViewGroup:addView(self.pMapDotGroup, nCityZorder)

	--创建地图视图点层
	self.pWAFightGroup = MUI.MLayer.new()
	self.pWAFightGroup:setContentSize(cc.size(WORLD_BG_WIDTH, WORLD_BG_HEIGHT))
	self.pMapViewGroup:addView(self.pWAFightGroup, nWAFightZorder)

	--创建路线层
	self.pWarLine = WarLine.new(self.pMapViewGroup:getContentSize(), self)
	self.pMapViewGroup:addView(self.pWarLine, nLineZorder)

	--创建乱军动画层
	self.tWAFightKeys = {}
	self.tWAFightLay = {}
	self.tWAFightUis = {}

	--箭头
	self.pArrowImg = Player:getUIHomeLayer():getArrowImg()
	self.pLyArrowImg = Player:getUIHomeLayer():getLyArrowImg()
	self.pArrowImg:onMViewClicked(function ( )
		local nX, nY = Player:getWorldData():getMyCityDotPos()
		local fX, fY = WorldFunc.getMapPosByDotPos( nX, nY )
		if not fX then
			return
		end
		self:jumpToPosAndClick(fX, fY, true)
	end)

	--初始化9张草皮
	self:init9WorldMap()
	--初始化装饰层
	self:initDecorateDots()
	--初始化系统城池
	self:initSysCityDots()
	--初始化玩家城池
	self:initCityDots()
	--初始化资源城池
	self:initResDots()
	--实始化乱军城池
	self:initWildArmyDots()
	--实始化Boss
	self:initBossDots()
	--初始化限时Boss
	self:initTLBossDots()
	--初始化点击特效
	self:initClickEffect()
	--初始化区域边框
	self:initBlockBorder()
	--初始化阿房宫区域边框
	self:initImperialBorder()
	--初始化幽魂
	self:initGhostdomDots()
	--初始化纣王试炼
	self:initZhouTrialBossDots()		
	--self:initDebugDraw()
	--滚动层
	self:onScroll(function ( event )
		-- dump(event)
		local pScrollView = event.scrollView
		local sEvent = event.name
		local nX = event.x
		local nY = event.y
		local nOriginX = event.originX
		local nOriginY = event.originY
		if sEvent == "began" then
			--惯性滑动
			if bIsInertia then
				self.tVecPot = {}
				transition.stopTarget(self.scrollNode)
			end
		elseif sEvent == "moved" then
			self:hideCityClickLayer()
			local bTrue = self:isPointInLingXing(nOriginX, nOriginY)
			if not bTrue  then
				myprint("moved 到尽头了")
			end

			--惯性滑动
			if bIsInertia then
				table.insert(self.tVecPot,cc.p(nOriginX,nOriginY))
			end
			--移动中请求
			self.nDelayClickPos = nil
			self.tDelayOther = nil
			-- self:searchDotReq(true)
			--重置引导时间
			N_LAST_CLICK_TIME = getSystemTime()
		elseif sEvent == "ended" then
			-- myprint("ended")
			--惯性滑动
			if bIsInertia then
				local nVecSize = #self.tVecPot 
				if nVecSize >= 2 then
					local fXspeed = self.tVecPot[nVecSize].x - self.tVecPot[nVecSize - 1].x
					local fYspeed = self.tVecPot[nVecSize].y - self.tVecPot[nVecSize - 1].y
					transition.moveBy(self.scrollNode,
					{x = fXspeed, y = fYspeed, time = 0.8,
					easing = "sineOut",
					onComplete = function()
						self:doScrollEnd()
					end})
				end
			end
		elseif sEvent == "scrollEnd" then
			-- myprint("scrollEnd")
			self:doScrollEnd()
			--重置引导时间
			N_LAST_CLICK_TIME = getSystemTime()
		elseif sEvent == "clicked" then
			
			--原版self:onWorldClicked(nX, nY)
			if b_open_far_and_near_view_forworld then
				--坐标系啊，原点是左上角
				local location = cc.p(event.screenX, display.height - event.screenY)

				local nearP = cc.vec3(location.x, location.y, -1.0)
	            local farP  = cc.vec3(location.x, location.y, 1.0)
	            
	            local size = cc.Director:getInstance():getWinSize()
	            nearP = self._camera:unproject(size, nearP, nearP)
	            farP  = self._camera:unproject(size, farP, farP)
	                            
	            local a_segmentPointA = nearP
	            local a_segmentPointB = farP
	            local a_planePos = vec3Minus(cc.vec3(WORLD_BG_WIDTH, WORLD_BG_HEIGHT, 0), cc.vec3(0, 0, 0))
	            local a_planeNormal = cc.vec3(0, 0, -1)
	            local bIsCllision, pCllision = cIntersectionSegmentPlane( a_segmentPointA, a_segmentPointB, a_planePos, a_planeNormal)
	            -- print("bIsCllision, pCllision",bIsCllision)
	            -- dump(pCllision,"pCllision",100)
	            if bIsCllision then
	            	local nNewX = self:getScrollNode():getPositionX() 
				    local nNewY = self:getScrollNode():getPositionY() + WORLD_BOTTOM_HEIGHT --位置,不知道为毛+WORLD_BOTTOM_HEIGHT才对
				    nNewX = pCllision.x + (nNewX * -1)
					nNewY = pCllision.y + (nNewY * -1)
					self:onWorldClicked(nNewX, nNewY)
	            end
			else
				-- WORLD_BOTTOM_HEIGHT修正
				nY = nY - WORLD_BOTTOM_HEIGHT
				self:onWorldClicked(nX, nY)
			end
			
			--重置引导时间
			N_LAST_CLICK_TIME = getSystemTime()
		end
	end)
end

--国战胜利失败特效
function WorldLayer:showCountryWarResultTx(sMsgName, pMsgObj)
	-- body
	if not pMsgObj.tMailData or not pMsgObj.tMailMsg then return end
	--只有国战才显示特效
	if pMsgObj.tMailData.template ~= e_type_mail_report.countryWar then
		return
	end
	local tMailMsg = pMsgObj.tMailMsg
	--是否胜利
	local bWin = tMailMsg.nResult == 1
	local pJson  		--动画资源
	local sChangeImg 	--需要换的图片
	local sBoneName 	--被替换的骨骼图片
	if bWin then
		pJson = "sg_sjdt_slbx_a_01"
		sChangeImg = "#sg_sjdt_sl2bx_a_01y_03.png"
		sBoneName = "sjthsl001"
	-- else
	-- 	pJson = "sg_sjdt_sbbx_a_01"
	-- 	sChangeImg = "#sg_sjdt_sbbx_a2_x_1.png"
	-- 	sBoneName = "sjsbth001"
	-- end
		--替换图片
		local sName = createAnimationBackName("tx/exportjson/", pJson)
	    if tolua.isnull(self.pResultArm) then
		    self.pResultArm = ccs.Armature:create(sName)
			--替换骨骼
			local pImg = changeBoneWithPngAndScale(self.pResultArm,sBoneName,sChangeImg,false,cc.p(0.5,0.5))
		   	self.pMapViewGroup:addChild(self.pResultArm, nCityZorder)
		   	WorldFunc.setHighCameraMaskForView( self.pResultArm )
		    self.pResultArm:getAnimation():setMovementEventCallFunc(function ( arm, eventType, movmentID )
				if (eventType == MovementEventType.COMPLETE) then
					self.pResultArm:removeSelf()
				end
			end)
		end
		--获取城池坐标
		local tViewDotMsg = Player:getWorldData():getViewDotMsg(tMailMsg.nDefX, tMailMsg.nDefY)
		if not tViewDotMsg then return end
		local posX, posY = tViewDotMsg:getWorldMapPos()
		posY = posY + 100
		self.pResultArm:setPosition(posX, posY)
		local pSeq = cc.Sequence:create(
			{
				cc.DelayTime:create(0.5),
				cc.MoveTo:create(0.6, cc.p(posX, posY + 4)),
				cc.MoveTo:create(0.6, cc.p(posX, posY))
			}
		)
		self.pResultArm:getAnimation():play("Animation1", 1)
		self.pResultArm:runAction(pSeq)
	end
end

--点击世界
--fX,fY 世界坐标
function WorldLayer:onWorldClicked(fX, fY )
	--点击了系统城池ui
	if self:checkIsClickSysCityUis(fX, fY) then
		return
	end
	--点击了玩家城池ui
	if self:checkIsClickCityUis(fX, fY) then
		return
	end
	--点击了BossUi
	if self:checkIsClickBossUis(fX, fY) then
		return
	end
	--点到到地图
	self:clickScrollTo(fX, fY)
end

--测试方法
function WorldLayer:initDebugDraw( )
	if not self.pLayDebugDraw then
		local pLayDebugDraw = MUI.MLayer.new()
		pLayDebugDraw:setContentSize(cc.size(WORLD_BG_WIDTH, WORLD_BG_HEIGHT))
		pLayDebugDraw:setLayoutSize(WORLD_BG_WIDTH, WORLD_BG_HEIGHT)
		pLayDebugDraw:setPositionY(WORLD_BOTTOM_HEIGHT)
		self.pLayDebugDraw = pLayDebugDraw
		self.pScrollView:addView(self.pLayDebugDraw, 999)
	end

-- 	--最左边点
-- 	local nX, nY = 0, WORLD_BG_HEIGHT/2
-- 	local tPoint = {
-- 		{nX-10,  nY-10},
-- 		{nX+10,  nY-10},
-- 		{nX+10,  nY+10},
-- 		{nX-10,  nY+10},
-- 	}

-- 	local tColor = {fillColor = cc.c4f(171/255,151/255,95/255,0),
--     borderWidth  = 1,
--     borderColor  = cc.c4f(1,0,0,179/255)} 

-- 	local pNodeViewRect =  display.newPolygon(tPoint,tColor)
-- 	self.pLayDebugDraw:addView(pNodeViewRect, 999)

-- 	--画线
-- 	local nOriginX = 0
-- 	local nOriginY = WORLD_BG_HEIGHT/2
-- 	for i=1,100 do
-- 		-- local drawNode = cc.DrawNode:create()
-- 		local pPoint = {nOriginX, nOriginY}
-- 		local pPoint2 = {nOriginX + UNIT_WIDTH/2 * 100 , nOriginY + UNIT_HEIGHT/2 * 100}
-- 	    -- drawNode:drawSegment(pPoint, pPoint2, 0.5, cc.c4f(1,0,0,179/255))
-- 	    local drawNode = display.newLine({pPoint, pPoint2}, {fillColor = cc.c4f(1,0,0,179/255), borderWidth = 1, borderColor = cc.c4f(1,0,0,179/255)})
-- 	    self.pLayDebugDraw:addView(drawNode, 999)

-- 	    nOriginX = nOriginX + UNIT_WIDTH/2
-- 	    nOriginY = nOriginY - UNIT_HEIGHT/2
-- 	end

-- 	local nOriginX = 0
-- 	local nOriginY = WORLD_BG_HEIGHT/2
-- 	for i=1,100 do
-- 		-- local drawNode = cc.DrawNode:create()
-- 		local pPoint = {nOriginX, nOriginY}
-- 		local pPoint2 = {nOriginX + UNIT_WIDTH/2 * 100 , nOriginY - UNIT_HEIGHT/2 * 100}
-- 	    -- drawNode:drawSegment(pPoint, pPoint2, 0.5, cc.c4f(1,0,0,179/255))
-- 	    local drawNode = display.newLine({pPoint, pPoint2}, {fillColor = cc.c4f(1,0,0,179/255), borderWidth = 1, borderColor = cc.c4f(1,0,0,179/255)})
-- 	    self.pLayDebugDraw:addView(drawNode, 999)

-- 	    nOriginX = nOriginX + UNIT_WIDTH/2
-- 	    nOriginY = nOriginY + UNIT_HEIGHT/2
-- 	end
-- end

-- function WorldLayer:addDebugPoint( tViewDotMsg )
-- 	if true then
-- 		return
-- 	end
-- 	if not self.pLayDebugDraw then
-- 		local pLayDebugDraw = MUI.MLayer.new()
-- 		pLayDebugDraw:setContentSize(cc.size(WORLD_BG_WIDTH, WORLD_BG_HEIGHT))
-- 		pLayDebugDraw:setPositionY(WORLD_BOTTOM_HEIGHT)
-- 		self.pScrollView:addView(pLayDebugDraw)
-- 		self.pLayDebugDraw = pLayDebugDraw
-- 	end

-- 	local nX, nY = WorldFunc.getMapPosByDotPos(tViewDotMsg.nX, tViewDotMsg.nY)
-- 	local tPoint = {
-- 		{nX-10,  nY-10},
-- 		{nX+10,  nY-10},
-- 		{nX+10,  nY+10},
-- 		{nX-10,  nY+10},
-- 	}

-- 	local tColor = {fillColor = cc.c4f(171/255,151/255,95/255,179/255),
--     borderWidth  = 1,
--     borderColor  = cc.c4f(171/255,151/255,95/255,179/255)} 

-- 	local pNodeViewRect =  display.newPolygon(tPoint,tColor)
-- 	self.pLayDebugDraw:addView(pNodeViewRect, 999)
end

--初始化9张草皮
function WorldLayer:init9WorldMap(  )
	self.t9WorldMapsUn = {}
	for i = 1, 25 do
		local pWorldMap = WorldMapBg.new()
		table.insert(self.t9WorldMapsUn, pWorldMap)
	end
end

--更新视图
function WorldLayer:updateViews(  )
end

--第一次进入逻辑
function WorldLayer:doFirstEnterLogic(  )
	-- 监听消息
	self:resMsgs()
	--更新地表
	self.nUpdateScheduler = MUI.scheduler.scheduleGlobal(function ()
		self:fixScrollNodePos()
		self:refershDots()
	end,0.02)
	--第一次进入要初始化这个
	self:initMyCityData()
	-- 跳转到自己的试图点
	self:JumpToMyCityDot()
end

--跳转到格子
--nDotX, nDotY 格子点
function WorldLayer:JumpToDotPos( nDotX, nDotY )
	self.pLeftDownPos = self:getFixedMapPosByDotPos(nDotX, nDotY)
	self:showViewByLDPos(self.pLeftDownPos.x, self.pLeftDownPos.y, true)
end

--跳转到像素 --znftodo 以后优化
--fX, fY: 像素
function WorldLayer:JumpToMapPos( fX, fY, nMovedFunc )
	if not fX then
		return
	end
	if not fY then
		return
	end

	fX = fX - self.nCanSeeWidth/2
	fY = fY - self.nCanSeeHeight/2 + WORLD_BOTTOM_HEIGHT
	if fX < 0 then
		fX = 0
	end
	if fX > WORLD_BG_WIDTH - self.nCanSeeWidth then
		fX = WORLD_BG_WIDTH - self.nCanSeeWidth
	end
	if fY < 0 then
		fY = 0
	end
	if fY > WORLD_BG_HEIGHT_EX - self.nCanSeeHeight then
		fY = WORLD_BG_HEIGHT_EX - self.nCanSeeHeight
	end
	--刷新视图点信息
	self.pLeftDownPos = cc.p(-fX, -fY)
	self:showViewByLDPos(self.pLeftDownPos.x, self.pLeftDownPos.y, true)
end

--跳转到主城格子
function WorldLayer:JumpToMyCityDot( nFuckX, nFuckY )
	local nX, nY = Player:getWorldData():getMyCityDotPos()
	nX = nFuckX or nX
	nY = nFuckY or nY
	local fX, fY = WorldFunc.getMapPosByDotPos( nX, nY )
	self:jumpToPosAndClick(fX, fY)
end

--点击移动到某个点
--fX, fY 点击格子时世界坐标
--bIsClickEffect：只是点击特效
function WorldLayer:clickScrollTo( fX, fY ,bIsClickEffect)
	--隐藏自己
	self:hideCityClickLayer()

	--点击的格
	local nDotX, nDotY = self:getDotPosByMapPos(fX, fY)
	if nDotX then

		--点击系统城池周围
		local bIsInCity = false
		local nSysCityId = WorldFunc.getSysCityIdInAround(nDotX, nDotY)
		if nSysCityId then
			local tViewDotMsg = Player:getWorldData():getSysCityDot(nSysCityId)
			if tViewDotMsg then
				fX, fY = tViewDotMsg:getWorldMapPos()
				nDotX, nDotY = self:getDotPosByMapPos(fX, fY)
				bIsInCity = true
				if not nDotX then
					return
				end
			end
		end

		--点击TLBoss周围(!!!!!注意这里是写死是3个格子范围)
		local bIsInTLBoss = false
		if not bIsInCity and Player:getTLBossData():getIsShowWorldTLBoss() then
			local tBLocatVos = Player:getTLBossData():getBLocatVos()
			for k, tBLocatVo in pairs(tBLocatVos) do
				local nTLBossX, nTLBossY = tBLocatVo:getX(), tBLocatVo:getY()
				if nDotX >= nTLBossX - 1 and nDotX <= nTLBossX + 1 and
				 nDotY >= nTLBossY - 1 and nDotY <= nTLBossY + 1 then
					nDotX, nDotY = nTLBossX, nTLBossY
					bIsInTLBoss = true
					break
				end
			end
		end
		

		--点击方法回调-----------------------------------------------------------
		local function clickFunc( fX, fY, size )
			--点击特效
			self:showClickEffect(fX, fY, size)
			--是否只是点击播放特效
			if bIsClickEffect then
				return
			end
			--选中的不在配表中的区域就不弹出迁城层
			local tRangeData = WorldFunc.getBlockRangeData(nDotX, nDotY)
			if tRangeData then
				if not tRangeData.nBlockId then
					return
				end
			end

			--点击地图格子
			local tViewDotMsg = Player:getWorldData():getViewDotMsg(nDotX, nDotY)
			if tViewDotMsg then
				if tViewDotMsg.nType == e_type_builddot.sysCity then		
					self:showCityClickLayer(fX, fY, tViewDotMsg)
					return
				elseif tViewDotMsg.nType == e_type_builddot.city then
					self:showCityClickLayer(fX, fY, tViewDotMsg)
					return
				elseif tViewDotMsg.nType == e_type_builddot.res then
					--不选中
					self:hideClickEffect()
					--打开采集面板
					local tObject = {
					    nType = e_dlg_index.collectres, --dlg类型
					    --
					    tViewDotMsg = tViewDotMsg,
					}
					sendMsg(ghd_show_dlg_by_type, tObject)
					return
				elseif tViewDotMsg.nType == e_type_builddot.wildArmy then
					--不选中
					self:hideClickEffect()
					--打开乱军界面
					local tObject = {
					    nType = e_dlg_index.wildarmy, --dlg类型
					    --
					    tViewDotMsg = tViewDotMsg,
					}
					sendMsg(ghd_show_dlg_by_type, tObject)
					return
				elseif tViewDotMsg.nType == e_type_builddot.boss then
					self:showCityClickLayer(fX, fY, tViewDotMsg)
					return
				elseif tViewDotMsg.nType == e_type_builddot.ghostdom then
					
					--不选中
					self:hideClickEffect()
					--打开乱军界面
					local tObject = {
					    nType = e_dlg_index.ghostdomdetail, --dlg类型
					    --
					    tViewDotMsg = tViewDotMsg,
					}
					sendMsg(ghd_show_dlg_by_type, tObject)
					return
				elseif tViewDotMsg.nType == e_type_builddot.zhouwang then
					--不选中
					self:hideCityClickLayer()
				    -- 打开乱军界面
					local tObject = {
					    nType = e_dlg_index.zhouwangtrialdetail, --dlg类型
					    --
					    tViewDotMsg = tViewDotMsg,
					}
					sendMsg(ghd_show_dlg_by_type, tObject)
					return					
				end
			end

			--点中限时Boss
			if bIsInTLBoss then
				local ViewDotMsg = require("app.layer.world.data.ViewDotMsg")
				local tViewDotMsg2 = ViewDotMsg.new({t = e_type_builddot.tlboss, x = nDotX, y = nDotY})
				self:showCityClickLayer(fX, fY, tViewDotMsg2)
				return
			end

			--选中的是装饰物就不那个
			local tDecorateData = getDecorateData(string.format("%s_%s", nDotX, nDotY))
			if tDecorateData then
				TOAST(getConvertedStr(3, 10443))
				return
			end

			--打开迁城面板
			local nBlockId = WorldFunc.getBlockId(nDotX, nDotY)
			local bIsUsedMove = Player:getWorldData():getBlockIsCanMigrate(nBlockId)
			if bIsUsedMove then
				local tNullDotMsg = {
					nX = nDotX,	
					nY = nDotY,
					nType = e_type_builddot.null,
				}
				self:showCityClickLayer(fX, fY, tNullDotMsg)
			end
		end
		--点击方法回调-----------------------------------------------------------

		--滚动-----------------------------------------------------------
		local function doScroll( fX, fY, size )
			local pFixedPos = self:getFixedMapPosByPos(fX, fY)
			local fCurX, fCurY = self.scrollNode:getPosition()
			local fDistance = cc.pGetDistance(cc.p(fCurX, fCurY),pFixedPos)
			local moveTime = 0.3 -- 默认移动时长
			moveTime = math.min(fDistance/UNIT_WIDTH * moveTime, moveTime)
			transition.stopTarget(self.scrollNode)
			transition.moveTo(self.scrollNode,
			{x = pFixedPos.x, y = pFixedPos.y, time = moveTime,
			easing = "sineOut",
			onComplete = function()
				self:doScrollEnd()
				clickFunc(fX, fY, size)
			end})
		end
		--滚动-----------------------------------------------------------

		--是否点击
		local tViewDotMsg = Player:getWorldData():getViewDotMsg(nDotX, nDotY)
		if tViewDotMsg then
			if tViewDotMsg.nType == e_type_builddot.sysCity then
				--移动
				local fX, fY = tViewDotMsg:getWorldMapPos()
				local size = tViewDotMsg:getCityImgSize()
				doScroll(fX, fY, size)
				return
			elseif tViewDotMsg.nType == e_type_builddot.city then
				--移动
				local fX, fY = tViewDotMsg:getWorldMapPos()
				doScroll(fX, fY)
				return
			elseif tViewDotMsg.nType == e_type_builddot.res then
				--移动
				local fX, fY = tViewDotMsg:getWorldMapPos()
				doScroll(fX, fY)
				return
			elseif tViewDotMsg.nType == e_type_builddot.wildArmy then
				--移动
				local fX, fY = tViewDotMsg:getWorldMapPos()
				-- doScroll(fX, fY)
				--直接打开
				clickFunc(fX, fY)

				return
			elseif tViewDotMsg.nType == e_type_builddot.boss then
				--移动
				local fX, fY = tViewDotMsg:getWorldMapPos()
				doScroll(fX, fY)
				return
			elseif tViewDotMsg.nType == e_type_builddot.zhouwang then
                --移动
				local fX, fY = tViewDotMsg:getWorldMapPos()
				doScroll(fX, fY)
				return				
			end
		end

		--点中限时Boss
		if bIsInTLBoss then
			local fX, fY = self:getMapPosByDotPos(nDotX, nDotY)
			doScroll(fX, fY, self.tTLBossBorderSize)
			return
		end

		--空地
		local fMapX, fMapY = self:getMapPosByDotPos(nDotX, nDotY)
		if fMapX then
			--移动
			doScroll(fMapX, fMapY)
		end
	end
end

--更新节点坐标（一帧一个）
function WorldLayer:refershDots(  )
	local tPos = Player:getWorldData():getRefreshDotPos()
	if tPos then
		Player:getWorldData():delRefreshDotPos(tPos.nX, tPos.nY)

		local tViewDotMsg = Player:getWorldData():getViewDotMsg(tPos.nX, tPos.nY)
		if tViewDotMsg then
			self:onDotRefresh(nil, tViewDotMsg)
		else
			local sDotKey = string.format("%s_%s",tPos.nX, tPos.nY)
			self:onDotDispear(nil, sDotKey)
		end
	end
end

--修正滚动节点坐标
function WorldLayer:fixScrollNodePos(  )
	--容错
	if not self.pLeftDownPos then return end
	--滚动的层左下方的位置
	local nOriginX,nOriginY = self.scrollNode:getPosition()
	--像素不同时才进行刷新
	if self.pLeftDownPos.x ~= nOriginX or self.pLeftDownPos.y ~= nOriginY then
		--菱形边界判断
		local bIsNeedJump = false
		local bIsInLingXing = self:isPointInLingXing(nOriginX, nOriginY)
		--在菱形里
		if bIsInLingXing then
			self.pLeftDownPos.x = nOriginX
			self.pLeftDownPos.y = nOriginY
		else--修正位置
			nOriginX = self.pLeftDownPos.x
			nOriginY = self.pLeftDownPos.y
			bIsNeedJump = true
			-- print("滚动中到尽头")
			TOAST(getTipsByIndex(20009), true)
		end
		--刷新视图点信息
		self:showViewByLDPos(nOriginX, nOriginY, bIsNeedJump)
	end
end

--显示左下角为起始点的视图信息
function WorldLayer:showViewByLDPos( fLDX, fLDY, bIsNeedJump)
	--更新视图信息 转变视图在地图的中的坐标（左下角坐标)
	self.fViewX = fLDX * -1
	self.fViewY = fLDY * -1
	self.fViewCX = self.fViewX + self.nCanSeeWidth/2
	self.fViewCY = self.fViewY + self.nCanSeeHeight/2

	--刷新图层
	self:refreshMap()
	self:refreshBlockBorder()
	self:refreshImperialBorder()
	self:refreshPosTips()

	--滚动位置
	if bIsNeedJump then
		transition.stopTarget(self.scrollNode)
		self:scrollTo(fLDX, fLDY) 
		self:doScrollEnd()
	end
end

--获取视图框
function WorldLayer:getShowViewRect(  )
	local pRect = cc.rect(self.fViewX, self.fViewY, self.nCanSeeWidth, self.nCanSeeHeight)
	-- WORLD_BOTTOM_HEIGHT修正
	pRect.y = pRect.y - WORLD_BOTTOM_HEIGHT

	--检测打印
	-- if self.pNodeViewRect then
	-- 	self.pNodeViewRect:removeFromParent(true)
	-- 	self.pNodeViewRect = nil
	-- end
	-- local tPoint = {
	-- 	{pRect.x + pRect.width,  pRect.y},
	-- 	{pRect.x + pRect.width,  pRect.y + pRect.height},
	-- 	{pRect.x,  pRect.y + pRect.height},
	-- 	{pRect.x,  pRect.y},
	-- }
	-- local tColor = {fillColor = cc.c4f(171/255,151/255,95/255,179/255),
 --    borderWidth  = 1,
 --    borderColor  = cc.c4f(171/255,151/255,95/255,179/255)} 

	-- self.pNodeViewRect =  display.newPolygon(tPoint,tColor)
	-- self.pMapViewGroup:addView(self.pNodeViewRect, 999)

	return pRect
end


--获取视图点的框
function WorldLayer:getShowViewDotRect(  )
	local nGridX = math.ceil(self.nCanSeeWidth/UNIT_WIDTH) + 5
	local nGridY = math.ceil(self.nCanSeeHeight/UNIT_HEIGHT) + 5
	local pRect = cc.rect(self.fViewCX, self.fViewCY, nGridX * UNIT_WIDTH, nGridY * UNIT_HEIGHT)
	pRect.x = pRect.x - pRect.width/2
	pRect.y = pRect.y - pRect.height/2 - WORLD_BOTTOM_HEIGHT
	return pRect
end

--地图滚动结束时处理函数
function WorldLayer:doScrollEnd(  )
	-- myprint("doScrollEnd")
	--请求视图点
	local bIsReq = self:searchDotReq()
	if not bIsReq then
		--刷新视图点
		self:refreshItemDots()
	end
end

--坐标是否在菱形里
--x,y：滚动内容层左下角坐标
function WorldLayer:isPointInLingXing( x, y )
	--中心位置
	local fBeginX = x * -1
	local fBeginY = y * -1 - WORLD_BOTTOM_HEIGHT
	local nX = fBeginX + self.nCanSeeWidth / 2
	local nY = fBeginY + self.nCanSeeHeight / 2
	local nW = UNIT_WIDTH
	local nH = UNIT_HEIGHT
	local tPos = {
		{x = nX - nW/2 + 1, y = nY},
		{x = nX + nW/2 - 1, y = nY},
		{x = nX, y = nY - nH/2 + 1},
		{x = nX, y = nY + nH/2 - 1},
	}

	-- --碰撞点检测
	-- if self.pNodePolygon then
	-- 	self.pNodePolygon:removeFromParent(true)
	-- 	self.pNodePolygon = nil
	-- end
	-- local tPoint = {
	-- 	{nX + nW/2 - 1,  nY},
	-- 	{nX,  nY + nH/2 - 1},
	-- 	{nX - nW/2 + 1,  nY},
	-- 	{nX,  nY - nH/2 + 1},
	-- }
	-- local tColor = {fillColor = cc.c4f(171/255,151/255,95/255,179/255),
	-- borderWidth  = 1,
	-- borderColor  = cc.c4f(171/255,151/255,95/255,179/255)} 
	-- self.pNodePolygon =  display.newPolygon(tPoint,tColor)
	-- self.pMapViewGroup:addView(self.pNodePolygon, 999)

	--上下两边判断
	-- if cc.rectContainsPoint(WORLD_BOTTOM_RECT, cc.p(nX, nY)) then
	-- 	return false
	-- end
	-- if cc.rectContainsPoint(WORLD_TOP_RECT, cc.p(nX, nY)) then
	-- 	return false
	-- end
	--菱形判断
	for i=1,#tPos do
		if not pointInLingxingEx(WORLD_BG_WIDTH, WORLD_BG_HEIGHT,tPos[i].x ,tPos[i].y) then
			return false
		end
	end
	return true
end

--获取与菱形碰撞的点
--x,y：滚动内容层左下角坐标
function WorldLayer:getCollisionPointLingXing( x, y)
	--中心位置
	local fBeginX = x * -1
	local fBeginY = y * -1 - WORLD_BOTTOM_HEIGHT
	local nX = fBeginX + self.nCanSeeWidth / 2
	local nY = fBeginY + self.nCanSeeHeight / 2
	local nW = UNIT_WIDTH
	local nH = UNIT_HEIGHT
	local tPos = {
		cc.p(nX - nW/2 + 1, nY),--左下
		cc.p(nX + nW/2 - 1, nY),--左上
		cc.p(nX, nY - nH/2 + 1),--右下
		cc.p(nX, nY + nH/2 - 1),--右上
	}

	local tLines = {
		{cc.p(0, WORLD_BG_HEIGHT/2), cc.p(WORLD_BG_WIDTH/2, 0)}, --左下
		{cc.p(0, WORLD_BG_HEIGHT/2), cc.p(WORLD_BG_WIDTH/2, WORLD_BG_HEIGHT)}, --左上
		{cc.p(WORLD_BG_WIDTH/2, 0), cc.p(WORLD_BG_WIDTH, WORLD_BG_HEIGHT/2)}, --右下
		{cc.p(WORLD_BG_WIDTH, WORLD_BG_HEIGHT/2), cc.p(WORLD_BG_WIDTH/2, WORLD_BG_HEIGHT)}, --右上
	}
	
	local tCenterPos = cc.p(WORLD_BG_WIDTH/2, WORLD_BG_HEIGHT/2)

	for i=1,4 do
		local bIsCollision, pPos = pIsSegmentIntersectEx(tCenterPos,tPos[i],tLines[i][1],tLines[i][2])
		if bIsCollision then
			pPos.x = pPos.x + WORLD_BOTTOM_HEIGHT
			return pPos
		end
	end
	return nil
end


--视图点坐标转成世界坐标
--nDotX, nDotY 视图点坐标
-- p.x = originP.x + tileW /2 × M + （-tileW/2） × N = originP.x + (M – N) × tileW/2；
-- p.y = originP.y + tileH/2 × M + tileH/2 × N = originP.y + (M + N) × tileH/2;
function WorldLayer:getMapPosByDotPos( nDotX, nDotY )
	return WorldFunc.getMapPosByDotPos(nDotX, nDotY)
end

--世界坐标转成视图点坐标
function WorldLayer:getDotPosByMapPos( fPosX, fPosY )
	return WorldFunc.getDotPosByMapPos(fPosX, fPosY)
end

--获取的修正地图坐标(适配视图的大小显示，一般用于给滚动层移动位置）
function WorldLayer:getFixedMapPosByDotPos( nDotX, nDotY)
	local nCurPosX, nCurPosY = self:getMapPosByDotPos(nDotX, nDotY)
	return self:getFixedMapPosByPos(nCurPosX, nCurPosY)
end

--获取的修正地图坐标
function WorldLayer:getFixedMapPosByPos( fDotX, fDotY)
	--显示坐标
	local nCurPosX = fDotX - self.nCanSeeWidth/2
	local nCurPosY = fDotY - self.nCanSeeHeight/2
	-- WORLD_BOTTOM_HEIGHT修正
	nCurPosY = nCurPosY + WORLD_BOTTOM_HEIGHT
	if nCurPosX < 0 then
		nCurPosX = 0
	end
	if nCurPosX > WORLD_BG_WIDTH - self.nCanSeeWidth then
		nCurPosX = WORLD_BG_WIDTH - self.nCanSeeWidth
	end
	if nCurPosY < 0 then
		nCurPosY = 0
	end
	local nWolrdHeight = WORLD_BG_HEIGHT_EX
	if nCurPosY > nWolrdHeight - self.nCanSeeHeight then
		nCurPosY = nWolrdHeight - self.nCanSeeHeight
	end
	return cc.p(-nCurPosX, -nCurPosY)
end

--在已有的草皮上判断是否已经铺到正确位置上
function WorldLayer:isRightMap(_nRow, _nCol )
	-- body
	local bIsRight = false
	if self.tWorldMaps and table.nums(self.tWorldMaps) > 0 then
		for k, v in pairs (self.tWorldMaps) do
			bIsRight = v:isOnRightRowAndCol(_nRow,_nCol)
			if bIsRight then
				break
			end
		end
	end
	return bIsRight
end

--刷新草皮
function WorldLayer:refreshMap( )
	local fX = self.fViewCX
	local fY = self.fViewCY - WORLD_BOTTOM_HEIGHT + 150
	local nCurRow = math.ceil(fX / IMAGE_MAP_WIDTH)
	local nCurCol = math.ceil(fY / IMAGE_MAP_HEIGHT)
	if self.nCurRow ~= nCurRow or self.nCurCol ~= nCurCol then
		self.nCurRow = nCurRow
		self.nCurCol = nCurCol
		--重新铺草皮
		self:fillMap(nCurRow,nCurCol)
	end
end

--根据行列_nRow,_nCol参数，铺世界背景（草皮），以_nRow,_nCol为中点，9宫格铺草皮
--_nRow,_nCol：已经就算好的草皮行列
function WorldLayer:fillMap( _nRow, _nCol )
	--回收已经超出范围的草皮
	self:collectMapByRowAndCol(_nRow,_nCol)

	-- print(string.format("_nRow = %s,_nCol = %s", _nRow, _nCol))
	--铺九宫格草皮
	for i = -2, 2 , 1 do --行
		-- if _nRow + i > 0 and _nRow + i <= self.nMaxMapRow then --非边界
			for j = -2, 2, 1 do
				-- if _nCol + j > 0 and _nCol + j <= self.nMaxMapCol then --非边界
					-- print(string.format("_nRow + i = %s,_nCol + j = %s", _nRow + i, _nCol + j))
					self:fillMapByRowAndCol(_nRow + i,_nCol + j)
				-- else
					-- print("越界j")
				-- end
			end
		-- else
			-- print("越界i")
		-- end
	end
end

--根据传进来的行列，回收已经超出范围的草皮块
function WorldLayer:collectMapByRowAndCol( _nRow, _nCol)
	-- body
	if self.tWorldMaps and table.nums(self.tWorldMaps) > 0 then
		local nSize = table.nums(self.tWorldMaps)
		for i = nSize, 1, -1 do
			local pMap = self.tWorldMaps[i]
			if pMap then
				if pMap:isOutZone(_nRow,_nCol) then --判断是否需要回收
					--从已使用的列表中删除
					table.remove(self.tWorldMaps, i)
					--添加到未使用的列表中
					table.insert(self.t9WorldMapsUn, pMap)
				end
			end
		end
	end
end

--根据行列铺草皮
--_nRow,_nCol：行列
function WorldLayer:fillMapByRowAndCol( _nRow, _nCol )
	--判断该地方是否已经铺了草皮
	local bIsRight = self:isRightMap(_nRow,_nCol) 
	-- print("bIsRight _nRow,_nCol =",bIsRight,_nRow,_nCol)
	if not bIsRight then
		if self.t9WorldMapsUn and table.nums(self.t9WorldMapsUn) > 0 then
			--拿出最先添加到回收列表中的草皮
			local pMap = self.t9WorldMapsUn[1]
			if pMap then --理论上这个地方肯定不为nil值
				--判断是否已经添加到父节点上
				if pMap:isAdd() == false then
					--添加到父节点上
					-- pMap.pImageBg = cc.Sprite:createWithTexture(self.pBatchNodeMap:getTexture())
					-- self.pBatchNodeMap:addChild(pMap.pImageBg)
					--
					pMap.pImageBg = MUI.MImage.new("ui/daitu.png")
					self.pMapBgGroup:addView(pMap.pImageBg)
					WorldFunc.setCameraMaskForView(pMap.pImageBg)
					pMap:setIsAdd()
				end
				--设置行列和位置
				pMap:setRowAndCol(_nRow,_nCol)
				--刷新位置
				pMap:refreshPos()
				--添加到已使用的列表中
				table.insert(self.tWorldMaps, pMap)
				--从未使用的列表中删除
				table.remove(self.t9WorldMapsUn,1)
			end
		else
			-- myprint("草皮已经用完了")
		end
	end
end

--视图点搜索请求
--bIsMove:是否移动中
--bIsReconnect:是否重连后
--是否强制：刷新
function WorldLayer:searchDotReq( bIsMove, bIsReconnect )
	if not isSelectedCountry() then
		return
	end

	--坐标
	local fX = self.fViewCX
	local fY = self.fViewCY - WORLD_BOTTOM_HEIGHT
	--计算点中心位置
	local nDotX, nDotY = self:getDotPosByMapPos(fX, fY)
	if nDotX then
		local nBlockId = WorldFunc.getBlockId(nDotX, nDotY)
		local bIsChangeBlock = false
		if self.nPrevCheckBlockId ~= nBlockId then
			self.nPrevCheckBlockId = nBlockId
			bIsChangeBlock = true
		end
		--如果解锁才请求
		if Player:getWorldData():getBlockIsCanSeeByPos(nDotX, nDotY) then
			local bIsReq = false
			--上一个检测点
			local pPrevSearchDot = Player:getWorldData():getPrevSearchDot()
			--如果不存在上一个检测点
			if not pPrevSearchDot then
				bIsReq = true
			elseif bIsReconnect then
				bIsReq = true
			else
				--超过一定距离就请求
				-- local nOffsetX = math.abs(pPrevSearchDot.x - nDotX)
				-- local nOffsetY = math.abs(pPrevSearchDot.y - nDotY)
				-- if nOffsetX >= self.nSearchX or
				-- 	nOffsetY >= self.nSearchY then
				-- 	bIsReq = true
				-- end
				if nDotX ~= pPrevSearchDot.x or nDotY ~= pPrevSearchDot.y then
					bIsReq = true
				end
			end
			--发送请求
			if bIsReq then
				local nLoadTime = getSystemTime(false)
				SocketManager:sendMsg("reqWorldAroundDot", {nDotX, nDotY,nLoadTime}, handler(self, self.onSearchDotReq),-1)
				return true
			else
				--模拟点击
        		self:showDelayClick()
        		self:doDelayOther()
			end
		else
			--设置搜索点为当前
			Player:getWorldData():setPrevSearchDot(nDotX, nDotY)

			--该区域未解锁，滑动时不弹出
			if not bIsMove then
				--检测过的id不检测
				if bIsChangeBlock then
					--特殊处理，不要在边边移动的时候弹
					local bIsInNullDlg = WorldFunc.getIsShowInNullBlock(nDotX, nDotY)
					--print("bIsInNullNotDlg========================", bIsInNullDlg)
					if bIsInNullDlg then
						self:checkIsInLockBlock(nDotX, nDotY)
					else
						self.nPrevCheckBlockId = -1 --这里设置为-1了为下次进入没有区域可以开启检测，现在三种状态，有区域(看配表），没有区域（nil)，没有区域不显示弹窗(-1)
					end
				end
			end
		end
	end
end

--搜索点列表请求返回
function WorldLayer:onSearchDotReq( __msg, __oldMsg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqWorldAroundDot.id then
         	--数据已经在WorldController层进行存储。
        	--模拟点击
        	if self.showDelayClick then
        		self:showDelayClick()
        	end
        	if self.doDelayOther then
        		self:doDelayOther()
        	end
        end
    else
       	TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end

--播放点击特效
function WorldLayer:showDelayClick(  )
	--播放点击特效
	if self.nDelayClickPos then
		local fX, fY = self.nDelayClickPos.x, self.nDelayClickPos.y
		--隐藏自己
		self:hideCityClickLayer()
		local nDotX, nDotY = self:getDotPosByMapPos(fX, fY)
		if nDotX then
			local size = nil
			--点击中地图视图点
			local tViewDotMsg = Player:getWorldData():getViewDotMsg(nDotX, nDotY)
			if tViewDotMsg then
				if tViewDotMsg.nType == e_type_builddot.sysCity then
					size = tViewDotMsg:getCityImgSize()
				elseif tViewDotMsg.nType == e_type_builddot.zhouwang then
					size = tViewDotMsg:getKingZhouImgSize()
					fX, fY = tViewDotMsg:getWorldMapPos()
				end
			end
			--点击中限时Boss
			if not tViewDotMsg and Player:getTLBossData():getIsShowWorldTLBoss() then
				local tBLocatVos = Player:getTLBossData():getBLocatVos()
				for k, tBLocatVo in pairs(tBLocatVos) do
					local nTLBossX, nTLBossY = tBLocatVo:getX(), tBLocatVo:getY()
					if nDotX >= nTLBossX - 1 and nDotX <= nTLBossX + 1 and
					 nDotY >= nTLBossY - 1 and nDotY <= nTLBossY + 1 then
					 	size = self.tTLBossBorderSize
						break
					end
				end
			end
			--点击特效
			self:showClickEffect(fX, fY, size)
		end
	end

	self.nDelayClickPos = nil
end

--执行请求数据后的某些回调
function WorldLayer:doDelayOther(  )
	if self.tDelayOther then
		local nX, nY = WorldFunc.getDotPosByMapPos(self.tDelayOther.__tPos.x, self.tDelayOther.__tPos.y )
		if nX and nY then
			--从目标按钮打开或从聊天卡片打开，是城战就打开城战, 是国战就打开国战，
			if self.tDelayOther.bIsOpenCWar then
				local tViewDotMsg = Player:getWorldData():getViewDotMsg(nX, nY)
				if tViewDotMsg then
					if tViewDotMsg.nType == e_type_builddot.city then
						if tViewDotMsg.bIsHasCityWar then --有城战
							local bIsOpenDlg = true
							--如果是目标城池是自己且自己被打
							if tViewDotMsg:getIsMe() and Player:getWorldData():getOtherIsAttackMe() then
								--不拦截请求
							else
								--等级不足
								local nNeedLv = getWorldInitData("castkeWarOpen")
								if Player:getPlayerInfo().nLv < nNeedLv then
									bIsOpenDlg = false
								end
							end
							if bIsOpenDlg then
								SocketManager:sendMsg("reqWorldCityWarInfo", {tViewDotMsg.nCityId}, handler(self, self.onWorldCityWarInfo))
							else
								--打开二级菜单
								local fX, fY = tViewDotMsg:getWorldMapPos()
								self:showCityClickLayer(fX, fY, tViewDotMsg)
							end
						end
					elseif tViewDotMsg.nType == e_type_builddot.sysCity then
						if tViewDotMsg.bIsHasCountryWar then --有国战
							local bIsOpenDlg = true
							--等级不足
							local nNeedLv = getWorldInitData("warOpen")
							if Player:getPlayerInfo().nLv < nNeedLv then
								bIsOpenDlg = false
							end
							if bIsOpenDlg then
								SocketManager:sendMsg("reqWorldCountryWarInfo", {tViewDotMsg.nSystemCityId}, handler(self, self.onWorldCountryWarInfo))
							else
								--打开二级菜单
								local fX, fY = tViewDotMsg:getWorldMapPos()
								self:showCityClickLayer(fX, fY, tViewDotMsg)
							end
						end
					elseif tViewDotMsg.nType == e_type_builddot.boss and tViewDotMsg:getBossLeaveCd() > 0 then
						if tViewDotMsg.bIsHasBossWar then --已经发起Boss战
							local bIsOpenDlg = true
							--表数据
							local tAwakeBoss = getAwakeBossData(tViewDotMsg.nBossLv, Player:getWuWangDiff())
							if not tAwakeBoss then
								bIsOpenDlg = false
							else
								--等级限制
								local nLvNeed = getAwakeInitData("evilOpen")
								if nLvNeed and Player:getPlayerInfo().nLv < nLvNeed then
									bIsOpenDlg = false
								end

								local nX, nY = tViewDotMsg.nX, tViewDotMsg.nY
								--不可以跨区
								if not Player:getWorldData():getIsCanWarByPos(nX, nY, e_war_type.boss) then
									bIsOpenDlg = false
								end
							end

							if bIsOpenDlg then
								--获取Boss战列表
								SocketManager:sendMsg("reqWorldBossWarList",{nX, nY, tAwakeBoss})
							else
								--打开二级菜单
								local fX, fY = tViewDotMsg:getWorldMapPos()
								self:showCityClickLayer(fX, fY, tViewDotMsg)
							end
						end
					end
				end
			elseif self.tDelayOther.bIsOpenTLBoss then --打开限时Boss
				local bIsShow = Player:getTLBossData():getIsShowWorldTLBoss()
				if bIsShow then
					local nBlockId = WorldFunc.getBlockId(nX, nY)
					local tBLocatVo = Player:getTLBossData():getBLocatVo(nBlockId)
		    		if tBLocatVo then
		    			local ViewDotMsg = require("app.layer.world.data.ViewDotMsg")
						local tViewDotMsg2 = ViewDotMsg.new({t = e_type_builddot.tlboss, x = tBLocatVo:getX(), y = tBLocatVo:getY()})
						local fX, fY = tBLocatVo:getWorldMapPos()
						self:showCityClickLayer(fX, fY, tViewDotMsg2)
		    		end
		    	end
			end
		end
	end
	self.tDelayOther = nil
end

--刷新位置提示
function WorldLayer:refreshPosTips(  )
	--坐标变换就刷新
	if self.fPosTipsX ~= self.fViewX or self.fPosTipsY ~= self.fViewY then
		self.fPosTipsX = self.fViewX
		self.fPosTipsY = self.fViewY

		--计算点中心位置
		local nDotX, nDotY = self:getDotPosByMapPos(self.fViewCX, self.fViewCY - WORLD_BOTTOM_HEIGHT)
		if nDotX then
			local nBlockId = WorldFunc.getBlockId(nDotX, nDotY)
			--发送中心点位置刷新小地图
			sendMsg(ghd_world_view_pos_msg,{
				fViewCX = self.fViewCX,
				fViewCY = self.fViewCY - WORLD_BOTTOM_HEIGHT,
				nDotX = nDotX,
				nDotY = nDotY,
				nBlockId = nBlockId,
				})

			--定位按钮特效
			local bIsShow = true
			if Player:getWorldData():getBlockIsCanSeeByPos(nDotX, nDotY) then
				bIsShow = false
			end
			sendMsg(ghd_worldtop_lbtn_effect_show_or_hide, bIsShow)
		end

		--刷新指向世界的箭头
		self:refreshArrow()
	end
end

--初始化区域边框
function WorldLayer:initBlockBorder()
	self.tBorderDict = {}
	self.tUnBorder = {}
end

--刷新区域边框
function WorldLayer:refreshBlockBorder(  )
	--显示的框
	local _pViewRect = self:getShowViewRect()
	local pViewRect = nil
	--为了远景地图视角加大显示，数字是手动测试出来的。。。
	if b_open_far_and_near_view_forworld then
		nX = _pViewRect.x - 250
		nY = _pViewRect.y - 250
		nW = _pViewRect.width + 500
		nH = _pViewRect.height + 500
		pViewRect = cc.rect(nX, nY, nW, nH)
	else
		pViewRect = _pViewRect
	end

	--四边的点
	local tViewRectPoints = {
		{{x = nX, 		y = nY}, 		{x = nX + nW, 	y = nY }},
		{{x = nX + nW, 	y = nY}, 		{x = nX + nW, 	y = nY + nH}},
		{{x = nX + nW, 	y = nY + nH}, 	{x = nX, 	  	y = nY + nH}},
		{{x = nX, 		y = nY + nH},	{x = nX, 		y = nY}},
	}

	--显示的边字典
	self.tShowBorderDict = {}

	--所有区域边框的线
	local tBlockDatas = getWorldMapData()
	for nBlockId, tBlockData in pairs(tBlockDatas) do
		local nBlockWidth = (tBlockData.xover - tBlockData.xstart + 1) * UNIT_WIDTH
		local nBlockHeight = (tBlockData.yover - tBlockData.ystart + 1) * UNIT_HEIGHT
		--菱形左下角
		local nX ,nY = WorldFunc.getMapPosByDotPos(tBlockData.xstart, tBlockData.ystart)
		nX = nX - UNIT_WIDTH/2
		nY = nY - nBlockHeight/2
		--边的点
		local tBorderPoints = {
			--左中至下中
			{{x = nX,					y = nY + nBlockHeight/2}, 	{x = nX + nBlockWidth/2,y = nY}},
			--下中至右中
			{{x = nX + nBlockWidth/2,	y = nY}, 					{x = nX + nBlockWidth, 	y = nY + nBlockHeight/2}},
			--右中至上中
			{{x = nX + nBlockWidth, 	y = nY + nBlockHeight/2}, 	{x = nX + nBlockWidth/2,y = nY + nBlockHeight}},
			--上中至左中
			{{x = nX + nBlockWidth/2, 	y = nY + nBlockHeight}, 	{x = nX, 				y = nY + nBlockHeight/2}},
		}
		--先进行矩形判断
		local tBlockRect = cc.rect(nX, nY, nBlockWidth, nBlockHeight)
		if cc.rectIntersectsRect(tBlockRect, pViewRect) then
			--小边长
			local nBorderWidth = 109
			--求出相交点的并显示
			for i=1,#tBorderPoints do
				local pPosA1 = cc.p(tBorderPoints[i][1].x, tBorderPoints[i][1].y)
				local pPosA2 = cc.p(tBorderPoints[i][2].x, tBorderPoints[i][2].y)
				
				--最后的下标
				local nLastIndex = math.floor(cc.pGetDistance(pPosA1, pPosA2)/nBorderWidth)

				--相撞点
				local tCollision = {}
				for j=1,#tViewRectPoints do
					local pPosB1 = cc.p(tViewRectPoints[j][1].x, tViewRectPoints[j][1].y)
					local pPosB2 = cc.p(tViewRectPoints[j][2].x, tViewRectPoints[j][2].y)
					--有两个交点才显示
					local bIsCollision, pPos = pIsSegmentIntersectEx(pPosA1, pPosA2, pPosB1, pPosB2)
					if pPos then
						table.insert(tCollision, pPos)
					end
				end

				if #tCollision > 0 then
					--绘制线路
					local pCollisionA = tCollision[1]
					local pCollisionB = tCollision[2]
					if pCollisionB == nil then
						--哪个在框里就
						if cc.rectContainsPoint(pViewRect, pPosA1) then
							pCollisionB = pPosA1
						else
							pCollisionB = pPosA2
						end
					end
					--哪个点在前，哪个点在后
					local fDistance = cc.pGetDistance(pPosA1, pCollisionA)
					local nIndex1 = math.floor(fDistance/nBorderWidth)

					local fDistance = cc.pGetDistance(pPosA1, pCollisionB)
					local nIndex2 = math.floor(fDistance/nBorderWidth)
					--保证顺序
					if nIndex1 > nIndex2 then
						nIndex1, nIndex2 = nIndex2, nIndex1
					end	
					--绘制边		
					local nAngle = getAngle(pPosA1.x, pPosA1.y, pPosA2.x, pPosA2.y)
					local pPosStart = cc.p(pPosA1.x, pPosA1.y)
					--美化少少
					if i == 1 then
						pPosStart.x = pPosA1.x + 3 
						pPosStart.y = pPosA1.y + 3 
					elseif i == 2 then
						pPosStart.x = pPosA1.x - 3 
						pPosStart.y = pPosA1.y + 3 
					elseif i == 3 then
						pPosStart.x = pPosA1.x - 3 
						pPosStart.y = pPosA1.y  -3
					elseif i == 4 then
						pPosStart.x = pPosA1.x + 3 
						pPosStart.y = pPosA1.y - 3 
					end
					for k = nIndex1, nIndex2 do
						local tSubData = {pPos = pPosStart, nSubLength = nBorderWidth, nIndex = k, nAngle = nAngle, bIsLast = nLastIndex == k}
						local sKey = string.format("%s_%s_%s",nBlockId,i,k)
						self.tShowBorderDict[sKey] = tSubData
					end
				end
			end
		end
	end

	

	--绘制图片
	local nBorderNum = table.nums(self.tShowBorderDict)
	if nBorderNum > 0 then
		--隐藏之前的图片
		for sKey,pBorder in pairs(self.tBorderDict) do
			if not self.tShowBorderDict[sKey] then
				pBorder:setVisible(false)
				table.insert(self.tUnBorder, pBorder)
				self.tBorderDict[sKey] = nil
			end
		end

		--显示现在的
		for sKey,tBorderData in pairs(self.tShowBorderDict) do
			if not self.tBorderDict[sKey] then
				--是否获取边
				local pBorder = nil
				local nCount = #self.tUnBorder
				if nCount > 0 then
					pBorder = self.tUnBorder[nCount]
					pBorder:setVisible(true)
					table.remove(self.tUnBorder, nCount)
				else
					pBorder = MUI.MImage.new("#v1_line_sjbj_sj.png")
					pBorder:setAnchorPoint(cc.p(0,0.5))
					self.pMapBorderGroup:addView(pBorder)
					WorldFunc.setCameraMaskForView(pBorder)
				end
				self.tBorderDict[sKey] = pBorder
				pBorder:setVisible(true)
				local nLastSubLenght = 0
				if tBorderData.bIsLast then
					nLastSubLenght = 73
				end
				self:setBorderByIndex(pBorder, tBorderData.pPos, tBorderData.nSubLength, tBorderData.nIndex, tBorderData.nAngle, nLastSubLenght)
			end
		end
		-- print("img===============",table.nums(self.tBorderDict),#self.tUnBorder,table.nums(self.tBorderDict) + #self.tUnBorder)
	end
end

--设置边的位置
function WorldLayer:setBorderByIndex( pBorder, pPos, nSubLength, nIndex, nAngle, nLastSubLenght)
	if not pBorder then
		return
	end

	local fDistance = nSubLength * nIndex
	local nRadian = nAngle * math.pi / 180;
	pBorder:setRotation(nAngle)
	if nLastSubLenght then --(最后一条要偏移量)
		fDistance = fDistance - nLastSubLenght
	end
	local fX, fY = pPos.x + fDistance * math.cos(nRadian), pPos.y - fDistance * math.sin(nRadian)
	pBorder:setPosition(fX, fY)
end

--初始化阿房宫势力边框
function WorldLayer:initImperialBorder()
	self.tImperialBorderDict = {}
	self.tImperialUnBorder = {}
	self.tImperialRanges = {}
	--系统城池对应该的一个势力区域的最左边点与最右边点的集合
	local tBlockData = getWorldMapDataById(nImperialCityMapId)
	if tBlockData then		
		--先按x再按y排列
		local tCityDatas = getWorldCityDataByMapId(nImperialCityMapId)
		table.sort(tCityDatas, function(a, b)
			if a.tCoordinateCenter.x == b.tCoordinateCenter.x then
				return a.tCoordinateCenter.y < b.tCoordinateCenter.y
			end
			return a.tCoordinateCenter.x < b.tCoordinateCenter.x
		end)

		--（注意！！！配表更改就要改）
		--[[
		大地图菱形(不怎么标准，自己想像)
			  1，500
			  /\
			 /  \
		1，1/    \500，500
		    \    /
			 \  /
			  \/
			  500，1

		方向,1,1为原点开始
		/:y
		\:x
		--]]
		local nBlockNum = 5 --小区域间隔
		for i=1,#tCityDatas do
			local tCityData = tCityDatas[i]
			if tCityData.tArea then
				table.insert(self.tImperialRanges,{id = tCityData.id, name= tCityData.name, xstart = tCityData.tArea.xstart, xover = tCityData.tArea.xover, ystart = tCityData.tArea.ystart, yover = tCityData.tArea.yover })
			end
		end
	end


	--边框信息
	self.tImperialBorderImgs = {
		[e_type_country.shuguo] = "#v1_border_red_%s.png",
		[e_type_country.weiguo] = "#v1_border_blue_%s.png",
		[e_type_country.wuguo] = "#v1_border_green_%s.png",
		[e_type_country.qunxiong] = "#v1_border_white_%s.png",
	}
	--边框摆放信息
	self.tImperialBorderPut = {
		--左中至下中
		{
			tImgIndex = {1, 2, 3},
		},
		--下中至右中
		{
			tImgIndex = {3, 2, 1},
			flippedX = true,
		},
		--右中至上中
		{
			tImgIndex = {1, 2, 3},
		},
		--上中至左中
		{
			tImgIndex = {3, 2, 1},
			flippedX = true,
		},
	}
end

--刷新阿房宫势力边框
function WorldLayer:refreshImperialBorder(  )
	--显示的框
	local _pViewRect = self:getShowViewRect()
	local pViewRect = nil
	--为了远景地图视角加大显示，数字是手动测试出来的。。。
	if b_open_far_and_near_view_forworld then
		nX = _pViewRect.x - 250
		nY = _pViewRect.y - 250
		nW = _pViewRect.width + 500
		nH = _pViewRect.height + 500
		pViewRect = cc.rect(nX, nY, nW, nH)
	else
		pViewRect = _pViewRect
	end
	--四边的点
	local tViewRectPoints = {
		{{x = nX, 		y = nY}, 		{x = nX + nW, 	y = nY }},
		{{x = nX + nW, 	y = nY}, 		{x = nX + nW, 	y = nY + nH}},
		{{x = nX + nW, 	y = nY + nH}, 	{x = nX, 	  	y = nY + nH}},
		{{x = nX, 		y = nY + nH},	{x = nX, 		y = nY}},
	}

	--显示的边字典
	self.tShowImperialBorderDict = {}

	--阿房宫边框的线
	local tBlockData = getWorldMapDataById(nImperialCityMapId)
	if tBlockData then
		local nBlockWidth = (tBlockData.xover - tBlockData.xstart + 1) * UNIT_WIDTH
		local nBlockHeight = (tBlockData.yover - tBlockData.ystart + 1) * UNIT_HEIGHT
		--菱形左下角
		local nX ,nY = WorldFunc.getMapPosByDotPos(tBlockData.xstart, tBlockData.ystart)
		nX = nX - UNIT_WIDTH/2
		nY = nY - nBlockHeight/2
		--边的点
		local tBorderPoints = {
			--左中至下中
			{{x = nX,					y = nY + nBlockHeight/2}, 	{x = nX + nBlockWidth/2,y = nY}},
			--下中至右中
			{{x = nX + nBlockWidth/2,	y = nY}, 					{x = nX + nBlockWidth, 	y = nY + nBlockHeight/2}},
			--右中至上中
			{{x = nX + nBlockWidth, 	y = nY + nBlockHeight/2}, 	{x = nX + nBlockWidth/2,y = nY + nBlockHeight}},
			--上中至左中
			{{x = nX + nBlockWidth/2, 	y = nY + nBlockHeight}, 	{x = nX, 				y = nY + nBlockHeight/2}},
		}
		--先进行矩形判断
		local tBlockRect = cc.rect(nX, nY, nBlockWidth, nBlockHeight)
		if cc.rectIntersectsRect(tBlockRect, pViewRect) then
			--占领信息
			local tBlockSCOI = Player:getWorldData():getBlockSCOI(nImperialCityMapId)
			--阿房宫里面的小区域进行相关判定
			for _key ,tImperialRange in pairs(self.tImperialRanges) do				
				--小区域数据
				local nBlockWidth = (tImperialRange.xover - tImperialRange.xstart + 1) * UNIT_WIDTH
				local nBlockHeight = (tImperialRange.yover - tImperialRange.ystart + 1) * UNIT_HEIGHT
				-- local nBlockWidth = (tImperialRange.xover - tImperialRange.xstart ) * UNIT_WIDTH
				-- local nBlockHeight = (tImperialRange.yover - tImperialRange.ystart ) * UNIT_HEIGHT
				--菱形左下角
				local nX ,nY = WorldFunc.getMapPosByDotPos(tImperialRange.xstart, tImperialRange.ystart)
				nX = nX - UNIT_WIDTH/2
				nY = nY - nBlockHeight/2
				--边的点
				local tBorderPoints = {
					--左中至下中
					{{x = nX,					y = nY + nBlockHeight/2}, 	{x = nX + nBlockWidth/2,y = nY}},
					--下中至右中
					{{x = nX + nBlockWidth/2,	y = nY}, 					{x = nX + nBlockWidth, 	y = nY + nBlockHeight/2}},
					--右中至上中
					{{x = nX + nBlockWidth, 	y = nY + nBlockHeight/2}, 	{x = nX + nBlockWidth/2,y = nY + nBlockHeight}},
					--上中至左中
					{{x = nX + nBlockWidth/2, 	y = nY + nBlockHeight}, 	{x = nX, 				y = nY + nBlockHeight/2}},
				}
				--先进行矩形判断
				local tBlockRect = cc.rect(nX, nY, nBlockWidth, nBlockHeight)
				if cc.rectIntersectsRect(tBlockRect, pViewRect) then
					--小边长
					local nBorderWidth = UNIT_HYPOTENUSE/2
					--求出相交点的并显示
					for i=1,#tBorderPoints do
						local pPosA1 = cc.p(tBorderPoints[i][1].x, tBorderPoints[i][1].y)   --每条边的起点
						local pPosA2 = cc.p(tBorderPoints[i][2].x, tBorderPoints[i][2].y)   --每条边的终点
						
						--最后的下标
						local nLastIndex = nGridNum - 1--(这里写死,一边一共20个格子,由于下标是从0开始，最后一个下标为19)

						--相撞点
						local tCollision = {}
						for j=1,#tViewRectPoints do
							local pPosB1 = cc.p(tViewRectPoints[j][1].x, tViewRectPoints[j][1].y)
							local pPosB2 = cc.p(tViewRectPoints[j][2].x, tViewRectPoints[j][2].y)
							--有两个交点才显示
							local bIsCollision, pPos = pIsSegmentIntersectEx(pPosA1, pPosA2, pPosB1, pPosB2)
							if pPos then
								table.insert(tCollision, pPos)
							end
						end

						if #tCollision > 0 then
							--绘制线路
							local pCollisionA = tCollision[1]
							local pCollisionB = tCollision[2]
							if pCollisionB == nil then
								--哪个在框里就
								if cc.rectContainsPoint(pViewRect, pPosA1) then
									pCollisionB = pPosA1
								else
									pCollisionB = pPosA2
								end
							end
							--哪个点在前，哪个点在后
							local fDistance = cc.pGetDistance(pPosA1, pCollisionA)
							local nIndex1 = math.floor(fDistance/nBorderWidth)

							local fDistance = cc.pGetDistance(pPosA1, pCollisionB)
							local nIndex2 = math.floor(fDistance/nBorderWidth)
							--保证顺序
							if nIndex1 > nIndex2 then
								nIndex1, nIndex2 = nIndex2, nIndex1
							end
							if nIndex2 >= nLastIndex then --(这里写死,一边一共20个格子,由于下标是从0开始，最后一个下标为19)
								nIndex2 = nLastIndex
							end
							--绘制边		
							local nAngle = getAngle(pPosA1.x, pPosA1.y, pPosA2.x, pPosA2.y)
							local pPosStart = cc.p(pPosA1.x, pPosA1.y)
							--美化少少
							if i == 2 then
								pPosStart.x = pPosA1.x - 54 + 3 -20 -15 - 5 - 5-3-1-0.5 - 0.03
								pPosStart.y = pPosA1.y - 26 - 0.5 -10 - 12+1 -3
							elseif i == 4 then
								pPosStart.x = pPosA1.x + 54 - 3 +20 + 15 +5 + 5 +3 +1 +0.5 +0.03
								pPosStart.y = pPosA1.y + 26 +0.5+10 +12-1 +3
							end
							for k = nIndex1, nIndex2 do
								-- if tImperialRange.id == 11173 then
									--图片信息
									local sImg = nil
									local bFlippedX = self.tImperialBorderPut[i].flippedX or false
									local nCountry = e_type_country.qunxiong
									if tBlockSCOI[tImperialRange.id] then
										nCountry = tBlockSCOI[tImperialRange.id].nCountry
									end
									--第一张
									if k == 0 then
										sImg = string.format(self.tImperialBorderImgs[nCountry],self.tImperialBorderPut[i].tImgIndex[1])
									--最后一张
									elseif k == nLastIndex then
										sImg = string.format(self.tImperialBorderImgs[nCountry],self.tImperialBorderPut[i].tImgIndex[3])
									else --中间
										sImg = string.format(self.tImperialBorderImgs[nCountry],self.tImperialBorderPut[i].tImgIndex[2])
									end
									local tSubData = {pPos = pPosStart, nSubLength = nBorderWidth, nIndex = k, nAngle = nAngle, sImg = sImg, bFlippedX = bFlippedX}
									local sKey = string.format("%s_%s_%s_%s",tImperialRange.id, i, k, nCountry)
									self.tShowImperialBorderDict[sKey] = tSubData
								-- end
							end
						end
					end		
				end
			end

			--绘制图片
			local nBorderNum = table.nums(self.tShowImperialBorderDict)
			if nBorderNum > 0 then
				--隐藏之前的图片
				for sKey,pBorder in pairs(self.tImperialBorderDict) do
					if not self.tShowImperialBorderDict[sKey] then
						pBorder:setVisible(false)
						table.insert(self.tImperialUnBorder, pBorder)
						self.tImperialBorderDict[sKey] = nil
					end
				end

				--显示现在的
				for sKey,tBorderData in pairs(self.tShowImperialBorderDict) do
					if not self.tImperialBorderDict[sKey] then
						local sImg = tBorderData.sImg
						--是否获取边
						local pBorder = nil
						local nCount = #self.tImperialUnBorder
						if nCount > 0 then
							pBorder = self.tImperialUnBorder[nCount]
							pBorder:setCurrentImage(sImg)
							pBorder:setVisible(true)
							table.remove(self.tImperialUnBorder, nCount)
						else
							pBorder = MUI.MImage.new(sImg)
							pBorder:setAnchorPoint(cc.p(0,0))
							self.pImperialBorderGroup:addView(pBorder)
							WorldFunc.setCameraMaskForView(pBorder)
						end
						pBorder:setFlippedX(tBorderData.bFlippedX)
						self.tImperialBorderDict[sKey] = pBorder
						pBorder:setVisible(true)
						local nLastSubLenght = 0
						self:setBorderByIndex(pBorder, tBorderData.pPos, tBorderData.nSubLength, tBorderData.nIndex, tBorderData.nAngle, nLastSubLenght)
					end
				end
			end
			-- print("img2===============",table.nums(self.tImperialBorderDict),#self.tImperialUnBorder,table.nums(self.tImperialBorderDict) + #self.tImperialUnBorder)
		end
	end
end

--获取屏幕中心点位置
function WorldLayer:getViewCenterPos(  )
	return self:getDotPosByMapPos(self.fViewCX, self.fViewCY - WORLD_BOTTOM_HEIGHT)
end

--获取屏幕中心点位置2
function WorldLayer:getViewCenterMapPos( )
	return self.fViewCX, self.fViewCY - WORLD_BOTTOM_HEIGHT
end

--刷新箭头
function WorldLayer:refreshArrow(  )
	if not self.pArrowImg or not self.pLyArrowImg then
		return
	end
	--算偏移值
	local fOffsetX = self.fMyPosX - self.fViewCX
	local fOffsetY = self.fMyPosY - self.fViewCY
	local fTopY = self.nCanSeeHeight/2 - WORLD_TOP_HEGITH
	local fBottomY = self.nCanSeeHeight/2 - 200
	local fLeftX = self.nCanSeeWidth/2
	local fRightX = self.nCanSeeWidth/2
	local tImgSize = self.pArrowImg:getContentSize()
	local nImgAnchorX = 1-self.pArrowImg:getAnchorPoint().x

	local bIsOverX = true
	if (fOffsetX < 0 and math.abs(fOffsetX) < fLeftX) or (fOffsetX >= 0 and fOffsetX < fRightX) then
		bIsOverX = false
	end
	local bIsOverY = true
	if (fOffsetY < 0 and math.abs(fOffsetY) < fBottomY) or (fOffsetY >= 0 and fOffsetY < fTopY) then
		bIsOverY = false
	end
	if not bIsOverX and not bIsOverY then
		self.pLyArrowImg:setVisible(false)
		return
	end

	--超出的按最大部分显示
	if bIsOverX then
		if fOffsetX < 0 then
			fOffsetX = (fLeftX - tImgSize.width*nImgAnchorX) * -1
		else
			fOffsetX = fRightX - tImgSize.width*nImgAnchorX
		end
	end
	if bIsOverY then
		if fOffsetY < 0 then
			fOffsetY = (fBottomY  + tImgSize.width*nImgAnchorX) * -1
		else
			fOffsetY = fTopY  - tImgSize.width*nImgAnchorX
		end
	end
	--设置文本翻转
	local pArrowLabel = self.pLyArrowImg.pArrowLabel
	--
	local pArrowImage = self.pLyArrowImg.pArrowImage
	-- if fOffsetX < 0 then
	-- 	pArrowLabel:setRotation(180)
	-- else
	-- 	pArrowLabel:setRotation(0)
	-- end

	--显示文本长度
	local nX = self.fViewCX + fOffsetX
	local nY = self.fViewCY + fOffsetY
	local nDotX, nDotY = self:getViewCenterPos()
	local nMyDotX, nMyDotY = Player:getWorldData():getMyCityDotPos()
	if nDotX and nDotY and nMyDotX and nMyDotY then
		local nLenght = math.abs(nDotX - nMyDotX) + math.abs(nDotY - nMyDotY)
		pArrowLabel:setString(string.format(getConvertedStr(3,10000), nLenght),false)
	end
	
	--设置箭头角度
	local fAnlge = getAngle(self.fViewCX, self.fViewCY, self.fMyPosX, self.fMyPosY)
	--设置文字位置
	-- pArrowLabel:setPositionX(-8*math.cos(math.rad(fAnlge))/2)
	-- pArrowImage:setPositionX(-8*math.cos(math.rad(fAnlge))/2)


	self.pArrowImg:setRotation(fAnlge)
	--显示箭头
	self.pLyArrowImg:setVisible(true)
	--位置
	-- local pPos = cc.p(self.nCanSeeWidth/2 + fOffsetX, self.nCanSeeHeight/2 + fOffsetY)
	-- --位置修正
	-- --注意箭头同一坐标系统
	-- local pRect = self.pWorldPanel:getSmallMapRect() --小地图距形
	-- if pRect and cc.rectContainsPoint(pRect, pPos) then
	-- 	local pCenterPos = cc.p(self.nCanSeeWidth/2, self.nCanSeeHeight/2)
	-- 	local bIsCollision, _pPos = pIsSegmentIntersectEx(cc.p(pRect.x, pRect.y),cc.p(pRect.x + pRect.width, pRect.y), pCenterPos, pPos)
	-- 	if bIsCollision then
	-- 		pPos = cc.p(_pPos.x, _pPos.y- tImgSize.width*nImgAnchorX)
	-- 	else
	-- 		local bIsCollision, _pPos = pIsSegmentIntersectEx(cc.p(pRect.x, pRect.y),cc.p(pRect.x, pRect.y + pRect.height), pCenterPos, pPos)
	-- 		if bIsCollision then
	-- 			pPos = cc.p(_pPos.x - tImgSize.width*nImgAnchorX, _pPos.y) 
	-- 		end
	-- 	end
	-- end
	-- --任务栏
	-- local pRect = self.pWorldPanel:getTaskRect()
	-- if pRect and cc.rectContainsPoint(pRect, pPos) then
	-- 	local pCenterPos = cc.p(self.nCanSeeWidth/2, self.nCanSeeHeight/2)
	-- 	local bIsCollision, _pPos = pIsSegmentIntersectEx(cc.p(pRect.x, pRect.y + pRect.height),cc.p(pRect.x + pRect.width, pRect.y + pRect.height), pCenterPos, pPos)
	-- 	if bIsCollision then
	-- 		pPos = cc.p(_pPos.x, _pPos.y + tImgSize.width*nImgAnchorX)
	-- 	else
	-- 		local bIsCollision, _pPos = pIsSegmentIntersectEx(cc.p(pRect.x + pRect.width, pRect.y),cc.p(pRect.x, pRect.y + pRect.height), pCenterPos, pPos)
	-- 		if bIsCollision then
	-- 			pPos = cc.p(_pPos.x + tImgSize.width*nImgAnchorX, _pPos.y)
	-- 		end
	-- 	end
	-- end

	--设置位置
	-- self.pLyArrowImg:setPosition(pPos)
end

--显示城池点击面板
--fX,fY: 世界地图坐标
--tData: tViewDotMsg
function WorldLayer:showCityClickLayer( fX, fY, tData)
	if not tData then
		return
	end
	--可点击面板
	if not self.pCityClickLayer then
		self.pCityClickLayer = CityClickLayer.new(self)
		self.pMapViewGroup:addView(self.pCityClickLayer, nClickLayerZorder)
	end
	self.pCityClickLayer:setPosition(fX, fY)
	self.pCityClickLayer:setJumpType(self.nJumpType)		--设置是从哪个地方跳转过来的 注意顺序 如果要设置特效 要先设置跳转类型
	self.nJumpType=e_jumpto_world_type.null
	self.pCityClickLayer:setData(tData)
	self.pCityClickLayer:setVisibleEx(true)

	--格子亮框且是玩家的才显示
	if tData.nType == e_type_builddot.city and tData.nDotCountry then
		local sImg = WorldFunc.getWorldCityDotBgImg(tData.nDotCountry)
		if not self.pImgGridBg then
            self.pImgGridBg = WorldFunc.getWorldCityDotBgImgLayer(sImg)
			--self.pImgGridBg = MUI.MImage.new(sImg)
			self.pMapViewGroup:addView(self.pImgGridBg, nGridLightZorder)
			WorldFunc.setCameraMaskForView(self.pImgGridBg)
		else
			--self.pImgGridBg:setCurrentImage(sImg)
            self.pImgGridBg:changeBgImg(sImg)
			self.pImgGridBg:setVisible(true)
		end
		self.pImgGridBg:setScale(0.25)
		self.pImgGridBg:setPosition(fX, fY)
	end

	--可点击面板背景
	if not self.pBgCityClickLayer then
		self.pBgCityClickLayer = MUI.MLayer.new()
		self.pBgCityClickLayer:setContentSize(WORLD_BG_WIDTH, WORLD_BG_HEIGHT_EX)
		self.pBgCityClickLayer:setTouchCatchedInList(true)
		self.pBgCityClickLayer:onMViewClicked(function (  )
			self:hideCityClickLayer()
		end)
		self.pBgCityClickLayer:setViewTouched(true)
		self.pMapViewGroup:addView(self.pBgCityClickLayer, nClickLayerBgZorder)
	end
	self.pBgCityClickLayer:setVisible(true)

	-- --设置为不可以点击
	-- self:setViewTouched(false)
	--就显示城池点击面板
	self.bIsShowCityLayer = true
end

--初始化点特效
function WorldLayer:initClickEffect( )
	--点击点
	self.pClickNode = MUI.MLayer.new()
	self.pMapViewGroup:addView(self.pClickNode, nGridLightZorder)
	WorldFunc.setCameraMaskForView(self.pClickNode)

	--进击特效
	self.pClickArms = WorldFunc.getViewDotAtkEffect(self.pClickNode, 0, 0, 0)
	for i=1,#self.pClickArms do
		WorldFunc.setCameraMaskForView(self.pClickArms[i])
	end
end

--显示点击特效
function WorldLayer:showClickEffect( fX, fY, size )
	self.pClickNode:setVisible(true)
	self.pClickNode:setPosition(fX, fY)
	--
	--循环动画整体缩放值
	self.pClickNode:stopAllActions()
	self.pClickNode:setOpacity(0)
	local scale = 1.5
	if size then
		local nLong = math.max(size.height, size.width)
		scale = size.width/196
		self.pClickNode:setScale(scale)
	else
		self.pClickNode:setScale(scale)
	end

	--动画
	if size then
		WorldFunc.setViewDotAtkEffectScale(self.pClickArms, scale)
	else
		WorldFunc.setViewDotAtkEffectScale(self.pClickArms, 1)
	end
	if self.pClickArms then
		for i=1,#self.pClickArms do
			self.pClickArms[i]:setVisible(true)
			self.pClickArms[i]:play(-1)
		end
	end
	--动作
	local pSeqAct = cc.Sequence:create({
		cc.Spawn:create({
			cc.FadeIn:create(0.3),
			cc.ScaleTo:create(0.3, 1),
		}),
	})
	self.pClickNode:runAction(pSeqAct)
end

--隐藏点击特效
function WorldLayer:hideClickEffect(  )
	if self.pClickArms then
		for i=1,#self.pClickArms do
			self.pClickArms[i]:setVisible(false)
			self.pClickArms[i]:stop()
		end
	end
	if self.pClickNode then
		self.pClickNode:setVisible(false)
	end
end


--关闭城池点击面板
function WorldLayer:hideCityClickLayer(  )
	if self.bIsShowCityLayer == false then
		--不选中
		self:hideClickEffect()
		return
	end
	self.bIsShowCityLayer = false

	if self.pCityClickLayer then
		self.pCityClickLayer:setVisibleEx(false)
		self.pCityClickLayer:removeEffect()
	end
	if self.pImgGridBg then
		self.pImgGridBg:setVisible(false)
	end
	if self.pBgCityClickLayer then
		self.pBgCityClickLayer:setVisible(false)
	end
	self:hideClickEffect()
	-- self:setViewTouched(true)
	sendMsg(ghd_show_tlboss_small_rank, false)
end

 --创建格子底部特效层
function WorldLayer:createGridEffectLayer(  )
	local pClickNode = MUI.MLayer.new()
	self.pMapViewGroup:addView(pClickNode, nGridLightZorder)
	WorldFunc.setCameraMaskForView(pClickNode)
	return pClickNode
end
--------------------------------------地图点公用方法
--消除当前的点
function WorldLayer:onDotDispear( sMsgName, pMsgObj )
	local sDotKey = pMsgObj
	if sDotKey then
		for i=1,#self.tCityDots do 
			local pDot = self.tCityDots[i]
			if pDot:isVisible() and pDot:getDotKey() == sDotKey then
				--释放占用格子
				self:setDotKeyUsed(sDotKey, false)
				--隐藏自我
				self:hideMyCityBorder(pDot)
				pDot:setVisibleEx(false)
				return
			end
		end

		for i=1,#self.tResDots do
			local pDot = self.tResDots[i]
			if pDot:isVisible() and pDot:getDotKey() == sDotKey then
				--释放占用格子
				self:setDotKeyUsed(sDotKey, false)
				--隐藏自我
				pDot:setVisibleEx(false)
				return
			end
		end

		for i=1,#self.tWildArmyDots do
			local pDot = self.tWildArmyDots[i]
			if pDot:isVisible() and pDot:getDotKey() == sDotKey then
				--释放占用格子
				self:setDotKeyUsed(sDotKey, false)
				--隐藏自我
				pDot:setVisibleEx(false)
				return
			end
		end

		for i=1,#self.tBossDots do
			local pDot = self.tBossDots[i]
			if pDot:isVisible() and pDot:getDotKey() == sDotKey then
				--释放占用格子
				self:setDotKeyUsed(sDotKey, false)
				--隐藏自我
				pDot:setVisibleEx(false)
				return
			end
		end
		
		for i=1,#self.tGhostdomDots do
			local pDot = self.tGhostdomDots[i]
			if pDot:isVisible() and  pDot:getDotKey() == sDotKey  then
				--释放占用格子
				self:setDotKeyUsed(sDotKey, false)
				--隐藏自我
				pDot:setVisibleEx(false)
				return
			end
		end

		for i=1,#self.tZhouBossDots do
			local pDot = self.tZhouBossDots[i]
			if pDot:isVisible() and pDot:getIsInDotKey(sDotKey) then
				--释放占用格子
				local tDotKey = pDot:getDotKeys()
				for j=1,#tDotKey do
					local sDotKey = tDotKey[j]
					self:setDotKeyUsed(sDotKey, false)
				end
				--隐藏自我
				self:hideKingZhouNoCtrlBorder(pDot)
				pDot:setVisibleEx(false)
				return
			end
		end
	end
end

--刷新当前的点
function WorldLayer:onDotRefresh( sMsgName, pMsgObj )
	local tViewDotMsg = pMsgObj
	if tViewDotMsg then
		--刷新已有
		if tViewDotMsg.nType == e_type_builddot.city then
			for i=1,#self.tCityDots do
				local pDot = self.tCityDots[i]
				if pDot:isVisible() and pDot:getId() == tViewDotMsg.nCityId then
					pDot:setData(tViewDotMsg)
					self:showMyCityBorder(pDot)
					return
				end
			end
		elseif tViewDotMsg.nType == e_type_builddot.sysCity then
			for i=1,#self.tSysCityDots do
				local pDot = self.tSysCityDots[i]
				if pDot:isVisible() and  pDot:getId() == tViewDotMsg.nSystemCityId  then
					pDot:setData(tViewDotMsg)
					self:showSysCityNoCtrlBorder(pDot)
					return
				end
			end

			for i=1,#self.tImperialCityDots do
				local pDot = self.tImperialCityDots[i]
				if pDot:isVisible() and  pDot:getId() == tViewDotMsg.nSystemCityId  then
					pDot:setData(tViewDotMsg)
					self:showSysCityNoCtrlBorder(pDot)
					return
				end
			end

			for i=1,#self.tFireTowerDots do
				local pDot = self.tFireTowerDots[i]
				if pDot:isVisible() and  pDot:getId() == tViewDotMsg.nSystemCityId  then
					pDot:setData(tViewDotMsg)
					self:showSysCityNoCtrlBorder(pDot)
					return
				end
			end
		elseif tViewDotMsg.nType == e_type_builddot.res then
			for i=1,#self.tResDots do
				local pDot = self.tResDots[i]
				if pDot:isVisible() and  pDot:getDotKey() == tViewDotMsg:getDotKey()  then
					pDot:setData(tViewDotMsg)
					return
				end
			end
		elseif tViewDotMsg.nType == e_type_builddot.wildArmy then
			for i=1,#self.tWildArmyDots do
				local pDot = self.tWildArmyDots[i]
				if pDot:isVisible() and  pDot:getDotKey() == tViewDotMsg:getDotKey()  then
					pDot:setData(tViewDotMsg)
					return
				end
			end
		elseif tViewDotMsg.nType == e_type_builddot.boss then
			for i=1,#self.tBossDots do
				local pDot = self.tBossDots[i]
				if pDot:isVisible() and  pDot:getDotKey() == tViewDotMsg:getDotKey()  then
					pDot:setData(tViewDotMsg)
					return
				end
			end
		elseif tViewDotMsg.nType == e_type_builddot.tlboss then
			--并没有这个视图点
			return
		elseif tViewDotMsg.nType == e_type_builddot.ghostdom then
			for i=1,#self.tGhostdomDots do
				local pDot = self.tGhostdomDots[i]
				if pDot:isVisible() and  pDot:getDotKey() == tViewDotMsg:getDotKey()  then
					pDot:setData(tViewDotMsg)
					return
				end
			end
		elseif tViewDotMsg.nType == e_type_builddot.zhouwang then
			for i=1,#self.tZhouBossDots do
				local pDot = self.tZhouBossDots[i]
				if pDot:isVisible() and pDot:getIsInDotKey(tViewDotMsg:getDotKey()) then
					pDot:setData(tViewDotMsg)
					return
				end
			end
		end

		--新建的视图点
		if tViewDotMsg.nType == e_type_builddot.zhouwang then  --新建纣王
			local pViewRect = self:getShowViewDotRect()	
			local fX, fY = tViewDotMsg:getWorldMapPos()
			if fX and fY then
				local nWidth = 2 * UNIT_WIDTH
				local nHeight = 2 * UNIT_HEIGHT
				local pRect = cc.rect(fX - nWidth/2, fY - nHeight/2, nWidth, nHeight)
				if cc.rectIntersectsRect(pViewRect, pRect) then
					self:refreshItemDots()
				end
			end
		else
			if self:checkIsInView(tViewDotMsg:getDotKey()) then --新建其他点
				self:refreshItemDots()
			end
		end

	end
end


--刷新所有点集
function WorldLayer:refreshItemDots(  )
	--清空所有变更点
	Player:getWorldData():delRefreshDotPosAll()

	--遍历视图内
	local nDotX, nDotY = self:getDotPosByMapPos(self.fViewCX, self.fViewCY - WORLD_BOTTOM_HEIGHT)
	if not nDotX then
		return
	end

	--收集视图内的格子信息给后面使用
	self.tViewDotInfos = {}
	local pViewRect = self:getShowViewDotRect() --显示框大小
	local nGridX = math.ceil(pViewRect.width/ UNIT_WIDTH)
	local nGridY = math.ceil(pViewRect.height/ UNIT_HEIGHT)
	local nBeginRow = nDotX - nGridX
	if nBeginRow < 1 then
		nBeginRow = 1
	end
	local nEndRow = nDotX + nGridX
	if nEndRow > WORLD_GRID then
		nEndRow = WORLD_GRID
	end
	local nBeginCol = nDotY - nGridY
	if nBeginCol < 1 then
		nBeginCol = 1
	end
	local nEndCol = nDotY + nGridY
	if nEndCol > WORLD_GRID then
		nEndCol = WORLD_GRID
	end
	-- dump({nBeginRow=nBeginRow,nEndRow = nEndRow,nBeginCol = nBeginCol,nEndCol = nEndCol})
	local pUnitRect = cc.rect(0,0,UNIT_WIDTH,UNIT_HEIGHT) --单个菱形矩形
	for nRow = nBeginRow, nEndRow do
		for nCol = nBeginCol, nEndCol do
			local nPosX, nPosY = self:getMapPosByDotPos(nRow,nCol)
			pUnitRect.x = nPosX - UNIT_WIDTH/2
			pUnitRect.y = nPosY - UNIT_HEIGHT/2
			--矩形判断有相交就是在视图里-_-
			if cc.rectIntersectsRect(pViewRect, pUnitRect) then
				local sDotKey = string.format("%s_%s", nRow, nCol)
				self.tViewDotInfos[sDotKey] = {nDotX = nRow, nDotY = nCol, nPosX = nPosX, nPosY = nPosY}
			end
		end
	end
	
	--清空已使用点集标记
	self.tUsedDotKey = {}

	--分帧添加的视图点
	self.tFrameViewDots = {}

	--刷新空地
	-- self:refreshNullDots()
	--刷新玩家城池
	self:refreshCityDots()
	--刷新系统城池
	self:refreshSysCityDots()
	--刷新资源
	self:refreshResDots()
	--刷新乱军
	self:refreshWildArmyDots()
	--刷新Boss
	self:refreshBossDots()
	--刷新限时Boss
	self:refreshTLBossDots()
	--刷新宴界
	self:refreshGhostdomDots()
	--纣王试炼视图点刷新
	self:refreshZhouTrialBossDots()

	--刷新装饰点
	self:refreshDecorateDots()

	--进分帧处理的视图点
	self:doFrameViewDots()
end

--添加分帧处理
function WorldLayer:addFrameViewDots( tData )
	table.insert(self.tFrameViewDots, tData)
end

--创建视图点
function WorldLayer:createViewDot( nIndex )
	local tData = self.tFrameViewDots[nIndex]
	if tData then
		--装饰点
		if tData.tDecorateData then
			local pDot = self:getDecorateDot()
			if pDot then
				pDot:setDecorateData(tData.tDecorateData)
				pDot:setPosition(cc.p(tData.fX, tData.fY))
			end
		--限时Boss
		elseif tData.tBossLocatVo then
			local pDot = self:getTLBossDot()
			if pDot then
				pDot:setViewRect(tData.pRect)
				pDot:setData(tData.tBossLocatVo)
				self:setMapDotZoder(pDot)
				pDot:setVisibleEx(true)
				--如果摄机2没有初始化就不处理
				if self:getIsCamera2Inited() then
					--实例化Boss和入场
					pDot:initTLBoss()
					--是否播放出场动画
					local nBlockId = pDot:getBlockId()
					local bIsNew = Player:getTLBossData():getIsNewTLBoss(nBlockId)
					if bIsNew then
						--标记不为新
						Player:getTLBossData():setIsNewTLBoss(nBlockId, false)
						pDot:showTLBossEnter()
					end
				end
			end
		else
			local tViewDotMsg = tData.tViewDotMsg
			if tViewDotMsg then
				-- self:addDebugPoint(tViewDotMsg)
				--系统城池
				if tViewDotMsg.nType == e_type_builddot.sysCity then
					local pDot = nil
					local tCityData = getWorldCityDataById(tViewDotMsg.nSystemCityId)
					if tCityData then
						if tCityData.kind == e_kind_city.zhongxing then
							pDot = self:getImperialCityDot()
						elseif tCityData.kind == e_kind_city.firetown then
							pDot = self:getFireTowerDots()
						else
							pDot = self:getSysCityDot()
						end
					end
					if pDot then
						pDot:setDataByCityId(tViewDotMsg.nSystemCityId)
						pDot:setViewRect(tData.pRect)
						pDot:setDotKeys(tData.tDotKey)
						self:setMapDotZoder(pDot)
						self:showSysCityNoCtrlBorder(pDot)
						pDot:setVisibleEx(true)
					end
				elseif tViewDotMsg.nType == e_type_builddot.city then--玩家城池
					local pDot = self:getCityDot()
					if pDot then
						pDot:setData(tViewDotMsg)
						self:setMapDotZoder(pDot)
						self:showMyCityBorder(pDot)
						pDot:setVisibleEx(true)
					end
				elseif tViewDotMsg.nType == e_type_builddot.res then--资源点
					local pDot = self:getResDot()
					if pDot then
						pDot:setData(tViewDotMsg)
						self:setMapDotZoder(pDot)
						pDot:setVisibleEx(true)
					end
				elseif tViewDotMsg.nType == e_type_builddot.wildArmy then--乱军
					local pDot = self:getWildArmyDot()
					if pDot then
						pDot:setData(tViewDotMsg)
						self:setMapDotZoder(pDot)
						pDot:setVisibleEx(true)
					end
				elseif tViewDotMsg.nType == e_type_builddot.boss then--boss
					local pDot = self:getBossDot()
					if pDot then
						pDot:setData(tViewDotMsg)
						self:setMapDotZoder(pDot)
						pDot:setVisibleEx(true)

						--是否播放
						local sDotKey = tViewDotMsg:getDotKey()
						local bIsNew = Player:getWorldData():getIsNewBoss(sDotKey)
						if bIsNew then

							--标记不为新
							Player:getWorldData():setIsNewBoss(sDotKey, nil)
							--播放升级特效
							local sName = createAnimationBackName("tx/exportjson/", "sg_jzsj_dh_1_001",2,nil,nil,1,{"sg_jzsj_dh_1_0011"})
						    local pArm = ccs.Armature:create(sName)
						    local fX, fY = pDot:getPosition()
						    pArm:setPosition(fX, fY)
						    pArm:setScale(0.5)
						    pDot:getParent():addChild(pArm, pDot:getLocalZOrder() + 1)
						    pArm:getAnimation():play("Animation1", 1)
						    pArm:getAnimation():setMovementEventCallFunc(function ( arm, eventType, movmentID )
								if (eventType == MovementEventType.COMPLETE) then
									pArm:removeSelf()
								end
							end)
						end

					end
				elseif tViewDotMsg.nType == e_type_builddot.ghostdom then--幽魂
					-- print("2361")
					local pDot = self:getGhostdomDot()
					if pDot then
						pDot:setData(tViewDotMsg)
						self:setMapDotZoder(pDot)
						pDot:setVisibleEx(true)
					end
				elseif tViewDotMsg.nType == e_type_builddot.zhouwang then--纣王
					local pDot = self:getZhouTrialBossDot()
					if pDot then
						pDot:setData(tViewDotMsg)
						pDot:setViewRect(tData.pRect)
						pDot:setDotKeys(tData.tDotKey)
						self:setMapDotZoder(pDot)
						pDot:setVisibleEx(true)
						self:showKingZhouNoCtrlBorder(pDot)
					end									
				end
			end
		end
	end
end

--进行分帧处理
function WorldLayer:doFrameViewDots( )
	--第一次不分侦
	if not self.bIsFirstCreateDot then
		self.bIsFirstCreateDot = true
		for i=1,#self.tFrameViewDots do
			self:createViewDot(i)
		end
		self:printDotData()
		return
	end

	-- --环形(有空再做)
	-- local nDotX, nDotY = self:getDotPosByMapPos(self.fViewCX, self.fViewCY - WORLD_BOTTOM_HEIGHT)
	-- if nDotX then
	-- 	local fX, fY = self:getMapPosByDotPos(nDotX, nDotY)
	-- 	if fX then
	-- 		local tFrameViewDots2 = {}
	-- 		local x = 1
	-- 		while true do
				
	-- 		end
	-- 	end
	-- end
	-- for i=1,#self.tFrameViewDots do
		
	-- end


	--近到远排
	local pPosCenter = cc.p(self.fViewCX, self.fViewCY)
	table.sort(self.tFrameViewDots, function ( a, b )
		local fDestA = cc.pGetDistance(pPosCenter, cc.p(a.fX, a.fY))
		local fDestB = cc.pGetDistance(pPosCenter, cc.p(b.fX, b.fY))
		return fDestA < fDestB
	end)

	--圆环
	if false then
		local tFrameViewDotsNew = {}
		local nAngle = 360/8
		for i=1,8 do
			local nCurrAngle = i * nAngle
			local nAngleLeft = nCurrAngle - nAngle
			local nAngleRight = nCurrAngle
			local nLenght = i * 100
			local tDelKey = {}
			for j=1,#self.tFrameViewDots do
				local tDot = self.tFrameViewDots[j]
				local fDestA = cc.pGetDistance(pPosCenter, cc.p(tDot.fX, tDot.fY))
				local nAngle = getAngle(pPosCenter.x, pPosCenter.y, tDot.fX, tDot.fY)
				if nAngle > 360 then
					nAngle = nAngle%360
				end
				if nAngle < -360 then
					nAngle = math.ceil(math.abs(nAngle)/360) + nAngle
				end
				if nAngle < nAngleLeft and nAngle <= nAngleRight then
					if fDestA <= nLenght then
						table.insert(tDelKey, j)
						table.insert(tFrameViewDotsNew, tDot)
					end
				end
			end
			--从后面往上删
			for j=#tDelKey, 1, -1 do
				table.remove(self.tFrameViewDots, tDelKey[j])
			end
		end
		self.tFrameViewDots = nil
		self.tFrameViewDots = tFrameViewDotsNew
	end

	self.nFrameIndex = 1
	local nAddCount = 3
	if not self.nAddcheduler then
		self.nAddcheduler = MUI.scheduler.scheduleUpdateGlobal(function (  )
			for i=1,nAddCount do
				self:createViewDot(self.nFrameIndex)
	    		self.nFrameIndex = self.nFrameIndex + 1
	    		if self.nFrameIndex > #self.tFrameViewDots then
	    			break
				end
			end
			
	    	if self.nFrameIndex > #self.tFrameViewDots then
	    		if self.nAddcheduler then
	            	MUI.scheduler.unscheduleGlobal(self.nAddcheduler)
	            	self.nAddcheduler = nil
	            end

	            --清除超出框的视图点数据
	            --self:delNoUsedViewDotMsgs()

	            self:printDotData()
	    	end
	    end)
	end
end

--清除超出框的视图点数据
function WorldLayer:delNoUsedViewDotMsgs( )
	for i=1,#self.tUnSysCityDots do
		local pDot = self.tUnSysCityDots[i]
		if pDot and not pDot:isVisible() then 
			pDot:delViewDotMsg()
		end
	end
	for i=1,#self.tUnImperialCityDots do
		local pDot = self.tUnImperialCityDots[i]
		if pDot and not pDot:isVisible() then 
			pDot:delViewDotMsg()
		end
	end
	for i=1,#self.tUnFireTowerDots do
		local pDot = self.tUnFireTowerDots[i]
		if pDot and not pDot:isVisible() then 
			pDot:delViewDotMsg()
		end
	end
	for i=1,#self.tUnCityDots do
		local pDot = self.tUnCityDots[i]
		if pDot and not pDot:isVisible() then 
			pDot:delViewDotMsg()
		end
	end
	for i=1,#self.tUnWildArmyDots do
		local pDot = self.tUnWildArmyDots[i]
		if pDot and not pDot:isVisible() then 
			pDot:delViewDotMsg()
		end
	end
	for i=1,#self.tUnResDots do
		local pDot = self.tUnResDots[i]
		if pDot and not pDot:isVisible() then 
			pDot:delViewDotMsg()
		end
	end
	for i=1,#self.tUnBossDots do
		local pDot = self.tUnBossDots[i]
		if pDot and not pDot:isVisible() then 
			pDot:delViewDotMsg()
		end
	end
	for i=1,#self.tUnTLBossDots do
		local pDot = self.tUnTLBossDots[i]
		if pDot and not pDot:isVisible() then 
			pDot:delViewDotMsg()
		end
	end
	for i = 1, self.tUnZhouBossDots do
		local pDot = self.tUnZhouBossDots[i]
		if pDot and not pDot:isVisible() then 
			pDot:delViewDotMsg()
		end
	end	
end

--对应格子是否已用
function WorldLayer:checkIsUsedDotKey( sDotKey )
	return self.tUsedDotKey[sDotKey] ~= nil
end

--使用格子标记
function WorldLayer:setDotKeyUsed( sDotKey, bIsUsed)
	if bIsUsed == nil then
		bIsUsed = true
	end
	self.tUsedDotKey[sDotKey] = bIsUsed
end

--对应格子是否在视图里
function WorldLayer:checkIsInView( sDotKey )
	return self.tViewDotInfos[sDotKey] ~= nil
end

--------------------------------------装饰
--初始化装饰
function WorldLayer:initDecorateDots(  )
	self.tDecorateDots = {}	
	self.tUnDecorateDots = {}
end

--获取格子
function WorldLayer:getDecorateDot()
	local nCount = #self.tUnDecorateDots
	if nCount > 0 then
		local pDot = self.tUnDecorateDots[nCount]
		pDot:setVisible(true)
		table.remove(self.tUnDecorateDots, nCount)
		return pDot
	end
	local pDot = DecorateDot.new()
	local pImageBg = MUI.MImage.new("ui/daitu.png")
	pDot:setZsImg(pImageBg)
	self.pMapDecorateGroup:addView(pImageBg)
	WorldFunc.setCameraMaskForView(pImageBg)
	table.insert(self.tDecorateDots, pDot)
	return pDot
end

--刷新视图内的装饰点集
function WorldLayer:refreshDecorateDots( )
	--设置已占用点
	local function setDotKeyUsed( tDecorateData)
		if not tDecorateData then
			return
		end

		local nStartX, nEndX, nStartY, nEndY = tDecorateData.nStartX, tDecorateData.nEndX, tDecorateData.nStartY, tDecorateData.nEndY
		for j=nStartX,nEndX do
			for k = nStartY, nEndY do
				local sDotKey = string.format("%s_%s",j, k)
				self:setDotKeyUsed(sDotKey)
			end
		end
	end

	--回收不用点
	self.tUnDecorateDots = {}
	--当前视图
	local pViewRect = self:getShowViewDotRect()
	for i=1,#self.tDecorateDots do
		local pDot = self.tDecorateDots[i]
		if pDot then
			--矩形相交判断在否在界面内(因为有可能占用多个格子)
			local pDotRect = pDot:getViewRect()
			if pDotRect and cc.rectIntersectsRect(pViewRect, pDotRect) then
				pDot:setVisible(true)
				--设置占用
				setDotKeyUsed(pDot:getDecorateData())
			else
				--在视图外的就回收
				table.insert(self.tUnDecorateDots, pDot)
			end
		end
	end

	--遍历视图格子内的格子生成对应的
	for sDotKey,v in pairs(self.tViewDotInfos) do
		local nDotX = v.nDotX
		local nDotY = v.nDotY
		local nPosX = v.nPosX
		local nPosY = v.nPosY
		--还没有被占用
		if not self:checkIsUsedDotKey(sDotKey) then
			--判断是否是装饰点
			local tDecorateData = getDecorateData(sDotKey)
			if tDecorateData then
				--设置为占用格子
				setDotKeyUsed(tDecorateData)
				--生成格子
				-- local nZsType = (nDotX * 3 + nDotY + 3) % 10
				--加入分帧处理
				self:addFrameViewDots({tDecorateData = tDecorateData, fX = tDecorateData.tMapPos.x, fY = tDecorateData.tMapPos.y})
			end
		end
	end

	--如果有剩余没有用到的就隐藏
	for i=1,#self.tUnDecorateDots do
		local pDot = self.tUnDecorateDots[i]
		if pDot then
			pDot:setVisible(false)
		end
	end
	-- print("#self.tDecorateDots==============",#self.tDecorateDots)
	-- print("#self.tUnDecorateDots==============",#self.tUnDecorateDots)
	-- print("#self.tViewDotInfos=================",table.nums(self.tViewDotInfos))
end

--设置地图视图点zorder
function WorldLayer:setMapDotZoder( pDot )
	if not pDot then
		return
	end
	local nY = pDot:getPositionY()
	pDot:setLocalZOrder(math.max(WORLD_BG_HEIGHT - nY, 0))
end

--------------------------------------系统城池
--初始化系统城池点
function WorldLayer:initSysCityDots(  )
	self.tSysCityDots = {}	--普通系统城池
	self.tUnSysCityDots = {} --闲置系统城池
	self.tImperialCityDots = {} --皇城
	self.tUnImperialCityDots = {} --闲置皇城
	self.tFireTowerDots = {} --烽火台
	self.tUnFireTowerDots = {} --闲置烽火台
	self.tNoCtrlSCityBorders = {}
	self.tUnNoCtrlSCityBorders = {}

	--初始化4个系统城池
	local tUnSysCityDots = {}
	for i=1,4 do
		local pDot = self:getSysCityDot()
		pDot:setVisible(false)
		table.insert(tUnSysCityDots, pDot)
	end
	self.tUnSysCityDots = tUnSysCityDots
	--初始化系统城池纹理
	self:initSysCityTexture()
end

--初始化系统城池纹理
function WorldLayer:initSysCityTexture(  )
	-- body
end

--获取格子
function WorldLayer:getSysCityDot()
	local nCount = #self.tUnSysCityDots
	if nCount > 0 then
		local pDot = self.tUnSysCityDots[nCount]
		pDot:setVisibleEx(true)
		table.remove(self.tUnSysCityDots, nCount)
		return pDot
	end
	local pImgDot = MUI.MImage.new("ui/daitu.png")
	self.pMapDotGroup:addView(pImgDot)

	local pClickNode = self:createGridEffectLayer()
	local pDot = SysCityDot.new(self, pImgDot, pClickNode)
	table.insert(self.tSysCityDots, pDot)
	self.pMapDotGroup:addView(pDot)
	return pDot
end

--获取皇城
function WorldLayer:getImperialCityDot(  )
	local nCount = #self.tUnImperialCityDots
	if nCount > 0 then
		local pDot = self.tUnImperialCityDots[nCount]
		pDot:setVisibleEx(true)
		table.remove(self.tUnImperialCityDots, nCount)
		return pDot
	end
	local pImgDot = MUI.MImage.new("ui/daitu.png")
	self.pMapDotGroup:addView(pImgDot)
	local pClickNode = self:createGridEffectLayer()
	local pDot = ImperialCityDot.new(self, pImgDot, pClickNode)
	table.insert(self.tImperialCityDots, pDot)
	self.pMapDotGroup:addView(pDot)
	return pDot
end

--获取烽火台
function WorldLayer:getFireTowerDots(  )
	local nCount = #self.tUnFireTowerDots
	if nCount > 0 then
		local pDot = self.tUnFireTowerDots[nCount]
		pDot:setVisibleEx(true)
		table.remove(self.tUnFireTowerDots, nCount)
		return pDot
	end
	local pImgDot = MUI.MImage.new("ui/daitu.png")
	self.pMapDotGroup:addView(pImgDot)
	local pClickNode = self:createGridEffectLayer()
	local pDot = FireTownDot.new(self, pImgDot, pClickNode)
	table.insert(self.tFireTowerDots, pDot)
	self.pMapDotGroup:addView(pDot)
	return pDot
end

--刷新视图内的城池纹理
function WorldLayer:refreshSysCityDots( )
	--设置已占用点
	local function setDotKeyUsed( tDotKey )
		for i=1,#tDotKey do
			local sDotKey = tDotKey[i]
			self:setDotKeyUsed(sDotKey)
		end
	end

	--系统城池数据
	local tDots = Player:getWorldData():getBuildDots(e_type_builddot.sysCity)
	--当前视图
	local pViewRect = self:getShowViewDotRect()
	--已显示城池id集
	local tSysCityId = {}

	--检查是否可以回收
	local function checkIsCanRecovery( pDot )
		--矩形相交判断在否在界面内(因为有可能占用多个格子)
		local pDotRect = pDot:getViewRect()
		if pDotRect and cc.rectIntersectsRect(pViewRect, pDotRect) then
			--更新城池数据
			local nId = pDot:getId()
			if nId then
				local tDot = tDots[nId]
				pDot:setData(tDot)
				pDot:setVisibleEx(true)
				self:showSysCityNoCtrlBorder(pDot)

				--设置为占用格子
				local tDotKey = pDot:getDotKeys()
				if tDotKey then
					setDotKeyUsed(tDotKey)
					tSysCityId[nId] = true
				end
			end
			return false
		else
			--在视图外的就回收
			return true
		end
		return true
	end

	--回收不用点
	--系统城池
	self.tUnSysCityDots = {}
	for i=1,#self.tSysCityDots do
		local pDot = self.tSysCityDots[i]
		if pDot then
			if checkIsCanRecovery(pDot) then
				table.insert(self.tUnSysCityDots, pDot)
			end
		end
	end
	--皇城城池
	self.tUnImperialCityDots = {}
	for i=1,#self.tImperialCityDots do
		local pDot = self.tImperialCityDots[i]
		if pDot then
			if checkIsCanRecovery(pDot) then
				table.insert(self.tUnImperialCityDots, pDot)
			end
		end
	end
	--烽火台
	self.tUnFireTowerDots = {}
	for i=1,#self.tFireTowerDots do
		local pDot = self.tFireTowerDots[i]
		if pDot then
			if checkIsCanRecovery(pDot) then
				table.insert(self.tUnFireTowerDots, pDot)
			end
		end
	end

	--遍历本地配表城池
	--在视图内的，且存在数据的就生成，再设置占用的格子、
	local tWorldCityData = getWorldCityData()
	for k,tCityData in pairs(tWorldCityData) do
		--遍历还没有显示的城市数据
		local nId = tCityData.id
		if not tSysCityId[nId] and tDots[nId] then
			--获取世界坐标
			local pPos = tCityData.tMapPos
			if pPos then
				local nWidth = math.sqrt(tCityData.grid) * UNIT_WIDTH
				local nHeight = math.sqrt(tCityData.grid) * UNIT_HEIGHT
				local pRect = cc.rect(pPos.x - nWidth/2, pPos.y - nHeight/2, nWidth, nHeight)
				--矩形相交判断在否在界面内(因为有可能占用多个格子)
				if cc.rectIntersectsRect(pViewRect, pRect) then
					--点集key
					local tDotKey = {}
					local tCoordinate = tCityData.tCoordinate
					if tCoordinate then
						if tCoordinate.x and tCoordinate.y and tCoordinate.x2 and tCoordinate.y2 then
							for i=tCoordinate.x,tCoordinate.x2 do
								for j=tCoordinate.y,tCoordinate.y2 do
									table.insert(tDotKey, string.format("%s_%s",i,j))
								end
							end
						elseif tCoordinate.x and tCoordinate.y then
							table.insert(tDotKey, string.format("%s_%s", tCoordinate.x,tCoordinate.y))
						end
					end
					--设置为占用格子
					setDotKeyUsed(tDotKey)
					tSysCityId[nId] = true

					--加入分侦处理
					local tViewDotMsg = Player:getWorldData():getSysCityDot(nId)
					if tViewDotMsg then
						local fX, fY = tViewDotMsg:getWorldMapPos()
						if fX then
							self:addFrameViewDots({tViewDotMsg = tViewDotMsg, pRect = pRect, tDotKey = tDotKey, fX = fX, fY = fY})
						end
					end
				end
			end
		end
	end

	--如果有剩余没有用到的就隐藏
	for i=1,#self.tUnSysCityDots do
		local pDot = self.tUnSysCityDots[i]
		if pDot then 
			self:hideSysCityNoCtrlBorder(pDot)
			pDot:setVisibleEx(false)
		end
	end
	for i=1,#self.tUnImperialCityDots do
		local pDot = self.tUnImperialCityDots[i]
		if pDot then 
			self:hideSysCityNoCtrlBorder(pDot)
			pDot:setVisibleEx(false)
		end
	end
	for i=1,#self.tUnFireTowerDots do
		local pDot = self.tUnFireTowerDots[i]
		if pDot then 
			self:hideSysCityNoCtrlBorder(pDot)
			pDot:setVisibleEx(false)
		end
	end

	-- myprint("#self.tSysCityDots==============",#self.tSysCityDots)
	-- myprint("#self.tUnSysCityDots==============",#self.tUnSysCityDots)
end

--显示系统城池不可操作边框
function WorldLayer:showSysCityNoCtrlBorder( pDot )
	local nSysCityId = pDot:getId()
	if nSysCityId then
		local tViewDotMsg = Player:getWorldData():getSysCityDotById(nSysCityId)
		if not tViewDotMsg then
			return
		end
		--图片
		local pNoCtrlBorder = self.tNoCtrlSCityBorders[nSysCityId]
		if not pNoCtrlBorder then
			local sImg = WorldFunc.getWorldCityDotBgImg( tViewDotMsg.nDotCountry )
			--用闲置图片
			local nCount = #self.tUnNoCtrlSCityBorders
			if nCount > 0 then
				pNoCtrlBorder = self.tUnNoCtrlSCityBorders[nCount]
				table.remove(self.tUnNoCtrlSCityBorders, nCount)
				pNoCtrlBorder:setVisible(true)
                pNoCtrlBorder:changeBgImg(sImg)
			else
                pNoCtrlBorder = WorldFunc.getWorldCityDotBgImgLayer(sImg)
				self.pMapViewGroup:addView(pNoCtrlBorder, nSysCityNoCtrlZorder)
				WorldFunc.setCameraMaskForView(pNoCtrlBorder)
			end
			--记录图片所属性
			pNoCtrlBorder.nDotCountry = tViewDotMsg.nDotCountry
			--记录以防重新加载
			self.tNoCtrlSCityBorders[nSysCityId] = pNoCtrlBorder
			
		else
			--复止重复刷新
			if pNoCtrlBorder.nDotCountry ~= tViewDotMsg.nDotCountry then
				pNoCtrlBorder.nDotCountry = tViewDotMsg.nDotCountry
				local sImg = WorldFunc.getWorldCityDotBgImg( tViewDotMsg.nDotCountry )
				--pNoCtrlBorder:setCurrentImage(sImg)
                pNoCtrlBorder:changeBgImg(sImg)
			end
		end

		--位置
		local fX, fY = pDot:getPosition()
		pNoCtrlBorder:setPosition(fX, fY)
		--大小
		local tCityData = getWorldCityDataById(nSysCityId)
		if tCityData then
			if tCityData.kind == e_kind_city.firetown then 
				pNoCtrlBorder:setScale(2*UNIT_WIDTH/808)
			else
				if tCityData.grid == 1 then
					pNoCtrlBorder:setScale(3*UNIT_WIDTH/808)
				elseif tCityData.grid == 4 then
					pNoCtrlBorder:setScale(4*UNIT_WIDTH/808)
				elseif tCityData.grid == 9 then
					pNoCtrlBorder:setScale(5*UNIT_WIDTH/808)
				end
			end
		end
		
	end
end

--隐藏城池不可以边框
function WorldLayer:hideSysCityNoCtrlBorder( pDot )
	local nSysCityId = pDot:getId()
	if nSysCityId then
		local pNoCtrlBorder = self.tNoCtrlSCityBorders[nSysCityId]
		if pNoCtrlBorder then
			pNoCtrlBorder:setVisible(false)
			table.insert(self.tUnNoCtrlSCityBorders, pNoCtrlBorder)
			self.tNoCtrlSCityBorders[nSysCityId] = nil
		end
	end
end

--显示我的城池底框
function WorldLayer:showMyCityBorder( pDot )
	if not isSelectedCountry() then
		return
	end
	--自己也要显示底框
	local tData = pDot:getData()
	if tData:getIsMe() then
		local sImg = WorldFunc.getWorldCityDotBgImg(Player:getPlayerInfo().nInfluence)
		if not self.pImgMyCityBorder then
			--self.pImgMyCityBorder = MUI.MImage.new(sImg)
            self.pImgMyCityBorder = WorldFunc.getWorldCityDotBgImgLayer(sImg)
			self.pImgMyCityBorder:setScale(0.25)

			self.pMapViewGroup:addView(self.pImgMyCityBorder, nSysCityNoCtrlZorder)
			-- 加入斜底
			WorldFunc.setCameraMaskForView(self.pImgMyCityBorder)
		else
			self.pImgMyCityBorder:setVisible(true)
		end
		local fX, fY = pDot:getPosition()
		self.pImgMyCityBorder:setPosition(fX, fY)
	end
end

--隐藏我的城池底框
function WorldLayer:hideMyCityBorder( pDot )
	--自己也要显示底框
	local tData = pDot:getData()
	if tData and tData:getIsMe() then
		if self.pImgMyCityBorder then
			self.pImgMyCityBorder:setVisible(false)
		end
	end
end


--检测是否点系统城池UI
--fX,fY 世界坐标
function WorldLayer:checkIsClickSysCityUis( fX, fY )
	for i=1,#self.tSysCityDots do
		local pDot = self.tSysCityDots[i]
		if pDot and pDot:isVisible() then
			if pDot:checkIsClickedUis(fX, fY) then
				return true
			end
		end
	end
	for i=1,#self.tImperialCityDots do
		local pDot = self.tImperialCityDots[i]
		if pDot and pDot:isVisible() then
			if pDot:checkIsClickedUis(fX, fY) then
				return true
			end
		end
	end
	for i=1,#self.tFireTowerDots do
		local pDot = self.tFireTowerDots[i]
		if pDot and pDot:isVisible() then
			if pDot:checkIsClickedUis(fX, fY) then
				return true
			end
		end
	end
	return false
end

-- --------------------------------------空地
-- --刷新空地
-- function WorldLayer:refreshNullDots(  )
-- 	local tDots = Player:getWorldData():getBuildDots(e_type_builddot.null)
-- 	if not tDots then
-- 		return
-- 	end
-- 	--设置为已使用
-- 	for k,v in pairs(tDots) do
-- 		self:setDotKeyUsed(v.sDotKey)
-- 	end
-- end

--------------------------------------玩家城池
--初始化城池点
function WorldLayer:initCityDots(  )
	self.tCityDots = {}	
	self.tUnCityDots = {}
	--初始化30个玩家城
	local tUnCityDots = {}
	for i=1,30 do
		local pDot = self:getCityDot()
		pDot:setVisible(false)
		table.insert(tUnCityDots, pDot)
	end
	self.tUnCityDots = tUnCityDots
	--初始化玩家城池纹理
	self:initCityTexture()
end

--初始化玩家城池纹理
function WorldLayer:initCityTexture(  )
end

--获取格子
function WorldLayer:getCityDot()
	local nCount = #self.tUnCityDots
	if nCount > 0 then
		local pDot = self.tUnCityDots[nCount]
		pDot:setVisibleEx(true)
		table.remove(self.tUnCityDots, nCount)
		return pDot
	end
	local pImgDot = MUI.MImage.new("ui/daitu.png")
	self.pMapDotGroup:addView(pImgDot)
	local pClickNode = self:createGridEffectLayer()
	local pDot = CityDot.new(self, pImgDot, pClickNode)
	table.insert(self.tCityDots, pDot)
	self.pMapDotGroup:addView(pDot)
	return pDot
end

--刷新视图内的城池纹理
function WorldLayer:refreshCityDots( )
	--玩家城池数据
	local tDots = Player:getWorldData():getBuildDots(e_type_builddot.city)
	-- dump(tDots)
	--回收不用点
	self.tUnCityDots = {}
	for i=1,#self.tCityDots do
		local pDot = self.tCityDots[i]
		if pDot then
			--更新城池数据
			local sDotKey = pDot:getDotKey()
			if sDotKey then
				local tDot = tDots[sDotKey]
				if tDot then
					--在视图内的更新数据和显示
					if self:checkIsInView(sDotKey) then
						pDot:setData(tDot)
						pDot:setVisibleEx(true)
						self:showMyCityBorder(pDot)
						--设置为占用格子
						self:setDotKeyUsed(sDotKey)
					else
						--在视图外的就回收
						table.insert(self.tUnCityDots, pDot)
					end
				else
					--不存在(可能被击飞了)
					table.insert(self.tUnCityDots, pDot)
				end
			else
				-- myprint("城池sDotKey为nil")
				--不存在(数据出错)
				table.insert(self.tUnCityDots, pDot)
			end
		end
	end

	-- if OPEN_DEBUG_PRINT then
	-- 	dump(tDots)
	-- end
	--遍历玩家的城池数据
	for k,v in pairs(tDots) do
		--还没有被占用
		local sDotKey = v.sDotKey
		-- myprint("self:checkIsInView(sDotKey)======",self:checkIsInView(sDotKey),sDotKey)
		if not self:checkIsUsedDotKey(sDotKey) then
			-- if OPEN_DEBUG_PRINT then
			-- 	dump(v)
			-- end
			--在视图格子内
			if self:checkIsInView(sDotKey) then
				--设置为占用格子
				self:setDotKeyUsed(sDotKey)
				--加入分侦处理
				local fX, fY = v:getWorldMapPos()
				if fX then
					self:addFrameViewDots({tViewDotMsg = v, fX = fX, fY = fY})
				end
			end
		end
	end

	--如果有剩余没有用到的就隐藏
	for i=1,#self.tUnCityDots do
		local pDot = self.tUnCityDots[i]
		if pDot then 
			self:hideMyCityBorder(pDot)
			pDot:setVisibleEx(false)
		end
	end
	-- myprint("#self.tCityDots==============",#self.tCityDots)
	-- myprint("#tUnCityDots==============",#tUnCityDots)
end

-- --检测是否点玩家城池
-- function WorldLayer:getClickCity( nDotX, nDotY )
-- 	for i=1,#self.tCityDots do
-- 		local pDot = self.tCityDots[i]
-- 		if pDot and pDot:isVisible() then
-- 			if pDot:isDotPosIn(nDotX, nDotY) then
-- 				return pDot
-- 			end
-- 		end
-- 	end
-- 	return nil
-- end

--检测是否点玩家城池UI
--fX,fY 世界坐标
function WorldLayer:checkIsClickCityUis( fX, fY )
	for i=1,#self.tCityDots do
		local pDot = self.tCityDots[i]
		if pDot and pDot:isVisible() then
			if pDot:checkIsClickedCall(fX, fY) then
				return true
			end
		end
	end
	return false
end
--------------------------------------资源
--初始化资源
function WorldLayer:initResDots(  )
	self.tResDots = {}	
	self.tUnResDots = {}
	--初始化10个资源
	local tUnResDots = {}
	for i=1,10 do
		local pDot = self:getResDot()
		pDot:setVisible(false)
		table.insert(tUnResDots, pDot)
	end
	self.tUnResDots = tUnResDots
	--初始化资源纹理
	self:initResTexture()
end

--初始化资源纹理
function WorldLayer:initResTexture(  )
	-- body
end

--获取格子
function WorldLayer:getResDot()
	local nCount = #self.tUnResDots
	if nCount > 0 then
		local pDot = self.tUnResDots[nCount]
		pDot:setVisibleEx(true)
		table.remove(self.tUnResDots, nCount)
		return pDot
	end
	local pImgDot = MUI.MImage.new("ui/daitu.png")
	self.pMapDotGroup:addView(pImgDot)

	local pDot = ResDot.new(self, pImgDot)
	table.insert(self.tResDots, pDot )
	self.pMapDotGroup:addView(pDot)
	return pDot
end

--刷新视图内的资源点集
function WorldLayer:refreshResDots( )
	--玩家城池数据
	local tDots = Player:getWorldData():getBuildDots(e_type_builddot.res)

	--回收不用点
	self.tUnResDots = {}
	for i=1,#self.tResDots do
		local pDot = self.tResDots[i]
		if pDot then
			--更新资源数据
			local sDotKey = pDot:getDotKey()
			if sDotKey then
				local tDot = tDots[sDotKey]
				if tDot then
					--在视图内的更新数据和显示
					if self:checkIsInView(sDotKey) then
						pDot:setData(tDot)
						pDot:setVisibleEx(true)
						--设置为占用格子
						self:setDotKeyUsed(sDotKey)
					else
						--在视图外的就回收
						table.insert(self.tUnResDots, pDot)
					end
				else
					--不存在(资源被采光了)
					table.insert(self.tUnResDots, pDot)
				end
			else
				-- myprint("资源sDotKey为nil")
				--不存在(数据出错)
				table.insert(self.tUnResDots, pDot)
			end
		end
	end

	--遍历资源数据
	for k,v in pairs(tDots) do
		--还没有被占用
		local sDotKey = v.sDotKey
		if not self:checkIsUsedDotKey(sDotKey) then
			--在视图格子内
			if self:checkIsInView(sDotKey) then
				--设置为占用格子
				self:setDotKeyUsed(sDotKey)
				--加入分帧
				local fX, fY = v:getWorldMapPos()
				if fX then
					self:addFrameViewDots({tViewDotMsg = v, fX = fX, fY = fY})
				end
			end
		end
	end

	--如果有剩余没有用到的就隐藏
	for i=1,#self.tUnResDots do
		local pDot = self.tUnResDots[i]
		if pDot then
			pDot:setVisibleEx(false)
		end
	end

	-- myprint("#self.tResDots==============",#self.tResDots)
	-- myprint("#self.tUnResDots==============",#self.tUnResDots)
end

-- --检测是否点资源
-- function WorldLayer:getClickRes( nDotX, nDotY )
-- 	for i=1,#self.tResDots do
-- 		local pDot = self.tResDots[i]
-- 		if pDot and pDot:isVisible() then
-- 			if pDot:isDotPosIn(nDotX, nDotY) then
-- 				return pDot
-- 			end
-- 		end
-- 	end
-- 	return nil
-- end

--------------------------------------乱军
--初始化乱军
function WorldLayer:initWildArmyDots(  )
	self.tWildArmyDots = {}	
	self.tUnWildArmyDots = {}

	--初始化30个乱军
	local tUnWildArmyDots = {}
	for i=1,30 do
		local pDot = self:getWildArmyDot()
		pDot:setVisible(false)
		table.insert(tUnWildArmyDots, pDot)
	end
	self.tUnWildArmyDots = tUnWildArmyDots
	--初始化乱军纹理
	self:initWildArmyTexture()
end

--初始化乱军纹理
function WorldLayer:initWildArmyTexture(  )
	-- body
end

--获取格子
function WorldLayer:getWildArmyDot()
	local nCount = #self.tUnWildArmyDots
	if nCount > 0 then
		local pDot = self.tUnWildArmyDots[nCount]
		-- pDot:setVisible(true)
		table.remove(self.tUnWildArmyDots, nCount)
		return pDot
	end
	local pImgDot = MUI.MImage.new("ui/daitu.png")
	self.pMapDotGroup:addView(pImgDot)
	local pClickNode = self:createGridEffectLayer()
	local pDot = WildArmyDot.new(self, pImgDot, pClickNode)
	table.insert(self.tWildArmyDots, pDot )
	self.pMapDotGroup:addView(pDot)

	return pDot
end

--刷新视图内的乱军点集
function WorldLayer:refreshWildArmyDots( )
	--乱军数据
	local tDots = Player:getWorldData():getBuildDots(e_type_builddot.wildArmy)
	
	--回收不用点
	self.tUnWildArmyDots = {}
	for i=1,#self.tWildArmyDots do
		local pDot = self.tWildArmyDots[i]
		if pDot then
			--更新乱军数据
			local sDotKey = pDot:getDotKey()
			if sDotKey then
				local tDot = tDots[sDotKey]
				if tDot then
					--在视图内的更新数据和显示
					if self:checkIsInView(sDotKey) then
						pDot:setData(tDot)
						pDot:setVisibleEx(true)
						--设置为占用格子
						self:setDotKeyUsed(sDotKey)
					else
						--在视图外的就回收
						table.insert(self.tUnWildArmyDots, pDot)
					end
				else
					--不存在(乱军被人打死了)
					table.insert(self.tUnWildArmyDots, pDot)
				end
			else
				-- myprint("乱军sDotKey为nil")
				--不存在(数据出错)
				table.insert(self.tUnWildArmyDots, pDot)
			end
		end
	end

	--遍历玩家的城池数据
	for k,v in pairs(tDots) do
		--还没有被占用
		local sDotKey = v.sDotKey
		if not self:checkIsUsedDotKey(sDotKey) then
			--在视图格子内
			if self:checkIsInView(sDotKey) then
				--设置为占用格子
				self:setDotKeyUsed(sDotKey)
				--加入分帧处理
				local fX, fY = v:getWorldMapPos()
				if fX then
					self:addFrameViewDots({tViewDotMsg = v, fX = fX, fY = fY})
				end
			end
		end
	end

	--如果有剩余没有用到的就隐藏
	for i=1,#self.tUnWildArmyDots do
		local pDot = self.tUnWildArmyDots[i]
		if pDot then
			pDot:setVisibleEx(false)
		end
	end
	-- myprint("#self.tWildArmyDots==============",#self.tWildArmyDots)
	-- myprint("#self.tUnWildArmyDots==============",#self.tUnWildArmyDots)
end

-- --检测是否点乱军
-- function WorldLayer:getClickWildEnemy( nDotX, nDotY )
-- 	for i=1,#self.tWildArmyDots do
-- 		local pDot = self.tWildArmyDots[i]
-- 		if pDot and pDot:isVisible() then
-- 			if pDot:isDotPosIn(nDotX, nDotY) then
-- 				return pDot
-- 			end
-- 		end
-- 	end
-- 	return nil
-- end

--------------------------------------Boss
--初始化Boss
function WorldLayer:initBossDots(  )
	self.tBossDots = {}	
	self.tUnBossDots = {}
end

--获取格子
function WorldLayer:getBossDot()
	local nCount = #self.tUnBossDots
	if nCount > 0 then
		local pDot = self.tUnBossDots[nCount]
		pDot:setVisibleEx(true)
		table.remove(self.tUnBossDots, nCount)
		return pDot
	end
	local pImgDot = MUI.MImage.new("ui/daitu.png")
	self.pMapDotGroup:addView(pImgDot)
	local pClickNode = self:createGridEffectLayer()
	local pDot = BossDot.new(self, pImgDot, pClickNode)
	table.insert(self.tBossDots, pDot )
	self.pMapDotGroup:addView(pDot)

	return pDot
end

--刷新视图内的Boss点集
function WorldLayer:refreshBossDots( )
	--乱军数据
	local tDots = Player:getWorldData():getBuildDots(e_type_builddot.boss)
	
	--回收不用点
	self.tUnBossDots = {}
	for i=1,#self.tBossDots do
		local pDot = self.tBossDots[i]
		if pDot then
			--更新乱军数据
			local sDotKey = pDot:getDotKey()
			if sDotKey then
				local tDot = tDots[sDotKey]
				if tDot and tDot:getBossLeaveCd() > 0 then
					--在视图内的更新数据和显示
					if self:checkIsInView(sDotKey) then
						pDot:setData(tDot)
						pDot:setVisibleEx(true)
						--设置为占用格子
						self:setDotKeyUsed(sDotKey)
					else
						--在视图外的就回收
						table.insert(self.tUnBossDots, pDot)
					end
				else
					--不存在(乱军被人打死了)
					table.insert(self.tUnBossDots, pDot)
				end
			else
				-- myprint("乱军sDotKey为nil")
				--不存在(数据出错)
				table.insert(self.tUnBossDots, pDot)
			end
		end
	end

	--遍历乱军的城池数据
	for k,v in pairs(tDots) do
		--还没有被占用
		local sDotKey = v.sDotKey
		if not self:checkIsUsedDotKey(sDotKey) then
			--在视图格子内
			if self:checkIsInView(sDotKey) then
				--设置为占用格子
				self:setDotKeyUsed(sDotKey)
				--加入分帧处理
				local fX, fY = v:getWorldMapPos()
				if fX then
					self:addFrameViewDots({tViewDotMsg = v, fX = fX, fY = fY})
				end
			end
		end
	end

	--如果有剩余没有用到的就隐藏
	for i=1,#self.tUnBossDots do
		local pDot = self.tUnBossDots[i]
		if pDot then
			pDot:setVisibleEx(false)
		end
	end
end

--检测是否点BossUI
--fX,fY 世界坐标
function WorldLayer:checkIsClickBossUis( fX, fY )
	for i=1,#self.tBossDots do
		local pDot = self.tBossDots[i]
		if pDot and pDot:isVisible() then
			if pDot:checkIsClickedWar(fX, fY) then
				return true
			end
		end
	end
	return false
end

--------------------------------------限时Boss
--初始化限时Boss
function WorldLayer:initTLBossDots(  )
	self.tTLBossDots = {}	
	self.tUnTLBossDots = {}
	self.tNoCtrlTLBossBorders = {}
	self.tUnNoCtrlTLBossBorders = {}
end

--获取格子
function WorldLayer:getTLBossDot()
	local nCount = #self.tUnTLBossDots
	if nCount > 0 then
		local pDot = self.tUnTLBossDots[nCount]
		pDot:setVisibleEx(true)
		table.remove(self.tUnTLBossDots, nCount)
		return pDot
	end
	local pDot = TLBossDot.new(self)
	table.insert(self.tTLBossDots, pDot)
	self.pMapDotGroup:addView(pDot)

	return pDot
end

--刷新视图内的限时Boss纹理
function WorldLayer:refreshTLBossDots( )
	--设置已占用点
	local function setDotKeyUsed( tDotKey )
		for i=1,#tDotKey do
			local sDotKey = tDotKey[i]
			self:setDotKeyUsed(sDotKey)
		end
	end

	--状态未开不显示
	local bIsShow = Player:getTLBossData():getIsShowWorldTLBoss()

	--限时Boss数据
	local tBLocatVos = Player:getTLBossData():getBLocatVos()

	--当前视图
	local pViewRect = self:getShowViewDotRect()
	--已显示限时Bossid集
	local tShowTLBossId = {}

	--回收不用点
	self.tUnTLBossDots = {}
	for i=1,#self.tTLBossDots do
		local pDot = self.tTLBossDots[i]
		if pDot then
			local nId = pDot:getBlockId()
			if nId and bIsShow then
				local tBLocatVo = tBLocatVos[nId]
				if tBLocatVo then
					--矩形相交判断在否在界面内(因为有可能占用多个格子)
					local pDotRect = pDot:getViewRect()
					if pDotRect and cc.rectIntersectsRect(pViewRect, pDotRect) then
						--更新限时Boss数据
						pDot:setData(tBLocatVo)
						pDot:setVisibleEx(true)
						-- self:showTLBossNoCtrlBorder(pDot)

						--设置为占用格子
						local tDotKey = tBLocatVo:getDotKeys()
						if tDotKey then
							setDotKeyUsed(tDotKey)
							tShowTLBossId[nId] = true
						end
					else
						--在视图外的就回收
						table.insert(self.tUnTLBossDots, pDot)
					end
				else
					--已经离开就要回收
					table.insert(self.tUnTLBossDots, pDot)
				end
			else
				 --没有id就要回收
				table.insert(self.tUnTLBossDots, pDot)
			end
		end
	end

	--在视图内的，且存在数据的就生成，再设置占用的格子、
	if bIsShow then
		for k,tBLocatVo in pairs(tBLocatVos) do
			--遍历还没有显示的限时数据
			local nId = tBLocatVo:getBlockId()
			if not tShowTLBossId[nId] then
				--获取世界坐标
				local fX, fY = tBLocatVo:getWorldMapPos()
				if fX and fY then
					--占3个格
					local nWidth = 3 * UNIT_WIDTH
					local nHeight = 3 * UNIT_HEIGHT
					local pRect = cc.rect(fX - nWidth/2, fY - nHeight/2, nWidth, nHeight)
					--矩形相交判断在否在界面内(因为有可能占用多个格子)
					if cc.rectIntersectsRect(pViewRect, pRect) then
						--点集key
						local tDotKey = tBLocatVo:getDotKeys()
						--设置为占用格子
						setDotKeyUsed(tDotKey)
						tShowTLBossId[nId] = true
						--加入分侦处理
						self:addFrameViewDots({tBossLocatVo = tBLocatVo, pRect = pRect, fX = fX, fY = fY, tDotKey = tDotKey})
					end
				end
			end
		end
	end

	--如果有剩余没有用到的就隐藏
	for i=1,#self.tUnTLBossDots do
		local pDot = self.tUnTLBossDots[i]
		if pDot then 
			-- self:hideTLBossNoCtrlBorder(pDot)
			pDot:setVisibleEx(false)
		end
	end
end

--显示限时Boss不可操作边框
function WorldLayer:showTLBossNoCtrlBorder( pDot )
	local nBlockId = pDot:getBlockId()
	if nBlockId then
		--图片
		local pNoCtrlBorder = self.tNoCtrlTLBossBorders[nBlockId]
		if not pNoCtrlBorder then
			local sImg = "#v1_line_sj_gray.png"
			--用闲置图片
			local nCount = #self.tUnNoCtrlTLBossBorders
			if nCount > 0 then
				pNoCtrlBorder = self.tUnNoCtrlTLBossBorders[nCount]
				table.remove(self.tUnNoCtrlTLBossBorders, nCount)
				pNoCtrlBorder:setVisible(true)
				pNoCtrlBorder:setCurrentImage(sImg)
			else
				pNoCtrlBorder = MUI.MImage.new(sImg)
				self.pMapViewGroup:addView(pNoCtrlBorder, nTLBossNoCtrlZorder)
				WorldFunc.setCameraMaskForView(pNoCtrlBorder)
			end

			--位置
			local fX, fY = pDot:getPosition()
			pNoCtrlBorder:setPosition(fX, fY)
			--大小
			pNoCtrlBorder:setScale(5*UNIT_WIDTH/808)
			--记录以防重新加载
			self.tNoCtrlTLBossBorders[nBlockId] = pNoCtrlBorder
		end
	end
end

--隐藏限时Boss不可以边框
function WorldLayer:hideTLBossNoCtrlBorder( pDot )
	local nBlockId = pDot:getBlockId()
	if nBlockId then
		local pNoCtrlBorder = self.tNoCtrlTLBossBorders[nBlockId]
		if pNoCtrlBorder then
			pNoCtrlBorder:setVisible(false)
			table.insert(self.tUnNoCtrlTLBossBorders, pNoCtrlBorder)
			self.tNoCtrlTLBossBorders[nBlockId] = nil
		end
	end
end

--------------------------------------幽魂
--初始化幽魂
function WorldLayer:initGhostdomDots(  )
	self.tGhostdomDots = {}	
	self.tUnGhostdomDots = {}

	--初始化30个幽魂
	local tUnGhostdomDots = {}
	-- for i=1,30 do
	-- 	local pDot = self:getGhostdomDot()
	-- 	pDot:setVisible(false)
	-- 	table.insert(tUnGhostdomDots, pDot)
	-- end
	self.tUnGhostdomDots = tUnGhostdomDots
	
end

--获取格子
function WorldLayer:getGhostdomDot()
	local nCount = #self.tUnGhostdomDots
	if nCount > 0 then
		local pDot = self.tUnGhostdomDots[nCount]
		-- pDot:setVisible(true)
		table.remove(self.tUnGhostdomDots, nCount)
		return pDot
	end
	local pImgDot = MUI.MImage.new("ui/daitu.png")
	self.pMapDotGroup:addView(pImgDot)
	local pClickNode = self:createGridEffectLayer()
	local pDot = GhostdomDot.new(self, pImgDot, pClickNode)
	table.insert(self.tGhostdomDots, pDot )
	self.pMapDotGroup:addView(pDot)

	return pDot
end

--刷新视图内的幽魂点集
function WorldLayer:refreshGhostdomDots( )
	--乱军数据
	local tDots = Player:getWorldData():getBuildDots(e_type_builddot.ghostdom)
	
	--回收不用点
	self.tUnGhostdomDots = {}
	for i=1,#self.tGhostdomDots do
		local pDot = self.tGhostdomDots[i]
		if pDot then
			--更新幽魂数据
			local sDotKey = pDot:getDotKey()
			if sDotKey then
				local tDot = tDots[sDotKey]
				if tDot then
					--在视图内的更新数据和显示
					if self:checkIsInView(sDotKey) then
						pDot:setData(tDot)
						pDot:setVisibleEx(true)
						--设置为占用格子
						self:setDotKeyUsed(sDotKey)
					else
						--在视图外的就回收
						table.insert(self.tUnGhostdomDots, pDot)
					end
				else
					--不存在(乱军被人打死了)
					table.insert(self.tUnGhostdomDots, pDot)
				end
			else
				-- myprint("乱军sDotKey为nil")
				--不存在(数据出错)
				table.insert(self.tUnGhostdomDots, pDot)
			end
		end
	end

	--遍历玩家的城池数据
	for k,v in pairs(tDots) do
		--还没有被占用
		local sDotKey = v.sDotKey
		if not self:checkIsUsedDotKey(sDotKey) then
			--在视图格子内
			if self:checkIsInView(sDotKey) then
				--设置为占用格子
				self:setDotKeyUsed(sDotKey)
				--加入分帧处理
				local fX, fY = v:getWorldMapPos()
				if fX then
					self:addFrameViewDots({tViewDotMsg = v, fX = fX, fY = fY})
				end
			end
		end
	end

	--如果有剩余没有用到的就隐藏
	for i=1,#self.tUnGhostdomDots do
		local pDot = self.tUnGhostdomDots[i]
		if pDot then
			pDot:setVisibleEx(false)
		end
	end
	-- myprint("#self.tWildArmyDots==============",#self.tWildArmyDots)
	-- myprint("#self.tUnWildArmyDots==============",#self.tUnWildArmyDots)
end

--------------------------------------纣王试炼boss
--初始化Boss
function WorldLayer:initZhouTrialBossDots(  )
	self.tZhouBossDots = {}	
	self.tUnZhouBossDots = {}

	self.tNoCtrlKingZhouBorders = {}
	self.tUnNoCtrlKingZhouBorders = {}	
end

--获取格子
function WorldLayer:getZhouTrialBossDot()
	local nCount = #self.tUnZhouBossDots
	if nCount > 0 then
		local pDot = self.tUnZhouBossDots[nCount]
		pDot:setVisibleEx(true)
		table.remove(self.tUnZhouBossDots, nCount)
		return pDot
	end
	local pImgDot = MUI.MImage.new("ui/daitu.png")
	self.pMapDotGroup:addView(pImgDot)
	local pClickNode = self:createGridEffectLayer()
	local pDot = ZhouTrialDot.new(self, pImgDot, pClickNode)
	table.insert(self.tZhouBossDots, pDot )
	self.pMapDotGroup:addView(pDot)

	return pDot
end

--刷新视图内的Boss点集
function WorldLayer:refreshZhouTrialBossDots( )

	--设置已占用点
	local function setDotKeyUsed( tDotKey )
		if tDotKey then
			for i=1,#tDotKey do
				local sDotKey = tDotKey[i]
				self:setDotKeyUsed(sDotKey)
			end
		end
	end	
	--纣王数据
	local tDots = Player:getWorldData():getBuildDots(e_type_builddot.zhouwang)
	--当前视图
	local pViewRect = self:getShowViewDotRect()	
	--已显示纣王id集
	local tShowZhouTrialId = {}
	--回收不用点
	self.tUnZhouBossDots = {}
	for i=1,#self.tZhouBossDots do
		local pDot = self.tZhouBossDots[i]
		if pDot then
			--更新乱军数据
			local sDotKey = pDot:getDotKey()
			if sDotKey then
				local tDot = tDots[sDotKey]
				if tDot and tDot:getZhouWangLeaveCd() > 0 then
					--在视图内的更新数据和显示
					local pDotRect = pDot:getViewRect()
					if pDotRect and cc.rectIntersectsRect(pViewRect, pDotRect) then
						pDot:setData(tDot)
						pDot:setVisibleEx(true)
						self:showKingZhouNoCtrlBorder(pDot)
						--设置为占用格子				
						local tDotKey = tDot:getDotKeys()
						setDotKeyUsed(tDotKey)
						tShowZhouTrialId[tDot.sDotKey] = true
					else
						--在视图外的就回收
						table.insert(self.tUnZhouBossDots, pDot)
					end
				else
					--不存在(乱军被人打死了)
					table.insert(self.tUnZhouBossDots, pDot)
				end
			else
				--不存在(数据出错)
				table.insert(self.tUnZhouBossDots, pDot)
			end
		end
	end

	--遍历纣王试炼数据
	for k,v in pairs(tDots) do
		--还没有被占用
		local sDotKey = v.sDotKey
		if not tShowZhouTrialId[sDotKey] then
			local fX, fY = v:getWorldMapPos()
			if fX and fY then
				--占3个格
				local nWidth = 2 * UNIT_WIDTH
				local nHeight = 2 * UNIT_HEIGHT
				local pRect = cc.rect(fX - nWidth/2, fY - nHeight/2, nWidth, nHeight)
				if cc.rectIntersectsRect(pViewRect, pRect) then
					local tDotKey = v:getDotKeys()
					setDotKeyUsed(tDotKey)
					tShowZhouTrialId[sDotKey] = true
					--加入分侦处理
					self:addFrameViewDots({tViewDotMsg = v, pRect = pRect, fX = fX, fY = fY, tDotKey = tDotKey})
				end
			end
		end
	end

	--如果有剩余没有用到的就隐藏
	for i=1,#self.tUnZhouBossDots do
		local pDot = self.tUnZhouBossDots[i]
		if pDot then
			self:hideKingZhouNoCtrlBorder(pDot)
			pDot:setVisibleEx(false)			
		end
	end
end

--显示限时Boss不可操作边框
function WorldLayer:showKingZhouNoCtrlBorder( pDot )
	local sDotKey = pDot:getDotKey()	
	if sDotKey then
		--图片
		local pNoCtrlBorder = self.tNoCtrlKingZhouBorders[sDotKey]
		if not pNoCtrlBorder then
			local sImg = WorldFunc.getWorldCityDotBgImg( 4 )
			--用闲置图片
			local nCount = #self.tUnNoCtrlKingZhouBorders
			if nCount > 0 then
				pNoCtrlBorder = self.tUnNoCtrlKingZhouBorders[nCount]
				table.remove(self.tUnNoCtrlKingZhouBorders, nCount)
				pNoCtrlBorder:setVisible(true)
				pNoCtrlBorder:changeBgImg(sImg)
			else
				pNoCtrlBorder = WorldFunc.getWorldCityDotBgImgLayer(sImg)
				self.pMapViewGroup:addView(pNoCtrlBorder, nTLBossNoCtrlZorder)
				WorldFunc.setCameraMaskForView(pNoCtrlBorder)
			end
			--位置
			local fX, fY = pDot:getPosition()
			pNoCtrlBorder:setPosition(fX, fY)
			--大小
			pNoCtrlBorder:setScale(2*UNIT_WIDTH/808)			
			--记录以防重新加载
			self.tNoCtrlKingZhouBorders[sDotKey] = pNoCtrlBorder
		end
	end
end

--隐藏限时Boss不可以边框
function WorldLayer:hideKingZhouNoCtrlBorder( pDot )
	local sDotKey = pDot:getDotKey()	
	if sDotKey then
		local pNoCtrlBorder = self.tNoCtrlKingZhouBorders[sDotKey]
		if pNoCtrlBorder then			
			pNoCtrlBorder:setVisible(false)
			table.insert(self.tUnNoCtrlKingZhouBorders, pNoCtrlBorder)
			self.tNoCtrlKingZhouBorders[sDotKey] = nil
		end
	end
end

-- --检测是否点乱军
-- function WorldLayer:getClickWildEnemy( nDotX, nDotY )
-- 	for i=1,#self.tWildArmyDots do
-- 		local pDot = self.tWildArmyDots[i]
-- 		if pDot and pDot:isVisible() then
-- 			if pDot:isDotPosIn(nDotX, nDotY) then
-- 				return pDot
-- 			end
-- 		end
-- 	end
-- 	return nil
-- end
-----------------------------消息处理
--是否在未解锁的区域，是就弹出相关提示
function WorldLayer:checkIsInLockBlock( nDotX, nDotY )
	return WorldFunc.checkIsInLockBlock(nDotX, nDotY)
end

--跳转和点击
--bIsClick 显示点击特效（之前是显示二级界面。。。）
--tOther 执行其他操作
function WorldLayer:jumpToPosAndClick( fX ,fY, bIsClick, tOther)
	self:hideCityClickLayer()
	self.nDelayClickPos = nil
	self.tDelayOther = tOther
	if not fX or not fY then
		return
	end
	--设置点击
	if bIsClick then
		self.nDelayClickPos = cc.p(fX, fY)
	end
	if self.tDelayOther then
		self.tDelayOther.__tPos = cc.p(fX, fY)
	end
	--跳
	self:JumpToMapPos(fX, fY)
end

--定位位置消息(世界坐标点)
function WorldLayer:onLocationMapPosMsg( sMsgName, pMsgObj )
	--容错
	if pMsgObj and pMsgObj.fX and pMsgObj.fY then
		--世界未开启，返回
		local bIsOpen = getIsReachOpenCon(4, true)
		if not bIsOpen then
			return
		end
		
		--区域没有开启
		local nX, nY = WorldFunc.getDotPosByMapPos(pMsgObj.fX, pMsgObj.fY )
		if self:checkIsInLockBlock(nX, nY) then
			return
		end

		--切换世界地图
		sendMsg(ghd_home_show_base_or_world, 2)

		--如果跳转的是纣王来袭就打开UI界面
		if Player:getTLBossData():getIsShowWorldTLBoss() then
			local tBLocatVos = Player:getTLBossData():getBLocatVos()
			for k, tBLocatVo in pairs(tBLocatVos) do
				local nTLBossX, nTLBossY = tBLocatVo:getX(), tBLocatVo:getY()
				if nX == nTLBossX and nY == nTLBossY then
					pMsgObj.tOther = {bIsOpenTLBoss = true}
				end
			end
		end
		
		self:jumpToPosAndClick(pMsgObj.fX, pMsgObj.fY, pMsgObj.isClick, pMsgObj.tOther)
	end
end

--定位位置消息(视图坐标点)
function WorldLayer:onLocationDotPosMsg( sMsgName, pMsgObj )
	--容错
	if pMsgObj and pMsgObj.nX and pMsgObj.nY then
		--世界未开启，返回
		local bIsOpen = getIsReachOpenCon(4, true)
		if not bIsOpen then
			return
		end

		local nX, nY = pMsgObj.nX, pMsgObj.nY

		--区域没有开启
		if self:checkIsInLockBlock(nX, nY) then
			return
		end

		--切换世界地图
		sendMsg(ghd_home_show_base_or_world, 2)

		--如果跳转的是纣王来袭就打开UI界面
		if Player:getTLBossData():getIsShowWorldTLBoss() then
			local tBLocatVos = Player:getTLBossData():getBLocatVos()
			for k, tBLocatVo in pairs(tBLocatVos) do
				local nTLBossX, nTLBossY = tBLocatVo:getX(), tBLocatVo:getY()
				if nX == nTLBossX and nY == nTLBossY then
					pMsgObj.tOther = {bIsOpenTLBoss = true}
				end
			end
		end
		
		local fX, fY = WorldFunc.getMapPosByDotPosEx( nX, nY )
		self:jumpToPosAndClick(fX, fY, pMsgObj.isClick, pMsgObj.tOther)
	end
end

--定位位置消息(视图坐标点)GM测试
function WorldLayer:onLocationDotPosMsgGM( sMsgName, pMsgObj )
	--容错
	if pMsgObj and pMsgObj.nX and pMsgObj.nY then
		local nX, nY = pMsgObj.nX, pMsgObj.nY

		--切换世界地图
		sendMsg(ghd_home_show_base_or_world, 2)
		
		local fX, fY = WorldFunc.getMapPosByDotPosEx( nX, nY )
		self:jumpToPosAndClick(fX, fY, pMsgObj.isClick, pMsgObj.tOther)
	end
end

--定位我的城市加选中
function WorldLayer:onLocationMyPosMsg( sMsgName, pMsgObj )
	--世界未开启，返回
	local bIsOpen = getIsReachOpenCon(4, true)
	if not bIsOpen then
		return
	end

	--切换世界地图
	sendMsg(ghd_home_show_base_or_world, 2)

	local nX, nY = Player:getWorldData():getMyCityDotPos()
	local fX, fY = WorldFunc.getMapPosByDotPos( nX, nY )
	self:jumpToPosAndClick(fX, fY, true)
		
	if pMsgObj and pMsgObj.bIsOpenWar then
		--自己城池处于城战状态定位过去需要打开城战面板
		if Player:getWorldData():getOtherIsAttackMe() then
			--发送城战请求
			local tViewDotMsg = Player:getWorldData():getMyViewDotMsg()
			if tViewDotMsg then
				sendMsg(ghd_send_city_war_req, tViewDotMsg)
			end
		end
	end
end

--定位附近的点
function WorldLayer:onLocationDotFinger( sMsgName, pMsgObj )
	--世界未开启，返回
	local bIsOpen = getIsReachOpenCon(4, true)
	if not bIsOpen then
		return
	end
	
	if not pMsgObj.nDotType then
		return
	end
	--是否隐藏手指
	self.bHideFinger = pMsgObj.bHideFinger

	--记录想定位的视图类型
	self.bSearhDotClicked = pMsgObj.bIsClicked
	self.nSearhDotTypeNear = pMsgObj.nDotType
	self.nSearhDotLv       = pMsgObj.nDotLv

	self.nJumpType=pMsgObj.nJumpType
	self.nGuideFingerId		   = pMsgObj.nFingerId
	self.tSearhSysCityData = nil
	--定位系统城池
	if self.nSearhDotTypeNear == e_type_builddot.sysCity then
		--根据系统城池类型定位
		if pMsgObj.nSysCityId then
			local tCityData = getWorldCityDataById(pMsgObj.nSysCityId)
			if tCityData then
				self.tSearhSysCityData = tCityData
				local nLoadTime = getSystemTime(false)
				SocketManager:sendMsg("reqWorldAroundDot", {self.tSearhSysCityData.tCoordinate.x, self.tSearhSysCityData.tCoordinate.y,nLoadTime}, handler(self, self.showDotFinger),-1)
			end
		end
		
	--定位城池附近的视图点
	else
		--请求我的城池附近的数据
		local nX, nY = Player:getWorldData():getMyCityDotPos()
		local nLoadTime = getSystemTime(false)
		SocketManager:sendMsg("reqWorldAroundDot", {nX, nY,nLoadTime}, handler(
			self, self.showDotFinger),-1)
	end

end

--显示手指头
function WorldLayer:__showFinger( fX, fY )
	if not fX or not fY then
		return
	end
	
	if getIsNoFingerSeq() then
		return
	end

	if not self.pLayFinger then
		self.pLayFinger = MUI.MLayer.new()
  		self.pMapDotGroup:addView(self.pLayFinger)
	end
	self.pLayFinger:setPosition(fX, fY)

	--移动
	closeDlgByType(e_dlg_index.dotfinger)
	local DlgFlow = require("app.common.dialog.DlgFlow")
	local pDlg,bNew = getDlgByType(e_dlg_index.dotfinger)
	if(not pDlg) then
		pDlg = DlgFlow.new(e_dlg_index.dotfinger)
	end
	local DotFinger = require("app.layer.world.DotFinger")
	local pChildView = DotFinger.new()
	pDlg:showChildView(pView, pChildView)
	pDlg:setToCenter()
	pChildView:setData(self.pLayFinger)
	UIAction.enterDialog( pDlg, RootLayerHelper:getCurRootLayer(), bNew)
	pDlg:setDialogBgColor(GLOBAL_DIALOG_BG_COLOR_TRANSPARENT)
end

--弹框隐藏手指
function WorldLayer:hideDotFinger( sMsgName, pMsgObj )
	if pMsgObj == false then
		closeDlgByType(e_dlg_index.dotfinger)
	end
end

--显示视图点的手指头
function WorldLayer:showDotFinger( __msg, __oldMsg )
	if  __msg.head.state == SocketErrorType.success then
        if __msg.head.type == MsgType.reqWorldAroundDot.id then
        	--容错
			if not self.nSearhDotTypeNear then
				return
			end
			--空地
			if self.nSearhDotTypeNear == e_type_builddot.null then

				--切换世界地图
				sendMsg(ghd_home_show_base_or_world, 2)

				local nX, nY = Player:getWorldData():getNullPosNear()
				if nX and nY then
					local fX, fY = WorldFunc.getMapPosByDotPos( nX, nY )
					--跳到具体位置
					self:JumpToMapPos(fX, fY)
					----------------------------找机会整理znftodo
					--点击特效
					self:showClickEffect(fX, fY, size)
					--展开
					local tNullDotMsg = {
						nX = nX,	
						nY = nY,
						nType = e_type_builddot.null,
					}
					self:showCityClickLayer(fX, fY, tNullDotMsg)
				else
					--定位到我的城池
					self:JumpToMyCityDot()
				end
				
			elseif self.nSearhDotTypeNear == e_type_builddot.sysCity then --系统城池
				--容错
				if not self.tSearhSysCityData then
					return
				end
				--切换世界地图
				sendMsg(ghd_home_show_base_or_world, 2)
				self:JumpToMapPos(self.tSearhSysCityData.tMapPos.x, self.tSearhSysCityData.tMapPos.y)

				--获取城池视图点Ui
				local fX, fY = self.tSearhSysCityData.tMapPos.x, self.tSearhSysCityData.tMapPos.y
				self:__showFinger(fX, fY)
			else
				local tViewDotMsg = Player:getWorldData():getViewDotMsgNear(self.nSearhDotTypeNear, self.nSearhDotLv)
				if tViewDotMsg then
					--定位到主要位置
					local fX, fY = tViewDotMsg:getWorldMapPos()
					if not fX then
						return
					end
					
					--切换世界地图
					sendMsg(ghd_home_show_base_or_world, 2)
					self:jumpToPosAndClick(fX, fY, self.bSearhDotClicked)

					--当前是不显示手指时候
					if not self.bHideFinger then
						--乱军
						if self.nSearhDotTypeNear == e_type_builddot.wildArmy then
							--箭头不同时显示
							local nArmyLv = Player:getWorldData():getWildArmyCirEffectLv() --需要显示箭头特效的乱军等级
							if nArmyLv ~= tViewDotMsg:getDotLv() then
								--获取乱军视图点Ui
								self:__showFinger(fX, fY)
							end
						end
					end
				else--定位到我的城池
					--切换世界地图
					sendMsg(ghd_home_show_base_or_world, 2)
					self:JumpToMyCityDot()
				end
			end
			--清空数据
			self.nSearhDotTypeNear = nil
			self.tSearhSysCityData = nil
			self.bSearhDotClicked = nil
        end
    else
    	--切换世界地图
		sendMsg(ghd_home_show_base_or_world, 2)
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end

--迁城
function WorldLayer:onMigrateMsg( sMsgName, pMsgObj)
	--OPEN_DEBUG_PRINT = true
	--更新我的城池信息
	self:onMyCityChange()
	--更新我的城池信息
	self:initMyCityData()
	--跳转我的城池信息
	self:JumpToMyCityDot()
end

--
function WorldLayer:onSearchAroundMsg(sMsgName, pMsgObj)
	if pMsgObj then
		--设置已搜索点
		Player:getWorldData():setPrevSearchDot(pMsgObj.nX, pMsgObj.nY)
	end
	self:refreshItemDots()
end

--视图点进击特效
function WorldLayer:updateAtkEffects( )
	--系统城池是否被击
	for i=1,#self.tSysCityDots do
		local pDot = self.tSysCityDots[i]
		if pDot and pDot:isVisible() then
			pDot:updateAtkEffect()
		end
	end
	for i=1,#self.tImperialCityDots do
		local pDot = self.tImperialCityDots[i]
		if pDot and pDot:isVisible() then
			pDot:updateAtkEffect()
		end
	end
	for i=1,#self.tFireTowerDots do
		local pDot = self.tFireTowerDots[i]
		if pDot and pDot:isVisible() then
			pDot:updateAtkEffect()
		end
	end

	--系统城池是否被击
	for i=1,#self.tCityDots do
		local pDot = self.tCityDots[i]
		if pDot and pDot:isVisible() then
			pDot:updateAtkEffect()
		end
	end

	--乱军是否被击
	for i=1,#self.tWildArmyDots do
		local pDot = self.tWildArmyDots[i]
		if pDot and pDot:isVisible() then
			pDot:updateAtkEffect()
		end
	end

	--Boss是否被击
	for i=1,#self.tBossDots do
		local pDot = self.tBossDots[i]
		if pDot and pDot:isVisible() then
			pDot:updateAtkEffect()
		end
	end
end

--更新指定wildArmy效果
function WorldLayer:updateWildArmyCirEffect( sMsgName, pMsgObj )
	local nArmyLv = 0
	if pMsgObj then
		nArmyLv = pMsgObj.nDotLv
	end
	--乱军底座特效
	Player:getWorldData():setWildArmyCirEffectLv(nArmyLv)
	--更新当前显示的
	for i=1,#self.tWildArmyDots do
		local pDot = self.tWildArmyDots[i]
		if pDot and pDot:isVisible() then
			pDot:updateCircleEffect()
		end
	end
end

--隐藏或显示系统城池Ui
function WorldLayer:updateSysCityUiVisible( sMsgName, pMsgObj )
	if pMsgObj then
		for i=1,#self.tSysCityDots do
			local pDot = self.tSysCityDots[i]
			if pDot and pDot:isVisible() and pDot:getId() == pMsgObj.sysCityId then
				pDot:setDotUiVisible(pMsgObj.bIsShow)
				break
			end
		end
		for i=1,#self.tImperialCityDots do
			local pDot = self.tImperialCityDots[i]
			if pDot and pDot:isVisible() and pDot:getId() == pMsgObj.sysCityId then
				pDot:setDotUiVisible(pMsgObj.bIsShow)
				break
			end
		end
		for i=1,#self.tFireTowerDots do
			local pDot = self.tFireTowerDots[i]
			if pDot and pDot:isVisible() and pDot:getId() == pMsgObj.sysCityId then
				pDot:setDotUiVisible(pMsgObj.bIsShow)
				break
			end
		end
	end
end

--隐藏或显示城池Ui
function WorldLayer:updateCityUiVisible( sMsgName, pMsgObj )
	if pMsgObj then
		for i=1,#self.tCityDots do
			local pDot = self.tCityDots[i]
			if pDot and pDot:getId() == pMsgObj.cityId then
				pDot:setDotUiVisible(pMsgObj.bIsShow)
				break
			end
		end
	end
end

--更新我势力国战列表（会影响系统城池Ui)
function WorldLayer:updateCountryWar( )
	for i=1,#self.tSysCityDots do
		local pDot = self.tSysCityDots[i]
		if pDot and pDot:isVisible() then
			pDot:updateSysCityUi()
		end
	end
	-- for i=1,#self.tImperialCityDots do
	-- 	local pDot = self.tImperialCityDots[i]
	-- 	if pDot and pDot:isVisible() then
	-- 		pDot:updateSysCityUi()
	-- 	end
	-- end
	-- for i=1,#self.tFireTowerDots do
	-- 	local pDot = self.tFireTowerDots[i]
	-- 	if pDot and pDot:isVisible() then
	-- 		pDot:updateSysCityUi()
	-- 	end
	-- end
end

--我的城池数据发生改变
function WorldLayer:onMyCityChange( )
	for i=1,#self.tCityDots do
		local pDot = self.tCityDots[i]
		if pDot and pDot:isVisible() and pDot:getIsMe() then
			pDot:onMyCityChange()
			break
		end
	end
end

--我的城池保护cd时间发生改变
function WorldLayer:updateMyProtectCd( )
	for i=1,#self.tCityDots do
		local pDot = self.tCityDots[i]
		if pDot and pDot:isVisible() and pDot:getIsMe() then
			pDot:updateMyProtectCd()
			break
		end
	end
end

--我的城池召唤信息
function WorldLayer:udpateMyCallInfo( )
	for i=1,#self.tCityDots do
		local pDot = self.tCityDots[i]
		if pDot and pDot:isVisible() and pDot:getIsMe() then
			pDot:udpateMyCallInfo()
			break
		end
	end
end

--重连成功再请求一次数据
function WorldLayer:onReconnectSuccess( )
	self:searchDotReq(nil, true)
end

--可击杀最高发生变化
function WorldLayer:onCanKillWildArmy( )
	for i=1,#self.tWildArmyDots do
		local pDot = self.tWildArmyDots[i]
		if pDot and pDot:isVisible() then
			pDot:updateCanAtkLv()
		end
	end
end

--更新离开的Boss
function WorldLayer:onBossLeaveUpdate( sMsgName, pMsgObj )
	if not pMsgObj then
		return
	end
	local tDelKeys = pMsgObj
	for i=1, #self.tBossDots do
		local pDot = self.tBossDots[i]
		if pDot and pDot:isVisible() then
			if tDelKeys[pDot:getDotKey()] then
				pDot:setVisibleEx(false)
			end
		end
	end
end
--更新离开的纣王
function WorldLayer:onKingzhouLeaveUpdate( sMsgName, pMsgObj  )
	-- body
	if not pMsgObj then
		return
	end
	local tDelKeys = pMsgObj
	for i=1, #self.tZhouBossDots do
		local pDot = self.tZhouBossDots[i]
		if pDot and pDot:isVisible() then
			if tDelKeys[pDot:getDotKey()] then
				pDot:setVisibleEx(false)
			end
		end
	end	
end

--更新视图点
function WorldLayer:updateVisibleFightArm( sDotKey )
	--乱军是否被击
	for i=1,#self.tWildArmyDots do
		local pDot = self.tWildArmyDots[i]
		if pDot and pDot:isVisible() and pDot:getDotKey() == sDotKey then
			pDot:updateVisibleFightArm()
			break
		end
	end
end

--更新限时Boss
function WorldLayer:updateTLBoss(  )
	for i=1, #self.tTLBossDots do
		local pDot = self.tTLBossDots[i]
		if pDot and pDot:isVisible() then
			pDot:updateTLBoss()
		end
	end
end

--更新限时Boss血条
function WorldLayer:updateTLBossHp( )
	for i=1, #self.tTLBossDots do
		local pDot = self.tTLBossDots[i]
		if pDot and pDot:isVisible() then
			pDot:updateTLBossHp()
		end
	end
end

--最终打印视图点数量
function WorldLayer:printDotData( )
	if true then
		return
	end
	print("WorldLayer:printDotData")
	print("#self.tCityDots==============",#self.tCityDots,#self.tUnCityDots)
	print("#self.tSysCityDots==============",#self.tSysCityDots,#self.tUnSysCityDots)
	print("#self.tResDots==============",#self.tResDots,#self.tUnResDots)
	print("#self.tWildArmyDots==============",#self.tWildArmyDots,#self.tUnWildArmyDots)
	print("#self.tDecorateDots==============",#self.tDecorateDots,#self.tUnDecorateDots)
end


--播放乱军动画层
function WorldLayer:playWildArmyFight( sMsgName, pMsgObj )
	if not pMsgObj then
		return
	end
	--如果在视图中就真接播放否则不播放
	local nDotX, nDotY = pMsgObj.nX, pMsgObj.nY
	local fX, fY = WorldFunc.getMapPosByDotPos(nDotX, nDotY)
	if not fX then
		return
	end

	local sKey = string.format("%s_%s",nDotX, nDotY)

	--如果存在就返回
	if self.tWAFightUis[sKey] then
		return
	end
	--标记
	Player:getWorldData():setWArmyFightPos(sKey, true)

	--创建Ui字典
	self.tWAFightUis[sKey] = {}

	--更新当前乱军
	self:updateVisibleFightArm(sKey)

	--隐藏返回行军线路
	sendMsg(ghd_hide_wild_army_line, sKey)

	--创建特效层
	local pLayEffect = MUI.MLayer.new()
	pLayEffect:setContentSize(100, 100)
	self.tWAFightLay[sKey] = pLayEffect
	pLayEffect:setPosition(fX, fY)
	self.pWAFightGroup:addView(pLayEffect)

	local fX,fY = 0, 0
	--人物动画 （播放到48帧的时候，武将出现返回基地）
	local tArmData2  = 
	{
        sPlist = "tx/other/sg_sjdt_zdtx_sa",
        nImgType = 1,
		nFrame = 57, -- 总帧数
		pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 1,-- 初始的缩放值
		nBlend = 0, -- 需要加亮
	   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
		tActions = {
			 {
				nType = 1, -- 序列帧播放
				sImgName = "sg_sjdt_zdtx_sa_",
				nSFrame = 1, -- 开始帧下标
				nEFrame = 57, -- 结束帧下标
				tValues = nil, -- 参数列表
			},
		},
	}
	local pHeroArmAction = MArmatureUtils:createMArmature(
	tArmData2, 
	pLayEffect, 
	2, 
	cc.p(fX, fY),
    function ( _pArm )
    	_pArm:removeSelf()
    	_pArm = nil

		--清空所有
		if self.tWAFightLay[sKey] then
			self.tWAFightLay[sKey]:removeFromParent(true)
			self.tWAFightLay[sKey] = nil
		end
		--清空字典
		self.tWAFightUis[sKey] = nil

		--
		Player:getWorldData():setWArmyFightPos(sKey, false)

		--更新当前乱军
		self:updateVisibleFightArm(sKey)

	end, Scene_arm_type.normal)
	pHeroArmAction:play(1)
	WorldFunc.setCameraMaskForView(pHeroArmAction, true)
	self.tWAFightUis[sKey]["hero"] = pHeroArmAction

	--显示返回行军路线回调
	pHeroArmAction:setFrameEventCallFunc(function ( _nCur )
		if _nCur == 48 then
			--显示返回行军线路
			sendMsg(ghd_show_wild_army_line, sKey)
		end
	end)
	
	--光晕效果
	local tArmData3  =  {
		nFrame = 18, -- 总帧数
		pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 3,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
	  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
		tActions = {
			{
				nType = 2, -- 透明度
				sImgName = "sg_sjdt_zd0tx_sa_0001",
				nSFrame = 1,
				nEFrame = 4,
				tValues = {-- 参数列表
					{20, 255}, -- 开始, 结束透明度值
				}, 
			},
			{
				nType = 2, -- 透明度
				sImgName = "sg_sjdt_zd0tx_sa_0001",
				nSFrame = 5,
				nEFrame = 18,
				tValues = {-- 参数列表
					{255, 0}, -- 开始, 结束透明度值
				}, 
			},
		},
	}
	local pLightArmAction = MArmatureUtils:createMArmature(
	tArmData3, 
	pLayEffect, 
	3,
	cc.p(fX, fY),
    function ( _pArm )
    	_pArm:removeSelf()
    	_pArm = nil
	end, Scene_arm_type.normal)
	pLightArmAction:play(1)
	WorldFunc.setCameraMaskForView(pLightArmAction, true)
	self.tWAFightUis[sKey]["light"] = pLightArmAction

	-- fX,fY = fX - 5,fY - 38
	--烟雾动画（播放3次） 
	self.tWAFightKeys[sKey] = 3
	local pFogArm = self:playWildArmyFightFog(sKey, fX, fY)
	if pFogArm then
		self.tWAFightUis[sKey]["fog"] = pFogArm
	end

	--0.2秒后出现(为了处理地图的问题)
	-- local pUis = self.tWAFightUis[sKey]
	-- for k,v in pairs(pUis) do
	-- 	-- v:setOpacity(0)
	-- 	v:setVisible(false)
	-- end
	-- -- local function __show( )
	-- -- 	local _pUis = self.tWAFightUis[sKey]
	-- -- 	if _pUis then
	-- -- 		for k,v in pairs(_pUis) do
	-- -- 			-- v:setOpacity(255)
	-- -- 			v:setVisible(true)
	-- -- 		end
	-- -- 	end
	-- -- end
	-- -- local pSeqAct = cc.Sequence:create({
	-- -- 	cc.DelayTime:create(0.1),
	-- -- 	cc.CallFunc:create(__show)
	-- -- 	})
	-- pLayEffect:runAction(pSeqAct)
	WorldFunc.setCameraMaskForView(pLayEffect, true)
end


--播放烟雾动画3次
function WorldLayer:playWildArmyFightFog( sKey, fX, fY)
	if not sKey or not fX or not fY then
		return
	end

	local nCanPlayTime = self.tWAFightKeys[sKey]
	if nCanPlayTime <= 0 then
		return
	end
	--记录
	self.tWAFightKeys[sKey] = nCanPlayTime - 1

	--如果存在该Ui
	if self.tWAFightUis[sKey] then
		local pArm = self.tWAFightUis[sKey]["fog"]
		if pArm then
			pArm:play(1)
			return
		end
	end

	local pLayEffect = self.tWAFightLay[sKey]
	--烟雾动画（播放3次） 
	local tArmData1  = 
	{
        sPlist = "tx/other/sg_sjdt_zdtx_sa",
        nImgType = 1,
		nFrame = 19, -- 总帧数
		pos = {1, -6}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 4,-- 初始的缩放值
		nBlend = 0, -- 需要加亮
	   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
		tActions = {
			 {
				nType = 1, -- 序列帧播放
				sImgName = "sg_sjdt_csdtx_sa_",
				nSFrame = 1, -- 开始帧下标
				nEFrame = 19, -- 结束帧下标
				tValues = nil, -- 参数列表
			},
		},
	}
	local pArmAction = MArmatureUtils:createMArmature(
		tArmData1, 
		pLayEffect, 
		4, 
		cc.p(fX, fY),
	    function ( _pArm )
	    	-- _pArm:removeSelf()
	    	-- _pArm = nil
	    	--再播放
	    	self:playWildArmyFightFog(sKey, fX, fY)
		end, Scene_arm_type.normal)
	pArmAction:play(1)
	WorldFunc.setCameraMaskForView(pArmAction, true)
	return pArmAction
end


--设置摄相机（为了做碰撞检测)
function WorldLayer:setCamera( pCamera )
	self._camera = pCamera
end


--只请求城战列表
function WorldLayer:onWorldCityWarInfo( __msg, __oldMsg  )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqWorldCityWarInfo.id then
        	--容错
    		if not __oldMsg then
    			return
    		end
    		local nCityId = __oldMsg[1]
    		if not nCityId then
    			return
    		end
    		local tViewDotMsg = Player:getWorldData():getCityDot(nCityId)
			if not tViewDotMsg then
				return
			end

			openDlgCityWar(__msg.body,tViewDotMsg)

   --      	--多人战检测
   --      	if __msg.body.wars and #__msg.body.wars > 0 then
			-- 	--转成本地数据
			-- 	local tCityWarMsgs = {}
			-- 	local CityWarMsg = require("app.layer.world.data.CityWarMsg")
			-- 	for i=1,#__msg.body.wars do
			-- 		table.insert(tCityWarMsgs, CityWarMsg.new(__msg.body.wars[i]))
			-- 	end
			-- 	--倒计时排列
			-- 	table.sort(tCityWarMsgs, function ( a , b )
			-- 		return a:getCd() < b:getCd()
			-- 	end)

			-- 	--发送消息打开dlg
			-- 	local tObject = {
			-- 	    nType = e_dlg_index.citywar, --dlg类型
			-- 	    --
			-- 	    tCityWarMsgs = tCityWarMsgs,
			-- 	    tViewDotMsg = tViewDotMsg,
			-- 	}
			-- 	sendMsg(ghd_show_dlg_by_type, tObject)
			-- end
        end
    elseif __msg.head.state == SocketErrorType.no_citywar then
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end

--只请求世界国战列表
function WorldLayer:onWorldCountryWarInfo( __msg, __oldMsg)
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqWorldCountryWarInfo.id then
        	--容错
			if not __oldMsg then
				return
			end
			local nSysCityId = __oldMsg[1]
			if not nSysCityId then
				return
			end
			local tViewDotMsg = Player:getWorldData():getSysCityDot(nSysCityId)
			if not tViewDotMsg then
				return
			end
        	--判断是否有多国战
			if __msg.body.wars and #__msg.body.wars > 0 then
				--转化为本地数据
				local tCountryWarMsgs = {}
				local CountryWarMsg = require("app.layer.world.data.CountryWarMsg")
				for i=1,#__msg.body.wars do
					table.insert(tCountryWarMsgs, CountryWarMsg.new(__msg.body.wars[i]))
				end
				--倒计时排列
				table.sort(tCountryWarMsgs, function ( a , b )
					return a:getCd() < b:getCd()
				end)

				--发送消息打开dlg
				local tObject = {
				    nType = e_dlg_index.countrywar, --dlg类型
				    --
				    tCountryWarMsgs = tCountryWarMsgs,
				    tViewDotMsg = tViewDotMsg,
				}
				sendMsg(ghd_show_dlg_by_type, tObject)
			end
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end

--实例化摄像机2的视图点
function WorldLayer:initCamera2Dot( )
	self.bIsCamera2Inited = true
	for i=1,#self.tTLBossDots do
		self.tTLBossDots[i]:initTLBoss()
	end
	for i=1,#self.tImperialCityDots do
		self.tImperialCityDots[i]:initCaptureBar()
	end
	for i=1,#self.tZhouBossDots do
		self.tZhouBossDots[i]:initZhouDotBar()
	end
end
--是否有初始化摄机2
function WorldLayer:getIsCamera2Inited()
	return self.bIsCamera2Inited
end

--播放TLBoss地震加变黑
function WorldLayer:onTLBossShake(  )
	if self.bTLBossShake then
		return
	end
	-- 震动动画(全满震动)
	-- 时间         位置（Y）
	-- 0                 0
	-- 0.06秒            -4
	-- 0.17秒            2    （-4 到 2 = 6 像素）
	-- 0.28秒            0
	local nX, nY = self.pMapViewGroup:getPosition()
	local pMoveTo1 = cc.MoveTo:create(0.06, cc.p(nX, nY - 4))
	local pMoveTo2 = cc.MoveTo:create(0.17 -0.06, cc.p(nX, nY + 2))
	local pMoveTo3 = cc.MoveTo:create(0.28 - 0.17, cc.p(nX, nY))
	local nFunc = cc.CallFunc:create(function ( )
 		self.bTLBossShake = false
 	end)
 	self.bTLBossShake = true
	self.pMapViewGroup:runAction(cc.Sequence:create({pMoveTo1,pMoveTo2,pMoveTo3,nFunc})) 
end

function WorldLayer:onTLBossAtkName( sMsgName, pMsgObj )
	for i=1, #self.tTLBossDots do
		local pDot = self.tTLBossDots[i]
		if pDot and pDot:isVisible() then
			pDot:showAtkTLBossName(pMsgObj.sName, pMsgObj.bIsBroke)
		end
	end
end

function WorldLayer:onTLBossHurt( sMsgName, pMsgObj )
	for i=1, #self.tTLBossDots do
		local pDot = self.tTLBossDots[i]
		if pDot and pDot:isVisible() then
			pDot:showAtkTLBossHurt(pMsgObj.nNum, pMsgObj.bIsBest)
		end
	end
end

function WorldLayer:onTLBossFinger( sMsgName, pMsgObj )
	for i=1, #self.tTLBossDots do
		local pDot = self.tTLBossDots[i]
		if pDot and pDot:isVisible() then
			pDot:updateFinger()
		end
	end
end

function WorldLayer:onImperWarOpen(  )
	for i=1,#self.tImperialCityDots do
		local pDot = self.tImperialCityDots[i]
		if pDot and pDot:isVisible() then
			pDot:updateProtect()
			pDot:updateEpwFightEffect()
		end
	end
	
	for i=1,#self.tFireTowerDots do
		local pDot = self.tFireTowerDots[i]
		if pDot and pDot:isVisible() then
			pDot:updateProtect()
			pDot:updateEpwFightEffect()
		end
	end
end

--隐藏限时Boss并回复
function WorldLayer:onHideTLBoss(  )
	local bIsNeedRefresh = false
	for i=1,#self.tTLBossDots do
		if self.tTLBossDots[i]:isVisible() then
			bIsNeedRefresh = true
			break
		end
	end
	if bIsNeedRefresh then
		self:refreshItemDots()
	end
end

--测试
function WorldLayer:setTestSprite( nCheck )
	local function doFunc( ... )
		for i=1, #self.tTLBossDots do
			local pDot = self.tTLBossDots[i]
			if pDot and pDot:isVisible() then
				pDot:showAtkTLBossHurt(pMsgObj.nNum, pMsgObj.bIsBest)
			end
		end
	end
	for i=1,#self.tCityDots do
		local pDot = self.tCityDots[i]
		if pDot and pDot:getIsMe() then
			if nCheck == 1 then
			elseif nCheck == 2 then
				for i=1, #self.tTLBossDots do
					local pDot = self.tTLBossDots[i]
					if pDot and pDot:isVisible() then
						pDot:showAtkTLBossName("测试六个名字", false)
					end
				end
			elseif nCheck == 3 then
				for i=1, #self.tTLBossDots do
					local pDot = self.tTLBossDots[i]
					if pDot and pDot:isVisible() then
						pDot:showAtkTLBossName("测试六个名字", true)
					end
				end
			elseif nCheck == 4 then
				for i=1, #self.tTLBossDots do
					local pDot = self.tTLBossDots[i]
					if pDot and pDot:isVisible() then
						pDot:showAtkTLBossHurt(9999)
					end
				end
			elseif nCheck == 5 then
				for i=1, #self.tTLBossDots do
					local pDot = self.tTLBossDots[i]
					if pDot and pDot:isVisible() then
						pDot:showAtkTLBossHurt(9999, true)
					end
				end
			end
			break
		end
	end
end


return WorldLayer