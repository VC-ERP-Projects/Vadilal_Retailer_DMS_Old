<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="ItemSortOrderMapping.aspx.cs" Inherits="Master_ItemSortOrderMapping" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>

    <script type="text/javascript">
        var availableGroup = [];
        var UserID = '<% =UserID%>';

        $(document).ready(function () {

            $('#CountRowMaterial').val(0);

            $('.txtSearch').on('keyup', function () {
                var word = this.value;

                $('#tblItemOrderMap > tbody tr').each(function () {

                    if ($(this).find("td").text().toUpperCase().indexOf(word.toUpperCase()) >= 0 || $(this).find("input").val().toUpperCase().indexOf(word.toUpperCase()) >= 0)
                        $(this).show();
                    else
                        $(this).hide();
                });
            });

            FillData();
        });

        function FillData() {
            $.ajax({
                url: 'ItemSortOrderMapping.aspx/LoadData',
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
                        return false;
                    }
                    else {
                        var Parent = result.d[0];
                        availableGroup = [];

                        for (var i = 0; i < Parent.length; i++) {
                            availableGroup.push(Parent[i]);
                        }
                        $(".txtItemGroupCode").autocomplete({
                            source: availableGroup,
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

        function AddMoreRowMaterial() {

            $('table#tblItemOrderMap tr#NoROW').remove();  // Remove NO ROW
            /// Add Dynamic Row to the existing Table
            var ind = $('#CountRowMaterial').val();
            ind = parseInt(ind) + 1;
            $('#CountRowMaterial').val(ind);

            var str = "";
            str = "<tr id='trMaterial" + ind + "'>"
                + "<td>" + ind + "</td>"
                + "<td id='Code" + ind + "'></td>"
                + "<td id='Name" + ind + "' class='Name'></td>"
                + "<td id='Group" + ind + "'></td>"
                + "<td><input type='text' id='txtSortOrder" + ind + "' name='txtSortOrder' class='form-control search' /><input type='hidden' id='Type" + ind + "' name='Type' class='form-control' /><input type='hidden' id='CodeID" + ind + "' name='CodeID' class='form-control' /></td></tr>"

            $('#tblItemOrderMap > tbody').append(str);
        }

        function GetDetail() {
            var cnt = 1;

            if ($.fn.DataTable.isDataTable('#tblItemOrderMap')) {
                $('#tblItemOrderMap').DataTable().destroy();
            }

            $('#tblItemOrderMap tbody').empty();

            $('#CountRowMaterial').val(0);


            $.ajax({
                url: 'ItemSortOrderMapping.aspx/GetDetail',
                type: 'POST',
                dataType: 'json',
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify({ strGroupCode: $('.txtItemGroupCode').val() }),
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
                            $('#CodeID' + cnt).val(result.d[0][i].CodeID);
                            $('#Type' + cnt).val(result.d[0][i].Type);
                            $('#Code' + cnt).text(result.d[0][i].Code);
                            $('#Name' + cnt).text(result.d[0][i].Name);
                            $('#Group' + cnt).text(result.d[0][i].Group);
                            $('#txtSortOrder' + cnt).val(result.d[0][i].SortOrder);
                            cnt++;
                        }
                        $("#tblItemOrderMap").DataTable({
                            bFilter: false,
                            scrollCollapse: true,
                            "stripeClasses": ['odd-row', 'even-row'],
                            scrollY: '70vh',
                            "destroy": true,
                            scrollX: true,
                            responsive: true,
                            "bPaginate": false,
                            "ordering": false,
                            "bInfo": false
                        });
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

            $('#tblItemOrderMap  > tbody > tr').each(function (row, tr) {

                totalItemcnt = 1;

                var Type = $("input[name='Type']", this).val();
                var CodeID = $("input[name='CodeID']", this).val();
                var Name = $(".Name", this).text();
                var SortOrder = $("input[name='txtSortOrder']", this).val();

                var obj = {
                    Type: Type,
                    CodeID: CodeID,
                    Name: Name,
                    SortOrder: SortOrder
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
            cnt = 0;
            var successMSG = false;
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
                    url: 'ItemSortOrderMapping.aspx/SaveData',
                    type: 'POST',
                    dataType: 'json',
                    data: JSON.stringify({ hidJsonInputMaterial: JSON.stringify(TableData_Material) }),
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
    <style>
        td {
            padding: 2px !important;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default" style="margin-top: 45px; margin-left: 18px;">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-4">
                    <input type="hidden" id="CountRowMaterial" />
                    <div class="input-group form-group" runat="server">
                        <asp:Label ID="lblGroup" runat="server" Text="Group Code" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtItemGroupCode" runat="server" CssClass="txtItemGroupCode form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-default" OnClientClick="GetDetail(); return false;" />
                        &nbsp;
                        <asp:Button ID="btnSubmit" runat="server" Text="Submit" CssClass="btn btn-success" OnClientClick="return btnSubmit_Click()" />
                        &nbsp
                        <asp:Button ID="btnClear" runat="server" Text="Clear" TabIndex="5" CssClass="btn btn-danger" OnClick="btnClear_Click" />
                    </div>
                </div>
            </div>
            <table id="tblItemOrderMap" class="table table-bordered" tabindex="10" style="font-size: 11px;">
                <thead>
                    <tr class="table-header-gradient">
                        <th style="width: 3%;">Sr</th>
                        <th style="width: 10%">Code</th>
                        <th style="width: 40%">Name</th>
                        <th style="width: 20%">Group</th>
                        <th style="width: 10%">Sort Order</th>
                    </tr>
                </thead>
                <tbody>
                </tbody>
            </table>
        </div>
    </div>
</asp:Content>

