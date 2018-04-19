local BossWarVO = class("BossWarVO")

function BossWarVO:ctor( tData )
	self.nSenderName = ""
	self.nSenderLv = 0
	self:update(tData)
end

function BossWarVO:update( tData)
	if not tData then
		return
	end
	self.nSenderName = tData.sn or self.nSenderName --发起者名字
	self.nSenderLv = tData.sl or self.nSenderLv --发起者等级
	self.nSenderId = tData.sp or self.nSenderId --	Long	发起者
	self.nSenderCountry =  tData.sC or self.nSenderCountry --	Integer	发起者国家
	self.nAtkTroops = tData.at or self.nAtkTroops --	Integer	发起者兵力
	self.nDefTroops = tData.dt or self.nDefTroops --	Integer	防守者兵力
	if tData.cd then
		self.nCd = tData.cd --	Long	倒计时/秒
		self.nCdSystemTime = getSystemTime()
	end
	self.nSupport = tData.s	or self.nSupport --Integer	已经请求支援的次数
end

function BossWarVO:getCd( )
	if self.nCd and self.nCd > 0 then
		local fCurTime = getSystemTime()
		local fLeft = self.nCd - (fCurTime - self.nCdSystemTime)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end
end

function BossWarVO:getIsMeSender( )
	return self.nSenderId == Player:getPlayerInfo().pid
end

function BossWarVO:getIsMineCountry( )
	return self.nSenderCountry == Player:getPlayerInfo().nInfluence
end

function BossWarVO:getSenderName(  )
	return self.nSenderName
end

function BossWarVO:getSenderLv(  )
	return self.nSenderLv
end

return BossWarVO