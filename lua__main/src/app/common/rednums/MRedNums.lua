-- Author: liangzhaowei
-- Date: 2017-04-24 16:45:45
-- 红点层 (26*26)

local MCommonView = require("app.common.MCommonView")
local MRedNums = class("MRedNums", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function MRedNums:ctor(nType)
	-- body
	self:myInit()

	self.nType =nType or 0

	parseView("item_red_nums", handler(self, self.onParseViewCallback))


	--注册析构方法
	self:setDestroyHandler("MRedNums",handler(self, self.onDestroy))
	
end

--初始化参数
function MRedNums:myInit()
	self.nType = 0 --类型
	self.nNums = 0 --数量
end

--解析布局回调事件
function MRedNums:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	--img         	
	self.pImgRed = self:findViewByName("img_red")

	--lb
	self.pLbNums = self:findViewByName("lb_nums")
	

	-- self:setupViews()
	-- self:updateViews()
end

--初始化控件
function MRedNums:setupViews( )

end

-- 修改控件内容或者是刷新控件数据
function MRedNums:updateViews()


	-- body
	--根据类型是否显红点个数
	if self.nType == 0 then
		self.pLbNums:setVisible(false)
		self.pImgRed:setScale(0.7)
	else
		self.pImgRed:setScale(1)
		if self.nNums then
			self.pLbNums:setString(self.nNums)
		end
		self.pLbNums:setVisible(true)
	end



	--根据数量显示红点层
	if self.nNums then
		if self.nNums == 0 then
			self:setVisible(false)
		else
			self:setVisible(true)
		end
	else
		self:setVisible(false)
	end

end

--析构方法
function MRedNums:onDestroy(  )
	-- body
end

--设置数据 _data
function MRedNums:setCurData(_nType,_nNum)

	self.nType = _nType or 0
	self.nNums = _nNum or 0


	self:updateViews()	


end


return MRedNums