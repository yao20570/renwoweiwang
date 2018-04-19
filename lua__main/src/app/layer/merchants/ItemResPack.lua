-- ItemResPack.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-3-9 17:28:55 星期五
-- Description: 资源打包item
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local MImgLabel = require("app.common.button.MImgLabel")

local ItemResPack = class("ItemResPack", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)
function ItemResPack:ctor()
	-- body
	self:myInit()
	parseView("item_res_pack", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemResPack:myInit(  )
	-- body
	self.tCurData 		= 	 nil 		--当前数据
	self.bLackRes 		= false --是否缺少资源
	self.bLackMoney 	= false --是否缺少黄金
end

--解析布局回调事件
function ItemResPack:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("ItemResPack",handler(self, self.onItemResPackDestroy))
end

--初始化控件
function ItemResPack:setupViews( )
	-- body
	self.pLayRoot 		= self:findViewByName("default")
	self.pLayIcon1 		= self:findViewByName("lay_icon_1")
	self.pLayIcon2 		= self:findViewByName("lay_icon_2")
	--已达上限文字
	self.pLbReTop 		= self:findViewByName("lb_re_top")
	self.pLbReTop:setString(getConvertedStr(7, 10399))
	setTextCCColor(self.pLbReTop, _cc.pwhite)
	local pLayBtn 		= self:findViewByName("lay_btn")
	self.pBtn = getCommonButtonOfContainer(pLayBtn,TypeCommonBtn.M_BLUE,getConvertedStr(7, 10400))
    --按钮点击事件
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))
	--按钮上的带图片的文本
	self.pImgBtnLb = MImgLabel.new({text="", size = 20, parent = self.pLayRoot})
	self.pImgBtnLb:setImg("#v1_img_qianbi.png", 1, "left")
	self.pImgBtnLb:followPos("center", pLayBtn:getPositionX()+pLayBtn:getWidth()/2, 
		pLayBtn:getPositionY()+pLayBtn:getHeight()+10, 2)
end


-- 修改控件内容或者是刷新控件数据
function ItemResPack:updateViews(  )
	-- body
	if self.tCurData == nil then
		return
	end
	local nHasPack = self.tCurData.nHasPack 		--今日已打包次数
	local bReachMax = false 						--是否到达今日上限
	if nHasPack >= self.tCurData.nMaxPackCnt then
		nShowPack = self.tCurData.nMaxPackCnt
		bReachMax = true
	else
		nShowPack = nHasPack + 1
	end
	--第一个icon信息
	local tPackCost = self.tCurData.tPackCost[nShowPack]
	local tGoods = getGoodsByTidFromDB(self.tCurData.nResId)
	self.pLayIcon1:removeAllChildren()
	self.pIcon1 = nil
	-- if not self.pIcon1 then
		self.pIcon1 = getIconGoodsByType(self.pLayIcon1, TypeIconGoods.HADMORE, 
			type_icongoods_show.itemnum, tGoods, TypeIconEquipSize.M)
		self.pIcon1:setMoreTextSize(25)
	-- end
	local nNeedNum = tonumber(tPackCost[2])
	local nMyGoodsCnt = getMyGoodsCnt(self.tCurData.nResId)
	--打包提示
	self.tResList = {}
	self.tResList[e_resdata_ids.lc] = 0
	self.tResList[e_resdata_ids.bt] = 0
	self.tResList[e_resdata_ids.mc] = 0
	self.tResList[e_resdata_ids.yb] = 0
	if nNeedNum > nMyGoodsCnt and not bReachMax then
		self.tResList[self.tCurData.nResId] = nNeedNum
		self.pIcon1:setMoreTextColor(_cc.red)
		self.bLackRes = true
	else
		self.pIcon1:setMoreTextColor(_cc.white)
		self.bLackRes = false
	end
	local sCount = formatCountToStr(nNeedNum)
	self.pIcon1:setMoreText(tGoods.sName..sCount)
	--第二个icon信息
	local tExchange = self.tCurData.tExchange[nShowPack]
	local nGoodId = tonumber(tExchange[2])
	local tGoods = getGoodsByTidFromDB(nGoodId)
	self.pLayIcon2:removeAllChildren()
	self.pIcon2 = nil
	-- if not self.pIcon2 then
		self.pIcon2 = getIconGoodsByType(self.pLayIcon2, TypeIconGoods.HADMORE, 
			type_icongoods_show.itemnum, tGoods, TypeIconEquipSize.M)
		self.pIcon2:setMoreTextSize(25)
	-- end
	local sCount = formatCountToStr(tonumber(tExchange[3]))
	self.pIcon2:setIconImg(tGoods.sIcon)
	self.pIcon2:setMoreText(tGoods.sName.."*"..sCount)
	self.sPackCnt = sCount
	self.sPackName = tGoods.sName

	local nCost = tonumber(tPackCost[3])
	local nMyMoney = getMyGoodsCnt(e_type_resdata.money)
	local sColor = _cc.blue
	self.bLackMoney = false
	if nCost > nMyMoney then
		sColor = _cc.red
		self.bLackMoney = true
	end
	local tStr = {
		{text = formatCountToStr(nMyMoney), color = sColor},
		{text = "/"..nCost, color = _cc.pwhite},
	}
	self.nCost = nCost or 0
	self.pImgBtnLb:showImg()
	self.pImgBtnLb:setString(tStr)

	if bReachMax then
		self.pBtn:setVisible(false)
		self.pLbReTop:setVisible(true)
		self.pImgBtnLb:hideImg()
		self.pImgBtnLb:setString("")
	else
		self.pBtn:setVisible(true)
		self.pLbReTop:setVisible(false)
	end

end

--打包按钮响应
function ItemResPack:onBtnClicked( )
	if self.bLackRes then
		goToBuyRes(self.tCurData.nResId,self.tResList)
		return
	end
	if self.bLackMoney then
		local tObject = {}
		tObject.nType = e_dlg_index.dlgrechargetip --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)
		return
	end
	local tStr = {
		{color = _cc.pwhite, text = getConvertedStr(7, 10403)},
		{color = _cc.yellow, text = self.sPackName.."*"..self.sPackCnt}
	}
	showBuyDlg(tStr, self.nCost, function()
		-- body
		SocketManager:sendMsg("reqPackResours", {self.tCurData.nResId})
	end, 0, true)
end

-- 析构方法
function ItemResPack:onItemResPackDestroy(  )
	-- body
end

--设置当前数据
function ItemResPack:setCurData( _data )
	-- body
	self.tCurData = _data or self.tCurData
	self:updateViews()
end


return ItemResPack