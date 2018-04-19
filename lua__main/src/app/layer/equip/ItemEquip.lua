----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-01 15:48:14
-- Description: 装备背包 装备列表子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local EquipInfoLayer = require("app.module.EquipInfoLayer")

local ItemEquip = class("ItemEquip", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)


function ItemEquip:ctor(  )
	--解析文件
	parseView("item_equip_bag_equip", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemEquip:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemEquip", handler(self, self.onItemEquipDestroy))
end

-- 析构方法
function ItemEquip:onItemEquipDestroy(  )
    self:onPause()
end

function ItemEquip:regMsgs(  )
end

function ItemEquip:unregMsgs(  )
end

function ItemEquip:onResume(  )
	self:regMsgs()
end

function ItemEquip:onPause(  )
	self:unregMsgs()
end

function ItemEquip:setupViews(  )
	self.pLayEquip = self:findViewByName("lay_equip")
	
	local pLayBtnWear = self:findViewByName("lay_btn_wear")
	local pBtnWear = getCommonButtonOfContainer(pLayBtnWear, TypeCommonBtn.M_BLUE, getConvertedStr(3, 10287))
	-- setMCommonBtnScale(pLayBtnWear, pBtnWear, 0.8)
	pBtnWear:onCommonBtnClicked(handler(self, self.onWearClicked))
	self.pBtnWear = pBtnWear
end

function ItemEquip:updateViews(  )	
	if not self.sUuid then
		return
	end
	--装备
	local tEquipVo = Player:getEquipData():getEquipVoByUuid(self.sUuid)
	if tEquipVo then
		if not self.pEquipInfoLayer then
			self.pEquipInfoLayer = EquipInfoLayer.new()
			self.pLayEquip:addView(self.pEquipInfoLayer)
		end
		self.pEquipInfoLayer:setCurData(tEquipVo)

		local function showFingerGuide()
			-- body
			sendMsg(ghd_guide_finger_show_or_hide, true)
			if tEquipVo.nId == e_wear_equip_id.wear_gun then
				Player:getNewGuideMgr():setNewGuideFinger(self.pBtnWear, e_guide_finer.wear_gun_btn)
			elseif tEquipVo.nId == e_wear_equip_id.wear_sword then
				Player:getNewGuideMgr():setNewGuideFinger(self.pBtnWear, e_guide_finer.wear_sword_btn)
			elseif tEquipVo.nId == e_wear_equip_id.wear_corselet then
				Player:getNewGuideMgr():setNewGuideFinger(self.pBtnWear, e_guide_finer.wear_corselet_btn)
			elseif tEquipVo.nId == e_wear_equip_id.wear_helmet then
				Player:getNewGuideMgr():setNewGuideFinger(self.pBtnWear, e_guide_finer.wear_helmet_btn)
			elseif tEquipVo.nId == e_wear_equip_id.wear_yin then
				Player:getNewGuideMgr():setNewGuideFinger(self.pBtnWear, e_guide_finer.wear_yin_btn)
			elseif tEquipVo.nId == e_wear_equip_id.wear_fu then
				Player:getNewGuideMgr():setNewGuideFinger(self.pBtnWear, e_guide_finer.wear_fu_btn)
			end
		end

		--新手引导设置入口
		doDelayForSomething(self, showFingerGuide, 0.02)

	end
end

--sUuid 装备uuid
--nHeroId 武将id
function ItemEquip:setData( sUuid, nHeroId)
	self.sUuid = sUuid
	self.nHeroId = nHeroId
	self:updateViews()
end

function ItemEquip:onWearClicked( pView )
	-- dump({self.sUuid, self.nHeroId})
	SocketManager:sendMsg("reqEquipWear", {self.sUuid, self.nHeroId},function ( __msg )
		-- body
		if __msg.head.state == SocketErrorType.success then
			--播放音效
			Sounds.playEffect(Sounds.Effect.equip)
		end
	end)
	sendMsg(gud_close_dlg_equip_bag)

	--新手引导
	if B_GUIDE_LOG then
		print("B_GUIDE_LOG ItemEquip 装备穿上点击回调")
	end
	Player:getNewGuideMgr():onClickedNewGuideFinger(self.pBtnWear)
end

function ItemEquip:getBtn(  )
	return self.pBtnWear
end

return ItemEquip


