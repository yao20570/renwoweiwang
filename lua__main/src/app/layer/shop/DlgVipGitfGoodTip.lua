---------------------------------------------
-- Author: maheng
-- Date: 2017-08-22 16:36:00
-- 特权礼包相关提示对话框
---------------------------------------------

local DlgAlert = require("app.common.dialog.DlgAlert")
local ShopFunc = require("app.layer.shop.ShopFunc")
local DlgVipGitfGoodTip = class("DlgVipGitfGoodTip", function ()
	return DlgAlert.new(e_dlg_index.vipgitfgoodtip)
end)

--构造
function DlgVipGitfGoodTip:ctor(_tData)
	-- body
	self:myInit(_tData)
	parseView("lay_vip_good_tip", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgVipGitfGoodTip:myInit(_tData)
	-- body
	self.tData = _tData.tShopBase
	self.sTopTip = _tData.sTopTip
end
  
--解析布局回调事件
function DlgVipGitfGoodTip:onParseViewCallback( pView )
	-- body
	self:addContentView(pView, true)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgVipGitfGoodTip",handler(self, self.onDlgBuyGrowthFoundDestroy))
end

--初始化控件
function DlgVipGitfGoodTip:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(3, 10091))

	self.pLayRoot 	= self:findViewByName("lay_def")
	self.pLayIcon 	= self:findViewByName("lay_icon")

	
	self.pLbTip = MUI.MLabel.new({
		    text = "",
		    size = 20,
		    anchorpoint = cc.p(0.5, 0.5),
		    align = cc.ui.TEXT_ALIGN_CENTER,
    		valign = cc.ui.TEXT_VALIGN_CENTER,
		    color = cc.c3b(255, 255, 255),
		    dimensions = cc.size(350, 60),
		})
	self.pLbTip:setPosition(200, 53)
	self.pLayRoot:addView(self.pLbTip, 10)

	local tGoods = getGoodsByTidFromDB(self.tData.id)
	getIconGoodsByType(self.pLayIcon, TypeIconGoods.HADMORE, type_icongoods_show.item, tGoods)

	local bNeedVipGift, bHadVipGift, tStr = ShopFunc.getGoodVipGiftInfo( self.tData.id )			
	self.pLbTip:setString(tStr, false)
	local nId = self.tData.id
	local nVipLv = nil
	if nId == e_resdata_ids.bb then
		nVipLv = getArmyVipLvLimit(e_id_item.bbgm)			
	elseif nId == e_resdata_ids.qb then
		nVipLv = getArmyVipLvLimit(e_id_item.qbgm)
	elseif nId == e_resdata_ids.gb then
		nVipLv = getArmyVipLvLimit(e_id_item.gbgm)
	elseif nId == e_id_item.gfys then
		nVipLv = tonumber(getBuildParam("workshopVip"))
	elseif nId == e_id_item.kjky then
		nVipLv = getArmyVipLvLimit(e_id_item.kjky)
	end
	self:setRightBtnText(getConvertedStr(6, 10524))
	self:setRightBtnType(TypeCommonBtn.L_YELLOW)
	self:setRightHandler(function ( ... )
		-- body
		closeDlgByType(e_dlg_index.vipgitfgoodtip)
		local tObject = {
		    nType = e_dlg_index.dlgvipprivileges, --dlg类型
		    nVipLv = nVipLv
		}
		sendMsg(ghd_show_dlg_by_type, tObject)	
	end)

	--上面提示
	if self.sTopTip then
		if not self.pTopTip then
			self.pTopTip = MUI.MLabel.new({text = "", size = 22})
			self.pLayRoot:addView(self.pTopTip, 10)
			self.pTopTip:setPosition(self.pLayRoot:getWidth()/2, 230)
		end
		self.pTopTip:setString(self.sTopTip)

		--重置位置
		self.pLayIcon:setPositionY(60)
		self.pLbTip:setPositionY(37)
	else
		if self.pTopTip then
			self.pTopTip:setString("")
		end
		self.pLayIcon:setPositionY(88)
		self.pLbTip:setPositionY(53)
	end
end

-- 修改控件内容或者是刷新控件数据
function DlgVipGitfGoodTip:updateViews()
	-- body
	
end

--析构方法
function DlgVipGitfGoodTip:onDlgBuyGrowthFoundDestroy()
	self:onPause()
end

-- 注册消息
function DlgVipGitfGoodTip:regMsgs( )
	-- body
end

-- 注销消息
function DlgVipGitfGoodTip:unregMsgs(  )
	-- body
end


--暂停方法
function DlgVipGitfGoodTip:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgVipGitfGoodTip:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

return DlgVipGitfGoodTip
