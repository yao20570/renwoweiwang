----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2018-03-30 10:13:33
-- Description: 国家宝藏数据
-----------------------------------------------------

--国家宝藏数据
local DataCountryTreasure = class("DataCountryTreasure")

function DataCountryTreasure:ctor(  )
	self:myInit()
end

function DataCountryTreasure:myInit(  )		


	self.nD = 0 		-- Integer 今日剩余挖掘次数|digCount| 
	self.nFdcd = 0 		-- Long 免费挖掘CD时间|freeDigCd| 
	self.nFr = 0 		-- Integer 今日免费剩余刷新次数|freeRefresh| 
	self.nCr = 0 		-- Integer 今日花费已经刷新次数|costRefresh| 
	self.nArcd = 0 		-- Long 自动刷新倒计时|autoRefreshCd| 
	self.nH = 0 		-- Integer 今日剩余帮助次数|helpCount| 
	self.tList = {}		-- List<country.TreasureRes$TreasureVo> 宝藏列表|list| 
	self.tMine = {} 	-- List<country.TreasureRes$TreasureVo> 我的宝藏|mine| 
	self.tHelp = {} 	-- List<country.TreasureRes$TreasureVo> 协助列表|help| 
	self.tAskHelp = {}	-- List<country.TreasureRes$TreasureVo> 求助列表|askHelp| 
	self.nAp = 0 		-- Integer 全部页数|allPage| 
	self.nCp = 0 		-- Integer 当前页数|currPage| 

	self.tTotalHelpList = {}

	self.fLastLoadTime = 0
	--o List<Pair<Integer,Long>> 开启获得的物品 

end

-- 读取服务器中的数据
function DataCountryTreasure:refreshDatasByService( _tData )
	-- dump(_tData,"国家宝藏")
	if not _tData then
	 	return
	end
	self.fLastLoadTime = getSystemTime()

	self.nD = _tData.d or self.nD 		-- Integer 今日剩余挖掘次数|digCount| 
	self.nFdcd = _tData.fdcd or self.nFdcd 		-- Long 免费挖掘CD时间|freeDigCd| 
	self.nFr = _tData.fr or self.nFr 		-- Integer 今日免费剩余刷新次数|freeRefresh| 
	self.nCr = _tData.cr or self.nCr 		-- Integer 今日花费已经刷新次数|costRefresh| 
	self.nArcd = _tData.arcd or self.nArcd 		-- Long 自动刷新倒计时|autoRefreshCd| 
	self.nH = _tData.h or self.nH 		-- Integer 今日剩余帮助次数|helpCount| 
	self.tList = _tData.list or self.tList		-- List<country.TreasureRes$TreasureVo> 宝藏列表|list| 
	if #self.tMine > 0 then   --当已经有我的宝箱列表的状态下刷新数据 需要判断是否有人帮助
		self:showBeHelped(_tData.mine)
	end
	self.tMine = _tData.mine or self.tMine 	-- List<country.TreasureRes$TreasureVo> 我的宝藏|mine| 
	self.tHelp = _tData.help or self.tHelp 	-- List<country.TreasureRes$TreasureVo> 协助列表|help| 
	-- self.tAskHelp = _tData.askhelp or self.tAskHelp	-- List<country.TreasureRes$TreasureVo> 求助列表|askHelp| 

	
	self.nAp = _tData.ap or self.nAp 		-- Integer 全部页数|allPage| 
	self.nCp = _tData.cp or self.nCp 		-- Integer 当前页数|currPage| 

	-- if self.nCp == 1 then
	-- 	self.tAskHelp = _tData.askhelp or self.tAskHelp	-- List<country.TreasureRes$TreasureVo> 求助列表|askHelp| 
	-- else

	if _tData.askhelp then
		self:addAskHelp( _tData.askhelp)
	end

	if _tData.help  or _tData.askhelp then
		
		self:updateTotalHelpList()
	end
