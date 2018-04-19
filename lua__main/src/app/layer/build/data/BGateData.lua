-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-21 18:18:01 星期五
-- Description: 城门数据 
-----------------------------------------------------

local Build = require("app.layer.build.data.Build")
local DataNpcWall = require("app.layer.wall.DataNpcWall")

local BGateData = class("BGateData", function()
	-- body
	return Build.new()
end)

function BGateData:ctor(  )
	-- body
	self:myInit()
end


function BGateData:myInit(  )
    self.nCd	                =       0        	--	招募CD
    self.tDs	                =       {}      	--	城墙守卫 (全部)
    self.tDf                    =       {}          --  单个城墙守卫
    self.ns	                    =       0           --	自动招募守卫开关 0.关闭 1.开启
    self.tSq	                =       {}      	--	上阵武将顺序
    self.tDq	                =       {}      	--	城防武将顺序
    self.nLastServerTime        =       0           --  最后一次更新服务器的时间
	self.nLv 					= 		0    		  --等级


    self.tNpcList               =       {}          --  城防守卫列表
end

--从服务端获取数据刷新
function BGateData:refreshDatasByService( tData )
	-- body
	self.nCellIndex 			= 		tData.loc or self.nCellIndex  --建筑格子下标（位置）
	self.nLv 					= 		tData.lv or self.nLv 		  --等级

    self.nCd	                =       tData.gcd or self.nCd       	--	招募CD
    if tData.gcd then
    	self.nLastServerTime = getSystemTime(true)
    end
    self.tDs	                =       tData.ds or self.tDs       	--	城墙守卫

    if tData.ds then 	--	城墙守卫
    	self:refreshDefenResList(tData.ds)
    end


    self.ns	                    =       tData.s	 or self.ns	        --	自动招募守卫开关 0.关闭 1.开启
    self.tSq	                =       tData.sq or self.tSq       	--	上阵武将顺序
    self.tDq 					= 		tData.dq or self.tDq 		--  城防武将顺序
    if tData.dt then
    	self:refshDsData(tData.dt)
    end

	-- dump(tData)

end

--获取招募cd剩余时间
function BGateData:getRecruitCd()
	local nTime = 0
	nTime = self.nCd - (getSystemTime(true) -self.nLastServerTime )
	if nTime< 0 then
       nTime = 0
	end
	return nTime
end

--获取是否有招募提示
function BGateData:showRecruitTip()
	-- body
	local bShow = false
	if not self:getIsLocked() then
		local nDefenNums = table.nums(self.tDs)
		if self:getRecruitCd()== 0  and nDefenNums < getWallBaseDataByLv(self.nLv).num  then
			bShow = true
		end
	end
	return bShow
end

--刷新守卫数据 _tData (刷新的守卫列表)
function BGateData:refshDsData(_tData)

	if not _tData then
		return
	end

	-- dump(_tData,"_tData")

	if  table.nums(_tData)> 0 then
		local bFind = false
		for k,v in pairs(_tData) do
			for x,y in pairs(self.tDs) do
				if v.id == y.id then
					self.tDs[x] = v --for循环不可以直接赋值
					bFind = true
				end
			end
			if not bFind  then
				table.insert(self.tDs, v)
			end
		end
	else
		table.insert(self.tDs, v)
	end

	self:refreshDefenResList(self.tDs)
end


-- --刷新单个守卫数据
-- function BGateData:refreshSingleDefData(_tData)
-- 	-- body
-- 	if (not _tData) or table.nums(_tData)<= 0 then
--        return
-- 	end

-- 	for k,v in pairs(self.tDs) do
-- 		if v.id == _tData.id then
-- 			if _tData.lv then --等级(治疗不返回)
-- 				v.lv = _tData.lv
-- 			end

-- 			if _tData.max then --最高带兵量(治疗不返回)
-- 			   v.max = _tData.max
-- 			end

-- 			if _tData.tp then --带兵量
-- 				v.tp = _tData.tp
-- 			end

-- 			if _tData.q then --品质(治疗不返回)
-- 				v.q = _tData.q
-- 			end

-- 			if _tData.ct then --剩余提升次数(治疗不返回)
-- 				v.ct = _tData.ct
-- 			end

-- 		end
-- 	end
-- end


--获取一键提升金币个数
function BGateData:getUpdateAllGateNpcGold()
	local nGold = 0
	local nSingle = tonumber(getWallInitParam("trainCost")) 
	if self.tDs and table.nums(self.tDs)> 0 then
		for k,v in pairs(self.tDs) do
			if v.ct then
				nGold = nGold + v.ct*nSingle
			end
		end
	end
	return nGold
end

--获取是否有需要治疗的守卫
function BGateData:getBCureDef()
	local bNeed = false
	if self.tDs and table.nums(self.tDs)> 0 then
		for k,v in pairs(self.tDs) do
			if v.tp and v.max then
				if v.tp < v.max then
					bNeed = true
					break
				end
			end
		end
	end
	return bNeed
end

--刷新城门守卫数据
function BGateData:refreshDefenResList(_serverNpc)
	self.tNpcList = {}

	if (not _serverNpc) or table.nums(_serverNpc)<= 0 then
		return self.tNpcList
	end

	for k,v in pairs(_serverNpc) do
		if v.mid then
			local pNpc = getNPCData(v.mid,en_npc_tpye.wall) --城墙守卫
			if pNpc then
				pNpc:refreshDatasByService(v)
				table.insert(self.tNpcList, pNpc)
			end
		end
	end


	return self.tNpcList
end

--获取显示城门守军列表
function BGateData:getshowDefWallArmy()
	local tList = {}
	local tShowList = {}--为了展示4个一列
	local nNums = getWallBaseDataByLv(self.nLv).num --当前等级城防容量个数
	local nNextNums = nil --下一级城防容量个数
	local tNextLevelData = getWallBaseDataByLv(self.nLv) --下一级城防数据
	if tNextLevelData then
	   nNextNums = tNextLevelData.num +1
		local nMaxNums = getBuildParam("defenceLimit")
		if nMaxNums then
			nMaxNums = tonumber(nMaxNums)
			if nNextNums > nMaxNums then
				nNextNums = nMaxNums
			end
		end
	end

	--当前显示城防列表个数
	local nIndex = 1
	if nNextNums then
		nIndex = nNextNums
	else
		nIndex = nNums
	end

	for i=1,nIndex do
		if self.tNpcList[i] then
			table.insert(tList,self.tNpcList[i])
		else
			local nType = TypeIconHero.LOCK
			if i > nNums then
				nType = TypeIconHero.LOCK --锁住状态
			else
				nType = TypeIconHero.ADD --可添加状态
			end
			table.insert(tList,nType)
		end
	end

	local tData = {}
	for k,v in pairs(tList) do
		if k == table.nums(tList) then
			table.insert(tData,v)
			table.insert(tShowList,tData)
		else
			if k%4 == 0 then
				table.insert(tData,v)
				table.insert(tShowList,tData)
				tData = {}
			else
				table.insert(tData,v)
			end
		end
	end

	return tShowList

end

return BGateData