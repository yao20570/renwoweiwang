----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-06 12:02:52
-- Description: 世界地图界面
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local WorldLayer = require("app.layer.world.WorldLayer")
-- local WorldLeft = require("app.layer.world.WorldLeft")
local WorldTargetLayer = require("app.layer.worldtarget.WorldTargetLayer")


--层次
local nWorldZorder = 0 --地图层
local nFogZorder = 2 --雾层
local nFogParticleZorder = 3 --雾层粒子
local nShadowZorder = 4
local nArrowZorder = 5 --地图箭头层
local nBlockNameZorder = 6 --区域名字
local nSmallMapZorder = 10 --小地图层
local nLeftZorder = 15 -- 左边层
local nLTItemZorder = 16 --左上小图标
local nSearchBtnZorder = 17 --搜索小按钮

local e_lt_item = {
	worldhelp = 1,--世界目标
	cfblood   = 2,--城池首杀
	freetostate = 3, --免费去州
	remains   = 4, --韬光养晦
}


--世界地图界面
local WorldPanel = class("WorldPanel", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function WorldPanel:ctor( nWidth, nHeight, nBottomH, nTopH)
	self.nWidth = nWidth
	self.nHeight = nHeight
	self.nBottomH = nBottomH
	self.nTopH = nTopH
	self.tItemLTList            =       {}      --左上边列表

	self:myInit()
	self:setContentSize(cc.size(nWidth, nHeight))
end

function WorldPanel:myInit(  )
	self:setupViews()
	self:onResume()

    --注册析构方法
	self:setDestroyHandler("WorldPanel",handler(self, self.onWorldPanelDestroy))
end

function WorldPanel:setupViews(  )

	--世界层
	local pSize = cc.size(self.nWidth, self.nHeight)
	self.pWorldLayer = WorldLayer.new(pSize, self, self.nBottomH, self.nTopH)
    self:addView(self.pWorldLayer, nWorldZorder)

    -- local pImgFog = MUI.MImage.new("#sg_sjdt_ywtx_0001.png")
    -- pImgFog:setPosition(self.nWidth/2, self.nHeight - pImgFog:getContentSize().height - self.nTopH)
    -- pImgFog:setScale(2.5)
    -- self:addView(pImgFog, nFogZorder)

    -- local pParitcle =  createParitcle("tx/other/lizi_sjduywlzi_002.plist")
	-- pParitcle:setPosition(0,self.nHeight - 200 + 170)
	-- self:addView(pParitcle, nFogParticleZorder)

    --是否开启远近视角
    if b_open_far_and_near_view_forworld then
		doDelayForSomething(self,function (  )
			-- body
			local ss = cc.Director:getInstance():getWinSize()
			local _nZeye = cc.Director:getInstance():getZEye()
			self._camera = cc.Camera:createPerspective(75, ss.width/ss.height, 1, 3000)
			self._camera:setCameraFlag(cc.CameraFlag.USER1)
			self._camera:setPosition3D(cc.vec3(ss.width / 2, 500, _nZeye))
			self._camera:lookAt(cc.vec3(ss.width / 2, ss.height/2, 0), cc.vec3(0, 1, 0))
            self._camera:setVisible(false)
			self.pWorldLayer:addChild(self._camera)
			self.pWorldLayer:setCameraMask(MUI.CAMERA_FLAG.USER1,true)
			self.pWorldLayer:setCamera(self._camera)

			--创建一样的摄像机用于最后面的渲染，注意效率，尽量少用(主要用于世界Boss)
			self._camera2 = cc.Camera:createPerspective(75, ss.width/ss.height, 1, 3000)
			self._camera2:setCameraFlag(cc.CameraFlag.USER3)
			self._camera2:setPosition3D(cc.vec3(ss.width / 2, 500, _nZeye))
			self._camera2:lookAt(cc.vec3(ss.width / 2, ss.height/2, 0), cc.vec3(0, 1, 0))
            self._camera2:setVisible(false)
			self.pWorldLayer:addChild(self._camera2)
			self.pWorldLayer:initCamera2Dot()
			--

			if(NEW_ROLE) then
				-- 定位到特殊点，一定要让9张草皮铺上去
				self.pWorldLayer:JumpToDotPos(20, 20)
			else
				--定位到我的城池
				self.pWorldLayer:JumpToMyCityDot()
			end
		end,0.1)
	end

	-- --箭头
	-- self.pArrowImg = MUI.MImage.new("#v1_img_sj_fanhui.png")
	-- self.pArrowImg:setViewTouched(true)
	-- local pSize = self.pArrowImg:getContentSize()
	-- local pArrowLabel = MUI.MLabel.new({"",size=18})
	-- pArrowLabel:setPosition(pSize.width/2 - 20, pSize.height/2)
	-- self.pArrowImg:setAnchorPoint(cc.p(1,0.5))
	-- self.pArrowImg:addChild(pArrowLabel)
	-- self.pArrowImg:setVisible(false)
	-- self.pArrowImg.pArrowLabel = pArrowLabel
	-- self:addView(self.pArrowImg, nArrowZorder)


	--暗图片遮罩
	local nIShadowW, nIShadowH = self.nWidth, self.nHeight - self.nBottomH - self.nTopH
	-- local pLayShadow = MUI.MLayer.new()
	-- pLayShadow:setLayoutSize(cc.size(nIShadowW, nIShadowH))
	-- pLayShadow:setBackgroundImage("#v1_img_zz_sj.png",{scale9 = true,capInsets=cc.rect(28, 209, 1, 1)})
	-- self:addView(pLayShadow, 999)
	-- pLayShadow:setPosition(0, self.nBottomH)

	local pImgShadow = MUI.MImage.new("#v1_img_zz_sj.png")
	self:addView(pImgShadow, nShadowZorder)
	pImgShadow:setScaleX(nIShadowW/pImgShadow:getContentSize().width)
	pImgShadow:setPosition(nIShadowW/2, self.nBottomH + pImgShadow:getContentSize().height/2)

	--已集成到顶部

    -- --左边层
    -- local pWorldLeft = WorldLeft.new()
    -- self:addView(pWorldLeft, nLeftZorder)
    -- self.pWorldLeft = pWorldLeft
    -- --左边层
    -- local pWorldLeft = WorldLeft.new()
    -- self:addView(pWorldLeft, nLeftZorder)
    -- self.pWorldLeft = pWorldLeft

	--已集成到顶部
 --    --国家城池图片
 --    local pImgCountry = MUI.MImage.new("#v1_btn_guojiachengchi.png")
 --    pImgCountry:setPosition(self.nWidth - pImgCountry:getContentSize().width/2, self.nHeight/2)
	-- self:addView(pImgCountry, nLeftZorder)
 --    pImgCountry:setViewTouched(true)
	-- pImgCountry:setIsPressedNeedScale(false)
	-- pImgCountry:onMViewClicked(function (  )
	-- 	local tObject = {
	-- 	    nType = e_dlg_index.dlgcountrycity, --dlg类型
	-- 	}
	-- 	sendMsg(ghd_show_dlg_by_type, tObject)
	-- end)

	--地图先创建
	local pWorldSmallMap = Player:getUIHomeLayer():getWorldSmallMap()
	if pWorldSmallMap then
		local pFingerUiPoint = pWorldSmallMap:getAnchorPointInPoints()
		local pWorldPoint = pWorldSmallMap:convertToWorldSpace(pFingerUiPoint);
		local pCurrPoint = self:convertToNodeSpace(pWorldPoint)
		local pRect = pWorldSmallMap:getBoundingBox()
		pRect.x = pCurrPoint.x
		pRect.y = pCurrPoint.y
		pRect.width = pRect.width + 20
		pRect.height = pRect.height + 20
		self.pRectSmallMap = pRect
	end

	--世界目标
	if not self.pHomeCenter then
		self.pHomeCenter =Player:getUIHomeLayer():getHomeCenter()
		if self.pHomeCenter then
			self.pWorldTargetLayer=self.pHomeCenter:getWorldTargetLayer()
			if self.pWorldTargetLayer then
				self.pWorldTargetLayer:setVisible(false)
			end
			self.pHomeCenter:refreshLayDownLeft()
		end
	end
	
	-- 任务
	local pHomeCenter = Player:getUIHomeLayer():getHomeCenter()
	if pHomeCenter then
		local pTask = pHomeCenter:getHomeTaskLayer()
		if pTask then
			local pFingerUiPoint = pTask:getAnchorPointInPoints()
			local pWorldPoint = pTask:convertToWorldSpace(pFingerUiPoint);
			local pCurrPoint = self:convertToNodeSpace(pWorldPoint)
			local pRect = pTask:getBoundingBox()
			pRect.x = pCurrPoint.x - 20
			pRect.y = pCurrPoint.y - 30
			pRect.width = 380
			pRect.height = pRect.height + 20
			self.pRectTask = pRect
		end
	end

	-- --测试鼠标碰撞框
	-- local pLayDebugDraw = MUI.MLayer.new()
	-- local pLaySize = self:getContentSize()
	-- pLayDebugDraw:setLayoutSize(pLaySize.width, pLaySize.height)
	-- self:addView(pLayDebugDraw)
	-- local nX, nY = pLaySize.width/2, pLaySize.height/2
	-- local pRect = self.pRectTask
	-- local tPoint = {
	-- 	{pRect.x,  pRect.y},
	-- 	{pRect.x + pRect.width,  pRect.y},
	-- 	{pRect.x + pRect.width,  pRect.y + pRect.height},
	-- 	{pRect.x,  pRect.y + pRect.height},
	-- }
	-- local tColor = {fillColor = cc.c4f(171/255,151/255,95/255,255),
 --    borderWidth  = 4,
 --    borderColor  = cc.c4f(1,0,0,179/255)} 
	-- local pNodeViewRect =  display.newPolygon(tPoint,tColor)
	-- pLayDebugDraw:addView(pNodeViewRect, 999)	

	--区域浮动名字，过3秒消失
	self.pLayBlockName = MUI.MLayer.new()
  	self:addView(self.pLayBlockName, nBlockNameZorder)
  	self.pLayBlockName:setLayoutSize(276, 68)
	self.pLayBlockName:setBackgroundImage("#v1_img_tishichangtiao.png",{scale9 = true,capInsets=cc.rect(276/2,43/2, 1, 1)})
	-- self.pLayBlockName:setContentSize(cc.size(276, 68))

	self.pTxtBlockName1 = MUI.MLabel.new({text = "", size = 24})
	self.pTxtBlockName1:setPosition(276/2, 68 * 0.7)
	self.pTxtBlockName2 = MUI.MLabel.new({text = "", size = 18})
	self.pTxtBlockName2:setPosition(276/2, 68 * 0.3)
	self.pLayBlockName:addView(self.pTxtBlockName1)
	self.pLayBlockName:addView(self.pTxtBlockName2)
	self.pLayBlockName:setVisible(false)

	-- --搜索按钮
	-- local pImgSearch = MUI.MImage.new("#v2_btn_zjm_sousuo.png")
	-- pImgSearch:setPosition(self.nWidth - pImgSearch:getContentSize().width/2 - 10, self.nHeight - 360)
	-- self:addView(pImgSearch, nSearchBtnZorder)
	-- pImgSearch:setViewTouched(true)
	-- pImgSearch:setIsPressedNeedScale(false)
	-- pImgSearch:setIsPressedNeedColor(false)
	-- pImgSearch:onMViewClicked(function ( _pView )
	--     local DlgFlow = require("app.common.dialog.DlgFlow")
	-- 	local pDlg,bNew = getDlgByType(e_dlg_index.worldsearch)
	-- 	if(not pDlg) then
	-- 		pDlg = DlgFlow.new(e_dlg_index.worldsearch)
	-- 	end
	-- 	local DlgWorldSearch = require("app.layer.worldsearch.DlgWorldSearch")
	-- 	local pChildView = DlgWorldSearch.new()
	-- 	pChildView:refreshData()
	-- 	pDlg:showChildView(nil, pChildView)
	-- 	pChildView:setPosition((self:getWidth() - pChildView:getWidth())/2, 0)
	-- 	UIAction.enterDialog( pDlg, RootLayerHelper:getCurRootLayer(), bNew)
	-- 	pDlg:setDialogBgColor(GLOBAL_DIALOG_BG_COLOR_TRANSPARENT)

	-- end)
end


-- 析构方法
function WorldPanel:onWorldPanelDestroy(  )
    self:onPause()
end

-- 注册消息
function WorldPanel:regMsgs( )
	-- 大地图视图移动
	regMsg(self, ghd_world_view_pos_msg, handler(self, self.onShowBlockName))
	-- 注册主公等级变化消息
	regMsg(self, ghd_refresh_playerlv_msg, handler(self, self.onPlayerLvUp))
	--监听首杀红点
	regMsg(self, gud_city_first_blood_red, handler(self, self.updateCFBloodRedNum))
	--刷新每日免费迁往州的次数刷新
	regMsg(self, ghd_refresh_freetostate_msg, handler(self, self.refreshFreeToState))
	--自己城池位置发生改变
	regMsg(self, gud_world_my_city_pos_change_msg, handler(self, self.refreshFreeToState))
	--韬光养晦刷新
	regMsg(self, ghd_remains_refresh_msg, handler(self, self.refreshItemRemains))
end

-- 注销消息
function WorldPanel:unregMsgs(  )
	-- 大地图视图移动
	unregMsg(self, ghd_world_view_pos_msg)
	--注册主公等级变化消息
	unregMsg(self, ghd_refresh_playerlv_msg)
	--监听首杀红点
	unregMsg(self, gud_city_first_blood_red)
	--刷新每日免费迁往州的次数刷新
	unregMsg(self, ghd_refresh_freetostate_msg)
	--自己城池位置发生改变
	unregMsg(self, gud_world_my_city_pos_change_msg)
	--韬光养晦刷新
	unregMsg(self, ghd_remains_refresh_msg)
end

--暂停方法
function WorldPanel:onPause( )
	self:unregMsgs()
end

--继续方法
function WorldPanel:onResume( )
	self:updateViews()
	self:regMsgs()
end

function WorldPanel:updateViews(  )
	self:refreshWorldHelp()
	self:refreshCFBlood()
	self:refreshFreeToState()
	self:refreshItemRemains()
end

-- --获取箭头
-- function WorldPanel:getArrowImg(  )
-- 	return self.pArrowImg
-- end

--获取小地图矩形
function WorldPanel:getSmallMapRect(  )
	return self.pRectSmallMap
end

--获取任务矩形
function WorldPanel:getTaskRect(  )
	return self.pRectTask
end

-- --获取左边对联
-- function WorldPanel:getWorldLeft(  )
-- 	return self.pWorldLeft
-- end

--显示区域名字
function WorldPanel:onShowBlockName( sMsgName, pMsgObj )
	if not pMsgObj then
		return
	end

	if not pMsgObj.nBlockId then
		self.sPrevBlockName = nil
		self.nPrevBlockCountry = nil
		return
	end

	if not Player:getWorldData():getBlockIsCanSee(pMsgObj.nBlockId) then
		self.sPrevBlockName = nil
		self.nPrevBlockCountry = nil
		return
	end

	local tBlockData = getWorldMapDataById(pMsgObj.nBlockId)
	if not tBlockData then
		return
	end

	local sName = tBlockData.name
	local nCountry = Player:getWorldData():getMainCityCaptureCountry(tBlockData.maincity)

	--重复不刷新
	if self.sPrevBlockName ~= sName or self.nPrevBlockCountry ~= nCountry then
		self.sPrevBlockName = sName
		self.nPrevBlockCountry = nCountry

		--颜色
		local sColor = _cc.yellow
		if e_type_country.shuguo == nCountry then
			sColor = _cc.red
		elseif e_type_country.weiguo == nCountry then
			sColor = _cc.blue
		elseif e_type_country.wuguo == nCountry then
			sColor = _cc.green
		end

		self.pTxtBlockName1:setString(sName)
		setTextCCColor(self.pTxtBlockName1, sColor)

		self.pTxtBlockName2:setString(getCountryName(nCountry)..getConvertedStr(3, 10446))
		setTextCCColor(self.pTxtBlockName2, sColor)

		--表现动作
		self.pLayBlockName:stopAllActions()
		local nX, nY = self:getContentSize().width/2 - self.pLayBlockName:getContentSize().width/2,  self:getContentSize().height/2 + 200
		self.pLayBlockName:setPosition(nX, nY)
		self.pLayBlockName:setOpacity(255)
		self.pLayBlockName:setVisible(false)

		--表现
		local pActionDelay = cc.DelayTime:create(1) -- 停留一定时间
		local pActionShow = cc.Show:create()
        local pAction1 = cc.MoveBy:create(0.35, cc.p(0, 10)) -- 上移一定的像素点
        local pAction2 = cc.DelayTime:create(1.5) -- 停留一定时间
        local pAction3 = cc.Spawn:create(
            cc.MoveBy:create(0.45, cc.p(0, 30)), -- 上移
            cc.FadeOut:create(0.45)) -- 渐隐
        local pAction4 = cc.CallFunc:create(function (  )
            self.pLayBlockName:setVisible(false)
        end)
        --自身的表现集合
        local actionsStep1 = cc.Sequence:create(pActionDelay, pActionShow, pAction1,pAction2,pAction3,pAction4)
        self.pLayBlockName:runAction(actionsStep1)
	end
end

--主公等级发生变化
function WorldPanel:onPlayerLvUp( )
	self:refreshWorldHelp()
	self:refreshCFBlood()
end

--刷新世界
function WorldPanel:refreshWorldHelp( )
	if b_open_world_help then
		--获取开放等级范围
		local tLv = getWorldInitData("worldHelpIcon")
		if Player.baseInfos.nLv >= tLv[1] and Player.baseInfos.nLv <= tLv[2] then
			local sIcon = getWorldInitData("worldIcon") or  "v1_btn_biaoqing"
			local tData = {
				nId = e_lt_item.worldhelp,
				sIcon = "#"..sIcon..".png",
				onClickedFunc = handler(self, self.onWorldHelpClick)
			}
			self:addItemLT(tData)
		else
			self:removeItemLT(e_lt_item.worldhelp)
		end
	end
end

--点击世界帮忙
function WorldPanel:onWorldHelpClick( _pView )
	local tObject = {}
	tObject.nType = e_dlg_index.dlgworldhelp --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)
