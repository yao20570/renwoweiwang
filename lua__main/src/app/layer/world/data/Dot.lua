require("framework.cc.utils.bit")
local Dot = class("Dot")
--地图视图点
function Dot:ctor( tData, tViewDotMsg)
	self:update(tData)
	self:udpateByViewDotMsg(tViewDotMsg)
end

function Dot:update( tData )
	if not tData then
		return
	end

	-- -- 地图点数 +---+| 9bit | 9bit | 6bit | 2bit | +---+| x | y | 皇宫等级 | 势力0：群雄 1：蜀 2: 魏 3: 吴 |
	-- local nNum = tData
	-- self.nCountry = bit.band(nNum, 0x3)

	-- local nNum = bit.brshift(tData, 2)
 --    self.nCityLv = bit.band(nNum, 0x3f)

	-- local nNum = bit.brshift(tData, 8)	
 --    self.nY = bit.band(nNum, 0x1ff)

 --    local nNum = bit.brshift(tData, 17)
 --    self.nX = bit.band(nNum, 0x1ff)

 	self.nCountry, self.nCityLv, self.nY, self.nX = self:parseData(tData) 	
 	
    local fX, fY = WorldFunc.getMapPosByDotPos(self.nX, self.nY)
    self.tMapPos = cc.p(fX or 0, fY or 0)
    --关键字
    self.sDotKey = string.format("%s_%s",self.nX, self.nY)
end

--简单转化
function Dot:parseData( _tData )
	--顺序
	--10010000001100110100010011
	local tBitData = bit.tobits(_tData)

	--倒序
	--110010001 011001100 000010 01
	--9,9,6,2
	local tX = {}
	local tY = {}
	local tCityLv = {}
	local tCountry = {}

	for i = 1,#tBitData do
		if i > 17 and i <= 26 then
			table.insert(tX, tBitData[i])
		elseif i > 8 and i <= 17 then
			table.insert(tY, tBitData[i])
		elseif i > 2 and i <= 8 then
			table.insert(tCityLv, tBitData[i])
		else
			table.insert(tCountry, tBitData[i])
		end
	end
	
	local nCountry =bit.tonumb(tCountry)
	local nCityLv =bit.tonumb(tCityLv)
	local nY = bit.tonumb(tY)
	local nX = bit.tonumb(tX)
	return nCountry, nCityLv, nY, nX
end

function Dot:udpateByViewDotMsg( tViewDotMsg )
	if not tViewDotMsg then
		return
	end
	self.nCountry = tViewDotMsg.nCountry

	self.nCityLv = tViewDotMsg.nLevel

	self.nY = tViewDotMsg.nY
	
	self.nX = tViewDotMsg.nX

	local fX, fY = WorldFunc.getMapPosByDotPos(self.nX, self.nY)
	self.tMapPos = cc.p(fX or 0, fY or 0)

	--关键字
	self.sDotKey = string.format("%s_%s",self.nX, self.nY)
end


return Dot