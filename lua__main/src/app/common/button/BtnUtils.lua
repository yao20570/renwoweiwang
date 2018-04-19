-----------------------------------------------------
-- author: wangxs
-- updatetime: 2017-03-31 16:10:52 星期五
-- Description: 通用按钮工具类
-----------------------------------------------------

--按钮状态
MBtnState = {
    NORMAL   = "normal",
    PRESSED  = "pressed",
    DISABLED = "disabled"
}
--特殊按钮类型
TypeSepBtn = {
    PLUS             =       1,          --加号按钮1
    MINUS            =       2,          --减号按钮1
    HELP             =       3,          --问号按钮1
    REFRESH          =       4,          --刷新按钮1 
    CROSS            =       5,          --×号按钮1  
    PLUS_VIEW        =       51,         --蓝底加号按钮2
    I_VIEW           =       52,         --蓝底i按钮
    OPERATE_VIEW     =       53,         --蓝底i按钮
}

--圆形按钮类型
TypeCirleBtn = {
    CALL             =       1,          --召唤
    PROTECT          =       2,          --保护
    ENTER            =       3,          --进入
    SHARE            =       4,          --分享
    DETECT           =       5,          --帧查
    CITYWAR          =       6,          --城战
    COUNTRYWAR       =       7,          --国战
    MOVECITY         =       8,          --迁城
    GARRRISON        =       9,          --驻防
    CHAT             =       10,         --私聊
    DETAIL           =       11,         --详情
    WOLRD            =       12,         --世界
    BOSS             =       13,         --Boss召唤
    BOSSWAR          =       14,         --Boss讨伐
    LEVY             =       15,         --征收
    ELECT            =       16,         --竞选
    FILLCDEF         =       17,         --补充城防
    RANK             =       18,         --榜单（限时BOSS）
    DISPATCH         =       19,         --派遣（限时BOSS）
    FIVEHIT          =       20,         --五连击（限时BOSS）
    ATTACK           =       21,         --攻击（限时BOSS）
    BATTLEFIELD      =       22,         --战场（决战阿房宫）
    TOGETHER         =       23,         --集结（决战阿房宫）
}

--特殊按钮容错范围方向偏移
TypeSepBtnDir = {
    top              =       1,         --上
    bottom           =       2,         --下
    left             =       3,         --左
    right            =       4,         --右
    center           =       5,         --中
}       

--通用按钮类型
TypeCommonBtn = {
    

	L_BLUE 			= 		1, 			--蓝色按钮（155x62）
	L_RED 			= 		2, 			--红色按钮（155x62）
	L_YELLOW 		= 		3, 			--黄色按钮（155x62）


	M_BLUE 			= 		11, 		--蓝色按钮（130x50）
    M_RED           =       12,         --红色按钮（130x50）
	M_YELLOW 		= 		13, 		--黄色按钮（130x50）

    S_BLUE          =       21,         --蓝色按钮 (96,45)

    O_BLUE          =       31,         --拉伸按钮 蓝色（110*50）
    O_RED           =       32,         --拉伸按钮 红色（110*50）
    O_YELLOW        =       33,         --拉伸按钮 黄色（110*50）

    R_BLUE          =       35,         --拉伸按钮 蓝色 (176*45) 

    B_DARK          =       41,         --暗色按钮 (249*64)


    XL_BLUE         =       51,         --蓝色加大按钮 (252,64)
    XL_YELLOW       =       52,         --黄色加大按钮 (252,64)

    XL_BLUE2        =       60,         --蓝色按钮（110，46）
}

local MCommonBtn = require("app.common.button.MCommonBtn")
local MSepBtn = require("app.common.button.MSepBtn")
local MSepView = require("app.common.button.MSepView")
local MOvalSw = require("app.common.button.MOvalSw")

--扩大点击范围的尺寸
local tSizeA = {width = 200, height = 100}
local tSizeB = {width = 160, height = 80}
local tSizeC = {width = 115, height = 60}
local tSizeD = {width = 270, height = 100}
local tSizeE = {width = 200, height = 60}
local tSizeSep = {width = 100, height = 100}


