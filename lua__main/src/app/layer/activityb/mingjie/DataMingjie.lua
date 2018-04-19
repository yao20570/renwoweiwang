
----------------------------------------------------- 
-- Author: luwenjing
-- Date: 2018-02-26 15:41:45  星期一
-- 冥界入侵数据
----------------------------------------------------- 
local Activity = require("app.data.activity.Activity")
local DataMingjie = class("DataMingjie", function()
	return Activity.new(e_id_activity.luckystar) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.mingjie] = function (  )
	return DataMingjie.new()
end

-- _index
function DataMingjie:ctor()
	-- body
   self:myInit()
   -- self.nLastLoginTime = 0 --最后登陆的时间
end


function DataMingjie:myInit( )

	self.nS = 0 		-- Integer 当前的阶段 
	self.nCd = 0 		-- Long 本阶段结束CD 
	self.tBt = {} 		-- List<Pair<Integer,Integer>> 属性已购买次数 
	self.nP = 0 		-- Integer 玩家已有积分 
	self.tAts = {}		-- List<AttrExchangeVO> 配置的属性数据 
	self.tSs = {}  		-- List<ShopVO> 配置的积分商店数据 

	self.tAtts = {}		--List<Pair<short,float>> 已有属性

	self.tGt = {}		--List<Pair<Integer,Integer>> 积分兑换次数

	self.fLastLoadTime = 0

	self.nF = 0 		--玩家拥有的符纸的数量

	self.nP = 0

	self.bCheckExchange = getLocalInfo("mingjie_exchange_check".. Player:getPlayerInfo().pid, 0 )
	self.bCheckPoint = getLocalInfo("mingjie_point_check".. Player:getPlayerInfo().pid, 0 )

end


-- 读取服务器中的数据
function DataMingjie:refreshDatasByServer( _tData )
	-- dump(_tData,"，冥界入侵数据", 20)
	if not _tData then
	 	return
	end

	self.nS = _tData.s or self.nS 		    -- Integer 当前的阶段 0:准备阶段，1:第一阶段，2第二阶段
	self.nCd = _tData.cd or self.nCd 		-- Long 本阶段结束CD,修改后0阶段也发cd了
	self.tBt = _tData.bt or self.tBt 		-- List<Pair<Integer,Integer>> 属性已购买次数 
	
	self.nP = _tData.p or self.nP 		    -- Integer 玩家已有积分 
	self.tAts = _tData.ats or self.tAts		-- List<AttrExchangeVO> 配置的属性数据 
	self.tSs = _tData.ss or self.tSs  		-- List<ShopVO> 配置的积分商店数据 
	self.tAtts = _tData.atts or self.tAtts  -- List<Pair<short,float>> 已有属性
	self.tGt = _tData.gt or self.tGt 		-- List<Pair<Integer,Integer>> 积分兑换次数
	self.nP = _tData.p or self.nP 
	self.nF = _tData.f or self.nF 
	if _tData.bt then  		--如果有购买次数的更新 就刷新属性数据
		self:refreshAttrData()

	end
	if _tData.gt then  --如果有购买次数的更新 就刷新属性数据
		self:refreshShopData()
	end

	self:refreshActService(_tData)--刷新活动共有的数据

	self.fLastLoadTime = getSystemTime()

end
-- 获取下一阶段的倒计时
-- return(int):返回剩余时长
function DataMingjie:getStageLeftTime( )
	
	-- 单位是秒
	local fCurTime = getSystemTime()
	if self.nCd and self.nCd >0 then
		local fLeft=self.nCd - (fCurTime - self.fLastLoadTime)
		if fLeft <0 then
			fLeft = 0
		end
		return fLeft
	end
	return 0

end
--刷新属性商品信息
function DataMingjie:refreshAttrData(  )
	-- body
	for i=1, #self.tAts do
		local nNum = self:getBuyAttrCountByIndex(self.tAts[i].i)
		self.tAts[i].num=nNum
		if self.tAts[i].t > 0 then
			if self.tAts[i].num < self.tAts[i].t then
				self.tAts[i].state = 1 
			else
				self.tAts[i].state = 2
			end
		else
			self.tAts[i].state = 1
		end
	end

	table.sort( self.tAts, function (a,b)
		if a.state ~= b.state then
			return a.state < b.state
		else
			return a.i < b.i
		end
	end )
