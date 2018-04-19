----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-08 16:10:10
-- Description: 新手管理器
-----------------------------------------------------
B_GUIDE_LOG = false
--手指位置标识
e_guide_finer = {
	task_reward_btn         =  1,  --主线任务完成奖励弹窗  领取按钮
	home_task_layer         =  3,  --主界面任务栏
	house1_lvup_btn         =  4,  --4-客栈1升级按钮
	house1_speed_btn        =  5,  --5-客栈1加速气泡
	house2_lvup_btn         =  6,  --6-客栈2升级按钮
	house2_speed_btn        =  7,  --7-客栈1加速气泡
	wood1_lvup_btn          =  8,  --8-木场1升级按钮
	wood2_lvup_btn          =  9,  --9-木场2升级按钮
	wood1_speed_btn         =  10, --10-木场1加速气泡
	wood2_speed_btn         =  11, --11-木场2加速气泡
	wood3_lvup_btn          =  12, --12-木场3升级按钮
	wood3_speed_btn         =  13, --13-木场3加速气泡
	wood4_lvup_btn          =  14, --14-木场4升级按钮
	wood4_speed_btn         =  15, --15-木场4加速气泡
	palace_lvup_btn         =  16, --16-王宫升级按钮
	palace_speed_btn        =  17, --17-王宫加速气泡
	house3_army_btn         =  18, --客栈3乱军头像
	house3_lvup_btn         =  19, --客栈3升级按钮
	house3_speed_btn        =  20, --客栈3加速气泡
	tnoly_enter_btn         =  21, --科技院进入按钮
	world_enter_btn         =  22, --世界入口按钮
	world_wildamry_lv1      =  23, --1级乱军
	world_hero_go           =  24, --世界，出征按钮
	hero_enter_btn          =  25, --武将入口按钮
	first_hero_head         =  26, --上阵界面，第一个武将头像
	hero_third_equip        =  27, --武将详情，第3个装备格子
	world_wildamry_lv2      =  28, --2级乱军
	tnoly_build             =  29, --科技院建筑
	tnoly_build_bubble      =  30, --科技院头顶科技气泡
	food1_lvup_btn          =  31, --农田1升级按钮
	food1_speed_btn         =  32, --农田1加速气泡
	food1_res_bubble        =  33, --农田1资源气泡
	store_lvup_btn          =  34, --仓库升级按钮
	camp_enter_btn          =  35, --步兵营建筑募兵按钮
	camp_recruit_btn        =  36, --步兵营界面, 招募按钮
	smithshop_build         =  37, --铁匠铺建筑
	build_equip_btn         =  38, --铁匠铺-打造装备
	fuben_enter_btn         =  39, --副本入口按钮
	fuben_first_chapter     =  40, --副本界面第一章中心点
	fuben_first_post_cruit  =  41, --第一章关卡列表-招募按钮
	wear_corselet_btn       =  42, --装备背包-白虹甲穿戴按钮
    recruit_hero_btn1       =  43, --第一章-武将招募-免费招募按钮
    hero_online_btn1        =  44, --第一章-武将招募-前往上阵按钮
    wear_sword_btn          =  45, --装备背包-白虹剑穿戴按钮
    second_hero_head        =  46, --武将上阵-第二个武将头像
    online_btn              =  47, --选择上阵武将界面-上阵按钮
    invisible_finger        =  48, --隐形的手指
    go_battle_btn           =  49, --出征武将界面出征按钮
    wear_gun_btn            =  50, --装备背包-白虹枪穿戴按钮
    hero_first_equip        =  51, --武将详情，第1个装备格子
    hero_second_equip       =  52, --武将详情，第2个装备格子
    house5_lvup_btn         =  53, --客栈5升级按钮
    house5_speed_btn        =  54, --客栈5加速气泡
    wood5_lvup_btn          =  55, --木场5升级按钮
    wood5_speed_btn         =  56, --木场5加速气泡
    treasure_build          =  57, --珍宝阁建筑位置
    store_speed_btn         =  58, --仓库加速按钮
    tnoly_lvup_btn          =  59, --科技院升级按钮
    tnoly_speed_btn         =  60, --科技院加速按钮
    item_technology         =  61, --科技项
    technology_btn          =  62, --科技消耗-科技研究按钮
    sowar_hero_online_btn   =  63, --选择上阵骑兵武将-上阵按钮
    change_hero_btn         =  64, --武将基础参数-武将更换按钮
	world_wildamry_lv3      =  65, --3级乱军
	house5_res_bubble       =  66, --客栈5资源气泡
	white_sword_icon        =  67, --铁匠铺-白装-白虹剑图标
	wood5_res_bubble        =  68, --木场5资源气泡
	white_corselet_icon     =  69, --铁匠铺-白装-白虹甲图标
	recruit_smith_btn       =  70, --铁匠铺-招募铁匠按钮
	hire_smith_btn          =  71, --铁匠铺-铁匠雇佣-雇用按钮
	white_helmet_icon       =  72, --铁匠铺-白装-白虹盔图标
	hero_forth_equip        =  74, --武将详情，第4个装备格子
    wear_helmet_btn         =  75, --装备背包-白虹盔穿戴按钮
    food5_res_bubble        =  76, --农场5资源气泡
    food5_lvup_btn          =  77, --农场5升级按钮
    food5_speed_btn         =  78, --农场5加速气泡
	white_yin_icon          =  79, --铁匠铺-白装-三略图标
	hero_fifth_equip        =  80, --武将详情，第5个装备格子
	white_fu_icon           =  81, --铁匠铺-白装-火鼠印图标
	hero_sixth_equip        =  82, --武将详情，第6个装备格子
    wear_yin_btn            =  83, --装备背包-三略穿戴按钮
    wear_fu_btn             =  84, --装备背包-火鼠印穿戴按钮
	smithshop_bubble        =  85, --铁匠铺领取装备
	-- sowar_hero_type         =  86, --选择上阵武将界面-骑兵分类
	sowar_lvup_btn          =  87, --骑兵营升级按钮
    sowar_speed_btn         =  88, --骑兵营加速按钮
	world_wildamry_lv4      =  89, --4级乱军
	world_wildamry_lv5      =  90, --5级乱军
	world_wildamry_lv6      =  91, --6级乱军
	change_name_btn         =  92, --玩家基础信息-改名按钮
	-- tjp_equip_speed         =  93, --铁匠铺加速冒泡
	tjp_equip_speed         =  94, --铁匠铺免费加速打造
	show_hero_btn           =  95, --武将获得界面确定按钮
	palace_lvup_speed_btn   =  96, --王宫建筑加速按钮
	five_min_speed_btn      =  97, --5分钟加速使用按钮
	battle_selected_btn     =  98, --出征武将界面第2个武将勾选按妞
	res_collectall_btn      =  99, --资源征收弹窗一键征收按妞
	hero_wear_all_btn       =  101, --武将界面一键穿戴按钮

	hero_lvup_btn      		=  102, --武将界面升级加号按钮(这里的102~108是教你玩引导)
	store_build				=  103, --仓库建筑
	infantry_build			=  104, --步兵营建筑
	house1_build			=  105, --客栈1建筑
	gate_build				=  106, --城门建筑
	arena_build				=  107, --竞技场建筑
	palace_build			=  108, --王宫建筑

	first_hero_change_btn   =  109, --武将界面-第1个武将[更换武将]按钮
	sec_hero_change_btn     =  110, --武将界面-第2个武将[更换武将]按钮

	country_enter_btn	    =  111, --国家按钮
	gequip_enter_btn        =  112, --神器
	gequip_sword            =  113, --天帝剑
	buyhero_build           =  114, --拜将台
	buyhero_normal          =  115, --良将推演一次
	buyhero_close           =  116, --推演获得界面关闭按钮
	warhall_build           =  117, --战争大厅
	pkhero_enter            =  118, --过关斩将入口
	pkhero_enemy            =  119, --过关斩将红色武将
	pkhero_power_btn        =  120, --最大战力按钮
	pkhero_fight_btn        =  121, --战斗按钮
	atelier_enter_btn       =  122, --工坊进入按钮
	atelier_produce_btn     =  124, --生产按钮
	tcf_enter_btn           =  125, --统帅府进入按钮
	smith_strenght_btn      =  126, --铁匠铺强化按钮
	tcf_collect_tab         =  127, --采集队列
	first_cteam_add         =  128, --采集队列一号位
	first_select_hero       =  129, --武将列表第一个上阵位
	smith_refine_tab        =  130, --铁匠铺洗练分页
	hero_starsoul_btn       =  131, --星魂按钮
    hssoul_active_btn       =  132, --激活按钮
    arena_enter             =  133, --竞技场入口按钮
    first_arena_btn         =  134, --竞技场第一个挑战按钮

}

e_model_unlock = {
	refine = 21, --洗炼，
	atelier = 32, --工访,
	tcf = 31,--统帅府
}

