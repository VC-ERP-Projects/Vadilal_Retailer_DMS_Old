<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="EmployeeDALDays.aspx.cs" Inherits="EmployeeDALDays" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript" src="../Scripts/fixHeaderFooter.js"></script>
    <script>
        $(function () {
            Reload();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });
        function ReloadPage() {
            __doPostBack('Refresh', 'Refresh');
        }

        function Reload() {
            $("#gvDALDaysValidation").tableHeadFixer('77vh');
            FillData();
            $('#CountRowDALDaysDetail').val(0);
            AddMoreRow();
        }

        function EndRequestHandler2(sender, args) {
            Reload();
        }

        function ChangeData(txt) {
            $(txt).parent().parent().find("input[name='IsChange']").val("1");
        }

        function FillData() {

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

            var IsValid = true;

            $.ajax({
                url: 'EmployeeDALDays.aspx/LoadData',
                type: 'POST',
                dataType: 'json',
                contentType: 'application/json; charset=utf-8',
                success: function (result) {
                    $.unblockUI();

                    if (result.d == "") {
                        //ClearAll();
                        $.unblockUI();
                        event.preventDefault();
                        return false;
                    }
                    else if (result.d[0].indexOf("ERROR#") >= 0) {
                        $.unblockUI();
                        var ErrorMsg = result.d[0].split('#')[1].trim();
                        ModelMsg(ErrorMsg, 3);

                        event.preventDefault();

                        return false;
                    }
                    else {
                        var items = result.d[0];
                        if (items.length > 0) {
                            $('#gvDALDaysValidation  > tbody > tr').each(function (row1, tr) {
                                // post table's data to Submit form using Json Format
                                $(this).remove();
                            });
                            var row = 1;

                            for (var i = 0; i < items.length; i++) {
                                AddMoreRow();
                                row = $('#CountRowDALDaysDetail').val();
                                $('#hdnEmpdID' + row).val(items[i].EMPDID);
                                $('#hdnEmpID' + row).val(items[i].EmpID);
                                $('#hdnCustomerID' + row).val(items[i].CustomerID);
                                $('#txtEmpGroupDesc' + row).val(items[i].EmpGroupDesc);
                                $('#txtCustomerCode' + row).val(items[i].CustomerDesc);
                                $('#txtTDays' + row).val(items[i].Days);
                                $('#tdCreateBy' + row).text(items[i].CreatedBy);
                                $('#tdCreateOn' + row).text(items[i].CreatedDate);
                                $('#tdUpdateBy' + row).text(items[i].UpdatedBy);
                                $('#tdUpdateOn' + row).text(items[i].UpdatedDate);
                            }
                        }
                    }
                    AddMoreRow();
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    $.unblockUI();
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    event.preventDefault();
                    return false;
                }
            });
        }
        function AddMoreRow() {

            $('#gvDALDaysValidation tr#NoROW').remove();  // Remove NO ROW

            /// Add Dynamic Row to the existing Table
            var ind = $('#CountRowDALDaysDetail').val();
            ind = parseInt(ind) + 1;
            $('#CountRowDALDaysDetail').val(ind);

            var str = "";
            str = "<tr id='trItem" + ind + "'>"
                 + "<td class='txtSrNo dtbodyCenter' id='txtSrNo" + ind + "'>" + ind + "</td>"
                + "<td><input type='text' id='txtEmpGroupDesc" + ind + "' name='txtEmpGroupDesc' onchange='ChangeData(this);' class='form-control search' style='background-color: rgb(250, 255, 189);'/></td>"
                + "<td><input type='text' id='txtCustomerCode" + ind + "' name='txtCustomerCode' onchange='ChangeData(this);' class='form-control search' style='background-color: rgb(250, 255, 189);'/></td>"
                + "<td><input type='text' id='txtTDays" + ind + "' name='txtTDays' maxlength='4' onchange='ChangeData(this);' class='dtbodyLeft form-control allownumericwithoutdecimal search'/></td>"
                + "<td id='tdCreateOn" + ind + "' class='tdCreateOn dtbodyCenter'></td>"
                + "<td id='tdCreateBy" + ind + "' class='tdCreateBy'></td>"
                + "<td id='tdUpdateOn" + ind + "' class='tdUpdateOn dtbodyCenter'></td>"
                + "<td id='tdUpdateBy" + ind + "' class='tdUpdateBy'></td>"
                + "<input type='hidden' id='hdnLineNum" + ind + "' name='hdnLineNum' value='" + ind + "' /></td>"
                + "<input type='hidden' id='IsChange" + ind + "' name='IsChange' value='0' /></td>"
                + "<input type='hidden' id='hdnEmpdID" + ind + "' name='hdnEmpdID' /></td>"
                + "<input type='hidden' id='hdnCustomerID" + ind + "' name='hdnCustomerID' /></td>"
                + "<input type='hidden' id='hdnEmpID" + ind + "' name='hdnEmpID' /></td></tr>";

            $('#gvDALDaysValidation > tbody').append(str);

            $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);

            $('#txtEmpGroupDesc' + ind).autocomplete({
                source: function (Request, Response) {
                    $.ajax({
                        url: 'EmployeeDALDays.aspx/LoadEmpByType',
                        type: 'POST',
                        dataType: 'json',
                        data: JSON.stringify({ prefixText: Request.term }),
                        async: false,
                        contentType: 'application/json; charset=utf-8',
                        success: function (result) {
                            if (result.d == "") {
                                return false;
                            }
                            else if (result.d[0].indexOf("ERROR=") >= 0) {
                                var ErrorMsg = result.d[0].split('=')[1].trim();
                                ModelMsg(ErrorMsg, 3);
                                return false;
                            }
                            else {
                                Response(result.d[0]);
                            }
                        },
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            alert('Something is wrong...' + XMLHttpRequest.responseText);
                            return false;
                        }
                    });
                },
                select: function (event, ui) {
                    $('#txtEmpGroupDesc' + ind).val(ui.item.value + " ");
                    $('#hdnEmpID' + ind).val(ui.item.value.split('-')[2].trim());
                    $('#txtCustomerCode' + ind).val("");
                    $('#hdnCustomerID' + ind).val(0);
                },
                change: function (event, ui) {
                    if (!ui.item) {
                        $('#txtEmpGroupDesc' + ind).val("");
                        $('#hdnEmpID' + ind).val(0);
                        $('#txtCustomerCode' + ind).val("");
                        $('#hdnCustomerID' + ind).val(0);
                    }
                },
                minLength: 0,
                scroll: true
            });
            $('#txtCustomerCode' + ind).autocomplete({
                source: function (request, response) {
                    var EmpID = $("#txtEmpGroupDesc" + ind).val() != "" && $("#txtEmpGroupDesc" + ind).val() != undefined ? $("#txtEmpGroupDesc" + ind).val().split("-")[2].trim() : "0";

                    $.ajax({
                        type: "POST",
                        url: "EmployeeDALDays.aspx/GetDealerCurrHierarchy",
                        dataType: "json",
                        data: "{ 'prefixText': '" + request.term + "','EmpID': '" + EmpID + "'}",
                        contentType: "application/json; charset=utf-8",
                        success: function (data) {
                            response($.map(data.d, function (item) {
                                return {
                                    label: item.Text,
                                    value: item.Text,
                                    id: item.Value
                                };
                            }))
                        },
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                        }
                    });
                },
                select: function (event, ui) {
                    $('#txtCustomerCode' + ind).val(ui.item.value + " ");
                    $('#hdnCustomerID' + ind).val(ui.item.value.split('-')[2].trim());
                },
                change: function (event, ui) {
                    if (!ui.item) {
                        $('#txtCustomerCode' + ind).val("");
                        $('#hdnCustomerID' + ind).val(0);
                    }
                },
                minLength: 1
            });
            $('#txtCustomerCode' + ind).on('autocompleteselect', function (e, ui) {
                $('#txtCustomerCode' + ind).val(ui.item.value);
                GetEmployeeDetailsByCode(ui.item.value, ind);
            });

            $('#txtCustomerCode' + ind).on('change keyup', function () {
                if ($('#txtCustomerCode' + ind).val() == "") {
                    ClearDealerRow(ind);
                }
            });

            $('#txtCustomerCode' + ind).on('blur', function (e, ui) {
                if ($('#txtCustomerCode' + ind).val().trim() != "") {
                    if ($('#txtCustomerCode' + ind).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Dealer", 3);
                        $('#txtCustomerCode' + ind).val("");
                        $('#hdnCustomerID' + ind).val(0);
                        return;
                    }
                    var txt = $('#txtCustomerCode' + ind).val().trim();
                    if (txt == "undefined" || txt == "") {
                        return false;
                    }
                    CheckDuplicateCustomer($('#txtCustomerCode' + ind).val().trim(), ind);
                }
                //else {
                //    $('#txtCustomerCode' + ind).val("");
                //    $('#hdnCustomerID' + ind).val(0);
                //}
            });
            $(".allownumericwithoutdecimal").on("keypress keyup", function (event) {
                $(this).val($(this).val().replace(/[^\d].+/, ""));
                if ((event.which < 48 || event.which > 57)) {
                    event.preventDefault();
                }
            });
            $('#txtEmpGroupDesc' + ind).on('autocompleteselect', function (e, ui) {
                $('#txtEmpGroupDesc' + ind).val(ui.item.value);
                GetEmployeeDetailsByCode(ui.item.value, ind);
            });

            $('#txtEmpGroupDesc' + ind).on('change keyup', function () {
                if ($('#txtEmpGroupDesc' + ind).val() == "") {
                    ClearEmpRow(ind);
                }
            });

            $('#txtEmpGroupDesc' + ind).on('blur', function (e, ui) {
                if ($('#txtEmpGroupDesc' + ind).val().trim() != "") {
                    if ($('#txtEmpGroupDesc' + ind).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Employee", 3);
                        $('#txtEmpGroupDesc' + ind).val("");
                        $('#hdnEmpID' + ind).val('0');
                        $('#txtTDays' + ind).val("");
                        $('#txtCustomerCode' + ind).val("");
                        $('#hdnCustomerID').val(0);
                        return;
                    }
                    var txt = $('#txtEmpGroupDesc' + ind).val().trim();
                    if (txt == "undefined" || txt == "") {
                        return false;
                    }
                    CheckDuplicateEmp($('#txtEmpGroupDesc' + ind).val().trim(), ind);
                }
            });
            $('#txtTDays' + ind).on('blur', function (e, ui) {
                if ($('#txtTDays' + ind).val().trim() != "") {

                    if ($('#txtTDays' + ind).val() < 0) {
                        ModelMsg("Select Proper DAL Days", 3);
                        $('#txtTDays' + ind).val("");
                        return;
                    }
                    var txt = $('#txtTDays' + ind).val().trim();
                    if (txt == "undefined" || txt == "") {
                        return false;
                    }
                }
            });

            var lineNum = 1;
            $('#gvDALDaysValidation > tbody > tr').each(function (row, tr) {
                $(".txtSrNo", this).text(lineNum);
                lineNum++;
            });
        }

        function CheckDuplicateEmp(CustCode, row) {

            var Item = CustCode.split("-")[0].trim();
            var rowCnt_Customer = 1;
            var cnt = 0;
            var errRow = 0;

            $('#gvDALDaysValidation  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format
                var CustCode = $("input[name='txtEmpGroupDesc']", this).val();
                 var DealerCode = $("input[name='txtCustomerCode']", this).val();
                if ((CustCode != undefined && CustCode != "")||(DealerCode != undefined && DealerCode != "")) {

                    CustCode = CustCode.split("-")[0].trim();

                    var LineNum = $("input[name='hdnLineNum']", this).val();

                    if (CustCode != "") {
                        if (parseInt(row) != parseInt(LineNum)) {
                            if (Item == CustCode) {
                                cnt = 1;
                                errRow = row;
                                $('#txtTDays' + row).val('');
                                $('#txtEmpGroupDesc' + row).val("");
                                $('#hdnEmpID' + row).val(0);
                                errormsg = 'Employee = ' + CustCode + ' is already seleted at row : ' + rowCnt_Customer;
                                return false;
                            }
                        }
                    }
                    rowCnt_Customer++;
                }
            });

            if (cnt == 1) {
                $('#txtEmpGroupDesc' + row).val('');
                ClearEmpRow(row);
                ModelMsg(errormsg, 3);
                return false;
            }

            var ind = $('#CountRowDALDaysDetail').val();
            if (ind == row) {
                AddMoreRow();
            }
        }
        function CheckDuplicateCustomer(CustCode, row) {

             var Item = CustCode.split("-")[0].trim();
            var rowCnt_Customer = 1;
            var cnt = 0;
            var errRow = 0;

            $('#gvDALDaysValidation  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format
                var EmpCode = $("input[name='txtEmpGroupDesc']", this).val();
                var CustCode = $("input[name='txtCustomerCode']", this).val();
                if ((EmpCode != undefined && EmpCode != "")||(CustCode != undefined && CustCode != "")) {

                    CustCode = CustCode.split("-")[0].trim();

                    var LineNum = $("input[name='hdnLineNum']", this).val();

                    if (CustCode != "") {
                        if (parseInt(row) != parseInt(LineNum)) {
                            if (Item == CustCode) {
                                cnt = 1;
                                errRow = row;
                                $('#txtTDays' + row).val('');
                                $('#txtCustomerCode' + row).val("");
                                $('#hdnCustomerID' + row).val(0);
                                errormsg = 'Dealer = ' + CustCode + ' is already seleted at row : ' + rowCnt_Customer;
                                return false;
                            }
                        }
                    }
                    rowCnt_Customer++;
                }
            });
            if (cnt == 1) {
                $('#txtCustomerCode' + row).val('');
                $('#hdnCustomerID' + row).val('');
                ClearDealerRow(row);
                ModelMsg(errormsg, 3);
                return false;
            }

            var ind = $('#CountRowDALDaysDetail').val();
            if (ind == row) {
                AddMoreRow();
            }
        }

        function ClearEmpRow(row) {

            var rowCnt_Customer = 1;
            var cnt = 0;

            $('#gvDALDaysValidation > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var CustCode = $("input[name='txtEmpGroupDesc']", this).val();
                var DealerCode = $("input[name='txtCustomerCode']", this).val();
                if (CustCode == "" && DealerCode == "") {
                    //$(this).remove();
                }
                cnt++;

                rowCnt_Customer++;
            });

            if (cnt > 1) {
                var rowCnt_Customer = 1;
                $('#gvDALDaysValidation > tbody > tr').each(function (row1, tr) {
                    // post table's data to Submit form using Json Format                    
                    if (cnt != rowCnt_Customer) {
                        var CustCode = $("input[name='txtEmpGroupDesc']", this).val();
                        var DealerCode = $("input[name='txtCustomerCode']", this).val();
                        if (CustCode == "" && DealerCode == "") {
                            $(this).remove();
                        }
                    }

                    rowCnt_Customer++;
                });
            }

            var lineNum = 1;
            $('#gvDALDaysValidation > tbody > tr').each(function (row, tr) {
                $(".txtSrNo", this).text(lineNum);
                lineNum++;
            });

        }

        function ClearDealerRow(row) {

            var rowCnt_Customer = 1;
            var cnt = 0;

            $('#gvDALDaysValidation > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format
                var EmpCode = $("input[name='txtEmpGroupDesc']", this).val();
                var CustCode = $("input[name='txtCustomerCode']", this).val();
                if (CustCode == "" && EmpCode == "") {
                    //$(this).remove();
                }
                cnt++;

                rowCnt_Customer++;
            });

            if (cnt > 1) {
                var rowCnt_Customer = 1;
                $('#gvDALDaysValidation > tbody > tr').each(function (row1, tr) {
                    // post table's data to Submit form using Json Format                    
                    if (cnt != rowCnt_Customer) {
                        var EmpCode = $("input[name='txtEmpGroupDesc']", this).val();
                        var CustCode = $("input[name='txtCustomerCode']", this).val();
                        if (EmpCode == "" && CustCode == "") {
                            $(this).remove();
                        }
                    }
                    rowCnt_Customer++;
                });
            }

            var lineNum = 1;
            $('#gvDALDaysValidation > tbody > tr').each(function (row, tr) {
                $(".txtSrNo", this).text(lineNum);
                lineNum++;
            });
        }

        function GetEmployeeDetailsByCode(CustCode, row) {

            var CustID = CustCode.split("-").pop().trim();

            var rowCnt_Material = 1;
            var cnt = 0;
            var errRow = 0;

            $('#gvDALDaysValidation  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format
                var Item = $("input[name='txtEmpGroupDesc']", this).val();
                var CustItem = $("input[name='txtCustomerCode']", this).val();

                if (Item != undefined && Item != "" && CustItem != undefined && CustItem != "") {
                    Item = Item.split("-").pop().trim();
                    var LineNum = $("input[name='hdnLineNum']", this).val();
                    if (CustID != "") {
                        if (parseInt(row) != parseInt(LineNum)) {
                            if (Item == CustID) {
                                cnt = 1;
                                errRow = row;
                                return false;
                            }
                        }
                    }
                    rowCnt_Material++;
                }
            });

            if (cnt == 1) {
                return false;
            }
            else {
                var EmpID = $('#txtEmpGroupDesc' + row).val() != "" ?$('#txtEmpGroupDesc' + row).val().split('-').pop().trim() : 0;
                var CustomerID = $('#txtCustomerCode' + row).val() != "" ? $('#txtCustomerCode' + row).val().split('-').pop().trim() : 0;

                $.ajax({
                    url: 'EmployeeDALDays.aspx/GetEmployeeDetail',
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    contentType: 'application/json; charset=utf-8',
                    data: JSON.stringify({ EmpID: EmpID, CustomerID: parseFloat(CustomerID) }),
                    success: function (result) {
                        if (result == "") {
                            return false;
                        }
                        else if (result.d.indexOf("ERROR=") >= 0) {
                            var ErrorMsg = result.d[0].split('=')[1].trim();
                            ModelMsg(ErrorMsg, 3);
                            $("input[name='txtEmpGroupDesc']", this).val() == "";
                            $("input[name='txtCustomerCode']", this).val() == "";
                            return false;
                        }
                        else {
                            $('#txtTDays' + row).val(result.d[0].Days);
                            $('#tdCreateBy' + row).text(result.d[0].CreatedBy);
                            $('#tdCreateOn' + row).text(result.d[0].CreatedDate);
                            $('#tdUpdateBy' + row).text(result.d[0].UpdatedBy);
                            $('#tdUpdateOn' + row).text(result.d[0].UpdatedDate);
                            $('#hdnEmpID' + row).val(result.d[0].EmpID);
                            $('#hdnCustomerID' + row).val(result.d[0].CutomerID);
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        alert('Something is wrong...' + XMLHttpRequest.responseText);
                        return false;
                    }
                });
            }

            $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);
        }

        function btnSubmit_Click() {

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

            var IsValid = true;

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();

            if (!IsValid) {
                $.unblockUI();
                return false;
            }

            var TableData_Customer = [];

            var totalItemcnt = 0;
            var cnt = 0;

            rowCnt_Customer = 0;

            $('#gvDALDaysValidation  > tbody > tr').each(function (row, tr) {
                var CustCode = $("input[name='txtEmpGroupDesc']", this).val();
                var DealerCode = $("input[name='txtCustomerCode']", this).val();
                //if (CustCode != "" || DealerCode != "") {
                totalItemcnt = 1;
                var EmpID = $("input[name='txtEmpGroupDesc']", this).val().split('-').pop().trim();
                var CustomerID = $("input[name='txtCustomerCode']", this).val().split('-').pop().trim();
                var IsChange = $("input[name='IsChange']", this).val().trim();
                var EmpdID = $("input[name='hdnEmpdID']", this).val().trim();
                var TDays = $("input[name='txtTDays']", this).val();

                var obj = {
                    EmpID: EmpID,
                    CustomerID: CustomerID,
                    EmpdID: EmpdID,
                    EmpCode: CustCode,
                    TDays: TDays,
                    IsChange: IsChange,
                };
                TableData_Customer.push(obj);
                //}
                rowCnt_Customer++;
                
                if (EmpID != 0 || CustomerID != 0) {
                    if (TDays == "") {
                        ModelMsg("DAL process Days should not be blank at row : " + rowCnt_Customer, 3);
                        IsValid = false;
                    }
                }
            });

            if (totalItemcnt == 0) {
                $.unblockUI();
                ModelMsg("Please select atleast one Item", 3);
                return false;
            }
            if (cnt == 1) {
                $.unblockUI();
                ModelMsg(errormsg, 3);
                return false;
            }

            var CustomerData = JSON.stringify(TableData_Customer);

            var successMSG = true;
            if (IsValid) {
                var sv = $.ajax({
                    url: 'EmployeeDALDays.aspx/SaveData',
                    type: 'POST',
                    dataType: 'json',
                    data: JSON.stringify({ hidJsonInputCustomer: CustomerData }),
                    contentType: 'application/json; charset=utf-8'
                });

                var sendcall = 0;

                sv.success(function (result) {

                    if (result.d == "") {
                        $.unblockUI();
                        return false;
                    }
                    else if (result.d.indexOf("ERROR=") >= 0) {
                        $.unblockUI();
                        var ErrorMsg = result.d.split('=')[1].trim();
                        ModelMsg(ErrorMsg, 2);
                        return false;
                    }
                    else if (result.d.indexOf("WARNING=") >= 0) {
                        $.unblockUI();
                        var ErrorMsg = result.d.split('=')[1].trim();
                        ModelMsg(ErrorMsg, 3);
                        return false;
                    }
                    if (result.d.indexOf("SUCCESS=") >= 0) {
                        var SuccessMsg = result.d.split('=')[1].trim();
                        alert(SuccessMsg);
                        location.reload(true);
                        return false;
                    }
                });

                sv.error(function (XMLHttpRequest, textStatus, errorThrown) {
                    $.unblockUI();
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    return false;
                });
            }
            else {
                $.unblockUI();
            }
        }

    </script>

    <style type="text/css">
        .table > tbody > tr > td.txtSrNo {
            text-align: center;
            vertical-align: middle;
        }

        .dtbodyCenter {
            text-align: center;
        }

        .dtbodyLeft {
            text-align: left;
        }

        .dtbodyRight {
            text-align: right;
        }

        .ui-widget {
            font-size: 11px;
        }

        .HideColumn {
            display: none;
        }

        #gvDALDaysValidation td input {
            font-size: 10px;
            height: 30px;
        }

        html {
            overflow: hidden;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <input type="hidden" id="CountRowDALDaysDetail" />
            <div id="divCustEntry" class="divCustEntry" runat="server" style="max-height: 80vh; overflow-y: auto;">
                <table id="gvDALDaysValidation" class="table gvDALDaysValidation" border="1" tabindex="6" style="width: 100%; border-collapse: collapse; font-size: 10px;">
                    <thead>
                        <tr class="table-header-gradient">
                            <th style="width: 3%; text-align: center">Sr. No</th>
                            <th style="width: 22%">Employee Code & Name</th>
                            <th style="width: 25%">Dealer Code & Name</th>
                            <th style="width: 4%; text-align: right">Total DAL Days</th>
                            <th style="width: 7%; text-align: center">Created Date/Time</th>
                            <th style="width: 10%">Created By</th>
                            <th style="width: 7%; text-align: center">Updated Date/Time</th>
                            <th style="width: 10%">Updated By</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
            <input type="button" id="btnSubmit" name="btnSubmit" value="Submit" class="btnSubmit btn btn-default" onclick="btnSubmit_Click()" tabindex="18" />
            <asp:Button ID="btnCancel" runat="server" Text="Cancel" TabIndex="2" CssClass="btn btn-default" OnClick="btnCancelClick" UseSubmitBehavior="false" CausesValidation="false" />
        </div>
    </div>
</asp:Content>

