package acms.pcm.frm;

import acms.common.CommonDTO;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@Data
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = false)
@JsonIgnoreProperties(ignoreUnknown = true)
@SuppressWarnings("serial")
public class FrmEntity extends CommonDTO {
	private long frmSeq;
	private String purchaseRequestNo;
	private String requestDt;
	private String specNo;
	private String qtClassCd;
	private String receiptNo;
	private String receiptDt;
	private String contractDt;
	private String siteDeliveryDt;
	private String remark;
	private String attachFileGrpSeq;

	private long regUserSeq;
	private String regDt;
	private long modiUserSeq;
	private String modiDt;
	private String delYn;
	private long delUserSeq;
	private String delDt;

	// 특정 클래스의 모든 필드를 반환하는 메서드
	@JsonIgnore
	public static List<String> getFields(Class<?> clazz) {
		Field[] fields = clazz.getDeclaredFields();
		List<String> fieldNames = new ArrayList<>();
		for (Field field : fields) {
			fieldNames.add(field.getName());
		}
		return fieldNames;
	}
	// 특정 클래스의 변환된 필드명을 반환하는 메서드
	@JsonIgnore
	public static List<String> getConvertedFields() {
		return Arrays.stream(FrmEntity.class.getDeclaredFields())
				.map(Field::getName)
				.map(FrmEntity::toUpperSnakeCase)
				.collect(Collectors.toList());
	}

	@JsonIgnore
	public List<Object> getFieldValues() {
		List<Object> fieldValues = new ArrayList<>();
		List<String> fieldNames = Arrays.stream(FrmEntity.class.getDeclaredFields())
				.map(Field::getName)
				.collect(Collectors.toList());
		for (String fieldName : fieldNames) {
			try {
				Field field = this.getClass().getDeclaredField(fieldName);
				field.setAccessible(true);
				if (field.get(this) != null){
					fieldValues.add(field.get(this));
				}else{
					fieldValues.add(null);
				}
			} catch (NoSuchFieldException | IllegalAccessException e) {
				e.printStackTrace();
			}
		}
		return fieldValues;
	}

	@JsonIgnore
	public static String toCamelCase(String upperSnakeCase) {
		StringBuilder result = new StringBuilder();
		boolean nextUpper = false;
		for (char c : upperSnakeCase.toCharArray()) {
			if (c == '_') {
				nextUpper = true;
			} else if (nextUpper) {
				result.append(Character.toUpperCase(c));
				nextUpper = false;
			} else {
				result.append(Character.toLowerCase(c));
			}
		}
		return result.toString();
	}

	// 필드명 변환 유틸리티 메서드
	@JsonIgnore
	public static String toUpperSnakeCase(String camelCase) {
		StringBuilder result = new StringBuilder();
		for (char c : camelCase.toCharArray()) {
			if (Character.isUpperCase(c)) {
				result.append("_").append(Character.toUpperCase(c));
			} else {
				result.append(Character.toUpperCase(c));
			}
		}
		return result.toString();
	}
}
