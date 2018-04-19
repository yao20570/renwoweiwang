local PeopleRecBackAllVo = class("PeopleRecBackAllVo")
function PeopleRecBackAllVo:ctor( tData )
	self:update(tData)
end

function PeopleRecBackAllVo:update( tData )
	if not tData then
		return
	end

	self.nGold = tData.gold or self.nGold --	Integer	累计金币
	self.tAwards = tData.awards or self.tAwards --	List<Pair<Integer,Long>>	奖励
	--物品排序
	sortGoodsList(self.tAwards)
end

return PeopleRecBackAllVo