end
--刷新积分兑换商品信息
function DataMingjie:refreshShopData(  )
	-- body
	for i=1, #self.tSs do
		local nNum = self:getShopExchangeCountByIndex(self.tSs[i].i)
		self.tSs[i].num=nNum

		if self.tSs[i].t > 0 then
			if self.tSs[i].num < self.tSs[i].t then
				self.tSs[i].state = 1 
			else
				self.tSs[i].state = 2
			end
		else
			self.tSs[i].state = 1
		end
	end
	table.sort( self.tSs, function (a,b)
		if a.state ~= b.state then
			return a.state < b.state
		else
			return a.i < b.i
		end

	end )
end
--刷新已拥有的属性
function DataMingjie:refreshOwnAttr( _tData )
	-- body
	self.tAtts=_tData or self.tAtts

end
--属性是否能兑换
function DataMingjie:isCanExchangeAttr(  )
	-- body
	local bCanChange = false
	local tItemData=Player:getBagInfo():getItemDataById(100170)
	if tItemData then
		for i=1,#self.tAts do
			if self.tAts[i].t > 0 then
				if self.tAts[i].num < self.tAts[i].t then

					if tItemData.nCt > self.tAts[i].c then --拥有量大于消耗量
						bCanChange = true
					end
				end
			else
				if tItemData.nCt > self.tAts[i].c then --拥有量大于消耗量

					bCanChange = true
				end
			end
		end
		if not bCanChange then
			return bCanChange
		end

		if tItemData.nRedNum >0 or tonumber(self.bCheckExchange) == 0 then
			bCanChange = true
		else
			bCanChange = false
		end
	end
	return bCanChange
end
--积分商店是否能兑换
function DataMingjie:isCanExchangePoint(  )
	-- body
	local bCanChange = false
	local tItemData=Player:getBagInfo():getItemDataById(100171)
	if tItemData then
		for i=1,#self.tSs do
			if self.tSs[i].t > 0 then
				if self.tSs[i].num < self.tSs[i].t then
					if tItemData.nCt > self.tSs[i].c[1].v then --拥有量大于消耗量
						bCanChange = true
					end
				end
			else
				if tItemData.nCt > self.tSs[i].c[1].v then --拥有量大于消耗量
					bCanChange = true
				end
			end
		end
		if not bCanChange then
			return bCanChange
		end

		if tItemData.nRedNum>0 or tonumber(self.bCheckPoint) == 0 then
			bCanChange = true
		else
			bCanChange = false
		end
	end
	return bCanChange

end
--根据索引获得该属性已购买次数
function DataMingjie:getBuyAttrCountByIndex( _nIndex )
	-- body
	if not _nIndex then
		return
	end
	for i=1,#self.tBt do
		if self.tBt[i].k==_nIndex then
			return self.tBt[i].v
		end
	end
	return 0
end
--根据索引获得商店已兑换次数
function DataMingjie:getShopExchangeCountByIndex( _nIndex )
	-- body
	if not _nIndex then
		return
	end
	for i=1,#self.tGt do
		if self.tGt[i].k==_nIndex then
			return self.tGt[i].v
		end
	end
	return 0
end

--更新属性兑换价格
function DataMingjie:refreshAttrCost( _tData,_nIndex )
	-- body
	if not _tData then
		return
	end
	for i=1,#self.tAts do
		if self.tAts[i].i == _nIndex then
			self.tAts[i].c = _tData.c
			self.tAts[i].g = _tData.g
		end
	end
end
--设置冥界入侵商店的红点提示状态
function DataMingjie:setShopCheckState( _nType )
	-- body
	if _nType == 1 then
		self.bCheckExchange = 1
		saveLocalInfo("mingjie_exchange_check" .. Player:getPlayerInfo().pid,1)
	elseif _nType == 2 then
		self.bCheckPoint = 1
		saveLocalInfo("mingjie_point_check" .. Player:getPlayerInfo().pid,1)
	end
end


-- 获取红点方法
function DataMingjie:getRedNums()
	local nNums = self.nLoginRedNums
	if self:isCanExchangeAttr() or self:isCanExchangePoint() then

		return nNums + 1
	else
		return nNums
	end
end



return DataMingjie