end

--城池首杀
function WorldPanel:refreshCFBlood( )
	--关闭入口
	if Player:getWorldData():getCFBloodClose() then
		self:removeItemLT(e_lt_item.cityfirstblood)
		return
	end

	if getIsReachOpenCon(14, false) then
		local tData = {
			nId = e_lt_item.cfblood,
			sIcon = "#v1_btn_chengchishousha.png",
			onClickedFunc = handler(self, self.onCFBloodClick)
		}
		self:addItemLT(tData)
		self:updateCFBloodRedNum()
	else
		self:removeItemLT(e_lt_item.cityfirstblood)
	end
end

--点击城池首杀
function WorldPanel:onCFBloodClick( _pView )
	local tObject = {}
	tObject.nType = e_dlg_index.cityfirstblood --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)
end
--免费去州
function WorldPanel:refreshFreeToState()
	-- body	
	--剩余免费次数
	local nLeftTimes = Player:getWorldData():getTodayFreeChangeCityTimes()
	local nMyBlockId = Player:getWorldData():getMyCityBlockId()
	local tBlockData = getWorldMapDataById(nMyBlockId)
	--世界地图的开启状态--0开郡,--1开州,--2开皇城
	local nState = Player:getWorldData():getWorldOpenState()
	--州为开启或者玩家位置在郡
	--print("nLeftTimes=", nLeftTimes)
	if nState < 1 or e_type_block.jun ~= tBlockData.type then
		--print("-----------111111111111")
		self:removeItemLT(e_lt_item.freetostate)
		return
	end
	if not self:getItemLT(e_lt_item.freetostate) then				
		local tData = {
			nId = e_lt_item.freetostate,
			sIcon = "#v1_btn_mianfeiquzhou.png",
			onClickedFunc = handler(self, self.onFreeToStateClick)
		}
		self:addItemLT(tData)
	end
	local pItem = self:getItemLT(e_lt_item.freetostate)
	showRedTips(pItem, 1, nLeftTimes, 2)	
