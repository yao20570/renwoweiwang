----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-01-16 16:01:05 
-- Description: 消息名称的类
-----------------------------------------------------
-- 第一类消息名称，必须带gud_开头(意思为updatedata)，
-- 用来标识数据发生变化了，界面可以刷新了，不携带任何操作行为
-- 目的为了可以执行分帧刷新处理

--小地图区域更新
gud_world_block_dots_msg = "gud_world_block_dots_msg"

--大地图主城位置更改(被击飞，迁城)
gud_world_my_city_pos_change_msg = "gud_world_my_city_pos_change_msg"

--服务器推送线路更新3005
gud_world_task_move_push_msg = "gud_world_task_move_push_msg"

--视图点消失
gud_world_dot_disappear_msg = "gud_world_dot_disappear_msg"

--视图点更新
gud_world_dot_change_msg = "gud_world_dot_change_msg"

--任务变更推送
gud_world_task_change_msg = "gud_world_task_change_msg"

--搜索周围视图点
gud_world_search_around_msg = "gud_world_search_around_msg"

--区域城池内战
--blockId
gud_block_city_war_change_push_msg = "gud_block_city_war_change_push_msg"

--区域城池占领变化推送
--blockId
gud_block_city_occupy_change_push_msg = "gud_block_city_occupy_change_push_msg"

--出征面板选中发生变化
gud_dlg_battle_hero_selected_msg = "gud_dlg_battle_hero_selected_msg"

--我国国战列表发生变化
gud_my_country_war_list_change = "gud_my_country_war_list_change"

--季节日推送
gud_world_season_day_change = "gud_world_season_day_change"

--被打推送
gud_world_my_city_be_attack_msg = "gud_world_my_city_be_attack_msg"

--中心城占领信息列表发生变化
gud_world_center_city_capture_msg = "gud_world_center_city_capture_msg"


--邮件请求加载
gud_mail_load_req_msg = "gud_mail_load_req_msg"

--邮件发生变化(请求加载，已读，已取，已删。。。)
gud_mail_change_msg = "gud_mail_change_msg"

--邮件获取国战战斗列表
gud_mail_country_war_battle_req_msg = "gud_mail_country_war_battle_req_msg"

--邮件保存成功
gud_mail_save_success_msg = "gud_mail_save_success_msg"

--邮件撤销保存成功
gud_mail_save_cancel_success_msg = "gud_mail_save_cancel_success_msg"

--邮件获取请求成功
gud_mail_get_succeess_msg = "gud_mail_get_succeess_msg"

--邮件未读数请求
gud_mail_not_read_nums_msg = "gud_mail_not_read_nums_msg"

--打造装备发生变化
gud_equip_makevo_change_msg = "gud_equip_makevo_change_msg"

--雇用铁匠成功
gud_equip_smith_hire_msg = "gud_equip_smith_hire_msg"

--装备恢复免费洗炼次数
gud_equip_refine_cd_msg = "gud_equip_refine_cd_msg"

--装备洗炼成功
gud_equip_refine_success_msg = "gud_equip_refine_success_msg"

--装备洗炼失败
gud_equip_refine_Fail_msg = "gud_equip_refine_Fail_msg"

--关闭装备背包
gud_close_dlg_equip_bag = "gud_close_dlg_equip_bag"

--武将装备发生改变
gud_equip_hero_equip_change = "gud_equip_hero_equip_change"

--打造装备状态时刻刷新
gud_equip_makevo_refresh_msg = "gud_equip_makevo_refresh_msg"

--战力提升途径界面排行榜发生改变
gud_fc_promote_my_rank_info = "gud_fc_promote_my_rank_info"

--商品数据更新
gud_shop_data_update_msg = "gud_shop_data_update_msg"

--珍宝阁数据更新
gud_treasure_shop_update_msg = "gud_treasure_shop_update_msg"


--buff更新消夏
gud_buff_update_msg = "gud_buff_update_msg"

--vip礼包购买记录更新
gud_vip_gift_bought_update_msg = "gud_vip_gift_bought_update_msg"


--我的世界目标发生变化
gud_my_world_target_refresh = "gud_my_world_target_refresh"

--我的世界目标杀敌数量发生变化
gud_world_target_wild_amry_kill_refresh = "gud_world_target_wild_amry_kill_refresh"

