-- DlgSpecialSale.lua
---------------------------------------------
-- Author: dshulan
-- Date: 2017-07-04 17:37:00
-- 特价卖场
---------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local ItemSpecialSale = require("app.layer.activityb.specialsale.ItemSpecialSale")

local DlgSpecialSale = class("DlgSpecialSale", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgspecialsale)
end)

function DlgSpecialSale:ctor(  )
	-- body
	self:myInit()
	parseView("dlg_special_sale", handler(self, self.onParseViewCallback))
end

function DlgSpecialSale:myInit(  )
	-- body
	self.tItemIcons = nil
	self.tActData  = {} --活动数据
end

--解析布局回调事件
function DlgSpecialSale:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgSpecialSale",handler(self, self.onDlgSpecialSaleDestroy))
end

--初始化控件
function DlgSpecialSale:setupViews()
	--设置标题
	self:setTitle(getConvertedStr(7,10112))

	self.pLayRoot = self:findViewByName("default")

	self.pLayTop  = self:findViewByName("lay_top")

	self.pLbTitle = self:findViewByName("lb_title")
	self.pLbTitle:setString(getConvertedStr(7,10126))

	self.pLbTime = self:findViewByName("lb_r_time")
	setTextCCColor(self.pLbTime, _cc.green)

	self.pLayList = self:findViewByName("lay_list")

	--设置banner图
	self.pLayBannerBg = self:findViewByName("lay_banner_bg")
	setMBannerImage(self.pLayBannerBg,TypeBannerUsed.fl_tjmc)

	local pTxtTip= self:findViewByName("txt_tip")
	pTxtTip:setString(getConvertedStr(9,10066))

end

--控件刷新
function DlgSpecialSale:updateViews()
	self.tActData = Player:getActById(e_id_activity.specialsale)
	if not self.tActData then
		self:closeDlg(false)
		return
	end
	local tGoodsList = self.tActData.tGoodsList
	local nItemCnt = table.nums(tGoodsList)
	if(not self.pListView) then
		--列表层
		self.pListView = MUI.MListView.new{
	        viewRect = cc.rect(0, 0, self.pLayList:getWidth(), self.pLayList:getHeight()),
	        direction = MUI.MScrollView.DIRECTION_VERTICAL,
	        itemMargin = {
	        	left =  0,
	        	right =  0,
	        	top =  8,
	        	bottom =  2
	        },
		}
		self.pLayList:addView(self.pListView)
		self.pListView:setBounceable(true)
	    self.pListView:setItemCount(nItemCnt)      
	    self.pListView:setItemCallback(function ( _index, _pView )
	        local pTempView = _pView
	    	if pTempView == nil then
	        	pTempView = ItemSpecialSale.new()                        
	        end
	        pTempView:setItemData(_index)
	        return pTempView
	    end)
	    --上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow, true)
	    self.pListView:reload(true)
	else
		self.pListView:notifyDataSetChange(true, nItemCnt)
	end

	if not self.pActTime then
		--活动时间
		self.pActTime = createActTime(self.pLayTop,self.tActData,cc.p(0,240))
	else
		self.pActTime:setCurData(self.tActData)
	end
	if not self.tAc then
		self.tAc = Player:getActById(e_id_activity.specialsale)
	end


end

--刷新时间
function DlgSpecialSale:updateRefreshCD()
	self.pLbTime:setString(self.tAc:getNextRefreshTime())
end


--刷新界面
function DlgSpecialSale:updateLayer()
	self:updateViews()	
end


--析构方法
function DlgSpecialSale:onDlgSpecialSaleDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgSpecialSale:regMsgs(  )
	-- body
	regMsg(self, gud_refresh_activity, handler(self, self.updateLayer))

end
--注销消息
function DlgSpecialSale:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_activity)

end
--暂停方法
function DlgSpecialSale:onPause( )
	-- body
	self:unregMsgs()
	unregUpdateControl(self)
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgSpecialSale:onResume(_bReshow)
	-- body
	if(_bReshow and self.pListView) then
		-- 如果是重新显示，定位到顶部
		self.pListView:scrollToBegin()
	end
	self:updateViews()
	self:regMsgs()
	regUpdateControl(self, handler(self, self.updateRefreshCD))
end


return DlgSpecialSale