-- WeaponData.lua
-----------------------------------------------------
-- Author: dshulan
-- Date: 2017-06-6 19:53:53
-- Description: 神兵基础数据
-----------------------------------------------------


-- 神兵数据类
local WeaponData = class("WeaponData")

e_cd_type = {
	build            = 1,
	advance          = 2
}

function WeaponData:ctor(  )
	self.tAllWeaponDatas    = {}                      --所有神兵
	self.tFragmentsList     = {}                      --碎片列表
	--初始化所有的神兵
	self:initAllWeaponDatas() 
end

--初始化所有的神兵
function WeaponData:initAllWeaponDatas()
	-- body
	getAllWeaponDatas()
	self.tWeaponsList    = clone(getAllInitWeapons())     --神兵列表
	self.tAllWeaponDatas = {}
	for k,weapon in pairs(self.tWeaponsList) do
		self.tAllWeaponDatas[weapon.nId] = weapon
	end
	-- self.tAllWeaponDatas = clone(getAllWeaponDatas())
	-- self.tWeaponsList    = clone(getAllInitWeapons())     --神兵列表
end

--获得所有的神兵
function WeaponData:getAllWeaponDatas()
	-- body
	return self.tAllWeaponDatas
end

--通过id获取某个神兵对象信息
function WeaponData:getWeaponInfoById(_nId)
	-- body

	return self.tAllWeaponDatas[_nId]
end

function WeaponData:getWeaponByIndex(_idx)
	-- body
	return self.tWeaponsList[_idx]
end

function WeaponData:getWeaponList()
	-- body
	return self.tWeaponsList
end


--[7100]加载玩家神兵数据
function WeaponData:onLoadAllWeaponInfo(tData)
	self:createWeaponListInfo(tData)
end

--神兵列表信息(碎片列表和神兵对象列表)
function WeaponData:createWeaponListInfo(tData)
	-- body
	if not tData then return end
	local tRes = {}
	tRes.tFragmentList       = tData.fs       --list 碎片列表
	tRes.tWeaponList         = tData.as       --list 神兵列表

	for _, v in pairs(tRes.tFragmentList) do
		self.tFragmentsList[v.i] = self:createFragmentInfo(v)        --神兵id为key
	end
	for k, weapon in pairs(tRes.tWeaponList) do
		local tWeapon = self:getWeaponInfoById(weapon.i)
		if tWeapon then
			tWeapon:refreshDatasByService(weapon)
			tWeapon:setPreData(weapon.l, weapon.s, weapon.c)
		end
		local nIndex = self:getWeaponIndexAtList(tWeapon)
		if nIndex then
			self.tWeaponsList[nIndex] = tWeapon  --这里是修改原来该神兵的信息，不是重新插入,所以要查找原来的位置
		end
	end

	return tRes
end

--获取武器在tWeaponsList的位置
function WeaponData:getWeaponIndexAtList( tWeapon )
	if not tWeapon then
		return 
	end
	for k,v in pairs(self.tWeaponsList) do
		if v and v.nId == tWeapon.nId then
			return k
		end
	end
end

--创建神兵碎片信息
function WeaponData:createFragmentInfo(tData)
	-- body
	if not tData then return end
	local tRes = {}  
	tRes.nWeaponId          = tData.i       --Integer 神兵id
	tRes.nFragments         = tData.n       --Integer 碎片数量

	return tRes
end


--刷新神兵数据
function WeaponData:refreshWeaponInfo(_tData, _nType)
	-- body
	if not _tData then return end
	local tData = _tData.a
	if tData then
		local tWeapon = self:getWeaponInfoById(tData.i)
		if tWeapon then
			tWeapon:refreshDatasByService(tData)
			if _nType then
				self:showEffect(tWeapon, _nType)
			end
		end
	end
end

