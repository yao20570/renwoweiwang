local StormVo = class("StormVo")

function StormVo:ctor( tData )
	self.tGoodsList = {}
	self:update(tData)
end

function StormVo:update( tData )
	self.nDouble = tData.d	--Integer	伤害翻倍 0否 1是
	if tData.o then--	List<Pair<Integer,Long>>	获得东西
		self.tGoodsList = {}
		for i=1,#tData.o do
			local tGoods = getGoodsByTidFromDB(tData.o[i].k)
			if tGoods then
				tGoods.nCt = tData.o[i].v
				table.insert(self.tGoodsList, tGoods)
			end
		end
	end
end

function StormVo:getIsDouble(  )
	return self.nDouble == 1
end

function StormVo:getGoodsList( )
	return self.tGoodsList
end

return StormVo