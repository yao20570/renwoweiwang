----------------------------------------------------- 
-- author: wangxiaoshuo
-- updatetime: 2017-01-16 16:01:05 
-- Description: 消息名称的类
-----------------------------------------------------
-- 第一类消息名称，必须带gud_开头(意思为updatedata)，
-- 用来标识数据发生变化了，界面可以刷新了，不携带任何操作行为
-- 目的为了可以执行分帧刷新处理

--玩家基础信息刷新消息
--pMsgObj （table）: 未使用
gud_refresh_playerinfo = "gud_refresh_playerinfo"

--建筑状态变化消息
--pMsgObj （table）: nCell（int）     ==>建筑格子下标
gud_build_state_change_msg = "ghd_build_state_change_msg"

--建筑数据发生变化消息
--pMsgObj （table）: nType（int）    ==>1：表示购买队列时间变化
gud_build_data_refresh_msg = "gud_build_data_refresh_msg"

--科技列表发生变化的消息
--pMsgObj （table）: 未使用
gud_refresh_tnoly_lists_msg = "gud_refresh_tnoly_lists_msg"

----------------------------------------------------------------------------------------
-- 第二类消息名称，必须带ghd_开头(handle)，
-- 用来通知操作行为的，例如打开对话框，飘字等操作行为
-- 目的为了立马刷新界面

--socket连接回调消息
--pMsgObj （table）: nType（int）  ==> 1世界 2 城内建筑 3 资源田
-- 					 bEnd （boolean） ==> 是否结束
ghd_update_login_slider_value = "ghd_update_login_slider_value"

--socket连接回调消息
--pMsgObj （table）: nType（int）  ==> 连接状态类型
ghd_socket_connection_event = "ghd_socket_connection_event"

--后台切换到前台刷新消息
--pMsgObj （table）: 未使用
ghd_backtoforeground_msg = "ghd_backtoforeground_msg"

--重连成功消息
--pMsgObj （table）: 未使用
ghd_msg_reconnect_success = "ghd_msg_reconnect_success"

--关闭对话框消息
--pMsgObj （table）: eDlgType（int）   ==>对话框类型
ghd_msg_close_dlg_by_type = "ghd_msg_close_dlg_by_type"

--开启世界或者基地的背景音乐
--pMsgObj （table）: 未使用
ghd_open_worldorbase_music_msg = "ghd_open_worldorbase_music_msg"

--打开基地云
--pMsgObj （table）: 未使用
ghd_open_yu_onhome_msg = "ghd_open_yu_onhome_msg"

--关闭悬浮框消息
--pMsgObj （table）: 未使用
ghd_close_flow_dlg_msg = "ghd_close_flow_dlg_msg"

--玩家能量刷新消息
--pMsgObj （table）: 未使用
ghd_refresh_energy_msg = "ghd_refresh_energy_msg"

--玩家等级刷新消息
--pMsgObj （table）: 未使用
ghd_refresh_playerlv_msg = "ghd_refresh_playerlv_msg"

--升级建筑消息
--pMsgObj （table）: nType（int）        ==>-2：普通升级立即完成 -1：普通升级 1：免费加速 2：道具加速 3：金币完成 4：购买并使用
-- 					 nBuildId（int）     ==>建筑id
-- 					 nCell（int） 		 ==>建筑格子下标
ghd_up_build_msg = "ghd_up_build_msg"

--建筑更多操作消息
--pMsgObj （table）: nType（int）        ==>1.拆除 2.重建
-- 					 nBuildId（int）     ==>建筑id
-- 					 nCell（int） 		 ==>建筑格子下标
ghd_more_action_build_msg = "ghd_more_action_build_msg"

--移除一个建筑buildgroup
--pMsgObj （table）: nCell（int）        ==>建筑下标
ghd_remove_one_buildgroup_msg = "ghd_remove_one_buildgroup_msg"