--世界目标最高发生变化
gud_world_target_top_refresh = "gud_world_target_top_refresh"

--世界目标Boss发生变化
gud_world_target_boss_refresh = "gud_world_target_boss_refresh"

--世界目标都城占领发生变化
gud_world_target_capital_refresh = "gud_world_target_capital_refresh"

--世界召唤更新
gud_world_my_callinfo_refresh = "gud_world_my_callinfo_refresh"

--我的城池列表发生更新
gud_my_city_war_list_change = "gud_my_city_war_list_change"

--友军驻防列表发生更新
gud_friend_army_list_change = "gud_friend_army_list_change"

--重连成功
gud_reconnect_success = "gud_reconnect_success"

--别人城池驻守界面数据需要再次请求
gud_city_garrisonInfo_req = "gud_city_garrisonInfo_req"


--播放战斗动画
gud_play_wild_army_fight = "gud_play_wild_army_fight"

--名将推荐cd时间
--int 时间
gud_hero_recommond_cd = "gud_hero_recommond_cd"

--触发列表刷新
gud_trigger_gift_list_refresh = "gud_trigger_gift_list_refresh"

--城池首杀刷新
gud_city_first_blood_refresh = "gud_city_first_blood_refresh"

--城池首杀红点
gud_city_first_blood_red = "gud_city_first_blood_red"

--被打提示层高度发生改变
gud_be_attack_notices_height_refresh = "gud_be_attack_notices_height_refresh"

--统帅府位置解锁
gud_tcf_hero_pos_unlock_push = "gud_tcf_hero_pos_unlock_push"

--统帅府自动耐力
gud_tcf_auto_add_naili = "gud_tcf_auto_add_naili"

--限时Boss数据刷新
gud_tlboss_data_refresh = "gud_tlboss_data_refresh"

--限时Boss世界位置数据刷新
gud_tlboss_world_pos_refersh = "gud_tlboss_world_pos_refersh"

--我的积分刷新
gud_imperialwar_score_refresh = "gud_imperialwar_score_refresh"

--详情发生变化
gud_imperialwar_vo_refresh = "gud_imperialwar_vo_refresh"

--国家数据发生刷新
gud_countrycity_data_refresh = "gud_countrycity_data_refresh"
----------------------------------------------------------------------------------------
-- 第二类消息名称，必须带ghd_开头(handle)，
-- 用来通知操作行为的，例如打开对话框，飘字等操作行为
-- 目的为了立马刷新界面

--大地图视图坐标更新
--pMsgObj （table）: fViewCX,fViewCY,nDotX,nDotY
ghd_world_view_pos_msg = "ghd_world_view_pos_msg"

--显示大地图
--pMsgObj （number）: 1:主城,2：世界
ghd_home_show_base_or_world = "ghd_home_show_base_or_world"

--定位大地图位置
--pMsgObj （table）: fX,fY,isClick
ghd_world_location_mappos_msg = "ghd_world_location_mappos_msg"

--定位大地图位置
--pMsgObj （table）: nX,nY,isClick,tOther
ghd_world_location_dotpos_msg = "ghd_world_location_dotpos_msg"

-- --申请修选人城市
-- -- pMsgObj = {
-- -- 	nSystemCityId 
-- -- 	nCurrPage 	
-- -- 	nPageCount 	
-- -- 	nPageCountMax 
-- -- 	nItemCountMax 
-- -- 	tElectorList 
-- -- }
-- ghd_world_city_owner_candidate_msg = "ghd_world_city_owner_candidate_msg"

--定位大地图位置
--pMsgObj （table）: nX,nY,isClick
ghd_world_location_dotpos_gm_msg = "ghd_world_location_dotpos_gm_msg"

--遣返友军驻防成功
--pMsgObj （number）:sTid --任务id
ghd_world_city_garrison_call_msg = "ghd_world_city_garrison_call_msg"


--定位大地图我的主城位置
--pMsgObj （nil）
ghd_world_locaction_my_city_msg = "ghd_world_locaction_my_city_msg"

--珍宝阁翻牌成功
--pMsgObj （number）:翻牌 id
ghd_treasure_shop_flip_card_msg = "ghd_treasure_shop_flip_card_msg"


