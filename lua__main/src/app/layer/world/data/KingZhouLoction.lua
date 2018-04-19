local KingZhouLoction = class("KingZhouLoction")

function KingZhouLoction:ctor( tData, tViewDotMsg)
	self:udpate(tData)
	self:udpateByViewDotMsg(tViewDotMsg)
end

function KingZhouLoction:udpate( tData )
	if not tData then
		return
	end	
	self.nKzt = tData.kzt or self.nKzt   
	self.nKztt = tData.kztt or self.nKztt

	self.tKzps = tData.pvos or self.tKzps	
	if self.tKzps then
		local tLeftPos = nil
		for i = 1, #self.tKzps do
			if tLeftPos then
				if self.tKzps[i].x <= tLeftPos.x and self.tKzps[i].y <= tLeftPos.y then
					tLeftPos = self.tKzps[i]
				end
			else
				tLeftPos = self.tKzps[i]
			end
		end
		self.nX = tLeftPos.x or self.nX --x坐标
		self.nY = tLeftPos.y or self.nY --y坐标
	else
		self.nX = tData.x or self.nX --	Integer	X
		self.nY = tData.y or self.nY --	Integer	Y	
	end	
	
	self.sDotKey = string.format("%s_%s",self.nX, self.nY)
end

function KingZhouLoction:udpateByViewDotMsg( tViewDotMsg )
	if not tViewDotMsg then
		return
	end
	self.nX = tViewDotMsg.nX or self.nX
	self.nY = tViewDotMsg.nY or self.nY
	self.nKzt = tViewDotMsg.nKzt or self.nKzt   
	self.nKztt = tViewDotMsg.nKztt or self.nKztt
	self.sDotKey = string.format("%s_%s",self.nX, self.nY)
end

return KingZhouLoction
