-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-04-16 16:37:23 星期一
-- Description: 女将对话框
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local FCommonTabHost = require("app.common.tabhost.FCommonTabHost")
local LayoutFemaleLookfor = require("app.layer.femalehero.LayoutFemaleLookfor")
local LayoutFemaleHeros = require("app.layer.femalehero.LayoutFemaleHeros")
local LayoutFemaleHeroShop = require("app.layer.femalehero.LayoutFemaleHeroShop")

local DlgFemaleHeros = class("DlgFemaleHeros", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgfemaleheros)
end)

function DlgFemaleHeros:ctor(  )
	-- body
	self:myInit()
    self.pLayRoot = MUI.MFillLayer.new()
    self.pLayRoot:setViewTouched(false)
    self.pLayRoot:setLayoutSize(640, 1060)
    self:addContentView(self.pLayRoot)
	--设置标题
	self:setTitle(getConvertedStr(6,10853))
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgFemaleHeros",handler(self, self.onDestroy))
	
end

function DlgFemaleHeros:myInit(  )
	-- body	
	self.nCurIndex 	= -1
	self.tPages = {}
end

--控件刷新
function DlgFemaleHeros:updateViews(  )
	self.nCurIndex = 1
	if not self.pTabHost then
		local pLayTab 			= 		self.pLayRoot
		local tTitles = {getConvertedStr(6, 10854), getConvertedStr(6, 10853), getConvertedStr(6, 10855)}

		self.pTabHost = FCommonTabHost.new(pLayTab,1,1,tTitles,handler(self, self.getLayerByKey), 1)
		self.pTabHost:setLayoutSize(pLayTab:getLayoutSize())
		self.pTabHost:removeLayTmp1()
		self.pTabHost:removeLayTmp2()
		self.pTabHost:setTabChangedHandler(handler(self, self.onTabChanged))
		pLayTab:addView(self.pTabHost,10)
		self.pTabMgr = self.pTabHost.pTabManager
		self.pTabMgr:setImgBag("#v1_btn_selected_biaoqian.png", "#v1_btn_biaoqian.png")
		self.pTabHost:setDefaultIndex(self.nCurIndex)
		self.tTabItems = self.pTabHost:getTabItems()
	end	
		
end

function DlgFemaleHeros:getLayerByKey( _sKey, _tKeyTabLt )
	-- body
	local pLayer = nil	
	local tSize = self.pTabHost:getCurContentSize()	
	if( _sKey == _tKeyTabLt[1] ) then
		pLayer = LayoutFemaleLookfor.new(tSize)	
		self.tPages[1] = pLayer
	elseif (_sKey == _tKeyTabLt[2] ) then
		pLayer = LayoutFemaleHeros.new(tSize)
		self.tPages[2] = pLayer
	elseif (_sKey == _tKeyTabLt[3] ) then
		pLayer = LayoutFemaleHeroShop.new(tSize)
		self.tPages[3] = pLayer
	end
	return pLayer
end

function DlgFemaleHeros:onTabChanged( _sKey, _nType )
	if _sKey == "tabhost_key_1" then
		
	elseif _sKey == "tabhost_key_2" then
	
	elseif _sKey == "tabhost_key_3" then
		
	end
end

function DlgFemaleHeros:getCurTabLayer(  )
	-- body
	if self.nCurIndex == 1 then
		
	elseif self.nCurIndex == 2 then
		
	elseif self.nCurIndex == 3 then
		
	end
	return nil
end


--析构方法
function DlgFemaleHeros:onDestroy()
	-- body
	self:onPause()
end

--注册消息
function DlgFemaleHeros:regMsgs(  )
	-- body
end
--注销消息
function DlgFemaleHeros:unregMsgs( )
	-- body

end

--暂停方法
function DlgFemaleHeros:onPause( )
	-- body		
	self:unregMsgs()	

end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgFemaleHeros:onResume( _bReshow )
	-- body		
	self:regMsgs()	
	self:updateViews()
end

return DlgFemaleHeros