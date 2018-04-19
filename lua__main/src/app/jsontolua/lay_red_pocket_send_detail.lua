local tTable = {}

tTable["texturesPng"] = {"ui/bg_base/v2_img_honbaoab.png","ui/p1_commonse1.plist","ui/bar/v1_bar_b1.png","ui/p1_button1.plist"}
tTable["index_1"] = {
lay_default={classname="Panel",name="lay_default",parName="root",childCount="14",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",backGroundImage="ui/bg_base/v2_img_honbaoab.png",height="596",width="480",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="7",anchorPointX="0",anchorPointY="0",},
}
tTable["index_2"] = {
lay_btn_close={classname="Panel",name="lay_btn_close",parName="lay_default",childCount="1",ZOrder="1",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="70",width="64",x="416",y="526",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="206",anchorPointX="0",anchorPointY="0",},
lay_icon_1={classname="Panel",name="lay_icon_1",parName="lay_default",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="108",width="108",x="75",y="468",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="37",anchorPointX="0",anchorPointY="0",},
lay_icon_2={classname="Panel",name="lay_icon_2",parName="lay_default",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="108",width="108",x="297",y="468",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="60",anchorPointX="0",anchorPointY="0",},
lb_par_1={classname="Label",name="lb_par_1",parName="lay_default",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="18",height="24",width="87",x="129",y="458",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="38",anchorPointX="0.5",anchorPointY="1",},
lb_par_2={classname="Label",name="lb_par_2",parName="lay_default",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="60",areaWidth="360",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="18",height="60",width="360",x="240",y="396",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="39",anchorPointX="0.5",anchorPointY="1",},
lb_par_3={classname="Label",name="lb_par_3",parName="lay_default",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="18",height="24",width="87",x="351",y="458",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="61",anchorPointX="0.5",anchorPointY="1",},
lb_par_4={classname="Label",name="lb_par_4",parName="lay_default",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="18",height="24",width="87",x="115",y="250",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="124",anchorPointX="0.5",anchorPointY="0.5",},
lb_par_5={classname="Label",name="lb_par_5",parName="lay_default",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="18",height="24",width="87",x="365",y="250",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="125",anchorPointX="0.5",anchorPointY="0.5",},
lay_bar={classname="Panel",name="lay_bar",parName="lay_default",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="true",backGroundImage="ui/bar/v1_bar_b1.png",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="45",capInsetsY="9",height="18",width="254",x="113",y="280",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="41",anchorPointX="0",anchorPointY="0",},
img_btn_reduce={classname="ImageView",name="img_btn_reduce",parName="lay_default",ZOrder="0",fileName="#v1_btn_reduce.png",scale9Enable="false",scale9Height="34",scale9Width="34",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="0",capInsetsY="0",height="34",width="34",x="80",y="289",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="42",anchorPointX="0.5",anchorPointY="0.5",},
img_btn_increase={classname="ImageView",name="img_btn_increase",parName="lay_default",ZOrder="0",fileName="#v1_btn_increase.png",scale9Enable="false",scale9Height="34",scale9Width="34",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="0",capInsetsY="0",height="34",width="34",x="400",y="289",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="43",anchorPointX="0.5",anchorPointY="0.5",},
lay_btn_left={classname="Panel",name="lay_btn_left",parName="lay_default",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="62",width="150",x="40",y="143",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="44",anchorPointX="0",anchorPointY="0",},
lay_btn_right={classname="Panel",name="lay_btn_right",parName="lay_default",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="62",width="150",x="290",y="146",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="45",anchorPointX="0",anchorPointY="0",},
Image_25={classname="ImageView",name="Image_25",parName="lay_default",ZOrder="0",fileName="#v1_img_lanjiantou.png",scale9Enable="false",scale9Height="41",scale9Width="65",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="0",capInsetsY="0",height="41",width="65",x="240",y="523",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="126",anchorPointX="0.5",anchorPointY="0.5",},
}
tTable["index_3"] = {
img_btn_close={classname="ImageView",name="img_btn_close",parName="lay_btn_close",ZOrder="0",fileName="#v1_btn_close.png",scale9Enable="false",scale9Height="32",scale9Width="31",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="0",capInsetsY="0",height="32",width="31",x="54",y="60",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="8",anchorPointX="1",anchorPointY="1",},
}

return tTable