----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-10-26 15:25:37
-- Description: 武王控制类
-----------------------------------------------------

--[-3101]对BOSS发起战争
SocketManager:registerDataCallBack("reqWorldBossWar",function ( __type, __msg, __oldMsg )
	--dump(__msg.body,"reqWorldBossWar",100)
	if  __msg.head.state == SocketErrorType.success then
        if __msg.head.type == MsgType.reqWorldBossWar.id then
        	local nX, nY = __oldMsg[1], __oldMsg[2]

        	--获取Boss战列表
			SocketManager:sendMsg("reqWorldBossWarList",{nX, nY})
		
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)

--[-3104]加载boss战争列表
SocketManager:registerDataCallBack("reqWorldBossWarList",function ( __type, __msg, __oldMsg )
	-- dump(__msg.body,"reqWorldBossWarList",100)
	if  __msg.head.state == SocketErrorType.success then
        if __msg.head.type == MsgType.reqWorldBossWarList.id then
        	local nX, nY, tAwakeBoss = __oldMsg[1], __oldMsg[2], __oldMsg[3]
        	if __msg.body then
	        	local BossWarVO = require("app.layer.wuwang.data.BossWarVO")
	        	local tBossWarVOs = {}
	        	local bIsHasMe = false
	        	for i=1, #__msg.body.vos do
	        		local tBossWarVO = BossWarVO.new(__msg.body.vos[i])
	        		table.insert(tBossWarVOs, tBossWarVO)
	        		if tBossWarVO.nSenderCountry == Player:getPlayerInfo().nInfluence then
	        			bIsHasMe = true
	        		end
	        	end
	        	if bIsHasMe == false and tAwakeBoss then --是发起
	        		--等级限制
					local nLvNeed = getAwakeInitData("evilOpen")
					if nLvNeed and Player:getPlayerInfo().nLv < nLvNeed then
						TOAST(string.format(getTipsByIndex(20097),nLvNeed))

						-- TOAST(string.format(getConvertedStr(3, 10517), nLvNeed))
						return
					end
	        		
	        		--不可以跨区
					if not Player:getWorldData():getIsCanWarByPos(nX, nY, e_war_type.boss) then
						TOAST(getTipsByIndex(20032))
						return
					end

	        		--二次确认
					local DlgAlert = require("app.common.dialog.DlgAlert")
				    local pDlg = getDlgByType(e_dlg_index.alert)
				    if(not pDlg) then
				        pDlg = DlgAlert.new(e_dlg_index.alert)
				    end
				    pDlg:setTitle(getConvertedStr(3, 10091))
				    local tStr = {
				        {color=_cc.white,text=getConvertedStr(3, 10506)},
				        {color=_cc.blue,text= string.format("%s",tAwakeBoss.name)},
				        {color=_cc.white,text=getConvertedStr(3, 10507)},
				    }
				    pDlg:setContent(tStr)
				    pDlg:setRightHandler(function (  )
				    	pDlg:closeDlg(false)

				    	--发起Boss战
				        SocketManager:sendMsg("reqWorldBossWar" ,{nX, nY})
					end)
				    pDlg:showDlg(bNew)
	        	else
	        		local tViewDotMsg =  Player:getWorldData():getViewDotMsg(nX, nY)
		        	if tViewDotMsg and tViewDotMsg.nType == e_type_builddot.boss then
		        		--打开界面
		        		local tObject = {
						    nType = e_dlg_index.bosswar, --dlg类型
						    tViewDotMsg = tViewDotMsg,
						    tBossWarVOs = tBossWarVOs,
						}
						sendMsg(ghd_show_dlg_by_type, tObject)
		        	end	
	        	end
			end
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end)


