--
-- Author: liangzhaowei
-- Date: 2017-04-18 09:27:06
-- 按钮上方扩展内容

local MCommonView = require("app.common.MCommonView")

local MBtnExText = class("MBtnExText", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

local IMGLABELGAP = 5 --图片与文字间的间隙

MBTNEXTEXTHEIGHT = 10 --扩展内容与按钮之间的排版高度

local tImgScaleSize = 0.8 --图片不可以超过文字的倍数

local nLabelSize_i = 20 --默认字体的大小


--_table.parent 存放按钮的父层 _table.img 图片 _table.tLabel 


-- local tBtnTable = {}
-- tBtnTable.img = "ui/i85001.png"
-- --文本
-- local tLabel = {
-- 	{"消耗体力: ",getC3B(_cc.white)},
-- 	{"1",getC3B(_cc.white)},
-- 	{"/"},
-- 	{"10",getC3B(_cc.white)},
-- }

--_table.awayH 扩展内容层离存放按钮的父层 的高度 (默认self.nAwayH 的高度)
function MBtnExText:ctor( _table ,_isScaleImg)


	self:myInit()

	if _isScaleImg ~= nil then
		self.isResetImgScale=_isScaleImg
	end


	--存放按钮的父层
	if _table.parent then
		self.pContainer = _table.parent
		self.pContainer:getParent():addView(self)
	end


	-- self:setBackgroundImage("#v3_bg1.png")

    --字体的大小
	local nLabelSize = _table.fontSize or nLabelSize_i
	
	--存放扩展内容的文本内容
	if _table.tLabel and table.nums(_table.tLabel) > 0 then
        --添加文本
		for k,v in pairs(_table.tLabel) do
			self.tLbList[k] = MUI.MLabel.new({text = v[1] or "", size = nLabelSize})
			self.tLbList[k]:setAnchorPoint(cc.p(0,0.5))
			self.tLbList[k]:setColor(v[2] or getC3B(_cc.white))
			self:addView(self.tLbList[k])
		end
	end


	--扩展内容层离存放按钮的父层 的高度
	if _table.awayH then
		self.nAwayH = _table.awayH
	else
		self.nAwayH = MBTNEXTEXTHEIGHT
	end

	--添加图片
	if _table.img then
		self.pImg = MUI.MImage.new(_table.img)
		self.pImg:setAnchorPoint(cc.p(0,0.5))
		self:addView(self.pImg,2)
	end

	--重新设置位置
	self:resetLayerSize()


	self:setupViews()
	--注册析构方法
	self:setDestroyHandler("MBtnExText",handler(self, self.onDestroy))
end

--初始化成员变量
function MBtnExText:myInit(  )
	-- body
	self.pContainer 		= nil           --存放按钮的父层
	self.pImg               = nil           --存放扩展内容中的图片
	self.pLabel             = nil           --存放扩展内容中的文本

	self.nAwayH             = 0             --扩展内容层离存放按钮的父层 的高度
	self.nInterval          = IMGLABELGAP   --图片与文字间的间隙
	self.tLbList            = {}            --文本table

	self.isResetImgScale 	=true   		--是否需要重新设置图片大小
end


--设置文本与颜色 _index 下标 _cn 内容 _color 颜色 (只刷新已经存在文本)
function MBtnExText:setLabelCnCr(_index,_cn,_color)
	if self.tLbList and table.nums(self.tLbList) > 0 and _index then
		for k,v in pairs(self.tLbList) do
			if k == _index then
				--内容
				if _cn then 
       				v:setString(tostring(_cn),false)
				end
				--颜色
				if _color then
					v:setColor(_color)
				end
			end
		end
        self:resetLayerSize()
	end
end

--重新计算位置 bAddLoc
function MBtnExText:resetLayerSize()
	local nImgH = 0
	local nImgW = 0
	local nLabelW = 0
	local nLabelH = 0

	--扩展层大小
	local nMaxH = 0
	local nMaxW = 0

	if self.tLbList and table.nums(self.tLbList)> 0 then
		for k, v in pairs(self.tLbList) do
			if v:getHeight() > nLabelH then
				nLabelH = v:getHeight()
			end	   		
		end
	end

	
	if self.pImg  then
		if self.isResetImgScale  then
			local nImgScale = 1
			nImgScale =  nLabelH / tImgScaleSize  / self.pImg:getHeight()
			self.pImg:setScale(nImgScale)
		end
		nImgW = self.pImg:getWidth() * self.pImg:getScale()
		nImgH = self.pImg:getHeight() * self.pImg:getScale()
		self.nInterval          = IMGLABELGAP --图片与文本之间存在间隙
	else
		self.nInterval          = 0
	end

	nMaxW = self.nInterval + nImgW

	--设置最大高度
	if nImgH < nLabelH then
		nMaxH = nLabelH
	else
		nMaxH = nImgH
	end
    
    --重置文本位置
	if self.tLbList and table.nums(self.tLbList)> 0 then
		for k,v in pairs(self.tLbList) do
			v:setPosition(nMaxW,nMaxH/2)
			nMaxW = nMaxW + v:getWidth()
		end
	end


	--根据位置对齐方式进行位置分配
	local nLocX = 0
	local nLocY = 0
	if self.pContainer then
		nLocX = self.pContainer:getPositionX() +self.pContainer:getWidth()/2 - nMaxW/2
		nLocY = self.nAwayH +  self.pContainer:getPositionY() +self.pContainer:getHeight()
		self:setPosition(nLocX,nLocY)
	end



	--设置层的大小
	self:setLayoutSize(nMaxW,nMaxH)


	--重置图片位置
	if self.pImg then
		self.pImg:setPosition(0,nMaxH/2)
	end

	--重置红线
	self:updateRedLine()
end



--设置图片 _strImg 注意是否属于纹理图片(纹理图片需要添加"#")
---_strImg 为空的时候则移除图片
function MBtnExText:setImg(_strImg,_isScaleImg)
	if _isScaleImg ~=nil then
		self.isResetImgScale=_isScaleImg 
	end
	if _strImg then
		if self.pImg then
			self.pImg:setCurrentImage(_strImg)
		else
			self.pImg = MUI.MImage.new(_strImg)
			local nMaxH = self.pImg:getHeight()
			if self.pLabel then
				if self.pLabel:getHeight() > nMaxH then
				   nMaxH = self.pLabel:getHeight()
				end
			end
			self.pImg:setAnchorPoint(cc.p(0,0.5))
			self.pImg:setPosition(0,nMaxH/2)
			self:addView(self.pImg)
		end
	else
		if self.pImg then
			self.pImg:removeFromParent(true)
			self.pImg = nil
		end
	end
	self:resetLayerSize()
end


--初始化控件
function MBtnExText:setupViews()
end

-- 修改控件内容或者是刷新控件数据
function MBtnExText:updateViews(  )
end

-- 析构方法
function MBtnExText:onDestroy(  )
	-- body
end

--设置扩展内容是否隐藏
function MBtnExText:setBtnExTextEnabled(_bEnabled)
	self:setVisible(_bEnabled)
end

--重设高度距离  _nH 增加的高度
function MBtnExText:addHeight(_nH)
	if _nH then
		self.nAwayH =  self.nAwayH + _nH
		self:resetLayerSize()
	end
end

--添加红色删除线(bAll:如果为true则整个文本加上红线)
function MBtnExText:addRedLine( nlabelIndex, bAll )
	self.nRedLabelIndex = nlabelIndex
	self.bAllAddLine = bAll
	if not self.pImgLine then
		self.pImgLine =  MUI.MImage.new("#v1_line_red2.png")
		self.pImgLine:setAnchorPoint(0,0.5)
		self.pImgLine._orginWidth = self.pImgLine:getContentSize().width
		self:addView(self.pImgLine, 99)
	end
end

--更新红色删除线
function MBtnExText:updateRedLine(  )
	if not self.pImgLine then
		return
	end
	--如果整个文本加红线
	if self.bAllAddLine then
		self.pImgLine:setPosition(0, self:getContentSize().height/2)
		local fScaleW = self:getContentSize().width/self.pImgLine._orginWidth
		self.pImgLine:setScaleX(fScaleW)
		if self:getContentSize().width > 0 then
			self.pImgLine:setVisible(true)
		else
			self.pImgLine:setVisible(false)
		end
		return
	end

	if not self.nRedLabelIndex then
		return
	end
	if not self.tLbList[self.nRedLabelIndex] then
		return
	end
	local pLabel = self.tLbList[self.nRedLabelIndex]
	local x, y = pLabel:getPosition()
	self.pImgLine:setPosition(x, y)

	local fScaleW = pLabel:getContentSize().width/self.pImgLine._orginWidth
	self.pImgLine:setScaleX(fScaleW)
	if pLabel:getContentSize().width > 0 then
		self.pImgLine:setVisible(true)
	else
		self.pImgLine:setVisible(false)
	end
end

function MBtnExText:setImgScale(_nScale )
	-- body
	if not _nScale then
		return
	end
	if self.pImg then
		self.pImg:setScale(_nScale)
	end
	self:resetLayerSize()
end


return MBtnExText