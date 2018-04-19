-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-10 9:30:52 星期三
-- Description: 玩家工坊控制类
-----------------------------------------------------



--在生产队列中添加生产项或预生产项
SocketManager:registerDataCallBack("addProduceItem",function ( __type, __msg )
	-- body		
	if __msg.head.state == SocketErrorType.success then
		--dump( __msg.body,"addProduceItem=",100)	
		if 	__msg.body then
			--刷新生产队列数据
			Player:getBuildData():getBuildById(e_build_ids.atelier):refreshDatasByService(__msg.body)
		end
    end
end)

--推送生产完成
SocketManager:registerDataCallBack("pushProduceFinish",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		--dump( __msg.body,"pushProduceFinish=",100)
		if __msg.body then
			--刷新工坊数据
			Player:getBuildData():getBuildById(e_build_ids.atelier):refreshDatasByService(__msg.body)
		end
	end
end)
--购买生产队列
SocketManager:registerDataCallBack("buyProduceQueue",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		--dump( __msg.body,"buyProduceQueue=",100)
		if __msg.body then
			--刷新生产队列数据
			Player:getBuildData():getBuildById(e_build_ids.atelier):refreshDatasByService(__msg.body)						
		end
	end
end)

--领取材料
SocketManager:registerDataCallBack("getProduction",function ( __type, __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		--dump( __msg.body,"getProduction=",100)
		--刷新生产队列数据
		if __msg.body then
			Player:getBuildData():getBuildById(e_build_ids.atelier):refreshDatasByService(__msg.body)			
			if __msg.body.o then
				showGetAllItems(__msg.body.o)
			end
            -- 气泡点击响应
			local tOb = {}
			tOb.nCell = e_build_cell.atelier
			sendMsg(ghd_build_bubble_clicktx_msg, tOb)			
		end
	end
end)

--获取生产时间 [2133]工坊生产材料需要多少时间
SocketManager:registerDataCallBack("getProduceTime",function ( __type, __msg )
	-- body
	--dump( __msg.body,"getProduceTime=",100)
	if __msg.head.state == SocketErrorType.success then	
		if __msg.body then
			Player:getBuildData():getBuildById(e_build_ids.atelier):refreshProduceTimeByService(__msg.body)
			sendMsg(ghd_refresh_atelier_protime_msg)
		end
	end
end)
--生产队列时间校对
SocketManager:registerDataCallBack("checkProQueueCD",function ( __type, __msg )
	-- body
	--dump(__msg, "checkProQueueCD", 100)
	if __msg.head.state == SocketErrorType.success then		
		if __msg.body then			
			--刷新工坊数据
			Player:getBuildData():getBuildById(e_build_ids.atelier):refreshDatasByService(__msg.body)
		end
	end
end)

--元宝立即完成上产
SocketManager:registerDataCallBack("atelierSpeedFinished",function ( __type, __msg )
	-- body
	--dump(__msg, "atelierSpeedFinished", 100)
	if __msg.head.state == SocketErrorType.success then		
		if __msg.body then						
		end
	end
end)


--ItemSelect 选中方式
ItemSelect_Select_Type = {
	Bg 		= 	1,		--背景选中
	Gou 	= 	2,		--勾选选中
}
--生产层显示类型
ItemProductLine_Type = {
	expand	= 1,--扩展
	free    = 2,--空闲
	wait   	= 3,--等待
	produce = 4,--生产
}