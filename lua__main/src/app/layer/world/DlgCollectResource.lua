----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-19 17:41:19
-- Description: 采集资源界面
-----------------------------------------------------
-- 采集资源界面
local DlgBase = require("app.common.dialog.DlgBase")
local CollectResourceNoOccupy = require("app.layer.world.CollectResourceNoOccupy")
local CollectResourceOccupy = require("app.layer.world.CollectResourceOccupy")
local DlgCollectResource = class("DlgCollectResource", function()
	return DlgBase.new(e_dlg_index.collectres)
end)

function DlgCollectResource:ctor(  )
	parseView("dlg_collect_resource", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgCollectResource:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层

	self:setTitle(getConvertedStr(3, 10056))

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgCollectResource",handler(self, self.onDlgCollectResourceDestroy))
end

-- 析构方法
function DlgCollectResource:onDlgCollectResourceDestroy(  )
    self:onPause()
end

function DlgCollectResource:regMsgs(  )
	--视图点改变
	regMsg(self, gud_world_dot_change_msg, handler(self, self.onDotChange))
end

function DlgCollectResource:unregMsgs(  )
	--视图点改变
	unregMsg(self, gud_world_dot_change_msg)
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgCollectResource:onResume( _bReshow  )
	self:updateViews()	
	self:regMsgs()
	if not gIsNull(self.pCurrContent) then
		self.pCurrContent:onResume()
	end
end

--暂停方法
function DlgCollectResource:onPause(  )
	self:unregMsgs()
	if not gIsNull(self.pCurrContent) then
		self.pCurrContent:onPause()
	end
end

function DlgCollectResource:setupViews(  )
	self.pTxtName = self:findViewByName("txt_name")
	setTextCCColor(self.pTxtName, _cc.white)

	self.pLayIcon = self:findViewByName("lay_icon")
	self.pLayIcon1 = self:findViewByName("lay_icon1")
	self.pTxtResName = self:findViewByName("txt_res_name")

	self.pTxtPos = self:findViewByName("txt_pos")
	setTextCCColor(self.pTxtPos, _cc.white)
	self.pTxtMoveTime = self:findViewByName("txt_move_time")
	setTextCCColor(self.pTxtMoveTime, _cc.white)
	local pTxtBannerTip1 = self:findViewByName("txt_banner_tip1")
	pTxtBannerTip1:setString(getConvertedStr(3, 10116))
	self.pTxtBannerTip2 = self:findViewByName("lay_banner_tip2")

	local pTxtRemain = self:findViewByName("txt_remain")
	self.pTxtRemain = pTxtRemain

	local pTxtSpeed = self:findViewByName("txt_speed")
	self.pTxtSpeed = pTxtSpeed

	self.pTxtCollectTime = self:findViewByName("txt_collect_time")

	self.pTxtPreview = self:findViewByName("txt_preview")

	self.pLayContent = self:findViewByName("lay_content")

	--显示活动便签
	local nActivityId=getIsShowActivityBtn(self.eDlgType)
    if nActivityId>0 then
    	self.pLayActBtn=self:findViewByName("lay_act_btn")
    	self.pActBtn = addActivityBtn(self.pLayActBtn,nActivityId)
    else
    	if self.pActBtn then
    		self.pActBtn:removeSelf()
    		self.pActBtn=nil
    	end
    end
    
end

function DlgCollectResource:updateViews(  )
	if not self.tData then
		return
	end
	if not self.tMine then
		return
	end
	WorldFunc.getMineIconOfContainer(self.pLayIcon, self.tData.nMineID, true)

	--资源图片
	local tGood = getGoodsByTidFromDB(self.tMine.output)
    if tGood then
    	local sImgPath = tGood.sIcon
    	if not self.pImgRes then
			self.pImgRes = MUI.MImage.new(sImgPath)
			self.pLayIcon1:addView(self.pImgRes)
			centerInView(self.pLayIcon1, self.pImgRes)
		else
			self.pImgRes:setCurrentImage(sImgPath)
		end
		self.pTxtResName:setString(tGood.sName)
    end

	self.pTxtName:setString(self.tMine.name .. getLvString(self.tMine.level))

	self.pTxtPos:setString(getConvertedStr(3, 10109) .. getWorldPosString(self.tData.nX, self.tData.nY))

	local nMoveTime = WorldFunc.getMyArmyMoveTime(self.tData.nX, self.tData.nY)
	self.pTxtMoveTime:setString(getConvertedStr(3, 10019) .. formatTimeToMs(nMoveTime))

    local tStr = {
    	{color=_cc.white,text=getConvertedStr(3, 10119)},
    	{color=_cc.blue,text=getResourcesStr(self.tData.nRemainRes)},
    	{color=_cc.white,text="/"..getResourcesStr(self.tMine.limit)},
    }
    self.pTxtRemain:setString(tStr)


    local tStr = {
 		{color=_cc.white,text=getConvertedStr(3, 10120)},
    	{color=_cc.blue,text=getResourcesStr(self.tMine.crop)},
    	{color=_cc.white,text="/"..getConvertedStr(3, 10121)},
    }
    self.pTxtSpeed:setString(tStr)

	--判断是否被占领
	if self.tData.bIsOccupyer then
		self.pTxtBannerTip2:setString(getConvertedStr(3, 10118))
	else
		self.pTxtBannerTip2:setString(getTipsByIndex(20084))
	end

	if self.pCurrContent then
		self.pCurrContent:updateViews()
	end
	
end

function DlgCollectResource:getTxtCollectTime(  )
	return self.pTxtCollectTime
end

function DlgCollectResource:getTxtPreview(  )
	return self.pTxtPreview
end

--tData:tViewDotMsg
function DlgCollectResource:setData( tData )
	self.tData = tData

	self.tMine = getWorldMineData(self.tData.nMineID)
	self.nMoveTime = WorldFunc.getMyArmyMoveTime(self.tData.nX, self.tData.nY)
	--更新视图
	self:updateViews()

	--判断是否被占领
	if self.tData.bIsOccupyer then
		self:setBottomType(1)
	else
		self:setBottomType(2)
	end
end

--设置下
--nBottomType 1: 显示别人占领状态, 2：出征状态 
function DlgCollectResource:setBottomType( nBottomType )
	if nBottomType == 1 then
		--隐藏没有人占领
		if self.pNoOccupy then
			self.pNoOccupy:setVisible(false)
		end
		--显示有人占领
		if not self.pOccupy then
			self.pOccupy = CollectResourceOccupy.new(self)
			self.pLayContent:addView(self.pOccupy)
		end
		self.pOccupy:setVisible(true)
		self.pOccupy:setData( self.tData, self.tMine )
		self.pCurrContent = self.pOccupy
	else
		--隐藏有人占领
		if self.pOccupy then
			self.pOccupy:setVisible(false)
		end
		--显示没有人占领
		if not self.pNoOccupy then
			self.pNoOccupy = CollectResourceNoOccupy.new(self)
			self.pLayContent:addView(self.pNoOccupy)
		end
		self.pNoOccupy:setVisible(true)
		self.pNoOccupy:setData( self.tData, self.tMine )
		self.pCurrContent = self.pNoOccupy
	end
end

function DlgCollectResource:onCloseFunc()
	self:onCloseClicked()
end

function DlgCollectResource:onDotChange( sMsgName, pMsgObj )
	if not self.tData then
		return
	end
	--更新资源点更新
	local tViewDotMsg = pMsgObj
	if tViewDotMsg then
		if tViewDotMsg.nX == self.tData.nX and tViewDotMsg.nY == self.tData.nY and  tViewDotMsg.nType == self.tData.nType then
			self:setData(tViewDotMsg)
		end
	end
end

return DlgCollectResource