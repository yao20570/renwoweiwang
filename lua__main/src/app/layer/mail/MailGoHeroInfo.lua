----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-22 18:01:30
-- Description: 侦查邮件 武将列表
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemMailGoHeroInfo = require("app.layer.mail.ItemMailGoHeroInfo")

local MailGoHeroInfo = class("MailGoHeroInfo", function( pSize )
	local pView = MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
	pView:setContentSize(pSize)
	return pView
end)

--tGoHeros
function MailGoHeroInfo:ctor( pSize, tGoHeros )
	self.tGoHeros = tGoHeros

	self.pListView = MUI.MListView.new {
		viewRect   = cc.rect(0, 0, pSize.width, pSize.height - 10),
		direction  = MUI.MScrollView.DIRECTION_VERTICAL,
		itemMargin = {left = 0,
             right =  0,
             top =  0,
             bottom =  10},
    }
    self:addView(self.pListView)
	
	self.pListView:setItemCallback(function ( _index, _pView ) 
	    local pTempView = _pView
	    local pTempData = self.tGoHeros[_index]
	    if pTempView == nil then
	    	pTempView   = ItemMailGoHeroInfo.new()
		end
		pTempView:setData(pTempData)
	    return pTempView
	end)

	--数量
	self.pListView:setItemCount(#self.tGoHeros)
	-- 载入所有展示的item
	self.pListView:reload()
end

-- 析构方法
function MailGoHeroInfo:onMailGoHeroInfoDestroy(  )
    self:onPause()
end

function MailGoHeroInfo:regMsgs(  )
end

function MailGoHeroInfo:unregMsgs(  )
end

function MailGoHeroInfo:onResume(  )
	self:regMsgs()
end

function MailGoHeroInfo:onPause(  )
	self:unregMsgs()
end

function MailGoHeroInfo:setupViews(  )
end

function MailGoHeroInfo:updateViews(  )
end

return MailGoHeroInfo


