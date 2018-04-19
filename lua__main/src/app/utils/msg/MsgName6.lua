----------------------------------------------------- 
-- author: maheng
-- updatetime: 2017-01-16 16:01:05 
-- Description: 消息名称的类
-----------------------------------------------------
-- 第一类消息名称，必须带gud_开头(意思为updatedata)，
-- 用来标识数据发生变化了，界面可以刷新了，不携带任何操作行为
-- 目的为了可以执行分帧刷新处理

--背包界面刷新
gud_refresh_baginfo = "gud_refresh_baginfo"
--刷新排行榜数据刷新
gud_refresh_rankinfo = "gud_refresh_rankinfo"

--王宫界面资源数据刷新
gud_refresh_palace_resource = "gud_refresh_palace_resource"
--任务数据刷新
gud_refresh_task_msg = "gud_refresh_task_msg"
--国家任务界面刷新
gud_refresh_countrytask = "gud_refresh_countrytask"
--国家界面刷新
gud_refresh_country_msg = "gud_refresh_country_msg"
--国家官员刷新
gud_refresh_country_official_msg = "gud_refresh_country_official_msg"
--国家荣誉刷新
gud_refresh_country_honor_msg = "gud_refresh_country_honor_msg"
--
gud_refresh_country_log_msg = "gud_refresh_country_log_msg"
--将军任免刷新
gud_refresh_generalrenmian_msg = "gud_refresh_generalrenmian_msg"
--国家城池
gud_refresh_countrycity_msg = "gud_refresh_countrycity_msg"
--好友信息刷新
gud_refresh_friends_msg = "gud_refresh_friends_msg"

--竞技场数据刷新
gud_refresh_arena_msg = "gud_refresh_arena_msg"
---------------------------------------------------------------------------------------
-- 第二类消息名称，必须带ghd_开头(handle)，
-- 用来通知操作行为的，例如打开对话框，飘字等操作行为
-- 目的为了立马刷新界面
--刷新背包界面
ghd_refresh_baginfo = "gud_refresh_baginfo"
--刷新雇用文官倒计时显示刷新
ghd_refresh_palacecivil = "ghd_refresh_palacecivil"
--刷新王宫建筑数据消息
ghd_refresh_palace_msg = "ghd_refresh_palace_msg"
--使用物品
--pMsgObj （table）: useId--物品id useNum--物品数量 type--使用情况1-正常使用 2-购买并使用
ghd_useItems_msg = "ghd_useItems_msg"
--仓库数据刷新消息
ghd_refresh_warehouse_msg = "ghd_refresh_warehouse_msg"
--工坊数据刷新消息
ghd_refresh_atelier_msg = "ghd_refresh_atelier_msg"
--刷新雇用研究员信息
ghd_refresh_researcher_msg = "ghd_refresh_researcher_msg"
--获取其他玩家信息消息
--pMsgObj （table）: nplayerId--玩家ID
ghd_get_playerinfo_msg = "ghd_get_playerinfo_msg"
--
--免打扰设置项状态改变
ghd_no_desturb_status_change = "ghd_no_desturb_status_change"

--打开获取奖励对话框
--pMsgObj （table）: nTaskId--任务ID
ghd_open_dlg_gettaskprize = "ghd_open_dlg_gettaskprize"

--国家系统开放事件
ghd_open_countrysystem_msg = "ghd_open_countrysystem_msg"

--装备背包已买事件
ghd_equipBag_fulled_msg = "ghd_equipBag_fulled_msg"

--打开建筑对话框的home界面变化 nType = 1, 2 1--隐藏 2--显示
ghd_home_change_for_buildup_msg = "ghd_home_change_for_buildup_msg"

--任务跳转消息 nTaskID 任务ID
ghd_task_goto_msg = "ghd_task_goto_msg"

--打开界面任务消息
ghd_open_dlg_task_msg = "ghd_open_dlg_task_msg"

--预计生产时间刷新消息
ghd_refresh_atelier_protime_msg = "ghd_refresh_atelier_protime_msg"

--清理排行数据信息
ghd_clear_rankinfo_msg = "ghd_clear_rankinfo_msg"

--重新请求活动排行榜数据
ghd_rank_act_accounts_msg = "ghd_rank_act_accounts_msg"

--获取当前的时间我们不会获取时间的
ghd_atelier_gold_finish_msg = "ghd_atelier_gold_finish_msg"

--国家荣誉奖励变化
ghd_country_honor_prize_change_msg = "ghd_country_honor_prize_change_msg"

