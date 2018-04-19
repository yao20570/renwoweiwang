--国家任务数据
local BCountryTask = class("BCountryTask")

function BCountryTask:ctor( _tData )
	--body
	self:myInit()
	self:updateByDB(_tData)
end

function BCountryTask:myInit( )
	-- body
	--配置
	self.nId 		= 	nil
	self.sName 		= 	nil
	self.nDropId 	= 	nil
	self.sLinked 	= 	nil	
	self.nTargetNum = 	0
	self.nStage 	= 	nil

	--服务端
	self.nCurNum 	= 	0
	self.bFinished 	= 	false   	--是否已经完成
	self.bGet 		= 	false 		--是否已经领取
end
--获取配置数据
function BCountryTask:updateByDB( _tData )
	if not _tData then
		return
	end
	-- body
	self.nId 		= 	_tData.id or self.nId
	self.sName 		= 	_tData.name or self.sName
	self.nDropId 	= 	_tData.dropid or self.nDropId
	self.sLinked 	= 	_tData.linked or self.sLinked
	self.nTargetNum =   _tData.param or self.nTargetNum
	self.nStage 	= 	_tData.scienceStage or self.nStage

end
--从服务器刷新数据
function BCountryTask:updateByService(_nNum, _bGet)
	-- body
	if _nNum then
		self.nCurNum 	= 	_nNum
		if self.nCurNum >= self.nTargetNum and self.nCurNum > 0 then
			self.bFinished = true
		else
			self.bFinished = false
		end
	end
	self:updateStatus(_bGet)
end

function BCountryTask:updateStatus( _bGet )
	-- body
	if _bGet then
		self.bGet 		= 	_bGet 		--是否已经领取
	end		
end

function BCountryTask:isCanGetReward()
	-- body
	return self.bFinished and not self.bGet
end

function BCountryTask:release(  )

end

return BCountryTask