--特殊任务ID
e_special_task_id = {
	collect_res 	        = 20013,       --征收一次资源任务
	recruit_xiaoqiao        = 20030,       --招募孙尚香
	recruit_jingke          = 20049,       --招募荆轲
	recruit_hero            = 20080,       --招募高渐离
	hire_smith              = 20052,       --雇佣铁匠
	change_smith            = 20067,       --替换铁匠
	fuben_enter             = 20020,       --副本入口任务
	hero_enter              = 20069,       --武将入口任务
	online_sun              = 20031,       --上阵孙尚香
	online_jing             = 20050,       --上阵荆轲
	online_gao              = 20081,       --上阵高渐离
	palace_lv_five          = 20065,       --王宫升到5级任务
	beat_two_army           = 20087,       --任意攻打2个乱军任务
}

--装备id
e_wear_equip_id = {
	wear_gun         = 2001,        --白虹枪id
	wear_sword       = 2002,        --白虹剑id
	wear_corselet    = 2003,        --白虹甲id
	wear_helmet      = 2004,        --白虹盔id
	wear_yin         = 2005,        --三略id
	wear_fu          = 2006,        --火鼠印id
}

--特殊步骤类型
e_special_type = {
	lvup                 = 1,           --升级
	speedup              = 2,           --免费加速
	collect              = 3,           --征收
	get_tnoly            = 4,           --科技院领取科技
	get_equip            = 5,           --铁匠铺领取装备
	beat_army            = 6,           --攻打乱军
	build_lvup           = 7,           --建筑升级按钮特效
	speed_equip          = 8,           --铁匠铺加速
	hero_battle          = 9,           --武将出征按钮
	show_hero            = 10,          --获得武将
	useitem_speed_btn    = 11,          --道具加速按钮
}

--改表时必改 build_res
local nHouse1 = 1001
local nHouse2 = 1002
local nHouse3 = 1003
local nHouse5 = 1005
local nWood1  = 1017
local nWood2  = 1018
local nWood3  = 1019
local nWood4  = 1020
local nWood5  = 1021
local nFood1  = 1033
local nFood5  = 1037

--新手管理类
local NewGuideMgr = class("NewGuideMgr")
function NewGuideMgr:ctor( NewGuideMgr )
	self:release()
	self:initKeyData()
end

function NewGuideMgr:release()
	self.nCurrStepId = nil --当前进行的步骤id
	self.pFingerUis = {} --手指ui
	self.nCurrTaskId = nil --当前进行的任务id
	self.pHomeLayer = nil --城市界面
	self.tRewardKey = nil
	self.tUnlockLvKeys = nil
	self.tUnlockPLvKeys = nil
	self.tUnlockStepIds = nil
	self.tMissionId = nil
	self.bIsStopLocalUi = false
end

function NewGuideMgr:initKeyData(  )
	self.tRewardKey = {}
	self.tUnlockLvKeys = {}
	self.tUnlockPLvKeys = {}
	self.tUnlockStepIds = {}
	local tDatas = getAllGuideData()
	for k,v in pairs(tDatas) do
		if v.missionid and v.fingerid == e_guide_finer.task_reward_btn then
			self.tRewardKey[v.missionid] = v.step
		end
		if v.condition then
			self.tUnlockStepIds[v.condition] = v.step
			local tOpenSystem = getOpenSystem(v.condition)
			if tOpenSystem then
				-- 1任务开放:任务id
			    -- 2玩家等级开放:等级
			    -- 3王宫等级放开:等级
			    local tData = luaSplitMuilt(tOpenSystem.condition, ":", "|")
			    -- dump(tData, "tData", 100)
			    if tData and #tData >= 2 then
			        local nKey = tonumber(tData[1])
			        local nValue = nil
			        local nValue2 = nil
			        if type(tData[2]) == "table" then --主公等级区间
			            nValue = tonumber(tData[2][1])
			            nValue2 = tonumber(tData[2][2])
			        else
			            nValue = tonumber(tData[2])
			        end
			        if nKey and nValue then
				        if nKey == 2 then           --玩家等级开放
				            self.tUnlockLvKeys[nValue] = v.step
				        elseif nKey == 3 then       --皇宫等级开放
				        	self.tUnlockPLvKeys[nValue] = v.step
				        end
				    end
			    end
			end
		end
	end
end

--任务id,步骤id 表
function NewGuideMgr:getRewardKeys( )
	return self.tRewardKey
end

-- --获取是否需要强制跳回主城且关闭主界面(主要用于初始解锁功能触发)
-- function NewGuideMgr:getIsUnlockJumpCity( nGuideId )
-- 	for k,v in pairs(self.tUnlockLvKeys) do
-- 		if nGuideId == v then
-- 			closeAllDlg()--进入世界或者基地界面时候清理界面上的对话框
-- 			closeDlgByType(e_dlg_index.dlgchat)
-- 			sendMsg(ghd_home_show_base_or_world, 1)--主城或世界跳转	
-- 			break
-- 		end
-- 	end

-- 	for k,v in pairs(self.tUnlockPLvKeys) do
-- 		if nGuideId == v then
-- 			closeAllDlg()--进入世界或者基地界面时候清理界面上的对话框
-- 			closeDlgByType(e_dlg_index.dlgchat)
-- 			sendMsg(ghd_home_show_base_or_world, 1)--主城或世界跳转	
-- 			break
-- 		end
-- 	end
-- end

--设置主页界面
function NewGuideMgr:setHomeLayer( pHomeLayer )
	self.pHomeLayer = pHomeLayer
end

--判断是否在新手阶段
function NewGuideMgr:getIsInGuide()
 	local tTask = Player:getPlayerTaskInfo():getCurAgencyTask()
 	if not tTask then
 		return false
 	end

 	if not self.tMissionId then
 		self.tMissionId = {}
 		local tDatas = getAllGuideData()
		for k,v in pairs(tDatas) do
			if v.missionid then
				self.tMissionId[v.missionid] = true
			end
		end
	end

	local nCurTaskId = tTask.sTid
	return self.tMissionId[nCurTaskId] or false
end

--设置ui为新手指引的手指指向ui
--pUi新手指
--nFingerId手指id
--bIsNoTrigger 不触发
function NewGuideMgr:setNewGuideFinger( pUi, nFingerId, bIsNoTrigger)
	if B_GUIDE_LOG then
		myprint("B_GUIDE_LOG NewGuideMgr:setNewGuideFinger pUi, nFingerId =", tostring(pUi), tostring(nFingerId))
	end
	--被新手搞到想吐，恶心的暴力检测方法，当前Ui和后UI不一样是才进行触发
	local pPrevUi = self.pFingerUis[nFingerId]
	local nCurrUi = pUi
	if nCurrUi == pPrevUi then
		if B_GUIDE_LOG then
			myprint("B_GUIDE_LOG NewGuideMgr:setNewGuideFinger pPrevUi == nCurrUi")
		end
		return
	end
	--如果值和UI都相同就不触发
	self.pFingerUis[nFingerId] = nCurrUi
	if pUi then
		pUi.__guide_finger_msg = nFingerId
		if B_GUIDE_LOG then
			myprint("B_GUIDE_LOG NewGuideMgr:setNewGuideFinger 触发 showGuideLayer")
		end
		if B_GUIDE_LOG then
			myprint("111111111111111111111111111111111111111")
		end
		if not self.nCurrStepId then
			if B_GUIDE_LOG then
				myprint("B_GUIDE_LOG NewGuideMgr:setNewGuideFinger not self.nCurrStepId")
			end
			return
		end
		if B_GUIDE_LOG then
			myprint("111111111111111111111111111111111111112",self.nCurrStepId)
		end
		local tGuideData = getGuideData(self.nCurrStepId)
		if not tGuideData then
			if not self.nCurrStepId then
				if B_GUIDE_LOG then
					myprint("B_GUIDE_LOG NewGuideMgr:setNewGuideFinger not tGuideData")
				end
			end
			if B_GUIDE_LOG then
				myprint("111111111111111111111111111111111111113")
			end
			return
		end
		if B_GUIDE_LOG then
			myprint("11111111111111111111111111111111111111======== ",nFingerId,tGuideData.fingerid)
		end
		if nFingerId == tGuideData.fingerid then
			
			if bIsNoTrigger then
				return
			end
			if B_GUIDE_LOG then
				myprint("111111111111111111111111111111111111115")
			end
			self:showGuideLayer()
		end
	end
end

--设置手指点击完成
--用法Player:getNewGuideMgr():onClickedNewGuideFinger( nFingerId )
function NewGuideMgr:onClickedNewGuideFinger( pUi )
	if not pUi then
		if B_GUIDE_LOG then
			myprint("B_GUIDE_LOG NewGuideMgr:onClickedNewGuideFinger no pUi")
		end
		return
	end
	local nFingerId = pUi.__guide_finger_msg
	if not nFingerId then
		if B_GUIDE_LOG then
			myprint("B_GUIDE_LOG NewGuideMgr:onClickedNewGuideFinger no nFingerId")
		end
		return
	end
	
	return self:setNewGuideFingerClicked(nFingerId)