ghd_item_home_menu_red_msg = "ghd_item_home_menu_red_msg"
--ItemHomeMenu 任务红点消息
ghd_task_home_menu_red_msg = "ghd_task_home_menu_red_msg"
--国家红点消息
ghd_country_home_menu_red_msg = "ghd_country_home_menu_red_msg"
--国家膜拜红点消息
ghd_mobai_red_msg = "ghd_mobai_red_msg"

--多建筑升级任务引导
ghd_builds_task_guide_msg = "ghd_builds_task_guide_msg"

--移动到指定位置
ghd_move_to_point_dlg_msg = "ghd_move_to_point_dlg_msg"

--播放领奖特效
ghd_player_get_taskprize_msg = "ghd_player_get_taskprize_msg"

--征收任务位置引导
ghd_collect_task_guide_msg = "ghd_collect_task_guide_msg"

--发送Vip等级变化消息
ghd_refresh_playerviplv_msg = "ghd_refresh_playerviplv_msg"

--重新发送玩家主线任务奖励提示
ghd_renotice_taskprize_msg = "ghd_renotice_taskprize_msg"

--任务相关的建筑按钮引导
ghd_task_build_actionbtn_msg = "ghd_task_build_actionbtn_msg"

--每日目标引导消息
ghd_daily_task_guide_msg = "ghd_daily_task_guide_msg"

--聊天都想数据刷新
ghd_chat_icon_refresh_msg = "ghd_chat_icon_refresh_msg"

--选择红包好友
ghd_selected_redpocket_msg = "ghd_selected_redpocket_msg"

--红包刷新
ghd_refresh_redpocket_msg = "ghd_refresh_redpocket_msg"

--免费召唤活动数据刷新
ghd_refresh_actfreecall_msg = "ghd_refresh_actfreecall_msg"


--刷新每日免费迁往州的次数刷新
ghd_refresh_freetostate_msg = "ghd_refresh_freetostate_msg"

--统帅府数据刷新
ghd_refresh_chiefhouse_msg = "ghd_refresh_chiefhouse_msg"

--高级御兵术升级暴击消息
ghd_refresh_troop_trap_msg = "ghd_refresh_troop_trap_msg"



---------------------------竞技场------------------------
--刷新竞技场视图消息
ghd_refresh_arena_view_msg = "ghd_refresh_arena_view_msg"
--刷新竞技场排行
ghd_refresh_arena_rank_msg = "ghd_refresh_arena_rank_msg"
--刷新竞技场幸运列表
ghd_refresh_arena_lucky_msg = "ghd_refresh_arena_lucky_msg"
--我的战斗记录红点
ghd_refresh_my_arena_red_msg = "ghd_refresh_my_arena_red_msg"

ghd_refresh_god_fight_data_msg = "ghd_refresh_god_fight_data_msg"

ghd_adjust_arena_hero_msg = "ghd_adjust_arena_hero_msg"

ghd_arena_lineup_change_msg = "ghd_arena_lineup_change_msg"

ghd_arena_record_change_msg = "ghd_arena_record_change_msg"

---------------------------竞技场------------------------

---------------------------加速弹框------------------------
--设置数字
ghd_inputnum_setting_num_msg = "ghd_inputnum_setting_num_msg"

--加速科技研究
ghd_speed_tnoly_msg = "ghd_speed_tnoly_msg"
--加速装备打造
ghd_speed_make_equip_msg = "ghd_speed_make_equip_msg"
--加速工坊生产
ghd_speed_atelier_msg = "ghd_speed_atelier_msg"
---------------------------加速弹框------------------------

---------------------------VIP页面消息--------------------------------
ghd_vip_turnpage_msg = "ghd_vip_turnpage_msg"
---------------------------VIP页面消息--------------------------------


---------------------------韬光养晦--------------------------------
ghd_remains_refresh_msg = "ghd_remains_refresh_msg"

---------------------------韬光养晦--------------------------------

---------------------------自动建造消息--------------------------------
ghd_auto_build_mgr_msg = "ghd_auto_build_mgr_msg"
---------------------------自动建造消息--------------------------------

----------------------------显示主界面 活动加速按钮 点击反馈效果 -------------
ghd_build_bubble_clicktx_msg = "ghd_build_bubble_clicktx_msg"
----------------------------显示主界面 活动加速按钮 点击反馈效果 -------------

----------------------------玩家当前区域纣王数量变化-------------
ghd_kingzhou_num_change_msg = "ghd_kingzhou_num_change_msg"
----------------------------玩家当前区域纣王数量变化-------------