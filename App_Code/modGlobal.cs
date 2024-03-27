using Microsoft.VisualBasic;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.Web.UI.WebControls;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Net.Mail;
using System.Data.Common;

public static class modGlobal
{
	
	public enum MessageType
	{
		SuccessMsg = 0,
		ErrorMsg = 1,
		InformationMsg = 2,
		WarningMsg = 3,
		ExecptionMsg = 4
	}

	#region " Private Variables "

	private static string _FileName;
	private static string _Address;
	private static string _CompanyHeader;
	private static string _ReportHeader;
	private static string _ReportFooter;
	private static string _ReportExcelFooter;

	private static string _CurrencySymbol;
	private static string _DataTableHeader;
	private static string _DisplayHeader;

	private static string _dataWidth;
	private static string _CHeaderalign;
	private static string _SubHeaderAlign;
	private static string _HeaderAlign;
	private static string _DataAlign;

	public static DataTable _dtExcel = new DataTable();
	private static string _PrintTableHeader;
	private static string _PrintDisplayHeader;
	private static string _PrintWidth;
	private static DataTable _dtPrint = new DataTable();

	private static string _PrintHeaderAlign;
	private static bool _bbBorder;
	private static bool _hdBorder;
	private static bool _dateRequired;
	private static bool _htmlParse;
	private static bool _isCmdLine;
	private static int _verticalAlign;
	private static bool _OrientLandscape;

	private static bool _isPrintAddress;
	private static string _strTo;
	private static string _strFrom;
	private static string _strSubject;
	private static string _strMessage;
	private static string _strCC;

	private static bool _bodyHtml;
	private static string _headerColSpan;

	private static string _FooterAlign;
	#endregion

	#region " Public Properties "

	/// <summary>
	/// Name of File to save
	/// </summary>
	/// <value></value>
	/// <returns></returns>
	/// <remarks></remarks>
	public static string FileName {
		get { return _FileName; }
		set { _FileName = value; }
	}

	/// <summary>
	/// Adress to be printed in header
	/// </summary>
	/// <value></value>
	/// <returns></returns>
	/// <remarks></remarks>
	public static string Address {
		get { return _Address; }
		set { _Address = value; }
	}

	/// <summary>
	/// Name of the company or enterprise, to be displayed at the top in Excel
	/// </summary>
	/// <value></value>
	/// <returns></returns>
	/// <remarks></remarks>
	public static string CompanyHeader {
		get { return _CompanyHeader; }
		set { _CompanyHeader = value; }
	}

	/// <summary>
	/// Report header , Name of the Report and Date Information
	/// </summary>
	/// <value></value>
	/// <returns></returns>
	/// <remarks></remarks>
	public static string ReportHeader {
		get { return _ReportHeader; }
		set { _ReportHeader = value; }
	}

	/// <summary>
	/// Report Footer
	/// </summary>
	/// <value></value>
	/// <returns></returns>
	/// <remarks></remarks>
	public static string ReportExcelFooter {
		get { return _ReportExcelFooter; }
		set { _ReportExcelFooter = value; }
	}

	/// <summary>
	/// Report Footer
	/// </summary>
	/// <value></value>
	/// <returns></returns>
	/// <remarks></remarks>
	public static string ReportFooter {
		get { return _ReportFooter; }
		set { _ReportFooter = value; }
	}
	/// <summary>
	/// Currency of the Report
	/// </summary>
	/// <value></value>
	/// <returns></returns>
	/// <remarks></remarks>
	public static string CurrencySymbol {
		get { return _CurrencySymbol; }
		set { _CurrencySymbol = value; }
	}

	/// <summary>
	/// Columns to be included in the excel from the Datatable given ( The exact column name of the datatable, set them in the order you want to display in Excel )
	/// </summary>
	/// <value></value>
	/// <returns></returns>
	/// <remarks></remarks>
	public static string DataTableHeader {
		get { return _DataTableHeader; }
		set { _DataTableHeader = value; }
	}

