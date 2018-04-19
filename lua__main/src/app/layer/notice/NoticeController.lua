-- NoticeController.lua
-----------------------------------------------------
-- Author: dshulan
-- Date: 2017-06-6 09:41:41
-- Description: 公告数据操作类
-----------------------------------------------------

local NoticeData = require("app.layer.notice.NoticeData")


--请求公告数据回调
SocketManager:registerDataCallBack("loadNoticeData",function ( __type, __msg )
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			Player:getNoticeData():onLoadNotice(__msg.body)
			sendMsg(gud_refresh_notice) --通知刷新界面
		end
	end
end)

--请求阅读公告回调
SocketManager:registerDataCallBack("reqReadNoticeData",function ( __type, __msg, __oldMsg )
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.reqReadNoticeData.id then
			local nNoticeId = __oldMsg[1]
			local nNoticeVer = __oldMsg[2]
			Player:getNoticeData():onNoticeRead(nNoticeId, nNoticeVer)
			sendMsg(gud_refresh_notice) --通知刷新界面
			local tObject = {} 
			tObject.nType = e_index_itemrl.r_gg--对联类型
			tObject.nRedType = 0--红点类型
			tObject.nRedNums = Player:getNoticeData():getNoticeRedNums() --红点个数
			sendMsg(gud_refresh_homelr_red,tObject) --刷新公告上面的红点
			
		end
	end
end)

--获得公告数据单例
function Player:getNoticeData()
	-- body
	if not Player.pNoticeData then
		self:initNoticeData()
	end
	return Player.pNoticeData
end

-- 初始化公告数据
function Player:initNoticeData(  )
	if not Player.pNoticeData then
		Player.pNoticeData = NoticeData.new()
	end
	return "Player.pNoticeData"
end

--释放公告数据
function Player:releaseNoticeData(  )
	if Player.pNoticeData then
		Player.pNoticeData = nil
	end
	return "Player.pNoticeData"
end
