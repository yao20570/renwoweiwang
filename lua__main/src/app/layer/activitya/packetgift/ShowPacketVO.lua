-- ShowPacketVO.lua
local ShowPacketVO = class("ShowPacketVO")

function ShowPacketVO:ctor( tData )
	self:update(tData)
end

function ShowPacketVO:update( tData )
	if not tData then
		return
	end
	self.nIndex = tData.index or self.nIndex	                 --Integer	索引
	self.sPid = tData.pid or self.sPid	                         --string	触发礼包的充值id
	self.nPrice = tData.price or self.nPrice	                 --Integer	现价
	self.nOriPrice = tData.originPrice or self.nOriPrice	     --Integer	原价
	self.nDropId = tData.dropID or self.nDropId	                 --Integer	掉落id

	if not self.tItemKVList then
		self.tItemKVList = {} --掉落物品
		if self.nDropId then
			local tDropList = getDropById(self.nDropId)
			for i=1,#tDropList do
				table.insert(self.tItemKVList, {k = tDropList[i].sTid, v = tDropList[i].nCt})
			end
		end
	end
end


return ShowPacketVO