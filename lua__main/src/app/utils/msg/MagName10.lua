--
-- Author: wenzongyao
-- Date: 2018-1-17 14:04:25
--消息名称的类

-- 第一类消息名称，必须带gud_开头(意思为updatedata)，
-- 用来标识数据发生变化了，界面可以刷新了，不携带任何操作行为
-- 目的为了可以执行分帧刷新处理

-- 抢答信息刷新
gud_exam_info_refresh_msg = "gud_exam_info_refresh_msg"

-- 答题活动结束
gud_exam_activity_end_msg = "gud_exam_activity_end_msg"

-- 答题玩家列表刷新
gud_exam_ansewer_players_msg = "gud_exam_ansewer_players_msg"

-- 战争大厅->列表刷新
gud_war_hall_refresh = "ghd_war_hall_refresh"


-- 第二类消息名称，必须带ghd_开头(handle)，
-- 用来通知操作行为的，例如打开对话框，飘字等操作行为
-- 目的为了立马刷新界面
