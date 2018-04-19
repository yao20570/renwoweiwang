----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-01 15:31:25
-- Description: 装备背包 装备滚动层
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemEquip = require("app.layer.equip.ItemEquip")
local EquipsLayer = class("EquipsLayer", function(pSize)
	local pView = MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
	pView:setContentSize(pSize)
	-- pView:setBackgroundImage("#v1_bg_kelashen.png",{scale9 = true,capInsets=cc.rect(22,22, 1, 1)})
	return pView
end)

--pSize：区域大小
--nKind:装备种类
function EquipsLayer:ctor( pSize, nKind , nHeroId)
	self:setViewSize(pSize)
	self:setEquipParam(nKind, nHeroId)

	--解析文件
	parseView("lay_equip_bag_banner", handler(self, self.onParseViewCallback))
end

--解析界面回调
function EquipsLayer:onParseViewCallback( pView )
	local nY = self.pSize.height - pView:getContentSize().height
	pView:setPositionY(nY)
	self:addView(pView)

	self.ListViewHeight = nY

	--self:setupViews()
	
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("EquipsLayer", handler(self, self.onEquipsLayerDestroy))
end

-- 析构方法
function EquipsLayer:onEquipsLayerDestroy(  )
    self:onPause()
end

function EquipsLayer:regMsgs(  )
end

function EquipsLayer:unregMsgs(  )

end
--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function EquipsLayer:onResume( _bReshow )
	if _bReshow and self.pListView then
		self.pListView:scrollToBegin()
	end
	self:updateViews()
	self:regMsgs()
end
--暂停方法
function EquipsLayer:onPause(  )
	self:unregMsgs()
end

function EquipsLayer:setupViews(  )

end

function EquipsLayer:updateViews(  )
	--dump(self.pSize, "self.pSize", 100)
	if not self.pLayTitle then
		self.pLayTitle = self:findViewByName("lay_equip_bag_banner")		
		self.pTxtBanner = self:findViewByName("txt_banner")
		self.pTxtBanner:setString(getConvertedStr(3, 10284))			
	end

	self:setContentSize(self.pSize)	
	self.ListViewHeight = self.pSize.height - self.pLayTitle:getContentSize().height
	self.pLayTitle:setPositionY(self.ListViewHeight)
	self.tEquipVos = Player:getEquipData():getIdleEquipVosByKind(self.nKind)
	if not self.pListView then
		self.pListView = MUI.MListView.new {
			viewRect   = cc.rect(20, 0, 600, self.ListViewHeight - 10),
			direction  = MUI.MScrollView.DIRECTION_VERTICAL,
			itemMargin = {left =  0,
	            right =  0,
	            top =  10,
	            bottom =  0},
	    	}
		self.pListView:setItemCallback(function ( _index, _pView ) 
		    local pTempView = _pView
		    if pTempView == nil then
		    	pTempView   = ItemEquip.new()
			end
			local tEquipVo = self.tEquipVos[_index]
			pTempView:setData(tEquipVo.sUuid, self.nHeroId)
		    return pTempView
		end)
		self.pListView:setPosition(20, 0)
		self:addView(self.pListView, 2)

		self.pListView:setItemCount(#self.tEquipVos)
		-- 载入所有展示的item
		self.pListView:reload(true)	
	else
		self.pListView:setViewRect(cc.rect(20, 0, 600, self.ListViewHeight - 10))
		self.pListView:notifyDataSetChange(true, #self.tEquipVos)
	end
	self:setBackgroundImage("#v1_bg_kelashen.png",{scale9 = true,capInsets=cc.rect(22,22, 1, 1)})	
	--显示前往铁匠铺
	if not self.pNullUi then
		local tLabel = {
			str = getConvertedStr(3, 10288),
		    btnStr = getConvertedStr(3, 10265),
		    handler = function ( )
				local tObject = {
				    nType = e_dlg_index.smithshop,
				    nKind = self.nKind,
				    nFuncIdx = n_smith_func_type.build
				}
				sendMsg(ghd_show_dlg_by_type, tObject)
			end,
		}
		self.pNullUi = getLayNullUiTxtAndBtn(tLabel)
		local x, y = self.pListView:getPosition()
		local w, h = self.pListView:getContentSize().width,self.pListView:getContentSize().height
		self.pNullUi:setVisible(#self.tEquipVos == 0)
		self:addView(self.pNullUi, 1)		
	else
		self.pNullUi:setVisible(#self.tEquipVos == 0)
	end
	centerInView(self.pListView, self.pNullUi)
end

function EquipsLayer:setViewSize( pSize )
	-- body
	self.pSize = pSize
end

function EquipsLayer:setEquipParam( nKind , nHeroId )
	-- body
	self.nKind = nKind
	self.nHeroId = nHeroId
end

return EquipsLayer


