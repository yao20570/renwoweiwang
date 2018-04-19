----------------------------------------------------- 
-- author: maheng
-- updatetime:  2018-03-06 17:01:23 星期二
-- Description: 自定建造项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ItemAutoBuild = class("ItemAutoBuild", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemAutoBuild:ctor(  )
	--解析文件
	parseView("item_auto_build", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemAutoBuild:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("ItemAutoBuild", handler(self, self.onDestroy))
end

function ItemAutoBuild:setupViews(  )

	self.pLayRoot = self:findViewByName("lay_root")
	self.pLayBg   = self:findViewByName("lay_bg")
	self.pImgDian = self:findViewByName("img_dian")	

	self.pLbPar1  = self:findViewByName("lb_build_name")
	self.pLbPar2  = self:findViewByName("lb_status")
	self.pLbDesc  = self:findViewByName("lb_desc")
	self.pLbIndex = self:findViewByName("lb_index")
	self.pLayBtn  = self:findViewByName("lay_btn_blue")
	self.pSortBtn  = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.M_BLUE, getConvertedStr(6, 10780))--排序	
	self.pSortBtn:onCommonBtnClicked(handler(self, self.onSortBtnClicked))
	--响应
	self.pLayRoot:setViewTouched(true)
	self.pLayRoot:setIsPressedNeedScale(false)
	self.pLayRoot:onMViewClicked(handler(self, self.onItemClicked))
end

function ItemAutoBuild:updateViews()
	-- body
	-- dump(self.pData, "self.pData", 100)
	local pBuildData = Player:getBuildData()
	if not self.pData or not pBuildData or not self.nIndex then
		return
	end
	local nIndex = self.nIndex
	local pData = self.pData

	local nType = pBuildData.nAbt
	if nType == 2 then--自定义
		self.pLbIndex:setVisible(false)		
	else
		self.pLbIndex:setVisible(true)		
	end	

	local nLv = nil
	if pData.nCellIndex and pData.nCellIndex > 0 and pData.nCellIndex <= 1000 then--城内建筑
		local pCurData = pBuildData:getBuildById(pData.sTid, true)
		nLv = 0
		if pCurData then
			nLv = pCurData.nLv			
		end
		self.pLbPar1:setString(pData.sName..getLvString(nLv, false))
	else
		--郊外建筑
		self.pLbPar1:setString(pData.sName, false)
	end	
	setTextCCColor(self.pLbPar1, _cc.blue)
	local nAutoUp = pBuildData:isOpenAutoBuildById(pData.sTid)
	local bLocked = pBuildData:isBuildLockedById(pData.sTid)
	if bLocked then--是否已经解锁		
		self.pLbPar2:setString(pData.sNotOpen, false)
		setTextCCColor(self.pLbPar2, _cc.red)
		self.pLayBg:setVisible(false)
		self.pImgDian:setVisible(true)
		self.pSortBtn:setVisible(false)
	elseif nLv and nLv == pData.nMaxLv then --已经满级
		self.pLbPar2:setString(getConvertedStr(6, 10783), false)
		setTextCCColor(self.pLbPar2, _cc.red)
		self.pLayBg:setVisible(false)
		self.pImgDian:setVisible(false)
		self.pSortBtn:setVisible(false)
		self.pLbIndex:setVisible(false)
	else
		self.pSortBtn:setVisible(nType == 2)
		self.pImgDian:setVisible(true)
		if nAutoUp then
			self.pLbPar2:setString(getConvertedStr(6, 10777), false)
			setTextCCColor(self.pLbPar2, _cc.green)
			self.pLayBg:setVisible(true)
		else
			self.pLbPar2:setString(getConvertedStr(6, 10782), false)
			setTextCCColor(self.pLbPar2, _cc.red)
			self.pLayBg:setVisible(false)
		end
	end	
	if nAutoUp == true then --开启自动升级
		self.pImgDian:setCurrentImage("#v2_img_jz_dianb.png")	
		-- self.pLayBg:setVisible(true)		
	else
		self.pImgDian:setCurrentImage("#v2_img_jz_diana.png")			
		-- self.pLayBg:setVisible(false)
	end

	self.pLbDesc:setString(pData.sDes, false)

	local fScale, tPos, tShowData = self:getBuildImgPos(pData)
	if not self.pBuildImg then
		local pBuildImg = MUI.MImage.new(tShowData.img) --这里先临时全部统一用这个图片		
		self.pLayRoot:addView(pBuildImg,10)	
		self.pBuildImg = pBuildImg
	else
		self.pBuildImg:setCurrentImage(tShowData.img)
	end
	self.pBuildImg:setPosition(tPos)	
	self.pBuildImg:setScale(fScale)



	local nOrder = pBuildData:getBuildOrderById(pData.sTid)
	if nOrder then
		self.pSortBtn:updateBtnText(getConvertedStr(6, 10780)..nOrder)
	else
		self.pSortBtn:updateBtnText(getConvertedStr(6, 10780)..nIndex)
	end	
	self.pLbIndex:setString(getConvertedStr(6, 10780)..nIndex)
end
--
function ItemAutoBuild:onItemClicked( _pView )
	-- body
	local pBuildData = Player:getBuildData()
	if not self.pData or not pBuildData then
		return
	end
	local pData = self.pData
	-- dump(self.pData, "self.pData", 100)

	local nStatus = 0
	local nAutoUp = pBuildData:isOpenAutoBuildById(pData.sTid)	
	if nAutoUp then --已经开启
		nStatus = 0
	else
		nStatus = 1
	end	
	SocketManager:sendMsg("reqOpenAutoBuild", {pData.sTid, nStatus})
end

function ItemAutoBuild:onSortBtnClicked(  )
	-- body
	local tObject = {}
	tObject.nType = e_dlg_index.custombuildorder --dlg类型
	tObject.pBuildData = self.pData
	sendMsg(ghd_show_dlg_by_type,tObject)   
end

-- 析构方法
function ItemAutoBuild:onDestroy(  )

end

function ItemAutoBuild:setData( _tData, _nIndex )
	-- body
	if not _tData or not _nIndex then
		return
	end
	self.nIndex = _nIndex
	self.pData = _tData
	self:updateViews()
end

function ItemAutoBuild:getBuildImgPos( pData )
	-- body
	if not pData then
		return
	end
	
	local nCellIndex = nil
	if pData.sTid == e_build_ids.house then --民居
		nCellIndex = 1001
	elseif pData.sTid == e_build_ids.farm then--农场
		nCellIndex = 1033
	elseif pData.sTid == e_build_ids.iron then--铁矿
		nCellIndex = 1049
	elseif pData.sTid == e_build_ids.wood then --木场
		nCellIndex = 1017
	else
		nCellIndex = pData.nCellIndex
	end
	local tShowData = getBuildGroupShowDataByCell(nCellIndex, pData.sTid)
	local fScale = 1
	local tPos = cc.p(100,100)	
	if pData.sTid == e_build_ids.house
		or pData.sTid == e_build_ids.farm
		or pData.sTid == e_build_ids.iron
		or pData.sTid == e_build_ids.wood then --资源田		
		fScale = 0.75
		tPos = cc.p(tShowData.w * tShowData.fDzRw + 5,self.pLayRoot:getHeight() / 2)
	elseif pData.sTid == e_build_ids.store then --仓库
		fScale = 0.56
		tPos = cc.p(tShowData.w * tShowData.fDzRw - 75 ,tShowData.h * tShowData.fDzRh )
	elseif pData.sTid == e_build_ids.tnoly then --科技院
		fScale = 0.4
		tPos = cc.p((tShowData.w * tShowData.fDzRw - 190),(tShowData.h * tShowData.fDzRh + 18))
	elseif pData.sTid == e_build_ids.infantry then --步兵营
		fScale = 0.55
		tPos = cc.p((tShowData.w * tShowData.fDzRw - 125),(tShowData.h * tShowData.fDzRh + 7))
	elseif pData.sTid == e_build_ids.sowar then --骑兵营
		fScale = 0.5
		tPos = cc.p((tShowData.w * tShowData.fDzRw - 150),(tShowData.h * tShowData.fDzRh + 5))
	elseif pData.sTid == e_build_ids.archer then --弓兵营
		fScale = 0.5
		tPos = cc.p((tShowData.w * tShowData.fDzRw - 160),(tShowData.h * tShowData.fDzRh + 8))
	elseif pData.sTid == e_build_ids.gate then --城墙
		fScale = 0.35
		tPos = cc.p((tShowData.w * tShowData.fDzRw - 70),(tShowData.h * tShowData.fDzRh - 95))
	elseif pData.sTid == e_build_ids.atelier then --作坊
		fScale = 0.43
		tPos = cc.p((tShowData.w * tShowData.fDzRw - 115),(tShowData.h * tShowData.fDzRh + 8))
	elseif pData.sTid == e_build_ids.tjp then --铁匠铺
		fScale = 0.45
		tPos = cc.p((tShowData.w * tShowData.fDzRw - 155),(tShowData.h * tShowData.fDzRh + 3))
	elseif pData.sTid == e_build_ids.ylp then --冶炼铺
		fScale = 0.45
		tPos = cc.p((tShowData.w * tShowData.fDzRw - 95),(tShowData.h * tShowData.fDzRh + 5))
	elseif pData.sTid == e_build_ids.jxg then --将军府
		fScale = 0.6
		tPos = cc.p((tShowData.w * tShowData.fDzRw - 70),(tShowData.h * tShowData.fDzRh + 4))
	elseif pData.sTid == e_build_ids.jbp then --珍宝阁
		fScale = 0.6
		tPos = cc.p((tShowData.w * tShowData.fDzRw - 70),(tShowData.h * tShowData.fDzRh + 4))
	elseif pData.sTid == e_build_ids.bjt then --拜将台
		fScale = 0.45
		tPos = cc.p((tShowData.w * tShowData.fDzRw - 115),(tShowData.h * tShowData.fDzRh + 9))
	elseif pData.sTid == e_build_ids.palace then --王宫
		fScale = 0.17
		tPos = cc.p((tShowData.w * tShowData.fDzRw - 340),(tShowData.h * tShowData.fDzRh - 120))
	elseif pData.sTid == e_build_ids.tcf then --统帅府
		fScale = 0.6
		tPos = cc.p((tShowData.w * tShowData.fDzRw - 70),(tShowData.h * tShowData.fDzRh + 4))
	elseif pData.sTid == e_build_ids.arena then --竞技场
		fScale = 0.6
		tPos = cc.p((tShowData.w * tShowData.fDzRw - 70),(tShowData.h * tShowData.fDzRh + 4))
	elseif pData.sTid == e_build_ids.mbf then --募兵府
		local tBuildData = Player:getBuildData():getBuildById(e_build_ids.mbf, true)
		if tBuildData.nRecruitTp == e_mbf_camp_type.infantry then
			fScale = 0.55
			tPos = cc.p((tShowData.w * tShowData.fDzRw - 125),(tShowData.h * tShowData.fDzRh + 7))
		elseif tBuildData.nRecruitTp == e_mbf_camp_type.sowar then
			fScale = 0.5
			tPos = cc.p((tShowData.w * tShowData.fDzRw - 150),(tShowData.h * tShowData.fDzRh + 5))
		elseif tBuildData.nRecruitTp == e_mbf_camp_type.archer then
			fScale = 0.5
			tPos = cc.p((tShowData.w * tShowData.fDzRw - 160),(tShowData.h * tShowData.fDzRh + 8))
		else
			fScale = 0.45
			tPos = cc.p(100,(tShowData.h * tShowData.fDzRh + 8))
		end
	end
	return fScale, tPos, tShowData
end

return ItemAutoBuild


