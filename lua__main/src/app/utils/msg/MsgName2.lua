----------------------------------------------------- 
-- author: xieruidong
-- updatetime: 2017-01-16 16:01:05 
-- Description: 消息名称的类
-----------------------------------------------------
-- 第一类消息名称，必须带gud_开头(意思为updatedata)，
-- 用来标识数据发生变化了，界面可以刷新了，不携带任何操作行为
-- 目的为了可以执行分帧刷新处理
gud_testChangeData = "gud_testChangeData"
-- SDK登录成功
gud_sdkloginsucceed = "gud_sdkloginsucceed"



----------------------------------------------------------------------------------------
-- 第二类消息名称，必须带ghd_开头(handle)，
-- 用来通知操作行为的，例如打开对话框，飘字等操作行为
-- 目的为了立马刷新界面
ghd_testOpendialog = "ghd_testOpendialog"