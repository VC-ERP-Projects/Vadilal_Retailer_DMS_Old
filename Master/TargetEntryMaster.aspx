<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="TargetEntryMaster.aspx.cs" Inherits="Master_TargetEntryMaster" %>

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

        table#tblTargetDetail {
            width: 100%;
            margin-top: 0px !important;
            margin-bottom: 0px !important;
            position: relative;
        }

            table#tblTargetDetail tbody {
                width: 100%;
            }

            table#tblTargetDetail thead tr {
                position: relative;
            }

            table#tblTargetDetail tfoot tr {
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

        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }

        $(function () {
            $("#tblTargetDetail").tableHeadFixer('80vh');
            $('#CountRowMaterial').val(0);
            AddMoreRowMaterial();

            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
        }

        function RemoveMaterialRow(row) {
            $('table#tblTargetDetail tr#trMaterial' + row).remove();
            $('table#tblTargetDetail tr#trMaterial' + (row + 1)).focus();

            var lineNum = 0;
            $('#tblTargetDetail > tbody > tr').each(function (row, tr) {
                $("input[name^='hdnTargetID']", this).val(lineNum);
                lineNum++;
                $("input[name^='txtSr']", this).val(lineNum);
            });
        }

        function AddMoreRowMaterial() {

            $('table#tblTargetDetail tr#NoROW').remove();  // Remove NO ROW
            /// Add Dynamic Row to the existing Table
            var ind = $('#CountRowMaterial').val();
            ind = parseInt(ind) + 1;
            $('#CountRowMaterial').val(ind);

            var str = "";
            str = "<tr id='trMaterial" + ind + "'>"
                + "<td id='txtSr" + ind + "'>" + ind + "</td>"
                + "<td><input type='text' id='txtMonthYear" + ind + "' name='txtMonthYear' class='onlymonth form-control datepicker' /></td>"
                + "<td><input type='text' id='txtTargtAmt" + ind + "' name='txtTargtAmt' class='form-control allownumericwithdecimal' /></td>"
                + "<td id='txtUpdatedBy" + ind + "'></td>"
                + "<td id='txtUpdatedDate" + ind + "'></td>"
                + "<input type='hidden' id='hdnTargetID" + ind + "' name='hdnTargetID' value='" + ind + "' />"

            $('#tblTargetDetail > tbody').append(str);

            $("#txtMonthYear" + ind).datepicker({
                dateFormat: 'mm/yy', showButtonPanel: true, changeYear: true, changeMonth: true,
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, 3));
                },
                beforeShow: function () {
                    setTimeout(function () {
                        $('.ui-datepicker').css('z-index', 99999999999999);
                        var popup = $(this).offset();
                        var popupTop = popup.top - 40;
                        $('.ui-datepicker').css('top', popupTop);

                    }, 0);
                }
            });

            $("#txtMonthYear" + ind).on('focus blur click', function () {
                $(".ui-datepicker-calendar").hide();

            });

            var lineNum = 0;
            $('#tblTargetDetail > tbody > tr').each(function (row, tr) {
                $("input[name^='hdnTargetID']", this).val(lineNum);
                lineNum++;
                $("input[name^='txtSr']", this).val(lineNum);
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

        function Submit(print) {

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
                event.preventDefault();
                return false;
            }

            var TableData_Material = [];

            var totalItemcnt = 0;
            var cnt = 0;
            rowCnt_Material = 0;

            $('#tblTargetDetail  > tbody > tr').each(function (row, tr) {
                totalItemcnt = 1;
                var MonthYear = $("input[name='txtMonthYear']", this).val();
                var TargetAmt = $("input[name='txtTargtAmt']", this).val();

                var obj = {
                    MonthYear: MonthYear,
                    TargetAmt: TargetAmt
                };
                TableData_Material.push(obj);
                rowCnt_Material++;
            });

            if (cnt == 1) {
                $.unblockUI();
                $("#btnSubmit").removeAttr('disabled');
                ModelMsg(errormsg, 3);
                event.preventDefault();
                return false;
            }

            $('#hidJsonInputMaterial').val(JSON.stringify(TableData_Material));

            var totalItemcnt = 0;
            cnt = 0;

            var Division = $(".ddlDivision").val();
            var Emp = $(".txtCode").val().split("-").pop().trim();
            var postData = {
                Division: Division,
                Emp: Emp
            }
            $('#hidJsonInputHeader').val(JSON.stringify(postData));
            var HeaderData = $('#hidJsonInputHeader').val();

            var successMSG = false;
            var MaterialData = $('#hidJsonInputMaterial').val();
            var successMSG = true;

            if (successMSG == false) {
                $.unblockUI();
                $("#btnSubmit").removeAttr('disabled');
                event.preventDefault();
                return false;
            }
            else {
                var successMSG = true;
                var sv = $.ajax({
                    url: 'TargetEntryMaster.aspx/SaveData',
                    type: 'POST',
                    dataType: 'json',
                    data: JSON.stringify({ hidJsonInputMaterial: MaterialData, hidJsonInputHeader: HeaderData }),
                    contentType: 'application/json; charset=utf-8'
                });

                var sendcall = 0;
                sv.success(function (result) {
                    if (result.d == "") {
                        $.unblockUI();
                        $("#btnSubmit").removeAttr('disabled');
                        event.preventDefault();
                        return false;
                    }
                    else if (result.d.indexOf("ERROR=") >= 0) {
                        $.unblockUI();
                        $("#btnSubmit").removeAttr('disabled');
                        var ErrorMsg = result.d.split('=')[1].trim();
                        ModelMsg(ErrorMsg, 2);
                        event.preventDefault();
                        return false;
                    }
                    if (result.d.indexOf("SUCCESS=") >= 0) {
                        var SuccessMsg = result.d.split('=')[1].trim();
                        if (sendcall == 1) {
                            alert(SuccessMsg);
                            location.reload(true);
                            event.preventDefault();
                            return false;
                        }
                    }
                });

                sv.error(function (XMLHttpRequest, textStatus, errorThrown) {
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    event.preventDefault();
                    return false;
                });
            }

            if (sendcall == 0) {
                event.preventDefault();
                sendcall = 1;
                return false;
            }
        }

        function FillOrder() {
            var cnt = 1;
            $("#tblTargetDetail > tbody > tr").each(function () {
                if (cnt > 0) {
                    $(this).remove();       // remove other rows except first row.
                }
                cnt++;
            });
            $('#CountRowMaterial').val(0);
            var Division = $(".ddlDivision").val();
            var Emp = "";
            if ($(".txtCode").val() != "")
                Emp = $(".txtCode").val().split("-").pop().trim();

            $.ajax({
                url: 'TargetEntryMaster.aspx/GetDetail',
                type: 'POST',
                dataType: 'json',
                async: false,
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify({ strDivision: Division, strEmp: Emp }),

                success: function (result) {
                    if (result == "") {
                        //event.preventDefault();
                        return false;
                    }
                    else if (result.d[0].indexOf("ERROR=") >= 0) {
                        var ErrorMsg = result.d[0].split('=')[1].trim();
                        ModelMsg(ErrorMsg, 3);
                        //event.preventDefault();
                        return false;
                    }
                    else {
                        cnt = 1;
                        for (var i = 0; i < result.d[0].length; i++) {
                            AddMoreRowMaterial();
                            $('#txtMonthYear' + cnt).val(result.d[0][i].MonthYear);
                            $('#hdnTargetID' + cnt).val(result.d[0][i].OTRGID);
                            $('#txtTargtAmt' + cnt).val(result.d[0][i].TargetAmount);
                            $('#txtUpdatedBy' + cnt).text(result.d[0][i].UpdatedBy);
                            $('#txtUpdatedDate' + cnt).text(result.d[0][i].UpdatedDate);
                            cnt++;
                        }
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    event.preventDefault();
                    return false;
                }
            });
        }
        function downloadTargetEntry() {
            window.open("../Document/CSV Formats/TargetEntryUploadFormat.csv");
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body ">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Code" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" CssClass="txtCode form-control search" data-bv-notempty="true" data-bv-notempty-message="Field is required" onchange="FillOrder();"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceHierarchyEmp" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Division" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlDivision" TabIndex="9" CssClass="form-control ddlDivision" DataTextField="DivisionName" DataValueField="DivisionlID" onchange="FillOrder();">
                        </asp:DropDownList>
                        <input type="hidden" id="hidJsonInputMaterial" name="hidJsonInputMaterial" value="" />
                        <input type="hidden" id="hidJsonInputHeader" name="hidJsonInputHeader" value="" />

                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <input type="hidden" id="CountRowMaterial" />
                        <input type="button" id="btnAddMoreMaterial" name="btnAddMoreMaterial" value="Add Row" onclick="AddMoreRowMaterial();" class="btn btn-default" />
                        &nbsp;
                        <input type="button" id="btnSubmit" name="btnSubmit" value="Submit" onclick="Submit();" class="btn btn-default" />
                    </div>

                </div>
            </div>
            <div class="row _masterForm">
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label runat="server" Text="Target Entry" Font-Bold="true" ID="lblTentry" CssClass="input-group-addon"></asp:Label>
                        <asp:FileUpload ID="flTargetEntry" runat="server" CssClass="form-control" />
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Button ID="btnTargetEntryUpload" runat="server" Text="Upload Target Entry" OnClientClick="return confirm('Are you sure want to upload Target Entry Data?');" OnClick="btnTargetEntryUpload_Click" CssClass="btn btn-default" Style="display: inline" />
                        &nbsp; &nbsp; &nbsp; &nbsp;
                        <asp:Button ID="btnTargetEntryDownload" runat="server" Text="Download Target Entry Format" CssClass="btn btn-default" OnClientClick="downloadTargetEntry(); return false;" />
                    </div>
                </div>
            </div>
            <div class="border-la">&nbsp;</div>
            <table id="tblTargetDetail" class="table" border="1" tabindex="10">
                <thead>
                    <tr class="table-header-gradient">
                        <th style="width: 4%;">Sr. No</th>
                        <th style="width: 10%;">Month / Year</th>
                        <th style="width: 10%">Target Amount</th>
                        <th style="width: 20%">Updated By</th>
                        <th style="width: 20%">Updated Date</th>
                    </tr>
                </thead>
                <tbody>
                </tbody>
            </table>
        </div>
    </div>
</asp:Content>

