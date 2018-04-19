-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-04-25 11:12:23 星期二
-- Description: 背包装备信息显示 420*130
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local EquipInfoLayer = class("EquipInfoLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)



function EquipInfoLayer:ctor()
	-- body
	self:myInit()

	parseView("bag_item_equipinfo", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("EquipInfoLayer",handler(self, self.onEquipInfoLayerDestroy))	
end

--初始化参数
function EquipInfoLayer:myInit()
	-- body

	self.pData = nil --物品数据
	self.tAttr = {} --属性展示表	
end

--解析布局回调事件
function EquipInfoLayer:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:setupViews()
	self:updateViews()
end

--初始化控件
function EquipInfoLayer:setupViews( )
	--物品左上角标签
	self.pLayEquipLog = self:findViewByName("lay_log")
	self.pLbXin = self:findViewByName("lb_xin")
	self.pLbXin:setString(getConvertedStr(6, 10313))
	--图标
	self.pLayIcon = self:findViewByName("lay_icon")	
	-- local data = {}
	-- data.sName = ""
	-- data.nQuality = 1
	self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconEquip.NORMAL, type_icongoods_show.item, nil, TypeIconGoodsSize.L)
	self.pIcon:setIconIsCanTouched(true)
	centerInView(self.pLayIcon, self.pIcon)	
	--装备名称
	self.pLbEquipName = self:findViewByName("lb_equip_name")
	self.pLbEquipName:setString("装备名称")
	--主要属性
	self.pLbMainAttr = self:findViewByName("lb_attr")
	self.pLbMainAttr:setString(getConvertedStr(6, 10129))
	setTextCCColor(self.pLbMainAttr, _cc.white)	
	--属性值
	self.pLbAttrValue = self:findViewByName("lb_attr_value")
	self.pLbAttrValue:setString("+9999")
	setTextCCColor(self.pLbAttrValue, _cc.green)
	-- --属性详情	
	for i = 1, 4 do --从左到右，从上到下与界面对应
		local imgicon = self:findViewByName("img_attr"..i.."_icon")
		imgicon:setScale(0.3, 0.3)
		local lbattr = self:findViewByName("lb_attr"..i.."_name")
		lbattr:setString("", false)
		setTextCCColor(lbattr, _cc.pwhite)
		local lbattrvalue = self:findViewByName("lb_attr"..i.."_value")
		lbattrvalue:setString("lv.6")		
		setTextCCColor(lbattrvalue, _cc.blue)
		local attr = {imgicon, lbattr, lbattrvalue}
		self.tAttr[i] = attr
	end	
end

-- 修改控件内容或者是刷新控件数据
function EquipInfoLayer:updateViews(  )
	-- body
	if self.pData then	
		--装备图像		
		local tconfigdata = self.pData:getConfigData()
		self.pIcon:setCurData(tconfigdata)
		--装备名称
		self.pLbEquipName:setString(tconfigdata.sName)
		setTextCCColor(self.pLbEquipName, getColorByQuality(tconfigdata.nQuality))
		--装备星数
		local tDarkLights = self.pData:getStarDarkLights()
		if #tDarkLights > 0 then
			self.pIcon:initStarLayer(#tDarkLights, 0, tDarkLights)
		else			
			self.pIcon:removeStarLayer()
		end
		--装备强化等级(显示左上角)
		local nStrenthLv = self.pData:getEquipStrenthLv()
		if nStrenthLv > 0 then
			self.pIcon:showLeftTopLayer("+"..nStrenthLv)
		else
			self.pIcon:removeLeftTopLayer()
		end
		--装备是否是新
		self.pLayEquipLog:setVisible(self.pData:getIsNew())		
		--	
		local tAttr = luaSplit(tconfigdata.sAttributes,':')		
		if tAttr then
			local ttmp = getBaseAttData(tAttr[1])			
			self.pLbMainAttr:setString(ttmp.sName)
			local nValue = self.pData:getAttrValue()
			self.pLbAttrValue:setString("+"..nValue)
			-- self.pLbAttrValue:setString("+"..tAttr[2])
		end
		local tTrainAt = self.pData:getTrainAtbVos()

		--dump(tTrainAt, "tTrainAt=", 100)
		for i = 1, 4 do 
			if tTrainAt[i] then
				self.tAttr[i][1]:setVisible(true)
				self.tAttr[i][2]:setVisible(true)
				self.tAttr[i][3]:setVisible(true)

				self.tAttr[i][3]:setString(getLvString(tTrainAt[i].nLv))
				local ttrainAttr = getBaseAttData(tTrainAt[i].nAttrId)
				self.tAttr[i][1]:setCurrentImage(ttrainAttr.sIcon)
				self.tAttr[i][2]:setString(ttrainAttr.sName)

			else
				self.tAttr[i][1]:setVisible(false)
				self.tAttr[i][2]:setVisible(false)
				self.tAttr[i][3]:setVisible(false)
			end
		end
	end

end

--析构方法
function EquipInfoLayer:onEquipInfoLayerDestroy(  )
	-- body
end

--设置数据 _data
function EquipInfoLayer:setCurData(_equipdata)	

	if _equipdata then
		self.pData = _equipdata		
	end
	self:updateViews()
end

--获取数据
function EquipInfoLayer:getData()
	return self.pData
end
--设置头像的点击属性
function EquipInfoLayer:setIconIsCanTouched( _bEnbaled )
 	-- body
 	if self.pIcon then
 		self.pIcon:setIconIsCanTouched(_bEnbaled)
 	end
 end 
--设置头像点击回调方法
 function EquipInfoLayer:setIconClickedCallBack( _handler )
  	-- body 
  	if self.pIcon then
  		self.pIcon:setIconClickedCallBack(_handler)
  	end
 end
return EquipInfoLayer