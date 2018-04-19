----------------------------------------------------- 
-- author: wangxs
-- updatetime: 2016-03-08 14:07:45 
-- Description: 世界草皮
-----------------------------------------------------

local WorldMapBg = class("WorldMapBg")

-- local sImgList = {
-- 	["1_1"] = "df_lumina_caodi_D001.jpg",
-- 	["1_2"] = "df_lumina_caodi_D002.jpg",
-- 	["1_3"] = "df_lumina_caodi_D003.jpg",
-- 	["2_1"] = "df_lumina_caodi_D004.jpg",
-- 	["2_2"] = "df_lumina_caodi_D005.jpg",
-- 	["2_3"] = "df_lumina_caodi_D006.jpg",
-- 	["3_1"] = "df_lumina_caodi_D007.jpg",
-- 	["3_2"] = "df_lumina_caodi_D008.jpg",
-- 	["3_3"] = "df_lumina_caodi_D009.jpg",
-- }

local sImgList = {
	["3_1"] = "df_lumina_caodi_D01.jpg",
	["3_2"] = "df_lumina_caodi_D02.jpg",
	["3_3"] = "df_lumina_caodi_D03.jpg",
	["2_1"] = "df_lumina_caodi_D04.jpg",
	["2_2"] = "df_lumina_caodi_D05.jpg",
	["2_3"] = "df_lumina_caodi_D06.jpg",
	["1_1"] = "df_lumina_caodi_D07.jpg",
	["1_2"] = "df_lumina_caodi_D08.jpg",
	["1_3"] = "df_lumina_caodi_D09.jpg",
}


function WorldMapBg:ctor(  )
	self:myInit()
end

function WorldMapBg:myInit(  )
	self.pImageBg 		=		nil 			--草皮图片
	self.nRow 			= 		0 				--第几行
	self.nCol 			= 		0 				--第几列
	self.bIsAdd 		= 		false 			--是否已经添加到父节点上
	self.nCollectDis    =  		math.sqrt(2) 	--需要回收的距离

end

--设置第几行第几列
function WorldMapBg:setRowAndCol( _nRow, _nCol )
	-- body
	if _nRow and _nCol then
		self.nRow = _nRow
		self.nCol = _nCol
		if self.pImageBg then
			local nImgRow = self.nRow%3
			if nImgRow == 0 then
				nImgRow = 3
			end
			local nImgCol = self.nCol%3
			if nImgCol == 0 then
				nImgCol = 3
			end
			local sKey = nImgCol.."_"..nImgRow
			self.sBgKey = sKey
			if sImgList[sKey] then
				self.pImageBg:setCurrentImage("ui/world/"..sImgList[sKey])
			end
		end
	end
end

--判断是否已经铺到对应位置
function WorldMapBg:isOnRightRowAndCol( _nRow, _nCol )
	-- body
	if _nRow and _nCol then
		if _nRow == self.nRow and _nCol == self.nCol then
			return true
		else
			return false
		end
	else
		return false
	end
end

--判断当前草皮是否需要回收
-- _nRow, _nCol：已这个参数为判断依据
function WorldMapBg:isOutZone(  _nRow, _nCol)
	-- body
	if _nRow and _nCol then
		--计算对角线距离
		local nDis = math.sqrt((self.nRow - _nRow) * (self.nRow - _nRow) + (self.nCol - _nCol) * (self.nCol - _nCol))
		if nDis > self.nCollectDis then
			return true
		else
			return false
		end
	else
		return false
	end
end

--设置已经添加到父节点上
function WorldMapBg:setIsAdd(  )
	-- body
	self.bIsAdd = true
end

--是否添加到父节点上
function WorldMapBg:isAdd(  )
	-- body
	return self.bIsAdd
end

function WorldMapBg:getRowAndCol( )
	return self.nRow, self.nCol
end

--刷新草皮位置
--生成草皮，最左下开始如
--[[{
{3,1},{3,2},{3,3}
{2,1},{2,2},{2,3}
{1,1},{1,2},{1,3},
}--]]
function WorldMapBg:refreshPos(  )
	--这个有偏移值，为了匹配菱形最小单位
	if self.nRow and self.nRow ~= 0 and self.nCol and self.nCol ~= 0 then
		-- print("self.nRow,self.nCol========",self.nRow,self.nCol)
		-- local nBeginOffsetX, nBeginOffsetY = -UNIT_WIDTH+4, 10
		-- local nBeginOffsetX, nBeginOffsetY = -UNIT_WIDTH+5, 10
		local nBeginOffsetX, nBeginOffsetY = -UNIT_WIDTH/2, -400

		local nPosX = (self.nRow - 1) * IMAGE_MAP_WIDTH + IMAGE_MAP_WIDTH / 2 + nBeginOffsetX
		local nPosY = (self.nCol - 1) * IMAGE_MAP_HEIGHT + IMAGE_MAP_HEIGHT / 2 + nBeginOffsetY
		-- print("nPosX, nPosY==============",nPosX, nPosY)
		self.pImageBg:setPosition(nPosX, nPosY)
		-- 测试打印
        -- if not self.pLabel then
        -- 	local pLabel = MUI.MLabel.new({
	       --  text=string.format("(%s,%s)",self.nRow,self.nCol),
	       --  size=60,
	       --  anchorpoint=cc.p(0.5, 0.5),
	       --  color = cc.c3b(255, 0, 0), -- 使用纯红色
	       --  dimensions = cc.size(400, 0),
	       --  })
	       --  WorldLayerObj:getScrollNode():addChild(pLabel,9999,9999)
	       --  WorldFunc.setCameraMaskForView(pLabel)
	       --  pLabel:setPosition(nPosX, nPosY)
	       --  self.pLabel = pLabel
        -- else
        -- 	self.pLabel:setPosition(nPosX, nPosY)
        -- 	self.pLabel:setString(string.format("(%s,%s)",self.nRow,self.nCol))
        -- end
	end
end

return WorldMapBg

