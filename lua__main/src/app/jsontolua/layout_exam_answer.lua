local tTable = {}


tTable["index_1"] = {
layout_root={classname="Panel",name="layout_root@fill_layout",parName="root",childCount="2",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="500",width="170",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="63",anchorPointX="0",anchorPointY="0",},
}
tTable["index_2"] = {
lay_main={classname="Panel",name="lay_main@fill_layout",parName="layout_root",childCount="3",ZOrder="1",useMergedTexture="false",clipAble="false",backGroundScale9Enable="true",backGroundImage="#v1_img_kelashen9.png",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="15",capInsetsY="15",height="505",width="170",x="0",y="50",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="72",anchorPointX="0",anchorPointY="0",},
lay_result={classname="Panel",name="lay_result",parName="layout_root",childCount="1",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="50",width="170",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="77",anchorPointX="0",anchorPointY="0",},
}
tTable["index_3"] = {
lay_answer={classname="Panel",name="lay_answer",parName="lay_main",childCount="2",ZOrder="1",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="60",width="170",x="0",y="448",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="71",anchorPointX="0",anchorPointY="0",},
lay_list={classname="Panel",name="lay_list@fill_layout",parName="lay_main",childCount="1",ZOrder="1",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="440",width="170",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="169",anchorPointX="0",anchorPointY="0",},
lay_select={classname="Panel",name="lay_select@fill_layout_height",parName="lay_main",ZOrder="5",useMergedTexture="false",clipAble="false",backGroundScale9Enable="true",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="67",capInsetsY="67",height="505",width="170",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="610",anchorPointX="0",anchorPointY="0",},
img_result={classname="ImageView",name="img_result",parName="lay_result",ZOrder="0",fileName="ui/daitu.png",scale9Enable="false",scale9Height="10",scale9Width="10",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="0",capInsetsY="0",height="10",width="10",x="85",y="25",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="78",anchorPointX="0.5",anchorPointY="0.5",},
}
tTable["index_4"] = {
img_answer_bg={classname="ImageView",name="img_answer_bg",parName="lay_answer",ZOrder="0",fileName="#v1_btn_selected_biaoqian2.png",scale9Enable="true",scale9Height="60",scale9Width="172",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="40",capInsetsY="0",height="60",width="172",x="85",y="34",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="681",anchorPointX="0.5",anchorPointY="0.5",},
lab_answer={classname="Label",name="lab_answer",parName="lay_answer",ZOrder="1",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="85",y="30",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="165",anchorPointX="0.5",anchorPointY="0.5",},
lay_tip_content={classname="Panel",name="lay_tip_content@fill_layout_height",parName="lay_list",childCount="3",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="440",width="170",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="507",anchorPointX="0",anchorPointY="0",},
}
tTable["index_5"] = {
lay_tip_space1={classname="Panel",name="lay_tip_space1@fill_layout",parName="lay_tip_content",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="180",width="170",x="0",y="220",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="508",anchorPointX="0",anchorPointY="0",},
lay_tip={classname="Panel",name="lay_tip",parName="lay_tip_content",childCount="2",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="40",width="170",x="-1",y="190",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="557",anchorPointX="0",anchorPointY="0",},
lay_tip_space2={classname="Panel",name="lay_tip_space2@fill_layout",parName="lay_tip_content",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="190",width="170",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="509",anchorPointX="0",anchorPointY="0",},
}
tTable["index_6"] = {
lab_tip={classname="Label",name="lab_tip",parName="lay_tip",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="尚",fontName="微软雅黑",fontSize="22",height="30",width="22",x="85",y="20",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="76",anchorPointX="0.5",anchorPointY="0.5",},
lab_select_tip={classname="Label",name="lab_select_tip",parName="lay_tip",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="18",height="24",width="87",x="85",y="20",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="168",anchorPointX="0.5",anchorPointY="0.5",},
}

return tTable