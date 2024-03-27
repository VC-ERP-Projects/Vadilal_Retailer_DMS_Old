<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Attendence.aspx.cs" Inherits="Master_Attendence" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../Scripts/ui/css/smoothness/jquery-ui-1.10.3.custom.css" rel="stylesheet" type="text/css" />
    <link href="../Scripts/BootStrapCSS/bootstrap-theme.css" rel="stylesheet" type="text/css" />
    <link href="../Scripts/BootStrapCSS/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="../Scripts/BootStrapCSS/index.css" rel="stylesheet" type="text/css" />

    <script src="../Scripts/jquery-1.9.1.js" type="text/javascript"></script>
    <script src="../Scripts/ui/js/jquery-ui-1.10.3.custom.js" type="text/javascript"></script>
    <script src="../Scripts/Bootstrap/bootstrap.js" type="text/javascript"></script>
    <script src="../Scripts/model/jquery.simplemodal-1.4.4.js" type="text/javascript"></script>
    <script src="../Scripts/timepick/jquery.plugin.min.js"></script>
    <script src="../Scripts/timepick/jquery.timeentry.min.js"></script>

    <script type="text/javascript">

        $(document).ready(function () {

            $('.txtStartTime').timeEntry({ show24Hours: true, spinnerImage: '' });
            $('.txtEndTime').timeEntry({ show24Hours: true, spinnerImage: '' });

            if ($("#ddlEventType").val() == "1") {
                $("#divDayEvent").show();
                $("#divLeaveEntry").hide();
            }
            else {
                $("#divDayEvent").hide();
                $("#divLeaveEntry").show();
            }
            CalCNoOfDays();
            $('.frommindate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                minDate: new Date(2017, 6, 1),
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, inst.selectedDay));
                    CalCNoOfDays();
                },
                onSelect: function (selected) {
                    $('.tomindate').datepicker("option", "minDate", selected);
                    CalCNoOfDays();
                }
            });

            $('.tomindate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                //"maxDate": '<%=DateTime.Now %>',
                minDate: new Date(2017, 6, 1),
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, inst.selectedDay));
                    CalCNoOfDays();
                },
                onSelect: function (selected) {
                    $('.frommindate').datepicker("option", "maxDate", selected);
                    CalCNoOfDays();
                }
            });

            $("#ddlEventType").change(function () {
                if ($("#ddlEventType").val() == "1") {
                    $("#divDayEvent").show();
                    $("#divLeaveEntry").hide();
                }
                else {
                    $("#divDayEvent").hide();
                    $("#divLeaveEntry").show();
                }
            });
            var start = $(".frommindate").datepicker("getDate");
            var end = $(".tomindate").datepicker("getDate");
            if (start != null && end != null) {
                end.setDate(end.getDate() + 1);
                $('#txtNoOfDays').val((end - start) / (1000 * 60 * 60 * 24));
                if ($('.ddlFromTimeType').val() == $('.ddlToTimeType').val()) {
                    $('#txtNoOfDays').val($('#txtNoOfDays').val() - 0.5);
                }
                else if ($('.ddlFromTimeType').val() == '2' && $('.ddlToTimeType').val() == '1') {
                    $('#txtNoOfDays').val($('#txtNoOfDays').val() - 1);
                }
                else if ($('.ddlFromTimeType').val() == '1' && $('.ddlToTimeType').val() == '2') {
                    $('#txtNoOfDays').val($('#txtNoOfDays').val());
                }
                $('#hdnNoOfDays').val($('#txtNoOfDays').val());
            }

            $("#ddlFromTimeType").change(function () {
                CalCNoOfDays();
            });

            $("#ddlToTimeType").change(function () {
                CalCNoOfDays();
            });
        });

        function ModelMsg(Text, ECode) {
            if (ECode == undefined)
                ECode = "1";
            $.modal(Text, ECode);
        }

        function CalCNoOfDays() {
            var start = $(".frommindate").datepicker("getDate");
            var end = $(".tomindate").datepicker("getDate");
            if (start != null && end != null) {
                end.setDate(end.getDate() + 1);
                $('#txtNoOfDays').val((end - start) / (1000 * 60 * 60 * 24));
                if ($('.ddlFromTimeType').val() == $('.ddlToTimeType').val()) {
                    $('#txtNoOfDays').val($('#txtNoOfDays').val() - 0.5);
                }
                else if ($('.ddlFromTimeType').val() == '2' && $('.ddlToTimeType').val() == '1') {
                    $('#txtNoOfDays').val($('#txtNoOfDays').val() - 1);
                }
                else if ($('.ddlFromTimeType').val() == '1' && $('.ddlToTimeType').val() == '2') {
                    $('#txtNoOfDays').val($('#txtNoOfDays').val());
                }
                $('#hdnNoOfDays').val($('#txtNoOfDays').val());
            }
        }

        function _CheckTime() {

            var st = $('.txtStartTime').val();
            var et = $('.txtEndTime').val();

            var startTime = new Date().setHours(parseInt(st.split(':')[0]), parseInt(st.split(':')[1]), 0);
            var endTime = new Date().setHours(parseInt(et.split(':')[0]), parseInt(et.split(':')[0]), 0);

            if (startTime > endTime) {
                alert('End time always greater then start time.');
                return false;
            }
            sessionStorage.setItem("PostBackFlag", "1");
        }

        function _CheckData() {
            CalCNoOfDays();
            var sd = $('#txtFromDate').val();
            var td = $('#txtToDate').val();
            if (sd == "" || td == "") {
                alert("Please enter date");
                return false;
            }
            if (td == null) {
                alert("Please enter date");
                return false;
            }
            if ($('.ddlLeaveType').val() == "0") {
                alert("Please select leave type");
                return false;
            }
            if ($('#txtRemarks').val() == "") {
                alert("Please enter remarks");
                return false;
            }
            if ($('#ddlLeaveType option:selected').text().split("#")[1].trim() == "0") {
                alert("Not enough Leave Balance For Employee.");
                return false;
            }

            sessionStorage.setItem("PostBackFlag", "1");
        }

        function ValidateDate(txt) {
            var txtVal = $(txt).val();

            if (txtVal == "") {
                return true;
            }
            var rxDatePattern = /^(0?[1-9]|[12][0-9]|3[01])[\/\-](0?[1-9]|1[012])[\/\-]\d{4}$/; //Declare Regex
            var dtArray = txtVal.match(rxDatePattern); // is format OK?

            if (dtArray == null) {
                ModelMsg("Please enter proper date in dd/mm/yyyy format", 3);
                var today = new Date();

                var mon = today.getMonth() + 1;
                var mydt = today.getDate();
                if (mydt < 10) {
                    mydt = "0" + mydt;
                }
                if (mon < 10) {
                    mon = "0" + mon;
                }

                $(txt).val(mydt + "/" + mon + "/" + today.getFullYear());
                event.preventDefault();
                return false;
            }
            else {
                return true;
            }
        }
    </script>
    <style>
        .timeEntry-control {
            vertical-align: -webkit-baseline-middle;
            margin-left: 2px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container-fluid">
            <div class="panel panel-default">
                <div class="panel-body">
                    <div class="row _masterForm">
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label Text="Event" runat="server" CssClass="input-group-addon" />
                                <asp:DropDownList ID="ddlEventType" class="ddlEventType" runat="server" CssClass="ddlEventType form-control">
                                    <asp:ListItem Text="Day Start/End Event" Value="1" Selected="True" />
                                    <asp:ListItem Text="Leave Request Event" Value="2"></asp:ListItem>
                                </asp:DropDownList>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div id="divDayEvent" runat="server">
            <div class="container-fluid">
                <span style="color: blue; font-weight: bold">Day End Events</span>
                <div class="panel panel-default">
                    <div class="panel-body">
                        <div class="row _masterForm">
                            <span style="color: red; font-weight: bold; font-size: 11px">Time In 24 Hours.</span><br />
                            <div class="col-lg-4">
                                <div class="input-group form-group">
                                    <asp:Label Text="Start Date" runat="server" CssClass="input-group-addon" />
                                    <asp:TextBox runat="server" ID="txtStartDate" CssClass="form-control" Enabled="false" />
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label Text="End Date" runat="server" CssClass="input-group-addon" />
                                    <asp:TextBox runat="server" ID="txtEndDate" CssClass="form-control" Enabled="false" />
                                </div>
                            </div>
                            <div class="col-lg-4">
                                <div class="input-group form-group">
                                    <asp:Label Text="Start Time" runat="server" CssClass="input-group-addon" />
                                    <asp:TextBox runat="server" ID="txtStartTime" CssClass="txtStartTime form-control" Style="width: 50%;" />
                                </div>

                                <div class="input-group form-group">
                                    <asp:Label Text="End Time" runat="server" CssClass="input-group-addon" />
                                    <asp:TextBox runat="server" ID="txtEndTime" CssClass="txtEndTime form-control" Style="width: 50%;" />
                                </div>
                            </div>
                            <div class="col-lg-4">
                                <div class="input-group form-group">
                                    <asp:RadioButtonList ID="InTIme" runat="server" RepeatDirection="Horizontal">
                                        <asp:ListItem Text="(Day Start) In City" Value="1" Selected="True" />
                                        <asp:ListItem Text="(Day Start) Out City" Value="0" />
                                    </asp:RadioButtonList>
                                </div>
                                <div class="input-group form-group">
                                    <asp:RadioButtonList ID="OutTime" runat="server" RepeatDirection="Horizontal">
                                        <asp:ListItem Text="(Day End) In City" Value="1" Selected="True" />
                                        <asp:ListItem Text="(Day End) Out City" Value="0" />
                                    </asp:RadioButtonList>
                                </div>
                            </div>
                            <br />
                            <asp:Button Text="Submit" CssClass="btn btn-default" ID="btnDayEventSubmit" OnClick="btnDayEventSubmit_Click" OnClientClick="return _CheckTime();" runat="server" />
                            <asp:Button Text="Cancel" CssClass="btn btn-default" OnClientClick="parent.$.colorbox.close(); return false;" runat="server" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div id="divLeaveEntry" runat="server">
            <div class="container-fluid">
                <span style="color: blue;">Leave Request Events For Employee : 
                <asp:Label Style="color: blue; font-weight: bold" ID="txtEmpCode" runat="server"></asp:Label>
                    / Manager : 
                <asp:Label Style="color: blue; font-weight: bold" ID="txtManager" runat="server"></asp:Label>
                </span>
                <div class="panel panel-default">
                    <div class="panel-body">
                        <div class="row _masterForm">
                            <div class="col-lg-4">
                                <div class="input-group form-group">
                                    <asp:Label Text="From Date" runat="server" CssClass="input-group-addon" />
                                    <asp:TextBox ID="txtFromDate" runat="server" TabIndex="1" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="frommindate form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label Text="From Time" runat="server" CssClass="input-group-addon" />
                                    <asp:DropDownList ID="ddlFromTimeType" TabIndex="3" class="ddlRequestType" runat="server" CssClass="ddlFromTimeType form-control">
                                        <asp:ListItem Text="First Half" Value="1" Selected="True" />
                                        <asp:ListItem Text="Second Half" Value="2"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="col-lg-4">
                                <div class="input-group form-group">
                                    <asp:Label Text="To Date" runat="server" CssClass="input-group-addon" />
                                    <asp:TextBox ID="txtToDate" runat="server" TabIndex="2" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="tomindate form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label Text="To Time" runat="server" CssClass="input-group-addon" />
                                    <asp:DropDownList ID="ddlToTimeType" TabIndex="4" class="ddlRequestType" runat="server" CssClass="ddlToTimeType form-control">
                                        <asp:ListItem Text="First Half" Value="1" Selected="True" />
                                        <asp:ListItem Text="Second Half" Value="2"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="col-lg-4">
                                <div class="input-group form-group">
                                    <asp:Label Text="No of Days" runat="server" CssClass="input-group-addon" />
                                    <asp:TextBox ID="txtNoOfDays" runat="server" Enabled="false" TabIndex="2" CssClass="form-control"></asp:TextBox>
                                    <asp:HiddenField ID="hdnNoOfDays" runat="server"></asp:HiddenField>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label Text="Leave Type" runat="server" CssClass="input-group-addon" />
                                    <asp:DropDownList runat="server" TabIndex="5" ID="ddlLeaveType" CssClass="ddlLeaveType form-control">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="col-lg-8">
                                <div class="input-group form-group">
                                    <asp:Label Text="Remarks" runat="server" CssClass="input-group-addon" />
                                    <asp:TextBox ID="txtRemarks" runat="server" TabIndex="6" MaxLength="500" CssClass="txtRemarks form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-lg-4">
                                <asp:Button Text="Submit" CssClass="btn btn-default" TabIndex="8" ID="btnLeaveSubmit" OnClick="btnLeaveSubmit_Click" OnClientClick="return _CheckData();" runat="server" />
                                <asp:Button Text="Cancel" CssClass="btn btn-default" TabIndex="9" OnClientClick="parent.$.colorbox.close(); return false;" runat="server" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
