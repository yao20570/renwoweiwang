local EquipVo = class("EquipVo")

function EquipVo:ctor( tData )
	self.tTrainAtbVos = {}
	self.bIsNew = false
	self.nStrenthLv = 0 --强化等级
	self:update(tData)
end

function EquipVo:update( tData )
	if not tData then
		return
	end

	self.nId = tData.i or self.nId 									--Integer	装备的ID(配置id)
	self.sUuid = tData.u 											--String	装备的UUID(唯一id)
	self:createTrainAtbVos(tData.ns) 								--List<TrainAtbVo>	装备的普通洗炼属性
	self:createTrainAtbVo(tData.h)     	    					    --TrainAtbVo	装备的隐藏洗炼属性
	self.nHeroId = tData.w or self.nHeroId 							--Integer	装备穿在哪个武将身上
	self.nStrenthLv = tData.sl or self.nStrenthLv					--Integer 装备的强化等级
	self.tStrenthCost = tData.sc or self.tStrenthCost				--Integer 装备的强化消耗

	--自定义数据
	--洗炼星星明亮列表
	local tStarDarkLights = {}
	local tTrainAtbVos = self:getTrainAtbVos()
	for i=1,#tTrainAtbVos do
		table.insert(tStarDarkLights, tTrainAtbVos[i]:getIsLvMax())
	end
	self.tStarDarkLights = nil
	self.tStarDarkLights = tStarDarkLights
end

function EquipVo:getConfigData( )
	return getBaseEquipDataByID(self.nId)
end

--获取当前洗炼属性等级总和
function EquipVo:getCurrAttrLvTotal( )
	local nLv = 0
	if self.tTrainAtbVos then
		for i=1,#self.tTrainAtbVos do
			nLv = nLv + self.tTrainAtbVos[i].nLv
		end
	end
	if self.tHiddenTAVo then
		nLv = nLv + self.tHiddenTAVo.nLv
	end
	return nLv
end

--获取当前洗炼属性等级总和上限
function EquipVo:getCurrAttrLvTotalMax()
	local nLv = 0

	local tEquipData = self:getConfigData()
	if tEquipData then 
		if self.tTrainAtbVos then
			nLv = nLv + tEquipData.nTrainLvTop * #self.tTrainAtbVos
		end
		if self.tHiddenTAVo then
			nLv = nLv + tEquipData.nTrainLvTop
		end
	end
	return nLv
end

--判断当前洗炼属性是否已满
function EquipVo:getIsCurrRefineLvMax( )
	local tTrainAtbVos = self:getTrainAtbVos()
	for i=1,#tTrainAtbVos do
		if not tTrainAtbVos[i]:getIsLvMax() then
			return false
		end
	end
	return true
end

--判断是不是可以高级洗炼
function EquipVo:getIsCanHighRefine( )
	if self:getIsCurrRefineLvMax() then
		local tTrainAtbVos = self:getTrainAtbVos()
		return #tTrainAtbVos >= 3
	end
	return false
end

--判断是否全属性一致
function EquipVo:getIsAllTrainAtbSame( )
	local tTrainAtbVos = self:getTrainAtbVos()
	local nPrevAttrId = nil
	for i=1,#tTrainAtbVos do
		local nAttrId = tTrainAtbVos[i]:getAttrId()
		if nPrevAttrId and nPrevAttrId ~= nAttrId then
			return false
		else
			nPrevAttrId = nAttrId
		end
	end
	return true
end


function EquipVo:createTrainAtbVos( tData )
	if not tData then
		return
	end
	local TrainAtbVo = require("app.layer.equip.data.TrainAtbVo")
	local nPrevCount = #self.tTrainAtbVos
	local nCurrCount = #tData
	if nPrevCount > nCurrCount then
		local nSubCount = nPrevCount - nCurrCount
		for i=1,nSubCount do
			table.remove(self.tTrainAtbVos)
		end
	end

	for i=1,#tData do
		if self.tTrainAtbVos[i] then
			self.tTrainAtbVos[i]:setEquipId(self.nId)
			self.tTrainAtbVos[i]:update(tData[i])
		else
			table.insert(self.tTrainAtbVos, TrainAtbVo.new(tData[i], self.nId))
		end
	end