	/// <summary>
	/// Column wise Header to be display
	/// </summary>
	/// <value></value>
	/// <returns></returns>
	/// <remarks></remarks>
	public static string DisplayHeader {
		get { return _DisplayHeader; }
		set { _DisplayHeader = value; }
	}

	/// <summary>
	/// Print Width in Pixcel
	/// </summary>
	/// <value></value>
	/// <returns></returns>
	/// <remarks></remarks>
	public static string PrintWidth {
		get { return _PrintWidth; }
		set { _PrintWidth = value; }
	}

	/// <summary>
	/// Column wise Header alignment
	/// </summary>
	/// <value></value>
	/// <returns></returns>
	/// <remarks></remarks>
	public static string HeaderAlign {
		get { return _HeaderAlign; }
		set { _HeaderAlign = value; }
	}

	/// <summary>
	/// Column wise data alignment
	/// </summary>
	/// <value></value>
	/// <returns></returns>
	/// <remarks></remarks>
	public static string DataAlign {
		get { return _DataAlign; }
		set { _DataAlign = value; }
	}

	/// <summary>
	/// Column wise Data width in pixcel
	/// </summary>
	/// <value></value>
	/// <returns></returns>
	/// <remarks></remarks>
	public static string DataWidth {
		get { return _dataWidth; }
		set { _dataWidth = value; }
	}

	public static string CHeaderalign {
		get { return _CHeaderalign; }
		set { _CHeaderalign = value; }
	}

	public static string StrTo {
		get { return _strTo; }
		set { _strTo = value; }
	}
	public static string StrFrom {
		get { return _strFrom; }
		set { _strFrom = value; }
	}
	public static string StrSubject {
		get { return _strSubject; }
		set { _strSubject = value; }
	}
	public static string StrMessage {
		get { return _strMessage; }
		set { _strMessage = value; }
	}
	public static string StrCC {
		get { return _strCC; }
		set { _strCC = value; }
	}

	public static bool IsBodyHtml {
		get { return _bodyHtml; }
		set { _bodyHtml = value; }
	}

	/// <summary>
	/// datatable containing data
	/// </summary>
	/// <value></value>
	/// <returns></returns>
	/// <remarks></remarks>
	public static DataTable dtPrint {
		get { return _dtPrint; }
		set { _dtPrint = value; }
	}


	public static bool BbBorder {
		get { return _bbBorder; }
		set { _bbBorder = value; }
	}
	public static bool HdBorder {
		get { return _hdBorder; }
		set { _hdBorder = value; }
	}
	public static bool DateRequired {
		get { return _dateRequired; }
		set { _dateRequired = value; }
	}
	public static bool HtmlParse {
		get { return _htmlParse; }
		set { _htmlParse = value; }
	}
	public static bool IsCmdLine {
		get { return _isCmdLine; }
		set { _isCmdLine = value; }
	}
	public static int VerticalAlign {
		get { return _verticalAlign; }
		set { _verticalAlign = value; }
	}
	public static bool OrientLandscape {
		get { return _OrientLandscape; }
		set { _OrientLandscape = value; }
	}
	public static bool IsPrintAddress {
		get { return _isPrintAddress; }
		set { _isPrintAddress = value; }
	}

	public static DataTable DtExcel {
		get { return _dtExcel; }
		set { _dtExcel = value; }
	}

	public static string PrintTableHeader {
		get { return _PrintTableHeader; }
		set { _PrintTableHeader = value; }
	}
	public static string PrintDisplayHeader {
		get { return _PrintDisplayHeader; }
		set { _PrintDisplayHeader = value; }
	}
	public static string PrintHeaderAlign {
		get { return _PrintHeaderAlign; }
		set { _PrintHeaderAlign = value; }
	}

	public static string HeaderColSpan {
		get { return _headerColSpan; }
		set { _headerColSpan = value; }
	}

	public static string FooterAlign {
		get { return _FooterAlign; }
		set { _FooterAlign = value; }
	}

