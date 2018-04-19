local TurnConfVo = class("TurnConfVo")

function TurnConfVo:ctor( tData )
	self.tLuckyTurnConfVos = {}
	self.tKingTurnConfVos = {}
	self.tVipFree = {}
	self:update(tData)
end

function TurnConfVo:update( tData )
	if not tData then
		return
	end
	self.nOneLuckyCost = tData.lo or self.nOneLuckyCost --	Long	转1次幸运花费黄金
	self.nTenLuckyCost = tData.lt or self.nTenLuckyCost -- Long	转10次幸运花费黄金
	self.nOneKindCost = tData.ko or self.nOneKindCost --	Long	转1次王者转盘花费黄金
	self.nTenKindCost = tData.kt or self.nTenKindCost --Long	转10次王者转盘花费黄金
	self.tVipFree = tData.vp or self.tVipFree --	List<Integer>	vip转动次数配置

	if tData.ls then--	List<LucyTurnConfVo>	幸运转盘配置
		self.tLuckyTurnConfVos = {}
		local LucyTurnConfVo = require("app.layer.activityb.snatchturn.LucyTurnConfVo")
		for i=1,#tData.ls do
			table.insert(self.tLuckyTurnConfVos, LucyTurnConfVo.new(tData.ls[i]))
		end
	end
	if tData.ks then	--List<KingTurnConfVo>	王者转盘配置
		self.tKingTurnConfVos = {}
		local KingTurnConfVo = require("app.layer.activityb.snatchturn.KingTurnConfVo")
		for i=1,#tData.ks do
			table.insert(self.tKingTurnConfVos, KingTurnConfVo.new(tData.ks[i]))
		end
	end
	self.nPieceNum = tData.cm or self.nPieceNum --	Integer	碎片兑换数量
end

function TurnConfVo:getFreeNumMax( )
	local nVip = Player:getPlayerInfo().nVip
	return self.tVipFree[nVip] or 0
end

return TurnConfVo