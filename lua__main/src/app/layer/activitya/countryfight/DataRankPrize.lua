local DataRankPrize = class("DataRankPrize")

function DataRankPrize:ctor()
	-- body
   self:myInit()
end

function DataRankPrize:myInit(  )
	-- body
	self.nId = nil
	self.nL = nil
	self.nR = nil
	self.tAs = {}

	self.nStatus = en_get_state_type.null	
end

--国战排行奖励数据刷新
function DataRankPrize:refreshByServer1( tData )
	-- body
	if tData then
		self.nId = tData.id or self.nId
		self.nL = tData.min or self.nL
		self.nR = tData.max or self.nR
		if tData.awards and #tData.awards > 0 then
			--物品排序
			sortGoodsList(tData.awards)
			--物品解析
			for i, v in pairs(tData.awards) do
				local pitem = getGoodsByTidFromDB(v.k)
				if pitem then
					pitem.nCt = v.v
					self.tAs[i] = pitem
				end				
			end					
		end		
	end
end

function DataRankPrize:refreshByServer2( tData )
	-- body
	if tData then
		self.nId = tData.g or self.nId
		self.nL = tData.l or self.nL
		self.nR = tData.r or self.nR
		if tData.as and #tData.as > 0 then
			--物品排序
			sortGoodsList(tData.as)
			--物品解析
			for i, v in pairs(tData.as) do
				local pitem = getGoodsByTidFromDB(v.k)
				if pitem then
					pitem.nCt = v.v
					self.tAs[i] = pitem
				end				
			end					
		end		
	end
end

function DataRankPrize:refreshByServer3( tData )
	-- body
	if tData then
		self.nId = tData.lv or self.nId
		self.nL = tData.l or self.nL
		self.nR = tData.r or self.nR
		if tData.as and #tData.as > 0 then
			--物品排序
			sortGoodsList(tData.as)
			--物品解析
			for i, v in pairs(tData.as) do
				local pitem = getGoodsByTidFromDB(v.k)
				if pitem then
					pitem.nCt = v.v
					self.tAs[i] = pitem
				end				
			end					
		end		
	end
end

function DataRankPrize:updateStatus( nstatus )
	-- body	
	self.nStatus = nstatus or self.nStatus
end

function DataRankPrize:getRankStr(  )
	-- body
	if self.nL == self.nR then
		return self.nL 
	else
		return self.nL.."-"..self.nR
	end
end

return DataRankPrize