end

function WorldPanel:onFreeToStateClick( _pView )
	-- body
	local DlgAlert = require("app.common.dialog.DlgAlert")
    local pDlg = getDlgByType(e_dlg_index.alert)
    if(not pDlg) then
        pDlg = DlgAlert.new(e_dlg_index.alert)
    end
    pDlg:setTitle(getConvertedStr(3, 10091))
    local nMax = tonumber(getWorldInitData("maxFreeMigrate2Zhou"))
    local sStr = string.format(getTipsByIndex(20077), nMax)
    pDlg:setContent(sStr)
    local pBtn = pDlg:getOnlyConfirmButton(TypeCommonBtn.L_BLUE, getConvertedStr(6, 10640))
    pDlg:setOnlyConfirmBtnHeight(0)
    local nLeftTimes = Player:getWorldData():getTodayFreeChangeCityTimes()
    local sColor = _cc.red
    if nLeftTimes > 0 then
    	sColor = _cc.green
    end
	local tConTable = {}
	local tLabel = {
	 {getConvertedStr(6, 10641),getC3B(_cc.pwhite)},
	 {nLeftTimes,getC3B(sColor)},
	 {"/"..tostring(nMax),getC3B(_cc.pwhite)},
	}
	tConTable.tLabel = tLabel
	tConTable.awayH = -10
    pBtn:setBtnExText(tConTable)
    pDlg:setRightHandler(function (  )
		--不够45级就
		local nNeedLv = getWorldInitData("stateMinLimit")
		if Player:getPlayerInfo().nLv < nNeedLv then
			TOAST(string.format(getTipsByIndex(20088), nNeedLv))
			return
		end
		SocketManager:sendMsg("freetostate", {})
		--关闭本框
        pDlg:closeDlg(false)
    end)
    pDlg:showDlg(bNew)	
