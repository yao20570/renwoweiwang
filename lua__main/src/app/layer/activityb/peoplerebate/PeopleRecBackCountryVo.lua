local PeopleRecBackCountryVo = class("PeopleRecBackCountryVo")
function PeopleRecBackCountryVo:ctor( tData )
	self:update(tData)
end

function PeopleRecBackCountryVo:update( tData )
	if not tData then
		return
	end

	self.nId = tData.id or self.nId --	Integer	国家Id
	self.nGold = tData.gold or self.nGold --	Long	累计充值
end

return PeopleRecBackCountryVo