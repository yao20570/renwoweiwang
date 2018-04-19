----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-27 11:18:33
-- Description: 装备数据
-----------------------------------------------------
local EquipVo = require("app.layer.equip.data.EquipVo")
local TrainAtbVo = require("app.layer.equip.data.TrainAtbVo")
local MakeVo = require("app.layer.equip.data.MakeVo")

e_type_equip = {
	weapon = 1 	,--枪
	horse = 2 	,--剑
	clothes = 3 ,--甲
	helmet =4 	,--盔
	yin = 5 	,--书
	fu = 6 		,--印
}

--装备状态消息（1。未打造，2打造中，3打造完毕）
e_state_equip_make = {
	idle = 1,
	make = 2,
	finish = 3
}

--功能类型
n_func_type = {
	strengthen 		= 1, 		--强化
	train 			= 2 		--洗炼
}

--铁匠铺功能类型
n_smith_func_type = {
	build 			= 1, 		--打造
	strengthen 		= 2, 		--强化
	train 			= 3 		--洗炼
}

--装备数据
local EquipData = class("EquipData")

function EquipData:ctor(  )
	self.nEquipMakeState = nil
	self.tEquipVos = {}
end

function EquipData:release(  )
end

function EquipData:createEquipVo( tData )
	if not tData then
		return
	end
	return EquipVo.new(tData)
end

function EquipData:updateEquipVo( tData )
	if not tData then
		return
	end
	local sUuid = tData.u
	if self.tEquipVos[sUuid] then
		self.tEquipVos[sUuid]:update(tData)
	end
	-- self:sendIdleEquipFullMsg()
end

function EquipData:createEquipVos( tData )
	if not tData then
		return
	end
	self.tEquipVos = {}
	for k,v in pairs(tData) do
		local tEquipVo = self:createEquipVo(v)
		self.tEquipVos[tEquipVo.sUuid] = tEquipVo
	end
end

function EquipData:createMakeVo( tData )
	if not tData then
		self.tMakeVo = nil --重连时候需要
		return
	end
	self.tMakeVo = MakeVo.new(tData)
end

function EquipData:updateMakeVo( tData )
	if not tData then
		return
	end
	if self.tMakeVo then
		self.tMakeVo:update(tData)
	else
		self.tMakeVo = MakeVo.new(tData)
	end
end

function EquipData:updateEquipVos( tData, bNoFullTip )
	if not tData then
		return
	end

	for i=1,#tData do
		local sUuid = tData[i].u
		if self.tEquipVos[sUuid] then
			self:updateEquipVo(tData[i])
		else
			--获取新装备要加标设置
			self.tEquipVos[sUuid] = EquipVo.new(tData[i])
			self.tEquipVos[sUuid]:setIsNew(true)
		end
	end
	if not bNoFullTip then
		-- self:sendIdleEquipFullMsg()
	end
end

--根据uuid刷新装备
function EquipData:updateEquipById( tData )
	-- body
	if not tData then return end
	local tEquipVo = tData.e
	local sUuid = tEquipVo.u
	self.tEquipVos[sUuid] = EquipVo.new(tEquipVo)
	self.tEquipVos[sUuid]:setIsNew(true)
	-- self:sendIdleEquipFullMsg()
	--是否激活隐藏属性(1激活 0否)
	if tData.a == 1 then
		local tObject = {}
		tObject.nType = e_dlg_index.dlgequipfullattr --dlg类型
		tObject.nId   = sUuid                        --装备的uuid
		sendMsg(ghd_show_dlg_by_type,tObject)
		TOAST(getTipsByIndex(528))
	end
end

--[7000]加载玩家装备数据
function EquipData:onReqEquipLoad( tData )
	if not tData then
		return
	end
	self:createEquipVos(tData.es)	--Set<EquipVo>	所有装备数据
	self.nCapacity = tData.c	--int	装备容量
	self.nBoughtCount = tData.b	--int	装备容量购买次数
	self:setFreeTrain(tData.ft)	--Integer	免费洗炼次数
	self:setFreeTrainCd(tData.cd) --Long	免费洗炼恢复次数CD时间
	self:setSmithId(tData.si)	--Integer	雇佣的铁匠ID
	self:setSmithIsFree(tData.sg)	--Integer	铁匠是否是免费雇佣的
	self:setSmithRemainCd(tData.sw)--Long	雇佣的铁匠工作剩余时间
	self:createMakeVo(tData.m)	--MakeVo	装备打造

