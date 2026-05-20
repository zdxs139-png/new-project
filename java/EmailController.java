package acms.sys.email;

import java.util.HashMap;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import acms.common.CommonService;

@Controller
public class EmailController {

	@Autowired
	private CommonService commonService;

	@Autowired
	private EmailService emailService;

	@RequestMapping("/sys/email/email")
	public String 이메일_대용량첨부관리_페이지(HttpServletRequest request, Model model) throws Exception {
		return commonService.goToPage(request, model, "/sys/email/email");
	}

	@RequestMapping("/sys/email/emailPopup")
	public String 이메일_팝업(HttpServletRequest request, Model model) throws Exception {
		return commonService.goToPage(request, model, "/sys/email/emailPopup");
	}

	@RequestMapping("/sys/email/loadEmailGridData")
	public @ResponseBody HashMap<String, Object> 이메일_조회(@RequestParam HashMap<String, Object> mapParam, HttpServletRequest request) throws Exception {
		return emailService.getLoadEmailGridData(mapParam, request);
	}

	@RequestMapping("/sys/email/saveEmailGrid")
	public @ResponseBody HashMap<String, Object> 이메일_저장(@RequestParam HashMap<String, Object> mapParam, MultipartHttpServletRequest request) throws Exception {
		return emailService.getSaveEmailGrid(mapParam, request);
	}

	@RequestMapping("/sys/email/deleteEmail")
	public @ResponseBody HashMap<String, Object> 삭제(@RequestParam HashMap<String, Object> mapParam, HttpServletRequest request) throws Exception {
		return emailService.getDeleteEmail(mapParam, request);
	}

	@RequestMapping("/sys/email/emailsettingPopup")
	public String 이메일_기본설정_팝업(HttpServletRequest request, Model model) throws Exception {
		return commonService.goToPage(request, model, "/sys/email/emailsettingPopup");
	}

	@RequestMapping("/sys/email/loadEmailSetting")
	public @ResponseBody HashMap<String, Object> 이메일_기본설정_조회(@RequestParam HashMap<String, Object> mapParam, HttpServletRequest request) throws Exception {
		return emailService.getLoadEmailSetting(mapParam, request);
	}

	@RequestMapping("/sys/email/saveEmailSetting")
	public @ResponseBody HashMap<String, Object> 이메일_기본설정_저장(@RequestParam HashMap<String, Object> mapParam, HttpServletRequest request) throws Exception {
		return emailService.getEmailSetting(mapParam, request);
	}

	@RequestMapping("/common/outlookSettingPopup")
	public String Outloock_설정_팝업(HttpServletRequest request, Model model) throws Exception {
		return commonService.goToPage(request, model, "/common/outlookSettingPopup");
	}

	@RequestMapping("/sys/email/deletePhysicalFileInServer")
	public @ResponseBody HashMap<String, Object> 물리파일_삭제(@RequestParam HashMap<String, Object> mapParam, HttpServletRequest request) throws Exception {
		return emailService.deletePhysicalFileInServer(mapParam, request);
	}

}
