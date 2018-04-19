----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-05 17:04:43
-- Description: 世界地图
-----------------------------------------------------
local DlgBase = require("app.common.dialog.DlgBase")
local WorldMapCity = require("app.layer.world.WorldMapCity")
local nImperialCityMapId = 1013 --皇城mapId
--区域地图对话框
local DlgWorldMap = class("DlgWorldMap", function()
	return DlgBase.new(e_dlg_index.worldmap)
end)

function DlgWorldMap:ctor(  )
	parseView("dlg_world_map", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgWorldMap:onParseViewCallback( pView )
	self.pView = pView
	self:addContentView(pView) --加入内容层

	self:setTitle(getConvertedStr(3, 10115))

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgWorldMap",handler(self, self.onDlgWorldMapDestroy))
end

-- 析构方法
function DlgWorldMap:onDlgWorldMapDestroy(  )
    self:onPause()
end

function DlgWorldMap:regMsgs(  )
end

function DlgWorldMap:unregMsgs(  )
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgWorldMap:onResume( _bReshow )
	self:updateViews()	
	self:regMsgs()
end

--暂停方法
function DlgWorldMap:onPause(  )	
	self:unregMsgs()
end

function DlgWorldMap:setupViews(  )
	--顶部
	local pLayTop = self:findViewByName("lay_top")
	--绿红蓝黄
	local tCountry = {e_type_country.wuguo, e_type_country.shuguo, e_type_country.weiguo, e_type_country.qunxiong}
	--动态生成
	local nImgX, nImgY, nTxtXAdd, nOffsetX = 60, 56/2, 30, 150
	for i=1,#tCountry do
		local nCountry = tCountry[i]
		local sImg = getCountryDiamondImg(nCountry)
		local pImgCountry = MUI.MImage.new(sImg)
		pLayTop:addView(pImgCountry)
		pImgCountry:setPosition(nImgX, nImgY)

		local pTxtCountry = MUI.MLabel.new({text = string.format(getConvertedStr(3, 10551), getCountryShortName(nCountry)) , size = 20})
		pLayTop:addView(pTxtCountry)
		pTxtCountry:setAnchorPoint(0, 0.5)
		pTxtCountry:setPosition(nImgX + nTxtXAdd, nImgY)

		nImgX = nImgX + nOffsetX
	end

	--按钮
	local pLayBtnBlock = self:findViewByName("lay_btn_block")
	local pBtnBlock = getCommonButtonOfContainer(pLayBtnBlock,TypeCommonBtn.L_BLUE, getConvertedStr(3, 10012))
	pBtnBlock:onCommonBtnClicked(handler(self, self.onBtnBlockClicked))

	--我的定位
	self.pImgLocation = self:findViewByName("img_location")
	self.pWorldMapCitys = {}
	
	--初始化界面
	local tMapData = getWorldMapData()
	for k,v in pairs(tMapData) do
		local nBlockId = v.id
		local pLayContent = self:findViewByName(string.format("lay_city_%s", nBlockId))
		local pImgCountry = self:findViewByName(string.format("img_country_%s", nBlockId))
		local pImgLock = self:findViewByName(string.format("img_lock_%s", nBlockId))
			
		local pWorldMapCity = WorldMapCity.new(self, pLayContent, pImgCountry, pImgLock)
		pWorldMapCity:setData(v)
		self.pWorldMapCitys[nBlockId] = pWorldMapCity
	end
end

function DlgWorldMap:updateViews(  )
	--我的信息
	local nX, nY = Player:getWorldData():getMyCityDotPos()
	local nBlockId = WorldFunc.getBlockId(nX, nY)
	if nBlockId then
		--我的位置
		local pWorldMapCity = self.pWorldMapCitys[nBlockId]
		if pWorldMapCity then
			local fX, fY = pWorldMapCity:getLocalImgPos()
			if fX then
				self.pImgLocation:setPosition(fX, fY)
			end
		end
	end

	--更新区域显示
	for nBlockId,pWorldMapCity in pairs(self.pWorldMapCitys) do
		pWorldMapCity:updateViews()
	end

	-- --测试
	-- if not bIsTest then
	-- 	for nBlockId,pWorldMapCity in pairs(self.pWorldMapCitys) do
	-- 		local nX, nY = pWorldMapCity:getLocalImgPos()
	-- 		if nX then
	-- 			local pImg = MUI.MImage.new("#v1_img_weizhi.png")
	-- 			pImg:setPosition(nX, nY)
	-- 			self.pView:addView(pImg, 999)
	-- 		end
	-- 	end
	-- 	bIsTest = true
	-- end
end

function DlgWorldMap:setData( nDotX, nDotY)
	self.nDotX =  nDotX
	self.nDotY =  nDotY
	--self:updateViews()
end

--点击区域地图
function DlgWorldMap:onBtnBlockClicked( pView )
	local nX, nY = Player:getWorldData():getMyCityDotPos()
	local tObject = {
		nType = e_dlg_index.blockmap, --dlg类型
		--
		nDotX = self.nDotX or nX,
		nDotY = self.nDotY or nY,
	}
	sendMsg(ghd_show_dlg_by_type, tObject)

	self:closeDlg(false)
end


return DlgWorldMap