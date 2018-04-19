----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-01-10 11:18
-- Description: 世界地图城池首杀
-----------------------------------------------------
local DlgBase = require("app.common.dialog.DlgBase")
local WorldMapFirstBloodCity = require("app.layer.cityfirstblood.WorldMapFirstBloodCity")
local nImperialCityMapId = 1013 --皇城mapId
--区域地图对话框
local DlgWorldMapFirstBlood = class("DlgWorldMapFirstBlood", function()
	return DlgBase.new(e_dlg_index.worldmapfirstblood)
end)

function DlgWorldMapFirstBlood:ctor(  )
	parseView("dlg_world_map_first_blood", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgWorldMapFirstBlood:onParseViewCallback( pView )
	self.pView = pView
	self:addContentView(pView) --加入内容层

	self:setTitle(getConvertedStr(3, 10583))

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgWorldMapFirstBlood",handler(self, self.onDlgWorldMapFirstBloodDestroy))
end

-- 析构方法
function DlgWorldMapFirstBlood:onDlgWorldMapFirstBloodDestroy(  )
    self:onPause()
end

function DlgWorldMapFirstBlood:regMsgs(  )
	regMsg(self, gud_city_first_blood_refresh, handler(self, self.updateViews))

	--监听首杀红点
	regMsg(self, gud_city_first_blood_red, handler(self, self.updateRedNum))
end

function DlgWorldMapFirstBlood:unregMsgs(  )
	unregMsg(self, gud_city_first_blood_refresh)

	unregMsg(self, gud_city_first_blood_red)
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgWorldMapFirstBlood:onResume( _bReshow )
	self:updateViews()	
	self:regMsgs()
end

--暂停方法
function DlgWorldMapFirstBlood:onPause(  )	
	self:unregMsgs()
end

function DlgWorldMapFirstBlood:setupViews(  )
	--顶部
	local pLayTop = self:findViewByName("lay_top")
	--绿黄红蓝		e_type_country.qunxiong
	local tCountry = {e_type_country.wuguo, e_type_country.shuguo, e_type_country.weiguo}
	--动态生成
	local nImgX, nImgY, nTxtXAdd, nOffsetX = 80, 56/2, 30, 200
	for i=1,#tCountry do
		local nCountry = tCountry[i]
		local sImg = getCountryDiamondImg(nCountry)
		local pImgCountry = MUI.MImage.new(sImg)
		pLayTop:addView(pImgCountry)
		pImgCountry:setPosition(nImgX, nImgY)

		local pTxtCountry = MUI.MLabel.new({text = string.format(getConvertedStr(3, 10592), getCountryShortName(nCountry)) , size = 20})
		pLayTop:addView(pTxtCountry)
		pTxtCountry:setAnchorPoint(0, 0.5)
		pTxtCountry:setPosition(nImgX + nTxtXAdd, nImgY)

		nImgX = nImgX + nOffsetX
	end

	-- --按钮
	-- local pLayBtnBlock = self:findViewByName("lay_btn_block")
	-- local pBtnBlock = getCommonButtonOfContainer(pLayBtnBlock,TypeCommonBtn.L_BLUE, getConvertedStr(3, 10012))
	-- pBtnBlock:onCommonBtnClicked(handler(self, self.onBtnBlockClicked))

	--我的定位
	self.pImgLocation = self:findViewByName("img_location")
	self.pWorldMapCitys = {}
	
	--初始化界面
	local tMapData = getWorldMapData()
	for k,v in pairs(tMapData) do
		local nBlockId = v.id
		local pLayContent = self:findViewByName(string.format("lay_city_%s", nBlockId))
		local pImgCountry = pLayContent:findViewByName(string.format("img_country_%s", nBlockId))
		-- local pImgLock = pLayContent:findViewByName(string.format("img_lock_%s", nBlockId))
		local pTxtFirstBlood = pLayContent:findViewByName(string.format("txt_first_kill_%s", nBlockId))
		local pLayRed = pLayContent:findViewByName(string.format("lay_red_%s", nBlockId))
		pTxtFirstBlood:setLocalZOrder(2)
		--首杀背景
		local pLayTxtBg = MUI.MLayer.new()
		pLayTxtBg:setBackgroundImage("#v1_img_black50.png",{scale9 = true,capInsets=cc.rect(10,10, 1, 1)})
		pLayTxtBg:setLocalZOrder(1)
		local tAnPos = pTxtFirstBlood:getAnchorPoint()
		local nAX, nAY = tAnPos.x, tAnPos.y
		pLayTxtBg:setAnchorPoint(cc.p(nAX, nAY))
		local nX, nY = pTxtFirstBlood:getPosition()
		if nAX == 0 then
			pLayTxtBg:setPosition(nX-4, nY)
		elseif nAX == 1 then
			pLayTxtBg:setPosition(nX+4, nY)
		else
			pLayTxtBg:setPosition(nX, nY)
		end
		pLayContent:addView(pLayTxtBg)
		--
		local pWorldMapCity = WorldMapFirstBloodCity.new(self, pLayContent, pImgCountry, nil, pTxtFirstBlood, pLayTxtBg, pLayRed)
		pWorldMapCity:setData(v)
		self.pWorldMapCitys[nBlockId] = pWorldMapCity
	end

	--
	local pTxtBottomTip = self:findViewByName("txt_bottom_tip")
	pTxtBottomTip:setString(getConvertedStr(3, 10601))
	setTextCCColor(pTxtBottomTip, _cc.pwhite)
end

function DlgWorldMapFirstBlood:updateViews(  )
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
end

function DlgWorldMapFirstBlood:setData( )
end

function DlgWorldMapFirstBlood:updateRedNum( )
	--更新区域显示
	for nBlockId,pWorldMapCity in pairs(self.pWorldMapCitys) do
		pWorldMapCity:updateRedNum()
	end
end

return DlgWorldMapFirstBlood