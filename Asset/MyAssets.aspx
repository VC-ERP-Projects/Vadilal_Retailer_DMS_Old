<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="MyAssets.aspx.cs" Inherits="Asset_MyAssets" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">

    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />
    <script type="text/javascript" src="../Scripts/colorbox/jquery.colorbox-min.js"></script>

    <script>

        $(function () {
            Relaod();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        window.onresize = twidth;
        function Relaod() {
            twidth();
            $(".txtSearch").keyup(function () {
                var word = this.value;
                $(".gvAsset > tbody tr").each(function () {
                    if ($(this).find("td").text().toUpperCase().indexOf(word.toUpperCase()) >= 0)
                        $(this).show();
                    else
                        $(this).hide();
                });
            });
        }

        function _btnCheck() {
            TestCheckBox();
          
            if (!$('._masterForm').data('bootstrapValidator').isValid()) {
                $('._masterForm').bootstrapValidator('validate');
            }

            return $('._masterForm').data('bootstrapValidator').isValid();
        }

        function EndRequestHandler2(sender, args) {
            $('._masterForm')
                .bootstrapValidator({
                    // Only disabled elements are excluded
                    // The invisible elements belonging to inactive tabs must be validated
                    excluded: [':disabled'],
                    feedbackIcons: {
                        valid: 'glyphicon glyphicon-ok',
                        invalid: 'glyphicon glyphicon-remove',
                        validating: 'glyphicon glyphicon-refresh'
                    },
                    live: 'enabled',
                    trigger: null
                })
                // Called when a field is invalid
                .on('error.field.bv', function (e, data) {
                    var $tabPane = data.element.parents('.tab-pane'),
                        tabId = $tabPane.attr('id');

                    $('a[href="#' + tabId + '"][data-toggle="tab"]')
                        .parent()
                        .find('i')
                        .removeClass('fa-check')
                        .addClass('fa-times');
                })
                // Called when a field is valid
                .on('success.field.bv', function (e, data) {
                    var $tabPane = data.element.parents('.tab-pane'),
                        tabId = $tabPane.attr('id'),
                        $icon = $('a[href="#' + tabId + '"][data-toggle="tab"]')
                                    .parent()
                                    .find('i')
                                    .removeClass('fa-check fa-times');

                    // Check if the submit button is clicked
                    if (data.bv.getSubmitButton()) {
                        // Check if all fields in tab are valid

                        var isValidTab = data.bv.isValidContainer($tabPane);
                        $icon.addClass(isValidTab ? 'fa-check' : 'fa-times');
                    }
                });
        }

        function UploadAttachmentFile(No) {

            $.colorbox({
                width: '30%',
                height: '30%',
                iframe: true,
                href: 'Upload.aspx?LineID=' + No,
                onClosed: function () {
                    window.parent.ReloadPage();
                }
            });
        }

        function ReloadPage() {
            __doPostBack('Refresh', 'Refresh');
        }

        function twidth2() {

            $('.modal-body').css('max-height', (innerHeight - 100) + "px");
        }
        function twidth() {
            $('.tdiv').css('max-height', (innerHeight - 100) + "px");
        }

        function ViewAssetHistory(assetID) {
            $.ajax({
                url: 'MyAssets.aspx/GetMyAssetsDetailsByIDForPopup',
                type: 'POST',
                dataType: 'json',
                //data:{},
                data: JSON.stringify({ assetID: assetID }),
                //data: {assetID : assetID},
                contentType: 'application/json',

                success: function (result) {

                    if (result == "") {
                        alert('No Data Found.');
                        event.preventDefault();
                        return false;
                    }

                    var str = "";

                    // Asset Transfer Header Info.
                    str = "<table border='1' width='100%' class='table'><tr><td>Asset Code: <b>" + result.d[0].AssetCode + "</b></td><td>Asset Name:<b>" + result.d[0].AssetName + "</b></td><td >Currently Hold By: <b>" + result.d[0].HoldBy + "</b></td></tr>";
                    str += "<tr><td>Brand: <b>" + (result.d[0].Brand == null ? "" : result.d[0].Brand) + "</b></td><td>Model: <b>" + (result.d[0].Model == null ? "" : result.d[0].Model) + "</b></td><td >Serial No: <b>" + (result.d[0].SerialNo == null ? "" : result.d[0].SerialNo) + "</b></td></tr>";
                    str += "<tr><td colspan='3'>Description: " + (result.d[0].Description == null ? "" : result.d[0].Description) + "</td></tr>";
                    str += "</table>";

                    // Add Transfer Details
                    var sf = 1;
                    str += "Registration<table table border='1' width='100%' class='table'>";
                    str += "<tr class='table-header-gradient'><td>Type</td><td>Group</td><td>Status</td><td>Condition</td><td>View</td></tr>";
                    str += "<tr><td>" + result.d[0].AssetType + "</td><td>" + result.d[0].AssetGroup + "</td><td>" + result.d[0].AssetStatus + "</td><td>" + result.d[0].AssetCondition + "</td><td><a style='cursor:pointer;' onclick=ViewAttachGrid('" + result.d[0].AssetID + "','" + result.d[0].Asttype + "')>View</a></td></tr>";
                    str += "</table>";
                    if (sf < result.d.length) {
                        str += "Transfer<table table border='1' width='100%' class='table'><tr class='table-header-gradient'><td>Transfer To</td><td>Transfer Date</td><td>Transfer Time</td><td>Document Code</td><td>Document Date</td><td>Reason</td><td>Condition</td><td>Status</td><td>Remarks</td><td>View</td></tr>";

                        for (var i = 1; i < result.d.length; i++) {
                            str += "<tr><td>" + result.d[i].TransferToUser + "</td><td>" + ConvertJsonDateToNormal(result.d[i].TransferDate) + "</td><td>" + result.d[i].TransferTime + "</td><td>" + result.d[i].DocumentNo + "</td><td>" + ConvertJsonDateToNormal(result.d[i].DocumentDate) + "</td><td>" + result.d[i].Reason + "</td><td>" + result.d[i].Condition + "</td><td>" + result.d[i].Status + "</td><td>" + result.d[i].Remarks + "</td><td><a style='cursor:pointer;' onclick=ViewAttachGrid('" + result.d[i].AssetTransferID + "','" + result.d[i].Asttype + "')>View</a></td></tr>";
                        }
                    }
                    str += "</table><br/>";

                    $(".modal-body").empty();
                    $(".modal-body").append(str);
                    twidth2();
                    $('#myModal').modal('toggle');
                }
            });
        }

        function ViewConfirmDetails(assetID) {
            $.ajax({
                url: 'MyAssets.aspx/GetAssetConfirmDetailsByIDForPopup',
                type: 'POST',
                dataType: 'json',
                data: JSON.stringify({ assetID: assetID }),
                contentType: 'application/json',

                success: function (result) {

                    if (result == "") {
                        alert('No Data Found.');
                        event.preventDefault();
                        return false;
                    }

                    var str = "";

                    // Asset Header Info.
                    str = "<table border='1' width='100%' class='table'><tr><td>Asset Code: <b>" + result.d[0].AssetCode + "</b></td><td>Asset Name:<b>" + result.d[0].AssetName + "</b></td><td >Currently Hold By: <b>" + result.d[0].HoldBy + "</b></td></tr>";
                    str += "<tr><td>Brand: <b>" + (result.d[0].Brand == null ? "" : result.d[0].Brand) + "</b></td><td>Model: <b>" + (result.d[0].Model == null ? "" : result.d[0].Model) + "</b></td><td >Serial No: <b>" + (result.d[0].SerialNo == null ? "" : result.d[0].SerialNo) + "</b></td></tr>";
                    str += "<tr><td colspan='3'>Description: " + (result.d[0].Description == null ? "" : result.d[0].Description) + "</td></tr>";
                    str += "</table>";

                    // Add Confirm Details
                    if (result.d.length > 1) {
                        str += "Confirm Details<table table border='1' width='100%' class='table'>";
                        str += "<tr class='table-header-gradient'><td>Confirm By</td><td>Confirm Date</td><td>Confirm Time</td><td>Condition</td><td>Status</td><td>Remarks</td><td>Download</td></tr>";

                        for (var i = 1; i < result.d.length; i++) {
                            if (result.d[i].FileName != "" && result.d[i].FileName != null) {
                                str += "<tr><td>" + result.d[i].ConfirmBy + "</td><td>" + ConvertJsonDateToNormal(result.d[i].ConfirmDate) + "</td><td>" + result.d[i].ConfirmTime + "</td><td>" + result.d[i].Condition + "</td><td>" + result.d[i].Status + "</td><td>" + result.d[i].Remarks + "</td><td><a id='dwnFl" + i + "' href='" + result.d[i].FilePath + "/" + result.d[i].FileName + "' download='" + result.d[i].FileName + "'><img id='imgDn" + i + "' src='../Images/download.png' height='32' width='32' style='cursor:pointer;' /></a></td></tr>";
                            }
                            else {
                                str += "<tr><td>" + result.d[i].ConfirmBy + "</td><td>" + ConvertJsonDateToNormal(result.d[i].ConfirmDate) + "</td><td>" + result.d[i].ConfirmTime + "</td><td>" + result.d[i].Condition + "</td><td>" + result.d[i].Status + "</td><td>" + result.d[i].Remarks + "</td><td>No File</td></tr>";
                            }
                        }
                        str += "</table><br/>";
                    }
                    else {
                        str += "<br/>No Details Found."
                    }

                    $(".modal-body").empty();
                    $(".modal-body").append(str);
                    twidth2();
                    $('#myModal').modal('toggle');
                }
            });
        }

        function ViewAttachGrid(assetTransferID, type) {
            var comp = false;
            $.ajax({
                url: 'MyAssets.aspx/GetAssetTransferAttachmentsForPopup',
                type: 'POST',
                dataType: 'json',
                data: JSON.stringify({ assetTransferID: assetTransferID, type: type }),
                contentType: 'application/json',

                success: function (result1) {
                    var comp = true;
                    if (result1 == "") {
                        // alert('No Attachment available.');
                        var part1 = $(".modal-body").html();
                        var ss1 = part1.split("Attachment-Details");

                        str = ss1[0];
                        $(".modal-body").empty();
                        $(".modal-body").append(str);
                        alert('No Attachment found.');
                        event.preventDefault();
                        return false;
                    }

                    var part1 = $(".modal-body").html();
                    var ss1 = part1.split("Attachment-Details");

                    str = ss1[0];
                    $(".modal-body").empty();
                    str += "Attachment-Details";
                    str += "<table id='tblAttach' table border='1' width='100%' class='table'>";
                    str += "<tr class='table-header-gradient'><td>Type</td><td>Subject</td><td>Notes</td><td>Download</td></tr>";
                    for (var i = 0; i < result1.d.length; i++) {
                        if (result1.d[i].FileName != "" && result1.d[i].FileName != null) {
                            str += "<tr><td>" + result1.d[i].Type + "</td><td>" + result1.d[i].Subject + "</td><td>" + result1.d[i].Notes + "</td><td><a id='dwnFile" + i + "' href='" + result1.d[i].FilePath + "/" + result1.d[i].FileName + "' download='" + result1.d[i].FileName + "'><img id='imgDwn" + i + "' src='../Images/download.png' height='32' width='32' style='cursor:pointer;' /></a></td></tr>";
                        }
                        else {
                            str += "<tr><td>" + result1.d[i].Type + "</td><td>" + result1.d[i].Subject + "</td><td>" + result1.d[i].Notes + "</td><td>No File</td></tr>";
                        }
                    }
                    str += "</table>";
                    $(".modal-body").append(str);
                }
            });
        }

        function ConvertJsonDateToNormal(jsonDate) {
            if (jsonDate != null && jsonDate != "") {
                var date = new Date(parseInt(jsonDate.substr(6)));

                // format display date (e.g. 04/10/2012)
                var displayDate = $.datepicker.formatDate("dd-mm-yy", date);
                return displayDate;
            }
            else {
                return "";
            }
        }

        function TestCheckBox() {

            var bool = 0;
            for (j = 0; j < chkSelect_chk.length; j++) {
                var obj = document.getElementById(chkSelect_chk[j]);
                if (obj.checked == true) {
                    Checkbol = 1;
                    bool = 1;
                }
            }

            if (bool == 0) {
                alert(" Please select atleast one record");
                event.preventDefault();
                return false;
            }

            if (Checkbol == 1) {
                for (i = 0; i < chkSelect_chk.length; i++) {

                    var Obj1 = document.getElementById(chkSelect_chk[i]);

                    if (Obj1.checked == true) {

                        var objCnfDate = document.getElementById(txtCnfDate_Txt[i]);
                        if (objCnfDate.value == "") {
                            alert("Row No: " + [parseInt(i) + 1] + " Confirm date can not be blank");
                            objCnfDate.focus();
                            event.preventDefault();
                            return false;
                        }
                        var objCnfTime = document.getElementById(txtCnfTime_Txt[i]);
                        if (objCnfTime.value == "") {
                            alert("Row No: " + [parseInt(i) + 1] + " Confirm time can not be blank");
                            objCnfTime.focus();
                            event.preventDefault();
                            return false;
                        }
                        var objRemark = document.getElementById(txtRemark_Txt[i]);
                        if (objRemark.value == "") {
                            alert("Row No: " + [parseInt(i) + 1] + " Remark can not be blank");
                            objRemark.focus();
                            event.preventDefault();
                            return false;
                        }
                        var objCondition = document.getElementById(ddlCondition_ddl[i]);
                        if (objCondition.value == "0") {
                            alert("Row No: " + [parseInt(i) + 1] + " Select proper asset Condition");
                            objCondition.focus();
                            event.preventDefault();
                            return false;
                        }
                        var objStatus = document.getElementById(ddlStatus_ddl[i]);
                        if (objStatus.value == "0") {
                            alert("Row No: " + [parseInt(i) + 1] + " Select proper asset Status");
                            objStatus.focus();
                            event.preventDefault();
                            return false;
                        }
                    }
                }

            }
            return true;
        }

        function CheckAllRecords(Checkbox) {
            var GridVwHeaderChckbox = document.getElementById("<%=gvAsset.ClientID %>");
             for (i = 1; i < GridVwHeaderChckbox.rows.length; i++) {
                 GridVwHeaderChckbox.rows[i].cells[2].getElementsByTagName("INPUT")[0].checked = Checkbox.checked;
             }
        }

        function Check_Click(chkbox) {
            var cnt = 1;
            var gridView = document.getElementById("<%=gvAsset.ClientID %>");
            var headerchk = document.getElementById(gridView.id + '_chkboxSelectAll');

            if (chkbox.checked == false) {
                headerchk.checked = false;
            }
            else {
                for (i = 1; i < gridView.rows.length; i++) {
                    if (gridView.rows[i].cells[2].getElementsByTagName("INPUT")[0].checked) {
                        cnt++;
                    }
                }
                if (gridView.rows.length == cnt) {
                    headerchk.checked = true;
                }
            }
        }

    </script>

    <style type="text/css">
        .HideColumn {
            display: none;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">

    <!-- Modal -->
    <div class="modal fade" id="myModal" tabindex="-1" role="dialog"
        aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-dialog" style="width: 70%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close"
                        data-dismiss="modal" aria-hidden="true">
                        &times;
                    </button>
                    <h4 class="modal-title" id="myModalLabel">Asset History
                    </h4>
                </div>
                <div class="modal-body" style="overflow: auto">
                </div>

            </div>
            <!-- /.modal-content -->
        </div>
        <!-- /.modal-dialog -->
    </div>
    <!-- /.modal -->

    <div class="panel panel-default">
        <div class="panel-body _masterForm">

            <asp:TextBox runat="server" placeholder="Search here" CssClass="txtSearch form-control" />
            <br />
            <div style="overflow-x: auto; overflow-y: auto" class="tdiv">

                <asp:GridView runat="server" ID="gvAsset" CssClass="gvAsset table" AutoGenerateColumns="false" HeaderStyle-CssClass="table-header-gradient" EmptyDataText="No Item Found." OnRowDataBound="gvAsset_RowDataBound" OnPreRender="gvAsset_PreRender">
                    <Columns>
                        <asp:BoundField DataField="AssetID" HeaderText="Asset ID" ItemStyle-CssClass="HideColumn" HeaderStyle-CssClass="HideColumn" />
                        <asp:BoundField DataField="AssetTransferID" HeaderText="AssetTransfer ID" ItemStyle-CssClass="HideColumn" HeaderStyle-CssClass="HideColumn" />
                        <asp:TemplateField HeaderText="Select" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Center">
                            <HeaderTemplate>
                            <asp:CheckBox ID="chkboxSelectAll" runat="server" CssClass="form-control"  onclick="CheckAllRecords(this);" />
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:CheckBox ID="chkSelect" runat="server" CssClass="form-control" onclick = "Check_Click(this)"/>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="AssetCode" HeaderText="Asset Code"  Visible="true" ItemStyle-Width="7%" />
                        <asp:BoundField DataField="AssetName" HeaderText="Asset Name" Visible="true" ItemStyle-Width="7%" />
                        <asp:TemplateField HeaderText="Confirm Date">
                            <ItemTemplate>
                                <asp:TextBox ID="txtConfirmDate" runat="server" CssClass="datepick form-control"></asp:TextBox>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Confirm Time">
                            <ItemTemplate>
                                <asp:TextBox ID="txtConfirmTime" runat="server" CssClass="form-control"></asp:TextBox>
                                <asp:MaskedEditExtender ID="confirmMEE" runat="server" TargetControlID="txtConfirmTime" MaskType="Time"
                                    Mask="99:99:99">
                                </asp:MaskedEditExtender>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Condition">
                            <ItemTemplate>
                                <asp:DropDownList ID="ddlCondition" runat="server" DataSourceID="edsddlCondition" DataTextField="AssetConditionName" AppendDataBoundItems="true" SelectedValue='<%# Eval("AssetConditionID") %>' DataValueField="AssetConditionID" CssClass="form-control">
                                    <asp:ListItem Text="---Select---" Value="0" />
                                </asp:DropDownList>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <asp:DropDownList ID="ddlStatus" runat="server" DataSourceID="edsddlStatus" DataTextField="AssetStatusName" AppendDataBoundItems="true" SelectedValue='<%# Eval("AssetStatusID") %>' DataValueField="AssetStatusID" CssClass="form-control">
                                    <asp:ListItem Text="---Select---" Value="0" />
                                </asp:DropDownList>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Remark">
                            <ItemTemplate>
                                <asp:TextBox ID="txtRemark" runat="server" CssClass="form-control"></asp:TextBox>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Select File">
                            <ItemTemplate>
                                <asp:LinkButton Text="Upload" ID="lnkUpload" runat="server" OnClientClick='<%# String.Format("UploadAttachmentFile({0});", Container.DataItemIndex) %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="History">
                            <ItemTemplate>
                                <a onclick="ViewAssetHistory('<%#Eval("AssetID")%>');">
                                    <img id='imgMstCF' src='../Images/search.png' style='cursor: pointer;' /></a>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Confirm History">
                            <ItemTemplate>
                                <a onclick="ViewConfirmDetails('<%#Eval("AssetID")%>');">
                                    <img id='imgMstCF' src='../Images/search.png' style='cursor: pointer;' /></a>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>

                <asp:EntityDataSource ID="edsddlCondition" runat="server" ConnectionString="name=DDMSEntities" Where="it.Active = true"
                    DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OASTCs">
                </asp:EntityDataSource>
                <asp:EntityDataSource ID="edsddlStatus" runat="server" ConnectionString="name=DDMSEntities" Where="it.Active = true"
                    DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OASTUs">
                </asp:EntityDataSource>

            </div>

            <asp:Button ID="btnSubmit" runat="server" Text="Submit" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnSubmit_Click" />
            <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-default" OnClick="btnCancelClick" UseSubmitBehavior="false" CausesValidation="false" />
        </div>
    </div>

</asp:Content>

