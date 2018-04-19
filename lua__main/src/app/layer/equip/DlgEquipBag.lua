----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-01 15:02:24
-- Description: 装备背包
-----------------------------------------------------

-- 装备背包
local EquipedLayer = require("app.layer.equip.EquipedLayer")
local EquipsLayer = require("app.layer.equip.EquipsLayer")
local DlgBase = require("app.common.dialog.DlgBase")
local DlgEquipBag = class("DlgEquipBag", function()
	return DlgBase.new(e_dlg_index.equipbag)
end)

--sUuid:装备uuid
--nKind: 装备类型
--nHeroId: 武将id
function DlgEquipBag:ctor( sUuid, nKind, nHeroId)
	self.sUuid = nil 
	self.nKind = nil
	self.nHeroId = nil
	self.pEquipedLayer = nil
	self.pEquipsLayer = nil
	self:setEquipBagParam(sUuid, nKind, nHeroId)
	parseView("dlg_equip_bag", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgEquipBag:onParseViewCallback( pView )	
	self:addContentView(pView) --加入内容层

	self:setTitle(getConvertedStr(3, 10284))

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgEquipBag",handler(self, self.onDlgEquipBagDestroy))
end

-- 析构方法
function DlgEquipBag:onDlgEquipBagDestroy(  )
    self:onPause()
end

function DlgEquipBag:regMsgs(  )
	regMsg(self, gud_close_dlg_equip_bag, handler(self, self.onCloseFunc))
end

function DlgEquipBag:unregMsgs(  )
	unregMsg(self, gud_close_dlg_equip_bag)
end

function DlgEquipBag:onCloseFunc()
	self:closeDlg(false)
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgEquipBag:onResume( _bReshow )
	self:updateViews()
	self:regMsgs()	
	if _bReshow then
		if not gIsNull(self.pEquipedLayer) then
			self.pEquipedLayer:onResume(_bReshow)
		end
		if not gIsNull(self.pEquipsLayer) then
			self.pEquipsLayer:onResume(_bReshow)
		end
	end
end
--暂停方法
function DlgEquipBag:onPause(  )		
	self:unregMsgs()
	Player:getEquipData():setEquipVosNoNew(self.nKind)
	if not gIsNull(self.pEquipedLayer) and self.pEquipedLayer.onPause then
		self.pEquipedLayer:onPause()
	else
		self.pEquipedLayer = nil
	end
	if not gIsNull(self.pEquipsLayer) and self.pEquipsLayer.onPause then
		self.pEquipsLayer:onPause()
	else
		self.pEquipsLayer = nil
	end
end

function DlgEquipBag:setupViews()
    local pLayDefault = self:findViewByName("dlg_equip_bag")
    self.pLayRoot = pLayDefault:findViewByName("view")
    local pBannerImage = self.pLayRoot:findViewByName("img_banner_bg")
    setMBannerImage(pBannerImage, TypeBannerUsed.zbbb)

    self.pLayContent = self.pLayRoot:findViewByName("lay_content")
end

function DlgEquipBag:updateViews(  )
	
	local nHeight = self.pLayContent:getHeight()
	local nX = 0
	if self.sUuid then
		if not self.pEquipedLayer then
			self.pEquipedLayer = EquipedLayer.new(self.sUuid, self.nHeroId)			
			self.pLayContent:addView(self.pEquipedLayer, 10)
		else		
			self.pEquipedLayer:setEquipParam(self.sUuid, self.nHeroId)
		end
		local nY = nHeight - self.pEquipedLayer:getHeight()
		self.pEquipedLayer:setPosition(nX, nY)		
		self.pEquipedLayer:updateViews()
		nHeight = nHeight - self.pEquipedLayer:getHeight()
	else
		if self.pEquipedLayer then
			self.pEquipedLayer:removeSelf()
			self.pEquipedLayer = nil
		end
	end

	local nY = 30
	if not self.pEquipsLayer then
		self.pEquipsLayer = EquipsLayer.new(cc.size(640 , nHeight - nY), self.nKind, self.nHeroId)
		self.pEquipsLayer:setPosition(nX, nY)
		self.pLayContent:addView(self.pEquipsLayer, 1)
	else
		self.pEquipsLayer:setViewSize(cc.size(640 , nHeight - nY))
		self.pEquipsLayer:setEquipParam(self.nKind, self.nHeroId)
		self.pEquipsLayer:updateViews()
	end	
end

function DlgEquipBag:setEquipBagParam( sUuid, nKind, nHeroId )
	-- body
	self.sUuid = sUuid or nil 
	self.nKind = nKind
	self.nHeroId = nHeroId	
end


return DlgEquipBag