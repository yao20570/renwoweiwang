-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-04 9:26:03 星期四
-- Description: 资源数据 
-----------------------------------------------------

local ResourceData = class("ResourceData")

function ResourceData:ctor(  )
	-- body
	self:myInit()
end


function ResourceData:myInit(  )	
	self.tBase			 = 			{} 	--基础产量	
	self.tScience 		 = 			{} 	--科技加成	
	self.tSeason 		 = 			{} 	--季节加成	
	self.tAcitvity		 =			{} 	--活动加成
	self.tOfficer 		 =			{} 	--文官加成	
	self.tAll  			 =  		{}     --总产量
end

--从服务端获取数据刷新
function ResourceData:refreshDatasByService( tData )
	-- body  
	--刷新规则 接受数值为零时候说明该处数据刷新为空 接受数据为空则对应不刷新
	if tData then
		self.tBase		= 	tData.base or self.tBase -- 刷新基础产量	
		self.tScience 	= 	tData.science or self.tScience
		self.tSeason 	= 	tData.season or self.tSeason
		self.tAcitvity	=	tData.acitvity or self.tAcitvity
		self.tOfficer 	=	tData.officer or self.tOfficer
		self.tAll  		=  	tData.all or self.tAll
	end
end

--获得总产量
function ResourceData:getOutput(_resName)
	-- body
	return self.tAll[_resName] or 0
end

--获得基础资源的产量
function ResourceData:getResCntUnitTime( nId )
	-- body
	if not nId then
		return 0
	end
	local nCurrNum = 0
	if nId == e_type_resdata.food then --粮草
        nCurrNum = self.tAll.food or 0
    elseif nId == e_type_resdata.coin then --银币
        nCurrNum = self.tAll.coin or 0
    elseif nId == e_type_resdata.wood then --木材
        nCurrNum = self.tAll.wood or 0
    elseif nId == e_type_resdata.iron then --镔铁
        nCurrNum = self.tAll.iron or 0
    end
    return nCurrNum
end
return ResourceData
