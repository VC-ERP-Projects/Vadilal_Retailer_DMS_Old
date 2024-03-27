<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="EmpStoreLocMapping.aspx.cs" Inherits="Master_EmpStoreLocMapping" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        var availableEmployee = [];
        var availablePlant = [];
        var availableStoreLoc = [];

        var UserID = '<% =UserID%>';
        $(document).ready(function () {
            $('#CountRowMaterial').val(0);
            FillData();
            AddMoreRowMaterial();

            $(".AutoPlant").change(function () {
                FillData();
            });
        });

        function RemoveMaterialRow(row) {
            $('table#tblEmpStoreLocMapping tr#trMaterial' + row).remove();
            $('table#tblEmpStoreLocMapping tr#trMaterial' + (row + 1)).focus();

            var lineNum = 0;
            $('#tblEmpStoreLocMapping > tbody > tr').each(function (row, tr) {
                lineNum++;
                $("input[name^='txtSrNo']", this).val(lineNum);
            });
        }

        function AddMoreRowMaterial() {

            $('table#tblEmpStoreLocMapping tr#NoROW').remove();  // Remove NO ROW
            /// Add Dynamic Row to the existing Table
            var ind = $('#CountRowMaterial').val();
            ind = parseInt(ind) + 1;
            $('#CountRowMaterial').val(ind);

            var str = "";
            str = "<tr id='trMaterial" + ind + "'>"
                + "<td><input type='text'  disabled id='txtSrNo" + ind + "' name='txtSrNo' class='txtSrNo form-control allownumericwithdecimal' /></td>"
                + "<td><input type='text' id='AutoStoreLoc" + ind + "' name='AutoStoreLoc' class='AutoStoreLoc form-control search' /></td>"
                + "<td><input type='checkbox' checked='true' id='chckActive" + ind + "' name='chckActive' class='form-control '/></td>"
                + "<td><input type='image' id='btnDelete" + ind + "' name='btnDelete' src='../Images/delete2.png'  style='width:30px;' onclick='RemoveMaterialRow(" + ind + ");' /></td></tr>"

            $('#tblEmpStoreLocMapping > tbody').append(str);

            $("#AutoStoreLoc" + ind).autocomplete({
                source: availableStoreLoc,
                minLength: 0,
                scroll: true
            });

            var lineNum = 0;
            $('#tblEmpStoreLocMapping > tbody > tr').each(function (row, tr) {
                lineNum++;
                $("input[name^='txtSrNo']", this).val(lineNum);
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

        function FillData() {
            var PlantID = $('.AutoPlant').val().split('-').pop().trim();

            $.ajax({
                url: 'EmpStoreLocMapping.aspx/LoadData',
                type: 'POST',
                dataType: 'json',
                data: JSON.stringify({ strPlantID: PlantID }),
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
                        return false;
                    }
                    else {

                        var Employee = result.d[0];
                        availableEmployee = [];
                        for (var i = 0; i < Employee.length; i++) {
                            availableEmployee.push(Employee[i]);
                        }
                        $(".AutoEmp").autocomplete({
                            source: availableEmployee,
                            minLength: 0,
                            scroll: true
                        });

                        $(".AutoStoreLoc").autocomplete({ source: [] });
                        $(".AutoStoreLoc").autocomplete("destroy");
                        var StoreLoc = result.d[1];
                        availableStoreLoc = [];
                        for (var i = 0; i < StoreLoc.length; i++) {
                            availableStoreLoc.push(StoreLoc[i]);
                        }
                        $(".AutoStoreLoc").autocomplete({
                            source: availableStoreLoc,
                            minLength: 0,
                            scroll: true
                        });

                        var Plant = result.d[2];
                        availablePlant = [];
                        for (var i = 0; i < Plant.length; i++) {
                            availablePlant.push(Plant[i]);
                        }
                        $(".AutoPlant").autocomplete({
                            source: availablePlant,
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

        function GetDetail() {
            var cnt = 1;
            $("#tblEmpStoreLocMapping > tbody > tr").each(function () {
                if (cnt > 0) {
                    $(this).remove();       // remove other rows except first row.
                }
                cnt++;
            });
            $('#CountRowMaterial').val(0);
            var EmpID = $('.AutoEmp').val().split('-').pop().trim();
            $.ajax({
                url: 'EmpStoreLocMapping.aspx/GetDetail',
                type: 'POST',
                dataType: 'json',
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify({ strEmpID: EmpID }),
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
                            $('#AutoStoreLoc' + cnt).val(result.d[0][i].StoreLoc);
                            $('#chckActive' + cnt).prop('checked', result.d[0][i].Active);
                            cnt++;
                        }
                        $('.txtCreatedBy').val(result.d[1]);
                        $('.txtCreatedTime').val(result.d[2]);
                        $('.txtUpdatedBy').val(result.d[3]);
                        $('.txtUpdatedTime').val(result.d[4]);
                        return false;
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    event.preventDefault();
                    return false;
                }
            });
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
                event.preventDefault();
                return false;
            }

            var TableData_Material = [];

            var totalItemcnt = 0;
            var cnt = 0;
            rowCnt_Material = 0;

            $('#tblEmpStoreLocMapping  > tbody > tr').each(function (row, tr) {
                totalItemcnt = 1;
                var StoreLocID = $("input[name='AutoStoreLoc']", this).val();
                var Active = $("input[name='chckActive']", this).is(':checked');

                var obj = {
                    StoreLocID: StoreLocID.split('-').pop().trim(),
                    Active: Active
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
            var EmpID = $('.AutoEmp').val().split('-').pop().trim();
            if (EmpID == '') {
                $.unblockUI();
                $("#btnSubmit").removeAttr('disabled');
                ModelMsg("Please Select Proper Employee", 3);
                event.preventDefault();
                return false;
            }

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
                    url: 'EmpStoreLocMapping.aspx/SaveData',
                    type: 'POST',
                    dataType: 'json',
                    data: JSON.stringify({ hidJsonInputMaterial: MaterialData, EmpId: EmpID }),
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
    </script>
    <style type="text/css">
        .ui-autocomplete .ui-menu-item a {
            font-size: 12px;
        }

        .table thead tr th {
            background: linear-gradient(to bottom, rgba(245,246,246,1) 0%,rgba(219,220,226,1) 3%,rgba(184,186,198,1) 59%,rgba(221,223,227,1) 100%,rgba(245,246,246,1) 100%);
            position: sticky;
            top: 0;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default" style="margin-top: 45px; margin-left: 18px;">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class=" col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="AutoEmp" runat="server" CssClass="AutoEmp form-control txtCode" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <input type="hidden" id="hidJsonInputMaterial" name="hidJsonInputMaterial" value="" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblPlant" runat="server" Text="Plant" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="AutoPlant" runat="server" CssClass="AutoPlant form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                    </div>
                </div>
                <div class=" col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-info" OnClientClick="GetDetail(); return false;" />
                        &nbsp;
                        <input type="hidden" id="CountRowMaterial" />
                        <input type="button" id="btnAddMoreMaterial" name="btnAddMoreMaterial" value="Add Row" onclick="AddMoreRowMaterial();" class="btn btn-default" />
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCreatedBy" runat="server" Text="Created By" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCreatedBy" Enabled="false" runat="server" CssClass="form-control txtCreatedBy" Style="font-size: small"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCreatedTime" runat="server" Text="Created Time" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCreatedTime" Enabled="false" runat="server" CssClass="form-control txtCreatedTime" Style="font-size: small"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblUpdatedBy" runat="server" Text="Updated By" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtUpdatedBy" Enabled="false" runat="server" CssClass="form-control txtUpdatedBy" Style="font-size: small"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblUpdatedtime" runat="server" Text="Updated Time" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtUpdatedTime" Enabled="false" runat="server" CssClass="form-control txtUpdatedTime" Style="font-size: small"></asp:TextBox>
                    </div>
                </div>
            </div>
            <div id="divEmpTable" class="divEmpTable" runat="server" style="max-height: 60vh; overflow-y: auto;">
                <table id="tblEmpStoreLocMapping" class="table" border="1" tabindex="10" style="width: 100%; border-collapse: collapse; font-size: 11px;">
                    <thead>
                        <tr class="table-header-gradient">
                            <th style="width: 2%;">Sr.No</th>
                            <th style="width: 25%">Plant # Storage Location</th>
                            <th style="width: 2%">Active</th>
                            <th style="width: 2%">Delete</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </div>
        <input type="submit" value="Save" class="btn btn-default" tabindex="26" id="btnSubmit" onclick="return btnSubmit_Click();" />
        <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-default" OnClick="btnCancel_Click" UseSubmitBehavior="false" CausesValidation="false" />
    </div>
</asp:Content>

