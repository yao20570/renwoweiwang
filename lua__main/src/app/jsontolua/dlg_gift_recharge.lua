local tTable = {}

tTable["texturesPng"] = {"ui/p1_commmon1_sep.plist","ui/p1_commonse1.plist","ui/p1_commmon3_sep.plist"}
tTable["index_1"] = {
dlg_gift_recharge={classname="Panel",name="dlg_gift_recharge",parName="root",childCount="1",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="1066",width="517",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="440",anchorPointX="0",anchorPointY="0",},
}
tTable["index_2"] = {
lay_main={classname="Panel",name="lay_main",parName="dlg_gift_recharge",childCount="2",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="1066",width="517",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="441",anchorPointX="0",anchorPointY="0",},
}
tTable["index_3"] = {
ly_title={classname="Panel",name="ly_title",parName="lay_main",childCount="2",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="true",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="186",capInsetsY="24",height="200",width="517",x="0",y="866",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="442",anchorPointX="0",anchorPointY="0",},
ly_show={classname="Panel",name="ly_show",parName="lay_main",childCount="3",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="true",backGroundImage="#v1_bg_kelashen.png",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="22",capInsetsY="22",height="800",width="502",x="8",y="46",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="446",anchorPointX="0",anchorPointY="0",},
}
tTable["index_4"] = {
img_jianbian={classname="ImageView",name="img_jianbian",parName="ly_title",ZOrder="20",fileName="#v1_img_blackjianbian.png",scale9Enable="true",scale9Height="70",scale9Width="486",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="133",capInsetsY="31",height="70",width="486",x="248",y="40",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="451",anchorPointX="0.5",anchorPointY="0.5",},
lay_banner_bg={classname="Panel",name="lay_banner_bg",parName="ly_title",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="200",width="517",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="457",anchorPointX="0",anchorPointY="0",},
lay_btn={classname="Panel",name="lay_btn",parName="ly_show",ZOrder="1",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="64",width="252",x="122",y="340",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="447",anchorPointX="0",anchorPointY="0",},
lay_textfield={classname="Panel",name="lay_textfield",parName="ly_show",childCount="1",ZOrder="1",useMergedTexture="false",clipAble="false",backGroundScale9Enable="true",backGroundImage="#v1_img_shurukuang.png",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="20",capInsetsY="20",height="60",width="400",x="54",y="439",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="449",anchorPointX="0",anchorPointY="0",},
lb_dec={classname="Label",name="lb_dec",parName="ly_show",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="不区分大小写，每个礼包兑换码只可使用一次",fontName="微软雅黑",fontSize="20",height="27",width="400",x="56",y="716",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="450",anchorPointX="0",anchorPointY="1",},
}
tTable["index_5"] = {
lb_TextField={classname="TextField",name="lb_TextField",parName="lay_textfield",ZOrder="2",colorB="255",colorG="255",colorR="255",areaHeight="60",areaWidth="400",text="Text Field",fontName="微软雅黑",fontSize="20",maxLength="10",maxLengthEnable="false",passwordStyleText="*",passwordEnable="false",height="60",width="400",x="201",y="30",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="448",anchorPointX="0.5",anchorPointY="0.5",},
}

return tTable