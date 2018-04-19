local CityWarMsg = class("CityWarMsg")
--	城战
function  CityWarMsg:ctor( tData )
	self.nCdMax = 0
	self:update(tData)
end

function CityWarMsg:update( tData )
	if not tData then
		return
	end
	self.nType = e_type_task.cityWar
	self.sWarId = tData.wid --String 战役id 
	self.nWarType = tData.t --nIngter 1.短途 ，2合围，3奔
	self.sSenderHeadId = tData.sa -- String 发起者头像id
	self.sSenderBox = tData.sat -- String 发起者头像边框
	self.sSenderName = tData.sn --	String	发起者名字
	-- self.nSenderLv =  tData.sl	-- Integer	发起者等级
	self.nSenderCountry = tData.sC	--Integer	发起者国家
	self.nSenderCityLv = tData.spl --Integer	发起者城池等级
	self.nSenderX = tData.sx	--Integer	发起者坐标X
	self.nSenderY = tData.sy	--Integer	发起者坐标Y
	self.nAtkTroops = tData.at	--Integer	发起者兵力
	self.nDefTroops = tData.dt	--Integer	防守者兵力
	self.sDefHeadId = tData.da -- String 防守者像id
	self.sDefBox = tData.dat -- String 防守者头像边框
	self.nCd = tData.cd	--Integer	倒计时
	self.nCdMax = tData.tcd or self.nCdMax --Integer		城战总倒计时/秒
	self.nSupport = tData.s	--Integer	已经请求支援的次数
	self.nTargetX = tData.tx --Integer 目标X
	self.nTargetY = tData.ty --
	if tData.cd then
		self.nCdSystemTime = getSystemTime()
	end
end

function CityWarMsg:getCd( )
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
function CityWarMsg:getCdMax()
	return self.nCdMax or 0
end

function CityWarMsg:checkTargetIsMe( )
	local nX, nY = Player:getWorldData():getMyCityDotPos()
	return self.nTargetX == nX and self.nTargetY == nY
end


function CityWarMsg:getSenderHead(  )
	return self.sSenderHeadId
end

function CityWarMsg:getSenderBox(  )
	return self.sSenderBox
end

function CityWarMsg:getDeferHead(  )
	return self.sDefHeadId
end

function CityWarMsg:getDeferBox(  )
	return self.sDefBox
end

return CityWarMsg

