<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="TaskEscalationMatrix.aspx.cs" Inherits="Task_TaskEscalationMatrix" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        $(document).ready(function () {

            $("#hdnMatrixID").val(0);
            $('#CountRowMaterial').val(0);
            AddMoreRowMaterial();
            $.ajax({
                url: "TaskEscalationMatrix.aspx/GetData",
                type: 'POST',
                dataType: 'json',
                async: false,
                contentType: 'application/json; charset=utf-8',
                success: function (result) {
                    var MechHrchy = result.d[0];
                    var FStaffHrchy = result.d[1];
                    availableMechHrchy = [];
                    availableFStaffHrchy = [];

                    for (var i = 0; i < MechHrchy.length; i++) {
                        availableMechHrchy.push(MechHrchy[i]);
                    }

                    for (var i = 0; i < FStaffHrchy.length; i++) {
                        availableFStaffHrchy.push(FStaffHrchy[i]);
                    }

                    $("#txtMechHrchy1").autocomplete({
                        source: availableMechHrchy,
                        minLength: 0,
                        scroll: true
                    });

                    $("#txtFStaffHrchy1").autocomplete({
                        source: availableFStaffHrchy,
                        minLength: 0,
                        scroll: true
                    });
                }
            });
        });

        function autoCompleteStoreLoc_OnClientPopulating(sender, args) {
            var key = $('.txtRegion').val().split('-').pop();
            sender.set_contextKey(key + "-1");
        }

        function SeachData() {

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

            var cnt = 1;
            $("#tblLevelDetail > tbody > tr").each(function () {
                if (cnt > 0) {
                    $(this).remove();       // remove other rows except first row.
                }
                cnt++;
            });
            $('#CountRowMaterial').val(0);
            var ProbType = $(".ddlProbType").val();

            var RegionID = $('.txtRegion').val().split('-').pop();
            if (RegionID == undefined || RegionID == 0 || RegionID == '') {
                $.unblockUI();
                $("#btnSubmit").removeAttr('disabled');
                ModelMsg("Please select Region", 3);
                event.preventDefault();
                return false;
            }

            var LocationID = $('.txtLocation').val().split('-').pop();
            if (LocationID == undefined || LocationID == 0 || LocationID == '') {
                $.unblockUI();
                $("#btnSubmit").removeAttr('disabled');
                ModelMsg("Please select Location", 3);
                event.preventDefault();
                return false;
            }
            $.ajax({
                url: 'TaskEscalationMatrix.aspx/GetDetail',
                type: 'POST',
                dataType: 'json',
                async: false,
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify({ strProbType: ProbType, strRegionID: RegionID, strLocationID: LocationID }),
                success: function (result) {
                    if (result == "") {
                        $.unblockUI();
                        //event.preventDefault();
                        return false;
                    }
                    else if (result.d[0].indexOf("ERROR=") >= 0) {
                        $.unblockUI();
                        var ErrorMsg = result.d[0].split('=')[1].trim();
                        ModelMsg(ErrorMsg, 3);
                        //event.preventDefault();
                        return false;
                    }
                    else {
                        $.unblockUI();
                        if (result.d[0].length > 0) {
                            cnt = 1;
                            $('#hdnMatrixID').val(result.d[0][0].MatrixID);
                            $('.txtCreatedBy').val(result.d[0][0].CreatedBy);
                            $('.txtUpdatedBy').val(result.d[0][0].UpdatedBy);
                            $('.txtCreatedDate').val(result.d[0][0].CreatedDate);
                            $('.txtUpdatedDate').val(result.d[0][0].UpdatedDate);
                            for (var i = 0; i < result.d[0].length; i++) {
                                AddMoreRowMaterial();
                                $('#txtLvlNo' + cnt).val(result.d[0][i].LvlNo);
                                $('#txtInCityFromHr' + cnt).val(result.d[0][i].InCityFromHr);
                                $('#txtInCityToHr' + cnt).val(result.d[0][i].InCityToHr);
                                $('#txtOutCityFromHr' + cnt).val(result.d[0][i].OutCityFromHr);
                                $('#txtOutCityToHr' + cnt).val(result.d[0][i].OutCityToHr);
                                //$('#txtEmails' + cnt).val(result.d[0][i].Emails);
                                $('#txtMechHrchy' + cnt).val(result.d[0][i].MechHrchy);
                                $('#txtFStaffHrchy' + cnt).val(result.d[0][i].FStaffHrchy);
                                cnt++;
                            }
                        }
                        else {
                            $('#hdnMatrixID').val(0);
                            AddMoreRowMaterial();
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
                + "<td><input type='text'  disabled id='txtLvlNo" + ind + "' name='txtLvlNo' class='txtLvlNo form-control allownumericwithoutdecimal' /></td>"
                + "<td><input type='text' value = 0 id='txtInCityFromHr" + ind + "' name='txtInCityFromHr' class='form-control allownumericwithoutdecimal' /></td>"
                + "<td><input type='text' value = 0 id='txtInCityToHr" + ind + "' name='txtInCityToHr' class='form-control allownumericwithoutdecimal' /></td>"
                 + "<td><input type='text' value = 0 id='txtOutCityFromHr" + ind + "' name='txtOutCityFromHr' class='form-control allownumericwithoutdecimal' /></td>"
                + "<td><input type='text' value = 0 id='txtOutCityToHr" + ind + "' name='txtOutCityToHr' class='form-control allownumericwithoutdecimal' /></td>"
                + "<td><input type='text' id='txtMechHrchy" + ind + "' name='txtMechHrchy' class='form-control' Style='background-color: rgb(250, 255, 189);' /></td>"
                + "<td><input type='text' id='txtFStaffHrchy" + ind + "' name='txtFStaffHrchy' class='form-control' Style='background-color: rgb(250, 255, 189);' /></td>"
                //+ "<td><input type='text' id='txtEmails" + ind + "' hidden='hidden' name='txtEmails' class='form-control' /></td>"
                + "<td><input type='image' id='btnDelete" + ind + "' name='btnDelete' src='../Images/delete2.png'  style='width:30px;' onclick='RemoveMaterialRow(" + ind + ");' /></td>"
                + "<input type='hidden' id='hdnLineNum" + ind + "' name='hdnLineNum' value='" + ind + "' />"
                + "<input type='text' id='txtDeleteFlag" + ind + "' name='txtDeleteFlag' style='display:none' value='false' />"

            $('#tblLevelDetail > tbody').append(str);

            $.ajax({
                url: "TaskEscalationMatrix.aspx/GetData",
                type: 'POST',
                dataType: 'json',
                async: false,
                contentType: 'application/json; charset=utf-8',
                success: function (result) {
                    var MechHrchy = result.d[0];
                    var FStaffHrchy = result.d[1];

                    availableMechHrchy = [];
                    availableFStaffHrchy = [];

                    for (var i = 0; i < MechHrchy.length; i++) {
                        availableMechHrchy.push(MechHrchy[i]);
                    }

                    for (var i = 0; i < FStaffHrchy.length; i++) {
                        availableFStaffHrchy.push(FStaffHrchy[i]);
                    }

                    $("#txtMechHrchy" + ind).autocomplete({
                        source: availableMechHrchy,
                        minLength: 0,
                        scroll: true
                    });

                    $("#txtFStaffHrchy" + ind).autocomplete({
                        source: availableFStaffHrchy,
                        minLength: 0,
                        scroll: true
                    });
                }
            });

            var lineNum = 0;
            $('#tblLevelDetail > tbody > tr').each(function (row, tr) {
                $("input[name^='hdnLineNum']", this).val(lineNum);
                lineNum++;
                $("input[name^='txtLvlNo']", this).val(lineNum);
            });

            // allow decimal values only
            $(".allownumericwithoutdecimal").on("keypress keyup blur", function (event) {
                $(this).val($(this).val().replace(/[^\d].+/, ""));
                if ((event.which < 48 || event.which > 57)) {
                    event.preventDefault();
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

            var MatrixID = $("#hdnMatrixID").val();
            var ProbType = $(".ddlProbType").val();

            var RegionID = $('.txtRegion').val().split('-').pop();
            if (RegionID == undefined || RegionID == 0 || RegionID == '') {
                $.unblockUI();
                $("#btnSubmit").removeAttr('disabled');
                ModelMsg("Please select Region", 3);
                event.preventDefault();
                return false;
            }

            var LocationID = $('.txtLocation').val().split('-').pop();
            if (LocationID == undefined || LocationID == 0 || LocationID == '') {
                $.unblockUI();
                $("#btnSubmit").removeAttr('disabled');
                ModelMsg("Please select Location", 3);
                event.preventDefault();
                return false;
            }

            var postData = {
                ProbType: ProbType,
                RegionID: RegionID,
                LocationID: LocationID,
                MatrixID: MatrixID
            }
            $('#hidJsonInputHeader').val(JSON.stringify(postData));
            var HeaderData = $('#hidJsonInputHeader').val();

            $('#tblLevelDetail  > tbody > tr').each(function (row, tr) {
                var LvlNo = $("input[name='txtLvlNo']", this).val();
                var InCityFromHr = $("input[name='txtInCityFromHr']", this).val();
                var InCityToHr = $("input[name='txtInCityToHr']", this).val();
                var OutCityFromHr = $("input[name='txtOutCityFromHr']", this).val();
                var OutCityToHr = $("input[name='txtOutCityToHr']", this).val();
                var MechHrchy = $("input[name='txtMechHrchy']", this).val().split("#").pop().trim();
                var FStaffHrchy = $("input[name='txtFStaffHrchy']", this).val().split("#").pop().trim();
                //var Emails = $("input[name='txtEmails']", this).val();

                if (InCityFromHr == undefined || InCityFromHr == '' || InCityToHr == undefined || InCityToHr == '' || (InCityFromHr == 0 && InCityToHr == 0)) {
                    cnt = 1;
                    errormsg = 'Please Define In City Hours in Row: ' + (parseInt(rowCnt_Material) + 1);
                    event.preventDefault();
                    return false;
                }
                if (OutCityFromHr == undefined || OutCityFromHr == '' || OutCityToHr == undefined || OutCityToHr == '' || (OutCityFromHr == 0 && OutCityToHr == 0)) {
                    cnt = 1;
                    errormsg = 'Please Define Out City Hours in Row: ' + (parseInt(rowCnt_Material) + 1);
                    event.preventDefault();
                    return false;
                }
                if (MechHrchy == "" || MechHrchy == undefined) {
                    cnt = 1;
                    errormsg = 'Please enter Mechanic Hierarchy in Row: ' + (parseInt(rowCnt_Material) + 1);
                    event.preventDefault();
                    return false;
                }
                if (FStaffHrchy == "" || FStaffHrchy == undefined) {
                    cnt = 1;
                    errormsg = 'Please enter Field Staff Hierarchy in Row: ' + (parseInt(rowCnt_Material) + 1);
                    event.preventDefault();
                    return false;
                }

                var obj = {
                    LvlNo: LvlNo,
                    InCityFromHr: InCityFromHr,
                    InCityToHr: InCityToHr,
                    OutCityFromHr: OutCityFromHr,
                    OutCityToHr: OutCityToHr,
                    MechHrchy: MechHrchy,
                    FStaffHrchy: FStaffHrchy,
                    //Emails: Emails,
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
                    url: 'TaskEscalationMatrix.aspx/SaveData',
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
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default" style="margin-top: 45px; margin-left: 18px;">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblProblemType" runat="server" Text="Problem Type" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlProbType" runat="server" CssClass="ddlProbType form-control" DataTextField="ProbemName" DataValueField="ProblemID" AppendDataBoundItems="true">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text="Region" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" TabIndex="2" CssClass="txtRegion form-control" runat="server" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server" ServiceMethod="GetStatesCurrHierarchy"
                            ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            TargetControlID="txtRegion" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblLocation" runat="server" Text="Location" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtLocation" runat="server" TabIndex="6" Style="background-color: rgb(250, 255, 189);" CssClass="txtLocation form-control"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server"
                            ServiceMethod="GetStorageLocationCurrHierarchy" ServicePath="../Service.asmx" OnClientPopulating="autoCompleteStoreLoc_OnClientPopulating" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtLocation" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblCreatedBy" Text="Created By" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox runat="server" ID="txtCreatedBy" CssClass="txtCreatedBy form-control" disabled="disabled" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblCreatedDate" Text="Created Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox runat="server" ID="txtCreatedDate" CssClass="txtCreatedDate form-control" disabled="disabled" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblUpdateBy" Text="Update By" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox runat="server" ID="txtUpdatedBy" CssClass="txtUpdatedBy form-control" disabled="disabled" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblUpdatedDate" Text="Updated Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox runat="server" ID="txtUpdatedDate" CssClass="txtUpdatedDate form-control" disabled="disabled" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <input type="hidden" id="CountRowMaterial" />
                        <input type="button" id="btnGo" name="btnGo" value="Go" class="btn btn-default" onclick="SeachData();" />
                        &nbsp;
                        <input type="button" id="btnAddMoreMaterial" name="btnAddMoreMaterial" value="Add Row" onclick="AddMoreRowMaterial();" class="btn btn-default" />
                    </div>
                </div>
                <div class="col-lg-12">
                    <div class="border-la">&nbsp;</div>
                    <table id="tblLevelDetail" class="table" border="1" tabindex="10">
                        <thead>
                            <tr class="table-header-gradient">
                                <th style="width: 6%;">Level</th>
                                <th style="width: 9%">InCity From Hrs</th>
                                <th style="width: 9%;">InCity To Hrs</th>
                                <th style="width: 10%">OutCity From Hrs</th>
                                <th style="width: 9%;">OutCity To Hrs</th>
                                <th style="width: 26%;">Mechanic Hierarchy</th>
                                <th style="width: 26%;">Field Staff Hierarchy</th>
                                <%--<th style="width: 20%;">Additional Mail IDs</th>--%>
                                <th style="width: 5%" hidden="hidden">Delete</th>
                                <th style="display: none">ID</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
                <br />
                <asp:HiddenField ID="hdnMatrixID" ClientIDMode="Static" runat="server"></asp:HiddenField>
                <input type="hidden" id="hidJsonInputMaterial" name="hidJsonInputMaterial" value="" />
                <input type="hidden" id="hidJsonInputHeader" name="hidJsonInputHeader" value="" />
            </div>
            <input type="submit" value="Save" class="btn btn-default" tabindex="26" id="btnSubmit" onclick="return btnSubmit_Click();" />
            <asp:Button ID="btnCancel" Text="Cancel" class="btn btn-default" runat="server" OnClick="btnCancel_Click" />
            <asp:Button ID="btnSendNoti" Text="Send Notif" CssClass="btn btn-default" runat="server" OnClick="btnSendNoti_Click" />
        </div>
    </div>
</asp:Content>

