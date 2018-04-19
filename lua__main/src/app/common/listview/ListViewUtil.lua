--获取空层时显示文字和按钮样式
-- local tLabel = {
--     str = "xxxx", --文字
--	   btnStr = "xxx", --按钮文字
--     handler = xxx, --按钮回调
-- }
function getLayNullUiTxtAndBtn( tLabel )
    local NullLayerTxtAndBtn = require("app.common.listview.NullLayerTxtAndBtn")
    local pNullUi = NullLayerTxtAndBtn.new()
    pNullUi:setStr(tLabel.str)
    pNullUi:setBtnStr(tLabel.btnStr)
    pNullUi:setBtnHandler(tLabel.handler)
    pNullUi:setIgnoreOtherHeight(true)
    return pNullUi
end

--获取空层时显示图片和文字样式
-- local tLabel = {
--     str = "xxxx",--文字
-- }
function getLayNullUiImgAndTxt( tLabel )
    local NullLayerImgAndTxt = require("app.common.listview.NullLayerImgAndTxt")
    local pNullUi = NullLayerImgAndTxt.new()
    pNullUi:setStr(tLabel.str)
    pNullUi:setIgnoreOtherHeight(true)
    return pNullUi
end

--返回带动画的精灵，用于列表的上，下箭头
function getUpAndDownArrow(_sImg )
    local sImg=_sImg or "#v1_btn_left.png"
    local pImgUpArrow = MUI.MImage.new(sImg)
    pImgUpArrow:setFlippedY(true)
    local pImgDownArrow = MUI.MImage.new(sImg)

    local pAct = cc.RepeatForever:create(cc.Sequence:create(
        cc.FadeTo:create(1,120),
        cc.FadeTo:create(1,255)))
    pImgUpArrow:runAction(pAct)

    local pAct = cc.RepeatForever:create(cc.Sequence:create(
        cc.FadeTo:create(1,120),
        cc.FadeTo:create(1,255)))
    pImgDownArrow:runAction(pAct)

    return pImgUpArrow, pImgDownArrow
end

function getLeftAndRightArrow(_sImg )
    local sImg=_sImg or "#v1_btn_jiantou.png"
    local pImgLeftArrow = MUI.MImage.new(sImg)
    
    local pImgRightArrow = MUI.MImage.new(sImg)
    pImgRightArrow:setFlippedX(true)
    local pAct = cc.RepeatForever:create(cc.Sequence:create(
        cc.FadeTo:create(1,120),
        cc.FadeTo:create(1,255)))
    pImgLeftArrow:runAction(pAct)

    local pAct = cc.RepeatForever:create(cc.Sequence:create(
        cc.FadeTo:create(1,120),
        cc.FadeTo:create(1,255)))
    pImgRightArrow:runAction(pAct)

    return pImgLeftArrow, pImgRightArrow
end