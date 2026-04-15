package acms.pcm.frm;

import acms.common.CommonService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;

@Controller
public class FrmController {
	@Autowired private CommonService commonService;
	@Autowired private FrmService frmService;


	// ***************************************************************************
	// 계약관리 페이지
	// ***************************************************************************
	@RequestMapping("/pcm/frm/frm")
	public String 현장자재요청서_페이지(HttpServletRequest request, Model model) throws Exception {
		return commonService.goToPage(request, model, "/pcm/frm/frm");
	}

	// *************************************************************************************************
	// API
	// *************************************************************************************************
	@RequestMapping("/pcm/frm/query")
	public  @ResponseBody HashMap<String, Object> 현장자재요청서쿼리(@RequestParam HashMap<String, Object> mapParam, HttpServletRequest request) throws Exception {
		return frmService.getFrmList(mapParam, request);
	}

	@RequestMapping("/pcm/frm/save")
	public @ResponseBody HashMap<String, Object> 현장자재요청서저장(@RequestParam HashMap<String, Object> mapParam, MultipartHttpServletRequest request) throws Exception {
		return frmService.saveFrm(mapParam, request);
	}

	@RequestMapping("/pcm/frm/create")
	public  @ResponseBody HashMap<String, Object> 현장자재요청서생성(@RequestParam HashMap<String, Object> mapParam, HttpServletRequest request) throws Exception {
		return frmService.createFrm(mapParam, request);
	}
}
