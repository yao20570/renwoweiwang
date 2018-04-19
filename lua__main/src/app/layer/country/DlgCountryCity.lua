-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-06-09 16:59:24 星期五
-- Description: 国家城池对话框
-----------------------------------------------------
local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemCountryCityLayer = require("app.layer.country.ItemCountryCityLayer")

local DlgCountryCity = class("DlgCountryCity", function()
	-- body
	return DlgCommon.new(e_dlg_index.dlgcountrycity)
end)

function DlgCountryCity:ctor(  )
	-- body
	self:myInit()
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgCountryCity",handler(self, self.onDlgCountryCityDestroy))
end

--初始化成员变量
function DlgCountryCity:myInit(  )
	-- body
	self.pDataList = {}
end

--初始化控件
function DlgCountryCity:setupViews( )
	-- body
	self:setTitle(getConvertedStr(6, 10364))

	self.pLayListView = MUI.MLayer.new()
	self.pLayListView:setLayoutSize(560, 570)
	self:addContentView(self.pLayListView) --加入内容层

	self.pLbTip = MUI.MLabel.new({
		    text = getTipsByIndex(10020),
		    size = 20,
		    anchorpoint = cc.p(0.5, 0.5),
		    align = cc.ui.TEXT_ALIGN_CENTER,
    		valign = cc.ui.TEXT_VALIGN_CENTER,
		    color = cc.c3b(255, 255, 255),
		})
	self.pLayListView:addView(self.pLbTip, 10)
	setTextCCColor(self.pLbTip, _cc.pwhite)
	centerInView(self.pLayListView, self.pLbTip)

	self.pImg = MUI.MImage.new("#v1_img_biaoqing.png", {scale9=false})
	self.pLayListView:addView(self.pImg, 10)
	self.pImg:setPosition(self.pLayListView:getWidth()/2, self.pLbTip:getPositionY() + self.pLbTip:getHeight()/2 + self.pImg:getHeight()/2 + 10)


end

-- 修改控件内容或者是刷新控件数据
function DlgCountryCity:updateViews(  )
	-- body
	self.pDataList = Player:getCountryData():getCountryCitys()
	--dump(self.pDataList, "self.pDataList", 100)
	if not self.pDataList then
		self.pDataList = {}	
	end
	local nCnt = table.nums(self.pDataList)
	if not self.pListView then
		self.pListView = MUI.MListView.new {
	        bgColor = cc.c4b(255, 255, 255, 250),
	        viewRect = cc.rect(0, 0, self.pLayContent:getWidth(), self.pLayContent:getHeight()),
	        direction = MUI.MScrollView.DIRECTION_VERTICAL,
	        itemMargin = {left =  0,
	         right =  0,
	         top =  0,
	         bottom =  0}}
		self.pLayListView:addView(self.pListView, 10)   
		self.pListView:setBounceable(true)       
	    self.pListView:setItemCallback(handler(self, self.onListViewItemCallBack))
	    self.pListView:setItemCount(nCnt) 
	    --上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
		self.pListView:reload(false)
	    self.pListView:reload(true)		
	else
		self.pListView:notifyDataSetChange(true, nCnt)	
	end	

	if nCnt == 0 then
		self.pLbTip:setVisible(true)
		self.pImg:setVisible(true)		
	else
		self.pLbTip:setVisible(false)
		self.pImg:setVisible(false)
	end
end

function DlgCountryCity:refreshListView(  )
	-- body
	if self.pListView then
		self.pListView:notifyDataSetChange(false)	
	end	
end
-- 析构方法
function DlgCountryCity:onDlgCountryCityDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgCountryCity:regMsgs( )
	-- body
	regMsg(self, gud_refresh_countrycity_msg, handler(self, self.updateViews))

	regMsg(self, gud_world_dot_change_msg, handler(self, self.refreshListView))

	regMsg(self, gud_block_city_occupy_change_push_msg, handler(self, self.refreshListView))
	
end

-- 注销消息
function DlgCountryCity:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_countrycity_msg)
	unregMsg(self, gud_world_dot_change_msg)
	unregMsg(self, gud_block_city_occupy_change_push_msg)
end


--暂停方法
function DlgCountryCity:onPause( )
	-- body
	Player:getCountryData():clearCountryCityRed()	
	self:unregMsgs()
end

--继续方法
function DlgCountryCity:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

function DlgCountryCity:onListViewItemCallBack( _index, _pView )
	-- body
	local pTempView = _pView
    if pTempView == nil then
        pTempView = ItemCountryCityLayer.new()                        
        pTempView:setViewTouched(false)
    end        
    if self.pDataList and self.pDataList[_index] then
    	pTempView:setCurData(self.pDataList[_index])
	end
    return pTempView	
end

return DlgCountryCity