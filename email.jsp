<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%
/***********************************************************************************
* ○ 파일 : email.jsp
* ● 설명 : 시스템관리 > 이메일 대용량 첨부 관리
***********************************************************************************/
%>
<!DOCTYPE html>
<html>
<head>
<jsp:directive.include file="../../common/page_head.jsp" />
</head>
<body>
	<jsp:directive.include file="../../common/page_script.jsp" />
	<script>
    
  //**********************************************************************************
	// popupUrl 선언
  //**********************************************************************************
    
  
$(document).ready(function() {
    emailToolbar.click(TOOLBAR_REFRESH); // 페이지 로드 시 대용량 이메일 첨부 목록 조회
});

  
 // ********************************************************************************************
 // 레이아웃
 // ******************************************************************************************** 
    let layout = initLayout({
        cols: [
            {
                id: 'layout',
                resize: true,
                rows: [
                    { // 대용량 이메일 첨부 목록 영역
                        id: 'email',
                        resize: true,
                        rows: [
                            { // 대용량 이메일 첨부 목록 툴바
                                id: 'emailToolbar',
                                height: 'content'
                            },
                            { // 대용량 이메일 첨부 목록 그리드
                                id: 'emailGrid',
                                css: 'emailGrid'
                            }
                        ]
                    }
                ]
            }
        ]
    });

	// ********************************************************************************************
	// 대용량 첨부 정보 목록 툴바 
	// ********************************************************************************************

	
    let emailToolbar = setWidgetConfig({
        id: 'emailToolbar',
        parent: layout.emailToolbar,
        items: [
            {id: TOOLBAR_TITLE, text: '대용량 첨부 정보'}, // 대용량 첨부 파일 목록
            {id: 'guideText', type: 'html', html: '<span id="emailGuideText" style="color:red; font-size:12px;"></span>'},// 다운로드 가능 기간 및 횟수 안내문구
            {type: 'space'},
            {id: TOOLBAR_CREATE}, // 팝업창
            {id: TOOLBAR_DELETE}, //행삭제
            {id: TOOLBAR_SAVE}, // 삭제 저장
            {id: TOOLBAR_REFRESH}, //새로고침
            {id: TOOLBAR_EXCEL}, // 화면 다운로드
            {id: TOOLBAR_FILTER} //필터
        ]
    });

    emailToolbar[TOOLBAR_CREATE].onClick = function() { // 팝업창
        openEmailPopup(); // 팝업창 불러오기
    };
	

    let deleteTargetEmailFileSeq = ''; //변수 선언
    
    emailToolbar[TOOLBAR_DELETE].onClick = function() { // 삭제
        let rowId = emailGrid.getSelectedRowId(); // 이메일 그리드에서 선택한 행의 rowId에 담아준다
        let row = emailGrid.getRowData(rowId); // 선택한 행의 데이터를 row에 담아준다

        if (isNull(row) || isEmpty(row.emailFileSeq)) { // 로우 아이디와 로우 데이터 가 담긴 값과 로우의 이메일 파일 시퀀스 값도 없을 경우, 
            alert(multiLangText(MLANG.msg_mNoDataDelete)); // 삭제할 코드가 없습니다 
            return;
        }

        deleteTargetEmailFileSeq = row.emailFileSeq; // 로우의 이메일파일 시퀀스 가 담긴 값을  deleteTargetEmailFileSeq 담아준다 
        emailGrid.deleteRow(rowId);  // 해당 선택한 로우 삭제 
    };
    
    emailToolbar[TOOLBAR_SAVE].onClick = function() { // 저장
        if (isEmpty(deleteTargetEmailFileSeq)) { // 위에서 설정한 로우의 이메일파일 시퀀스 가 담긴 값이 비었다면 
            alert(multiLangText(MLANG.msg_mNoDataDelete)); // 삭제할 코드가 없습니다
            return;
        }

        confirm({ 
            text: mlang('msg_qDelete'), // 텍스트 삭제하시겠습니까 ? 
            ok: function() { // 코드가 맞다면 
            	 alert(multiLangText(MLANG.msg_mDelete)); // 삭제되었습니다.
                deleteEmail(deleteTargetEmailFileSeq); // 로우의 이메일파일 시퀀스 를 담긴 값을 삭제를 실행한다 
            }
        });
    };
    
    
    emailToolbar[TOOLBAR_REFRESH].onClick = function() { //새로고침
        loadEmailGridData(); // 이메일 대용랑 첨부관리 목록 그리드 데이터를 조회한다 
    };

    emailToolbar[TOOLBAR_EXCEL].onClick = function() { //엑셀 다운로드
          emailGrid.toExcel(); // 그리드 데이터를 다운로드 한다 
	};


    emailToolbar = initToolbar(emailToolbar); // 이메일 툴바를 초기화 한다 

	// ********************************************************************************************
	// 이메일 대용랑 첨부관리 목록 그리드 
	// ********************************************************************************************    
    let emailGrid = setWidgetConfig({
        parent: layout.emailGrid,
        items: [
            {id: 'no', text: mlang('col_no'), width: 50} //번호
            ,{id: 'fileNm', text: mlang('col_fileNm') + '(PDF)', width: 300, type: 'file', fileGrpId: 'fileGrpId', fileId: 'fileId', fileExt: 'fileExt', fileSizeShow: 'fileSizeShow', 허용된확장자: 'pdf', readonly: true, btnShow: false} // 파일명
            ,{id: 'filecopy', text: '대용량 링크', width: 100} //대용량 링크  
            ,{id: 'status', text: mlang('col_status'), width: 100} // 상태
            ,{id: 'regUserNm', text: mlang('col_regUser'), width: 100} // 등록자
            ,{id: 'regDt', text: mlang('col_regDt'), width: 160} // 등록 일자
            ,{id: 'delDt', text: '삭제 일자', width: 160} // 삭제 일자 
            ,{id: 'maxDownCnt', text: '다운로드 횟수', width: 120, align: 'center'} // 다운로드 횟수
            ,{id: 'rmk', text: mlang('col_remark'), width: 180, align: 'left'} //비고
					
         // 파일 (SYS_FILE)
            ,{id: 'emailFileSeq', hidden: true} // 삭제,다운로드 체크에 필요
            ,{id: 'fileGrpSeq', hidden: true} // 파일그룹 식별용
            ,{id: 'fileGrpId', hidden: true} // 대용량 링크 생성에 필요
            ,{id: 'fileId', hidden: true} //  type: 'file' 컬럼 다운로드 링크에 필요할 수 있음
            ,{id: 'fileExt', hidden: true} // 파일 컬럼 표시용
            ,{id: 'fileSize', hidden: true} // 파일 위젯 내부에서 쓸 수 있음
            ,{id: 'fileSizeShow', hidden: true} // 파일 위젯 내부 표시용
        ],
        toolbar: emailToolbar
    });
    
    emailGrid['filecopy'].onSetValue = function(value, rowId, colId) { // 대용량 링크 컬럼에 링크복사 버튼 표시
        let rowData = emailGrid.getRowData(rowId); // 로우아이디에 해당하는 행 데이터를 조회해서 rowData 에 담는다 

        if (isEmpty(rowData.fileNm) == false) { // 로우 행 데이터중 fileNm 이 값이 비어있지 않다면 
            return `<div class="grid_btn_i_center"><button style="font-size:11px;">링크복사</button></div>`;  // 링크복사 버튼 HTML을 반환
        } else {
            return '';
        }
    }
    
    emailGrid.onClick = function(rowId, colId) { // 대용량 링크 컬럼 클릭 시 다운로드 URL 복사
        if (colId == 'filecopy') {
            let row = emailGrid.getRowData(rowId); // 선택한 행의  데이터를 로우 아이디 값을 로우에 담는다 
            let textToCopy = buildEmailFilePopupUrl(row); // 선택한 행 데이터를 이용해 이메일 파일 팝업 URL을 생성하여 textToCopy에 담는다

            copyToClipboard(textToCopy); // textToCopy에 들어있는 문자열을 클립보드에 복사하는 함수 실행

            return false;
        }

        return true;
    };

    
    emailGrid = initGrid(emailGrid); // 이메일 그리드를 초기화 한다 

    function setGuideText(emailDwDay, emailDwCnt) { // 대용량 첨부파일 다운로드 기간 및 횟수 안내문구 설정

        let guideEl = document.getElementById('emailGuideText'); //

       if (guideEl) {
            guideEl.innerHTML =
                '* 대용량 파일은 등록일자 기준으로 <b style="color:blue;">'
                + emailDwDay
                + '일</b> 지나면 삭제되며, 파일당 다운로드 횟수는 <b style="color:blue;">'
                + emailDwCnt
                + '회</b> 입니다.';
        } else {
            alert('emailGuideText 없음');
        }
    } 

    
 // 대용량 이메일 첨부 목록 조회
    function loadEmailGridData() {
        emailGrid.search({
            url: '/sys/email/loadEmailGridData',
            param: {
                projSeq: PROJ_SEQ
            },
            success: function(data) {
                if (data[GC.RESULT_CODE] === GC.RESULT_OK) {
                    emailGrid.parse(data.list);

                    if (!isEmpty(data.emailDwDay) && !isEmpty(data.emailDwCnt)) {
                        setGuideText(data.emailDwDay, data.emailDwCnt);
                    }

                    if (data.list != null && data.list.length > 0) {
                        emailGrid.selectRow(0);
                    }
                } else {
                    alert(data[GC.RESULT_MESSAGE]);
                }
            }
        });
    }


    function openEmailPopup(rowId) { // // 신규 등록 및 수정용 이메일 첨부 팝업 호출
        let param = {
                title: '이메일 첨부파일',
                projSeq: PROJ_SEQ,
                width: 850,
                height: 240
            };

            if (isEmpty(rowId) == false) {
                let row = emailGrid.getRow(rowId);
                param.crudType = GC.CRUD_UPDATE;
                param.emailFileSeq = row.emailFileSeq;
            } else {
                param.crudType = GC.CRUD_INSERT;
            }

            openPopup({
                url: '/sys/email/emailPopup',
                param: param
            });
        }

    function deleteEmail(emailFileSeq) { // 선택한 이메일 첨부 데이터를 삭제 후 목록 재조회
        $.ajax({
            type: 'POST',
            url: '/sys/email/deleteEmail',
            data: {
            	 emailFileSeq: emailFileSeq
            },
            success: function(data) {
                if (data[GC.RESULT_CODE] === GC.RESULT_OK) {
                	deleteTargetEmailFileSeq = '';
                    loadEmailGridData();
                } else {
                    alert(data[GC.RESULT_MESSAGE]);
                }
            },
            error: function(xhr, status, error) {         	
            	 alert(multiLangText(MLANG.msg_systemError)); // 시스템 오류가 발생했습니다.*/
            }
        });
    }
    
    function refreshGrid() { // 대용량 이메일 첨부 목록 재조회
        loadEmailGridData();
    }
    
    
    function buildEmailFilePopupUrl(row) {
        // URL + "/common/emailFileListPopup?idx=" + fileGrpId + "-" + emailFileSeq
        // SYSTEM_DIV :: 개발 - dev, 품질 - qt, 운영 - oper

        let popupUrl = '';

        // 01) url 구성
        popupUrl = FILE_SERVER_URL;

        // 02) 경로 지정
        popupUrl = popupUrl + '/common/emailFileListPopup?idx=';

        // 03) fileGrpId
        let fileGrpId = row.fileGrpId;

        // 04) 구분자 + emailFileSeq
        popupUrl = popupUrl + fileGrpId + '-';

        // 05) emailFileSeq
        let emailFileSeq = row.emailFileSeq;

        // url 완성
        popupUrl = popupUrl + emailFileSeq;

        return popupUrl;
    }
    
    function copyToClipboard(textToCopy) {
        // 01) 표준 방식 복사 시도 (https 환경 등 강력한 보안이라 안될 수 있음)
         if (navigator.clipboard && navigator.clipboard.writeText) {
             navigator.clipboard.writeText(textToCopy).then(() => {
            	 alert(multiLangText(MLANG.msg_mCopy)); // 복사 되었습니다.
             }).catch(err => {
                 // 실패 시 우회 방식 실행 (요소를 임시로 만들어 복사 후 삭제하는 방식)
                 fallbackCopyToClipboard(textToCopy);
             });
         } else {
             // 2. 표준 API가 없으면 우회 방식 실행 (HTTP 환경 등)
            fallbackCopyToClipboard(textToCopy);
         }
     }

     function fallbackCopyToClipboard(textToCopy) {
         // 1. 화면에 보이지 않는 임시 텍스트 상자 생성
         var textArea = document.createElement("textarea");
         textArea.value = textToCopy;

         // 2. 브라우저 구석에 살짝 숨기기
         textArea.style.position = "fixed";
         textArea.style.left = "-9999px";
         textArea.style.top = "0";
         document.body.appendChild(textArea);

         // 3. 텍스트 선택 및 복사 실행
         textArea.select();

         try {
             var successful = false;
             if (successful) {
            	 alert(multiLangText(MLANG.msg_mCopy)); 
             }
         } catch (err) {
        	 alert(multiLangText(MLANG.mSaceingFailed));
         }

         // 4. 할 일 다했으니 삭제
         document.body.removeChild(textArea);
     } 
     
    </script>
</body>
</html>
