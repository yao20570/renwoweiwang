local CityWarNotice = class("CityWarNotice")
--	城战提示
function CityWarNotice:ctor( tData)
	self:update(tData)
end

function CityWarNotice:update( tData )
	if not tData then
		return
	end
	self.nType = tData.t --	Integer	类型:0:有人攻打我 1:有人支援我
	self.nX    = tData.x --	Integer	X坐标
	self.nY    = tData.y --	Integer	Y坐标
	self.nCd   = milliSecondToSecond(tData.cd) -- Integer	倒计时/毫秒(类型为0时表示城战倒计时,为1时表示支援者行军倒计时)
	self.sName = tData.n --	String	名字
	if tData.cd then
		self.nCdSystemTime = getSystemTime()
	end
	self.nTargetX = tData.tx --目标城池位置
	self.nTargetY = tData.ty --目标城池位置
end

function CityWarNotice:getCd( )
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

function CityWarNotice:checkTargetIsMe( )
	local nX, nY = Player:getWorldData():getMyCityDotPos()
	return self.nTargetX == nX and self.nTargetY == nY
end

return CityWarNotice

