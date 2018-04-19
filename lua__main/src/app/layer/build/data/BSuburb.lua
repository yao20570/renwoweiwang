-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-27 20:21:03 星期四
-- Description: 郊外建筑 
-----------------------------------------------------

local Build = require("app.layer.build.data.Build")

local BSuburb = class("BSuburb", function()
	-- body
	return Build.new()
end)

function BSuburb:ctor(  )
	-- body
	self:myInit()
end


function BSuburb:myInit(  )
	-- self.fCollectCd 				= 			0 		--征收累计倒计时
	self.fLastLoadTime 		 		= 			nil 	--最后加载的时间
	-- self.nColState 					= 			0 		--征收状态  0：不可征收  1：可征收 2：满征收
	self.nDraws 					= 			0 		--图纸数量	
end

--从服务端获取数据刷新
function BSuburb:refreshDatasByService( tData , bAct)
	-- body
	self.nCellIndex 			= 		tData.loc or self.nCellIndex  --建筑格子下标（位置）
	self.nLv 					= 		tData.lv or self.nLv 		  --等级
	-- self.fCollectCd 			= 		tData.cul or self.fCollectCd  --征收累计倒计时	
	if bAct ~= nil then
		self.bActivated 		= 		bAct 
	end
	self.nDraws					= 		tData.ds or self.nDraws 		--资源建筑图纸数量
	-- if tData.cul and tData.cul > 0 then
	-- 	self.fLastLoadTime 		= 		getSystemTime() 			  --最后加载的时间	
	-- end
	-- --刷新资源田征收状态
	-- local nEveryTime = Player:getBuildData():getResCollectTime()
	-- --获得满征收的时间
	-- local nMaxTime = Player:getBuildData():getResCollectTimeMax()
	-- if self:getCollectLeftTime() > nEveryTime then
	-- 	self.nColState = 1
	-- 	if self:getCollectLeftTime() >= nMaxTime then --满征收
	-- 		self.nColState = 2
	-- 	end
	-- else
	-- 	self.nColState = 0
	-- end
end

--获得征收累计时间
-- function BSuburb:getCollectLeftTime( )
-- 	-- body
-- 	if self.fCollectCd and self.fCollectCd > 0 then
-- 		-- 单位是秒
-- 		local fCurTime = getSystemTime()
-- 		-- 总共累计多少秒
-- 		local fLeft = self.fCollectCd + (fCurTime - self.fLastLoadTime or 0)
-- 		return fLeft
-- 	else
-- 		return 0
-- 	end
-- end

--获得资源田征收状态
-- function BSuburb:getColState(  )
-- 	-- body
-- 	return self.nColState
-- end

-- --设置资源田征收状态
-- function BSuburb:setColState( _nState )
-- 	-- body
-- 	self.nColState = _nState
-- end

--获取资源征收的类型
function BSuburb:getLevyResType( )
	if self.sTid == e_build_ids.house then
		return e_type_resdata.coin
	elseif self.sTid == e_build_ids.wood then
		return e_type_resdata.wood
	elseif self.sTid == e_build_ids.farm then
		return e_type_resdata.food
	elseif self.sTid == e_build_ids.iron then
		return e_type_resdata.iron
	end
	return nil
end


return BSuburb