end


--韬光养晦
function WorldPanel:refreshItemRemains(  )
	-- body
	local pRemainsData = Player:getRemainsData()
	if not pRemainsData or not pRemainsData:isOpen() then
		self:removeItemLT(e_lt_item.remains)
		return
	end
	local nRedNum = pRemainsData:getRewardRedNum()
	if not self:getItemLT(e_lt_item.remains) then				
		local tData = {
			nId = e_lt_item.remains,
			sIcon = "#v1_btn_taoguangyanghui.png",
			onClickedFunc = handler(self, self.onItemRemainsClicked)
		}
		self:addItemLT(tData)
	end
	local pItem = self:getItemLT(e_lt_item.remains)
	showRedTips(pItem, 1, nRedNum, 2)		
end
--韬光养晦 Item点击事件
function WorldPanel:onItemRemainsClicked(  )
	-- body
	local tObject = {}
	tObject.nType = e_dlg_index.dlgremains --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)   
end

function WorldPanel:getItemLT( _nType )	
	-- body
	if not _nType then
		return nil
	end
	local pItem = nil
	for i=1,#self.tItemLTList do
		if self.tItemLTList[i].nId == _nType then
			pItem = self.tItemLTList[i]
			break
		end
	end	
	return pItem
end
--添加左上角其中一个id
function WorldPanel:addItemLT( tData )
	local bIsNew = true
	for i=1, #self.tItemLTList do
		local pItem = self.tItemLTList[i]
		if tData.nId == pItem.nId then
			bIsNew = false
			break
		end
	end
	if bIsNew then
		local pImg = MUI.MImage.new(tData.sIcon)
		local pItem = MUI.MLayer.new()
		local pSize = pImg:getContentSize()
		pItem:setLayoutSize(pSize.width, pSize.height)
		pItem:addView(pImg)
		centerInView(pItem, pImg)
		pItem.nId = tData.nId
		pItem:setViewTouched(true)
		pItem:setIsPressedNeedScale(false)
		pItem:onMViewClicked(tData.onClickedFunc)
		self:addView(pItem, nLTItemZorder)
		table.insert(self.tItemLTList, pItem)
		--排序
		table.sort(self.tItemLTList, function(a, b)
			return a.nId < b.nId
		end)
		self:updateItemLTListPoses()
	end