end

--设置手指点击完成
--用法Player:getNewGuideMgr():setNewGuideFingerClicked( nFingerId )
function NewGuideMgr:setNewGuideFingerClicked( nFingerId )
	if B_GUIDE_LOG then
		myprint("B_GUIDE_LOG NewGuideMgr:setNewGuideFingerClicked 触发手指点击 ~~~~~~~~~~~ ", self.nCurrStepId)
	end
	if not nFingerId then
		if B_GUIDE_LOG then
			myprint("B_GUIDE_LOG NewGuideMgr:setNewGuideFingerClicked no nFingerId")
		end
		return
	end

	if not self.nCurrStepId then
		if B_GUIDE_LOG then
			myprint("B_GUIDE_LOG NewGuideMgr:setNewGuideFingerClicked no self.nCurrStepId")
		end
		return
	end
	--指引手指点击
	local tGuideData = getGuideData(self.nCurrStepId)
	if not tGuideData then
		if B_GUIDE_LOG then
			myprint("B_GUIDE_LOG NewGuideMgr:setNewGuideFingerClicked no tGuideData")
		end
		return
	end
	if B_GUIDE_LOG then
		myprint("B_GUIDE_LOG NewGuideMgr:setNewGuideFingerClicked ", tGuideData.fingerid , nFingerId)
	end
	--如果是攻打乱军步骤不用判断手指id直接触发下一步
	if tGuideData.fingerid == nFingerId or self:isAttackArmyStep(true) then
		if B_GUIDE_LOG then
			myprint("B_GUIDE_LOG NewGuideMgr:setNewGuideFingerClicked 手指点击完成 触发下一步: ", tGuideData.nextstep)
		end

		--隐藏手指
		sendMsg(ghd_guide_clicked_finger)

		--触发完成点击跳转转个界面
		local bIsJump = self:jumpToDlg(tGuideData.step)
		self:showNewGuide(tGuideData.nextstep, 1)
		return bIsJump
	-- else
		-- if nFingerId == e_guide_finer.home_task_layer then
			-- if B_GUIDE_LOG then
			-- 	print("点了任务栏 但当时的手指并非指向任务栏, 这个时候强制显示手指 ~~~~~~~~~~~~~~~~~~~")
			-- end
			-- self:showNewGuideAgain()
		-- end
	end


	return false
end


--任务触发新手(得到任务时触发)(强制显示)
function NewGuideMgr:showNewGuideByTask(  )
	local tTask = Player:getPlayerTaskInfo():getCurAgencyTask()
	if not tTask then
		if B_GUIDE_LOG then
			myprint("B_GUIDE_LOG NewGuideMgr:showNewGuideByTask tTask")
		end
		return
	end

	local nTaskId = tTask.sTid
	local tGuideData = getGuideDataByTask(nTaskId) 
	if not tGuideData then
		if B_GUIDE_LOG then
			myprint("B_GUIDE_LOG NewGuideMgr:showNewGuideByTask tGuideData")
		end
		return
	end
	--主线任务变更时重新强制重新检测新手教程
	if self.nCurrTaskId == nTaskId then
		if B_GUIDE_LOG then
			myprint("B_GUIDE_LOG NewGuideMgr:showNewGuideByTask self.nCurrTaskId == nTaskId", self.nCurrTaskId)
		end
		return
	end	
	--记录当前进行的主线任务id
	self.nCurrTaskId = nTaskId 

	if B_GUIDE_LOG then
		myprint("B_GUIDE_LOG NewGuideMgr:showNewGuideByTask 任务触发新手 步骤id：", tGuideData.step)
	end
	
	--显示手指
	sendMsg(ghd_guide_finger_show_or_hide, true)
	--允许定位
	self:setIsStopLocalUi(false)
	--显示新手流程
	self:showNewGuide(tGuideData.step, 2)
end

--任务领将弹出面板触发(强制显示)
--nTaskId
function NewGuideMgr:showNewGuideByRewordLayer( nTaskId )
	if not b_open_guide then return end
	if B_GUIDE_LOG then
		myprint("B_GUIDE_LOG NewGuideMgr:showNewGuideByRewordLayer nTaskId",nTaskId)
	end
	local nStepId = self.tRewardKey[nTaskId]
	if B_GUIDE_LOG then
		myprint("B_GUIDE_LOG NewGuideMgr:showNewGuideByRewordLayer nStepId", nStepId)
	end
	if nStepId then
		if B_GUIDE_LOG then
			myprint("B_GUIDE_LOG showNewGuideByRewordLayer showGuideLayer ", nStepId)
		end
		--显示手指
		sendMsg(ghd_guide_finger_show_or_hide, true)
		--允许定位
		self:setIsStopLocalUi(false)
		self:showGuideLayer(nStepId)
	end
end

--显示解锁开放功能
function NewGuideMgr:showNewGuideByLvRange( nPrevLv, nCurrLv )
	if not b_open_guide then return end
	if nPrevLv and nCurrLv then
		local nStepId = nil
		for i=nCurrLv, nPrevLv+1, -1 do
			local nLv = i
			nStepId = self.tUnlockLvKeys[nLv]
			if nStepId then
				break
			end
		end
		if B_GUIDE_LOG then
			myprint("B_GUIDE_LOG NewGuideMgr:showNewGuideByLvRange nStepId", nStepId)
		end
		if nStepId then
			local tGuideData =  getGuideData(nStepId)
			if tGuideData then
				showDlgUnlockModelByGuide(tGuideData.condition, nStepId)
			end
		end
	end
end

--显示解锁开放功能
function NewGuideMgr:showNewGuideByPalaceLv( nLv )
	if not b_open_guide then return end
	if B_GUIDE_LOG then
		myprint("B_GUIDE_LOG NewGuideMgr:showNewGuideByPalaceLv nStepId", nLv)
	end
	if not nLv then
		return
	end
	local nStepId = self.tUnlockPLvKeys[nLv]	
	if B_GUIDE_LOG then
		myprint("B_GUIDE_LOG NewGuideMgr:showNewGuideByPalaceLv nStepId", nStepId)
	end
	if nStepId then
		local tGuideData =  getGuideData(nStepId)
		if tGuideData then
			showDlgUnlockModelByGuide(tGuideData.condition, nStepId)
		end
	end
end

--模块解锁初始化
function NewGuideMgr:initModelUnlock(  )
	self.tUnlockState = self:getModelUnlockDict()
end

--获取模块状态
function NewGuideMgr:getModelUnlockDict(  )
	local tUnlockState = {}
	for k,nOpenId in pairs(e_model_unlock) do
		tUnlockState[nOpenId]  = getIsReachOpenCon(nOpenId, false)
	end
	return tUnlockState
end


--解锁教程
function NewGuideMgr:checkIsShowUnloakGuide(  )
	if not b_open_guide then return end

	if not self.tUnlockState then
		return
	end
	--开启模块id
	local nOpenId = nil
	local tUnlockState = self:getModelUnlockDict()
	for k,v in pairs(tUnlockState) do
		local bPrevState = self.tUnlockState[k]
		if bPrevState == false and v == true then
			nOpenId = k
			break
		end
	end
	self.tUnlockState = tUnlockState
	if B_GUIDE_LOG then
		myprint("B_GUIDE_LOG NewGuideMgr:checkIsShowUnloakGuide nOpenId = ",nOpenId)
	end
	if not nOpenId then
		return
	end
	--功能解锁
	local nStepId = self.tUnlockStepIds[nOpenId]
    if B_GUIDE_LOG then
		myprint("B_GUIDE_LOG NewGuideMgr:checkIsShowUnloakGuide nStepId = ",nStepId)
	end
	if nStepId then
		if nOpenId == e_model_unlock.atelier or 
			nOpenId == e_model_unlock.tcf then
			self:showNewGuideByStepId(nStepId)
		else
			local tGuideData =  getGuideData(nStepId)
			if tGuideData then
				showDlgUnlockModelByGuide(tGuideData.condition, nStepId)
			end
		end
	end
end

--显示解锁步骤
function NewGuideMgr:showNewGuideByStepId( nStepId )
	if not b_open_guide then return end
	if B_GUIDE_LOG then
		myprint("B_GUIDE_LOG NewGuideMgr:showNewGuideByStepId nStepId", nStepId)
	end
	if nStepId then
		--显示手指
		sendMsg(ghd_guide_finger_show_or_hide, true)
		--允许定位
		self:setIsStopLocalUi(false)
		self:showGuideLayer(nStepId)
	end
end

--强制激活当前步骤(数据发生变化时)
function NewGuideMgr:showNewGuideAgain(  )
	if B_GUIDE_LOG then
		print("强制激活当前步骤(数据发生变化时) !!!!!!!!!!!!!!!!!!! ", self.nCurrStepId)
	end
	--显示手指
	sendMsg(ghd_guide_finger_show_or_hide, true)
	--允许定位
	self:setIsStopLocalUi(false)
	
	self:showNewGuide(self.nCurrStepId, 3)
end

