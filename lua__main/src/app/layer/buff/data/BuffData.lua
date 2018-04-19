----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-14 15:26:14
-- Description: buff系统数据
-----------------------------------------------------
local BuffVo = require("app.layer.buff.data.BuffVo")

--buff系统数据
local BuffData = class("BuffData")

function BuffData:ctor(  )
	self.tBuffVos = {}
end

function BuffData:release(  )
end

--[8300]加载buff数据
function BuffData:onBuffLoad( tData )
	if not tData then
		return
	end
	for i=1,#tData.bs do --bs	List<BuffVo>	所有buff信息
		local tBuffVo = BuffVo.new(tData.bs[i])
		self.tBuffVos[tBuffVo.nId] = tBuffVo
	end	
	self:getCampBuffList()
end

--更新buff数据
--tData: ub List<BuffVo>	更新的BUF数据[update buffs]( 这里的BuffVo是服务器数据)
function BuffData:updateBuffVos( tData)
	if not tData then
		return
	end
	for i=1,#tData do
		local nId = tData[i].b
		if self.tBuffVos[nId] then
			self.tBuffVos[nId]:update(tData[i])
		else
			local tBuffVo = BuffVo.new(tData[i])
			self.tBuffVos[tBuffVo.nId] = tBuffVo
		end
	end	
end

function BuffData:removeBuffVos(tData)
	if not tData then
		return
	end
	for i=1,#tData do
		local nId = tData[i]
		if self.tBuffVos[nId] then
			self.tBuffVos[nId] = nil
			-- table.remove(self.tBuffVos, nId)
			--self.tBuffVos[nId]:update(tData[i])
		end
	end	
end

--获取建造相关buff
function BuffData:getBuildBuffList()
	-- body
	local tBuildBuffVos = {}
	for nId, tBuffVo in pairs(self.tBuffVos) do
		if not tBuffVo then break end
		if (nId >= 32190 and nId <= 32208) then
			tBuildBuffVos[nId] = tBuffVo
		end
	end
	return tBuildBuffVos
end

--获取兵营相关buff
function BuffData:getCampBuffList()
	-- body
	local tCampBuffVos = {}
	for nId, tBuffVo in pairs(self.tBuffVos) do
		if not tBuffVo then break end
		if nId == 30002 or nId == 30005 or (nId >= 32081 and nId <= 32110) then
			tCampBuffVos[nId] = tBuffVo
		end
		if self:isCampBuff(nId) then
			tCampBuffVos[nId] = tBuffVo
		end
	end
	return tCampBuffVos
end

--是否是募兵令buff
function BuffData:isCampBuff(_nId)
	-- body
	if (_nId >= 33009 and _nId <= 33013) then
		return true
	end
	return false
end

--获取募兵令Buff
function BuffData:getCampBuff( )
	-- body
	for nId, buffVo in pairs(self.tBuffVos) do
		if not buffVo then break end
		if self:isCampBuff(nId) then
			return buffVo
		end
	end
end

--移除buff
function BuffData:removeBuff(tData)
	if self.tBuffVos[tData.nId] then
		self.tBuffVos[tData.nId] = nil
	end
end

function BuffData:getBuffVo( nId )
	local nBuffId = tonumber( nId or 0)
	return self.tBuffVos[nBuffId]
end

function BuffData:getAllBuff()
	-- body
	return self.tRecruitVos
end

--获取指定属的Buff提升百分比数值
function BuffData:getBuffPercentAdds( nBuffKey )
	--服务器buff
	local fPercent = 0
	-- dump(self.tBuffVos, "self.tBuffVos ==")
	if self.tBuffVos then
		for nId, tBuffVo in pairs(self.tBuffVos) do
			fPercent = fPercent + tBuffVo:getBuffPercentAdd(nBuffKey)
		end
	end
	-- print("fPercent ?????????????????? nBuffKey: ", nBuffKey, fPercent)

	--季节数
	local nSeasonDay = Player:getWorldData().nSeasonDay
	if nSeasonDay then
		local tSeasonData = getWorldSeasonData(nSeasonDay)
		if tSeasonData then
			local tData = getBuffDataByIdFromDB(tSeasonData.buffid) 
			if tData then
				fPercent = fPercent + tData:getBuffPercentAdd(nBuffKey)
			end
		end
	end

	--科技等级
	--所有科技
	local tNolys = Player:getTnolyData():getAllTnolyDatas()
	for k,tNoly in pairs(tNolys) do
		local tNolyLvUp = tNoly:getCurLimitData()
		if tNolyLvUp then
			if tNolyLvUp.buffid then
				local tData = getBuffDataByIdFromDB(tNolyLvUp.buffid) 
				if tData then
					fPercent = fPercent + tData:getBuffPercentAdd(nBuffKey)
				end
			end
		end
	end

	return fPercent
end

function BuffData:getRecruitmentBuff(  )
	-- body
	local tBuffIds = {33009, 33010, 33011, 33012, 33013}
	local pBuffVo  = nil
	for k, v in pairs(tBuffIds) do
		pBuffVo = self:getBuffVo(v) 
		if pBuffVo then
			break
		end
	end
	return pBuffVo
end
return BuffData