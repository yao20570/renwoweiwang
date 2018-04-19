----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-11-20 15:42:17
-- Description: 触发礼包数据
-----------------------------------------------------
local PlayTriGiftRes = require("app.layer.triggergift.data.PlayTriGiftRes")
local PlayTpackVo = require("app.layer.triggergift.data.PlayTpackVo")
local TriggerGiftData = class("TriggerGiftData")

function TriggerGiftData:ctor(  )
	self.tPtgList = {}
	self.tPtgDict = {}

	--新触发礼包用到的
	self.tTpsList = {} 	    --礼包列表
	self.tTpsDict = {} 	    --礼包列表(字典)
	self.tGetItemList = {} 	--购买获得的物品列表
end

function TriggerGiftData:setPlayTriGiftResList( tData )
	if not tData then
		return
	end
	self.tPtgList = {}
	self.tPtgDict = {}
	for i=1,#tData do
		local tData2 = PlayTriGiftRes.new(tData[i])
		if not tData2.bIsTake then
			table.insert(self.tPtgList, tData2)
			self.tPtgDict[tData2.nPid] = tData2
		end
	end
	--排序，结束cd最短的放在前面
	table.sort(self.tPtgList, function(a, b)
		return a:getCd() < b:getCd()
	end)
end

function TriggerGiftData:getPlayTriGiftResList( )
	return self.tPtgList
end

function TriggerGiftData:addPlayTriGiftRes( tData )
	if not tData then
		return
	end

	local tData2 = PlayTriGiftRes.new(tData)
	if tData2.bIsTake then
		return
	end
	
	if self.tPtgDict[tData2.nPid] then
		self.tPtgDict[tData2.nPid]:update(tData2)
	else
		table.insert(self.tPtgList, tData2)
		self.tPtgDict[tData2.nPid] = tData2
	end
	--排序，结束cd最短的放在前面
	table.sort(self.tPtgList, function(a, b)
		return a:getCd() < b:getCd()
	end)
end

function TriggerGiftData:delPlayTriGiftRes( nPid, bIsBuy)
	if not nPid then
		return
	end

	for i=1,#self.tPtgList do
		if self.tPtgList[i].nPid == nPid then
			if bIsBuy then
				self.tPtgList[i].bIsTake = true
			end
			table.remove(self.tPtgList, i)
			break
		end
	end
	self.tPtgDict[nPid] = nil			
end

function TriggerGiftData:getPlayTriGiftRes( nPid )
	return self.tPtgDict[nPid]
end

function TriggerGiftData:getOffLineTriggerPid( )
	for i=1,#self.tPtgList do
		if self.tPtgList[i].bIsOffLine then
			return self.tPtgList[i].nPid
		end
	end
	return nil
end

--关闭所有离线标识
function TriggerGiftData:closeAllOffLineTriggerPid( )
	for i=1,#self.tPtgList do
		if self.tPtgList[i].bIsOffLine then
			self.tPtgList[i].bIsOffLine = false
		end
	end
end

