-- DlgLevelPreview.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-1-29 10:36:23 星期一
-- Description: 等级预告
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ItemLevelPreview = require("app.layer.notice.ItemLevelPreview")

local DlgLevelPreview = class("DlgLevelPreview", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function DlgLevelPreview:ctor( _tSize )
	-- body
	self:setContentSize(_tSize.width, 1000)
	self:myInit()
	parseView("dlg_level_preview", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgLevelPreview:myInit(  )
	-- body
	self.tConfData = {}
end

--解析布局回调事件
function DlgLevelPreview:onParseViewCallback( pView )
	-- body
	self.pView = pView
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgLevelPreview",handler(self, self.onDlgLevelPreviewDestroy))
end

--初始化控件
function DlgLevelPreview:setupViews()
	-- body
	self.pLayList 		= self:findViewByName("lay_list")
end

function DlgLevelPreview:updateViews()
	-- body
	local nLevel = Player:getPlayerInfo().nLv
	self.tConfData = {}
	--获取配置数据
	local tConfData = getLevelPreviewData()
	local nId = 1
	for id, v in pairs(tConfData) do
		--取第一个大于主公等级的配置数据
		if v.level > nLevel then
			self.tConfData[2] = v
			nId = id - 1 --当前等级读取的id
			break
		end
	end
	if not self.tConfData[2] then
		return
	end
	if tConfData[nId] then
		self.tConfData[1] = tConfData[nId]
	end
	if not self.pListView then
		self.pListView = createNewListView(self.pLayList, nil, nil, nil, 0, 30)
		self.pListView:setScrollTouchEnabled(false)
		self.pListView:setBounceable(false)
		self.pListView:setItemCount(2)
		self.pListView:setItemCallback(function ( _index, _pView ) 
		 	local pTempView = _pView
		    if pTempView == nil then
		        pTempView = ItemLevelPreview.new(_index)                        
		        pTempView:setViewTouched(false)   
		    end   
		    if self.tConfData[_index] then
		    	pTempView:setItemData(self.tConfData[_index])    	
		    end 
		    return pTempView	
		end)
		self.pListView:reload(false)
	else
		self.pListView:notifyDataSetChange(false)
	end
end

-- 析构方法
function DlgLevelPreview:onDlgLevelPreviewDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgLevelPreview:regMsgs(  )
	-- body
end
--注销消息
function DlgLevelPreview:unregMsgs(  )
	-- body
end

-- 暂停方法
function DlgLevelPreview:onPause()
	self:unregMsgs()	
end

--继续方法
function DlgLevelPreview:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

return DlgLevelPreview