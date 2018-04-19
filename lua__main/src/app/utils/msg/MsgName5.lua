----------------------------------------------------- 
-- author: liangzhaowei
-- updatetime: 2017-01-16 16:01:05 
-- Description: 消息名称的类
-----------------------------------------------------
-- 第一类消息名称，必须带gud_开头(意思为updatedata)，
-- 用来标识数据发生变化了，界面可以刷新了，不携带任何操作行为
-- 目的为了可以执行分帧刷新处理

--副本信息刷新消息
--pMsgObj （table）: 未使用
gud_refresh_fuben = "gud_refresh_fuben"

--城墙信息刷新消息
--pMsgObj （table）: 未使用
gud_refresh_wall = "gud_refresh_wall"

--通知副本显示路线消息
--pMsgObj （table）: 未使用
gud_show_fuben_line = "gud_show_fuben_line"

--通知英雄界面刷新
--pMsgObj （table）: 未使用
gud_refresh_hero = "gud_refresh_hero"


--通知登录界面刷新
--pMsgObj （table）: 未使用
gud_refresh_login = "gud_refresh_login"

--通知聊天界面刷新
--pMsgObj （table）: nType(聊天类型)
ghd_refresh_chat = "ghd_refresh_chat" -- 立刻更新
gud_refresh_chat = "gud_refresh_chat" -- 延迟更新

--刷新聊天隐藏的聊天条数 nCount 聊天条数
gud_refresh_hide_chat_num = "gud_refresh_hide_chat_num"

--通知刷新活动数据
gud_refresh_activity = "gud_refresh_activity"

--通知英雄更换英雄  pHero(英雄数据)
gud_replace_hero = "gud_replace_hero"

--通知刷新对联红点
--pMsgObj （table）:  nType(对联类型) nRedType(红点类型) nRedNums(红点个数)
gud_refresh_homelr_red = "gud_refresh_homelr_red"

--通知拜将台数据刷新
--pMsgObj （table）: 未使用
gud_refresh_buy_hero = "gud_refresh_buy_hero"

--通知刷新活动红点
gud_refresh_act_red = "gud_refresh_act_red"

--pMsgObj （table）:  nType(聊天类型)  nReds(红点个数)
--通知刷新聊天红点
gud_refresh_chat_red = "gud_refresh_chat_red"

--通知刷新私聊的聊天红点
gud_refresh_sl_chat_red = "gud_refresh_sl_chat_red"

--通知刷新活动模板a
gud_refresh_actlist = "gud_refresh_actlist"

----------------------------------------------------------------------------------------
-- 第二类消息名称，必须带ghd_开头(handle)，
-- 用来通知操作行为的，例如打开对话框，飘字等操作行为
-- 目的为了立马刷新界面

-- 根据对话框类型跳转到
--pMsgObj （table）: nType（int）   ==>dialog类型
--                   nIndex（int）  ==>分页1数
ghd_show_dlg_by_type  = "ghd_show_dlg_by_type"

-- 执行招募城墙守卫
--pMsgObj （table）: 未使用
ghd_recruit_wall_wall = "ghd_recruit_wall_wall"

--更换私人聊天对象
ghd_change_private_chat_player = "ghd_change_private_chat_player"