--商品商物成功
--pMsgObj （number）:商品 id
ghd_shop_buy_success_msg = "ghd_shop_buy_success_msg"


--发起国战请求
--pMsgObj （number）:系统城池id
ghd_world_country_war_req_msg = "ghd_world_country_war_req_msg"

--隐藏城市点击层
ghd_world_hide_city_click_msg = "ghd_world_hide_city_click_msg"

--皇宫等级变化
ghd_refresh_palace_lv_msg = "ghd_refresh_palace_lv_msg"

--城池点击特效
--pMsgObj (table) nDotX, nDotY 世界图点坐标
-- ghd_world_dot_clicked_effect = "ghd_world_dot_clicked_effect"

--视图点进击特效
ghd_world_dot_attack_effect = "ghd_world_dot_attack_effect"

--更新我的国家所属
ghd_refresh_playerinfo_country = "ghd_refresh_playerinfo_country"

--主动点击新手触发下一条
ghd_guide_clicked_finger = "ghd_guide_clicked_finger"

--关闭国家战争面板
ghd_dlg_country_war_close = "ghd_dlg_country_war_close"


--定位自己城池附近的某个视图点
--pMsgObj (table) {nDotType = xxx, nSysCityId = xxx }
-- e_type_builddot = {
-- 	null 		= 0, --空地点 （还没有支持）
-- 	city 		= 1, --玩家城池（还没有支持）
-- 	sysCity 	= 2, --系统城池（还没有支持）
-- 	res 		= 3, --资源田（还没有支持）
-- 	wildArmy 	= 4, --乱军（{nDotType = xxx, nDotLv = xxx }
-- }
ghd_world_dot_near_my_city = "ghd_world_dot_near_my_city"


--城战请求次数使用了
--pMsgObj （number）:城战id
ghd_world_city_war_support_used = "ghd_world_city_war_support_used"


--显示领取重建奖励
ghd_world_rebuild_reward_show = "ghd_world_rebuild_reward_show"

--强制隐藏新手教程全屏或并屏
ghd_guide_drama_or_tip_hide = "ghd_guide_drama_or_tip_hide"

--解锁一键征收
ghd_unlock_one_collect_all = "ghd_unlock_one_collect_all"

--进行登陆后逻辑
ghd_do_logined_logic = "ghd_do_logined_logic"

--新手手指重刷位置
ghd_guide_finger_pos_refresh = "ghd_guide_finger_pos_refresh"

--新手手指临时隐藏
ghd_guide_finger_img_hide = "ghd_guide_finger_img_hide"

--新手手指隐藏或显示
--pMsgObj (bool) true or false
ghd_guide_finger_show_or_hide = "ghd_guide_finger_show_or_hide"

--小地图循环
ghd_smallmap_search_around_msg = "ghd_smallmap_search_around_msg"

--显示或隐藏系统城池汽泡
--pMsgObj (table) {sysCityId = XXx, bIsShow = XXx} 显示或隐藏
ghd_show_or_hide_syscity_dot_ui = "ghd_show_or_hide_syscity_dot_ui"

--显示或显示玩家城池召唤
--pMsgObj (table) {cityId = XXx, bIsShow = XXx} 显示或隐藏
ghd_show_or_hide_city_dot_ui = "ghd_show_or_hide_city_dot_ui"

--发起城战请求
--pMsgObj (table) tViewDotMsg
ghd_send_city_war_req = "ghd_send_city_war_req"

--乱军底座特效
--pMsgObj( number) 乱军等级
ghd_wildarmy_circle_effect = "ghd_wildarmy_circle_effect"

--显示行军菜单
ghd_show_world_battle_menus = "ghd_show_world_battle_menus"

--显示行军详细
--pMsgObj (number) nTabIndex nil为隐藏
ghd_show_world_battle_detail = "ghd_show_world_battle_detail"

--多条列表请求
--pMsgObj(table) {xxx}
--我的城战，友军驻防
	-- self.tReqDataList = {"reqWorldCityWarInfo", "reqFriendArmys"}	
ghd_mulit_proto_list_req = "ghd_mulit_proto_list_req"

--城内建筑解锁状态
--pMsgObj (number) 解锁的id
ghd_build_group_unlock_msg = "ghd_build_group_unlock_msg"