	/// <summary>
	/// Specify Signs for the alignment - less than (Left) Greater than (Right)  
	/// </summary>
	/// <value></value>
	/// <returns></returns>
	/// <remarks></remarks>
	public static string SubHeaderAlign {
		get { return _SubHeaderAlign; }
		set { _SubHeaderAlign = value; }
	}

	#endregion

	public static System.DateTime ConvertDateToSysFormat(string DateStr, string Format)
	{
		try {
			string strFormat = Format;
			string TimeStr = "";
			Format = FormatDateGbl(Format);
			string[] aStr = null;
			string[] astrFormat = null;
			string Sep = null;

			Sep = FindSeparatorGbl(strFormat);
			if (Sep != null) {
				astrFormat = strFormat.Split(Convert.ToChar(Sep));
				aStr = DateStr.Split(Convert.ToChar(Sep));
			} else {
				Interaction.MsgBox(DateStr + " is invalid.");
				return DateTime.Now.Date;
			}

			string m = null;
			string d = null;
			string y = null;

			m = "";
			d = "";
			y = "";

			int i = 0;
			for (i = 0; i <= astrFormat.GetUpperBound(0); i++) {
				switch (Strings.UCase(astrFormat[i])) {
					case "MM":
						m = aStr[i];
						break;
					case "MMM":
						m = aStr[i];
						break;
					case "MON":
						m = aStr[i];
						break;
					case "M":
						m = aStr[i];
						break;
					case "DD":
						d = aStr[i];
						break;
					case "D":
						d = aStr[i];
						break;
					case "YY":
						if (aStr[i].ToString().Length > 2) {
							TimeStr = " " + Strings.Right(aStr[i].ToString(), aStr[i].ToString().Length - 3);
							y = "20" + Strings.Left(aStr[i], 2);
						} else {
							y = "20" + aStr[i];
						}

						break;
					case "YYYY":
						if (aStr[i].ToString().Length > 4) {
							TimeStr = " " + Strings.Right(aStr[i].ToString(), aStr[i].ToString().Length - 5);
							y = Strings.Left(aStr[i], 4);
						} else {
							y = aStr[i];
						}

						break;
					//Case "Y"
					//    y = Right("20" & aStr(i), 4)
				}
			}

			//validate year
			if (!string.IsNullOrEmpty(y) && Information.IsNumeric(y)) {
				if (Convert.ToInt32(y) < 1900) {
					Interaction.MsgBox("Year should be greater than or equal to 1900");
                    return DateTime.Now.Date;
				}
			}

			if (i < aStr.GetUpperBound(0)) {
				for (i = i; i <= aStr.GetUpperBound(0); i++) {
					TimeStr = Convert.ToString(TimeStr) + " " + aStr[i];
				}
			}

			string strCulture = null;
			strCulture = Strings.UCase(System.Globalization.CultureInfo.CurrentCulture.DateTimeFormat.ShortDatePattern);
			switch (Strings.UCase(FormatDateGbl(strCulture))) {
				case "M/D/Y":
					return Convert.ToDateTime(m + "/" + d + "/" + y + Convert.ToString(TimeStr));
				case "D/M/Y":
					return Convert.ToDateTime(d + "/" + m + "/" + y + Convert.ToString(TimeStr));
				case "Y/M/D":
					return Convert.ToDateTime(y + "/" + m + "/" + d + Convert.ToString(TimeStr));
                default:
                    return DateTime.Now.Date;
			}
		} catch (Exception ex) {
			Interaction.MsgBox("Date " + DateStr + " is invalid.");
            return DateTime.Now.Date;
		}
	}
    

	public static string GetShortMonthName(int MonthIndex)
	{
		switch (MonthIndex) {
			case 1:
				return "Jan";
			case 2:
				return "Feb";
			case 3:
				return "Mar";
			case 4:
				return "Apr";
			case 5:
				return "May";
			case 6:
				return "Jun";
			case 7:
				return "Jul";
			case 8:
				return "Aug";
			case 9:
				return "Sep";
			case 10:
				return "Oct";
			case 11:
				return "Nov";
			case 12:
				return "Dec";
		}
		return "";
	}

