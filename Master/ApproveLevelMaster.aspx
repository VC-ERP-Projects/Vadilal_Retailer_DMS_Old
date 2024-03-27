<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="ApproveLevelMaster.aspx.cs" Inherits="Master_ApproveLevelMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />
    <script type="text/javascript" src="../Scripts/colorbox/jquery.colorbox-min.js"></script>
    <script type="text/javascript" src="../Scripts/fixHeaderFooter.js"></script>

    <style>
        .req:after {
            content: "*";
            color: red;
        }

        .search {
            background-color: lightyellow;
        }

        table#tblLevelDetail {
            width: 100%;
            margin-top: 0px !important;
            margin-bottom: 0px !important;
            position: relative;
        }

            table#tblLevelDetail tbody {
                width: 100%;
            }

            table#tblLevelDetail thead tr {
                position: relative;
            }

            table#tblLevelDetail tfoot tr {
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
            $("#tblLevelDetail").tableHeadFixer('60vh');
        });

    </script>

    <script type="text/javascript">

        var availableEmployee = [];

        $(document).ready(function () {
            $('#CountRowMaterial').val(0);

            $("#txtDate").datepicker({
                dateFormat: 'dd/MM/yy',
                changeMonth: true, changeYear: true,
                yearRange: "2000:2090",
                beforeShow: function () {
                    setTimeout(function () {
                        $('.ui-datepicker').css('z-index', 99999999999999);
                    }, 0);
                }
            }).on("change", function (e) { FillData(); });
            var today = '<%=DateTime.Now.ToShortDateString()%>';
            $('#txtDate').val(today);
            FillData();
            AddMoreRowMaterial();
        });

        function FillData() {
            $.ajax({
                url: 'ApproveLevelMaster.aspx/LoadData',
                type: 'POST',
                dataType: 'json',
                async: false,
                contentType: 'application/json; charset=utf-8',
                success: function (result) {

                    if (result.d == "") {
                        event.preventDefault();
                        return false;
                    }
                    else if (result.d[0].indexOf("ERROR#") >= 0) {
                        var ErrorMsg = result.d[0].split('#')[1].trim();
                        ModelMsg(ErrorMsg, 3);
                        event.preventDefault();
                        var today = '<%=DateTime.Now.ToShortDateString()%>';
                        $('#txtDate').val(today);
                        return false;

                    }
                    else {

                        var Employee = result.d[0];

                        availableEmployee = [];

                        for (var i = 0; i < Employee.length; i++) {
                            availableEmployee.push(Employee[i]);
                        }

                        $("#AutoEmp").autocomplete({
                            source: availableEmployee,
                            minLength: 0,
                            scroll: true
                        });
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    event.preventDefault();
                    return false;
                }
            });
    }

    function FillOrder() {
        var cnt = 1;
        $("#tblLevelDetail > tbody > tr").each(function () {
            if (cnt > 0) {
                $(this).remove();       // remove other rows except first row.
            }
            cnt++;
        });
        $('#CountRowMaterial').val(0);
        var Menuid = $('.ddlRequestType').val();
        $.ajax({
            url: 'ApproveLevelMaster.aspx/GetDetail',
            type: 'POST',
            dataType: 'json',
            async: false,
            contentType: 'application/json; charset=utf-8',
            data: JSON.stringify({ strMenuid: Menuid }),

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
                        $('#txtLvlNo' + cnt).val(result.d[0][i].LevelNo);
                        $('#AutoEmp' + cnt).val(result.d[0][i].EmpName);
                        $('#chckIsManager' + cnt).prop('checked', result.d[0][i].IsManager);
                        $('#txtEscDays' + cnt).val(result.d[0][i].EscDays);
                        $('#chckIsMandatoy' + cnt).prop('checked', result.d[0][i].Mandatory);
                        $('#chckIsAsk' + cnt).prop('checked', result.d[0][i].IsAsk);
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

    function btnSubmit_Click(print) {
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
            event.preventDefault();
            return false;
        }

        var TableData_Material = [];

        var totalItemcnt = 0;
        var cnt = 0;
        rowCnt_Material = 0;

        $('#tblLevelDetail  > tbody > tr').each(function (row, tr) {
            totalItemcnt = 1;
            var LvlNo = $("input[name='txtLvlNo']", this).val();
            var AutoEmp = $("input[name='AutoEmp']", this).val();
            var IsManager = $("input[name='chckIsManager']", this).is(':checked');
            var IsAsk = $("input[name='chckIsAsk']", this).is(':checked');
            var EscDays = $("input[name='txtEscDays']", this).val();
            var IsMandatoy = $("input[name='chckIsMandatoy']", this).is(':checked');

            var obj = {
                LvlNo: LvlNo,
                AutoEmp: AutoEmp,
                IsManager: IsManager,
                EscDays: EscDays,
                IsMandatoy: IsMandatoy,
                IsAsk: IsAsk,
            };
            TableData_Material.push(obj);
            rowCnt_Material++;
        });

        if (totalItemcnt == 0) {
            $.unblockUI();
            $("#btnSubmit").removeAttr('disabled');
            ModelMsg("Please select atleast one Item", 3);
            event.preventDefault();
            return false;
        }
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

        var RequestType = $(".ddlRequestType").val();
        var Date = '<%=DateTime.Now.ToShortDateString()%>';
        var postData = {
            RequestType: RequestType,
            Date: Date
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
                url: 'ApproveLevelMaster.aspx/SaveData',
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

    function RemoveMaterialRow(row) {
        $('table#tblLevelDetail tr#trMaterial' + row).remove();
        $('table#tblLevelDetail tr#trMaterial' + (row + 1)).focus();

        var lineNum = 0;
        $('#tblLevelDetail > tbody > tr').each(function (row, tr) {
            $("input[name^='hdnLineNum']", this).val(lineNum);
            lineNum++;
            $("input[name^='txtLvlNo']", this).val(lineNum);
        });
    }

    function AddMoreRowMaterial() {

        $('table#tblLevelDetail tr#NoROW').remove();  // Remove NO ROW
        /// Add Dynamic Row to the existing Table
        var ind = $('#CountRowMaterial').val();
        ind = parseInt(ind) + 1;
        $('#CountRowMaterial').val(ind);

        var str = "";
        str = "<tr id='trMaterial" + ind + "'>"
            + "<td><input type='text'  disabled id='txtLvlNo" + ind + "' name='txtLvlNo' class='txtLvlNo form-control allownumericwithdecimal' /></td>"
            + "<td><input type='text' id='AutoEmp" + ind + "' name='AutoEmp' class='form-control search' /></td>"
            + "<td><input type='checkbox' id='chckIsManager" + ind + "' name='chckIsManager' class='form-control '/></td>"
            + "<td style='display:none;'><input type='checkbox' id='chckIsAsk" + ind + "' name='chckIsAsk'class='form-control'/></td>"
            + "<td><input type='text' id='txtEscDays" + ind + "' name='txtEscDays' class='form-control allownumericwithdecimal' /></td>"
            + "<td><input type='checkbox' id='chckIsMandatoy" + ind + "' name='chckIsMandatoy'class='form-control'/></td>"
            + "<td><input type='image' id='btnDelete" + ind + "' name='btnDelete' src='../Images/delete2.png'  style='width:30px;' onclick='RemoveMaterialRow(" + ind + ");' /></td>"
            //+ "<td><input type='button id='btnDelete" + ind + "' name='btnDelete' value='Delete' class='btn btn-default' style='width:8px' onclick='RemoveMaterialRow(" + ind + ");' /></td>"
            + "<input type='hidden' id='hdnLineNum" + ind + "' name='hdnLineNum' value='" + ind + "' />"
            + "<input type='text' id='txtDeleteFlag" + ind + "' name='txtDeleteFlag' style='display:none' value='false' />"

        $('#tblLevelDetail > tbody').append(str);

        $("#AutoEmp" + ind).autocomplete({
            source: availableEmployee,
            minLength: 0,
            scroll: true
        });

        var lineNum = 0;
        $('#tblLevelDetail > tbody > tr').each(function (row, tr) {
            $("input[name^='hdnLineNum']", this).val(lineNum);
            lineNum++;
            $("input[name^='txtLvlNo']", this).val(lineNum);
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
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <input type="hidden" id="hdnSchemeApply" value="0" class="hdnSchemeApply" />
    <div class="panel panel-default" style="margin-top: 45px; margin-left: 18px;">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Date</label>
                        <input type="text" id="txtDate" name="txtDate" disabled="disabled" class="datepick form-control" onkeyup="return ValidateDate(this);" tabindex="1" />
                        <input type="hidden" id="hidJsonInputMaterial" name="hidJsonInputMaterial" value="" />
                        <input type="hidden" id="hidJsonOrderDetail" name="hidJsonOrderDetail" value="" />
                        <input type="hidden" id="hidJsonInputHeader" name="hidJsonInputHeader" value="" />

                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblIsDetail" runat="server" Text="Request For" class="input-group-addon" />
                        <asp:DropDownList ID="ddlRequestType" class="ddlRequestType" runat="server" CssClass="ddlRequestType form-control" onchange="FillOrder();">
                            <asp:ListItem Text="---Select---" Value="0" Selected="True" />
                            <asp:ListItem Text="Assest" Value="9112"></asp:ListItem>
                            <asp:ListItem Text="Expense" Value="9120"></asp:ListItem>
                            <asp:ListItem Text="Travel" Value="9121"></asp:ListItem>
                            <asp:ListItem Text="Leave" Value="9114"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <input type="hidden" id="CountRowMaterial" />
                        <input type="button" id="btnAddMoreMaterial" name="btnAddMoreMaterial" value="Add Row" onclick="AddMoreRowMaterial();" class="btn btn-default" />
                    </div>
                </div>

            </div>
            <ul id="tabs" class="nav nav-tabs" role="tablist">
                <li class="active"><a href="#tabs-1" tabindex="10" role="tab" data-toggle="tab">Levels</a></li>
            </ul>
            <div id="myTabContent" class="tab-content">
                <div id="tabs-1" class="tab-pane active" tabindex="9">
                    <br />
                    <div id="Material" class="tab-pane">
                        <div class="row" style="display: none">
                            <%--<div class="col-lg-1">
                                <div class="input-group form-group">
                                    <input type="hidden" id="CountRowMaterial" />
                                    <input type="button" id="btnAddMoreMaterial" name="btnAddMoreMaterial" value="Add Row" onclick="AddMoreRowMaterial();" class="btn btn-default" />
                                </div>
                            </div>--%>
                            <div class="col-lg-11">
                                <div class="input-group form-group" style="width: 100%">
                                    <input type="text" id="txtSearchMaterial" data-val="false" class="form-control" placeholder="Type to Search" style="background-image: url('../Images/Search.png'); background-position: right; background-repeat: no-repeat; width: 100%" />
                                </div>
                            </div>
                        </div>
                        <div class="border-la">&nbsp;</div>
                        <table id="tblLevelDetail" class="table" border="1" tabindex="10">
                            <thead>
                                <tr class="table-header-gradient">
                                    <th style="width: 8%;">Level Number</th>
                                    <th style="width: 20%">Approval</th>
                                    <th style="width: 6%;">Is Manager</th>
                                    <th style="width: 6%; display: none;">Is Ask</th>
                                    <th style="width: 8%;">Escalation Days</th>
                                    <th style="width: 6%;">Mandatory</th>
                                    <th style="width: 5%">Delete</th>
                                    <th style="display: none">ID</th>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <br />
            <input type="submit" value="Save" class="btn btn-default" tabindex="26" id="btnSubmit" onclick="return btnSubmit_Click('0');" />
            <input type="submit" value="Cancel" id="btnCancel" class="btn btn-default" tabindex="28" onclick="btnCancel_Click();" />
        </div>
    </div>
</asp:Content>


