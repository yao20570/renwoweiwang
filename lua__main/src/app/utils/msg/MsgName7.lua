----------------------------------------------------- 
-- author: 
-- updatetime: 2017-01-16 16:01:05 
-- Description: 消息名称的类
-----------------------------------------------------
-- 第一类消息名称，必须带gud_开头(意思为updatedata)，
-- 用来标识数据发生变化了，界面可以刷新了，不携带任何操作行为
-- 目的为了可以执行分帧刷新处理
gud_refresh_notice = "gud_refresh_notice"


gud_refresh_weaponInfo = "gud_refresh_weaponInfo"

gud_show_weapon_extracritical = "gud_show_weapon_extracritical"

gud_refresh_merchants = "gud_refresh_merchants"

gud_refresh_dayloginawards = "gud_refresh_dayloginawards"

--是否显示副本关卡界面的右边特效消息
gud_refresh_fuben_arrowtx = "gud_refresh_fuben_arrowtx"

--可以触发引导免费加速点击后
gud_finish_speed_btn_click = "gud_finish_speed_btn_click"

--活动加速后刷新冒泡消息
gud_refresh_build_bubble = "gud_refresh_build_bubble"

--资源田征收后数据变化的消息
gud_refresh_suburb_data = "gud_refresh_suburb_data"

--新版成长基金限购时间结束刷新消息
gud_refresh_growthfound = "gud_refresh_growthfound"

--装备请求强化成功消息
gud_equip_strength_msg = "gud_equip_strength_msg"

--过关斩将数据刷新消息
gud_refresh_pass_kill_hero_msg = "gud_refresh_pass_kill_hero_msg"

--过关斩将武将上下阵刷新消息
gud_refresh_pass_kill_online_hero_msg = "gud_refresh_pass_kill_online_hero_msg"

--资源打包刷新
gud_refresh_res_pack = "gud_refresh_res_pack"

--通知刷新主城郊外资源建筑有图纸掉落
gud_refresh_suburb_draws = "gud_refresh_suburb_draws"

--国家科技刷新消息
gud_refresh_country_tnoly = "gud_refresh_country_tnoly"

----------------------------------------------------------------------------------------
-- 第二类消息名称，必须带ghd_开头(handle)，
-- 用来通知操作行为的，例如打开对话框，飘字等操作行为
-- 目的为了立马刷新界面

-- 根据对话框类型跳转到
--pMsgObj （table）: nType（int）   ==>dialog类型
--                   nIndex（int）  ==>分页1数
-- ghd_show_dlg_by_type  = "ghd_show_dlg_by_type"

ghd_treasure_shop_flip_card_cdchange_msg = "ghd_treasure_shop_flip_card_cdchange_msg"

ghd_equip_refine_times_change = "ghd_equip_refine_times_change"

ghd_gate_cdchange_msg = "ghd_gate_cdchange_msg"

--神兵升级消息
ghd_weapon_upgrade_effect = "ghd_weapon_upgrade_effect"
--神兵暴击消息
ghd_weapon_baoji_effect = "ghd_weapon_baoji_effect"
--神兵进阶消息
ghd_weapon_advance_effect = "ghd_weapon_advance_effect"

--界面跳转消息
ghd_jumpto_dlg_msg = "ghd_jumpto_dlg_msg"

--通知主界面底部列表刷新位置消息
ghd_refresh_home_bottom_msg = "ghd_refresh_home_bottom_msg"

--募兵消耗粮草消息
ghd_refresh_camp_recruit = "ghd_refresh_camp_recruit"

--募兵府募兵消耗消息
ghd_refresh_house_recruit = "ghd_refresh_house_recruit"

--副本资源特殊关卡时间到的时候通知界面刷新
ghd_refresh_special_level = "ghd_refresh_special_level"

--通知副本关卡界面刷新
ghd_refresh_fuben_level = "ghd_refresh_fuben_level"

--注册撤回消息刷新
ghd_refresh_recall_chat = "ghd_refresh_recall_chat"

--副本新关卡开启消息
ghd_show_fuben_openpost_tx = "ghd_show_fuben_openpost_tx"

--去掉活动加速冒泡的消息
ghd_update_speed_bubble = "ghd_update_speed_bubble"

--总览菜单显示与隐藏消息
ghd_showorhide_overview_menu = "ghd_showorhide_overview_menu"
--总览文字冒泡提示消息
ghd_show_overview_tip = "ghd_show_overview_tip"

--世界战斗结束消息
ghd_battle_result = "ghd_battle_result"

ghd_refresh_battle_tip = "ghd_refresh_battle_tip"

--神兵自动升级消息
ghd_weapon_auto_upgrade_tip = "ghd_weapon_auto_upgrade_tip"

--主城拖动的消息
ghd_base_moving = "ghd_base_moving"

--装备强化结果消息
ghd_equip_strength_result_msg = "ghd_equip_strength_result_msg"

--装备打造完成消息
ghd_equip_make_finish_msg = "ghd_equip_make_finish_msg"
