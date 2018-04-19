-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-03-31 15:37:29 星期五
-- Description: 公用按钮 MCommonBtn 
-----------------------------------------------------

--按钮属性
local tBtnAttribute = {}

tBtnAttribute[TypeCommonBtn.L_BLUE] = { 
	btnBg = "#v1_btn_blue1.png", 	    --按钮图片
	fontSize =  22,						--字体大小
	fontColor = _cc.white, 				--字体颜色
	fontStrokeColor = "000000ff", 		--描边颜色
	fontStrokeSize = 0, 				--描边大小
}

tBtnAttribute[TypeCommonBtn.L_RED] = { 
	btnBg = "#v1_btn_red1.png", 	    --按钮图片
	fontSize =  22,						--字体大小
	fontColor = _cc.white, 				--字体颜色
	fontStrokeColor = "000000ff", 		--描边颜色
	fontStrokeSize = 0, 				--描边大小
}

tBtnAttribute[TypeCommonBtn.L_YELLOW] = { 
	btnBg = "#v1_btn_yellow1.png", 	    --按钮图片
	fontSize =  22,						--字体大小
	fontColor = _cc.white, 				--字体颜色
	fontStrokeColor = "000000ff", 		--描边颜色
	fontStrokeSize = 0, 				--描大小
}

tBtnAttribute[TypeCommonBtn.M_BLUE] = { 
	btnBg = "#v1_btn_blue2.png", 	    --按钮图片
	fontSize =  20,						--字体大小
	fontColor = _cc.white, 				--字体颜色
	fontStrokeColor = "000000ff", 		--描边颜色
	fontStrokeSize = 0, 				--描边大小
}

tBtnAttribute[TypeCommonBtn.M_RED] = { 
	btnBg = "#v1_btn_red2.png", 	    --按钮图片
	fontSize =  20,						--字体大小
	fontColor = _cc.white, 				--字体颜色
	fontStrokeColor = "000000ff", 		--描边颜色
	fontStrokeSize = 0, 				--描边大小
}

tBtnAttribute[TypeCommonBtn.M_YELLOW] = { 
	btnBg = "#v1_btn_yellow2.png", 	    --按钮图片
	fontSize =  20,						--字体大小
	fontColor = _cc.white, 				--字体颜色
	fontStrokeColor = "000000ff", 		--描边颜色
	fontStrokeSize = 0, 				--描边大小
}

tBtnAttribute[TypeCommonBtn.S_BLUE] = { 
	btnBg = "#v1_btn_blue3.png", 	    --按钮图片
	fontSize =  22,						--字体大小
	fontColor = _cc.white, 				--字体颜色
	fontStrokeColor = "000000ff", 		--描边颜色
	fontStrokeSize = 0, 				--描边大小
}

tBtnAttribute[TypeCommonBtn.O_BLUE] = { 
	btnBg = "#v1_btn_blue4.png", 	    --按钮图片
	fontSize =  22,						--字体大小
	fontColor = _cc.white, 				--字体颜色
	fontStrokeColor = "000000ff", 		--描边颜色
	fontStrokeSize = 0, 				--描边大小
}

tBtnAttribute[TypeCommonBtn.O_RED] = { 
	btnBg = "#v1_btn_red3.png", 	    --按钮图片
	fontSize =  22,						--字体大小
	fontColor = _cc.white, 				--字体颜色
	fontStrokeColor = "000000ff", 		--描边颜色
	fontStrokeSize = 0, 				--描边大小
}

tBtnAttribute[TypeCommonBtn.O_YELLOW] = { 
	btnBg = "#v1_btn_yellow3.png", 	    --按钮图片
	fontSize =  22,						--字体大小
	fontColor = _cc.white, 				--字体颜色
	fontStrokeColor = "000000ff", 		--描边颜色
	fontStrokeSize = 0, 				--描边大小
}

tBtnAttribute[TypeCommonBtn.R_BLUE] = { 
	btnBg = "#v1_btn_blue3.png", 	    --按钮图片
	fontSize =  22,						--字体大小
	fontColor = _cc.white, 				--字体颜色
	fontStrokeColor = "000000ff", 		--描边颜色
	fontStrokeSize = 0, 				--描边大小
}


tBtnAttribute[TypeCommonBtn.B_DARK] = { 
	btnBg = "#v1_btn_biaoqian4.png", 	--按钮图片
	fontSize =  22,						--字体大小
	fontColor = _cc.white, 				--字体颜色
	fontStrokeColor = "000000ff", 		--描边颜色
	fontStrokeSize = 0, 				--描边大小
}


tBtnAttribute[TypeCommonBtn.XL_BLUE] = { 
	btnBg = "#v1_btn_lue1.png", --按钮图片
	fontSize =  22,						--字体大小
	fontColor = _cc.white, 				--字体颜色
	fontStrokeColor = "000000ff", 		--描边颜色
	fontStrokeSize = 0, 				--描边大小
}

