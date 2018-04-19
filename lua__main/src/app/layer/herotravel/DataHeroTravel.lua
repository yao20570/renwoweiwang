----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2017-12-07 21:15:33
-- Description: 武将游历数据数据
-----------------------------------------------------

--武将游历数据数据
local DataHeroTravel = class("DataHeroTravel")
local DataHero = require("app.layer.hero.data.DataHero")

function DataHeroTravel:ctor(  )
	self:myInit()
end

function DataHeroTravel:myInit(  )
	self.tTraveList={}

	self.tHero1= nil
	self.tHero2 = nil

	self.tHeroId={}
	-- self.nRandom2 = 0

end

-- 读取服务器中的数据
function DataHeroTravel:refreshDatasByServer( _tData )
	if not _tData then
	 	return
	end
	self.tTraveList={}
	for k, v in pairs(_tData.tls) do
		self:refreshTravelData(v)
		
	end
	-- self.fLastLoadTime 		= getSystemTime() 					 --最后刷新时间
end

function DataHeroTravel:refreshTravelData(_tData)
	-- body
	local tData={}
	tData.nQueueId=_tData.qid
	tData.nTaskId=_tData.tid
	if _tData.hero then

		--直接给英雄的id就好了吧？？？
		local tDataHero=DataHero.new()

		tDataHero:refreshDatasByService(_tData.hero)
		tData.tHeroData=tDataHero
		self.tHeroId[_tData.qid]=tDataHero.nId
		-- local tHeroData= Player:getHeroInfo():getHero(_tData.hero.h)
		-- if tHeroData then
		-- 	self.tHeroId[_tData.qid]= _tData.hero.h
		-- end
	else
		tData.tHeroData = self:setTraveHero(_tData.qid)
	end
	tData.fLastLoadTime 		= getSystemTime() 					 --最后刷新时间
	tData.nCd=_tData.cd
	self.tTraveList[_tData.qid]=tData
end

function DataHeroTravel:setTraveHero(_nIndex )
	-- body
	local tHeroList = Player:getHeroInfo():getHeroList() --获取拥有的英雄列表
	if #tHeroList ==1 then
		local tHero=tHeroList[1]
		self.tHeroId[_nIndex]=tHero.nId
		return tHero
	end
	if #tHeroList > 0 then
		local nHeroId=0
		-- local nHeroIndex=0
		if not self.tHeroId[_nIndex] then
			for i=1,#tHeroList do
				local nRandom = math.random(1,#tHeroList)
				local tHeroData=tHeroList[nRandom]
				nHeroId=tHeroData.nId
				for k,v in pairs(self.tHeroId) do
					if nHeroId == v then
						nHeroId=0 			--找到一个已经使用的英雄就重新找
					end
				end
				if nHeroId ~= 0 then 

					self.tHeroId[_nIndex]=nHeroId
					return tHeroData
				end
			end
			if nHeroId == 0 then  		--上面用随机数找不到的时候 就用第一个英雄
				local tHero=tHeroList[1]
				self.tHeroId[_nIndex]=tHero.nId
				return tHero
			end
		else
			return Player:getHeroInfo():getHero(self.tHeroId[_nIndex])
		end
	end
	
	return nil

end

function DataHeroTravel:getHeroTravelList( )
	-- body
	return self.tTraveList
end
--根据队列id获得队列数据
function DataHeroTravel:getTraveDataByQId( _qId )
	-- body
	for k,v in pairs(self.tTraveList) do
		if _qId== v.nQueueId then
			return v
		end
	end
	return nil
end


-- 获取下一阶段的倒计时
-- return(int):返回剩余时长
function DataHeroTravel:getTraveLeftTime( _qId )
	if not _qId then
		return
	end
	-- 单位是秒
	local fCurTime = getSystemTime()
	local tTravelData=self:getTraveDataByQId(_qId)
	if tTravelData then

		-- 总共剩余多少秒
		if tTravelData.nCd then
			if tTravelData.nCd < 0 then
				return tTravelData.nCd
			else 
				local fLeft = tTravelData.nCd - (fCurTime - tTravelData.fLastLoadTime)
				if(fLeft < 0) then
					fLeft = 0
				end
				return fLeft
			end
		end
	end
	return -1

end

function DataHeroTravel:getTravelingNum( )
	-- body
	local nNum=0
	for k,v in pairs(self.tTraveList) do
		local nLeftTime=self:getTraveLeftTime(v.nQueueId)
		if nLeftTime>0 then
			nNum=nNum+1
		end
	end
	return nNum
end

return DataHeroTravel