--继续显示新手的某一步骤
function NewGuideMgr:showGuideByStep()
	-- body
	self:showNewGuide(self.nCurrStepId)
end

--步骤id和ui决定显示新手引导
--nStepId:步骤id
function NewGuideMgr:showNewGuide( nStepId , type)
	if B_GUIDE_LOG then
		myprint("B_GUIDE_LOG NewGuideMgr:showNewGuide 显示新的指引 nStepId= ", nStepId)
	end

	--记录当前引导id
	self:setCurrStepId( nStepId )
	
	--容错
	if not nStepId then
		if B_GUIDE_LOG then
			myprint("B_GUIDE_LOG NewGuideMgr:showNewGuide no nStepId")
		end
		return
	end

	local tGuideData = getGuideData(nStepId) 
	if not tGuideData then
		if B_GUIDE_LOG then
			myprint("B_GUIDE_LOG NewGuideMgr:showNewGuide no tGuideData")
		end
		return
	end

	--如果是新手相关任务没有解锁就设置当前就反回
	if tGuideData.missionid then
		local bIsUnLock = Player:getPlayerTaskInfo():getTaskIsUnLock(tGuideData.missionid)
		if not bIsUnLock then
			if B_GUIDE_LOG then
				myprint("B_GUIDE_LOG NewGuideMgr:showNewGuide 相关任务没有解锁")
			end
			return
		end
	end

	--如果是建筑开启等效反回
	if self:isShowBuildOpen( nStepId ) then
		return
	end

	--如果有语音播放语音
	if tGuideData.audio and getIsCanPlayAudio() then
		local pAudio = tGuideData.audio
		--如果上次的语音还在播则停止
		if self.pAudio then
			Sounds.stopEffect(self.pAudio)
		end
		if Sounds.Effect.tGuideAudio[pAudio] then
			self.pAudio = Sounds.Effect.tGuideAudio[pAudio]
		elseif Sounds.Effect[pAudio] then
			self.pAudio = Sounds.Effect[pAudio]
		elseif Sounds.Effect.tFight[pAudio] then
			self.pAudio = Sounds.Effect.tFight[pAudio]
		end
		if B_GUIDE_LOG then
			myprint("B_GUIDE_LOG 播放语音 :", pAudio)
		end
		Sounds.playEffect(self.pAudio)
	end


	--如果是任务领奖步骤就返回(任务领奖步骤是任务领奖面板触发)
	if self:getIsGetTaskReward(nStepId) then
		if B_GUIDE_LOG then
			myprint("B_GUIDE_LOG 任务领奖步骤就返回(任务领奖步骤是任务领奖面板触发) 步骤: ", nStepId)
		end
		return
	end

	--如果是引导打乱军
	if self:isAttackArmyStep() then
		return
	end

	--新加的步骤是否在某个界面才显示该步骤, 不在该界面就中断
	if tGuideData.getready and not getDlgByType(tGuideData.getready) then
		return
	end


	--特殊步骤需要判断是否已经完成
	local bIsFinishStep = self:getIsNewGuideSubStepFinish(nStepId)
	if bIsFinishStep then
		if B_GUIDE_LOG then
			myprint("B_GUIDE_LOG 特殊步骤完成触发下一条 nStepId= ", nStepId)
		end
		self:showNewGuide(tGuideData.nextstep, 4)
	else
		--判断当前执行可以直接完成
		if (tGuideData.fingerid == nil or tGuideData.fingerid == 0) and tGuideData.chatbox == 0 then
			
			--如果任务有跳转就直接跳转
			if tGuideData.mode and tGuideData.interface then
				if B_GUIDE_LOG then
					myprint("B_GUIDE_LOG 新手引导执行直接跳转 nStepId=",nStepId)
				end
				self:jumpToDlg( tGuideData.step )
				return
			end

			--如果没有特效直接执行下个任务
			if tGuideData.specialeffects == 0 then
				if B_GUIDE_LOG then
					myprint("B_GUIDE_LOG 如果没有特效直接执行下个任务 nStepId=",nStepId)
				end
				self:showNewGuide(tGuideData.nextstep, 5)
			end
		else
			if B_GUIDE_LOG then
				myprint("B_GUIDE_LOG 显示新手面板 nStepId = ", nStepId)
			end
			--定位显示新手面板
			if getIsSequeneceFree() then 
				self:localBuildUi(true)
			end
			self:showGuideLayer()
		end
	end
end

--显示新手指引层
--nTestStepId 测试步骤 正式的时候不用传
function NewGuideMgr:showGuideLayer( nTestStepId )
	if nTestStepId then
		self:setCurrStepId( nTestStepId )
	end
	if not self.nCurrStepId then
		if B_GUIDE_LOG then
			myprint("B_GUIDE_LOG showGuideLayer no self.nCurrStepId")
		end
		return
	end

	local tGuideData = getGuideData(self.nCurrStepId)
	if not tGuideData then
		if B_GUIDE_LOG then
			myprint("B_GUIDE_LOG showGuideLayer no tGuideData",self.nCurrStepId)
		end
		return
	end
	if B_GUIDE_LOG then
		myprint("B_GUIDE_LOG showGuideLayer 显示新手引导  ",self.nCurrStepId, tGuideData.fingerid)
	end

	--需要手指
	local pFingerUi = nil
	if (tGuideData.fingerid ~= nil and tGuideData.fingerid ~= 0) then
		pFingerUi = self.pFingerUis[tGuideData.fingerid]
		local bIsNoTarget = false
		if pFingerUi == nil then
			if B_GUIDE_LOG then
				myprint("B_GUIDE_LOG showGuideLayer pFingerUi == nil  ", tGuideData.fingerid)
			end
			bIsNoTarget = true
		end
		if tolua.isnull(pFingerUi) then
			self.pFingerUis[tGuideData.fingerid] = nil --消灭c++对像已经销毁的lua地址
			if B_GUIDE_LOG then
				myprint("B_GUIDE_LOG showGuideLayer self.pFingerUis[tGuideData.fingerid] = nil", tGuideData.fingerid)
			end
			bIsNoTarget = true
		end
		--没有目标UI的，有时候还可以打开一下
		if bIsNoTarget then
			if B_GUIDE_LOG then
				myprint("B_GUIDE_LOG showGuideLayer 没有目标UI的 返回")
			end
			return
		end
	end

	local pGuideLayer = getRealShowLayer(self.pHomeLayer, e_layer_order_type.guidelayer)
    if pGuideLayer then
    	--手指
    	if tGuideData.fingerid ~= nil and tGuideData.fingerid ~= 0 then
    		if not tGuideData.specialeffects or tGuideData.specialeffects == 0 then
	    		if B_GUIDE_LOG then
					myprint("B_GUIDE_LOG showGuideLayer 显示手指", tGuideData.fingerid)
				end
		    	if not self.pNewGuideFinger then
		    		local NewGuideFinger = require("app.layer.newguide.NewGuideFinger")
					self.pNewGuideFinger = NewGuideFinger.new()
					pGuideLayer:addView(self.pNewGuideFinger)
					centerInView(pGuideLayer, self.pNewGuideFinger)
		    	-- else
		    	-- 	self.pNewGuideFinger:setVisible(true)
		    	end
		    	self.pNewGuideFinger:setData(self.nCurrStepId, pFingerUi)

		    else
		    	if self.pNewGuideFinger then
		    		self.pNewGuideFinger:setVisible(false)
		    		self.pNewGuideFinger:setData(nil)
		    	end
		    	if B_GUIDE_LOG then
					myprint("B_GUIDE_LOG showGuideLayer 配置配了 specialeffects = 1 不显示手指")
				end
		    end
	    else
	    	if self.pNewGuideFinger then
	    		self.pNewGuideFinger:setVisible(false)
	    		self.pNewGuideFinger:setData(nil)
	    	end
	    	if B_GUIDE_LOG then
				myprint("B_GUIDE_LOG showGuideLayer 没有配手指 不显示")
			end
	    end

    	--全屏
    	if tGuideData.chatbox == 1 then
    		if B_GUIDE_LOG then
				myprint("B_GUIDE_LOG showGuideLayer 显示全屏")
			end
    		if getIsSequeneceFree() then
    			--解锁功能跳
    			-- self:getIsUnlockJumpCity(self.nCurrStepId)

    			if not self.pNewGuideDrama then
					local NewGuideDrama = require("app.layer.newguide.NewGuideDrama")
					self.pNewGuideDrama = NewGuideDrama.new()
					pGuideLayer:addView(self.pNewGuideDrama)
					centerInView(pGuideLayer, self.pNewGuideDrama)
				else
					self.pNewGuideDrama:setVisible(true)
				end
				self.pNewGuideDrama:setData(self.nCurrStepId)
				--加入显示控制权
    			showSequenceFunc(e_show_seq.newguidedrama)

    			if B_GUIDE_LOG then
					myprint("B_GUIDE_LOG showGuideLayer 显示全屏2")
				end
    		end
		else
			if self.pNewGuideDrama then
				self.pNewGuideDrama:setVisible(false)
				--显示下一个
				showNextSequenceFunc(e_show_seq.newguidedrama)
			end
		end

    	--单屏
    	if tGuideData.chatbox == 2 or tGuideData.chatbox == 3 then
    		if B_GUIDE_LOG then
				myprint("B_GUIDE_LOG showGuideLayer 显示单屏 当前步骤", self.nCurrStepId)
			end
    		if getIsSequeneceFree() then
    			--解锁功能跳
    			-- self:getIsUnlockJumpCity(self.nCurrStepId)

				if not self.pNewGuideTip then
					local NewGuideTip = require("app.layer.newguide.NewGuideTip")
					self.pNewGuideTip = NewGuideTip.new()
					pGuideLayer:addView(self.pNewGuideTip)
					centerInView(pGuideLayer, self.pNewGuideTip)
				else
					self.pNewGuideTip:setVisible(true)
				end
				self.pNewGuideTip:setData(self.nCurrStepId)
				local nUpState = 0
				if self.pNewGuideFinger then
					nUpState = self.pNewGuideFinger:getInUpHalfState()
				end
				self.pNewGuideTip:setPosByFingerUi(nUpState)
				if B_GUIDE_LOG then
					myprint("B_GUIDE_LOG showGuideLayer 显示单屏2")
				end
				--加入显示控制权
    			showSequenceFunc(e_show_seq.newguidehalf)
    		else
    			if B_GUIDE_LOG then
					myprint("B_GUIDE_LOG showGuideLayer 控制权限不为空")
				end
    			if self.pNewGuideTip and self.pNewGuideTip:isVisible() then
    				self.pNewGuideTip:setData(self.nCurrStepId)
    			end
    			--发送服务器记录
			end
		else
			if self.pNewGuideTip then
				if B_GUIDE_LOG then
					myprint("B_GUIDE_LOG showGuideLayer 隐藏单屏")
				end
				self.pNewGuideTip:setVisible(false)
				--显示下一个
				showNextSequenceFunc(e_show_seq.newguidehalf)
			end
		end
	end