end
function DataCountryTreasure:addAskHelp( _tNewAskHelp )
	-- body
	if self.nCp == 1 then
		self.tAskHelp = {}
	end
	for i = 1 , #_tNewAskHelp do
		local v = _tNewAskHelp[i]
		self.tAskHelp[v.tsid] = v
		-- table.insert(self.tAskHelp,_tNewAskHelp[i])
	end
end

function DataCountryTreasure:updateTotalHelpList(  )
	self.tTotalHelpList = {}

	for k,vv in pairs (self.tAskHelp) do
		if not vv.bRemove then
			vv.bRemove= false
			for i = 1 , #self.tHelp do
				local v= self.tHelp[i] 
				if (v.tsid == vv.tsid )then   --在我已帮助列表移除列表
					vv.bRemove = true
				end
			end
			if self:isRemoveHelp(vv.tsid) then   --在我已帮助列表移除列表
				vv.bRemove = true
			end
		end
	end

	for i = 1 , #self.tHelp do 
		table.insert(self.tTotalHelpList,self.tHelp[i])
	end
	for k,v in pairs(self.tAskHelp) do 
		if not v.bRemove then
			table.insert(self.tTotalHelpList,v)
		end
	end
	-- sendMsg(ghd_refresh_country_treasure)

end
-- 获取自动刷新的倒计时
-- return(int):返回剩余时长
function DataCountryTreasure:getRefreshLeftTime(  )
	-- -- 单位是秒
	local fCurTime = getSystemTime()
	-- 总共剩余多少秒
	if self.nArcd then
		local fLeft = self.nArcd - (fCurTime - self.fLastLoadTime)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return self.nArcd
	end

end
-- 获取免费挖掘的倒计时
-- return(int):返回剩余时长
function DataCountryTreasure:getFreeDigLeftTime(  )
	-- -- 单位是秒
	local fCurTime = getSystemTime()
	-- 总共剩余多少秒
	if self.nFdcd then
		local fLeft = self.nFdcd - (fCurTime - self.fLastLoadTime)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return self.nFdcd
	end
end

-- 获取我的宝箱消失的倒计时
-- return(int):返回剩余时长
function DataCountryTreasure:getTreasureDisappearTime( _sId )
	if not _sId then
		return 0
	end
	-- -- 单位是秒
	local fCurTime = getSystemTime()
	for i = 1 , # self.tMine do
		if _sId == self.tMine[i].tsid then
			-- 总共剩余多少秒
			local nCd = self.tMine[i].gcd or self.tMine[i].tcd
			local fLeft = nCd - (fCurTime - self.fLastLoadTime)
			if(fLeft < 0) then
				fLeft = 0
			end
			return fLeft
		end
	end
	return 0
end

-- 获取求助列表宝箱消失的倒计时
-- return(int):返回剩余时长
function DataCountryTreasure:getHelpTreasureDisappearTime( _sId )
	if not _sId then
		return 0
	end
	-- -- 单位是秒
	local fCurTime = getSystemTime()
	for i = 1 , # self.tTotalHelpList do
		if _sId == self.tTotalHelpList[i].tsid then
			-- 总共剩余多少秒
			local nCd = self.tTotalHelpList[i].gcd or self.tTotalHelpList[i].tcd
			local fLeft = nCd - (fCurTime - self.fLastLoadTime)
			if(fLeft < 0) then
				fLeft = 0
			end
			return fLeft
		end
	end
	return 0
end

-- 获取是否移除求助列表宝箱
function DataCountryTreasure:isRemoveHelp( _sId )
	if not _sId then
		return
	end
	local tData = self.tAskHelp[_sId]
	if not tData then
		return true
	end
	-- 单位是秒
	local fCurTime = getSystemTime()
	local nCd = tData.gcd
	local fLeft = nCd - (fCurTime - self.fLastLoadTime)
	if(fLeft < 0) then
		return true
	else
		return false
	end
