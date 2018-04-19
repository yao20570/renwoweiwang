-----------------------------------------------------
-- author: liangzhaowei
-- Date: 2017-06-15 21:16:18
-- Description: 道具使用界面
-----------------------------------------------------
local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemInfo = require("app.module.ItemInfo")
local nArmyBackGoodsId = 100032 --行军召回道具id
local nBossCallGoodsId1 = 100154 --Boss召唤劵
local nBossCallGoodsId2 = 100155 --Boss召唤劵

local DlgWorldUseResItem = class("DlgWorldUseResItem", function()
	-- body
	return DlgCommon.new(e_dlg_index.worlduseresitem)
end)

--tItemList ：物品的数据
--tTaskCommend: 任务指令
--tCityMove:迁城指令
--tBossPos:Boss召唤位置
--bIsFromCityWar:是否是从城战面板点开的
function DlgWorldUseResItem:ctor( tItemList, tTaskCommend, tCityMove, tBossPos,bIsFromCityWar)
	--更改行军召回道具id配表
	nArmyBackGoodsId =  tonumber(getGlobleParam("vipMarchCallbackItem"))
	self.tItemList = tItemList
	self.tTaskCommend = tTaskCommend
	if self.tTaskCommend then
		--记录当前状态和类别
		local tTaskMsg = Player:getWorldData():getTaskMsgByUuid(self.tTaskCommend.sTaskUuid)
		if tTaskMsg then
			self.tTaskCommend.nTaskState = tTaskMsg.nState
			self.tTaskCommend.nTaskType = tTaskMsg.nType
			self.tTaskCommend.bIsBot = tTaskMsg:getIsBot()
		end
	end

	self.tCityMove = tCityMove
	self.tBossPos = tBossPos
	self.bIsFromCityWar = bIsFromCityWar or false
	parseView("item_use_res", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgWorldUseResItem:myInit(  )
end

--解析布局回调事件
function DlgWorldUseResItem:onParseViewCallback( pView )
	-- body
	self.pSelectView = pView
	self:addContentView(pView) --加入内容层

	self:initDatas()
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgWorldUseResItem",handler(self, self.onDestroy))
end

--初始化控件
function DlgWorldUseResItem:setupViews( )
	if self.tCityMove then
		self:setTitle(getConvertedStr(3, 10102))
	elseif self.tBossPos then
		self:setTitle(getConvertedStr(3, 10497))
	else
		self:setTitle(getConvertedStr(5, 10113))
	end
	--内容层
	self.pLyList 	= 		self:findViewByName("ly_list")

end

--创建listView
function DlgWorldUseResItem:createListView()
	-- listview
	if(not self.pListView) then
		self.pListView = createNewListView(self.pLyList)

		if table.nums(self.tShowData )> 0  then
			self.pListView:setItemCount(table.nums(self.tShowData))
			self.pListView:setItemCallback(handler(self, self.everyCallback))
			self.pListView:reload(true)
		end
	else
		if(self.tShowData) then
			self.pListView:setItemCount(table.nums(self.tShowData))
		else
			self.pListView:setItemCount(0)
		end
		self.pListView:notifyDataSetChange(true)
	end
end

-- 没帧回调 _index 下标 _pView 视图
function DlgWorldUseResItem:everyCallback( _index, _pView )
	local pView = _pView
	if not pView then
		if self.tShowData[_index] then
			pView = ItemInfo.new(TypeItemInfoSize.M)
			pView:setClickCallBack(handler(self, self.onBtnClicked))
		end
	end

	if _index and self.tShowData[_index] then
		pView:setCurData(self.tShowData[_index])	
		local sTid = self.tShowData[_index].sTid
		local nFree = 0
		local nMax = 0
		if sTid == nArmyBackGoodsId then
			nFree = Player:getWorldData():getVipFreeCall()
			local tVipData = getAvatarVIPByLevel(Player:getPlayerInfo().nVip)
			if tVipData then
	 			nMax = tVipData.freemarchback
	 		end
		end
		--Boss召唤券
		local bIsBossCall = sTid == e_id_item.bossCallS or sTid == e_id_item.bossCallL or sTid == e_id_item.bossCallH
		if nFree > 0 then --免费
			pView:changeExToFree(nFree, nMax)
		elseif getMyGoodsCnt(sTid) <= 0 then --需要购买
			if bIsBossCall then
				pView:changeExToGet()
			else
				pView:changeExToGold()
			end
		else 
			if bIsBossCall then
				pView:changeExToHad(getConvertedStr(3, 10163))
			else
				pView:changeExToHad()
			end
		end
	end

	return pView
end

-- 修改控件内容或者是刷新控件数据
function DlgWorldUseResItem:updateViews(  )
	self:createListView()

	if self.bIsFromCityWar then
		local pLabel1 = MUI.MLabel.new({text ="", size = 20})
		pLabel1:setString( getTextColorByConfigure(getTipsByIndex(20096)))

		local nHeight=self.pLyList:getHeight()
		local nY=#self.tItemList * 150
		pLabel1:setPosition(self.pLyList:getWidth()/2,nHeight - nY)
  	    self.pLyList:addChild(pLabel1,20)
	end

end

-- 析构方法
function DlgWorldUseResItem:onDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgWorldUseResItem:regMsgs( )
	regMsg(self, ghd_world_vipfree_called_change, handler(self, self.onVipFreeCalled))
end

-- 注销消息
function DlgWorldUseResItem:unregMsgs(  )
	unregMsg(self, ghd_world_view_pos_msg)
end


--暂停方法
function DlgWorldUseResItem:onPause( )
	-- body
	self:unregMsgs()
end

--继续方法
function DlgWorldUseResItem:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--初始化数据
function DlgWorldUseResItem:initDatas(  )
	--获取显示物品
	self.tShowData = {}
	if self.tItemList  and table.nums(self.tItemList)> 0 then
		for k,v in pairs(self.tItemList) do
			local pData = getGoodsByTidFromDB(v)
			if pData then
				table.insert(self.tShowData,pData)
			end
		end
	end
end

--vip免费召回次数更改
function DlgWorldUseResItem:onVipFreeCalled( )
	if self.tTaskCommend then
		if self.tTaskCommend.nOrder == e_type_task_input.call then
			self:updateViews()
		end
	end
end

--按钮点击回调
function DlgWorldUseResItem:onBtnClicked( tItemData )
	if tItemData then

		local nCnt = getMyGoodsCnt(tItemData.sTid)
		if self.tTaskCommend then
			local bIsCanCtrl = false
			--任务
			local tTaskMsg = Player:getWorldData():getTaskMsgByUuid(self.tTaskCommend.sTaskUuid)
			if tTaskMsg then
				local nTaskState = tTaskMsg.nState
				local nTaskType = tTaskMsg.nType
				--如果和当前状态没有发生改变
				if self.tTaskCommend.nTaskState == nTaskState and self.tTaskCommend.nTaskType == nTaskType then
					--前进
					if nTaskState == e_type_task_state.go then
						--加速
						if self.tTaskCommend.nOrder == e_type_task_input.quick then
							if nTaskType == e_type_task.wildArmy or
								nTaskType == e_type_task.collection or
								 nTaskType == e_type_task.tlboss or 
								 nTaskType == e_type_task.ghostdom or
								 nTaskType == e_type_task.imperwar then
							  	bIsCanCtrl = true
							end
						end
						--召回
						if self.tTaskCommend.nOrder == e_type_task_input.call then
							if nTaskType == e_type_task.wildArmy or
								 nTaskType == e_type_task.collection or
								 nTaskType == e_type_task.cityWar or
								 nTaskType == e_type_task.countryWar or
								 nTaskType == e_type_task.garrison or 
								 nTaskType == e_type_task.boss or
								 nTaskType == e_type_task.tlboss or
								 nTaskType == e_type_task.ghostdom or
								 nTaskType == e_type_task.imperwar or
								 nTaskType == e_type_task.zhouwang then
							  	bIsCanCtrl = true
							end
						end
					--返回
					elseif nTaskState == e_type_task_state.back then
						--加速
						if self.tTaskCommend.nOrder == e_type_task_input.quick then
							if nTaskType == e_type_task.wildArmy or
								 nTaskType == e_type_task.collection or
								 nTaskType == e_type_task.cityWar or
								 nTaskType == e_type_task.countryWar or
								 nTaskType == e_type_task.garrison or
								 nTaskType == e_type_task.boss or
								 nTaskType == e_type_task.tlboss or
								 nTaskType == e_type_task.ghostdom or
								 nTaskType == e_type_task.imperwar or
								 nTaskType == e_type_task.zhouwang then
							  	bIsCanCtrl = true
							end
						end
					end
				end
			end

			if not bIsCanCtrl then
				TOAST(getConvertedStr(3, 10361))
				self:closeDlg(false)
				return
			end
			
			--行军道具有vip免费召唤次数
			local nFree = 0
			if tItemData.sTid == nArmyBackGoodsId then
				nFree = Player:getWorldData():getVipFreeCall()
			end
			--数量大于1或免费
			if nCnt > 0 or nFree > 0 then
				-- dump({self.tTaskCommend.sTaskUuid, self.tTaskCommend.nOrder, tItemData.sTid, 0})
				SocketManager:sendMsg("reqWorldTaskInput", {self.tTaskCommend.sTaskUuid, self.tTaskCommend.nOrder, tItemData.sTid, 0})
				self:closeDlg(false)
			else
				local tStr = {
			    	{color = _cc.pwhite, text = getConvertedStr(3, 10172)},
			    	{color = _cc.yellow, text = tItemData.sName or ""},
			    }
				showBuyDlg(tStr, tItemData.nPrice, function( )
					SocketManager:sendMsg("reqWorldTaskInput", {self.tTaskCommend.sTaskUuid, self.tTaskCommend.nOrder, tItemData.sTid, 1})
					self:closeDlg(false)
				end)
			end
		elseif self.tCityMove then
			local nRandemMoveCityId = 100027 --随机
			local nLowMoveCityId = 100028 --中级
			local nHighMoveCityId = 100029 --高级
			local nIndex = nil
			local nGoodsId = tItemData.sTid
			if nGoodsId == nRandemMoveCityId then
				nIndex = 0	
			elseif nGoodsId == nLowMoveCityId then
				nIndex = 1
			elseif nGoodsId == nHighMoveCityId then
				nIndex = 2
			end
			if nIndex then				
				local nBlockId = WorldFunc.getBlockId(self.tCityMove.nX, self.tCityMove.nY)
				if nCnt > 0 then
					SocketManager:sendMsg("reqWorldMigrate", {nIndex, nBlockId, self.tCityMove.nX, self.tCityMove.nY, 0},handler(self,self.onMigrateCallback))
					sendMsg(ghd_world_hide_city_click_msg)
					self:closeDlg(false)
				else
					local tStr = {
				    	{color = _cc.pwhite, text = getConvertedStr(3, 10172)},
				    	{color = _cc.yellow, text = tItemData.sName or ""},
				    }
					showBuyDlg(tStr, tItemData.nPrice, function()
						SocketManager:sendMsg("reqWorldMigrate", {nIndex, nBlockId, self.tCityMove.nX, self.tCityMove.nY, 1},handler(self,self.onMigrateCallback))
						sendMsg(ghd_world_hide_city_click_msg)
						self:closeDlg(false)
					end)
				end
			end
		elseif self.tBossPos then --Boss召唤劵
			if nCnt > 0 then
				SocketManager:sendMsg("reqZhouWangCall", {tItemData.sTid, self.tBossPos.nX, self.tBossPos.nY})
				sendMsg(ghd_world_hide_city_click_msg)
				self:closeDlg(false)
			else
				--跳到
				local tObject = {
				    nType = e_dlg_index.wuwang --武王
				}
				sendMsg(ghd_show_dlg_by_type, tObject)
				self:closeDlg(false)
			end
		else
			local tObject = {}
			if nCnt > 0 then
				tObject.type = 1--使用
				tObject.useId = tItemData.sTid
				tObject.useNum = 1
			else
				tObject.type = 2--购买并使用
				tObject.useId = tItemData.sTid
				tObject.useNum = 1
			end
			sendMsg(ghd_useItems_msg,tObject)
			self:closeDlg(false)
		end
	end
end

function DlgWorldUseResItem:onMigrateCallback( __msg ,__oldMsg )
	-- body
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqWorldMigrate.id then
			if __msg.body then
					print("dlgworld-- 350",self.bIsFromCityWar)

				-- if self.bIsFromCityWar then
				-- 	print("dlgworld-- 351")
					closeDlgByType(e_dlg_index.citywar,false)
				-- end
			end
		end
    end
end

return DlgWorldUseResItem