end

--设置当前
function NewGuideMgr:setCurrStepId( nCurrStepId )
	if self.nCurrStepId == nCurrStepId then
	else
		if nCurrStepId then
			--新手指引服务器请求
			SocketManager:sendMsg("reqGuideRecord", {nCurrStepId})
			-- print("发送给服务器记录 -------- ", nCurrStepId)
		end
	end
	self.nCurrStepId = nCurrStepId
end

--获取当前步骤id
function NewGuideMgr:getCurrStepId()
	return self.nCurrStepId
end


--建筑移动定位
function NewGuideMgr:localBuildUi( bIsMove )
	if not self.nCurrStepId then
		return
	end

	local tGuideData = getGuideData(self.nCurrStepId)
	if B_GUIDE_LOG then
		myprint("B_GUIDE_LOG NewGuideMgr:localBuildUi !!!!!!!!!!!!!!!!!! ", self.nCurrStepId, tGuideData.fingerid)
	end
	if tGuideData then
		local nCell = nil
		local bIsOpenSecond = false
		local nFingerId = tGuideData.fingerid
		if not nFingerId or nFingerId == 0 then
			return
		end
		if nFingerId == e_guide_finer.house1_lvup_btn then
			nCell = nHouse1
			bIsOpenSecond = true
		elseif nFingerId == e_guide_finer.house1_speed_btn then
			nCell = nHouse1
		elseif nFingerId == e_guide_finer.house2_lvup_btn then
			nCell = nHouse2
			bIsOpenSecond = true
		elseif nFingerId == e_guide_finer.house2_speed_btn then
			nCell = nHouse2
		elseif nFingerId == e_guide_finer.house3_lvup_btn then
			nCell = nHouse3
			bIsOpenSecond = true
		elseif nFingerId == e_guide_finer.house3_speed_btn then
			nCell = nHouse3
		elseif nFingerId == e_guide_finer.house5_lvup_btn then
			nCell = nHouse5
			bIsOpenSecond = true
		elseif nFingerId == e_guide_finer.house5_res_bubble or nFingerId == e_guide_finer.house5_speed_btn then
			nCell = nHouse5
		elseif nFingerId == e_guide_finer.wood1_lvup_btn then
			nCell = nWood1
			bIsOpenSecond = true
		elseif nFingerId == e_guide_finer.wood1_speed_btn then
			nCell = nWood1
		elseif nFingerId == e_guide_finer.wood2_lvup_btn then
			nCell = nWood2
			bIsOpenSecond = true
		elseif nFingerId == e_guide_finer.wood2_speed_btn then
			nCell = nWood2
		elseif nFingerId == e_guide_finer.wood3_lvup_btn  then
			nCell = nWood3
			bIsOpenSecond = true
		elseif nFingerId == e_guide_finer.wood3_speed_btn then
			nCell = nWood3
		elseif nFingerId == e_guide_finer.wood4_lvup_btn then
			nCell = nWood4
			bIsOpenSecond = true
		elseif nFingerId == e_guide_finer.wood4_speed_btn then
			nCell = nWood4
		elseif nFingerId == e_guide_finer.wood5_lvup_btn then
			nCell = nWood5
			bIsOpenSecond = true
		elseif nFingerId == e_guide_finer.wood5_res_bubble or nFingerId == e_guide_finer.wood5_speed_btn then
			nCell = nWood5
		elseif nFingerId == e_guide_finer.palace_lvup_btn or nFingerId == e_guide_finer.palace_lvup_speed_btn then
			local tBuild = Player:getBuildData():getBuildById(e_build_ids.palace)
			if tBuild then
				bIsOpenSecond = true
				nCell = tBuild.nCellIndex
			end
		elseif nFingerId == e_guide_finer.palace_speed_btn then
			local tBuild = Player:getBuildData():getBuildById(e_build_ids.palace)
			if tBuild then
				nCell = tBuild.nCellIndex
			end
		--科技院进入按钮
		elseif nFingerId == e_guide_finer.tnoly_enter_btn or nFingerId == e_guide_finer.tnoly_lvup_btn then
			local tBuild = Player:getBuildData():getBuildById(e_build_ids.tnoly)
			if tBuild then
				bIsOpenSecond = true
				nCell = tBuild.nCellIndex
			end
		--工坊进入按钮
		elseif nFingerId == e_guide_finer.atelier_enter_btn then
			local tBuild = Player:getBuildData():getBuildById(e_build_ids.atelier)
			if tBuild then
				bIsOpenSecond = true
				nCell = tBuild.nCellIndex
			end
		--统帅府
		elseif nFingerId == e_guide_finer.tcf_enter_btn then
			local tBuild = Player:getBuildData():getBuildById(e_build_ids.tcf)
			if tBuild then
				bIsOpenSecond = true
				nCell = tBuild.nCellIndex
			end
		elseif nFingerId == e_guide_finer.tnoly_speed_btn then
			local tBuild = Player:getBuildData():getBuildById(e_build_ids.tnoly)
			if tBuild then
				nCell = tBuild.nCellIndex
			end
		--农田1升级 加速 和征收
		elseif nFingerId == e_guide_finer.food1_lvup_btn then
			nCell = nFood1
			bIsOpenSecond = true
		elseif nFingerId == e_guide_finer.food1_res_bubble or nFingerId == e_guide_finer.food1_speed_btn then
			nCell = nFood1
		--农田5升级 加速 和征收
		elseif nFingerId == e_guide_finer.food5_lvup_btn then
			nCell = nFood5
			bIsOpenSecond = true
		elseif nFingerId == e_guide_finer.food5_res_bubble or nFingerId == e_guide_finer.food5_speed_btn then
			nCell = nFood5
		--仓库升级
		elseif nFingerId == e_guide_finer.store_lvup_btn then
			local tBuild = Player:getBuildData():getBuildById(e_build_ids.store)
			if tBuild then
				nCell = tBuild.nCellIndex
				bIsOpenSecond = true
			end
		--仓库加速
		elseif nFingerId == e_guide_finer.store_speed_btn then
			local tBuild = Player:getBuildData():getBuildById(e_build_ids.store)
			if tBuild then
				nCell = tBuild.nCellIndex
			end
		--兵营进入按钮
		elseif nFingerId == e_guide_finer.camp_enter_btn then
			local tBuild = Player:getBuildData():getBuildById(e_build_ids.infantry)
			if tBuild then
				nCell = tBuild.nCellIndex
				bIsOpenSecond = true
			end
		--铁匠铺进入按钮
		elseif nFingerId == e_guide_finer.smithshop_build then
			local tBuild = Player:getBuildData():getBuildById(e_build_ids.tjp)
			if tBuild then
				nCell = tBuild.nCellIndex
			end
		--珍宝阁进入
		elseif nFingerId == e_guide_finer.treasure_build then
			local tBuild = Player:getBuildData():getBuildById(e_build_ids.jbp)
			if tBuild then
				nCell = tBuild.nCellIndex
			end
		--骑兵营升级和加速
		elseif nFingerId == e_guide_finer.sowar_lvup_btn then
			local tBuild = Player:getBuildData():getBuildById(e_build_ids.sowar)
			if tBuild then
				nCell = tBuild.nCellIndex
				bIsOpenSecond = true
			end
		--骑兵营升级和加速
		elseif nFingerId == e_guide_finer.sowar_speed_btn then
			local tBuild = Player:getBuildData():getBuildById(e_build_ids.sowar)
			if tBuild then
				nCell = tBuild.nCellIndex
			end
		--乱军3头像
		elseif nFingerId == e_guide_finer.house3_army_btn then
			if bIsMove then
				local pObj = {}
				pObj.nCell = 1005
				pObj.nBuildId = e_build_ids.house
				sendMsg(ghd_move_to_point_dlg_msg, pObj)
				return
			end
		--神器入口居中
		elseif nFingerId == e_guide_finer.gequip_enter_btn then
			sendMsg(ghd_homebottom_menu_center, e_home_bottom.godweapon)
			return
		--拜将台
		elseif nFingerId == e_guide_finer.buyhero_build then
			local tBuild = Player:getBuildData():getBuildByCell(e_build_cell.bjt)
			if tBuild then
				nCell = tBuild.nCellIndex
			end
		--战争大厅
		elseif nFingerId == e_guide_finer.warhall_build then
			local tBuild = Player:getBuildData():getBuildById(e_build_ids.warhall)
			if tBuild then
				nCell = tBuild.nCellIndex
			end
		end
		if nCell then
			if bIsMove then
				if self.bIsStopLocalUi then
					return
				end

				local tObject = {}
				tObject.nCell = nCell
				-- tObject.nFunc = function (  )
				-- 	-- body

				-- end
				sendMsg(ghd_move_to_build_dlg_msg,tObject)
				if B_GUIDE_LOG then
					print("B_GUIDE_LOG ghd_move_to_build_dlg_msg", nCell)
				end
				if bIsOpenSecond then
					if B_GUIDE_LOG then
						print("self:isHasSecondMenu(nFingerId)")
					end
					--如果需要找手指（还没有找到手指)
					local bIsNeedFound = false
					if tolua.isnull(self.pFingerUis[nFingerId]) then
						bIsNeedFound = true
					end
					--如果有二级菜单就打开二级菜单
					if bIsNeedFound and self:isHasSecondMenu(nFingerId) then
						local tObject = {}
						tObject.nCell = nCell
						if B_GUIDE_LOG then
							print("ghd_show_build_actionbtn_msg763 = ", nCell)
						end
						print("ghd_show_build_actionbtn_msg  999999999999999")
						sendMsg(ghd_show_build_actionbtn_msg,tObject)
					end
				end
			end
			
		end
	end
