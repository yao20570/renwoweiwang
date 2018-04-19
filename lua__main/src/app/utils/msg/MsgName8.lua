--
-- Author: tanqian
-- Date: 2017-10-20 12:48:25
--消息名称的类

-- 第一类消息名称，必须带gud_开头(意思为updatedata)，
-- 用来标识数据发生变化了，界面可以刷新了，不携带任何操作行为
-- 目的为了可以执行分帧刷新处理




-- 第二类消息名称，必须带ghd_开头(handle)，
-- 用来通知操作行为的，例如打开对话框，飘字等操作行为
-- 目的为了立马刷新界面

ghd_refresh_homebase_xlb_tips = "ghd_refresh_homebase_xlb_tips"