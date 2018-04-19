--官员
local KingDataVo = class("KingDataVo")

function KingDataVo:ctor(  )
	--body
	self:myInit()
end

function KingDataVo:myInit(  )
	-- body
	self.sKName  	= 	""
	self.nKLv 		= 	0
	self.sKIcon 	= 	nil 
	self.sKDec 		= 	"" 
end

function KingDataVo:refreshDataByService(tData )
	-- body	
	self.sKName  		= 	tData.kn or self.sKName --国王名字(有国王时才有该字段)
	self.nKLv 			= 	tData.klv or self.nKLv --国王等级 (有国王时才有该字段)
	if tData.tou then
		self.sKIcon 		= 	getPlayerIconStr(tData.tou)
	end
	self.sKDec 			= 	tData.zh or self.sKDec --国王装饰
end

function KingDataVo:release(  )

end
return KingDataVo