end

function EquipVo:createTrainAtbVo( tData )
	if not tData then
		self.tHiddenTAVo = nil
		return
	end
	if self.tHiddenTAVo then
		self.tHiddenTAVo:setEquipId(self.nId)
		self.tHiddenTAVo:update(tData)
	else
		local TrainAtbVo = require("app.layer.equip.data.TrainAtbVo")
		self.tHiddenTAVo =  TrainAtbVo.new(tData, self.nId)
	end
end

--洗炼vo列表,用于背包模块的装备显示
function EquipVo:getTrainAtbVos( )
	local tTrainAtbVos = {}
	if self.tTrainAtbVos then
		for i=1,#self.tTrainAtbVos do
			table.insert(tTrainAtbVos, self.tTrainAtbVos[i])
		end
	end
	if self.tHiddenTAVo then
		table.insert(tTrainAtbVos, self.tHiddenTAVo)
	end
	return tTrainAtbVos
end

--获取装备上的所有属性(基础、洗炼、强化属性)
function EquipVo:getEquipAllAttrs()
	--装备的洗炼属性
	local tTrainAtbVos = copyTab(self:getTrainAtbVos())
	local tEquipData = getBaseEquipDataByID(self.nId)
	--装备的基础属性
	local sAttr = luaSplit(tEquipData.sAttributes, ":")
	local bFind = false
	for k, v in pairs(tTrainAtbVos) do
		if v.nAttrId == tonumber(sAttr[1]) then
			v.nAttrValue = v.nAttrValue + tonumber(sAttr[2])
			bFind = true
		end
	end
	if not bFind then
		table.insert(tTrainAtbVos, {nAttrId = tonumber(sAttr[1]), nAttrValue = tonumber(sAttr[2])})
	end
	--装备的强化属性
	local tStrenAttr = self:getStrengthAttrs()
	if tStrenAttr then
		bFind = false
		for k, v in pairs(tTrainAtbVos) do
			if v.nAttrId == tStrenAttr.nAttrId then
				v.nAttrValue = v.nAttrValue + tStrenAttr.nAttrValue
				bFind = true
			end
		end
		if not bFind then
			table.insert(tTrainAtbVos, tStrenAttr)
		end
	end
	return tTrainAtbVos
end

--获取装备上的战力
function EquipVo:getEquipPower()
	--装备的洗炼属性
	local tTrainAtbVos = self:getEquipAllAttrs()
	local nEquipPower = 0
	for k, v in pairs(tTrainAtbVos) do
		if v.nAttrId == e_id_hero_att.gongji then
			nEquipPower = nEquipPower + v.nAttrValue * tonumber(getGlobleParam("scoreAtk"))
		elseif v.nAttrId == e_id_hero_att.fangyu then
			nEquipPower = nEquipPower + v.nAttrValue * tonumber(getGlobleParam("scoreDef"))
		elseif v.nAttrId == e_id_hero_att.bingli then
			nEquipPower = nEquipPower + v.nAttrValue * tonumber(getGlobleParam("scoreTrp"))
		elseif v.nAttrId == e_id_hero_att.mingzhong then
			nEquipPower = nEquipPower + v.nAttrValue * tonumber(getGlobleParam("scoreHit"))
		elseif v.nAttrId == e_id_hero_att.shanbi then
			nEquipPower = nEquipPower + v.nAttrValue * tonumber(getGlobleParam("scoreDod"))
		elseif v.nAttrId == e_id_hero_att.baoji then
			nEquipPower = nEquipPower + v.nAttrValue * tonumber(getGlobleParam("scoreCri"))
		elseif v.nAttrId == e_id_hero_att.jianyi then
			nEquipPower = nEquipPower + v.nAttrValue * tonumber(getGlobleParam("scoreTou"))
		elseif v.nAttrId == e_id_hero_att.qianggong then
			nEquipPower = nEquipPower + v.nAttrValue * tonumber(getGlobleParam("scoreSatk"))
		elseif v.nAttrId == e_id_hero_att.qiangfang then
			nEquipPower = nEquipPower + v.nAttrValue * tonumber(getGlobleParam("scoreSdef"))
		elseif v.nAttrId == e_id_hero_att.gongcheng then
			nEquipPower = nEquipPower + v.nAttrValue * tonumber(getGlobleParam("scoreSiege"))
		elseif v.nAttrId == e_id_hero_att.shoucheng then
			nEquipPower = nEquipPower + v.nAttrValue * tonumber(getGlobleParam("scoreDefCt"))
		end
	end
	return nEquipPower
