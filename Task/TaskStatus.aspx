<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="TaskStatus.aspx.cs" Inherits="Task_TaskStatus" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/fixedColumns.bootstrap.min.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>
    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />
    <script type="text/javascript" src="../Scripts/colorbox/jquery.colorbox-min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.fixedColumns.min.js"></script>

    <script type="text/javascript">

        $(document).ready(function () {

            $('.divDetails').hide();

            $('.fromdate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                minDate: new Date(2017, 6, 1)
            });

            $('.todate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                //"maxDate": '<%=DateTime.Now %>',
                minDate: new Date(2017, 6, 1)
            });

            $('.ddlStatus').change(function () {
                $('.tblDetailData').DataTable().destroy();
                $('.tblDetailData tbody').empty();
                $('.tblDetailData').hide();
            });
        });

        function LoadData() {
            var CustID = $('.txtCustCode').val().split('-').pop();
            var MechanicID = $('.txtCode').val().split('-').pop();

            if ($(".ddlStatus").val() == '0')
                TaskDetail($(".ddlStatus").val(), $(".hdnTaskType").val(), $(".fromdate").val(), $(".todate").val(), CustID, MechanicID);
            else
                TaskDetail($(".ddlStatus").val(), $(".hdnTaskType").val(), $(".fromdate").val(), $(".todate").val(), CustID, MechanicID);
        }

        function TaskDetail(Status, Type, FromDate, ToDate, CustID, MechanicID) {
            if (Type == "PM")
                $('.TaskType').val('Preventive Task')
            else if (Type == "BM")
                $('.TaskType').val('Breakdown Task')
            else if (Type == "AM")
                $('.TaskType').val('Audit Task')
            $.blockUI({
                message: '<img src="../Images/loadingbd.gif" />',
                css: {
                    padding: 0,
                    margin: 0,
                    width: '15%',
                    top: '36%',
                    left: '40%',
                    textAlign: 'center',
                    cursor: 'wait'
                }
            });

            $('.hdnTaskType').val(Type);

            if ($.fn.DataTable.isDataTable('.tblDetailData')) {
                $('.tblDetailData').DataTable().destroy();
            }

            $('.tblDetailData tbody').empty();

            $.ajax({
                url: 'TaskStatus.aspx/GetTaskDetails',
                type: 'POST',
                dataType: 'json',
                async: false,
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify({ strFromDate: FromDate, strToDate: ToDate, TAGID: Type + Status, CustId: CustID, MechanicId: MechanicID, UserId: $(".hdnLoginUserID").val() }),
                contentType: 'application/json',
                success: function (result) {
                    $.unblockUI();
                    //$('.tblDetailData tbody').empty();
                    $('.divStatus').hide(500);
                    $('.divDetails').show(500);

                    if (result.d[0] == "") {
                        event.preventDefault();
                        return false;
                    }
                    else if (result.d[0].indexOf("ERROR=") >= 0) {
                        $('.tblDetailData').hide();
                        $(".ddlStatus").val(Status);
                        var ErrorMsg = result.d[0].split('=')[1].trim();
                        ModelMsg(ErrorMsg, 3);
                        event.preventDefault();
                        return false;
                    }
                    else {
                        $('.tblDetailData').show();
                        $('.tblDetailData tbody').empty();
                        var ReportData = JSON.parse(result.d[0]);
                        var str = "";
                        //$('.fromdate').val(ReportData[0].FromDate);
                        //$('.todate').val(ReportData[0].ToDate);
                        $(".ddlStatus").val(Status);
                        for (var i = 0; i < ReportData.length; i++) {
                            str = "<tr><td>" + (i + 1) + "</td>"
                                    + "<td style='cursor:pointer; color:red'><a id='lnk" + ReportData[i].TaskID + "' onclick='ColorboxClick(" + ReportData[i].TaskID + ",0); return false;'> Re-Assign </a></td>"
                                    + "<td>" + ReportData[i].Type + "</td>"
                                    + "<td>" + ReportData[i].TaskNo + "</td>"
                                    + "<td>" + ReportData[i].TaskName + "</td>"
                                    + "<td>" + ReportData[i].CreatedDate + "</td>"
                                    + "<td>" + ReportData[i].DueDateTime + "</td>"
                                    + "<td>" + ReportData[i].AssignFrom + "</td>"
                                    + "<td>" + ReportData[i].AssignTo + "</td>"
                                    + "<td>" + ReportData[i].ActualMechanic + "</td>"
                                    + "<td>" + ReportData[i].AssetNo + "</td>"
                                    + "<td>" + ReportData[i].RSDLocation + "</td>"
                                    + "<td>" + ReportData[i].ConflictBy + "</td>"
                                    + "<td>" + ReportData[i].DiscountedSales + "</td>"
                                    + "<td>" + ReportData[i].ConflictWith + "</td>"
                                    + "<td>" + ReportData[i].City + "</td>"
                                    + "<td>" + ReportData[i].State + "</td>"
                                    + "<td>" + ReportData[i].Status + "</td>"
                                    + "<td style='cursor:pointer; color:red'><a id='lnk" + ReportData[i].TaskID + "' onclick='ColorboxClick(" + ReportData[i].TaskID + ",14); return false;'>" + ReportData[i].AssignmentHistory + "</a></td>"
                                    + "<td>" + ReportData[i].CompletionDateTime + "</td>"
                                    + "<td>" + ReportData[i].CompletionByCode + "</td>"
                                    + "<td>" + ReportData[i].CompletionByName + "</td>"
                                    + "<td>" + ReportData[i].CompletionRemarks + "</td>"
                             + "<td>" + ReportData[i].ScanningThrough + "</td></tr>"
                            $('.tblDetailData > tbody').append(str);
                        }
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    $.unblockUI();
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    event.preventDefault();
                    return false;
                }
            });
            if ($('.tblDetailData tbody tr').length > 0) {

                var aryJSONColTable = [];

                aryJSONColTable.push({ "width": "32px", "aTargets": 0 });
                aryJSONColTable.push({ "width": "55px", "className": "dt-body-center", "aTargets": 1 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 2 });
                aryJSONColTable.push({ "width": "30px", "aTargets": 3 });
                aryJSONColTable.push({ "width": "200px", "aTargets": 4 });
                aryJSONColTable.push({ "width": "100px", "aTargets": 5 });
                aryJSONColTable.push({ "width": "100px", "aTargets": 6 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 7 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 8 });
                aryJSONColTable.push({ "width": "150px", "aTargets": 9 });
                aryJSONColTable.push({ "width": "150px", "aTargets": 10 });
                aryJSONColTable.push({ "width": "120px", "aTargets": 11 });
                aryJSONColTable.push({ "width": "180px", "aTargets": 12 });
                aryJSONColTable.push({ "width": "57px", "className": "dt-body-right", "aTargets": 13 });
                aryJSONColTable.push({ "width": "180px", "aTargets": 14 });
                aryJSONColTable.push({ "width": "50px", "aTargets": 15 });
                aryJSONColTable.push({ "width": "50px", "aTargets": 16 });
                aryJSONColTable.push({ "width": "30px", "aTargets": 17 });
                aryJSONColTable.push({ "width": "60px", "className": "dt-body-center", "aTargets": 18 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 19 });
                aryJSONColTable.push({ "width": "70px", "aTargets": 20 });
                aryJSONColTable.push({ "width": "72px", "aTargets": 21 });
                aryJSONColTable.push({ "width": "240px", "aTargets": 22 });
                aryJSONColTable.push({ "width": "30px", "aTargets": 23 });

                $(".tblDetailData").DataTable({
                    'bSort': false,
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    scrollY: '53vh',
                    scrollX: true,
                    responsive: true,
                    "bPaginate": true,
                    "bLengthChange": false,
                    pageLength: 10,
                    "bInfo": false,
                    "aoColumnDefs": aryJSONColTable
                });
            }
        }

        function ColorboxClick(id, col) {
            $.colorbox({
                width: '95%',
                height: '95%',
                iframe: true,
                href: '../Task/TaskReassign.aspx?TaskID=' + id + '&Col=' + col,
                onClosed: function () {
                    if (col == '0')
                        LoadData();
                }
            });
        }

        function BackToDashBoard() {
            $('.divStatus').show(500);
            $('.divDetails').hide();
            location.reload(true);
        }

    </script>
    <style>
        .tblStatus td {
            padding: 5px 5px 5px 15px !important;
        }

            .tblStatus td:hover {
                font-weight: bolder;
                cursor: pointer;
                color: blue;
                text-decoration: underline;
            }

        .tblDetailData {
            width: 100%;
            margin-top: 0px !important;
            margin-bottom: 0px !important;
            position: relative;
        }

        th {
            padding: 3px !important;
        }

        td {
            padding: 5px !important;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div id="divStatus" class="divStatus" runat="server">
        <div class="panel panel-default">
            <div class="panel-heading">
                <h3 class="panel-title"><b>Preventive Maintenance As On Date</b></h3>
            </div>
            <div class="panel-body">
                <div class="input-group form-group">
                    <input type="hidden" runat="server" id="hdnLoginUserID" class="hdnLoginUserID" name="UserId" value="0" />
                    <table width="100%" class="tblStatus">
                        <tbody style="font-weight: bold">
                            <tr>
                                <td>
                                    <asp:LinkButton runat="server" ID="PMO" OnClientClick="TaskDetail('1','PM','','',0,0); return false;"></asp:LinkButton></td>
                                <td>
                                    <asp:LinkButton runat="server" ID="PMA" OnClientClick="TaskDetail('2','PM','','',0,0); return false;"></asp:LinkButton></td>
                                <td style="display:none;">
                                    <asp:LinkButton runat="server" ID="PMR" OnClientClick="TaskDetail('3','PM','','',0,0); return false;"></asp:LinkButton></td>
                                <td style="display:none;">
                                    <asp:LinkButton runat="server" ID="PMP" OnClientClick="TaskDetail('4','PM','','',0,0); return false;"></asp:LinkButton></td>
                                <td style="display:none;">
                                    <asp:LinkButton runat="server" ID="PMRA" OnClientClick="TaskDetail('5','PM','','',0,0); return false;"></asp:LinkButton></td>
                                <td>
                                    <asp:LinkButton runat="server" ID="PMI" OnClientClick="TaskDetail('8','PM','','',0,0); return false;"></asp:LinkButton></td>
                                <td>
                                    <asp:LinkButton runat="server" ID="PMC" OnClientClick="TaskDetail('7','PM','','',0,0); return false;"></asp:LinkButton></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <div class="panel panel-default">
            <div class="panel-heading">
                <h3 class="panel-title"><b>Breakdown Maintenance As On Date</b></h3>
            </div>
            <div class="panel-body">
                <div class="input-group form-group">
                    <table width="100%" class="tblStatus">
                        <tbody style="font-weight: bold">
                            <tr>
                                <td>
                                    <asp:LinkButton runat="server" ID="BMO" OnClientClick="TaskDetail('1','BM','','',0,0); return false;"></asp:LinkButton></td>
                                <td>
                                    <asp:LinkButton runat="server" ID="BMA" OnClientClick="TaskDetail('2','BM','','',0,0); return false;"></asp:LinkButton></td>
                                <td style="display:none;">
                                    <asp:LinkButton runat="server" ID="BMR" OnClientClick="TaskDetail('3','BM','','',0,0); return false;"></asp:LinkButton></td>
                                <td style="display:none;">
                                    <asp:LinkButton runat="server" ID="BMP" OnClientClick="TaskDetail('4','BM','','',0,0); return false;"></asp:LinkButton></td>
                                <td style="display:none;">
                                    <asp:LinkButton runat="server" ID="BMRA" OnClientClick="TaskDetail('5','BM','','',0,0); return false;"></asp:LinkButton></t>
                                <td>
                                    <asp:LinkButton runat="server" ID="BMI" OnClientClick="TaskDetail('8','BM','','',0,0); return false;"></asp:LinkButton></td>
                                <td>
                                    <asp:LinkButton runat="server" ID="BMC" OnClientClick="TaskDetail('7','BM','','',0,0); return false;"></asp:LinkButton></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <div class="panel panel-default">
            <div class="panel-heading">
                <h3 class="panel-title"><b>Audit Maintenance As On Date</b></h3>
            </div>
            <div class="panel-body">
                <div class="input-group form-group">
                    <table width="100%" class="tblStatus">
                        <tbody style="font-weight: bold">
                            <tr>
                                <td>
                                    <asp:LinkButton runat="server" ID="AMO" OnClientClick="TaskDetail('1','AM','','',0,0); return false;"></asp:LinkButton></td>
                                <td>
                                    <asp:LinkButton runat="server" ID="AMA" OnClientClick="TaskDetail('2','AM','','',0,0); return false;"></asp:LinkButton></td>
                                <td style="display:none;">
                                    <asp:LinkButton runat="server" ID="AMR" OnClientClick="TaskDetail('3','AM','','',0,0); return false;"></asp:LinkButton></td>
                                <td style="display:none;">
                                    <asp:LinkButton runat="server" ID="AMP" OnClientClick="TaskDetail('4','AM','','',0,0); return false;"></asp:LinkButton></td>
                                <td style="display:none;">
                                    <asp:LinkButton runat="server" ID="AMRA" OnClientClick="TaskDetail('5','AM','','',0,0); return false;"></asp:LinkButton></td>
                                <td>
                                    <asp:LinkButton runat="server" ID="AMI" OnClientClick="TaskDetail('8','AM','','',0,0); return false;"></asp:LinkButton></td>
                                <td>
                                    <asp:LinkButton runat="server" ID="AMC" OnClientClick="TaskDetail('7','AM','','',0,0); return false;"></asp:LinkButton></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <div id="divDetails" class="divDetails" runat="server">
        <div class="panel panel-default" style="margin-top: 45px; margin-left: 18px;">
            <div class="panel-body _masterForm">
                <div class="row">
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="lblTaskType" runat="server" Text="Task Type" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtTaskType" runat="server" TabIndex="1" CssClass="TaskType form-control" disabled></asp:TextBox>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <input type="hidden" id="hdnTaskType" class="hdnTaskType" runat="server" />
                        <div class="input-group form-group">
                            <asp:Label ID="lblFromDate" runat="server" Text="From Due Date" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtFromDate" runat="server" TabIndex="2" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="lblToDate" runat="server" Text="To Due Date" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtToDate" runat="server" TabIndex="3" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="lblStatus" runat="server" Text="Task Status" CssClass="input-group-addon"></asp:Label>
                            <asp:DropDownList ID="ddlStatus" runat="server" TabIndex="4" CssClass="ddlStatus form-control" DataTextField="TaskStatusName" DataValueField="TaskStatusID" AppendDataBoundItems="true">
                            </asp:DropDownList>
                        </div>
                    </div>
                    <div class="col-lg-4" id="divEmpCode" runat="server">
                        <div class="input-group form-group">
                            <asp:Label ID="lblCode" runat="server" Text="Employee/ Mechanic" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtCode" runat="server" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="5"></asp:TextBox>
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                                UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                                EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                            </asp:AutoCompleteExtender>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="lblCustomer" runat="server" Text="Customer" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtCustCode" runat="server" TabIndex="6" Style="background-color: rgb(250, 255, 189);" CssClass="txtCustCode form-control" autocomplete="off"></asp:TextBox>
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtCustCode" runat="server" ServicePath="~/Service.asmx"
                                UseContextKey="true" MinimumPrefixLength="1" CompletionInterval="10" ServiceMethod="GetCustomerByAllTypeWithoutTemp" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCustCode">
                            </asp:AutoCompleteExtender>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Button ID="btnGo" CssClass="btn btn-default" TabIndex="7" runat="server" Text="GO" OnClientClick="LoadData(); return false;" />
                            &nbsp;&nbsp;&nbsp;
                            <asp:Button ID="btnBack" CssClass="btn btn-default" TabIndex="8" runat="server" Text="Back to DashBoard" OnClientClick="BackToDashBoard(); return false;" />
                            &nbsp;&nbsp;&nbsp;
                            <asp:Button ID="btnExport" CssClass="btn btn-default" TabIndex="9" runat="server" Text="Export Excel" OnClick="btnExport_Click" />
                        </div>
                    </div>
                </div>
                <table id="tblDetailData" class="tblDetailData table table-bordered" style="width: 100%; font-size: 11px;">
                    <thead>
                        <tr class="table-header-gradient">
                            <th>Sr. No</th>
                            <th>Re-Assign</th>
                            <th>Type</th>
                            <th>Task No</th>
                            <th>Task Name (Subject)</th>
                            <th>Entry Date</th>
                            <th>Due Date & Time</th>
                            <th>Assign From</th>
                            <th>Assign To</th>
                            <th>Actual Mechanic Code & Name</th>
                            <th>Asset Serial No</th>
                            <th>RSD Location</th>
                            <th>Conflict By Customer</th>
                            <th>Disc Sales</th>
                            <th>Conflict With Customer</th>
                            <th>City</th>
                            <th>State</th>
                            <th>Status</th>
                            <th>History</th>
                            <th>End Date & Time</th>
                            <th>End By Code</th>
                            <th>End By Name</th>
                            <th>End Remarks</th>
                             <th>Scanning Through</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</asp:Content>

