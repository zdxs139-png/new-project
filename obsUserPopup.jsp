<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%
/***********************************************************************************
* ○ 파일    : obsUserPopup.jsp
* ● 설명    : 사용자 팝업
***********************************************************************************/
%>
<!DOCTYPE html>
<html>
    <head>
        <jsp:directive.include file="page_head.jsp"/>
        <style>
        body { margin: 0; }
        .popup_header { background: #5189ae; padding: 10px 25px; }
        .popup_ul { list-style: none; display: flex; justify-content: space-between; align-items: center; margin: 0; padding: 0; gap: 16px; }
        .popup_title { color: #ffffff; font-weight: bold; font-size: 20px; line-height: 50px; }
        .dhx_button--view_flat.dhx_button--color_primary { background-color: #dddddd; outline-width: 0; color: #2f3031; border: 1px solid #616161; border-radius: 5px; }
        .dhx_button--view_flat.dhx_button--color_primary:hover { background-color: #f3f3f3; outline-width: 0; color: #2f3031; border: 1px solid #616161; border-radius: 5px; }
        .dhx_button--view_flat.dhx_button--color_primary:active,
        .dhx_button--view_flat.dhx_button--color_primary:focus { background-color: #dddddd; outline-width: 0; color: #2f3031; border: 1px solid #616161; border-radius: 5px; }

        .popup_tab_wrap { padding: 16px 24px 0; border-bottom: 1px solid #d8d8d8; background: #ffffff; }
        .popup_tabs { display: flex; gap: 8px; }
        .popup_tab_button {
            min-width: 160px;
            padding: 10px 16px;
            border: 1px solid #b9c8d3;
            border-bottom: 0;
            border-radius: 6px 6px 0 0;
            background: #eef4f8;
            color: #2f3031;
            font-weight: bold;
            cursor: pointer;
        }
        .popup_tab_button.active {
            background: #5189ae;
            border-color: #5189ae;
            color: #ffffff;
        }

        .popup_content { width: 100%; text-align: center; padding: 24px; box-sizing: border-box; }
        .tab_panel { display: none; }
        .tab_panel.active { display: block; }
        .guide_image { width: 100%; max-width: 1000px; height: auto; display: block; margin: 0 auto; }
        </style>
    </head>
    <body>
        <jsp:directive.include file="page_script.jsp" />
        <script>
            const DEFAULT_GUIDE_IMAGE = "../../acms/image/login/https_setup.jpg";

            const guideTabs = [
                {
                    id: "outlook_classic",
                    imageSrc: POPUP_PARAM.outlookClassicImage || "../../acms/image/login/https_setup_outlook_classic.jpg"
                },
                {
                    id: "outlook_2016",
                    imageSrc: POPUP_PARAM.outlook2016Image || "../../acms/image/login/https_setup_outlook_2016.jpg"
                }
            ];

            function rootCa파일_다운로드() {
                downloadByFileId(`${POPUP_PARAM.rootCa파일_FileId}`);
            }

            function setActiveTab(tabId) {
                $(".popup_tab_button").removeClass("active");
                $(".tab_panel").removeClass("active");

                $('.popup_tab_button[data-tab="' + tabId + '"]').addClass("active");
                $("#" + tabId).addClass("active");
            }

            function bindGuideTabs() {
                $(".popup_tab_button").on("click", function() {
                    setActiveTab($(this).data("tab"));
                });
            }

            function applyGuideImages() {
                guideTabs.forEach(function(tab) {
                    $("#" + tab.id).find("img").attr("src", tab.imageSrc);
                });
            }

            function fallbackGuideImage(img) {
                if (img.dataset.fallbackApplied === "Y") {
                    return;
                }

                img.dataset.fallbackApplied = "Y";
                img.src = DEFAULT_GUIDE_IMAGE;
            }

            $(document).ready(function() {
                let toolbarTitle = POPUP_PARAM.toolbarTitle;
                $(".popup_title").html(toolbarTitle);

                applyGuideImages();
                bindGuideTabs();
                setActiveTab("outlook_classic");
            });
        </script>
        <div class="popup_header">
            <nav>
                <ul class="popup_ul">
                    <li>
                        <span class="popup_title"></span>
                    </li>
                    <li>
                        <a href="javascript: rootCa파일_다운로드()" class="dhx_button dhx_button--color_primary dhx_button--size_medium dhx_button--view_flat">
                            root_ca.crt 다운로드
                        </a>
                    </li>
                </ul>
            </nav>
        </div>

        <div class="popup_tab_wrap">
            <div class="popup_tabs">
                <button type="button" class="popup_tab_button active" data-tab="outlook_classic">outlook_classic</button>
                <button type="button" class="popup_tab_button" data-tab="outlook_2016">outlook_2016</button>
            </div>
        </div>

        <div class="popup_content">
            <div id="outlook_classic" class="tab_panel active">
                <img
                    src="../../acms/image/login/https_setup_outlook_classic.jpg"
                    class="guide_image"
                    alt="outlook_classic"
                    onerror="fallbackGuideImage(this);"
                >
            </div>
            <div id="outlook_2016" class="tab_panel">
                <img
                    src="../../acms/image/login/https_setup_outlook_2016.jpg"
                    class="guide_image"
                    alt="outlook_2016"
                    onerror="fallbackGuideImage(this);"
                >
            </div>
        </div>
    </body>
</html>
