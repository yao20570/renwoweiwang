-- ItemBuild.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-1-29 17:14:23 星期一
-- Description: 等级预告建筑图片和名字层
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ItemBuild = class("ItemBuild", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemBuild:ctor(_index)
	-- body	
	self:myInit(_index)	
	parseView("item_build", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemBuild:myInit(_index)
	-- body
	self.idx = _index
	self.nBuildId  = nil 				--建筑id
end

--解析布局回调事件
function ItemBuild:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemBuild",handler(self, self.onItemBuildDestroy))
end

--初始化控件
function ItemBuild:setupViews()
	-- body
	self.pImgBuild     		= self:findViewByName("img_build")
	self.pLbBuildName    	= self:findViewByName("lb_buildname")
end

-- 修改控件内容或者是刷新控件数据
function ItemBuild:updateViews()
	if not self.nBuildId then
		self.pLbBuildName:setString("")
		self.pImgBuild:setCurrentImage("ui/daitu.png")
		return
	end
	local tBuildData = Player:getBuildData():getBuildById(self.nBuildId, true)
	if tBuildData == nil then
		local pBuildDBData = getBuildDataByIdFromDB(self.nBuildId)
		local BSuburb = require("app.layer.build.data.BSuburb")
		tBuildData = BSuburb.new()
		tBuildData:initDatasByDB(pBuildDBData)
		tBuildData.nCellIndex = 1001
	end
	if tBuildData then
		self.pLbBuildName:setString(tBuildData.sName)
		local tShowData = getBuildGroupShowDataByCell(tBuildData.nCellIndex, tBuildData.sTid)
		if tShowData and tShowData.img then
			self.pImgBuild:setCurrentImage(tShowData.img)
		end
		--城内建筑和郊外资源图片大小不一样, 所以缩放值也不一样
		if tBuildData.nCellIndex < n_start_suburb_cell then --城内建筑
			self.pImgBuild:setScale(0.3)
		else
			self.pImgBuild:setScale(0.5)
		end
	end
end

-- 析构方法
function ItemBuild:onItemBuildDestroy()
	-- body
end

-- 设置单项数据
function ItemBuild:setBuildData(_data)
	if _data then
		self.nBuildId = tonumber(_data)
	end
	self:updateViews()
end


return ItemBuild