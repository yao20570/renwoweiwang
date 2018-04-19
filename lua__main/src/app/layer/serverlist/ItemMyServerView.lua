-- Author: liangzhaowei
-- Date: 2017-05-31 17:46:46
-- 登录过的服务器列表信息

local MCommonView = require("app.common.MCommonView")
local ItemMyServerView = class("ItemMyServerView", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function ItemMyServerView:ctor()
	-- body
	self:myInit()

	parseView("item_server_view_my", handler(self, self.onParseViewCallback))


	--注册析构方法
	self:setDestroyHandler("ItemMyServerView",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemMyServerView:myInit()
	self.pData = {} --数据
end

--解析布局回调事件
function ItemMyServerView:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	--ly   
	self.pLyTips = self:findViewByName("layout_tip")
	self.pLayoutMain = self:findViewByName("item_server_view")

	--lb
	self.pLbServerNum = self:findViewByName("label_server_num")
	setTextCCColor(self.pLbServerNum, _cc.pwhite)
	self.pLbState = self:findViewByName("label_state")
	self.pLbTip = self:findViewByName("label_tip")
	self.pLbName = self:findViewByName("lb_name")
	setTextCCColor(self.pLbName, _cc.blue)



	--img
	self.pImgTip = self:findViewByName("img_tip")
	self.pImgTip:setFlippedX(true)


    self.pLayoutMain:setViewTouched(true)
	self.pLayoutMain:setIsPressedNeedScale(false)
    self.pLayoutMain:onMViewClicked(handler(self,self.onGetClick))

	

	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemMyServerView:setupViews( )

end

-- 修改控件内容或者是刷新控件数据
function ItemMyServerView:updateViews(  )
	-- body
end


--获得按钮回调
function ItemMyServerView:onGetClick()
	if self.pData then
		changeServer(self.pData)
	end
end


--析构方法
function ItemMyServerView:onDestroy(  )
	-- body
end

--设置数据 _data
function ItemMyServerView:setCurData(_tData)
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
			--最近服
			if v == en_server_state.last then
				nShowState = v
				break
			end			
		end
	end

	if self.pData.nRecent and ( self.pData.nRecent > 0) then
		self.pLyTips:setVisible(true)
		self.pLbState:setVisible(false)
		self.pLbTip:setString(getConvertedStr(5, 10122))
		self.pImgTip:setCurrentImage("#v1_img_kejiman.png")
	else
		--状态显示
		if nShowState == en_server_state.maintain then  --维护
			self.pLyTips:setVisible(false)
			self.pLbState:setVisible(true)
			self.pLbState:setString(getConvertedStr(5, 10119))
			setTextCCColor(self.pLbState, _cc.blue)
		elseif nShowState == en_server_state.full then  --爆满
			self.pLyTips:setVisible(false)
			self.pLbState:setVisible(true)
			self.pLbState:setString(getConvertedStr(5, 10120))
			setTextCCColor(self.pLbState, _cc.red)
		else
			self.pLyTips:setVisible(false)
			self.pLbState:setVisible(true)
			self.pLbState:setString(getConvertedStr(5, 10120))
			setTextCCColor(self.pLbState, _cc.red)
		-- elseif nShowState == en_server_state.last then  --最近服
		-- 	self.pLyTips:setVisible(true)
		-- 	self.pLbState:setVisible(false)
		-- 	self.pLbTip:setString(getConvertedStr(5, 10122))
		-- 	self.pImgTip:setCurrentImage("#v1_img_kejiman.png")
		end	
	end


	--设置名字等级
	if self.pData.name and self.pData.lv then
		self.pLbName:setString(self.pData.name..getLvString(self.pData.lv))
	end



end


return ItemMyServerView