	/// <summary>
	/// Format a string provided for an SQL Query to prevent SQL injection: Replace single quotation mark (') with double ('')
	/// </summary>
	/// <param name="strSql"></param>
	/// <returns></returns>
	/// <remarks></remarks>
	public static string FormatString(string strSql)
	{
		if (strSql == null)
			return "";
		if (string.IsNullOrEmpty(strSql.Trim()))
			return "";
		return Strings.Replace(Convert.ToString(strSql), "'", "''").Trim();
	}

    
	#region " Date Methods "

	public static string GetCurrentDate(System.DateTime strDate)
	{
		return strDate.ToString("dd/MM/yyyy");
	}


	/// <summary>
	/// Converts the string (date) of the given format into culture specific date format
	/// </summary>
	/// <param name="DateStr"></param>
	/// <param name="Format"></param>
	/// <returns></returns>
	/// <remarks></remarks>
	public static System.DateTime ConvertDateToSysFormatGbl(string DateStr, string Format, ref string Message)
	{
		try {
			string strFormat = Format;
			string TimeStr = "";
			Format = FormatDateGbl(Format);
			string[] aStr = null;
			string[] astrFormat = null;
			string Sep = null;

			Sep = FindSeparatorGbl(strFormat);
			if (Sep != null) {
				astrFormat = strFormat.Split(Convert.ToChar(Sep));
				aStr = DateStr.Split(Convert.ToChar(Sep));
			} else {
				Message = "Date is Invalid";
                return DateTime.Now.Date;
			}

			string m = null;
			string d = null;
			string y = null;

			m = "";
			d = "";
			y = "";

			int i = 0;
			for (i = 0; i <= astrFormat.GetUpperBound(0); i++) {
				switch (Strings.UCase(astrFormat[i])) {
					case "MM":
						m = aStr[i];
						break;
					case "MMM":
						m = aStr[i];
						break;
					case "MON":
						m = aStr[i];
						break;
					case "M":
						m = aStr[i];
						break;
					case "DD":
						d = aStr[i];
						break;
					case "D":
						d = aStr[i];
						break;
					case "YY":
						if (aStr[i].ToString().Length > 2) {
							TimeStr = " " + Strings.Right(aStr[i].ToString(), aStr[i].ToString().Length - 3);
							y = "20" + Strings.Left(aStr[i], 2);
						} else {
							y = "20" + aStr[i];
						}

						break;
					case "YYYY":
						if (aStr[i].ToString().Length > 4) {
							TimeStr = " " + Strings.Right(aStr[i].ToString(), aStr[i].ToString().Length - 5);
							y = Strings.Left(aStr[i], 4);
						} else {
							y = aStr[i];
						}

						break;
					//Case "Y"
					//    y = Right("20" & aStr(i), 4)
				}
			}

			//validate year
			if (!string.IsNullOrEmpty(y) && Information.IsNumeric(y)) {
				if (Convert.ToInt32(y) < 1900) {
					//If MsgObj IsNot Nothing Then
					//    MsgObj.ReturnCode = 1
					//    MsgObj.Message = GetMessageGbl(MsgObj, "Compare>=", "Common", "Year", "1900")
					//End If
                    return DateTime.Now.Date;
				}
			}

			if (i < aStr.GetUpperBound(0)) {
				for (i = i; i <= aStr.GetUpperBound(0); i++) {
					TimeStr = Convert.ToString(TimeStr) + " " + aStr[i];
				}
			}

			string strCulture = null;
			strCulture = Strings.UCase(System.Globalization.CultureInfo.CurrentCulture.DateTimeFormat.ShortDatePattern);
			//If MsgObj IsNot Nothing Then ''''
			//    MsgObj.ReturnCode = 0
			//    MsgObj.Message = ""
			//End If
			switch (Strings.UCase(FormatDateGbl(strCulture))) {
				case "M/D/Y":
					return Convert.ToDateTime(m + "/" + d + "/" + y + Convert.ToString(TimeStr));
				case "D/M/Y":
					return Convert.ToDateTime(d + "/" + m + "/" + y + Convert.ToString(TimeStr));
				case "Y/M/D":
					return Convert.ToDateTime(y + "/" + m + "/" + d + Convert.ToString(TimeStr));
                default :
                    return DateTime.Now.Date;
			}
		} catch (Exception ex) {
			Message = "Date is Invalid";
            return DateTime.Now.Date;
		}
	}

