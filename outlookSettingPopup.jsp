<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%
/***********************************************************************************
* ○ 파일    : outlookSettingPopup.jsp
* ● 설명    : Outlook 설정 안내 팝업
***********************************************************************************/
%>
<!DOCTYPE html>
<html>
    <head>
        <jsp:directive.include file="page_head.jsp"/>
        <style>
        body { margin: 0; }
        .popup_header { background: #5189ae; padding: 10px 25px; }
        .popup_ul { list-style: none; display: flex; justify-content: space-between; margin: 0; padding: 0; }
        .popup_title { color: #ffffff; font-weight: bold; font-size: 20px; line-height: 50px; }
        .dhx_button--view_flat.dhx_button--color_primary { background-color: #dddddd; outline-width: 0; color: #2f3031; border: 1px solid #616161; border-radius: 5px; }
        .dhx_button--view_flat.dhx_button--color_primary:hover { background-color: #f3f3f3; outline-width: 0; color: #2f3031; border: 1px solid #616161; border-radius: 5px; }
        .dhx_button--view_flat.dhx_button--color_primary:active,
        .dhx_button--view_flat.dhx_button--color_primary:focus { background-color: #dddddd; outline-width: 0; color: #2f3031; border: 1px solid #616161; border-radius: 5px; }
        .manual_wrap { width: 100%; text-align: center; padding: 24px 0; overflow: auto; box-sizing: border-box; }
        .manual_box { width: 80%; margin: 0 auto; text-align: center; }
        .manual_box img { width: 900px; max-width: 100%; height: auto; display: inline-block; }
        </style>
    </head>
    <body>
        <jsp:directive.include file="page_script.jsp" />
        <script>


        // *************************************************************************************************
        // 변수 선언
        // *************************************************************************************************
        const defaultManualImage = "../../acms/image/login/outlook_manual.jpg";
        const outlookClassicImage = POPUP_PARAM.outlookClassicImage || "../../acms/image/login/outlook_manual_classic.jpg";
        const outlook2016Image = POPUP_PARAM.outlook2016Image || "../../acms/image/login/outlook_manual_2016.jpg";

        function manualImageError(img) {
            if (img.dataset.fallbackApplied === "Y") {
                return;
            }

            img.dataset.fallbackApplied = "Y";
            img.src = defaultManualImage;
        }

        $(document).ready(function() {
            let toolbarTitle = POPUP_PARAM.toolbarTitle;
            $(".popup_title").html(toolbarTitle);
        });

        // ********************************************************************************************
        // 레이아웃
        // ********************************************************************************************
        let layout = initLayout({
            rows: [
                {
                    id: "layout",
                    rows: [
                        {
                            id: "tabbar",
                            height: "content"
                        },
                        {
                            cols: [
                                {
                                    id: "outlook_classic",
                                    html: `
                                        <div class="manual_wrap">
                                            <div class="manual_box">
                                                <img src="${outlookClassicImage}" alt="Outlook Classic Manual" onerror="manualImageError(this);">
                                            </div>
                                        </div>
                                    `
                                },
                                {
                                    id: "outlook_2016",
                                    html: `
                                        <div class="manual_wrap">
                                            <div class="manual_box">
                                                <img src="${outlook2016Image}" alt="Outlook 2016 Manual" onerror="manualImageError(this);">
                                            </div>
                                        </div>
                                    `
                                }
                            ]
                        }
                    ]
                }
            ]
        });

        //**********************************************************************************
        // 탭 세팅
        //**********************************************************************************
        let tabbar = setWidgetConfig({
            parent: layout.tabbar,
            items: [
                {id: "outlook_classic", text: "Outlook (Classic)", target: layout.outlook_classic, active: true},
                {id: "outlook_2016", text: "Outlook (2016)", target: layout.outlook_2016}
            ]
        });

        tabbar = initTabbar(tabbar);
        </script>
        <div class="popup_header">
            <nav>
                <ul class="popup_ul">
                    <li class="">
                        <span class="popup_title"></span>
                    </li>
                </ul>
            </nav>
        </div>
    </body>
</html>