--升级建筑基地缩放消息
--pMsgObj （table）: nCell（int）        ==>建筑格子下标
--pMsgObj （table）: nType（int）        ==>1；放大 2：缩小
ghd_scale_for_buildup_dlg_msg = "ghd_scale_for_buildup_dlg_msg"

--移动到基地的消息
--pMsgObj （table）: nCell（int）        ==>建筑格子下标
ghd_move_to_build_dlg_msg = "ghd_move_to_build_dlg_msg"

--移动到基地的位置
ghd_move_to_base_pos_msg = "ghd_move_to_base_pos_msg"

--关闭建筑升级对话框消息
--pMsgObj （table）: nCell（int）        ==>建筑格子下标
ghd_close_buildup_dlg_msg = "ghd_close_buildup_dlg_msg"

--打开基地建筑操作按钮消息
--pMsgObj （table）: nCell（int）        ==>建筑格子下标
--                 : bHadChecked(boolean)==>是否已经验证了所有状态
ghd_show_build_actionbtn_msg = "ghd_show_build_actionbtn_msg"

--关闭基地建筑操作按钮消息
--pMsgObj （table）: 未使用
ghd_close_build_actionbtn_msg = "ghd_close_build_actionbtn_msg"

--建筑解锁消息
--pMsgObj （table）: nCell（int）        ==>建筑格子下标
ghd_unlock_build_msg = "ghd_unlock_build_msg"

--展示建筑解锁特效消息
--pMsgObj （table）: tData（table）      ==>建筑列表
ghd_show_tx_unlock_build_msg = "ghd_show_tx_unlock_build_msg"

--后台解锁建筑消息
--pMsgObj （table）: tData（table）      ==>建筑列表
ghd_show_unlock_build_background_msg = "ghd_show_unlock_build_background_msg"

--建筑升级完成(展示特效)消息
--pMsgObj （table）: nCell（int）        ==>建筑格子下标
ghd_show_buildup_tx_msg = "ghd_show_buildup_tx_msg"

--资源田状态刷新消息
--pMsgObj （table）: 未使用
ghd_refresh_suburb_state_msg = "ghd_refresh_suburb_state_msg"

--刷新左右对联消息
--pMsgObj （table）: nType（int）        ==>1：右边 2：左边
ghd_refresh_homeitem_msg = "ghd_refresh_homeitem_msg"

--全屏对话框展示与关闭消息
--pMsgObj （table）: nType（int）        ==>1：展示 2：关闭
ghd_state_for_filldlg_msg = "ghd_state_for_filldlg_msg"

--兵营士兵招募队列刷新消息
--pMsgObj （table）: nBuildId（int）     ==>建筑id
ghd_refresh_camp_recruit_msg = "ghd_refresh_camp_recruit_msg"

--募兵操作消息
--pMsgObj （table）: nBuildId（int）     ==>建筑id
-- 					 nType（int）        ==>1：加速道具加速 2:购买并使用加速道具 3：金币完成 4：取消生产5:招募完成领取士兵 6:刷新队列
-- 					 sId（string）       ==>队列id
-- 					 item（int）         ==>物品id
ghd_recruit_action_msg = "ghd_recruit_action_msg"

--兵营调整消息
--pMsgObj （table）: nBuildId（int）     ==>建筑id
-- 					 nType（int）        ==>1:扩建 2：募兵加时
ghd_update_camp_msg = "ghd_update_camp_msg"

--研究科技消息
--pMsgObj （table）: nId（int）          ==>科技id
ghd_uping_tnoly_msg = "ghd_uping_tnoly_msg"

--科技操作消息
--pMsgObj （table）: nType（int）        ==>1.研究员免费加速 2.元宝加速3.完成科技4.免费加速检查5.使用加速道具6.购买并使用加速道具
ghd_action_tnoly_msg = "ghd_action_tnoly_msg"

--战斗------------>飘字特效消息
--pMsgObj （table）: nDirection（int）   ==>1：下方 2：上方  
--                   nType（int）        ==>表示飘字的类型
ghd_fight_show_msg = "ghd_fight_show_msg"