end

--判断建筑是否有二级菜单
function NewGuideMgr:isHasSecondMenu(_nFingerId)
	if _nFingerId == e_guide_finer.smithshop_build then
		return false
	elseif _nFingerId == e_guide_finer.treasure_build then
		return false
	end
	return true
end

--判断是否是攻打乱军
--hideFinger:是否隐藏手指
function NewGuideMgr:isAttackArmyStep(hideFinger)
	local tStepData = getGuideData(self.nCurrStepId)
	if not tStepData.specialstep then
		return false
	end
	local tSpecial = luaSplit(tStepData.specialstep, ":")
	if tonumber(tSpecial[1]) == e_special_type.beat_army then
		if not hideFinger then
			sendMsg(ghd_world_dot_near_my_city,{nDotType = e_type_builddot.wildArmy,
				nDotLv = tonumber(tSpecial[2]), bHideFinger = true})
			sendMsg(ghd_wildarmy_circle_effect, {nDotLv = tonumber(tSpecial[2])})
		end
		return true
	end
	return false
end

--获取武将出征攻打的乱军等级, 是的话返回要攻打乱军的等级
function NewGuideMgr:getHeroBattleArmyLv()
	-- body
	local tCurTask = Player:getPlayerTaskInfo():getCurAgencyTask()
	if tCurTask then
		local tParam = luaSplit(tCurTask.sLinked, ":")
		if tonumber(tParam[1]) == e_dlg_index.taskworld then
			return tonumber(tParam[2])
		end
	else
		return false
	end
end

--判断小步骤是否完成
function NewGuideMgr:getIsNewGuideSubStepFinish( nStepId )
	local tStepData = getGuideData(nStepId)
	if not tStepData.specialstep then
		return false
	end
	local tSpecial = luaSplit(tStepData.specialstep, ":")
	if B_GUIDE_LOG then
		dump(tSpecial, "特殊步骤字段 ------ ")
	end
	--类型
	local nType = tonumber(tSpecial[1])
	--建筑id
	local nBuildId
	if tSpecial[2] then
		nBuildId = tonumber(tSpecial[2])
	end
	--升到等级
	local nToLv
	if tSpecial[3] then
		nToLv = tonumber(tSpecial[3])
	end
	--建筑升级
	if nType == e_special_type.lvup then
		--资源建筑
		if nBuildId < 10000 then
			return self:checkIsResBuildUpStep(nBuildId, nToLv)
		--非资源建筑
		else
			return self:checkIsBuildUpStep(nBuildId, nToLv)
		end
	--建筑免费加速
	elseif nType == e_special_type.speedup then
		--资源建筑
		if nBuildId < 10000 then
			return self:checkIsResBuildQuickStep(nBuildId, nToLv)
		--非资源建筑
		else
			return self:checkIsBuildQuickStep(nBuildId, nToLv)
		end
	--建筑道具加速
	elseif nType == e_special_type.useitem_speed_btn then
		--资源建筑
		if nBuildId < 10000 then
			return self:checkIsResBuildQuickStep(nBuildId, nToLv)
		--非资源建筑
		else
			return self:checkIsBuildQuickStep(nBuildId, nToLv)
		end
	--资源征收
	elseif nType == e_special_type.collect then
		return self:checkIsResCollectStep(nBuildId)
	--科技院领取科技
	elseif nType == e_special_type.get_tnoly then
		return self:checkIsGetTechnology()
	--铁匠铺加速
	elseif nType == e_special_type.speed_equip then
		return not Player:getEquipData():getIsCanSpeed()
	--铁匠铺领取装备
	-- elseif nType == e_special_type.get_equip then
	-- 	return self:checkIsTjpCanGetEquip()
	--升级按钮特效
	elseif nType == e_special_type.build_lvup then
		local nCellIdx = tonumber(tSpecial[2])
		--资源建筑
		if nCellIdx > n_start_suburb_cell then
			return self:checkIsResBuildUpStep(nCellIdx, nToLv)
		--非资源建筑
		else
			local tBuild = Player:getBuildData():getBuildByCell(nCellIdx)
			if tBuild then
				return self:checkIsBuildUpStep(tBuild.sTid, nToLv)
			end
			return false
		end
	elseif nType == e_special_type.show_hero then
		--展示获得武将特效界面
		local nHeroId = tonumber(tSpecial[2])
		local tDataList = {}
		local tKvData = {}
		tKvData.k = nHeroId
		tKvData.v = 1
		local tReward = {}
		tReward.d = {}
		tReward.g = {}
		table.insert(tReward.d, copyTab(tKvData))
		table.insert(tReward.g, copyTab(tKvData))
		table.insert(tDataList, tReward)

		local tObject = {}
		tObject.nType = e_dlg_index.showheromansion --dlg类型
		tObject.tReward = tDataList
		tObject.bHideGo = true
		sendMsg(ghd_show_dlg_by_type,tObject)
		return false
	end

end

--任务是否能领取
function NewGuideMgr:getIsTaskCanReward( nTaskId )
	local curAgencyTask = Player:getPlayerTaskInfo():getCurAgencyTask()
 	if curAgencyTask and (curAgencyTask.nIsFinished == 1 and curAgencyTask.nIsGetPrize == 0) then
 		if curAgencyTask.sTid == nTaskId then
 			return true
 		end
 	end
 	return false
end

--获取是否是任务领将步骤
function NewGuideMgr:getIsGetTaskReward( nStepId )
	for k,v in pairs(self.tRewardKey) do
		if v == nStepId then
			return true
		end
	end
	return false
end

--跳转到某个界面
function NewGuideMgr:jumpToDlg( nStepId )
	local tGuideData = getGuideData(nStepId)
	if tGuideData then
		if B_GUIDE_LOG then
			print("B_GUIDE_LOG NewGuideMgr:jumpToDlg ---------------")
		end
		if tGuideData.mode and tGuideData.interface then
			if B_GUIDE_LOG then
				print("B_GUIDE_LOG  tGuideData.mode , tGuideData.interface === ", tGuideData.mode, tGuideData.interface)
			end
			local tObject = {}
			tObject.nMode = tGuideData.mode		
			tObject.nInterface = tGuideData.interface	
			sendMsg(ghd_jumpto_dlg_msg, tObject)
			return true
		end
	end
	return false
end

