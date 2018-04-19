----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-01-10 11:22:00
-- Description: 世界地图首杀  城池
-----------------------------------------------------
local nImperialCityMapId = 1013 --皇城mapId
local WorldMapFirstBloodCity = class("WorldMapFirstBloodCity")

function WorldMapFirstBloodCity:ctor( pDlgWorldMap, pLayContent, pImgCountry, pImgLock, pTxtFirstBlood, pLayTxtBg, pLayRed )
	self.pDlgWorldMap = pDlgWorldMap
	self.pLayContent = pLayContent
	self.pImgCountry = pImgCountry
	self.pLayRed = pLayRed
	-- self.pImgLock = pImgLock
	-- self.pImgLock:setVisible(false)
	self.pTxtFirstBlood = pTxtFirstBlood
	setTextCCColor(self.pTxtFirstBlood, _cc.white)
	self.pLayTxtBg = pLayTxtBg

	self:setupViews()
	self:updateViews()
end

function WorldMapFirstBloodCity:setupViews()
	self.pLayContent:setViewTouched(true)
	self.pLayContent:setIsPressedNeedScale(false)
	self.pLayContent:onMViewClicked(handler(self, self.onBlockClicked))
end

function WorldMapFirstBloodCity:updateViews(  )
	if not self.tData then
		return
	end

	--区域内首杀国家最高的数据
	local nCountry = e_type_country.qunxiong
	local tCityFirstBloodVo = Player:getWorldData():getFirstBloodTopInBlock(self.tData.id)
	if tCityFirstBloodVo then
		nCountry = tCityFirstBloodVo:getCountry()
		self.pTxtFirstBlood:setVisible(true)
		self.pLayTxtBg:setVisible(true)
		--文字
		local sStr = tCityFirstBloodVo:getFirstBlooodStr()
		self.pTxtFirstBlood:setString(sStr, false)
		--文字背景
		local pSize = self.pTxtFirstBlood:getContentSize()
		self.pLayTxtBg:setLayoutSize(pSize.width+8, 20+8)
		-- local nX, nY = self.pTxtFirstBlood:getPosition()
		-- local nAX, nAY = self.pTxtFirstBlood:getAnchorPoint()
		-- local pSize = self.pTxtFirstBlood:getContentSize()
		-- self.pLayTxtBg:setLayoutSize(pSize.width, pSize.height)
		-- self.pLayTxtBg:setPosition(nX + nAX * pSize.width, nY + nAY * pSize.height)
	else
		self.pTxtFirstBlood:setVisible(false)
		self.pLayTxtBg:setVisible(false)
	end
	--城池图片
	local sImgPath = nil
	if self.tData.id == nImperialCityMapId then --皇城
		sImgPath = getCountryImperCityImg(nCountry)
	else
		sImgPath = getCountryDiamondImg(nCountry)
	end
	self.pImgCountry:setCurrentImage(sImgPath)
	
	--更新红点
	self:updateRedNum()

	--更新解锁
	self:updateLock()
end

--红点
function WorldMapFirstBloodCity:updateRedNum(  )
	if not self.tData then
		return
	end
	if self.pLayRed then
		if Player:getWorldData():getFirstBloodRedInBlock(self.tData.id) then
			showRedTips(self.pLayRed, 0, 1)
		else
			showRedTips(self.pLayRed, 0, 0)
		end
	end
end

function WorldMapFirstBloodCity:updateLock( )
	-- if not self.tData then
	-- 	return
	-- end

	-- if self.pImgLock then
	-- 	local bIsUnLock = Player:getWorldData():getBlockIsCanSee(self.tData.id)
	-- 	if bIsUnLock then
	-- 		self.pImgLock:setVisible(false)
	-- 	else
	-- 		self.pImgLock:setVisible(true)
	-- 	end
	-- end
end

--tData: 表格world_block的数据
function WorldMapFirstBloodCity:setData( tData )
	self.tData = tData
	self:updateViews()
end

function WorldMapFirstBloodCity:onBlockClicked(  )
	if not self.tData then
		return
	end

	-- local tCityData = getWorldCityDataById(tonumber(self.tData.maincity))
	-- if not tCityData then
	-- 	return
	-- end

	-- if self.pImgLock then
	-- 	if self.pImgLock:isVisible() then
	-- 		WorldFunc.checkIsInLockBlock(tCityData.tCoordinateCenter.x, tCityData.tCoordinateCenter.y)
	-- 		return
	-- 	end
	-- end

	--前往首杀界面
	local tObject = {}
	tObject.nType = e_dlg_index.cityfirstblood --dlg类型
	tObject.nBlockId = self.tData.id
	sendMsg(ghd_show_dlg_by_type,tObject)
	--关掉自己
	-- self.pDlgWorldMap:closeDlg(false)
end

function WorldMapFirstBloodCity:getLocalImgPos( )
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

return WorldMapFirstBloodCity