end

--获取装备上的兵力属性值
function EquipVo:getEquipBingliValue()
	local tTrainAtbVos = self:getEquipAllAttrs()
	local nValue = 0
	for k, v in pairs(tTrainAtbVos) do
		if v.nAttrId == e_id_hero_att.bingli then
			nValue = nValue + v.nAttrValue * tonumber(getGlobleParam("scoreTrp"))
			break
		end
	end
	return nValue
end

--获取装备的强化属性
function EquipVo:getStrengthAttrs()
	-- body
	if self.nStrenthLv == 0 then
		return
	end
	local tEquip = getBaseEquipDataByID(self.nId)
	if not tEquip then
		return
	end
	local tStrenAttr = {}
	local tStrenConf = getEquipStrengthInfo(tEquip.nQuality, self.nStrenthLv)
	if tStrenConf then
		local tParam = luaSplitMuilt(tStrenConf.attr, "|", ",")
		for k, pa in pairs(tParam) do
			if tonumber(pa[1]) == tEquip.nKind then
				local tAttr = luaSplit(pa[2], ":")
				tStrenAttr.nAttrId = tonumber(tAttr[1])
				tStrenAttr.nAttrValue = tonumber(tAttr[2])
				break
			end
		end
	end

	return tStrenAttr
end

--获取洗炼属性星星暗亮列表
function EquipVo:getStarDarkLights()
	return self.tStarDarkLights
end

--设置是否显示新标识
function EquipVo:setIsNew( bIsNew )
	self.bIsNew = bIsNew
end

--获取是否显示新标识
function EquipVo:getIsNew(  )
	return self.bIsNew
end

--获取是否空闲
function EquipVo:getIsIdle(  )
	return self.nHeroId == 0
end

--是否有隐藏属性
function EquipVo:getIsHasHiddenTAVo()
	if self.tHiddenTAVo and table.nums(self.tHiddenTAVo) > 0 then
		return true
	end
	return false
end

--获取装备当前实心星星数量
function EquipVo:getSolidStarNum()
	-- body
	local nSolidNum = 0
	for k, v in ipairs(self.tStarDarkLights) do
		if v == true then
			nSolidNum = nSolidNum + 1
		end
	end
	return nSolidNum
end

--获取装备强化等级
function EquipVo:getEquipStrenthLv()
	return self.nStrenthLv
end

--获取当前属性值
function EquipVo:getAttrValue()
	-- body
	local nValue = 0
	local nAddValue = 0
	local tEquip = getBaseEquipDataByID(self.nId)
	if not tEquip then
		return nValue
	end
	local tStrenConf = getEquipStrengthInfo(tEquip.nQuality, self.nStrenthLv)
	if tStrenConf then
		local tParam = luaSplitMuilt(tStrenConf.attr, "|", ",")
		for k, pa in pairs(tParam) do
			if tonumber(pa[1]) == tEquip.nKind then
				local tAttr = luaSplitMuilt(pa[2], ";", ":")
				if tAttr[1][2] then
					nAddValue = tonumber(tAttr[1][2])
				else
					nAddValue = tonumber(tAttr[2])
				end
				break
			end
		end
	end

	nValue = tEquip.nAttrValue + nAddValue

	return nValue
end

--获取该装备品质
function EquipVo:getQuality()
	local tEquip = getBaseEquipDataByID(self.nId)
	if not tEquip then
		return 0
	end
	return tEquip.nQuality
end

--获取该装备类型
function EquipVo:getKind()
	local tEquip = getBaseEquipDataByID(self.nId)
	if not tEquip then
		return 0
	end
	return tEquip.nKind
end

return EquipVo