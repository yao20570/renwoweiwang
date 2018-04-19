----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-18 11:18:23
-- Description: 邮件控制类
-----------------------------------------------------
local MailData = require("app.layer.mail.data.MailData")


--获取邮件数据单例
function Player:getMailData(  )
	if not Player.mailData then
		self:initMailData()
	end
	return Player.mailData
end

--初始化邮件数据
function Player:initMailData(  )
	if not Player.mailData then
		Player.mailData = MailData.new()
	end
	return "Player.mailData"
end

--释放邮件数据
function Player:releaseMailData()
	if Player.mailData then
		Player.mailData:release()
		Player.mailData = nil
	end
	return "Player.mailData"
end

--[3051]加载邮件
SocketManager:registerDataCallBack("reqMailLoad",function ( __type, __msg, __oldMsg)
	-- dump(__msg.body,"reqMailLoad=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqMailLoad.id then
			if __msg.body then
				if not __oldMsg then
					Player:getMailData():clearAllMailReqed()
					return
				end
				local nCategory = __oldMsg[1]
				local nLoadedNum = __oldMsg[2]
				Player:getMailData():onLoadMail(__msg.body, nCategory, nLoadedNum)
				sendMsg(gud_mail_change_msg)
				sendMsg(gud_mail_load_req_msg)
			end
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[3052]将邮件设置为已读状态
SocketManager:registerDataCallBack("reqMailReaded",function ( __type, __msg, __oldMsg)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqMailReaded.id then
			if not __oldMsg then
				Player:getMailData():clearAllMailReqed()
				return
			end
			local nCategory = __oldMsg[1]
			local nMailPid = __oldMsg[2]

			Player:getMailData():onMailReaded(nCategory, nMailPid)
			sendMsg(gud_mail_change_msg)
			sendMsg(gud_mail_not_read_nums_msg)
			sendMsg(ghd_item_home_menu_red_msg)
			if not nMailPid then
				TOAST(getTipsByIndex(536))
			end
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[3053]删除邮件
SocketManager:registerDataCallBack("reqMailDel",function ( __type, __msg, __oldMsg)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqMailDel.id then
			if not __oldMsg then
				Player:getMailData():clearAllMailReqed()
				return
			end
			local nCategory = __oldMsg[1]
			local nMailPid = __oldMsg[2]
			Player:getMailData():setNotReadNum(nCategory, __msg.body.nrn)
			Player:getMailData():onMailDel(nCategory, nMailPid)
			sendMsg(gud_mail_change_msg)
			sendMsg(gud_mail_not_read_nums_msg)
			sendMsg(ghd_item_home_menu_red_msg)
			TOAST(getTipsByIndex(606))
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[3054]推送新邮件
SocketManager:registerDataCallBack("pushMailNew",function ( __type, __msg)
	-- dump(__msg.body,"pushMailNew=",100)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.pushMailNew.id then
			if __msg.body then
				Player:getMailData():onPushMailNew(__msg.body)
				Player:getMailData():setNotReadNums(__msg.body.ns)

				--更改的邮件类别
				local tCategory = {}
				local tData = __msg.body.m
				for i=1, #tData do
					local nCategory = tData[i].c
					table.insert(tCategory, nCategory)
				end
				sendMsg(gud_mail_change_msg, tCategory)
				sendMsg(gud_mail_not_read_nums_msg)
				sendMsg(ghd_item_home_menu_red_msg)
				local sMailId = Player:getMailData():getDetectMailId()
				if sMailId then
					local tMailMsg = Player:getMailData():getMailMsg(sMailId)
	        		if tMailMsg then
	        			--直接弹出界面
	        			local tObject = {
						    nType = e_dlg_index.maildetail, --dlg类型
						    tMailMsg = tMailMsg,
						}
						sendMsg(ghd_show_dlg_by_type, tObject)
						Player:getMailData():setDetectMailId(nil)
					end
				end
			end
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[3055]保存邮件
SocketManager:registerDataCallBack("reqMailSave",function ( __type, __msg, __oldMsg)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqMailSave.id then
			if not __oldMsg then
				Player:getMailData():clearAllMailReqed()
				return
			end
			local nCategory = __oldMsg[1]
			local nMailPid = __oldMsg[2]
			Player:getMailData():onMailSave(nCategory, nMailPid)
			sendMsg(gud_mail_change_msg)
			sendMsg(gud_mail_save_success_msg)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[3056]获取邮件物品
SocketManager:registerDataCallBack("reqMailGet",function ( __type, __msg, __oldMsg)
	
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqMailGet.id then
			if not __oldMsg then
				Player:getMailData():clearAllMailReqed()
				return
			end
			local nCategory = __oldMsg[1]
			local nMailPid = __oldMsg[2]
			Player:getMailData():setNotReadNum(nCategory, __msg.body.nrn)
			if __msg.body.ids then    --一键领取
				Player:getMailData():onMailServeralGet(nCategory, __msg.body.ids)
			else
				Player:getMailData():onMailGet(nCategory, nMailPid)
			end
			sendMsg(gud_mail_change_msg)
			sendMsg(gud_mail_not_read_nums_msg)
			sendMsg(gud_mail_get_succeess_msg)
			sendMsg(ghd_item_home_menu_red_msg)
			--播放获取特效
			showGetAllItems(__msg.body.ob, 1)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[3057]加载战斗回放
SocketManager:registerDataCallBack("reqMailFightReplay",function ( __type, __msg, __oldMsg)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqMailFightReplay.id then
			if __msg.body then
				showFight(__msg.body.rf, function (  )
					--关闭战斗界面
					if Player:getUIFightLayer() then
			 			sendMsg(ghd_fight_close)
			 			showNextSequenceFunc(e_show_seq.fight)

			  		end
		
					-- local tData = {}
					-- tData.report = __msg.body.rf
					-- tData.mailPlayBack = true

					-- showFightRst(tData)

        		end, true)
			end
		end
	end
end)

--[3057]加载战斗回放
SocketManager:registerDataCallBack("reqMailBattle",function ( __type, __msg, __oldMsg)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqMailBattle.id then
			if __oldMsg then
				local sFightRid = __oldMsg[1] --战报id
				Player:getMailData():setCountryWarBattle(__msg.body, sFightRid)
			end
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[3059]撤销保存邮件
SocketManager:registerDataCallBack("reqMailSaveCancel",function ( __type, __msg, __oldMsg)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqMailSaveCancel.id then
			if not __oldMsg then
				Player:getMailData():clearAllMailReqed()
				return
			end
			local sPid = __oldMsg[1] --邮件id
			Player:getMailData():onMailSaveCancel(sPid)
			sendMsg(gud_mail_change_msg)
			sendMsg(gud_mail_save_cancel_success_msg)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)


--[3060]获取邮件未读数量
SocketManager:registerDataCallBack("reqMailNotReadNums",function ( __type, __msg, __oldMsg)
	if  __msg.head.state == SocketErrorType.success then 
		if __msg.head.type == MsgType.reqMailNotReadNums.id then
			--已知未读数与最新未读数，有出入就重新请求数据
			local tData = __msg.body.ns
			for i=1,#tData do
				local nCategory = tData[i].k
				local nNum = tData[i].v
				--（一般在后台期间断网，没有收到推送红点和邮件，然后重新请求红点数，不对就重置数据。）
				if Player:getMailData():getNotReadNums(nCategory) ~= nNum then
					Player:getMailData():clearAllMailCount(nCategory)
					sendMsg(gud_mail_change_msg, {nCategory})
				end
			end
			--设置数据
			Player:getMailData():setNotReadNums(__msg.body.ns)
			sendMsg(gud_mail_not_read_nums_msg)
			sendMsg(ghd_item_home_menu_red_msg)
		end
	else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)