end

--设置免费洗炼次数
function EquipData:setFreeTrain( tData )
	self.nPreTimes = self.nFreeTrain
	self.nFreeTrain = tData
	if tData ~= self.nPreTimes then
		sendMsg(ghd_equip_refine_times_change)
	end
end

--免费洗炼恢复次数CD时间
function EquipData:setFreeTrainCd( nCd )
	self.nFreeTrainCd = nCd
	self.nFreeTrainCdSystemTime = getSystemTime()
end

--[-7001]装备数据变化推送
function EquipData:onPushEquipChange( tData )
	if not tData then
		return
	end
	self:updateEquipVos(tData.es)
end

--[7002]装备恢复免费洗炼次数
function EquipData:onRefreshEquipFreeTrain( tData )
	if not tData then
		return
	end
	self:setFreeTrain(tData.ft)	--Integer	免费洗炼次数
	self:setFreeTrainCd(tData.cd) --Long	免费洗炼恢复次数CD时间)
end

--[7003]装备洗炼
function EquipData:onReqEquipTrain( tData )
	if not tData then
		return
	end
	self:updateEquipVo(tData.e) --EquipVo	洗炼后的装备属性
	local bIsCrit = tData.c == 1 --Integer	洗炼是否暴击
	local nUpLv = tData.l	--Integer	洗炼提升的等级
	self:setFreeTrain(tData.ft)	--Integer	免费洗炼次数
	self:setFreeTrainCd(tData.cd) --Long	免费洗炼恢复次数CD时间
end

--[7004]装备高级洗炼
function EquipData:onReqEquipHighTrain( tData )
	if not tData then
		return
	end
	self:updateEquipVo(tData.e)	--EquipVo	洗炼后的装备属性
end

--[7005]穿上装备
function EquipData:onReqEquipWear( tData )
	if not tData then
		return
	end
	self:updateEquipVos(tData.es)
	if tData.es then
		local tDatas = tData.es
		for i=1,#tDatas do
			local sUuid = tDatas[i].u
			if self.tEquipVos[sUuid] then
				self.tEquipVos[sUuid]:setIsNew(false)
			end
		end
	end
end

--[7006]解下装备
function EquipData:onReqEquipTakeOff( tData )
	if not tData then
		return
	end
	local bNoFullTip = true
	self:updateEquipVos(tData.es, bNoFullTip)
end

--[7007]购买装备容量
function EquipData:onReqEquipCapacity( tData )
	if not tData then
		return
	end
	self.nCapacity = tData.c	--int	装备容量
	self.nBoughtCount = tData.b	--int	装备容量购买次数
end

--[7008]打造装备
function EquipData:onReqEquipMake( tData )
	if not tData then
		return
	end
	self:updateMakeVo(tData.m)	--MakeVo	装备打造
end

--[7009]雇佣铁匠
function EquipData:onReqSmithHire( tData )
	if not tData then
		return
	end
	self.nSmithLv = tData.si --int	雇佣的铁匠等级
	self:setSmithRemainCd(tData.sw) --long	雇佣的铁匠工作剩余时间
end


--设置铁匠剩余cd时间
function EquipData:setSmithRemainCd( nCd )
	self.nSmithRemainCd = nCd 
	self.nSmithRemainCdSystemTime = getSystemTime()
end

--[7010]铁匠加速打造
function EquipData:onReqMakeQuick( tData )
	if not tData then
		return
	end
	self:updateMakeVo(tData.m)	--MakeVo	装备打造
end

--[7011]金币加速完成装备打造
function EquipData:onReqMakeQuickByCoin( tData )
	if not tData then
		return
	end
	self:updateMakeVo(tData.m)	--MakeVo	装备打造
end

--[7012]领取打造的装备
function EquipData:onReqEquipGet(  )
	if not self.tMakeVo then
		return
	end
	--播放获取特效
	local tItemList = {
		{k = self.tMakeVo.nId, v = 1},
	}
	showGetAllItems(tItemList)
	--清除数据
	self.tMakeVo = nil
end

--[7013]分解装备
--sUuid:装备的唯一id
function EquipData:onReqEquipDecompose( tData, sUuid )
	if self.tEquipVos and self.tEquipVos[sUuid] then
		self.tEquipVos[sUuid] = nil
	end

	if not tData then
		return
	end
	-- ds	List<Pair<Integer,Long>>	分解后获得的补偿
