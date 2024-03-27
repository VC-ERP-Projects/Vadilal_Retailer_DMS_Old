<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="AssetAuditRpt.aspx.cs" Inherits="Reports_AssetAuditRpt" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
  <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>


      <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />
    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />
    <script type="text/javascript" src="../Scripts/colorbox/jquery.colorbox-min.js"></script>
   

<%--    <script type="text/javascript" src="../Scripts/colorbox/jquery.colorbox-min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.fixedColumns.min.js"></script>--%>

    <script type="text/javascript">
        var ParentID = <% = ParentID%>;
        var CustType = '<% =CustType%>';
        // Get vadilal logo
        var imagebase64 = "";
        var LogoURL = '../Images/LOGO.png';
        function ToDataURL(url, callback) {
            var xhr = new XMLHttpRequest();
            xhr.onload = function () {
                var reader = new FileReader();
                reader.onloadend = function () {
                    callback(reader.result);
                }
                reader.readAsDataURL(xhr.response);
            };
            xhr.open('GET', url);
            xhr.responseType = 'blob';
            xhr.send();
        }
        $(document).ready(function () {

            //$('.divDetails').hide();

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
           
            var CustID = $('.txtDealerCode').is(":visible") ? $('.txtDealerCode').val().split('-').pop() : "0";
            
            //var AssetID = $('.txtAssetSerialNo').val().split('/').pop();
            var AssetID = $('.txtAssetSerialNo').val();
            var MechanicID = 0; // $('.txtCode').val().split('-').pop();
            

            if ($(".ddlStatus").val() == '0')
                TaskDetail($(".ddlStatus").val(), $(".hdnTaskType").val(), $(".fromdate").val(), $(".todate").val(), AssetID, MechanicID,CustID);//CustID
            else
                TaskDetail($(".ddlStatus").val(), $(".hdnTaskType").val(), $(".fromdate").val(), $(".todate").val(), AssetID, MechanicID,CustID);//CustID
        }

        function TaskDetail(Status, Type, FromDate, ToDate, AssetID, MechanicID,CustID) { //CustID
            
            var Value = $('.ddlTaskType').val();
            var Text = $(".ddlTaskType option:selected").text();
            var text;
            if (Value == "1") {
                //$('.TaskType').val('Preventive Maintenance');
                $('.hdnTaskType').val('PM');
                var Char1 = Text.charAt(0);
                var Char2 = Text.charAt(11);
                text = Char1 + Char2;
            }
            else if (Value == "2"){
                // $('.ddlTaskType').text('BM')//Breakdown Maintenance
                Type = $('.hdnTaskType').val('BM')
                var Char1 = Text.charAt(0);
                var Char2 = Text.charAt(10);
                text = Char1 + Char2;
            }
            else if (Value == "3"){
                //$('.ddlTaskType').text('AM')//Audit Maintenance
                Type = $('.hdnTaskType').val('AM')
                var Char1 = Text.charAt(0);
                var Char2 = Text.charAt(6);
                text = Char1 + Char2;
            }
            else
            {
                Type = "0";
                text = "AL";
            }
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
            debugger
            var Type = text;
            // $('.hdnTaskType').val(Type);

            if ($.fn.DataTable.isDataTable('.tblDetailData')) {
                $('.tblDetailData').DataTable().destroy();
            }

            $('.tblDetailData tbody').empty();
            $.ajax({
                url: 'AssetAuditRpt.aspx/GetAssetAuditDetails',
                type: 'POST',
                dataType: 'json',
                async: false,
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify({ strFromDate: FromDate, strToDate: ToDate, TAGID: Type + Status, AssetId: AssetID, MechanicId: MechanicID, UserId: $(".hdnLoginUserID").val(),CustomerCode:CustID }),//, UserId: $(".hdnLoginUserID").val()
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
                            //+ "<td>" + ReportData[i].IsManual + "</td></tr>"
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

        //function BackToDashBoard() {
        //    $('.divStatus').show(500);
        //    $('.divDetails').hide();
        //    location.reload(true);
        //}

    </script>
    <%--<style>
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
    </style>--%>
      <style>
        table.dataTable tbody tr.odd-row {
            background-color: #e3e7ff;
        }

        table.dataTable tbody tr.even-row {
            background-color: #fff;
        }

        .dataTables_scroll {
            overflow: auto;
        }

        .dtbodyRight {
            text-align: right;
        }

        div.dataTables_wrapper {
            margin: 0 auto;
        }

        table.dataTable thead th {
            padding: 5px;
        }

        table.dataTable tbody td {
            padding: 5px;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <input type="hidden" runat="server" id="hdnLoginUserID" class="hdnLoginUserID" name="UserId" value="0" />
    <div id="divDetails" class="divDetails" runat="server">
        <div class="panel panel-default" style="margin-top: 45px; margin-left: 18px;">
            <div class="panel-body _masterForm">
                <div class="row">
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="lblTaskType" runat="server" Text="Task Type" CssClass="input-group-addon"></asp:Label>
                            <%--<asp:TextBox ID="txtTaskType" runat="server" TabIndex="1" CssClass="TaskType form-control" disabled></asp:TextBox>--%>
                            <%--<asp:DropDownList ID="ddlTaskStatus" runat="server" CssClass="ddlTaskStatus form-control" TabIndex="1" DataTextField="TaskStatusName" DataValueField="TaskStatusID" AppendDataBoundItems="true">--%>
                            <asp:DropDownList ID="ddlTaskType" class="ddlTaskType" onchange="$('.hdnTaskType').val($(this).val());" runat="server" CssClass="ddlTaskType form-control" TabIndex="1" DataTextField="TaskTypeName" DataValueField="TaskTypeID" AppendDataBoundItems="true">
                                <asp:ListItem Value="AL">ALL</asp:ListItem>
                                <asp:ListItem Value="1">Preventive Maintenance</asp:ListItem>
                                <asp:ListItem Value="2">Breakdown Maintenance</asp:ListItem>
                                <asp:ListItem Value="3">Audit Maintenance</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <input type="hidden" id="hdnTaskType" class="hdnTaskType" runat="server" />
                        <div class="input-group form-group">
                            <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtFromDate" runat="server" TabIndex="2" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtToDate" runat="server" TabIndex="3" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="lblTaskStatus" runat="server" Text="Task Status" CssClass="input-group-addon"></asp:Label>
                            <%--<asp:DropDownList ID="DropDownList1" runat="server" CssClass="ddlTaskStatus form-control" TabIndex="6" DataTextField="TaskStatusName" DataValueField="TaskStatusID" AppendDataBoundItems="true">
                        </asp:DropDownList>--%>
                            <asp:DropDownList ID="ddlStatus" runat="server" TabIndex="4" CssClass="ddlStatus form-control" DataTextField="TaskStatusName" DataValueField="TaskStatusID" AppendDataBoundItems="true">
                            </asp:DropDownList>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="Label1" runat="server" Text="Customer" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtDealerCode" runat="server" CssClass="form-control txtDealerCode" Style="background-color: rgb(250, 255, 189);" TabIndex="5"></asp:TextBox>
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDealerCode" runat="server" ServicePath="~/Service.asmx"
                                UseContextKey="true" MinimumPrefixLength="1" CompletionInterval="10" ServiceMethod="GetCustomerByAllTypeWithoutTemp" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealerCode">
                            </asp:AutoCompleteExtender>
                        </div>
                    </div>
                    <div class="col-lg-4" id="divEmpCode" runat="server" visible="false">
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
                            <asp:Label ID="lblSerialNumber" runat="server" Text='Asset Serial Number' CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtAssetSerialNo" Style="background-color: rgb(250, 255, 189);" CssClass="txtAssetSerialNo form-control" runat="server" TabIndex="8"></asp:TextBox>
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtAssetSerialNo" runat="server" ServicePath="../Service.asmx"
                                UseContextKey="true" ServiceMethod="GetAssetSerialNo" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtAssetSerialNo">
                            </asp:AutoCompleteExtender>
                        </div>
                    </div>
                    <%-- <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="lblManual" runat="server" Text="Is Manual" CssClass="input-group-addon"></asp:Label>
                            <asp:CheckBox ID="chkManual" runat="server" Checked="true" CssClass="form-control"></asp:CheckBox>
                        </div>
                    </div>--%>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Button ID="btnGo" CssClass="btn btn-default" TabIndex="7" runat="server" Text="GO" OnClientClick="LoadData(); return false;" />
                            <%-- &nbsp;&nbsp;&nbsp;
                            <asp:Button ID="btnBack" CssClass="btn btn-default" TabIndex="8" runat="server" Text="Back to DashBoard" OnClientClick="BackToDashBoard(); return false;" />--%>
                            &nbsp;&nbsp;&nbsp;
                            <asp:Button ID="btnExport" CssClass="btn btn-default" TabIndex="9" runat="server" Text="Export Excel" OnClick="btnExport_Click" /><%--OnClick="btnExport_Click" --%>
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

