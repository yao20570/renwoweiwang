-- Author: liangzhaowei
-- Date: 2017-05-31 14:56:33
-- 服务器列表中选择服务器列表标签


local MCommonView = require("app.common.MCommonView")
local ItemServerTab = class("ItemServerTab", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数 _type
function ItemServerTab:ctor()
	-- body
	self:myInit()

	parseView("item_server_tab", handler(self, self.onParseViewCallback))


	--注册析构方法
	self:setDestroyHandler("ItemServerTab",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemServerTab:myInit()
	self.pData = {} --数据
	self.nIndex = 1 --下标
end

--解析布局回调事件
function ItemServerTab:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	--layout
    self.pLayoutMain = self:findViewByName("ly_main")
    self.pLyRed = self:findViewByName("ly_red")
    self.pLyRed:setVisible(false)

 	--img
    self.pImg = self:findViewByName("img_select")
    self.pImgSeleb = self:findViewByName("img_selectb")

    --lb
    self.pLbContent= self:findViewByName("lb_content") --个数
    self.pLbContent:setZOrder(self.pImg:getLocalZOrder()+9)

    self.pLayoutMain:setViewTouched(true)
	self.pLayoutMain:setIsPressedNeedScale(false)
    self.pLayoutMain:onMViewClicked(handler(self,self.onGetClick))

	

	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemServerTab:setupViews( )

end

-- 修改控件内容或者是刷新控件数据
function ItemServerTab:updateViews(  )
	-- body
end

--析构方法
function ItemServerTab:onDestroy(  )
	-- body
end

--设置按钮句柄
-- _handler 
function ItemServerTab:setHandler(_handler)
	self.pHandler = _handler
end

--获得按钮回调
function ItemServerTab:onGetClick()
	if self.pHandler then
		self.pHandler(self.nIndex)
	end
end

--设置数据 _strCon  _index 下标 _selectTab 当前选择的标签
function ItemServerTab:setCurData(_strCon,_index,_selectTab)

	self.nIndex = _index or 1

	--选择框
	if self.nIndex == _selectTab then
		self.pImg:setVisible(true)
		self.pImgSeleb:setVisible(true)
	else
		self.pImg:setVisible(false)
		self.pImgSeleb:setVisible(false)
	end

	

	--文字
	if _strCon then
		self.pLbContent:setString(_strCon)
	end
	

end

--设置红点 _tData 活动数据
function ItemServerTab:setRedNums(_tData)
	if not _tData then
		return
	end

	-- dump(_tData.sName)

	if _tData.getRedNums then
		--红点
		local nRedNum =_tData:getRedNums()
		-- dump(nRedNum,"nRedNum")
		if nRedNum > 0 then
			showRedTips(self.pLyRed,0,1)
			self.pLyRed:setVisible(true)
		else
			showRedTips(self.pLyRed,0,0)
			self.pLyRed:setVisible(false)
		end
	end

	--显示新
	if _tData:getIsNew() then
		showActivityNewVisible(self.pLayoutMain, true, 0.8)
	else
		showActivityNewVisible(self.pLayoutMain, false)
	end
end

function ItemServerTab:getRedLayer(  )
	-- body
	return self.pLyRed
end

return ItemServerTab