end


--获取当前装备打造的vo
function EquipData:getMakeVo(  )
	return self.tMakeVo
end


--获取当前装备打造的id(装备配表Id)
function EquipData:getCurrMakingId()
	if self.tMakeVo then
		return self.tMakeVo.nId
	end
	return nil
end

--获取铁匠id
function EquipData:getSmithId()
	return self.nSmithId
end

--获取雇佣中的铁匠是否是免费的
function EquipData:getIsSmithFree()
	return self.bSmithFree
end

--设置铁匠id
function EquipData:setSmithId( nSmithId, bisfree )
	self.nSmithId = nSmithId
end

--设置铁匠是否是免费雇佣的(0免费, 1使用黄金)
function EquipData:setSmithIsFree( nfree )
	self.bSmithFree = nfree == 0
end

--获取铁匠基础数据
function EquipData:getSmithConfigData( )
	if self:getSmithRemainCd() <= 0 or not self.nSmithId then
		return nil
	end
	return getBlackSmithByID(self.nSmithId)
end

--获取铁匠剩余工作时间
function EquipData:getSmithRemainCd(  )
	if self.nSmithRemainCd and self.nSmithRemainCd > 0 then
		local fCurTime = getSystemTime()
		local fLeft = self.nSmithRemainCd - (fCurTime - self.nSmithRemainCdSystemTime)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end
end

--判断当前是否有铁匠
function EquipData:getIsHasSmith(  )
	if self.nSmithId and self:getSmithRemainCd() > 0 then
		return true
	end
	return false
end

--判断打造是否可以加速
function EquipData:getIsCanSpeed(  )
	if self.tMakeVo then
		if self:getIsHasSmith() and self.nSmithId > self.tMakeVo.nSpeed then
			return true
		end
	end
	return false
end

--根据武将id获取装备vo以类型划分
--nHeroId 武将id
function EquipData:getEquipVosByKindInHero( nHeroId )
	local tRes = {}
	if self.tEquipVos then
		for k,v in pairs(self.tEquipVos) do
			if v.nHeroId == nHeroId then
				local tEquip = getBaseEquipDataByID(v.nId)
				if tEquip then
					tRes[tEquip.nKind] = v
				end
			end
		end
	end
	return tRes
end

--根据武将id获取装备vo
--nHeroId 武将id
function EquipData:getEquipVosByHero( nHeroId )
	local tRes = {}
	if self.tEquipVos then
		for k,v in pairs(self.tEquipVos) do
			if v.nHeroId == nHeroId then
				tRes[k] = v
			end
		end
	end
	return tRes
end

--通过武将类型和武将位获取该武将位装备vo
--_tHeroList:武将列表, _nPos:武将位
function EquipData:getEquipVosByPos(_tHeroList, _nPos)
	-- local _tHeroList = Player:getHeroInfo():getHeroOnlineQueueByTeam(_nTeamType)
	for k, v in ipairs(_tHeroList) do
		if k == _nPos then
			return self:getEquipVosByHero(v.nId)
		end
	end
end

--根据装备种类获取空闲装备vo
function EquipData:getIdleEquipVosByKind( nKind )
	local tRes = {}
	if self.tEquipVos then
		for k,v in pairs(self.tEquipVos) do
			if v.nHeroId == 0 then
				local tEquipData = v:getConfigData()
				if tEquipData then
					if tEquipData.nKind == nKind then
						table.insert(tRes, v)
					end
				end
			end
		end
	end
	--(装备品质，洗炼属性等级总和，表格id降序)
	table.sort(tRes, function(a, b)
		return self:getEquipIsBetter(a, b)
	end)
	return tRes
end

--获取所有空闲装备vo
function EquipData:getIdleEquipVos(  )
	local tRes = {}
	if self.tEquipVos then
		for k,v in pairs(self.tEquipVos) do
			if v:getIsIdle() then
				table.insert(tRes, v)
			end
		end
	end
	--(装备品质，洗炼属性等级总和，表格id降序)
	table.sort(tRes, function(a, b)
		return self:getEquipIsBetter(a, b)
	end)
	return tRes
end

