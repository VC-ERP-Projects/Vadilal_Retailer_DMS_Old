<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="ClaimPage.aspx.cs" Inherits="Sales_ClaimPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript" src="../Scripts/fixHeaderFooter.js"></script>
    <style>
        .req:after {
            content: "*";
            color: red;
        }

        .search {
            background-color: lightyellow;
        }

        table#tblMachineDetail {
            width: 100%;
            margin-top: 0px !important;
            margin-bottom: 0px !important;
            position: relative;
        }

            table#tblMachineDetail tbody {
                width: 100%;
            }

            table#tblMachineDetail thead tr {
                position: relative;
            }

            table#tblMachineDetail tfoot tr {
                position: relative;
            }

        .border-la {
            float: left;
            width: 100%;
            height: 1px;
            padding-right: 10px;
            background: #000;
        }
    </style>
    <script type="text/javascript">

        $(document).ready(function () {
            $("#tblMachineDetail").tableHeadFixer('60vh');
        });

    </script>
    <script type="text/javascript">

        var availableCustomer = [];

        $(document).ready(function () {
            $('#CountRowMachine').val(0);

            var today = '<%=DateTime.Now.ToShortDateString()%>';
            var lessday = '<%=DateTime.Now.AddDays(-1).ToShortDateString()%>';
            //$('#txtDocumentDate').val(today);

            $("#txtDocumentDate").datepicker({
                dateFormat: 'dd/MM/yy',
                changeMonth: true, changeYear: true,
                beforeShow: function () {
                    setTimeout(function () {
                        $('.ui-datepicker').css('z-index', 99999999999999);
                    }, 0);
                }
            });
            $('#txtDocumentDate').datepicker('option', 'minDate', lessday);
            $('#txtDocumentDate').datepicker('option', 'maxDate', today);

            FillData();

            AddMoreRowMachine();
        });

        function AddMoreRowMachine() {

            $('table#tblMachineDetail tr#NoROW').remove();  // Remove NO ROW

            /// Add Dynamic Row to the existing Table
            var ind = $('#CountRowMachine').val();
            ind = parseInt(ind) + 1;
            $('#CountRowMachine').val(ind);

            var str = "";
            str = "<tr id='trMachine" + ind + "'>"
                + "<td><input type='text' id='txtMachineNo" + ind + "' name='txtMachineNo' maxlength='50' class='form-control search' /></td>"
                + "<td><input type='text' id='txtFromDealer" + ind + "' name='txtFromDealer' maxlength='20' class='form-control search' /></td>"
                + "<td id='tdFromName" + ind + "' class='tdFromName'></td>"
                + "<td id='tdFromCity" + ind + "' class='tdFromCity'></td>"
                + "<td><input type='text' id='txtToDealer" + ind + "' name='txtToDealer' maxlength='20' class='form-control search' /></td>"
                 + "<td id='tdToName" + ind + "' class='tdToName'></td>"
                + "<td id='tdToCity" + ind + "' class='tdToCity'></td>"
                + "<td><input type='hidden' id='hdnLineNum" + ind + "' name='hdnLineNum' value='" + ind + "' /><input type='text' id='txtNetValue" + ind + "' name='txtNetValue' maxlength='7' value='0' class='form-control allownumericwithdecimal' onfocus='SetQtyDataFocus(this);' onblur='SetQtyDataBlur(this);' /></td>>/tr>";

            $('#tblMachineDetail > tbody').append(str);

            $("#txtFromDealer" + ind).autocomplete({
                source: availableCustomer,
                minLength: 0,
                scroll: true
            });

            $('#txtFromDealer' + ind).on('change keyup', function () {
                $('#tdFromName' + ind).text("");
                $('#tdFromCity' + ind).text("");
                if ($('#txtFromDealer' + ind).val() != "") {
                    if ($('#txtFromDealer' + ind).val().split('#').length == 3) {
                        $('#tdFromName' + ind).text($('#txtFromDealer' + ind).val().split('#')[1].trim());
                        $('#tdFromCity' + ind).text($('#txtFromDealer' + ind).val().split('#')[2].trim());
                    }
                }
            });

            $('#txtFromDealer' + ind).on('autocompleteselect', function (e, ui) {
                $('#txtFromDealer' + ind).val(ui.item.value);
                $('#tdFromName' + ind).text("");
                $('#tdFromCity' + ind).text("");
                if ($('#txtFromDealer' + ind).val() != "") {
                    if ($('#txtFromDealer' + ind).val().split('#').length == 3) {
                        $('#tdFromName' + ind).text($('#txtFromDealer' + ind).val().split('#')[1].trim());
                        $('#tdFromCity' + ind).text($('#txtFromDealer' + ind).val().split('#')[2].trim());
                    }
                }
            });

            $("#txtToDealer" + ind).autocomplete({
                source: availableCustomer,
                minLength: 0,
                scroll: true
            });

            $('#txtToDealer' + ind).on('change keyup', function () {
                $('#tdToName' + ind).text("");
                $('#tdToCity' + ind).text("");
                if ($('#txtToDealer' + ind).val() != "") {
                    if ($('#txtToDealer' + ind).val().split('#').length == 3) {
                        $('#tdToName' + ind).text($('#txtToDealer' + ind).val().split('#')[1].trim());
                        $('#tdToCity' + ind).text($('#txtToDealer' + ind).val().split('#')[2].trim());
                    }
                }
            });

            $('#txtToDealer' + ind).on('blur', function () {
                if ($('#txtToDealer' + ind).val().split('#').length == 3) {
                }
                else {

                    $.ajax({
                        url: 'ClaimPage.aspx/GetCustomerByCode',
                        type: 'POST',
                        dataType: 'json',
                        data: JSON.stringify({ Code: $('#txtToDealer' + ind).val() }),
                        contentType: 'application/json',
                        success: function (result) {

                            if (result.d.split('#').length == 3) {
                                $('#txtToDealer' + ind).val(result.d);
                                $('#tdToName' + ind).text(result.d.split('#')[1].trim());
                                $('#tdToCity' + ind).text(result.d.split('#')[2].trim());
                            }
                            else {
                                $('#txtToDealer' + ind).val("");
                            }
                        },
                        error: function (result) {
                            alert(result);
                        }
                    });
                }
            });

            $('#txtToDealer' + ind).on('autocompleteselect', function (e, ui) {
                $('#txtToDealer' + ind).val(ui.item.value);
                $('#tdToName' + ind).text("");
                $('#tdToCity' + ind).text("");
                if ($('#txtToDealer' + ind).val() != "") {
                    if ($('#txtToDealer' + ind).val().split('#').length == 3) {
                        $('#tdToName' + ind).text($('#txtToDealer' + ind).val().split('#')[1].trim());
                        $('#tdToCity' + ind).text($('#txtToDealer' + ind).val().split('#')[2].trim());
                    }
                }
            });

            $('#txtToDealer' + ind).on('change keyup', function () {
                $('#tdToName' + ind).text("");
                $('#tdToCity' + ind).text("");
                if ($('#txtToDealer' + ind).val() != "") {
                    if ($('#txtToDealer' + ind).val().split('#').length == 3) {
                        $('#tdToName' + ind).text($('#txtToDealer' + ind).val().split('#')[1].trim());
                        $('#tdToCity' + ind).text($('#txtToDealer' + ind).val().split('#')[2].trim());
                    }
                }
            });

            $('#txtMachineNo' + ind).on('blur', function (e, ui) {
                var txt = $('#txtMachineNo' + ind).val().trim();
                if (txt == "undefined" || txt == "") {
                    //ModelMsg("Enter machine Code Or Name", 3);
                    return false;
                }
                CheckDuplicatemachine($('#txtMachineNo' + ind).val().trim(), ind);
            });

            $('#txtMachineNo' + ind).on('change keyup', function () {
                if ($('#txtMachineNo' + ind).val() == "") {
                    ClearMachineRow(ind);
                }
            });

            $("#txtNetValue" + ind).on('change keyup paste', function (event) {
                CalculateSum();

            });

            // allow decimal values only
            $(".allownumericwithdecimal").keydown(function (e) {
                // Allow: backspace, delete, tab, escape, enter
                if ($.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190, 86, 67]) !== -1 ||
                    // Allow: Ctrl+A, Command+A
                    ((e.keyCode == 65 || e.keyCode == 86 || e.keyCode == 67) && (e.ctrlKey === true || e.metaKey === true)) ||
                    // Allow: home, end, left, right, down, up
                    (e.keyCode >= 35 && e.keyCode <= 40)) {
                    // let it happen, don't do anything

                    var myval = $(this).val();
                    if (myval != "") {
                        if (isNaN(myval)) {
                            $(this).val('');
                            e.preventDefault();
                            return false;
                        }
                    }

                    return;
                }
                // Ensure that it is a number and stop the keypress
                if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
                    e.preventDefault();
                }
            });
        }

        function CheckDuplicatemachine(machine, row) {

            var rowCnt_Machine = 1;
            var cnt = 0;
            var errRow = 0;

            $('#tblMachineDetail  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var machineCode = $("input[name='txtMachineNo']", this).val().trim();
                var LineNum = $("input[name='hdnLineNum']", this).val();
                //var isActive = $("input[name='txtisDeleteIDMachine']", this).val();

                //if (isActive == 'true') {
                if (machineCode != "") {
                    if (parseInt(row) != parseInt(LineNum)) {
                        if (machine == machineCode) {
                            cnt = 1;
                            errRow = row;
                            $('#txtMachineNo' + row).val('');
                            errormsg = 'Machine = ' + machineCode + ' is already seleted at row : ' + rowCnt_Machine;
                            return false;
                        }
                    }
                }
                //}

                rowCnt_Machine++;
            });

            if (cnt == 1) {
                $('#txtMachineNo' + row).val('');
                ClearMachineRow(row);
                ModelMsg(errormsg, 2);
                return false;
            }

            var ind = $('#CountRowMachine').val();
            if (ind == row) {
                AddMoreRowMachine();
            }

        }

        function ClearMachineRow(row) {
            var rowCnt_Machine = 1;
            var cnt = 0;
            $('#tblMachineDetail > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var machineCode = $("input[name='txtMachineNo']", this).val();
                if (machineCode == "") {
                    //$(this).remove();
                }
                cnt++;

                rowCnt_Machine++;
            });

            if (cnt > 1) {
                var rowCnt_Machine = 1;
                $('#tblMachineDetail > tbody > tr').each(function (row1, tr) {
                    // post table's data to Submit form using Json Format                    
                    if (cnt != rowCnt_Machine) {
                        var machineCode = $("input[name='txtMachineNo']", this).val();
                        if (machineCode == "") {
                            $(this).remove();
                            CalculateSum();
                        }
                    }

                    rowCnt_Machine++;
                });
            }

        }

        function btnSubmit_Click() {

            $("#btnSubmit").attr('disabled', 'disabled');

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
                $("#btnSubmit").removeAttr('disabled');
                return false;
            }

            if (IsValid) {
                if ($(".txtChallanDate").val() == "") {
                    $.unblockUI();
                    $("#btnSubmit").removeAttr('disabled');
                    ModelMsg("Please Enter Challan Date", 2);
                    event.preventDefault();
                    return false;
                }
            }

            var TableData_Machine = [];
            var rowCnt_Material = 0;
            var totalItemcnt = 0;
            var cnt = 0;
            $('#tblMachineDetail  > tbody > tr').each(function (row, tr) {

                var machinecode = $("input[name='txtMachineNo']", this).val();
                if (machinecode != "") {

                    totalItemcnt = 1;

                    var fromdealer = $("input[name='txtFromDealer']", this).val().split("#")[0];
                    if (fromdealer == "") {
                        cnt = 1;
                        errormsg = 'Please enter From Dealer in Row: ' + (parseInt(rowCnt_Material) + 1);
                        return false;
                    }

                    var todealer = $("input[name='txtToDealer']", this).val().split("#")[0];
                    if (todealer == "") {
                        cnt = 1;
                        errormsg = 'Please enter To Dealer in Row: ' + (parseInt(rowCnt_Material) + 1);
                        return false;
                    }

                    if (todealer == fromdealer) {
                        cnt = 1;
                        errormsg = 'Please select diffrent from - to dealers: ' + (parseInt(rowCnt_Material) + 1);
                        return false;
                    }

                    var netvalue = $("input[name='txtNetValue']", this).val().split("#")[0];
                    if (netvalue == "" || netvalue == "0") {
                        cnt = 1;
                        errormsg = 'Please enter Net Value in Row: ' + (parseInt(rowCnt_Material) + 1);
                        return false;
                    }

                    var obj = {
                        MachineNo: machinecode,
                        FromDealer: fromdealer,
                        ToDealer: todealer,
                        NetValue: netvalue
                    };

                    TableData_Machine.push(obj);
                }
                rowCnt_Material++;
            });

            if (totalItemcnt == 0) {
                $.unblockUI();
                $("#btnSubmit").removeAttr('disabled');
                ModelMsg("Please select atleast one Item", 2);
                event.preventDefault();
                return false;
            }

            if (cnt == 1) {
                $.unblockUI();
                $("#btnSubmit").removeAttr('disabled');
                ModelMsg(errormsg, 2);
                event.preventDefault();
                return false;
            }

            var postData = {
                txtDocumentDate: $("#txtDocumentDate").val(),
                txtVehicleNo: $("#txtVehicleNo").val(),
                txtTransporterName: $("#txtTransporterName").val(),
                txtLRNo: $("#txtLRNo").val(),
                txtLRDate: $("#txtLRDate").val(),
                txtAmount: $("#txtAmount").val(),
                txtChallanNo: $("#txtChallanNo").val(),
                txtChallanDate: $("#txtChallanDate").val()
            };

            $.ajax({
                url: 'ClaimPage.aspx/SaveData',
                type: 'POST',
                dataType: 'json',
                data: JSON.stringify({ tabledata_machine: JSON.stringify(TableData_Machine), postdata: JSON.stringify(postData) }),
                contentType: 'application/json; charset=utf-8',
                success: function (result) {
                    if (result.d == "") {
                        $.unblockUI();
                        $("#btnSubmit").removeAttr('disabled');
                        return false;
                    }
                    else if (result.d.indexOf("ERROR=") >= 0) {
                        $.unblockUI();
                        $("#btnSubmit").removeAttr('disabled');
                        var ErrorMsg = result.d.split('=')[1].trim();
                        ModelMsg(ErrorMsg, 2);
                        return false;
                    }
                    if (result.d.indexOf("SUCCESS=") >= 0) {
                        var SuccessMsg = result.d.split('=')[1].trim();
                        alert(SuccessMsg);
                        location.reload(true);
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    $.unblockUI();
                    $("#btnSubmit").removeAttr('disabled');
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    return false;
                }
            });

            return false;
        }

        function FillData() {
            $.ajax({
                url: 'ClaimPage.aspx/LoadData',
                type: 'POST',
                dataType: 'json',
                async: false,
                contentType: 'application/json; charset=utf-8',
                success: function (result) {

                    if (result.d == "") {
                        return false;
                    }
                    else if (result.d[0].indexOf("ERROR#") >= 0) {
                        var ErrorMsg = result.d[0].split('#')[1].trim();
                        ModelMsg(ErrorMsg, 3);
                        var today = '<%=DateTime.Now.ToShortDateString()%>';

                        $('#txtDate').val(today);
                        return false;

                    }
                    else {

                        var customer = result.d[0];
                        availableCustomer = [];

                        for (var i = 0; i < customer.length; i++) {
                            availableCustomer.push(customer[i]);
                        }
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    return false;
                }
            });
    }

    function CalculateSum() {

        var Total = 0;
        $('#tblMachineDetail  > tbody > tr').each(function (row, tr) {
            if ($(tr).find("input[name='txtNetValue']", this).val() != "")
                Total += parseFloat($(tr).find("input[name='txtNetValue']", this).val());
        });

        $("#txtAmount").val(Total.toFixed(2));
    }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel" style="margin-top: 45px; margin-left: 18px;">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <span class="input-group-addon">Document Date</span>
                        <input type="text" id="txtDocumentDate" class="datepick form-control" onkeyup="return ValidateDate(this);" tabindex="1" />
                    </div>
                    <div class="input-group form-group">
                        <span class="input-group-addon">Vehicle No</span>
                        <input type="text" id="txtVehicleNo" name="txtVehicleNo" class="form-control" tabindex="2" data-bv-notempty="true" data-bv-notempty-message="Field is required" />
                    </div>
                    <div class="input-group form-group">
                        <span class="input-group-addon">Transporter Name</span>
                        <input type="text" id="txtTransporterName" name="txtTransporterName" class="form-control" tabindex="3" data-bv-notempty="true" data-bv-notempty-message="Field is required" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <label class="input-group-addon">L.R.No</label>
                        <input type="text" id="txtLRNo" class="form-control" tabindex="4" maxlength="100" />
                    </div>
                    <div class="input-group form-group">
                        <span class="input-group-addon">L.R.Date</span>
                        <input type="text" id="txtLRDate" class="datepick form-control" onkeyup="return ValidateDate(this);" tabindex="5" />
                    </div>
                    <div class="input-group form-group">
                        <span class="input-group-addon">Amount</span>
                        <input type="text" id="txtAmount" class="form-control" tabindex="6" disabled="disabled" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <span class="input-group-addon">Challan No</span>
                        <input type="text" id="txtChallanNo" name="txtChallanNo" class="form-control" tabindex="7" data-bv-notempty="true" data-bv-notempty-message="Field is required" maxlength="100" />
                    </div>
                    <div class="input-group form-group">
                        <span class="input-group-addon">Challan Date</span>
                        <input type="text" id="txtChallanDate" name="txtChallanDate" class="datepick txtChallanDate form-control" onkeyup="return ValidateDate(this);" tabindex="8" />
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <input type="hidden" id="CountRowMachine" />
                    <div class="border-la">&nbsp;</div>
                    <table id="tblMachineDetail" class="table" border="1" tabindex="9" style="font-size: 11px;">
                        <thead>
                            <tr class="table-header-gradient">
                                <th style="width: 14%;">Machine Number</th>
                                <th style="width: 10%">From Dealer Code</th>
                                <th style="width: 21%;">From Dealer Name</th>
                                <th style="width: 8%;">From Dealer City</th>
                                <th style="width: 10%;">To Dealer Code</th>
                                <th style="width: 21%;">To Dealer Name</th>
                                <th style="width: 8%;">To Dealer City</th>
                                <th style="width: 8%;">Net Value</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
            </div>
            <br />
            <br />
            <input type="submit" value="Save" class="btn btn-default" tabindex="10" id="btnSubmit" onclick="return btnSubmit_Click();" />
            <input type="submit" value="Cancel" id="btnCancel" class="btn btn-default" tabindex="11" onclick="btnCancel_Click();" />
        </div>
    </div>
</asp:Content>

