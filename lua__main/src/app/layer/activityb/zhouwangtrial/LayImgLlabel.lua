-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-03-19 21:20:23 星期三
-- Description: 纣王试炼主页奖励项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local LayImgLlabel = class("LayImgLlabel", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)


function LayImgLlabel:ctor()
	-- body	
	self:myInit()
	parseView("lay_img_label", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function LayImgLlabel:onParseViewCallback( pView )
	-- body
	self:setContentSize(pView:getContentSize())
	self:addView(pView)

	self:setupViews()	
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("LayImgLlabel",handler(self, self.onDestroy))
end

-- --初始化参数
function LayImgLlabel:myInit()
	-- body

end

--初始化控件
function LayImgLlabel:setupViews( )
	-- body		
	self.pImgMark = self:findViewByName("img_mark")
	self.pLbTip = self:findViewByName("lb_tip")

end

-- 修改控件内容或者是刷新控件数据
function LayImgLlabel:updateViews(  )
	-- body

end

function LayImgLlabel:setData(_tParam)
	-- body
	if not _tParam then
		return 
	end
	if _tParam.text then
		self.pLbTip:setString(_tParam.text, false)
	end
	if _tParam.color then
		setTextCCColor(self.pLbTip, _tParam.color)
	end
end

--析构方法
function LayImgLlabel:onDestroy(  )
	self:onPause()
end

-- 注册消息
function LayImgLlabel:regMsgs( )
	-- body	   
end

-- 注销消息
function LayImgLlabel:unregMsgs(  )
	-- body

end
--暂停方法
function LayImgLlabel:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function LayImgLlabel:onResume( )
	-- body
	self:regMsgs()
	self:updateViews()
end

return LayImgLlabel