--是否存在未够买且已过了cd1且且未过cd2的触发式礼包
function TriggerGiftData:getIsHasGiftInCd2(  )
	-- print("TriggerGiftData:getIsHasGiftInCd2=",#self.tPtgList)
	for i=1,#self.tPtgList do
		-- print("self.tPtgList[i]:getCd(), self.tPtgList[i]:getCd2(), self.tPtgList[i].bIsTake =", self.tPtgList[i]:getCd(), self.tPtgList[i]:getCd2(), self.tPtgList[i].bIsTake )
		if self.tPtgList[i]:getCd() <= 0 and self.tPtgList[i]:getCd2() > 0 and not self.tPtgList[i].bIsTake then
			return true
		end
	end
	return false
end

--获取未够买且已过了cd1且且未过cd2的触发式礼包列表
function TriggerGiftData:getGiftListInCd2(  )
	local tGiftList = {}
	for i=1,#self.tPtgList do
		if self.tPtgList[i]:getCd() <= 0 and self.tPtgList[i]:getCd2() > 0 and not self.tPtgList[i].bIsTake then
			table.insert(tGiftList, self.tPtgList[i])
		end
	end
	--排序，结束cd最短的放在前面
	table.sort(tGiftList, function(a, b)
		return a:getCd2() < b:getCd2()
	end)
	return tGiftList
end

--获取cd1的触发式礼包列表
function TriggerGiftData:getGiftListInCd1(  )
	local tGiftList = {}
	for i=1,#self.tPtgList do
		if self.tPtgList[i]:getCd() > 0 then
			table.insert(tGiftList, self.tPtgList[i])
		end
	end
	return tGiftList
end





-------------------------------------------新版触发礼包数据-------------------------------------------

--刷新触发礼包数据
function TriggerGiftData:loadAllTriggerGift(_tData, _bPush)
	if not _tData then
		return
	end
	--如果是推送检查一下有没有新的触发礼包, 有就弹出界面, 没有只刷新数据
	local bHadNewPack = false --是否有新的触发礼包(新的礼包才触发, 礼包id相同的就不触发了)
	local nNewPid, nNewGid = nil, nil
	if _bPush then
		if _tData.tps then
			for k, v in pairs(_tData.tps) do
				local tData2
				if self.tTpsDict[v.p] and self.tTpsDict[v.p][v.g] then
					tData2 = self.tTpsDict[v.p][v.g]
					tData2:update(v)
				else
					tData2 = PlayTpackVo.new(v)
					if not tData2.bIsTake then
						table.insert(self.tTpsList, tData2)
						if not self.tTpsDict[tData2.nPid] then
							self.tTpsDict[tData2.nPid] = {}
							bHadNewPack = true
							nNewPid = tData2.nPid
							nNewGid = tData2.nGid
						end
						self.tTpsDict[tData2.nPid][tData2.nGid] = tData2
					end
				end
				--如果已购买删除礼包数据
				if tData2 and tData2.bIsTake then
					self:delPlayTpack(tData2.nPid, tData2.nGid, true)
				end
			end
		end
	else
		self.tTpsDict = {}
		self.tTpsList = {} 	    --礼包列表
		if _tData.tps then
			for i=1, #_tData.tps do
				local tData2 = PlayTpackVo.new(_tData.tps[i])
				if not tData2.bIsTake then
					table.insert(self.tTpsList, tData2)
					if not self.tTpsDict[tData2.nPid] then
						self.tTpsDict[tData2.nPid] = {}
					end
					self.tTpsDict[tData2.nPid][tData2.nGid] = tData2
				end
			end
		end
	end

	if _tData.o then
		self.tGetItemList = _tData.o  --购买获得的物品列表
		showGetItemsAction(self.tGetItemList)
		closeDlgByType(e_dlg_index.triggergift)
	end
	--排序，结束cd最长的放在前面
	table.sort(self.tTpsList, function(a, b)
		return a:getCd() > b:getCd()
	end)
	-- dump(self.tTpsList, "self.tTpsList 100", 100)

    sendMsg(gud_trigger_gift_list_refresh)

    if bHadNewPack then
		--有新的触发礼包
		-- 弹出触发礼包界面
		openDlgTriggerGift(nNewPid, nNewGid)
	end
end

--获取购买获得的物品列表
function TriggerGiftData:getHasGotItemList()
	-- body
	return self.tGetItemList
end


function TriggerGiftData:getPlayTpackList( )
	return self.tTpsList
end


--获取礼包
-- nPid, nGid: 礼包id, 礼品id
function TriggerGiftData:getPlayTpack(nPid, nGid)
	return self.tTpsDict[nPid][nGid]
end

--获取离线触发礼包id和礼品id
function TriggerGiftData:getOffLineTpackPidGid()
	for i = 1, #self.tTpsList do
		if self.tTpsList[i].bIsOffLine then
			return self.tTpsList[i].nPid, self.tTpsList[i].nGid
		end
	end
	return nil
end

--关闭所有离线标识
function TriggerGiftData:closeAllOffLineTpackPid( )
	for i=1, #self.tTpsList do
		if self.tTpsList[i].bIsOffLine then
			self.tTpsList[i].bIsOffLine = false
		end
	end
end

--是否存在未够买且已过了cd1且且未过cd2的触发式礼包
function TriggerGiftData:getIsHasTpackInCd2()
	for i=1, #self.tTpsList do
		if self.tTpsList[i]:getCd() <= 0 and self.tTpsList[i]:getCd2() > 0 and not self.tTpsList[i].bIsTake then
			return true
		end
	end
	return false
end

--获取未购买且已过了cd1且未过cd2的触发式礼包列表
function TriggerGiftData:getTpackListInCd2()
	local tGiftList = {}
	for i=1, #self.tTpsList do
		if self.tTpsList[i]:getCd() <= 0 and self.tTpsList[i]:getCd2() > 0 and not self.tTpsList[i].bIsTake then
			table.insert(tGiftList, self.tTpsList[i])
		end
	end
	--排序，结束cd最长的放在前面
	table.sort(tGiftList, function(a, b)
		return a:getCd2() > b:getCd2()
	end)
	return tGiftList
end

--获取cd1的触发式礼包列表
function TriggerGiftData:getTpackListInCd1()
	local tGiftList = {}
	for i=1, #self.tTpsList do
		if self.tTpsList[i]:getCd() > 0 then
			table.insert(tGiftList, self.tTpsList[i])
		end
	end
	return tGiftList
end

--删除礼包数据
function TriggerGiftData:delPlayTpack( nPid, nGid, bIsBuy)
	if not nPid or not nGid then
		return
	end

	for i=1, #self.tTpsList do
		if self.tTpsList[i].nPid == nPid and self.tTpsList[i].nGid == nGid then
			if bIsBuy then
				self.tTpsList[i].bIsTake = true
			end
			table.remove(self.tTpsList, i)
			break
		end
	end
	if self.tTpsDict[nPid] and self.tTpsDict[nPid][nGid] then
		self.tTpsDict[nPid][nGid] = nil
	end		
end


-------------------------------------------新版触发礼包数据-------------------------------------------

return TriggerGiftData