end


function DataCountryTreasure:removeHelpItem( _sId )
	if not _sId then
		return
	end
	-- dump(self.tTotalHelpList,"tTotalHelpList------")
	-- body
	-- print("#self.tTotalHelpList-------",#self.tTotalHelpList)
	for i = 1 , #self.tTotalHelpList do
		-- print("iiiiiiii",i)
		if _sId == self.tTotalHelpList[i].tsid then
			table.remove(self.tTotalHelpList,i)
			break
		end
	end

	for i = 1 , #self.tHelp do
		-- print("iiiiiiii",i)
		if _sId == self.tHelp[i].tsid then
			table.remove(self.tHelp,i)
			break
		end
	end
end
function DataCountryTreasure:isCanFreeDig(  )
	-- body
	local bFree = true
	-- for i = 1 , #self.tMine do
	-- 	local nCd = self.tMine[i].gcd or self.tMine[i].tcd
	-- 	if nCd > 0 then
	-- 		bFree = false
	-- 	end
	-- end
	if self:getFreeDigLeftTime() > 0 then
		bFree = false
	end
	return bFree
end

function DataCountryTreasure:removeMyItem( _sId )
	if not _sId then
		return
	end
	-- body
	for i = 1 , #self.tMine do
		if _sId == self.tMine[i].tsid then
			table.remove(self.tMine,i)
			break
		end
	end
end

function DataCountryTreasure:getRedNum(  )
	-- body
	local nNum = self:getTreasureListRedNum() + self:getMyTreasureRedNum() + self:getHelpTreasureRedNum()
	return nNum
end

function DataCountryTreasure:getTreasureListRedNum()
	-- body
	local nLeft = self:getFreeDigLeftTime()
	if (not nLeft or nLeft <= 0) and #self.tList > 0 and self.nD > 0 then
		return 1
	else
		return 0
	end
end

function DataCountryTreasure:getMyTreasureRedNum( )
	-- body
	local nNum = 0	
	if self.tMine and #self.tMine > 0 then
		for k, v in pairs(self.tMine) do
			local nLeftTime = self:getTreasureDisappearTime(v.tsid)
			if nLeftTime then
				if nLeftTime==0 then						
					if v.hn then    --被协助时间到可领取三个列表都要刷新
						nNum = nNum + 1
					end
				end
			end			
		end
	end
	return nNum	
end

--
function DataCountryTreasure:getHelpTreasureRedNum( )
	-- body
	local nNum = 0
	--可帮助其他成员
	if self.tTotalHelpList and #self.tTotalHelpList > 0 then
		for k, v in pairs(self.tTotalHelpList) do
			local nLeftTime = self:getHelpTreasureDisappearTime(v.tsid)
			if nLeftTime then
				if nLeftTime==0 then						
					if v.tcd then    --被协助时间到可领取三个列表都要刷新
						nNum = nNum + 1							
					end
				-- else
				-- 	if (not v.tcd) and (not self.tHelp or #self.tHelp <= 0) and self.nH > 0 then
				-- 		nNum = nNum + 1
				-- 	end					
				end
			end			
		end
	end	

	return nNum	
end
--被帮助飘字提示
function DataCountryTreasure:showBeHelped(_tNewMine  )
	if not _tNewMine or #_tNewMine <= 0 then
		return
	end
	-- body
	for i = 1, #self.tMine do
		local v = self.tMine[i]  
		for k = 1,# _tNewMine do
			local vv = _tNewMine[k]
			if v.tsid == vv.tsid and not v.hn and vv.hn then    --同一个宝箱 从没帮助人到有帮助人 就需要飘字提醒
				local tDbData = getCountryTreasureDataById(v.tid)
				if tDbData then
					TOAST(string.format(getConvertedStr(9,10236),vv.hn,tDbData.name))
				end
			end
		end
	end
end

return DataCountryTreasure