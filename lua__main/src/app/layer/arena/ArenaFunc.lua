local ArenaFunc = {}

function ArenaFunc.doClearChallengeCd( _nCost )
	-- body
	local strTips = {
	    {color=_cc.pwhite, text=getConvertedStr(6, 10819)}
	}
	--展示购买对话框
	showBuyDlg(strTips,_nCost,function (  )
	    SocketManager:sendMsg("clearChallengeCd", {}, function ( __msg )
			if  __msg.head.state == SocketErrorType.success then 
	            if __msg.head.type == MsgType.clearChallengeCd.id then
	            	TOAST(getConvertedStr(6, 10818))
	            end
	        else
	            TOAST(SocketManager:getErrorStr(__msg.head.state))
	        end
		end)
	end, 0, true)	
end

function ArenaFunc.doRefreshArenaView (_nCost)

	local func_refresh = function ( )
		-- body
	    SocketManager:sendMsg("reqNewChallengeList", {}, function ( __msg )
			if  __msg.head.state == SocketErrorType.success then 
	            if __msg.head.type == MsgType.reqNewChallengeList.id then
	            	TOAST(getConvertedStr(6, 10822))
	            end
	        else
	            TOAST(SocketManager:getErrorStr(__msg.head.state))
	        end
		end)		
	end
	if _nCost > 0 then--弹出提示消费
		local strTips = {
		    {color=_cc.pwhite, text=getConvertedStr(6, 10821)}
		}
		--展示购买对话框
		showBuyDlg(strTips,_nCost,function (  )
			func_refresh()
		end, 0, true)	
	else--免费直接调用刷新
		func_refresh()
	end
	
end

--设置默认的竞技场阵容
function ArenaFunc.adjustArenaLineUp( _bDefault, _tData )
	-- body	
	local tHeroList = {}
	if _bDefault then
		tHeroList = Player:getHeroInfo():getOnlineHeroList()
	else
		tHeroList = _tData
	end		
	if tHeroList and #tHeroList > 0 then
		local adasd = {}
		for k,v in pairs(tHeroList) do			
			if (type(v) == "table") then
				table.insert(adasd, v.nId)
			end
		end		
		local str = table.concat(adasd, ",")
		SocketManager:sendMsg("adjustArenaLineUp", {str}, function ( __msg )
			-- body
			if  __msg.head.state == SocketErrorType.success then 
	            if __msg.head.type == MsgType.adjustArenaLineUp.id then
	            	if not _bDefault then
	            		TOAST(getConvertedStr(6, 10824))
	            	end	            	
	            end
	        else
	            TOAST(SocketManager:getErrorStr(__msg.head.state))
	        end			
		end)
	end	
end

function ArenaFunc.readArenaReport( _nRId, _nType, _nOp )
	-- body
	local nType = _nType or 1
	SocketManager:sendMsg("readArenaReport", {_nRId, nType, _nOp}, function ( __msg , __oldMsg)
		-- body
		if  __msg.head.state == SocketErrorType.success then 
            if __msg.head.type == MsgType.readArenaReport.id then
            	if __oldMsg and __oldMsg[2] then
            		if __oldMsg[2] == 1 then
            			Player:getArenaData():clearRecordNewMark(__oldMsg[1], __oldMsg[3])
            		elseif __oldMsg[2] == 2 then
            			Player:getArenaData():clearAllRecordNewMark(__oldMsg[3])
            		end            		
            	end				
            end
        else
            TOAST(SocketManager:getErrorStr(__msg.head.state))
        end			
	end)	
	
end
return ArenaFunc