--获得特殊按钮
--_p_pContainer: 按钮的父节点
--_nBtntype：按钮样式（TypeSepBtn）
--_nDir：方向偏移（TypeSepBtnDir）
function getSepButtonOfContainer( _pContainer, _nBtntype, _nDir)
    -- body
    if not _pContainer then
        return
    end

    if _nDir == nil then
        if _nBtntype == TypeSepBtn.PLUS then
            _nDir = TypeSepBtnDir.right
        elseif _nBtntype == TypeSepBtn.MINUS then
            _nDir = TypeSepBtnDir.left
        else
            _nDir = TypeSepBtnDir.center
        end
    end

    --计算中心点位置
    local fCenterX = _pContainer:getPositionX() + _pContainer:getWidth() / 2
    local fCenterY = _pContainer:getPositionY() + _pContainer:getHeight() / 2

    local bRefreshPos = false 
    --判断是否需要扩大容错范围
    if _pContainer:getWidth() < tSizeSep.width and _pContainer:getHeight() < tSizeSep.height then
        bRefreshPos = true
        _pContainer:setContentSize(cc.size(tSizeSep.width,tSizeSep.height))
    end

    if bRefreshPos then 
        --重新设置位置
        _pContainer:setPosition(fCenterX - _pContainer:getWidth() / 2,
            fCenterY - _pContainer:getHeight() / 2)
    end

    local pSepBtn
    if _nBtntype >= TypeSepBtn.PLUS_VIEW then --样式2
        pSepBtn = MSepView.new(_pContainer,_nBtntype)
        _pContainer:addView(pSepBtn)

        if _nDir == TypeSepBtnDir.center then
            centerInView(_pContainer,pSepBtn)
        elseif _nDir == TypeSepBtnDir.top then
            pSepBtn:setPosition((_pContainer:getWidth() - pSepBtn:getWidth()) / 2, _pContainer:getHeight() - pSepBtn:getHeight())
        elseif _nDir == TypeSepBtnDir.bottom then
            pSepBtn:setPosition((_pContainer:getWidth() - pSepBtn:getWidth()) / 2, 0)
        elseif _nDir == TypeSepBtnDir.left then
            pSepBtn:setPosition(0, (_pContainer:getHeight() - pSepBtn:getHeight()) / 2)
        elseif _nDir == TypeSepBtnDir.right then
            pSepBtn:setPosition(_pContainer:getWidth() - pSepBtn:getWidth(), (_pContainer:getHeight() - pSepBtn:getHeight()) / 2)
        end
    else
        pSepBtn = MSepBtn.new(_pContainer,_nBtntype)
        _pContainer:addView(pSepBtn)

        if _nDir == TypeSepBtnDir.center then
            centerInView(_pContainer,pSepBtn)
        elseif _nDir == TypeSepBtnDir.top then
            pSepBtn:setPosition(_pContainer:getWidth() / 2, _pContainer:getHeight() - pSepBtn:getHeight() / 2)
        elseif _nDir == TypeSepBtnDir.bottom then
            pSepBtn:setPosition(_pContainer:getWidth() / 2, pSepBtn:getHeight() / 2)
        elseif _nDir == TypeSepBtnDir.left then
            pSepBtn:setPosition(pSepBtn:getWidth() / 2, _pContainer:getHeight() / 2)
        elseif _nDir == TypeSepBtnDir.right then
            pSepBtn:setPosition(_pContainer:getWidth() - pSepBtn:getWidth() / 2, _pContainer:getHeight() / 2)
        end
    end

    local pRedNums =_pContainer:findViewByTag(91974)--红点层
    if pRedNums then
        local nX = pSepBtn:getPositionX()
        local nY = pSepBtn:getPositionY()
        pRedNums:setPosition(nX, nY)--重置红点位置
    end


    if pSepBtn then
        --设置父层可点击
        _pContainer:setViewTouched(true)
        _pContainer:setIsPressedNeedScale( false)
        _pContainer:onMViewClicked( function (  )
            -- body
            pSepBtn:performClick(true)

        end)
    end
    return pSepBtn
end

