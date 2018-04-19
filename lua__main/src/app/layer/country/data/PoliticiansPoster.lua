--政要海报
local  PoliticiansPoster = class("PoliticiansPoster")

function PoliticiansPoster:ctor(  )
	--body
	self:myInit()
end

function PoliticiansPoster:myInit(  )
	-- body
	self.nOfficial  = 0
	self.sName 		= nil 
	self.sI 		= "" --头像ID	
	self.sB 		= "" --框	
	self.sT 		= nil
	self.sIcon 		= 	getPlayerIconStr() 		--i	String	当前头像 初始化默认头像
	self.sIconBg 	= 	getPlayerIconBg() 		--b	String	当前的头像框
	self.sTitle 	=   nil
end

function PoliticiansPoster:refreshDataByService(_data )
	-- body		
	self.nOfficial  = _data.j or self.nOfficial
	self.sName 		= _data.name or self.sName 
	self.sI 		= _data.icon or self.sI
	self.sB 		= _data.box or self.sB
	self.sT 		= _data.tit or self.sT
	if _data.icon then
		self.sIcon 		= getPlayerIconStr(_data.icon)
	end
	if _data.box then
		self.sIconBg 	= 	getPlayerIconBg(_data.box) 		--b	String	当前的头像框
	end
	if _data.tit then
		self.sTitle = 	getPlayerTitle(_data.tit)
	end

end

function PoliticiansPoster:release(  )

end
return PoliticiansPoster