-------------------------------------------------------
--资源建筑升级任务
function NewGuideMgr:checkIsResBuildUpStep( nBuildId, nLv )
	local tBSuburb = Player:getBuildData():getSuburbByCell(nBuildId)
	if tBSuburb then
		if (tBSuburb.nLv == nLv - 1 and tBSuburb.nState == e_build_state.uping ) or tBSuburb.nLv >= nLv then
			return true
		end
	end

	-- self:localBuildUi(true)
	return false
end

--资源建筑加速升级步骤2级任务
function NewGuideMgr:checkIsResBuildQuickStep( nBuildId, nLv )
	local tBSuburb = Player:getBuildData():getSuburbByCell(nBuildId)
	if tBSuburb then
		if tBSuburb.nLv >= nLv then
			return true
		end
	end
	
	-- self:localBuildUi(true)
	return false
end

--是否已征收
function NewGuideMgr:checkIsResCollectStep( nBuildId )
	-- body
	local tBSuburb = Player:getBuildData():getSuburbByCell(nBuildId)
	local tBuild = Player:getBuildData()
	if tBSuburb then
		local isAlreadyGet = false
		if Player:getPlayerTaskInfo():getLevyResTaskIsUnLock() then
			if tBuild:getColState() == 1 or tBuild:getColState() == 2 then --可征收
				isAlreadyGet = false
			else
				isAlreadyGet = true
			end
		else
			isAlreadyGet = true
		end
		if not isAlreadyGet then
			-- self:localBuildUi(true)
		end
		return isAlreadyGet
	end
	return true
end

--非资源建筑升级
function NewGuideMgr:checkIsBuildUpStep( nBuildId, nLv)
	local nCellIndex = nil
	local tBuild = Player:getBuildData():getBuildById(nBuildId)
	if tBuild then
		if (tBuild.nLv == nLv - 1 and tBuild.nState == e_build_state.uping ) or tBuild.nLv >= nLv then
			return true
		end
		-- self:localBuildUi(true)
	end
	return false
end

--非资源建筑加速升级任务
function NewGuideMgr:checkIsBuildQuickStep( nBuildId, nLv )
	local tBuild = Player:getBuildData():getBuildById(nBuildId)
	if tBuild then
		if tBuild.nLv >= nLv then
			return true
		end

		-- self:localBuildUi(true)
	end
	return false
end

-- --非资源建筑升级通过格子下标判断
-- function NewGuideMgr:checkIsBuildUpStepByCell( nCellIdx, nLv)
-- 	local tBuild = Player:getBuildData():getBuildByCell(nCellIdx)
-- 	if tBuild then
-- 		if tBuild.nLv >= nLv then
-- 			return true
-- 		end
-- 		local tObject = {}
-- 		tObject.nCell = nCellIdx
-- 		--进行场景移动操作
-- 		sendMsg(ghd_move_to_build_dlg_msg, tObject)
-- 		--打开建筑
-- 		if B_GUIDE_LOG then
-- 			print("ghd_show_build_actionbtn_msg1006",nCellIdx)
-- 		end
-- 		sendMsg(ghd_show_build_actionbtn_msg, tObject)

-- 	end
-- 	return false
-- end

--科技院是否领取了已完成的科技
function NewGuideMgr:checkIsGetTechnology()
	-- body
	--正在研究的科技
	local tUpingTnoly = Player:getTnolyData():getUpingTnoly()
	if tUpingTnoly then
		if tUpingTnoly:getUpingFinalLeftTime() <= 0 then
			return false
		else
			return true
		end
	else
		return true
	end
end

--铁匠铺是否领取了装备
function NewGuideMgr:checkIsTjpCanGetEquip()
	-- body
	if Player:getEquipData():getIsFinishMakeEquip() then
		return false
	else
		return true
	end
end

--是否可以显示建筑解锁特效
function NewGuideMgr:getIsCanPlayBuidopen( )
	if self:getIsInGuide() then
		local nStepId = self:getCurrStepId()
		if nStepId then
			local tGuideData = getGuideData(nStepId)
			if not tGuideData then
				if B_GUIDE_LOG then
					print("tGuideData no stepId", nStepId)
				end
				return true
			end
			if tGuideData.buildid then
				if B_GUIDE_LOG then
					print("tGuideData has buildid", tGuideData.buildid)
				end
				return true
			end

			return false
		end
		if B_GUIDE_LOG then
			print("NewGuideMgr:getIsCanPlayBuidopen")
		end
	end
	return true
end

--是否建筑播放特效
function NewGuideMgr:isShowBuildOpen( nStepId )
	if not nStepId then
		if B_GUIDE_LOG then
			myprint("B_GUIDE_LOG NewGuideMgr:isShowBuildOpen not nStepId")
		end
		return false
	end
	--如果是播放建筑开启特效，
	local tGuideData = getGuideData(nStepId)
	if not tGuideData then
		if B_GUIDE_LOG then
			myprint("B_GUIDE_LOG NewGuideMgr:isShowBuildOpen not tGuideData")
		end
		return
	end

	if tGuideData.buildid then
		--判断是否已解锁，是就判断是否有解锁持
		local tBuildId = {}
		if string.find(tGuideData.buildid, ";") then
			local tBuildIdStr = luaSplit(tGuideData.buildid, ";")
			for i=1,#tBuildIdStr do
				table.insert(tBuildId, tonumber(tBuildIdStr[i]))
			end
		else
			local nBuildId = tonumber(tGuideData.buildid)
			if nBuildId then
				table.insert(tBuildId, nBuildId)
			end
		end

		--判断是否已解锁，是就执行下一条，否就判断是否有建筑数据
		if #tBuildId > 0 then
			local bIsOpened = true
			for i=1,#tBuildId do
				local nBuildId = tBuildId[i]
				if nBuildId < 10000 then
					local tBSuburb = Player:getBuildData():getSuburbByCell(nBuildId)
					if not tBSuburb then
						bIsOpened = false
						break
					end
				else
					local tBuild = Player:getBuildData():getBuildById(nBuildId)
					if not tBuild then
						bIsOpened = false
						break
					end
				end
			end
			--判断是否有解锁建筑数据播放
			local tData = getUnLockBuildsData()
			if tData and table.nums(tData) > 0 then
				--展示解锁提示框
				showUnlockBuildDlg()
				--设置下一条新手步骤（完成当前步骤)
				self:setCurrStepId(tGuideData.nextstep)

				if B_GUIDE_LOG then
					myprint("有解锁建筑数据播放 完成当前步骤 nStepId", nStepId)
				end
				return true
			end

			--已经解锁过的就显示下一条
			if bIsOpened then
				if B_GUIDE_LOG then
					myprint("没有解锁建筑数据，但是已经解锁 完成当前步骤 nStepId", nStepId)
				end
				--显示下一条骤
				self:showNewGuide(tGuideData.nextstep, 6)
				return true
			end
			--解锁任务数据不在些触发
			return true
		end
	end

	return false
end

-------------------------------------------------------
--ui
--pUi：控件
--tBuildData:建筑数据
function NewGuideMgr:registeredBuildQuickUi( pUi, tBuildData, bIsCanQuickFree)
	local sMsg = nil
	if not tBuildData then
		return
	end
	if tBuildData.sTid == e_build_ids.house or
		tBuildData.sTid == e_build_ids.wood or
		tBuildData.sTid == e_build_ids.farm or
		tBuildData.sTid == e_build_ids.iron then
		local nCellIndex = tBuildData.nCellIndex
		if nCellIndex == nHouse1 then
			sMsg = e_guide_finer.house1_speed_btn
		elseif nCellIndex == nHouse2 then
			sMsg = e_guide_finer.house2_speed_btn
		elseif nCellIndex == nHouse3 then
			sMsg = e_guide_finer.house3_speed_btn
		elseif nCellIndex == nHouse5 then
			sMsg = e_guide_finer.house5_speed_btn
		elseif nCellIndex == nWood1 then
			sMsg = e_guide_finer.wood1_speed_btn
		elseif nCellIndex == nWood2 then
			sMsg = e_guide_finer.wood2_speed_btn
		elseif nCellIndex == nWood3 then
			sMsg = e_guide_finer.wood3_speed_btn
		elseif nCellIndex == nWood4 then
			sMsg = e_guide_finer.wood4_speed_btn
		elseif nCellIndex == nWood5 then
			sMsg = e_guide_finer.wood5_speed_btn
		elseif nCellIndex == nFood1 then
			sMsg = e_guide_finer.food1_speed_btn
		elseif nCellIndex == nFood5 then
			sMsg = e_guide_finer.food5_speed_btn
		end
	elseif tBuildData.sTid == e_build_ids.palace then
		sMsg = e_guide_finer.palace_speed_btn
	elseif tBuildData.sTid == e_build_ids.store then
		sMsg = e_guide_finer.store_speed_btn
	elseif tBuildData.sTid == e_build_ids.tnoly then
		sMsg = e_guide_finer.tnoly_speed_btn
	elseif tBuildData.sTid == e_build_ids.sowar then
		sMsg = e_guide_finer.sowar_speed_btn
	end

	if sMsg then
		if bIsCanQuickFree then--可加速
			self:setNewGuideFinger(pUi, sMsg)
		else
			self:setNewGuideFinger(nil, sMsg)
		end
	end
