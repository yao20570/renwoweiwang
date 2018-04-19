----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-17 19:59:21
-- Description: 世界大地图  城池
-----------------------------------------------------
local nImperialCityMapId = 1013 --皇城mapId
local WorldMapCity = class("WorldMapCity")

function WorldMapCity:ctor( pDlgWorldMap, pLayContent, pImgCountry, pImgLock)
	self.pDlgWorldMap = pDlgWorldMap
	self.pLayContent = pLayContent
	self.pImgCountry = pImgCountry
	self.pImgLock = pImgLock

	self:setupViews()
	self:updateViews()
end

function WorldMapCity:setupViews()
	self.pLayContent:setViewTouched(true)
	self.pLayContent:setIsPressedNeedScale(false)
	self.pLayContent:onMViewClicked(handler(self, self.onBlockClicked))
end

function WorldMapCity:updateViews(  )
	if not self.tData then
		return
	end

	if self.pImgCountry then
		local nCountry = Player:getWorldData():getMainCityCaptureCountry(self.tData.maincity)
		local sImgPath = nil
		if self.tData.id == nImperialCityMapId then --皇城
			sImgPath = getCountryImperCityImg(nCountry)
		else
			sImgPath = getCountryDiamondImg(nCountry)
		end
		--城池图片
		self.pImgCountry:setCurrentImage(sImgPath)
	end

	--更新解锁
	self:updateLock()
end

function WorldMapCity:updateLock( )
	if not self.tData then
		return
	end

	if self.pImgLock then
		local bIsUnLock = Player:getWorldData():getBlockIsCanSee(self.tData.id)
		if bIsUnLock then
			self.pImgLock:setVisible(false)
		else
			self.pImgLock:setVisible(true)
		end
	end
end

--tData: 表格world_block的数据
function WorldMapCity:setData( tData )
	self.tData = tData
	self:updateViews()
end

function WorldMapCity:onBlockClicked(  )
	if not self.tData then
		return
	end

	local tCityData = getWorldCityDataById(tonumber(self.tData.maincity))
	if not tCityData then
		return
	end

	if self.pImgLock then
		if self.pImgLock:isVisible() then
			WorldFunc.checkIsInLockBlock(tCityData.tCoordinateCenter.x, tCityData.tCoordinateCenter.y)
			return
		end
	end

	local tObject = {
		nType = e_dlg_index.blockmap, --dlg类型
		--
		nDotX = tCityData.tCoordinateCenter.x,
		nDotY = tCityData.tCoordinateCenter.y,
	}
	sendMsg(ghd_show_dlg_by_type, tObject)

	self.pDlgWorldMap:closeDlg(false)
end

function WorldMapCity:getLocalImgPos( )
	if not self.tData then
		return
	end

	if self.pLayContent and self.pImgCountry then
		local nX, nY = self.pLayContent:getPosition()
		local nX2, nY2 = self.pImgCountry:getPosition()
		
		if self.tData.id == nImperialCityMapId then
			nX2 = nX2 + 54
			nY2 = nY2 - 16
		else
			nX2 = nX2 + 44
			nY2 = nY2 - 16
		end

		return nX + nX2, nY + nY2
	end

	return nil
end

return WorldMapCity