-- 获取公用按钮
--_p_pContainer: 按钮的父节点
--_nBtntype：按钮样式（TypeCommonBtn）
--_sText：文字内容
--_bLarge：是否需要扩大点击范围
--_tExText: 按钮上方扩展内容
function getCommonButtonOfContainer(_pContainer, _nBtntype, _sText, _bLarge,_tExText)
    --默认需要扩大点击范围
    if _bLarge == nil then
        _bLarge = true
    end
    local pCommonBtn = _pContainer:findViewByTag(8376223)
    if not pCommonBtn then
        --计算中心点位置
        local fCenterX = _pContainer:getPositionX() + _pContainer:getWidth() / 2
        local fCenterY = _pContainer:getPositionY() + _pContainer:getHeight() / 2
        if _bLarge then
            local bRefreshPos = false 
            if _nBtntype == TypeCommonBtn.L_BLUE 
                or _nBtntype == TypeCommonBtn.L_RED
                or _nBtntype == TypeCommonBtn.L_YELLOW then   --如果是类型1扩大点击范围
                --判断本来父层的大小是否需要扩大
                if _pContainer:getWidth() < tSizeA.width or _pContainer:getHeight() < tSizeA.height then
                    bRefreshPos = true
                    _pContainer:setContentSize(cc.size(tSizeA.width,tSizeA.height))
                end
            elseif _nBtntype == TypeCommonBtn.M_BLUE 
                or _nBtntype == TypeCommonBtn.M_RED
                or _nBtntype == TypeCommonBtn.M_YELLOW then   --如果是类型2扩大点击范围
                --判断本来父层的大小是否需要扩大
                if _pContainer:getWidth() < tSizeB.width or _pContainer:getHeight() < tSizeB.height then
                    bRefreshPos = true
                    _pContainer:setContentSize(cc.size(tSizeB.width,tSizeB.height))
                end
            elseif  _nBtntype == TypeCommonBtn.S_BLUE 
                or _nBtntype == TypeCommonBtn.O_BLUE 
                or _nBtntype == TypeCommonBtn.O_RED
                or _nBtntype == TypeCommonBtn.O_YELLOW then --如果是类型3扩大点击范围
                --判断本来父层的大小是否需要扩大
                if _pContainer:getWidth() < tSizeC.width or _pContainer:getHeight() < tSizeC.height then
                    bRefreshPos = true
                    _pContainer:setContentSize(cc.size(tSizeC.width,tSizeC.height))
                end
            elseif _nBtntype == TypeCommonBtn.B_DARK 
                or _nBtntype == TypeCommonBtn.XL_BLUE 
                or _nBtntype == TypeCommonBtn.XL_YELLOW then
                if _pContainer:getWidth() < tSizeD.width or _pContainer:getHeight() < tSizeD.height then
                    bRefreshPos = true
                    _pContainer:setContentSize(cc.size(tSizeD.width,tSizeD.height))
                end
            elseif _nBtntype == TypeCommonBtn.R_BLUE  then
                if _pContainer:getWidth() < tSizeE.width or _pContainer:getHeight() < tSizeE.height then
                    bRefreshPos = true
                    _pContainer:setContentSize(cc.size(tSizeE.width,tSizeE.height))
                end 
            end
            if bRefreshPos then
                --重新设置位置
                _pContainer:setPosition(fCenterX - _pContainer:getWidth() / 2,
                    fCenterY - _pContainer:getHeight() / 2)
            end
        end
        pCommonBtn = MCommonBtn.new(_pContainer)
        pCommonBtn:setTag(8376223)
        pCommonBtn:setButton(_nBtntype,_sText)
        if _tExText then
            pCommonBtn:setBtnExText(_tExText)
        end


        local pRedNums =_pContainer:findViewByTag(91974)--红点层
        if pRedNums then
            local nX = pCommonBtn:getPositionX()+pCommonBtn:getWidth()
            local nY = pCommonBtn:getPositionY()+pCommonBtn:getHeight()
            pRedNums:setPosition(nX, nY)--重置红点位置
        end


        _pContainer:addView(pCommonBtn)
        centerInView(_pContainer,pCommonBtn)
        --设置父层可点击
        _pContainer:setViewTouched(true)
    end
    return pCommonBtn
end

--对MCommonBtn做缩放
-- _p_pContainer: 按钮的父节点
-- _pMCommonBtn：MCommonBtn
-- _fScale：缩放值
function setMCommonBtnScale( _pContainer, _pMCommonBtn, _fScale )
    -- body
    --按钮缩放
    _pMCommonBtn:setScale(_fScale)
    --重置位置
    _pMCommonBtn:setPosition((_pContainer:getWidth() - _pMCommonBtn:getWidth() * _fScale) / 2,
        (_pContainer:getHeight() - _pMCommonBtn:getHeight() * _fScale) / 2)

    local pRedNums =_pContainer:findViewByTag(91974)--红点层
    if pRedNums then
        local nX = _pMCommonBtn:getPositionX()+_pMCommonBtn:getWidth()* _fScale-pRedNums:getWidth()
        local nY = _pMCommonBtn:getPositionY()+_pMCommonBtn:getHeight()* _fScale-pRedNums:getHeight()
        pRedNums:setPosition(nX, nY)--重置红点位置
    end
end 


--创建椭圆形开关按钮  _pContainer 父节点 ,_handler 回调 _nState 开关状态
function getOvalSwOfContainer(_pParent,_handler,_nState)
    local pOvalSw = _pParent:findViewByTag(79464)
    if not pOvalSw then
        pOvalSw = MOvalSw.new(_nState)
        pOvalSw:setHandler(_handler)
        _pParent:addView(pOvalSw)
    end
    return pOvalSw
end


--创建圆形按钮  _pContainer 父节点 ,_handler 回调
--设置更改大小
function getCircleBtnOfContainer(_pParent, _nBtntype, fScale)
    local pBtnCircle = _pParent:findViewByTag(20170724)
    if not pBtnCircle then
        local MCircleBtn = require("app.common.button.MCircleBtn")
        pBtnCircle = MCircleBtn.new(_pParent, _nBtntype)
        _pParent:addView(pBtnCircle)
        pBtnCircle:setTag(20170724)
        pBtnCircle:setScale(fScale)
        centerInView(_pParent, pBtnCircle)
    else
        pBtnCircle:updateBtnType(_nBtntype)
    end
    return pBtnCircle
end
