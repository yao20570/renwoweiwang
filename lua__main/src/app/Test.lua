




Test = class("Test", function() return display.newLayer() end)

function Test:ctor()
    --self:runDemo()
    self:test()
    self:test2()
end

function Test:runDemo()

    self:removeAllChildren()

    --self:createUI1()
    print("\n")
    self:createUI2()
    print("\n\n\n")
end

function Test:createUI1()

    if self.pParentNode == nil then
        self.pParentNode = display.newLayer()
    end

    TestProfile:startTime()
    local n = cc.Node:create()
    self.pParentNode:addChild(n)
    for i = 1, 1000 do
        n:addChild(cc.Node:create())
    end    
    TestProfile:printTime(11)
    n:removeFromParent()
    TestProfile:printTime(1)

    n = cc.Node:create()
    self.pParentNode:addChild(n)
    for i = 1, 1000 do
        n:addChild(MUI.MLayer.new(false))
    end
    TestProfile:printTime(21)
    n:removeFromParent()
    TestProfile:printTime(2)

    n = cc.Node:create()
    self.pParentNode:addChild(n)
    for i = 1, 1000 do
        n:addChild(MUI.MFillLayer.new(false))
    end
    TestProfile:printTime(31)
    n:removeFromParent()
    TestProfile:printTime(3)
    
    n = cc.Node:create()
    self.pParentNode:addChild(n)
    for i = 1, 1000 do
        n:addChild(MUI.MImage.new( "ui/daitu.png" ))
    end
    TestProfile:printTime(41)
    n:removeFromParent()
    TestProfile:printTime(4)
        
    n = cc.Node:create()
    self.pParentNode:addChild(n)
    for i = 1, 1000 do
        --n:addChild(MUI.MImage.new( "ui/daitu.png", { scale9 = true, capInsets = { 0, 0, 0, 0 } } ))
        n:addChild(ccui.Scale9Sprite:create({ 0, 0, 0, 0 }, "ui/daitu.png"))
    end
    TestProfile:printTime(51)
    n:removeFromParent()
    TestProfile:printTime(5)
             
    n = cc.Node:create()
    self.pParentNode:addChild(n)
    for i = 1, 1000 do
        n:addChild(MUI.MLabel.new( { text = "", size = 20, color = cc.c3b(255, 255, 255) } ))
    end
    TestProfile:printTime(61)
    n:removeFromParent()
    TestProfile:printTime(6)

    TestProfile:endTime()

end


function Test:createUI2()

    TestProfile:startTime()
    for i = 1, 1000 do
        cc.Layer:create()
    end
    TestProfile:printTime(0)

    for i = 1, 1000 do
        cc.Node:create()
    end
    TestProfile:printTime(1)

--    for i = 1, 1000 do
--        display.newSprite("ui/daitu.png")
--    end
--    TestProfile:printTime(2)

--    for i = 1, 1000 do
--        display.newScale9Sprite("ui/daitu.png", 0, 0, cc.size(400, 300), { 1, 1, 1, 1 })
--    end
--    TestProfile:printTime(3)

--    for i = 1, 1000 do
--        display.newLayer()
--    end
--    TestProfile:printTime(4)

    for i = 1, 1000 do
        --MUI.MLayer.new(false)
        display.newLayer()
    end
    TestProfile:printTime(4)

--    for i = 1, 1000 do
--        MUI.MFillLayer.new(true)
--    end
--    TestProfile:printTime(5)
    
--    for i = 1, 1000 do  
--        local x = { scale9 = true, capInsets = { 0, 0, 0, 0 } }
--        MUI.MImage.new( "ui/daitu.png" )
--    end
--    TestProfile:printTime(6)

--    for i = 1, 1000 do
--        MUI.MImage.new( "ui/daitu.png", { scale9 = true, capInsets = { 0, 0, 0, 0 } } )
--    end
--    TestProfile:printTime(7)

--    for i = 1, 1000 do
--        MUI.MLabel.new( { text = "", size = 20, color = cc.c3b(255, 255, 255) } )
--    end
--    TestProfile:printTime(8)

    TestProfile:endTime()

end

function Test:test()
    local o = {}  
    o.val = 1  
      
    local t1 = os.clock()  
    for i = 1, 10000000, 1 do   
        o.val = o.val + 1  
    end  
    local t2 = os.clock()  
      
    print(t2 - t1)
end

function Test:test2()
    local o = cc.Node:create()  
    o.val = 1  
      
    local t1 = os.clock()  
    for i = 1, 10000000, 1 do   
        o.val = o.val + 1  
    end  
    local t2 = os.clock()  
      
    print(t2 - t1) 
end