-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-04-25 11:12:23 星期二
-- Description: 背包装备项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local EquipInfoLayer = require("app.module.EquipInfoLayer")

local BagEquip = class("BagEquip", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function BagEquip:ctor()
	-- body
	self:myInit()

	parseView("bag_item_equip", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("BagEquip",handler(self, self.onBagEquipDestroy))
	
end

--初始化参数
function BagEquip:myInit()
	-- body
end

--解析布局回调事件
function BagEquip:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:setupViews()
	self:updateViews()
end

--初始化控件
function BagEquip:setupViews( )
	--装备信息
	self.pLayEquipInfo = self:findViewByName("lay_equip_info")
	self.pEquipInfoLayer = EquipInfoLayer.new()
	self.pLayEquipInfo:addView(self.pEquipInfoLayer)
	centerInView(self.pLayEquipInfo, self.pEquipInfoLayer)
	--按钮洗练
	self.pLayBtn1 = self:findViewByName("lay_btn_1")
	self.pBtn1 = getCommonButtonOfContainer(self.pLayBtn1, TypeCommonBtn.L_BLUE, getConvertedStr(6, 10631), false)	
	self.pBtn1:onCommonBtnClicked(handler(self, self.onBtnSuccinctClicked))	
	setMCommonBtnScale(self.pLayBtn1, self.pBtn1, 0.8)
	--按钮分解
	self.pLayBtn2 = self:findViewByName("lay_btn_2")
	self.pBtn2 = getCommonButtonOfContainer(self.pLayBtn2, TypeCommonBtn.L_YELLOW, getConvertedStr(6, 10133), false)	
	self.pBtn2:onCommonBtnClicked(handler(self, self.onBtnSplitClicked))
	setMCommonBtnScale(self.pLayBtn2, self.pBtn2, 0.8)		
end

-- 修改控件内容或者是刷新控件数据
function BagEquip:updateViews(  )
	-- body
	if self.tCurData then
		self.pEquipInfoLayer:setCurData(self.tCurData)	
		local equip = self.tCurData:getConfigData()
		self.pBtn2:setVisible(equip:isEquipCanDecom())--是否可以分解
		self.pLayBtn1:setVisible(equip.nQuality >= 2)
		if equip.nQuality >= 2 then
			self.pLayBtn2:setPositionY((self:getHeight() - self.pLayBtn2:getHeight()*2)/3)
		else			
			self.pLayBtn2:setPositionY((self:getHeight() - self.pLayBtn2:getHeight())/2)
		end
	end
end

--析构方法
function BagEquip:onBagEquipDestroy(  )
	-- body
	Player:getEquipData():setEquipVosNoNew()
end

--设置数据 _data
function BagEquip:setCurData(_data)
	if _data then
		self.tCurData = _data	
		self:updateViews()
	end
end

--获取章节数据
function BagEquip:getData()
	return self.pEquipInfoLayer:getData()
end

--按钮点击回调
function BagEquip:onBtnSplitClicked( pView )	
	if not self.tCurData then
		return
	end	
	local dropitems = getDropById(self.tCurData:getConfigData().nDecomDrop)
	--dump(dropitems, "dropitems", 100)
	if dropitems then
		showDlgEquipDecomTip(self.tCurData:getConfigData().sTid, function (  )
			-- body
			SocketManager:sendMsg("reqEquipDecompose", {self.tCurData.sUuid}, function ( __msg )
				-- body
				closeDlgByType(e_dlg_index.dlgequipdecomtip)
			end)
		end, self.tCurData.sUuid)
	end	
	
end

--洗练
function BagEquip:onBtnSuccinctClicked( pView )
	-- body
	print("--------洗练")
	if not self.tCurData then
		return
	end
	local tObject = {
	    nType = e_dlg_index.smithshop,
	    sUuid = self.tCurData.sUuid,
	    nFuncIdx = n_smith_func_type.train
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end
return BagEquip