--播放升级特效测试
ghd_build_show_lvup_txt_msg = "ghd_build_show_lvup_txt_msg"

--改名卡成功
ghd_rename_success_msg = "ghd_rename_success_msg"

--城池改名成功
ghd_syscity_rename_success_msg = "ghd_syscity_rename_success_msg"

--区域视图点刷新开关
--pMsgObj(true or false)
ghd_world_block_dots_msg_switch = "ghd_world_block_dots_msg_switch"

--一键征收
--pMsgObj(征收数据list)
ghd_refresh_suburb_state_mulit_msg = "ghd_refresh_suburb_state_mulit_msg"

--定位按钮特效显示或隐藏
--pMsgObj(true or false)
ghd_worldtop_lbtn_effect_show_or_hide = "ghd_worldtop_lbtn_effect_show_or_hide"

--已使用vip免费召回次数
ghd_world_vipfree_called_change = "ghd_world_vipfree_called_change"

--光效保护检测
ghd_city_protect_effect_test = "ghd_city_protect_effect_test"


--可击杀最高乱军等级发生改变
ghd_can_kill_wildarmy_lv_change = "ghd_can_kill_wildarmy_lv_change"

--世界Boss离开
--pMsgObj(位置key)
ghd_world_boss_leave = "ghd_world_boss_leave"
--纣王试炼厉害
ghd_world_kingzhou_leave = "ghd_world_kingzhou_leave"

--世界Boss战求援次数
ghd_world_boss_war_support_used = "ghd_world_boss_war_support_used"

--隐藏乱军战斗动画
--乱军坐标key(string x_y )
ghd_hide_wild_army_line = "ghd_hide_wild_army_line"

--显示乱军线路(string x_y )
ghd_show_wild_army_line = "ghd_show_wild_army_line"

--输入聊天表情
--string. 输入聊天表情符
ghd_input_chat_emo = "ghd_input_chat_emo"

--行军路线从后台返前台要进行刷新
ghd_world_war_line_req = "ghd_world_war_line_req"

--私聊发送按钮更改(bool bIsFree )
ghd_pchat_send_btn_change = "ghd_pchat_send_btn_change"

--发送消息显示或隐藏限时Boss排行榜
--pMsgObj(为nil就根据当前显示取反, bool true:显示，false:隐藏)
ghd_show_tlboss_small_rank = "ghd_show_tlboss_small_rank"

--发送消息显示警告
ghd_show_tlboss_warning = "ghd_show_tlboss_warning"

--发送限时Boss振屏
ghd_show_tlboss_shake = "ghd_show_tlboss_shake"

--发送限时Boss玩家名字和伤害
--table({sName = xxx, bIsBroke = true or false)
ghd_show_tlboss_atk_name = "ghd_show_tlboss_atk_name"

--nNum 伤害数字
--发送伤害数字，是否最强一击
--table({nNum = xxx, bIsBest = true or false)
ghd_show_tlboss_hurt_num = "ghd_show_tlboss_hurt_num"

--显示限时Boss手指
ghd_show_tlboss_finger = "ghd_show_tlboss_finger"

--置到前台
ghd_real_enter_foreground = "ghd_real_enter_foreground"

--行军线发生改变
ghd_tlboss_line_change = "ghd_tlboss_line_change"

--限时Boss攻击cd
ghd_tlboss_attack_cd = "ghd_tlboss_attack_cd"

--限时Boss强攻cd
ghd_tlboss_sattack_cd = "ghd_tlboss_sattack_cd"

--战况推送 tReplay
ghd_imperialwar_fight_refresh = "ghd_imperialwar_fight_refresh"

--开启状态更新
ghd_imperialwar_open_state = "ghd_imperialwar_open_state"

--强制隐藏世界Boss
ghd_hide_world_tlboss = "ghd_hide_world_tlboss"

--发生战斗
ghd_imperialwar_show_fight = "ghd_imperialwar_show_fight"

--解锁教程 低部按钮移到中间
--nType 按钮类型
ghd_homebottom_menu_center = "ghd_homebottom_menu_center"

--关入口
ghd_close_epw_enter_item = "ghd_close_epw_enter_item"

--更新皇城战可领取状态
ghd_refresh_epw_award_state = "ghd_refresh_epw_award_state"