--设置空闲装备非新
function EquipData:setIdleEquipNoNew(  )
	-- body
	local tRes = self:getIdleEquipVos()
	for k, v in pairs(tRes) do
		v:setIsNew(false)
	end
	--刷新主界面菜单红点
	sendMsg(ghd_item_home_menu_red_msg)
end

--获取装备容量上限
function EquipData:getEquipCapacityMax(  )
	return self.nCapacity or 0
end

--获取装备空闲数量
function EquipData:getEquipIdleNum(  )
	local nNum = 0
	if self.tEquipVos then
		for k,v in pairs(self.tEquipVos) do
			if v:getIsIdle() then
				nNum = nNum + 1
			end
		end
	end
	return nNum
end

--根据品质和类型获取拥有的装备数量
--type 0-全部，1-枪，2-剑，3-甲，4-盔，5-书，6-印
--quality
function EquipData:getQualityCountByType( type , quality)
	local nCount = 0
	if not quality then
		return 0
	end
	for k, v in pairs (self.tEquipVos) do
		if quality == v:getQuality() then
			if type == 0 then
				nCount = nCount + 1
			else
				if type == v:getKind() then
					nCount = nCount + 1
				end
			end
		end
	end
	return nCount
end

--比较两件装备哪一件好
--return true 就是tEquipVoA好，反之tEquipVoB好
function EquipData:getEquipIsBetter( tEquipVoA, tEquipVoB)
	local tEquipDataA = tEquipVoA:getConfigData()
	local tEquipDataB = tEquipVoB:getConfigData()
	if not tEquipDataA or not tEquipDataB then
		return false
	end
	local nQualityA = tEquipDataA.nQuality
	local nQualityB = tEquipDataB.nQuality
	if nQualityA == nQualityB then
		local nLvA = tEquipVoA:getCurrAttrLvTotal()
		local nLvB = tEquipVoB:getCurrAttrLvTotal()
		if nLvA == nLvB then
			return tEquipDataA.sTid > tEquipDataB.sTid
		else
			return nLvA > nLvB
		end
	else
		return nQualityA > nQualityB
	end
end

--获取免费洗炼次数
function EquipData:getFreeTrain(  )
	return self.nFreeTrain or 0
end

--某装备是否可洗练
function EquipData:isCanRefine(tEquipVo)
	-- body
	local tEquip = getBaseEquipDataByID(tEquipVo.nId)
	--洗炼次数
	local nTrainFree = self:getFreeTrain()
	--当前洗炼属性是否已满
	local bLvMax = tEquipVo:getIsCurrRefineLvMax()
	--是否激活了隐藏属性
	local bHasHideAttr = tEquipVo:getIsHasHiddenTAVo()

	if bLvMax then
		--紫色装备品质及紫色以上装备激活了隐藏属性就不可洗炼
		if tEquip.nQuality > 3 then
			if bHasHideAttr then
				return false
			end
		--紫色以下洗炼属性已满就不可洗炼
		else
			return false
		end
	end
	if tEquip.nQuality > 1 and nTrainFree > 0 then --需要考虑属性已满的情况
		return true
	end
	return false
end

--免费洗炼恢复次数CD时间
function EquipData:getFreeTrainCd(  )
	if self.nFreeTrainCd and self.nFreeTrainCd > 0 then
		local fCurTime = getSystemTime()
		local fLeft = self.nFreeTrainCd - (fCurTime - self.nFreeTrainCdSystemTime)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end
end

--获取免费洗炼次数是否已满
function EquipData:getIsFreenTrainFull( )
	return self:getFreeTrain() >= getEquipInitParam("trainFreeMax")
end

--根据装备uuid返回EquipVo
function EquipData:getEquipVoByUuid( sUuid )
	return self.tEquipVos[sUuid]
end

--获取所有装备vos
function EquipData:getEquipVos( )
	return self.tEquipVos
end