--战斗------------>到达混战区消息
--pMsgObj （table）: nDirection（int）   ==>1：下方 2：上方  
--                   nIndex（int）       ==>teamlayer下标，对应着双方武将对阵的位置
ghd_fight_arrived_fzone = "ghd_fight_arrived_fzone"

--战斗------------>可以播放下一条战斗指令消息
--pMsgObj （table）: nDirection（int）   ==>1：下方 2：上方  
--                   nCurOrderIndex（int）       ==>当前指令的下标
ghd_fight_play_next_order = "ghd_fight_play_next_order"

--战斗------------>士兵动作表现
--pMsgObj （table）: nAcionType（int）   ==>1：射箭  
--                   tPos（cc.p）        ==>当前士兵相对于rootlayer的位置
-- 					 nDir（int）         ==>1：下方 2：上方
-- 					 nPos（int） 		 ==>当前士兵的占位位置（1~9）
--                   sActionKey（string）==>特效key值
ghd_fight_play_soldier_action = "ghd_fight_play_soldier_action"

--战斗------------>战斗界面血量表现
--pMsgObj （table）: nDir（int）         ==>1：下方 2：上方  
-- 					 nCur（int） 		 ==>当前血量
--                   nAll（int）         ==>总血量
-- 					 bDeadth（boolean）  ==>是否死亡
ghd_fight_show_blood_onmain = "ghd_fight_show_blood_onmain"

--战斗------------>战斗界面血量表现(整块)
--pMsgObj （table）: nDir（int）         ==>1：下方 2：上方  
-- 					 nCur（int） 		 ==>当前掉血量
--                   nAll（int）         ==>总血量
ghd_fight_show_blood_onmain_block = "ghd_fight_show_blood_onmain_block"

--战斗------------>战斗即将结束（武将播放攻击动作完成）
--pMsgObj （table）: 未使用
ghd_fight_play_hero_attack_end = "ghd_fight_play_hero_attack_end"

--战斗------------>战斗结束
--pMsgObj （table）: 未使用
ghd_fight_play_end = "ghd_fight_play_end"

--战斗------------>关闭战斗界面
--pMsgObj （table）: 未使用
ghd_fight_close = "ghd_fight_close"

--第二版战斗------>进入混战区展示顶部信息层
--pMsgObj （table）: 队伍相关数据（第几个武将，类型，武将内第几队，上下方向等等==）
ghd_fight_sec_show_msg_state = "ghd_fight_sec_show_msg_state"

--第二版战斗------>掉血消息
--pMsgObj （table）: nDir（int）        ==>1：下方 2：上方 
-- 					 nDropBlood         ==>掉血血量
ghd_fight_sec_blood_msg = "ghd_fight_sec_blood_msg"

--第二版战斗------>刷新武将所属主公
--pMsgObj （table）:nDir（int）        ==>1：下方 2：上方 
--					sWho			   ==>主公名字
ghd_fight_sec_king_msg = "ghd_fight_sec_king_msg"

--拜将台进入推演
--pMsgObj （table）:未使用
ghd_buy_hero_update_msg = "ghd_buy_hero_update_msg"

--进阶红点状态刷新
--pMsgObj （table）:未使用
ghd_advance_hero_rednum_update_msg = "ghd_advance_hero_rednum_update_msg"

--竞技场挑战之后更新竞技场视图
ghd_arena_viewdata_refresh_msg = "ghd_arena_viewdata_refresh_msg"

--竞技场挑战之后更新竞技场视图
ghd_pass_report_update = "ghd_pass_report_update"

--过关斩将动画重置
ghd_req_Reset_Fight = "ghd_req_Reset_Fight"

--刷新藏宝信息
ghd_national_treasure_update = "ghd_national_treasure_update"

--武将进阶返回
--pMsgObj （table）
ghd_hero_advance_success_msg = "ghd_hero_advance_success_msg"

--国家互助刷新
gud_refresh_countryhelp = "gud_refresh_countryhelp"

--王者宝藏刷新
gud_refresh_nationaltreasure = "gud_refresh_nationaltreasure"