end

--移除左上角其中一个id
function WorldPanel:removeItemLT( nId )
	for i=1, #self.tItemLTList do
		local pItem = self.tItemLTList[i]
		if nId == pItem.nId then
			pItem:removeFromParent(true)
			table.remove(self.tItemLTList,i)
			--排序
			table.sort(self.tItemLTList, function(a, b)
				return a.nId < b.nId
			end)
			self:updateItemLTListPoses()
			break
		end
	end
end

--更新左上角列表位置
function WorldPanel:updateItemLTListPoses( )
	local tStartPos = cc.p(10, self.nHeight - self.nTopH - 125)
	local nOffsetX = 20
	for i=1,#self.tItemLTList do
		self.tItemLTList[i]:setPosition(tStartPos)
		tStartPos.x = tStartPos.x + self.tItemLTList[i]:getContentSize().width + nOffsetX
	end
end

--更新首杀红点
function WorldPanel:updateCFBloodRedNum( )
	for i=1,#self.tItemLTList do
		if self.tItemLTList[i].nId == e_lt_item.cfblood then
			local bIsNew = Player:getWorldData():getFirstBloodRedInBlock(Player:getWorldData():getMyCityBlockId())
			if bIsNew then
				showRedTips(self.tItemLTList[i], 0, 1, 2)
			else
				showRedTips(self.tItemLTList[i], 0, 0, 2)
			end
			break
		end
	end
end

return WorldPanel