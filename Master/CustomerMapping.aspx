<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="CustomerMapping.aspx.cs" Inherits="Master_CustomerMapping" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>

    <script type="text/javascript">
        var availableParent = [];
        var availableCustomer = [];
        var UserID = '<% =UserID%>';

        $(document).ready(function () {

            $('#CountRowMaterial').val(0);

            $('.txtSearch').on('keyup', function () {
                var word = this.value;

                $('#tblCustomerMapping > tbody tr').each(function () {

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
                url: 'CustomerMapping.aspx/LoadData',
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
                        var Customer = result.d[1];
                        availableParent = [];
                        availableCustomer = [];

                        for (var i = 0; i < Parent.length; i++) {
                            availableParent.push(Parent[i]);
                        }
                        $(".txtParentCode").autocomplete({
                            source: availableParent,
                            minLength: 0,
                            scroll: true
                        });

                        for (var i = 0; i < Customer.length; i++) {
                            availableCustomer.push(Customer[i]);
                        }
                        $(".txtCustCode").autocomplete({
                            source: availableCustomer,
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

            $('table#tblCustomerMapping tr#NoROW').remove();  // Remove NO ROW
            /// Add Dynamic Row to the existing Table
            var ind = $('#CountRowMaterial').val();
            ind = parseInt(ind) + 1;
            $('#CountRowMaterial').val(ind);

            var str = "";
            str = "<tr id='trMaterial" + ind + "'>"
                + "<td>" + ind + "</td>"
                + "<td id='Customer" + ind + "'></td>"
                + "<td><input type='text' id='txtEmailID" + ind + "' name='txtEmailID' class='form-control search' /><input type='hidden' id='CustomerID" + ind + "' name='CustomerID' class='form-control' /></td>"
                + "<td id='CreatedBy" + ind + "'></td>"
                + "<td id='CreatedDate" + ind + "'></td>"
                + "<td id='UpdatedBy" + ind + "'></td>"
                + "<td id='UpdatedDate" + ind + "'></td></tr>"

            $('#tblCustomerMapping > tbody').append(str);
        }

        function GetDetail() {
            var cnt = 1;

            if ($.fn.DataTable.isDataTable('#tblCustomerMapping')) {
                $('#tblCustomerMapping').DataTable().destroy();
            }

            $('#tblCustomerMapping tbody').empty();

            $('#CountRowMaterial').val(0);

            var ParentCode = $('.txtParentCode').val().split('-')[0].trim();
            var CustCode = $('.txtCustCode').val().split('-')[0].trim();

            $.ajax({
                url: 'CustomerMapping.aspx/GetDetail',
                type: 'POST',
                dataType: 'json',
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify({ strParent: ParentCode, strCustomer: CustCode }),
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
                            $('#Customer' + cnt).text(result.d[0][i].Customer);
                            $('#CustomerID' + cnt).val(result.d[0][i].CustomerID);
                            $('#txtEmailID' + cnt).val(result.d[0][i].EmailID);
                            $('#CreatedBy' + cnt).text(result.d[0][i].CreatedBy);
                            $('#CreatedDate' + cnt).text(result.d[0][i].CreatedDate);
                            $('#UpdatedBy' + cnt).text(result.d[0][i].UpdatedBy);
                            $('#UpdatedDate' + cnt).text(result.d[0][i].UpdatedDate);
                            cnt++;
                        }
                        $("#tblCustomerMapping").DataTable({
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

            $('#tblCustomerMapping  > tbody > tr').each(function (row, tr) {
                totalItemcnt = 1;
                var Customer = $("input[name='CustomerID']", this).val();
                var EmailID = $("input[name='txtEmailID']", this).val();

                var obj = {
                    Customer: Customer,
                    EmailID: EmailID
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
                    url: 'CustomerMapping.aspx/SaveData',
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
                        <asp:Label ID="lblParents" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtParentCode" runat="server" CssClass="txtParentCode form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
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
                <div class="col-lg-4">
                    <asp:TextBox runat="server" placeholder="Search here" CssClass="txtSearch form-control" MaxLength="150" />
                    <div class="input-group form-group" runat="server" style="display: none">
                        <asp:Label ID="lblCustomers" runat="server" Text="Dealer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCustCode" runat="server" CssClass="txtCustCode form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                    </div>
                </div>
            </div>
            <table id="tblCustomerMapping" class="table table-bordered" tabindex="10" style="font-size: 11px">
                <thead>
                    <tr class="table-header-gradient">
                        <th style="width: 3%;">Sr</th>
                        <th style="width: 26%">Customer</th>
                        <th style="width: 29%">Email ID</th>
                        <th style="width: 13%">Created By</th>
                        <th style="width: 8%">Created Date</th>
                        <th style="width: 13%">Updated By</th>
                        <th style="width: 8%">Updated Date</th>
                    </tr>
                </thead>
                <tbody>
                </tbody>
            </table>
        </div>
    </div>
</asp:Content>