--获取武将更好的穿戴装备(装备品质，洗炼属性等级总和，表格id降序)
--nHeroId 武将id
--bHasCurEquip:如果为true,代表只取比已穿戴装备更好的装备,而不包括没有穿戴的装备
function EquipData:getHeroBetterEquipVos( nHeroId, bHasCurEquip )
	local tRes = {}
	local tCurrEquipVos = self:getEquipVosByKindInHero(nHeroId)
	for k,nKind in pairs(e_type_equip) do
		local tIdleEquipVos = self:getIdleEquipVosByKind(nKind)
		local tCurrEquipVo = tCurrEquipVos[nKind]
		local tBetterEquipVo = tIdleEquipVos[1]
		if tBetterEquipVo then
			if tCurrEquipVo == nil then
				if not bHasCurEquip then
					table.insert(tRes, tBetterEquipVo)
				end
			else
				if self:getEquipIsBetter(tBetterEquipVo, tCurrEquipVo) then
					table.insert(tRes, tBetterEquipVo)
				end
			end
		end
	end
	return tRes
end

--获取是否有更好的穿戴装备
function EquipData:getIsHasBetterEquip( nHeroId, bHasCurEquip )
	local tEquipVos = self:getHeroBetterEquipVos(nHeroId, bHasCurEquip)
	return #tEquipVos > 0
end

--获取是否打造装备完毕
function EquipData:getIsFinishMakeEquip(  )
	if self.tMakeVo then
		return self.tMakeVo:getCd() == 0
	end
	return false
end

--更新打造装备倒计时
function EquipData:updateMakeEquipCd()
	--打造cd时间
	--三种状态（1。未打造，2打造中，3打造完毕）
	local nEquipMakeState = e_state_equip_make.idle
	if self.tMakeVo then
		local nCd = self.tMakeVo:getCd()
		if nCd > 0 then
			nEquipMakeState = e_state_equip_make.make
			self.bToasted = false
		else
			nEquipMakeState = e_state_equip_make.finish
		end
	end
	--发送消息更新界面
	if self.nEquipMakeState ~= nEquipMakeState then
		self.nEquipMakeState = nEquipMakeState
		sendMsg(gud_equip_makevo_refresh_msg)
	end
	if self.nEquipMakeState == e_state_equip_make.finish then
		if not self.bToasted then
			local pEquip = getGoodsByTidFromDB(self.tMakeVo.nId)
			local tObject = {}
			tObject.tEquipData = pEquip
			sendMsg(ghd_equip_make_finish_msg, tObject)
			self.bToasted = true
		end
	else
		self.bToasted = false
	end
end

--将全部的装备设置为非
--nKind:指定类型
function EquipData:setEquipVosNoNew( nKind )
	if self.tEquipVos then
		for k,v in pairs(self.tEquipVos) do
			if nKind then
				local tEquipData = v:getConfigData()
				if tEquipData then
					if tEquipData.nKind == nKind then
						v:setIsNew(false)
					end
				end
			else
				v:setIsNew(false)
			end
		end
	end
end

--判断铁匠id是否可以免费雇用
function EquipData:getIsCanFreeHire( nSmithId )
	if self.nSmithId == nSmithId then --之前已经调用
		return false
	end

	--皇宫等级
	local buildLv = Player:getBuildData():getBuildById(e_build_ids.palace).nLv
	local buildBlackSmith = getBuildBlackSmith()  
    table.sort(buildBlackSmith, function (a, b)
        return a.palacelevel < b.palacelevel
    end)
    --当前可以开启的雇用铁匠数据
    local tSmithData = nil
    local nCount = #buildBlackSmith
    for i=1,nCount do
    	local tSmithData2 = buildBlackSmith[i]
    	if tSmithData2.palacelevel <= buildLv then
            tSmithData = tSmithData2
        end
    end
    if tSmithData then
    	if tSmithData.id == nSmithId then
    		return true
    	end
    end

    return false
end

--根据装备id获取装备数量
--nEquipId装备表格id
function EquipData:getCntByEquipId( nEquipId )
	local nCnt = 0
	if self.tEquipVos then
		for k,v in pairs(self.tEquipVos) do
			local tEquipData = v:getConfigData()
			if tEquipData then
				if tEquipData.sTid == nEquipId then
					nCnt = nCnt + 1
				end
			end
		end
	end
	return nCnt
end

