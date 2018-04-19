-- Author: liangzhaowei
-- Date: 2017-05-16 10:06:49
-- 守城npc武将状态
local MCommonView = require("app.common.MCommonView")
local ItemWallNpcState = class("ItemWallNpcState", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemWallNpcState:ctor()
	-- body
	self:myInit()


	parseView("item_wall_npc_state", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemWallNpcState",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemWallNpcState:myInit()
	self.tCurData  			= 	nil 						-- 当前数据

end

--解析布局回调事件
function ItemWallNpcState:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)



	--img
	self.pImgBingzhong = self:findViewByName("img_bingzhong")
	self.pImgUp = self:findViewByName("img_up")
	self.pImgAdd = self:findViewByName("img_add")
	-- self.pLbLv:setVisible(false)


	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemWallNpcState:setupViews( )

end

-- 修改控件内容或者是刷新控件数据
function ItemWallNpcState:updateViews(  )
end

--析构方法
function ItemWallNpcState:onDestroy(  )
	-- body
end




--设置数据 _data
function ItemWallNpcState:setCurData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}

	--显示兵种
	self.pImgBingzhong:setCurrentImage(getSoldierTypeImg(self.pData.nKind))
	--显示升级
	if self.pData.nCt > 0 then
		self.pImgUp:setVisible(true)
	else
		self.pImgUp:setVisible(false)
	end

	--显示是否补充兵
	if self.pData.nTp < self.pData.nTroops then
       self.pImgAdd:setVisible(true)
    else
    	self.pImgAdd:setVisible(false)
	end

	
end


return ItemWallNpcState