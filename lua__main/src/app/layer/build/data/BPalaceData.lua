-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-21 14:28:04 2017-04-21
-- Description: 王宫数据
-----------------------------------------------------

local Build = require("app.layer.build.data.Build")

local BPalaceData = class("BPalaceData", function()
	-- body
	return Build.new()
end)

function BPalaceData:ctor(  )
	-- body
	self:myInit()
end


function BPalaceData:myInit(  )
	self.nPersonCt 				= 		0 		    --本城人口	
	self.nPersonOutCt 			= 		0    		--离线本城人口
	
	self.nMp 					= 		0 			--离线名城人口
	self.nDp 					= 		0 			--离线都城人口
	self.nGp 					= 		0 			--名城人口
	self.nUp 					= 		0 			--都城人口

	self.nId 					=  		nil 		--文官ID
	self.fCD 					= 		nil 		--倒计时				
	self.nLastLoadOfficalTime 	= 		nil 		--最后一次刷新cd的时间

end

--从服务端获取数据刷新
function BPalaceData:refreshDatasByService( tData )
	-- dump(tData,"palacedata=", 100)
	local nPrevLv = self.nLv

	-- body
	self.nPersonCt 				= 		tData.pl or self.nPersonCt    --本城人口
	self.nPersonOutCt 			= 		tData.of or self.nPersonOutCt --离线本城人口

	self.nMp 					= 		tData.mp or self.nMp 			--离线名城人口
	self.nDp 					= 		tData.dp or self.nDp 			--离线都城人口
	self.nGp 					= 		tData.gp or self.nGp 			--名城人口
	self.nUp 					= 		tData.up or self.nUp 			--都城人口

	self.nCellIndex 			= 		tData.loc or self.nCellIndex  --建筑格子下标（位置）
	self.nLv 					= 		tData.lv or self.nLv 		  --等级


	--刷新文官信息
	self:refreshOfficalDatas(tData)
	--通知刷新王宫数据消息
	sendMsg(ghd_refresh_palace_msg)
	--通知刷新王宫等级发生变化
	if nPrevLv ~= self.nLv then
		sendMsg(ghd_refresh_palace_lv_msg)
		--刷新活动红点
		sendMsg(gud_refresh_act_red)
	end
end

--刷新文官数据
function BPalaceData:refreshOfficalDatas( tData )
	--传送文官等级，根据文官buff倒计时判定是否确定雇用文官，否则为空
	--dump(tData,"palacedata=", 100)
	if tData.ft then		
		self.nId 		=  		tData.cId or self.nId --文官ID
		self.fCD 		= 		tData.ft or self.fCD --倒计时				
		self.nLastLoadOfficalTime = getSystemTime() --最后一次刷新cd的时间
		if self.fCD == 0 then
			self.nId = nil
		end
		--通知刷新王宫雇用文官面板的信息
		sendMsg(ghd_refresh_palacecivil)	
	end	
	
end

--获取文官buff当前的剩余时间
function BPalaceData:getOfficalLeftCD(  )
	-- body
	-- 单位是秒
	if self.fCD then
		local fCurTime = getSystemTime()
		-- 总共剩余多少秒
		local fLeft = self.fCD - (fCurTime - self.nLastLoadOfficalTime)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end
end

--获取当前文官的基础信息
function BPalaceData:getOfficalBaseData(  )
	-- body
	return getPalaceOfficialByID(self.nId)
end

--获取本城人口数量变化
function BPalaceData:getOwnCityPeopleChangeCnt(  )
	-- body
	return self.nPersonCt - self.nPersonOutCt	
end

--获取国家百姓
function BPalaceData:getCountryPeopleCnt(  )
	-- body
	return 	self.nGp + self.nUp	
end
--获取国家人口变化
function BPalaceData:getCountryPeopleChangeCnt()	
	-- body
	return self.nGp + self.nUp	- (	self.nMp + self.nDp)
end


return BPalaceData