--获取有打造权限的最高品质的装备id
function EquipData:getCanMakeBestEquipIds(  )
	local tBestEquipDatas = {}
	local nQualityMax = getEquipQualityMax()
	for i=1, nQualityMax do
		local tEquipDatas = getEquipsInSmith(i)
		for j=1,#tEquipDatas do
			if Player:getPlayerInfo().nLv >= tEquipDatas[j].nMakeLv then
				local tEquipData = tEquipDatas[j]
				local nEquipType = tEquipData.nType
				if tBestEquipDatas[nEquipType] then
					if tEquipData.nQuality > tBestEquipDatas[nEquipType].nQuality then
						tBestEquipDatas[nEquipType] = tEquipData
					end
				else
					tBestEquipDatas[nEquipType] = tEquipData
				end
			end
		end
	end
	local tBestEquipDataIds = {}
	for k,v in pairs(tBestEquipDatas) do
		tBestEquipDataIds[v.sTid] = v.sTid
	end
	return tBestEquipDataIds
end

--空闲装备满时发送消息
function EquipData:sendIdleEquipFullMsg(  )
	if self:getEquipIdleNum() > self:getEquipCapacityMax() then
		sendMsg(ghd_equipBag_fulled_msg)
	end
end

--装备是否即将满(_nEquip:即将要放入背包的装备个数)
function EquipData:isEquipWillFull(_nEquip)
	-- body
	if (_nEquip + self:getEquipIdleNum()) > self:getEquipCapacityMax() then
		return true
	end
	return false
end

--装备所有装备新的数量
function EquipData:getEquipVosNewCnt( )
	local nCnt = 0
	for k,v in pairs(self.tEquipVos) do
		if v:getIsNew() then
			nCnt = nCnt + 1
		end
	end
	return nCnt
end
--获取所有空前装备的新品数量
function EquipData:getIdleEquipVosNewCnt(  )
	-- body	
	local nCnt = 0
	local tIdleEquips = self:getIdleEquipVos()
	if tIdleEquips and #tIdleEquips > 0 then
		for k,v in pairs(tIdleEquips) do
			if v:getIsNew() then
				nCnt = nCnt + 1
			end
		end
	end
	return nCnt
end

--进阶后删除该武将上的装备数据
--tData: 装备id列表
function EquipData:delEquipList( tData )
	if not tData then
		return
	end
	for i=1,#tData do
		local sUuid = tData[i]
		if self.tEquipVos[sUuid] then
			self.tEquipVos[sUuid] = nil
		end
	end
	--发送武将装备发生改变
	sendMsg(gud_equip_hero_equip_change)
end


------------------------强化相关------------------------
--[7014]装备强化
function EquipData:onReqEquipStrengthen(tData, _sUuid)
	-- body
	if not tData then
		return
	end
	self:updateEquipVo(tData.e) --EquipVo	强化后的后的装备属性
	sendMsg(gud_equip_strength_msg)
end

--该品质装备强化等级是否已满
--_nQuality: 品质, 
--_nLv: 装备强化等级
function EquipData:getIsStrengthenFull(_nQuality, _nLv)
	-- body
	local strLimit = getEquipInitParam("strlimit")
	local tParam = luaSplitMuilt(strLimit, ";", ":")
	for k, v in pairs(tParam) do
		if tonumber(v[1]) == _nQuality then
			if _nLv >= tonumber(v[2]) then
				return true
			end
		end
	end
	return false
end

--获取每个祝福石的提升概率
function EquipData:getPerStoneProb()
	-- body
	local fProb = getEquipInitParam("stoneprob")
	if fProb then
		return fProb*100
	end
	return 0
end

--某装备是否可强化
function EquipData:isCanStrengthen(tEquipVo)
	local tEquip = getBaseEquipDataByID(tEquipVo.nId)
	local nQuality = tEquip.nQuality
	local nStrenLv = tEquipVo.nStrenthLv
	--当前强化等级是否已满
	local bLvMax = self:getIsStrengthenFull(nQuality, nStrenLv)
	if bLvMax then
		return false
	end
	--配表数据
	local tStrenConf = getEquipStrengthInfo(nQuality, nStrenLv + 1)
	--如果是消耗突破石, 判断突破石是否足够
	if tStrenConf.stone and tStrenConf.stone > 0 then
		local nHasStrenStone = getMyGoodsCnt(e_item_ids.strengthstone)
		if nHasStrenStone >= tStrenConf.stone then
			return true
		end
	else
		if tStrenConf.resources then
			local tCostRes = luaSplitMuilt(tStrenConf.resources, ";", ":")
			for k, v in pairs(tCostRes) do
				if getMyGoodsCnt(tonumber(v[1])) < tonumber(v[2]) then
					return false
				end
			end
			return true
		end
	end
	return false
end


return EquipData