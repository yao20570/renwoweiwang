-- Author: dengshulan
-- Date: 2017-12-28 15:51:08
-- 寻龙夺宝获得目标物品弹窗


local DlgAlert = require("app.common.dialog.DlgAlert")
local DlgGetTargetGoodsTip = class("DlgGetTargetGoodsTip", function ()
	return DlgAlert.new(e_dlg_index.gettargetgoodstip)
end)

--构造
function DlgGetTargetGoodsTip:ctor()
	-- body
	self:myInit()	
	parseView("lay_mansion_item_tip", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgGetTargetGoodsTip:myInit()
	-- body

end
  
--解析布局回调事件
function DlgGetTargetGoodsTip:onParseViewCallback( pView )
	-- body
	self:addContentView(pView, true)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgGetTargetGoodsTip",handler(self, self.onDestroy))
end

--初始化控件	
function DlgGetTargetGoodsTip:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(7, 10276))
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pLbName = self:findViewByName("lb_name")
	self.pLbSale = self:findViewByName("lb_sale")
	self.pLbDesc = self:findViewByName("lb_desc")
	setTextCCColor(self.pLbDesc, _cc.pwhite)

    self:setOnlyConfirm(getConvertedStr(6, 10106))
    self:setOnlyConfirmBtn(TypeCommonBtn.L_YELLOW) 
end

-- 修改控件内容或者是刷新控件数据
function DlgGetTargetGoodsTip:updateViews()
	-- body	
	if not self.pData then
		return
	end
	--物品信息
	local tIconData = getGoodsByTidFromDB(self.pData.k)
	if tIconData == nil then return end
	tIconData.nCt = self.pData.v or 1
	self.pLbName:setString(tIconData.sName)
	setTextCCColor(self.pLbName, getColorByQuality(tIconData.nQuality))
	self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.itemnum, tIconData,TypeIconGoodsSize.L)
	self.pIcon:setIconIsCanTouched(false)
	self.pLbDesc:setString(tIconData.sDes)

	local tData = Player:getActById(e_id_activity.dragontreasure)
	if tData then
		for k, v in pairs(tData.tTinfo.tTurnConfVos) do
    		if self.pData.k == v.tReward.k then
				self.pLbSale:setString(string.format(getConvertedStr(7, 10277), v.nPos), false)
    			break
    		end
    	end
	end
end

--析构方法
function DlgGetTargetGoodsTip:onDestroy()
	self:onPause()	   	
end

-- 注册消息
function DlgGetTargetGoodsTip:regMsgs( )
	-- body
end

-- 注销消息
function DlgGetTargetGoodsTip:unregMsgs(  )
	-- body
end


--暂停方法
function DlgGetTargetGoodsTip:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgGetTargetGoodsTip:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

function DlgGetTargetGoodsTip:setCurData(_tData)
	-- body
	self.pData = _tData
	self:updateViews()
end

return DlgGetTargetGoodsTip