end

--手指点击郊外资源免费加速
function NewGuideMgr:onBuildSpeedBtnClicked( _buildCell, _buildId)
	if B_GUIDE_LOG then
		print("手指点击建筑免费加速 -------- ", _buildCell, _buildId)
	end
	-- body
	if not _buildCell or not _buildId then return end 
	if _buildCell > n_start_suburb_cell then --郊外资源建筑
		if _buildCell == nHouse1 then
			self:setNewGuideFingerClicked(e_guide_finer.house1_speed_btn)
		elseif _buildCell == nHouse2 then
			self:setNewGuideFingerClicked(e_guide_finer.house2_speed_btn)
		elseif _buildCell == nHouse3 then
			self:setNewGuideFingerClicked(e_guide_finer.house3_speed_btn)
		elseif _buildCell == nHouse5 then
			self:setNewGuideFingerClicked(e_guide_finer.house5_speed_btn)
		elseif _buildCell == nWood1 then
			self:setNewGuideFingerClicked(e_guide_finer.wood1_speed_btn)
		elseif _buildCell == nWood2 then
			self:setNewGuideFingerClicked(e_guide_finer.wood2_speed_btn)
		elseif _buildCell == nWood3 then
			self:setNewGuideFingerClicked(e_guide_finer.wood3_speed_btn)
		elseif _buildCell == nWood4 then
			self:setNewGuideFingerClicked(e_guide_finer.wood4_speed_btn)
		elseif _buildCell == nWood5 then
			self:setNewGuideFingerClicked(e_guide_finer.wood5_speed_btn)
		elseif _buildCell == nFood1 then
			self:setNewGuideFingerClicked(e_guide_finer.food1_speed_btn)
		elseif _buildCell == nFood5 then
			self:setNewGuideFingerClicked(e_guide_finer.food5_speed_btn)
		end
	else                  -- 非资源建筑
		if _buildId == e_build_ids.palace then
			self:setNewGuideFingerClicked(e_guide_finer.palace_speed_btn)
		elseif _buildId == e_build_ids.store then
			self:setNewGuideFingerClicked(e_guide_finer.store_speed_btn)
		elseif _buildId == e_build_ids.tnoly then
			self:setNewGuideFingerClicked(e_guide_finer.tnoly_speed_btn)
		elseif _buildId == e_build_ids.sowar then
			self:setNewGuideFingerClicked(e_guide_finer.sowar_speed_btn)
		end
	end
end

--征收资源
function NewGuideMgr:registeredBuildCollectUi( pUi, tBuildData, bIsCanCollect)
	local sMsg = nil
	if not tBuildData then
		return
	end
	local nCellIndex = tBuildData.nCellIndex

	if tBuildData.sTid == e_build_ids.farm then
		if nCellIndex == nFood1 then
			sMsg = e_guide_finer.food1_res_bubble
		elseif nCellIndex == nFood5 then
			sMsg = e_guide_finer.food5_res_bubble
		end
	elseif tBuildData.sTid == e_build_ids.house then
		if nCellIndex == nHouse5 then
			sMsg = e_guide_finer.house5_res_bubble
		end
	elseif tBuildData.sTid == e_build_ids.wood then
		if nCellIndex == nWood5 then
			sMsg = e_guide_finer.wood5_res_bubble
		end
	end 

	if sMsg then
		if bIsCanCollect then    --可征收
			self:setNewGuideFinger(pUi, sMsg)
		else
			self:setNewGuideFinger(nil, sMsg)
		end
	end
end


--ui相关
--pUi：控件
--tBuildData:建筑数据
--bIsShow:是否显示
function NewGuideMgr:registeredBuildLvUi( pUi, tBuildData, bIsShow)
	local sMsg = nil
	if not tBuildData then
		return
	end
	if tBuildData.sTid == e_build_ids.house or
		tBuildData.sTid == e_build_ids.wood or
		tBuildData.sTid == e_build_ids.farm or
		tBuildData.sTid == e_build_ids.iron then
		local nCellIndex = tBuildData.nCellIndex
		if nCellIndex == nHouse1 then
			sMsg = e_guide_finer.house1_lvup_btn
		elseif nCellIndex == nHouse2 then
			sMsg = e_guide_finer.house2_lvup_btn
		elseif nCellIndex == nHouse3 then
			sMsg = e_guide_finer.house3_lvup_btn
		elseif nCellIndex == nHouse5 then
			sMsg = e_guide_finer.house5_lvup_btn
		elseif nCellIndex == nWood1 then
			sMsg = e_guide_finer.wood1_lvup_btn
		elseif nCellIndex == nWood2 then
			sMsg = e_guide_finer.wood2_lvup_btn
		elseif nCellIndex == nWood3 then
			sMsg = e_guide_finer.wood3_lvup_btn
		elseif nCellIndex == nWood4 then
			sMsg = e_guide_finer.wood4_lvup_btn
		elseif nCellIndex == nWood5 then
			sMsg = e_guide_finer.wood5_lvup_btn
		elseif nCellIndex == nFood1 then
			sMsg = e_guide_finer.food1_lvup_btn
		elseif nCellIndex == nFood5 then
			sMsg = e_guide_finer.food5_lvup_btn
		end
	elseif tBuildData.sTid == e_build_ids.palace then
		sMsg = e_guide_finer.palace_lvup_btn
	elseif tBuildData.sTid == e_build_ids.store then
		sMsg = e_guide_finer.store_lvup_btn
	elseif tBuildData.sTid == e_build_ids.tnoly then
		sMsg = e_guide_finer.tnoly_lvup_btn
	elseif tBuildData.sTid == e_build_ids.sowar then
		sMsg = e_guide_finer.sowar_lvup_btn
	end

	if sMsg then
		if bIsShow then
			self:setNewGuideFinger(pUi, sMsg)
		else
			self:setNewGuideFinger(nil, sMsg)
		end
	end
end

--ui相关
--pUi：控件
--tBuildData:建筑数据
--bIsShow:是否显示
function NewGuideMgr:registeredBuildSpeedUi( pUi, tBuildData, bIsShow)
	local sMsg = nil
	if not tBuildData then
		return
	end
	if tBuildData.sTid == e_build_ids.palace then
		sMsg = e_guide_finer.palace_lvup_speed_btn
	end
	if sMsg then
		if bIsShow then
			self:setNewGuideFinger(pUi, sMsg)
		else
			self:setNewGuideFinger(nil, sMsg)
		end
	end
end

--ui相关
--pUi：控件
--tBuildData:建筑数据
--bIsShow:是否显示
function NewGuideMgr:registeredBuildEnterUi( pUi, tBuildData, bIsShow)
	local sMsg = nil
	if not tBuildData then
		return
	end
	--科技院
	if tBuildData.sTid == e_build_ids.tnoly then
		sMsg = e_guide_finer.tnoly_enter_btn
		-- print("e_guide_finer.tnoly_enter_btn       ",bIsShow)
	--步兵营
	elseif tBuildData.sTid == e_build_ids.infantry then
		sMsg = e_guide_finer.camp_enter_btn
	--工坊
	elseif tBuildData.sTid ==  e_build_ids.atelier then
		sMsg = e_guide_finer.atelier_enter_btn
	--统帅府
	elseif tBuildData.sTid ==  e_build_ids.tcf then
		sMsg = e_guide_finer.tcf_enter_btn
	end

	if sMsg then
		if bIsShow then
			self:setNewGuideFinger(pUi, sMsg)
		else
			self:setNewGuideFinger(nil, sMsg)
		end
	end
end


--pUi：建筑本身layer
--tBuildData:建筑数据
function NewGuideMgr:registeredBuildSelfEnter(pUi, tBuildData)
	local sMsg = nil
	if not tBuildData then
		return
	end
	--铁匠铺
	if tBuildData.sTid == e_build_ids.tjp then
		sMsg = e_guide_finer.smithshop_build
	--珍宝阁
	elseif tBuildData.sTid == e_build_ids.jbp then
		sMsg = e_guide_finer.treasure_build
	--拜将台
	elseif tBuildData.sTid == e_build_ids.bjt then
		sMsg = e_guide_finer.buyhero_build
	--战争大厅
	elseif tBuildData.sTid == e_build_ids.warhall then
		sMsg = e_guide_finer.warhall_build
	end

	if sMsg then
		self:setNewGuideFinger(pUi, sMsg)
	end
end


function NewGuideMgr:setIsStopLocalUi( bIsStop )
	self.bIsStopLocalUi = bIsStop
end

--获取当前手指的显示状态与否
function NewGuideMgr:getIsFingerShow()
	-- body
	if self.pNewGuideFinger then
		return self.pNewGuideFinger:isVisible()
	end
end


return NewGuideMgr