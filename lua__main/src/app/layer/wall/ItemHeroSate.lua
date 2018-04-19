-- Author: liangzhaowei
-- Date: 2017-05-16 15:56:49
-- 守城武将状态

local MCommonView = require("app.common.MCommonView")
local ItemHeroSate = class("ItemHeroSate", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemHeroSate:ctor()
	-- body
	self:myInit()


	parseView("item_wall_hero_state", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemHeroSate",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemHeroSate:myInit()
	self.tCurData  			= 	nil 						-- 当前数据

end

--解析布局回调事件
function ItemHeroSate:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)



	--img
	self.pImgBingzhong = self:findViewByName("img_bingzhong")

	--lb
	self.pLbState = self:findViewByName("lb_state")

	


	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemHeroSate:setupViews( )

end

-- 修改控件内容或者是刷新控件数据
function ItemHeroSate:updateViews(  )
end

--析构方法
function ItemHeroSate:onDestroy(  )
	-- body
end




--设置数据 _data
function ItemHeroSate:setCurData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}

	--显示兵种
	self.pImgBingzhong:setCurrentImage(getSoldierTypeImg(self.pData.nKind))

	--出征状态
	if self.pData and self.pData.nW then
		if self.pData.nW == 0 then
			self.pLbState:setString(getConvertedStr(5, 10022))
			setTextCCColor(self.pLbState, _cc.green)
		elseif self.pData.nW == 1 then
			self.pLbState:setString(getConvertedStr(5, 10082))
			setTextCCColor(self.pLbState, _cc.yellow)
		end
	end


	
end


return ItemHeroSate