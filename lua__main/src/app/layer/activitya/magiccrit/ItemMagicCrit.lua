-- Author: maheng
-- Date: 2017-12-07 9:41:12
-- 神兵暴击
local MCommonView = require("app.common.MCommonView")
local ItemActContent = require("app.layer.activitya.ItemActContent")

local ItemMagicCrit = class("ItemMagicCrit", function()
	return ItemActContent.new(e_id_activity.magiccrit)
end)

--创建函数
function ItemMagicCrit:ctor()
	-- body
	self:myInit()

	self:setupViews()
	self:updateViews()

	self:regMsgs()

	--注册析构方法
	self:setDestroyHandler("ItemMagicCrit",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemMagicCrit:myInit()
	self.pData = {} --数据
end



--初始化控件
function ItemMagicCrit:setupViews( )
	local nBtnY = 54
	if self.pLyBtnM then
		self.pLyBtnM:setVisible(false)
		--nBtnY = self.pLyBtnM:getPositionY()
	end

	local pLayShow = self:findViewByName("ly_show")

	local pLayBtnLeft = MUI.MLayer.new()
	pLayBtnLeft:setLayoutSize(155, 62)
	pLayBtnLeft:setPosition(40, nBtnY)
	pLayShow:addView(pLayBtnLeft, 10)
	--征收资源
	local pBtnLeft = getCommonButtonOfContainer(pLayBtnLeft, TypeCommonBtn.L_BLUE, getConvertedStr(7, 10229))
	pBtnLeft:onCommonBtnClicked(handler(self, self.onLeftBtnClicked))

	local pLayBtnRight = MUI.MLayer.new()
	pLayBtnRight:setLayoutSize(155, 62)
	pLayBtnRight:setPosition(pLayShow:getWidth() - pLayBtnRight:getWidth() - 40, nBtnY)
	pLayShow:addView(pLayBtnRight, 10)
	--购买铁矿
	local pBtnRight = getCommonButtonOfContainer(pLayBtnRight, TypeCommonBtn.L_YELLOW, getConvertedStr(6, 10637))
	pBtnRight:onCommonBtnClicked(handler(self, self.onRightBtnClicked))
	-- self:setMHandler(handler(self, self.onClicked))
	-- self:setMBtnText(getConvertedStr(5, 10234)) --去挑战
end

--点击回调
function ItemMagicCrit:onLeftBtnClicked()
	print("跳转征收资源")--征收资源
	local tObject = {}
	tObject.nType = e_dlg_index.rescollect --dlg类型
	sendMsg(ghd_show_dlg_by_type, tObject)

    --关闭活动a界面
    closeDlgByType( e_dlg_index.actmodela, false)
end
--点击回调
function ItemMagicCrit:onRightBtnClicked()
	print("跳转")--购买铁矿

	local tObject = {}
	tObject.nType = e_dlg_index.shop --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)
    --关闭活动a界面
    closeDlgByType( e_dlg_index.actmodela, false)
end

-- 修改控件内容或者是刷新控件数据
function ItemMagicCrit:updateViews(  )
	self:setActTime()
end

--析构方法
function ItemMagicCrit:onDestroy(  )
	self:unregMsgs()
end


-- 注册消息
function ItemMagicCrit:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

-- 注销消息
function ItemMagicCrit:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end


--设置数据 _data
function ItemMagicCrit:setData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}
	self:setCurData(self.pData)

end


return ItemMagicCrit