----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-10-24 16:12:57
-- Description: 魔兵讨伐
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local AttackMoBingHelp = require("app.layer.activityb.wuwang.AttackMoBingHelp")

local MoBingTaoFa = class("MoBingTaoFa", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function MoBingTaoFa:ctor( _tSize )
    self:setContentSize(_tSize)
	--解析文件
	parseView("lay_mobingtaofa", handler(self, self.onParseViewCallback))
end

--解析界面回调
function MoBingTaoFa:onParseViewCallback( pView )
	--pView:setContentSize(self:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("MoBingTaoFa", handler(self, self.onMoBingTaoFaDestroy))
end

-- 析构方法
function MoBingTaoFa:onMoBingTaoFaDestroy(  )
    self:onPause()
end

function MoBingTaoFa:regMsgs(  )
end

function MoBingTaoFa:unregMsgs(  )
end

function MoBingTaoFa:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function MoBingTaoFa:onPause(  )
	self:unregMsgs()

end

function MoBingTaoFa:setupViews(  )
	local pTxtDesc = self:findViewByName("txt_desc")
	pTxtDesc:setString(getTipsByIndex(20033))

	local pLayBtn = self:findViewByName("lay_btn")
	local pGoBtn = getCommonButtonOfContainer(pLayBtn ,TypeCommonBtn.L_BLUE, getConvertedStr(3, 10476))
	pGoBtn:onCommonBtnClicked(handler(self, self.onGoClicked))

	local tConTable = {}
	--文本
	local tLabel = {
		{getConvertedStr(3, 10479),getC3B(_cc.white)},
	}
	tConTable.tLabel = tLabel
	pGoBtn:setBtnExText(tConTable)
	self.pLayContent = self:findViewByName("lay_content")
	--创建
	self.bIsCanGetItem = true
	self.pLayMoBingHelp = AttackMoBingHelp.new(self)		
	self.pLayContent:addView(self.pLayMoBingHelp, 1)
	self.pLayMoBingHelp:setPosition(60, 220)
end


function MoBingTaoFa:setCanShowGetItem( bIsCanGetItem )
	self.bIsCanGetItem = bIsCanGetItem
end

function MoBingTaoFa:getIsCanShowGetItem( )
	return self.bIsCanGetItem
end

function MoBingTaoFa:updateViews(  )
end

function MoBingTaoFa:onGoClicked( )
	sendMsg(ghd_world_dot_near_my_city, {nDotType = e_type_builddot.wildArmy, bIsClicked = true})
   	closeDlgByType(e_dlg_index.wuwang, false)
   	closeDlgByType(e_dlg_index.actmodelb, false)
   	closeDlgByType(e_dlg_index.wildarmy, false)
end

return MoBingTaoFa