--播放升级和升阶特效和音效
--_nType: 1指升级, 2指进阶
function WeaponData:showEffect(tInfo, _nType)
	--如果升一阶则播放音效和特效
	if _nType == 2 then
		--播放音效
		Sounds.playEffect(Sounds.Effect.lvup)
		--播放进阶特效
		sendMsg(ghd_weapon_advance_effect)

		tInfo.nPreAdLv = tInfo.nAdvanceLv
		return
	end
	--如果升一级则播放音效和特效
	if tInfo.nWeaponLv > tInfo.nPreLv then
		-- TOAST("升级成功")
		--播放音效
		Sounds.playEffect(Sounds.Effect.lvup)
		--触发升级特效
		sendMsg(ghd_weapon_upgrade_effect)
		tInfo.nPreLv = tInfo.nWeaponLv

		self.bHasLevelUp = true
	else
		self.bHasLevelUp = false
	end
	if not self.bHasLevelUp then
		if tInfo.nPreCritical > 1 then
			--触发暴击特效
			-- print("触发暴击特效")
			sendMsg(ghd_weapon_baoji_effect)
		end
	end
	tInfo.nPreCritical = tInfo.nCritical
	
end

--暴击活动影响刚刚升级时的暴击从而达到播放特效
function WeaponData:setPreCriticalByActivity( _weaponId, nCritical)
	local tWeapon = self:getWeaponInfoById(_weaponId)
	if tWeapon then
		if tWeapon.nPreCritical then 
		  	if tWeapon.nPreCritical <= 1 then
		  		tWeapon.nPreCritical = math.max(tWeapon.nPreCritical, nCritical)
			end
		else
			tWeapon.nPreCritical = nCritical
		end
	end
end

--获得打造剩余时间
function WeaponData:getBuildCDLeftTime(_weaponId)
	-- body
	local tWeaponInfo = self:getWeaponInfoById(_weaponId)
	if not tWeaponInfo then return -999 end
	if tWeaponInfo.nBuildCD and tWeaponInfo.nBuildCD > 0 then
		-- 单位是秒
		local fCurTime = getSystemTime()
		-- 总共剩余多少秒
		local fLeft = tWeaponInfo.nBuildCD - (fCurTime - tWeaponInfo.nBuildLastLoadTime or 0)
		-- if(fLeft < 0) then
		-- 	fLeft = 0
		-- end
		return fLeft
	else
		return -999
	end
end

--获取进阶剩余时间
function WeaponData:getAdvCDLeftTime(_weaponId)
	-- body
	local tWeaponInfo = self:getWeaponInfoById(_weaponId)
	if not tWeaponInfo then return -999 end
	if tWeaponInfo.nAdvanceCD and tWeaponInfo.nAdvanceCD > 0 then
		-- 单位是秒
		local fCurTime = getSystemTime()
		-- 总共剩余多少秒
		local fLeft = tWeaponInfo.nAdvanceCD - (fCurTime - tWeaponInfo.nAdvLastLoadTime or 0)
		-- if(fLeft < 0) then
		-- 	fLeft = 0
		-- end
		return fLeft
	else
		return -999
	end
end

--获取额外暴击产生剩余时间
function WeaponData:getExtraCriticalLeftTime(_weaponId)
	-- body
	local tWeaponInfo = self:getWeaponInfoById(_weaponId)
	if not tWeaponInfo then return -999 end

	if tWeaponInfo.nExtraCD and tWeaponInfo.nExtraCD > 0 then
		-- 单位是秒
		local fCurTime = getSystemTime()
		-- 总共剩余多少秒
		local fLeft = tWeaponInfo.nExtraCD - (fCurTime - tWeaponInfo.nExtraBjLastLoad or 0)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return -999
	end
end


--是否升了一级
function WeaponData:isHasLevelUp()
	-- body
	return self.bHasLevelUp
end


--[7108]神兵碎片推送
function WeaponData:onRefreshFragments(tData)
	-- body
	self:onResetFragments(tData)
end

--[7109]购买神兵碎片
function WeaponData:retBuyFragments(tData)
	-- body
	self:onResetFragments(tData)
end

--刷新碎片数量
function WeaponData:onResetFragments(tData)
	-- body
	if not tData then return end
	local tInfo = self:createFragmentInfo(tData.f)
	self.tFragmentsList[tInfo.nWeaponId] = tInfo
end 

---获得神兵碎片列表
function WeaponData:getFragmentsList()
	-- body
	return self.tFragmentsList
end


