----------------------------------------------------- 
-- author: maheng
-- updatetime: 2017-06-07 16:37:14
-- Description: 官员层
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local ItemOfficial = class("ItemOfficial", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)


function ItemOfficial:ctor(  )
	-- body
	self:myInit()
	parseView("item_official", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemOfficial:myInit(  )
	-- body
	self.tCurData = nil
	self.nIndex = 1
end

--解析布局回调事件
function ItemOfficial:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemOfficial",handler(self, self.onItemOfficialDestroy))
end

--初始化控件
function ItemOfficial:setupViews( )
	-- body
	--
	self.pLayIcon = self:findViewByName("lay_icon")
	
	self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconHero.NORMAL,type_icongoods_show.item, nil, TypeIconHeroSize.M)

	self.pLbName = self:findViewByName("lb_name")
	setTextCCColor(self.pLbName, _cc.pwhite)	

	self.pImgFlag = self:findViewByName("img_flag")	

	self.pImgBg = self:findViewByName("img_bg")
end

-- 修改控件内容或者是刷新控件数据
function ItemOfficial:updateViews( )
	-- body
	if self.tCurData then
		--local sImgPath = self.tCurData.sIcon or "ui/daitu.png"
		--self.pImgIcon:setCurrentImage(sImgPath)

		-- local data = {}
		-- data.nGtype = e_type_goods.type_head --头像
		-- data.sIcon = sImgPath
		-- data.nQuality = 100
		self.pIcon:setCurData(self.tCurData)

		self.pLbName:setString(self.tCurData.sName)
		-- self.pLbName:setVisible(true)
		setTextCCColor(self.pLbName,_cc.white)
	else

		self.pIcon:setCurData({nQuality = 1})
		self.pLbName:setString(getConvertedStr(9,10233), false)
		setTextCCColor(self.pLbName,_cc.pwhite)

		local sImg = "#v1_img_youxiangjianying03.png"
		if self.nIndex == 1 then
			sImg = "#v1_img_youxiangjianying03.png"
		elseif self.nIndex == 2 then
			sImg = "#v1_img_youxiangjianying.png"
		elseif self.nIndex == 3 then
			sImg = "#v1_img_youxiangjianying02.png"
		end
		-- self.pIcon:setIconBg("#v1_img_touxiangkuanghui.png")
		self.pIcon:setIconImg(sImg,6)
		self.pIcon:setIsShowNumber(false)
		


	end
end

-- 析构方法
function ItemOfficial:onItemOfficialDestroy(  )
	-- body
end

--设置图标
function ItemOfficial:setImg( _img, _nscale )
	-- body
	if _img then
		self.pImgFlag:setCurrentImage(_img)
	end
	if _nscale then
		self.pImgFlag:setScale(_nscale)
	else
		self.pImgFlag:setScale(1)
	end
end

function ItemOfficial:setImgBg( sImgBg )
	-- body
	if sImgBg then
		self.pImgBg:setCurrentImage(sImgBg)		
	end
end

--
function ItemOfficial:setCurData( _data,_nIndex )
	-- body
	self.tCurData = _data
	self.nIndex = _nIndex
	self:updateViews()
end
return ItemOfficial


