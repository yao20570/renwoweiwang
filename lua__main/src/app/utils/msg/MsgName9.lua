--
-- Author: luwenjing
-- Date: 2017-11-1 10:04:25
--消息名称的类

-- 第一类消息名称，必须带gud_开头(意思为updatedata)，
-- 用来标识数据发生变化了，界面可以刷新了，不携带任何操作行为
-- 目的为了可以执行分帧刷新处理




-- 第二类消息名称，必须带ghd_开头(handle)，
-- 用来通知操作行为的，例如打开对话框，飘字等操作行为
-- 目的为了立马刷新界面

ghd_daily_gift_push = "ghd_daily_gift_push"

ghd_world_country_war_support_used = "ghd_world_country_war_support_used"

ghd_hero_travel_update = "ghd_hero_travel_update"
ghd_hero_travel_push = "ghd_hero_travel_push"
ghd_laba_stop = "ghd_laba_stop" --拉霸自然停止
ghd_laba_stop_force = "ghd_laba_stop_force"  --拉霸强制停止
ghd_zero_act_push = "ghd_zero_act_push"  --零点活动推送
ghd_update_city_owner_apply = "ghd_update_city_owner_apply"  --系统城池城主发生变化
ghd_catch_red_pocket = "ghd_catch_red_pocket"  --抢红包刷新红包状态
gud_load_chat_data = "gud_load_chat_data"  --可以加载聊天数据了
ghd_sys_city_mingjie_action = "ghd_sys_city_mingjie_action"  --城池是否发出冥王进攻玩家
ghd_ghost_war_support_used = "ghd_ghost_war_support_used"    --使用冥界入侵求援
ghd_star_soul_preview_state = "ghd_star_soul_preview_state"    --显示星魂上一阶段的状态 主要用于最后一个星魂的动画播放
ghd_refresh_country_shop = "ghd_refresh_country_shop"    -- 国家商店界面刷新
ghd_refresh_country_treasure = "ghd_refresh_country_treasure"    -- 国家宝藏界面刷新
