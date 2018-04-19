local BagInfo = class("BagInfo")

function BagInfo:ctor(  )
	self:myInit()
end

function BagInfo:myInit(  )
	-- body
	--基础信息
	self.items = {}	 	--List<ItemRes>	物品
	self.tItemUseInfo = {} --每日使用信息
end

--刷新物品数据
function BagInfo:refreshItemsByService( _data, nType )
	-- body
	if not _data then
		print("物品数据异常")
		return
	end
	--加载背包物品数据
	if nType == 1 then
		for i, itemRes in pairs(_data) do
			if self.items[itemRes.id] then
				self.items[itemRes.id]:refreshItemDataByService(itemRes, false)			
			else
				local itemdata = getBaseItemDataByID(itemRes.id) 
				if itemdata then
					itemdata:refreshItemDataByService(itemRes, false)
					self.items[itemRes.id] = itemdata
				end		
			end
		end
	--推送背包物品数据		
	elseif nType == 2 then
		for i, itemRes in pairs(_data) do
			if self.items[itemRes.i] then
				self.items[itemRes.i]:refreshItemDataByService(itemRes, true)			
			else
				local itemdata = getBaseItemDataByID(itemRes.i)
				if itemdata then
					itemdata:refreshItemDataByService(itemRes, true)
					self.items[itemRes.i] = itemdata			
				end
			end
			--推送物品数量为零则对该物品进行清理
			if self.items[itemRes.i] then
				if(self.items[itemRes.i].nCt == 0) then
					self.items[itemRes.i] = nil
				end
			end
		end
	end
	sendMsg(gud_refresh_act_red)			

end

--刷新物品的当前使用数量 _nType 1--加载 2--推送
function BagInfo:refreshItemsUseInfo( tData, _nType )
	-- body
	if not tData or #tData < 0 then
		return
	end
	if _nType == 1 then
		self:clearItemsDayUseInfo()
	end
	for k, v in pairs(tData) do
		self.tItemUseInfo[v.i] = v.c
	end
end
--清理当天的物品使用数据
function BagInfo:clearItemsDayUseInfo()
	-- body
	self.tItemUseInfo = {}
end

--物品是否可以使用 对
function BagInfo:isItemCanUse( _itemid )
	-- body	
	if not _itemid then
		return false
	end
	local pItemData = self:getItemDataById(_itemid) or getBaseItemDataByID(_itemid)
	if pItemData.nDayUse == -1 then--无使用限制
		return true
	else
		local nHadUseCnt = self:getItemHadUseNum(_itemid) --self.tItemUseInfo[_itemid] or 0
		if nHadUseCnt < pItemData.nDayUse then
			return true
		else
			return false
		end 
	end
end

--获取物品已经使用次数
function BagInfo:getItemHadUseNum( _itemid )
	-- body
	local nHadUseCnt = 0 
	if _itemid then
		nHadUseCnt = self.tItemUseInfo[_itemid] or 0
	end
	return nHadUseCnt
end

--获取指定物品数据
function BagInfo:getItemDataById( _itemid )
	-- body
	return self.items[_itemid]
end

--获取items分类列表
function BagInfo:getItemsByType( _type )
	-- body
	local titems = {}
	for k, v in pairs(self.items) do
		if v.nType == _type and v.nIsShow == 1 then
			table.insert(titems, v)
		end
	end
	table.sort( titems, function ( a, b )
		-- body
		return a.nSequence < b.nSequence --升序
	end )
	return titems
end

--获取背包红点
function BagInfo:getBagRedNum( _nType )
	-- body	
	local nRedNum = 0--Player:getEquipData():getEquipVosNewCnt()
	local tItems = {}
	if not _nType then
		nRedNum = Player:getEquipData():getIdleEquipVosNewCnt()
		tItems = self:getAllBagData(_nType)
		-- for k, v in pairs(self.items) do 
		-- 	table.insert(tItems, v)
		-- end
	else
		tItems = self:getItemsByType(_nType)
	end
	for k, v in pairs(tItems) do 
		if v.nRedNum > 0 then
			nRedNum = nRedNum + 1
		end
	end
	return nRedNum
end
--获得在背包的的所有物品
function BagInfo:getAllBagData(  )
	-- body
	local titems = {}
	for k, v in pairs(self.items) do
		if v.nIsShow == 1 then
			table.insert(titems, v)
		end
	end
	return titems

end

--清理物品红点
function BagInfo:clearItemRedNum( _nType )
	-- body
	local tItems = {}
	if not _nType then
		for k, v in pairs(self.items) do 
			table.insert(tItems, v)
		end
	else
		tItems = self:getItemsByType(_nType)
	end
	for k, v in pairs(tItems) do
		v:clearItemRed()
	end
	--刷新主界面菜单红点
	sendMsg(ghd_item_home_menu_red_msg)
end

--刷新背包容量数据
function BagInfo:updateBagCapacity( _data )		
	-- body
	if _data then
		self.ms = _data.ms or self.ms
		self.bm = _data.bm or self.bm		
	end
end
return BagInfo