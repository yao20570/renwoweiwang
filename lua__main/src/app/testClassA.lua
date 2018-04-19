--region NewFile_1.lua
--Author : User
--Date   : 2017/11/18
--此文件由[BabeLua]插件自动生成

TestA = class("TestA",function() return cc.Node:create() end)

function TestA:ctor()
    self:isVisible()
end


TestB = class("TestB", TestA)

function TestB:ctor()
    self:setVisible(false)
end

function TestB:setVisible(isVisible)
    TestB.super.setVisible(self, isVisible)

    print(self:isVisible())
    print("ssss")
end

--endregion