	/// <summary>
	/// Format date 
	/// </summary>
	/// <param name="strSql"></param>
	/// <returns></returns>
	/// <remarks></remarks>
	public static string FormatDateGbl(string strSql)
	{
		if ((strSql != null)) {
			strSql = strSql.Replace(".", "/");
			strSql = strSql.Replace("-", "/");
			strSql = strSql.Replace(" ", "/");

			strSql = Strings.Replace(strSql, "yyyy", "Y");
			strSql = Strings.Replace(strSql, "yy", "Y");
			strSql = Strings.Replace(strSql, "mmm", "M");
			strSql = Strings.Replace(strSql, "mon", "M");
			strSql = Strings.Replace(strSql, "mm", "M");
			strSql = Strings.Replace(strSql, "dd", "D");

			strSql = Strings.Replace(strSql, "YYYY", "Y");
			strSql = Strings.Replace(strSql, "YY", "Y");
			strSql = Strings.Replace(strSql, "MMM", "M");
			strSql = Strings.Replace(strSql, "MON", "M");
			strSql = Strings.Replace(strSql, "MM", "M");
			strSql = Strings.Replace(strSql, "DD", "D");
		}
		return strSql;
	}

	/// <summary>
	/// Find out a separator used in a Date-Time format
	/// </summary>
	/// <param name="DateTimeFormat"></param>
	/// <returns></returns>
	/// <remarks></remarks>
	public static string FindSeparatorGbl(string DateTimeFormat)
	{
		if (Strings.InStr(DateTimeFormat, "/") != 0) {
			return "/";
		} else if (Strings.InStr(DateTimeFormat, ".") != 0) {
			return ".";
		} else if (Strings.InStr(DateTimeFormat, "-") != 0) {
			return "-";
		} else if (Strings.InStr(DateTimeFormat, " ") != 0) {
			return " ";
		}
		return "";
	}

