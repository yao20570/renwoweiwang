----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-01 15:06:34
-- Description: 装备背包 已装备层
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local EquipInfoLayer = require("app.module.EquipInfoLayer")

local EquipedLayer = class("EquipedLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--sUuid 装备uuid
--nHeroId 武将id
function EquipedLayer:ctor( sUuid, nHeroId)
	self.sUuid = nil
	self.nHeroId = nil
	self:setEquipParam(sUuid, nHeroId)
	--解析文件
	parseView("lay_equip_bag_equiped", handler(self, self.onParseViewCallback))
end

--解析界面回调
function EquipedLayer:onParseViewCallback( pView )
	self:setLayoutSize(pView:getLayoutSize())	
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()	
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("EquipedLayer", handler(self, self.onEquipedLayerDestroy))
end

-- 析构方法
function EquipedLayer:onEquipedLayerDestroy(  )
    self:onPause()
end

function EquipedLayer:regMsgs(  )
	regMsg(self, gud_equip_refine_success_msg, handler(self, self.updateViews))
end

function EquipedLayer:unregMsgs(  )
	unregMsg(self, gud_equip_refine_success_msg)
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function EquipedLayer:onResume( _bReshow )
	self:updateViews()
	self:regMsgs()
end

--暂停方法
function EquipedLayer:onPause(  )
	self:unregMsgs()
end

function EquipedLayer:setupViews(  )


end

function EquipedLayer:updateViews(  )
	if not self.pLayRoot then
		self.pLayRoot = self:findViewByName("lay_equip_bag_equiped")

		local pTxtBanner = self:findViewByName("lb_title")
		pTxtBanner:setString(getConvertedStr(3, 10285))

		local pLayBtnShare = self:findViewByName("lay_btn_share")
		local pBtnShare = getCommonButtonOfContainer(pLayBtnShare, TypeCommonBtn.M_BLUE, getConvertedStr(3, 10003))
		-- setMCommonBtnScale(pLayBtnShare, pBtnShare, 0.8)
		pBtnShare:onCommonBtnClicked(handler(self, self.onShareClicked))
	
		-- local tEquipVo = Player:getEquipData():getEquipVoByUuid(self.sUuid)
		-- if tEquipVo then
		-- 	local pEquipInfoLayer = EquipInfoLayer.new()
		-- 	--pEquipInfoLayer:setCurData(tEquipVo)
		-- 	local pLayEquip = self:findViewByName("lay_equip")
		-- 	pLayEquip:addView(pEquipInfoLayer)
		-- 	self.pEquipInfoLayer = pEquipInfoLayer
		-- end
		
		local pLayBtnTakeOff = self:findViewByName("lay_btn_takeoff")
		local pBtnTakeOff = getCommonButtonOfContainer(pLayBtnTakeOff, TypeCommonBtn.M_RED, getConvertedStr(3, 10286))
		-- setMCommonBtnScale(pLayBtnTakeOff, pBtnTakeOff, 0.8)
		pBtnTakeOff:onCommonBtnClicked(handler(self, self.onTakeOffClicked))
		
		local pLayBtnRefine = self:findViewByName("lay_btn_refine")
		local pBtnRefine = getCommonButtonOfContainer(pLayBtnRefine, TypeCommonBtn.M_YELLOW, getConvertedStr(3, 10270))
		-- setMCommonBtnScale(pLayBtnRefine, pBtnRefine, 0.8)
		pBtnRefine:onCommonBtnClicked(handler(self, self.onRefineClicked))

		--装备
		local pEquipInfoLayer = EquipInfoLayer.new()
		--pEquipInfoLayer:setCurData(tEquipVo)
		local pLayEquip = self:findViewByName("lay_equip")
		pLayEquip:addView(pEquipInfoLayer)
		self.pEquipInfoLayer = pEquipInfoLayer	
		centerInView(pLayEquip, self.pEquipInfoLayer)				
	end	

	local tEquipVo = Player:getEquipData():getEquipVoByUuid(self.sUuid)
	if tEquipVo then
		self.pEquipInfoLayer:setCurData(tEquipVo)
		self.pEquipInfoLayer:updateViews()
	end

end


function EquipedLayer:onShareClicked( pView )
	--打开分享
	local tEquipVo = Player:getEquipData():getEquipVoByUuid(self.sUuid)
	local tEquipData = tEquipVo:getConfigData()
	openShare(pView, e_share_id.equip, {"c^g_"..tEquipData.sTid,tEquipVo:getSolidStarNum()},
	 self.sUuid)
end

function EquipedLayer:onTakeOffClicked( pView )
	local bIsWillFull = Player:getEquipData():isEquipWillFull(1)
	if bIsWillFull then
		sendMsg(ghd_equipBag_fulled_msg)
		return
	end
	SocketManager:sendMsg("reqEquipTakeOff", {self.sUuid, self.nHeroId})
	sendMsg(gud_close_dlg_equip_bag)
end

--去洗练铺
function EquipedLayer:onRefineClicked( pView )
	local tObject = {
	    nType = e_dlg_index.smithshop,
	    sUuid = self.sUuid,
	    nHeroId = self.nHeroId,
	    nFuncIdx = n_smith_func_type.train
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

function EquipedLayer:setEquipParam( sUuid, nHeroId )
	-- body
	self.sUuid = sUuid
	self.nHeroId = nHeroId
end
return EquipedLayer