tBtnAttribute[TypeCommonBtn.XL_YELLOW] = { 
	btnBg = "#v1_btn_low1.png", --按钮图片
	fontSize =  22,						--字体大小
	fontColor = _cc.white, 				--字体颜色
	fontStrokeColor = "000000ff", 		--描边颜色
	fontStrokeSize = 0, 				--描边大小
}

tBtnAttribute[TypeCommonBtn.XL_BLUE2] = { 
	btnBg = "#v2_btn_blue6.png", --按钮图片
	fontSize =  20,						--字体大小
	fontColor = _cc.white, 				--字体颜色
	fontStrokeColor = "000000ff", 		--描边颜色
	fontStrokeSize = 0, 				--描边大小
}

local MCommonView = require("app.common.MCommonView")
local MBtnExText = require("app.common.button.MBtnExText")


local MCommonBtn = class("MCommonBtn", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_pContainer：存放按钮的父层
function MCommonBtn:ctor( _pContainer )
	-- body
	self:myInit()
	self.pContainer = _pContainer
	self:setupViews()
	--注册析构方法
	self:setDestroyHandler("MCommonBtn",handler(self, self.onMCommonBtnDestroy))
end

--初始化成员变量
function MCommonBtn:myInit(  )
	-- body
	self.pContainer 		= nil           --存放按钮的父层
	self.nBtnType 			= nil 			--按钮类型
	self.tBtnAttri 			= nil 			--按钮属性
	self.sText  			= "" 			--按钮文字

	self._nHandlerBtnClicked = nil 			--按钮点击事件回调
	self._nHandlerBtnDisabled = nil  		--按钮无效事件回调

	self.pBtnExText = nil                   --按钮上方扩展内容

end

--初始化控件
function MCommonBtn:setupViews( )
	-- body
	--初始化按钮（默认一张图片）
	self.pCommonBtn = MUI.MPushButton.new("#v1_btn_yellow1.png")
	self:setContentSize(self.pCommonBtn:getContentSize())
	self:addView(self.pCommonBtn)
	centerInView(self,self.pCommonBtn)

	--屏蔽点击事件
	self.pCommonBtn:setViewTouched(false)

	--设置事件回调方法
	self.pContainer:onMViewClicked(function ( pView )
		if tolua.isnull(self.pContainer) then
			myprint("ERROR tolua.isnull(self.pContainer) is nil")
			return
		end
            local pRedNums =self.pContainer:findViewByTag(91974)--红点层
            if pRedNums then
            	pRedNums:setViewTouched(true)
                pRedNums:performClick(true)
            end

        if self._nHandlerBtnClicked and self:isVisible() == true then        	
			self._nHandlerBtnClicked(pView, self._tCallBackParam)        	
        end
    end)
    self.pContainer:onMViewDisabledClicked(function ( pView )
        if self._nHandlerBtnDisabled and self:isVisible() == true then
        	self._nHandlerBtnDisabled(pView)
        end
    end)
 
	
end


function MCommonBtn:setBtnContentSize( _nFw , _nFh )
	if _nFw and _nFh then
		self.pCommonBtn:setButtonSize(_nFw, _nFh)
		self:setContentSize(_nFw, _nFh)
	end
end

-- 修改控件内容或者是刷新控件数据
function MCommonBtn:updateViews(  )
	-- body
	if self.tBtnAttri then
		self.pCommonBtn:setButtonImage(self.tBtnAttri.btnBg)
		local param = {}
		param.text = self.sText
		param.size = self.tBtnAttri.fontSize
		param.color = getC3B(self.tBtnAttri.fontColor) 
		self.pCommonBtn:setString(param)
		--设置描边
		self:setOutLine(self.tBtnAttri)
		local fw = self.pCommonBtn.m_fBtnWidth or self.pCommonBtn:getContentSize().width
		local fh = self.pCommonBtn.m_fBtnHeight or self.pCommonBtn:getContentSize().height
		if self.nBtnType == TypeCommonBtn.O_BLUE  --可拉伸按钮
			or self.nBtnType == TypeCommonBtn.O_RED 
			or self.nBtnType == TypeCommonBtn.O_YELLOW then
			fw = 110
			fh = 50
		elseif self.nBtnType == TypeCommonBtn.B_DARK then
			fw = 250
			fh = 64
		elseif self.nBtnType == TypeCommonBtn.R_BLUE then
			fw = 176
			fh = 45
		end
		self.pCommonBtn.m_fBtnWidth = fw
		self.pCommonBtn.m_fBtnHeight = fh
		self.pCommonBtn:setButtonSize(fw, fh)
		self:setContentSize(fw, fh)
		centerInView(self,self.pCommonBtn)
		--判断是否需要按钮特效
		self:checkIfNeedTx()
	else
		print("当前没有该按钮类型")
	end
end

function MCommonBtn:setButtonImage(_img)
	if _img and self.pCommonBtn then
		self.pCommonBtn:setButtonImage(_img)
	end
end

function MCommonBtn:setButtonSize(fw, fh)
	if fw and fh and self.pCommonBtn then
		self.pCommonBtn:setButtonSize(fw, fh)
	end
end

--检测是否需要特效
function MCommonBtn:checkIfNeedTx(  )
	-- body
	--判断按钮上的文字是否是 
	local sStr = self:getBtnText()
	local bRight = false
	if sStr == getConvertedStr(5, 10208) --“领取” 
		or sStr == getConvertedStr(3, 10260) --“铁匠加速”
		or sStr == getConvertedStr(1, 10177) then --“学者加速”
		bRight= true
	end
	if bRight and self.pCommonBtn:isViewEnabled() then --领取 并且是可领取状态
		self:showLingTx()
	else
		self:removeLingTx()
	end
end

--展示特效
function MCommonBtn:showLingTx(  )
	-- body
	if not self.pArmLing then
		self.pArmLing = MArmatureUtils:createMArmature(
			tNormalCusArmDatas["5"], 
			self, 
			10, 
			cc.p(self:getWidth() / 2, self:getHeight() / 2),
		    function ( _pArm )

		    end, Scene_arm_type.normal)
		if self.pArmLing then
			--设置缩放比例
			local nWidth = 110
			local nHeight = 50

			if self.nBtnType == TypeCommonBtn.O_BLUE  --可拉伸按钮
				or self.nBtnType == TypeCommonBtn.O_RED 
				or self.nBtnType == TypeCommonBtn.O_YELLOW 
				or self.nBtnType == TypeCommonBtn.B_DARK
				or self.nBtnType == TypeCommonBtn.R_BLUE then
				--nWidth,nHeight = self.pCommonBtn:getLayoutSize()	
				local nScale = self.pCommonBtn:getScale()
				nWidth = nWidth*nScale
				nHeight = nHeight*nScale				
			else
				nWidth = self.pCommonBtn:getContentSize().width
				--由于阿彪特效光圈内容层的大小为 110*50 ，所以在这里大小写死
				nHeight = self.pCommonBtn:getContentSize().height
			end
			
			local fScaleX = nWidth / 110 
			local fScaleY = nHeight / 50 
			self.pArmLing:setScaleX(fScaleX)
			self.pArmLing:setScaleY(fScaleY)
			self.pArmLing:play(-1)
		end
	end
end

--移除特效
function MCommonBtn:removeLingTx(  )
	-- body
	if self.pArmLing then
		self.pArmLing:removeSelf()
		self.pArmLing = nil
	end
end



-- 析构方法
function MCommonBtn:onMCommonBtnDestroy(  )
	-- body
end

--设置按钮类型
--_nBtntype：按钮样式
--_sText：文字内容
function MCommonBtn:setButton( _nBtntype, _sText )
	-- body
	self.nBtnType = _nBtntype or TypeCommonBtn.L_BLUE
	self.sText = _sText or self.sText
	self.tBtnAttri = tBtnAttribute[self.nBtnType]
	self:updateViews()
end

--获得按钮
function MCommonBtn:getButton(  )
	-- body
	return self.pContainer
end

--设置按钮回调时候的参数
function MCommonBtn:setCallBackParam( param )
	self._tCallBackParam = param
end

--修改文字内容
--_sText：文字内容
--_bNeedTx:如果是true不用判断是否需要按钮特效
function MCommonBtn:updateBtnText( _sText, _nSize, _bNeedTx )
	-- body
	if(_sText) then
		self.sText = _sText
		local param = {}
		param.text = self.sText
		if _nSize then
			param.size = _nSize
		end
		self.pCommonBtn:setString(param)
		if _bNeedTx then
		else
			--判断是否需要按钮特效
			self:checkIfNeedTx()
		end
	end
end

--修改文字大小
--_nSize：文字大小
function MCommonBtn:updateBtnTextSize( _nSize )
	-- body
	if(_nSize) then
		local param = {}
		param.text = self.sText
		param.size = _nSize
		self.pCommonBtn:setString(param)
	end
end

--修改文字颜色
--_nSize：文字大小
function MCommonBtn:updateBtnTextColor( _sColor )
	-- body
	if(_sColor) then
		local param = {}
		param.text = self.sText
		param.color = getC3B(_sColor) 
		self.pCommonBtn:setString(param)
	end
end

--修改按钮样式
--_nBtntype：按钮样式
function MCommonBtn:updateBtnType( _nBtntype )
	-- body
	self.nBtnType = _nBtntype or self.nBtnType
	self.tBtnAttri = tBtnAttribute[self.nBtnType]

	self:updateViews()
end

--修改按下状态下按钮的样式
function MCommonBtn:updateBtnTypeForState( _nBtntype )
	-- body
	self.nBtnType = _nBtntype or self.nBtnType
	self.tBtnAttri = tBtnAttribute[self.nBtnType]
	if self.tBtnAttri then
		self.pCommonBtn:setButtonImage(self.tBtnAttri.btnBg,MBtnState.PRESSED)
	end
end

--获得按钮文字
function MCommonBtn:getBtnText(  )
	-- body
	return self.pCommonBtn:getButtonLabelString()
end

--设置按钮是否可用
function MCommonBtn:setBtnEnable( _bEnabled )
	-- body
	self.pContainer:setViewEnabled( _bEnabled )
	self.pCommonBtn:setViewEnabled( _bEnabled )
	self.pCommonBtn:setIsPressedNeedScale(_bEnabled)
	self.pCommonBtn:setIsPressedNeedColor(_bEnabled)
	self.pContainer:setIsPressedNeedScale(_bEnabled)
	self.pContainer:setIsPressedNeedColor(_bEnabled)
end

--设置点击回调事件
function MCommonBtn:onCommonBtnClicked( _handler )
	-- body
	self._nHandlerBtnClicked = _handler
end

--设置无效状态下点击回调事件
function MCommonBtn:onCommonBtnDisabledClicked( _handler )
	-- body
	self._nHandlerBtnDisabled = _handler
end

-- 设置描边
function MCommonBtn:setOutLine( _tAttr )
	-- body
    --判断描边的大小是否大于1（是否有描边）
    if _tAttr and _tAttr.fontStrokeSize and _tAttr.fontStrokeSize >= 1 then
    	self.pCommonBtn:getButtonLabel():enableOutline(getC4B(_tAttr.fontStrokeColor), _tAttr.fontStrokeSize)
    end
    --设置阴影
    -- self.pCommonBtn:getButtonLabel():enableShadow(cc.c4b(255, 0, 0, 255),cc.size(5,5))
end

-- 设置按钮上方扩展内容 
--_tabele.img 图片(图片名称) _tabele.tLabel(label 队列) 文本内容 

-- local tBtnTable = {}
-- tBtnTable.img = "ui/i85001.png"
-- --文本
-- tBtnTable.tLabel = {
-- 	{"消耗体力: ",getC3B(_cc.white)},
-- 	{"1",getC3B(_cc.white)},
-- 	{"/"},
-- 	{"10",getC3B(_cc.white)},
-- }
--_tabele.awayH 扩展内容层离存放按钮的父层 的高度 (默认self.nAwayH 的高度)
function MCommonBtn:setBtnExText(_table,_isScaleImg)
	if not self.pContainer then
       return
	end

	if not _table then
		return
	end

	_table.parent = self.pContainer
	--因为按钮存在扩展点击范围原因,需要特需处理高度 MBTNEXTEXTHEIGHT 为美术设定的高度
	if not _table.awayH then
		_table.awayH = (self:getHeight() -self.pContainer:getHeight())/2 + MBTNEXTEXTHEIGHT
	end	
	self.pBtnExText = MBtnExText.new(_table,_isScaleImg)
	return self.pBtnExText 
end

--
function MCommonBtn:setBtnVisible(_vis)
	-- body
	self.pContainer:setVisible(_vis)
	if self.pBtnExText then
		self.pBtnExText:setVisible(_vis)
	end
end


--设置文本与颜色 _index 下标 _cn 内容 _color 颜色 (只刷新已经存在文本)
function MCommonBtn:setExTextLbCnCr(_index,_cn,_color)
	if self.pBtnExText then
		self.pBtnExText:setLabelCnCr(_index,_cn,_color)
	end
end

--设置按钮上方扩展内容图片 
--_strImg 注意是否属于纹理图片(纹理图片需要添加"#")
function MCommonBtn:setExTextImg(_strImg,_isScaleImg)
	if self.pBtnExText then
		self.pBtnExText:setImg(_strImg,_isScaleImg)
	end
end

--设置按钮上方扩展内容是否显示
function MCommonBtn:setExTextVisiable(_bEnabled)
	if self.pBtnExText then
		self.pBtnExText:setBtnExTextEnabled(_bEnabled) 
	end
end

--添加红色删除线
function MCommonBtn:addRedLine( nLabelIndex )
	if self.pBtnExText then
		self.pBtnExText:addRedLine(nLabelIndex) 
	end
end

function MCommonBtn:setExTextZorder( _nZorder )
	-- body
	if not _nZorder then
		return
	end
	if self.pBtnExText then
		self.pBtnExText:setLocalZOrder(_nZorder)
	end
end

return MCommonBtn