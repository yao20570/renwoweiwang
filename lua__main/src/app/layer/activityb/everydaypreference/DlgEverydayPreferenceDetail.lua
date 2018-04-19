-----------------------------------------------------
-- author: luwenjing
-- updatetime:  2018-01-04 18:25:17 星期五
-- Description: 每日特惠物品详情对话框
-----------------------------------------------------
local DlgCommon = require("app.common.dialog.DlgCommon")
local MBtnExText = require("app.common.button.MBtnExText")
local MImgLabel = require("app.common.button.MImgLabel")
local IconGoods = require("app.common.iconview.IconGoods")

local DlgEverydayPreferenceDetail = class("DlgEverydayPreferenceDetail", function ()
	return DlgCommon.new(e_dlg_index.dlgeverypreferencedetail, 340, 130)
end)

--构造
function DlgEverydayPreferenceDetail:ctor(_tData)
	-- body
	self:myInit(_tData)
	parseView("dlg_everyday_preference_detail", handler(self, self.onParseViewCallback))
end
  
--解析布局回调事件
function DlgEverydayPreferenceDetail:onParseViewCallback( pView )
	-- body
	
	self:addContentView(pView, false)
	self:setupViews()
	self:updateViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgEverydayPreferenceDetail",handler(self, self.onDestroy))
end

function DlgEverydayPreferenceDetail:myInit( _tData )
	-- body
	self.tData=_tData

	self.tRewardImg ={
		"#v1_img_chufalibao.png",
		"#v2_img_3yuanlibao.png",
		"#v2_img_6yuanlibao.png",
	}
end

--初始化控件
function DlgEverydayPreferenceDetail:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(9, 10076))

	local pTxtTip=self:findViewByName("txt_tip")
	pTxtTip:setString(getConvertedStr(9,10077))

	self.pLayList=self:findViewByName("lay_list")

	local pLayBtn=self:findViewByName("lay_btn")
	self.pBtn = getCommonButtonOfContainer(pLayBtn, TypeCommonBtn.L_BLUE, getConvertedStr(9, 10078))
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))

	self.pImgIcon= self:findViewByName("img_icon")

	self.temp={}
	
end

-- 修改控件内容或者是刷新控件数据
function DlgEverydayPreferenceDetail:updateViews()
	-- body

	if not self.tData then
		return
	end

	local nCurrCount =#self.tData.gs
	if not self.pListView then
		local pLayGoods = self.pLayList
		self.pListView = MUI.MListView.new {
		viewRect   = cc.rect(0, 0, pLayGoods:getContentSize().width, pLayGoods:getContentSize().height),
		direction  = MUI.MScrollView.DIRECTION_HORIZONTAL,
		itemMargin = {left = 8,
		        right =  10,
		        top = 17,
		        bottom =0 },
		}
		pLayGoods:addView(self.pListView)
		centerInView(pLayGoods, self.pListView )
		self.pListView:setItemCallback(handler(self, self.onGoodsListViewCallBack))
		self.pListView:setItemCount(nCurrCount)
		self.pListView:reload(true)
	else
		self.pListView:notifyDataSetChange(true, nCurrCount)
	end

	if self.tRewardImg[self.tData.i] then
		self.pImgIcon:setCurrentImage(self.tRewardImg[self.tData.i])
	end
	local nListPosX=0
	if nCurrCount == 1 then
		nListPosX = 189
	elseif nCurrCount == 2 then
		nListPosX = 132

	elseif nCurrCount == 3 then
		nListPosX=63
	end
	self.pLayList:setPositionX(nListPosX)
	
end
--列表项回调
function DlgEverydayPreferenceDetail:onGoodsListViewCallBack( _index, _pView )
	-- body
    local pItemData =getGoodsByTidFromDB(self.tData.gs[_index].k)--self.tData[_index]
    local pTempView = _pView
    if pTempView == nil then
        pTempView = IconGoods.new(TypeIconGoods.HADMORE)
    end
    pTempView:setScale(0.8)
    pTempView:setCurData(pItemData)
    pTempView:setMoreText(pItemData.sName)
	pTempView:setNumber(self.tData.gs[_index].v)

	pTempView:setMoreTextColor(getColorByQuality(pItemData.nQuality))	
    return pTempView
end

function DlgEverydayPreferenceDetail:onBtnClicked( ... )
	-- body
	self:closeDlg(false)
end

--析构方法
function DlgEverydayPreferenceDetail:onDestroy()
	self:onPause()
end

-- 注册消息
function DlgEverydayPreferenceDetail:regMsgs( )
	-- body
	-- 注册免费宝箱推送回调
	regMsg(self, ghd_daily_gift_push, handler(self, self.updateViews))
	regMsg(self,gud_shop_data_update_msg,handler(self,self.updateViews))

end

-- 注销消息
function DlgEverydayPreferenceDetail:unregMsgs(  )
	-- body
	unregMsg(self, ghd_daily_gift_push)
	unregMsg(self, gud_shop_data_update_msg)
	unregUpdateControl(self)
end


--暂停方法
function DlgEverydayPreferenceDetail:onPause( )
	-- body
	self:unregMsgs()

end

--继续方法
function DlgEverydayPreferenceDetail:onResume( )
	-- body
	self:regMsgs()

end



return DlgEverydayPreferenceDetail