--获取神兵增加的属性和属性值(id,等级,进阶级)
function WeaponData:getWeaponAttribute(_wId, _wLv, _wAdLv)
	if not _wId or not _wLv or not _wAdLv then
		return
	end
	-- body
	--神兵等级信息
	local tLvData = getWeaponLvData(_wId, _wLv)
	--神兵进阶信息
	local tAdData = getWeaponAdData(_wId, _wAdLv)

	local tAttrData = {}
	--属性增加值(基础值加进阶值)
	local nAttack = 0
	if not tLvData then return end
	if tLvData.tAttribute then
		for attrid, attrValue in pairs(tLvData.tAttribute) do
			tAttrData = getBaseAttData(attrid)
			nAttack = nAttack + attrValue
		end
	end
	if tAdData.tAttribute then
		for _, attrValue in pairs(tAdData.tAttribute) do
			nAttack = nAttack + attrValue
		end
	end
	return tAttrData.sName, nAttack
end

--神兵是否可升级
function WeaponData:isWeaponCanLeveUp(_wId)
	local weapon = self:getWeaponInfoById(_wId)
	if not weapon then
		return false
	end
	local wLv = weapon.nWeaponLv
	if not wLv or wLv <= 0 then
		return false
	end

	if self:isWeaponCanAdvance(_wId) then
		return false
	end

	--神兵等级信息
	local tLvData = getWeaponLvData(_wId, wLv)
	--材料是否足够
	local nIndex = 0
	local nNeedNum, nHasNum, tGoods
	for nId, need in pairs(tLvData.tCosts) do
		local tGoods = getGoodsByTidFromDB(nId)
		if tGoods then
			local nHasNum = getMyGoodsCnt(nId)
			if nHasNum >= need then
				nIndex = nIndex + 1
			else
				return false 
			end
		else
			return false
		end
	end
	if nIndex > 0 and nIndex == table.nums(tLvData.tCosts) then  --升级材料足够
		--判读是否达到主公等级限制
		if weapon.nWeaponLv < Player:getPlayerInfo().nLv then
			return true
		else 
			return false 
		end
	end
	return false
end

--神兵是否可进阶
function WeaponData:isWeaponCanAdvance(_wId)
	local weapon = self:getWeaponInfoById(_wId)
	if not weapon then
		return false
	end
	local wLv = weapon.nWeaponLv
	local nALv = weapon.nAdvanceLv
	if not wLv or wLv <= 0 then
		return false
	end
	--神兵进阶信息
	local tAdData = getWeaponAdData(_wId, nALv)
	if not tAdData then return false end
	if wLv == tAdData.toplv and tAdData.canadv == 1 and weapon.nAdvanceCnt <= tAdData.section then

		return true
	end
	return false
end

--神兵等级是否已满
function WeaponData:isWeaponFullLv(_wId)
	-- body
	local weapon = self:getWeaponInfoById(_wId)
	if not weapon then
		return false
	end
	local wLv = weapon.nWeaponLv
	if not wLv or wLv <= 0 then
		return false
	end
	--神兵进阶信息
	local tAdData = getWeaponAdData(_wId, weapon.nAdvanceCnt)
	if wLv == tAdData.toplv and tAdData.canadv ~= 1 then
		return true
	else
		return false
	end
end

--判断神兵是否有足够材料进阶
--nId 神兵ID
--_nLv 神兵进阶等级
function WeaponData:isCanAdvance( _nId,_nLv)
	if not _nId or not _nLv then
		return false 
	end
	--拿到进阶消耗
	local tCost = getWeaponAdData(_nId, _nLv)
	local nIndex = 0
	for id,num in pairs(tCost.tCosts or {}) do
	
		--获取玩家身上拥有的材料数量
		local nHas = getMyGoodsCnt(id)
		if nHas >= num then
			nIndex = nIndex + 1
		else
			return false 
		end
	end
	if nIndex > 0 and nIndex == table.nums(tCost.tCosts) then
		return true
	end
	return false 
	
end

--主界面底部神器红点
function WeaponData:getHomeMenuRedNum()
	-- body
	local nRedNum = 0
	local tWeaponList = self:getAllWeaponDatas()
	local tFragments = self:getFragmentsList()
	local roleLevel = Player:getPlayerInfo().nLv
	for nId, v in pairs(tWeaponList) do
		local bCanUpgrade = self:isWeaponCanLeveUp(nId)
		--未打造的神器中有已解锁的神器显示红点
		--神器可升级显示红点
		if (roleLevel >= v.nMakeLv) and ((v.nWeaponLv < 1 and tFragments[nId]) or bCanUpgrade) then
			nRedNum = nRedNum + 1
		end
	end
	return nRedNum
end


return WeaponData
