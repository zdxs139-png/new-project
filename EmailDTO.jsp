package acms.sys.email;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import acms.common.CommonDTO;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@Data
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = false)
@JsonIgnoreProperties(ignoreUnknown = true)
@SuppressWarnings("serial")
public class EmailDTO extends CommonDTO {

	private long emailFileSeq;
	private long fileGrpSeq;
	private String rmk;
	private String status;
	private long regUserSeq;
	private String regDt;
	private String delDt;

	private String regUserNm;
	private String fileGrpId;
	private String statusNm;

	private String fileNm;
	private String fileSize;
	private String fileId;
	private String fileTitle;
	private String fileLink;

	private int downloadCnt;
	private String maxDownCnt;
	private int downloadDay;
	private String expireDt;
	private String downloadableYn;

	private int emailDwCnt;
	private int emailDwDay;

	private String filePath;
}
