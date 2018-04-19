-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-04-02 20:46:40 星期一
-- Description: 国家任务
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ItemCountryTask = class("ItemCountryTask", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemCountryTask:ctor(  )
	-- body
	self:myInit()
	parseView("item_country_task", handler(self, self.onParseViewCallback))

end

--初始化成员变量
function ItemCountryTask:myInit( )
	-- body	
	self.tCurData 			= 	nil 				--当前数据	
	self.nHandler 			= 	nil 				--回调事件	
end

--解析布局回调事件
function ItemCountryTask:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemCountryTask",handler(self, self.onDestroy))
end

--初始化控件
function ItemCountryTask:setupViews( )
	-- body
	self.pLayRoot = self:findViewByName("lay_default")
	self.pLayTitle = self:findViewByName("lay_title")
	self.pLayCont = self:findViewByName("lay_cont")

	self.pLbTitle = self:findViewByName("lb_title")
	self.pLbNum = self:findViewByName("lb_num")
	self.pImgFlag = self:findViewByName("img_flag")
	self.pLayReward = self:findViewByName("lay_reward")

	self.pLayBtn = self:findViewByName("lay_btn")
	self.pBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.M_BLUE, getConvertedStr(6, 10216), false)
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))
end

-- 修改控件内容或者是刷新控件数据
function ItemCountryTask:updateViews( )
	-- body
	if not self.tCurData then
		return		
	end
	-- dump(self.tCurData, "self.tCurData", 100)	
	--标题
	local pData = self.tCurData
	local nStart, nEnd = string.find(pData.sName, "%d+")
	if nStart and nEnd then
		local nNum = string.sub(pData.sName, nStart, nEnd)
		local sTmp = string.format(";%s:%s;", nNum, _cc.yellow)
		local sStr = string.gsub(pData.sName, "%d+", sTmp)
		self.pLbTitle:setString(getTextColorByConfigure(sStr), false)
	else
		self.pLbTitle:setString(pData.sName, false)
	end
	--完成度
	local sNum = string.format("%s:%s;/%s", pData.nCurNum, _cc.green, pData.nTargetNum)
	self.pLbNum:setString(getTextColorByConfigure(sNum), false)

	--奖励物品
	local tReward = getDropById(pData.nDropId)
	if tReward and #tReward > 0 then
		table.sort(tReward, function ( a, b )
			-- body
			return a.nQuality > b.nQuality
		end)
	end
	gRefreshHorizontalList(self.pLayReward, tReward)
	
	--按钮状态
	if pData.bGet then--已经领取
		self.pBtn:setButton(TypeCommonBtn.M_YELOW, getConvertedStr(6, 10217))
		self.pBtn:setBtnEnable(false)	
		self.pBtn:removeLingTx()	
	else
		self.pBtn:setBtnEnable(true)
		if pData.bFinished then--已经完成
			self.pBtn:setButton(TypeCommonBtn.M_YELLOW, getConvertedStr(6, 10217))
			self.pBtn:showLingTx()
		else
			self.pBtn:setButton(TypeCommonBtn.M_BLUE, getConvertedStr(6, 10216))
			self.pBtn:removeLingTx()
		end
	end
end

-- 析构方法
function ItemCountryTask:onDestroy(  )
	-- body
end

function ItemCountryTask:setCurData( _data )
	-- body
	self.tCurData = _data
	self:updateViews()
end

function ItemCountryTask:getData(  )
	-- body
	return self.tCurData
end

--设置点击事件回到
function ItemCountryTask:setBtnClickCallBack( _handler)
	-- body
	self.nHandler = _handler
end

--按钮点击回调
function ItemCountryTask:onBtnClicked( pView )
	-- body
	if self.nHandler then
		self.nHandler(self.tCurData)
	end	
end



return ItemCountryTask