	/// <summary>
	/// Used to insert date into database: Convert a date from specified format to 'yyyy/MM/dd' format
	/// </summary>
	/// <returns></returns>
	/// <remarks>This will be passed from page to class for Inserting in database</remarks>
	public static string ToYMDGbl(string InputDate, string strDateFormat)
	{
		try {
			InputDate = InputDate.Trim();
			string CompFormat = strDateFormat;
			//Find out seperator used from the actual date. Seperator can be one only (mixed not allowed)
			string Sep = FindSeparatorGbl(CompFormat);
			string[] dateformat = null;
			dateformat = CompFormat.Split(Convert.ToChar(Sep));

			string[] values = null;
			string InputDateSep = null;
			InputDateSep = FindSeparatorGbl(InputDate);

			if (Sep != InputDateSep) {
				//MsgObj.ReturnCode = 1
				//MsgObj.Message = GetMessageGbl(MsgObj, "Invalid", "Common", "Date Format of " & InputDate)
				return "";
			}

			values = InputDate.Split(Convert.ToChar(Sep));
			//Extract Day, month, year and time
			string D = null;
			string M = null;
			string Y = null;
			string Time = null;
			D = "";
			M = "";
			Y = "";
			Time = "";

			for (int i = 0; i <= dateformat.GetUpperBound(0); i++) {
				switch (Strings.UCase(Strings.Left(dateformat[i].ToString(), 1))) {
					//--------------------------------------------
					case "D":
						if (i == dateformat.GetUpperBound(0)) {
							//Check if time is included
							if (values[i].ToString().Length > 2) {
								Time = Strings.Right(values[i].ToString(), values[i].ToString().Length - 3);
								D = Strings.Left(values[i].ToString(), 2);
							} else {
								D = values[i];
							}
						} else {
							D = values[i];
						}
						break;
					//--------------------------------------------
					case "M":
						if (i == dateformat.GetUpperBound(0)) {
							//Check if time is included
							if (values[i].ToString().Length > 3) {
								Time = Strings.Right(values[i].ToString(), values[i].ToString().Length - 4);
								M = Strings.Left(values[i].ToString(), 3);
							} else if (values[i].ToString().Length > 2) {
								M = GetMonthIndexGbl(values[i]);
							} else {
								M = values[i];
							}
						} else {
							if (values[i].ToString().Length > 2) {
								M = GetMonthIndexGbl(values[i]);
							} else {
								M = values[i];
							}
						}
						break;
					case "Y":
						if (i == dateformat.GetUpperBound(0)) {
							//Check if time is included
							if (values[i].ToString().Length > 4) {
								Time = Strings.Right(values[i].ToString(), values[i].ToString().Length - 5);
								Y = Strings.Left(values[i].ToString(), 4);
							} else {
								Y = values[i];
							}
						} else {
							Y = values[i];
						}
						break;
				}
			}
			if (values.GetUpperBound(0) > 3) {
				for (int i = 3; i <= values.GetUpperBound(0); i++) {
					Time = Convert.ToString(Time) + " " + values[i];
				}
			}

			//validate date
			if (!string.IsNullOrEmpty(Y) && Information.IsNumeric(Y)) {
				if (Convert.ToInt32(Y) < 1900) {
					//MsgObj.ReturnCode = 1
					//MsgObj.Message = GetMessageGbl(MsgObj, "Compare>=", "Common", "Year", "1900")
					return "";
				}
			}
			if (!IsValidDateGbl(D, M, Y)) {
				//MsgObj.ReturnCode = 1
				//MsgObj.Message = GetMessageGbl(MsgObj, "Invalid", "Common", "Date " & InputDate)
				return "";
			}

			//MsgObj.ReturnCode = 0
			//MsgObj.Message = ""
			//arrange elements
			if (string.IsNullOrEmpty(Time)) {
				return Y + "/" + M + "/" + D;
			} else {
				return Y + "/" + M + "/" + D + " " + Strings.Trim(Time);
			}
		} catch (Exception ex) {
			//MsgObj.ReturnCode = 1
			//MsgObj.Message = GetMessageGbl(MsgObj, "Invalid", "Common", "Date " & InputDate)
			return "";
		}
	}

	/// <summary>
	/// Check if a date is valid or not
	/// </summary>
	/// <param name="Day"></param>
	/// <param name="Month"></param>
	/// <param name="Year"></param>
	/// <returns></returns>
	/// <remarks></remarks>
	public static bool IsValidDateGbl(string Day, string Month, string Year)
	{
		if (Conversion.Val(Year) == 0 | Conversion.Val(Month) == 0 | Conversion.Val(Day) == 0)
			return false;

		//validate year
		if (Year.Length != 4) {
			return false;
		}
		//validate month
		if (Conversion.Val(Month) > 12) {
			return false;
		}
		//validate days
		if (Conversion.Val(Day) > DateTime.DaysInMonth(Convert.ToInt32(Year), Convert.ToInt32(Month))) {
			return false;
		}
		return true;
	}

	/// <summary>
	/// Get index of month provided in the short month format
	/// </summary>
	/// <param name="ShortMonthName"></param>
	/// <returns></returns>
	/// <remarks></remarks>
	public static string GetMonthIndexGbl(string ShortMonthName)
	{
		switch (Strings.LCase(ShortMonthName)) {
			case "jan":
				return "01";
			case "feb":
				return "02";
			case "mar":
				return "03";
			case "apr":
				return "04";
			case "may":
				return "05";
			case "jun":
				return "06";
			case "jul":
				return "07";
			case "aug":
				return "08";
			case "sep":
				return "09";
			case "oct":
				return "10";
			case "nov":
				return "11";
			case "dec":
				return "12";
		}
		return "";
	}
    	#endregion

	

}