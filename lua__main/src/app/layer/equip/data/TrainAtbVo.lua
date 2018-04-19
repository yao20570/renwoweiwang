local TrainAtbVo = class("TrainAtbVo")

function TrainAtbVo:ctor( tData, nEquipId )
	self.nAttrValue = 0
	self:setEquipId(nEquipId)
	self:update(tData)
end

function TrainAtbVo:setEquipId(nEquipId)
	self.nEquipId = nEquipId
end

function TrainAtbVo:update( tData )
	if not tData then
		return
	end
	self.nLv = tData.l or self.nLv	--Integer	洗炼属性等级
	self.nIdentify = tData.i or self.nIdentify	--Integer	洗炼属性标识[对应equip_train_attr表里的属性字段,假如i=2就取表里的atb2字段属性配置]

	--自定义数据
	local tAttrData = getEquipTrainAttr(self.nLv)
	if tAttrData then
		local sAttr = tAttrData["atb"..self.nIdentify]
		if sAttr then
			local tAttr = luaSplit(sAttr, ":")
			local nAttrId = tonumber(tAttr[1])
			local nAttrValue = tonumber(tAttr[2])
			if nAttrId and nAttrValue then
				self.nAttrId = nAttrId --自定义数据，属性id
				self.nAttrValue = nAttrValue --自定义数据，属性值
			end
		end
	end
end

--获取对应的基础表
function TrainAtbVo:getConfigData( )
	if not self.nAttrId then
		return nil
	end
	return getBaseAttData(self.nAttrId)
end

function TrainAtbVo:getAttrId(  )
	return self.nAttrId
end

--获取洗炼等级是否满
function TrainAtbVo:getIsLvMax( )
	if not self.nLv then
		return false
	end
	local tEquipData = getBaseEquipDataByID(self.nEquipId)
	if not tEquipData then
		return
	end
	return self.nLv >= tEquipData.nTrainLvTop
end


return TrainAtbVo