-- Author: liangzhaowei
-- Date: 2017-05-31 16:16:00
-- 服务器列表信息

local MCommonView = require("app.common.MCommonView")
local ItemServerView = class("ItemServerView", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function ItemServerView:ctor()
	-- body
	self:myInit()

	parseView("item_server_view", handler(self, self.onParseViewCallback))


	--注册析构方法
	self:setDestroyHandler("ItemServerView",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemServerView:myInit()
	self.pData = {} --数据
end

--解析布局回调事件
function ItemServerView:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	--ly   
	self.pLyTips = self:findViewByName("layout_tip")
	self.pLayoutMain = self:findViewByName("item_server_view")

	--lb
	self.pLbServerNum = self:findViewByName("label_server_num")
	self.pLbState = self:findViewByName("label_state")
	self.pLbTip = self:findViewByName("label_tip")
	self.pLbName = self:findViewByName("label_name")

	--img
	self.pImgTip = self:findViewByName("img_tip")

    self.pLayoutMain:setViewTouched(true)
	self.pLayoutMain:setIsPressedNeedScale(false)
    self.pLayoutMain:onMViewClicked(handler(self,self.onGetClick))

	

	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemServerView:setupViews( )

end

-- 修改控件内容或者是刷新控件数据
function ItemServerView:updateViews(  )
	-- body
end

--获得按钮回调
function ItemServerView:onGetClick()
	if self.pData then
		changeServer(self.pData)
	end
end

function ItemServerView:setMyName(_sName)
	if not _sName then
		self.pLbName:setString("")
	else
		self.pLbName:setString(_sName)
	end
end

--析构方法
function ItemServerView:onDestroy(  )
	-- body
end

--设置数据 _data
function ItemServerView:setCurData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}

	--显示服务器名字
	if self.pData then
		self.pLbServerNum:setString(getServerNameByServer(self.pData))
	end

	local nShowState = en_server_state.full
	--解析服务器状态
	if self.pData.tState and table.nums(self.pData.tState)> 0 then
		for k,v in pairs(self.pData.tState) do
			--维护中
			if v == en_server_state.maintain then
				nShowState = v
				break
			end
			--推荐服
			if v == en_server_state.recomm then
				nShowState = v
				break
			end			
		end
	end

	if self.pData.name and self.pData.lv then
		self.pLbName:setString(self.pData.name.." Lv."..self.pData.lv)
	else
		self.pLbName:setString("")
	end
	self.pLbState:setVisible(false)
	self.pLyTips:setVisible(false)
	if nShowState == en_server_state.maintain then  --维护
		self.pLyTips:setVisible(true)
		self.pLbTip:setString(getConvertedStr(5, 10119))
		self.pImgTip:setCurrentImage("#v2_img_weihu.png")
	elseif self.pData.nRecent and ( self.pData.nRecent > 0) then --最近
		self.pLyTips:setVisible(true)
		self.pLbTip:setString(getConvertedStr(5, 10122))
		self.pImgTip:setCurrentImage("#v2_img_zuijin.png")
	elseif nShowState == en_server_state.full then  --爆满
		-- self.pLyTips:setVisible(false)
		-- self.pLbState:setVisible(false)
		-- self.pLbState:setString(getConvertedStr(5, 10120))
		-- setTextCCColor(self.pLbState, _cc.red)
	elseif nShowState == en_server_state.recomm then  --推荐服
		self.pLyTips:setVisible(true)
		self.pLbTip:setString(getConvertedStr(5, 10121))
		self.pImgTip:setCurrentImage("#v2_img_tuijian.png")
	end	

end


return ItemServerView