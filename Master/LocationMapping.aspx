<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="LocationMapping.aspx.cs" Inherits="Master_LocationMapping" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script type="text/javascript">

        var availableData = [];
        var UserID = '<% =UserID%>';

        $(document).ready(function () {

            $('#CountRowMaterial').val(0);
            $('#gridSearch').hide();

            $('.txtSearchData').on('keyup', function () {
                var word = this.value;

                $('#tblLocationMapping > tbody tr').each(function () {

                    if ($(this).find("td").text().toUpperCase().indexOf(word.toUpperCase()) >= 0 || $(this).find("input").val().toUpperCase().indexOf(word.toUpperCase()) >= 0)
                        $(this).show();
                    else
                        $(this).hide();
                });
            });

            FillData();

            $('.ddlSearchBy').change(function () {
                FillData();
                if ($.fn.DataTable.isDataTable('#tblLocationMapping')) {
                    $('#tblLocationMapping').DataTable().destroy();
                }
                $('#tblLocationMapping tbody').empty();
                $('#tblLocationMapping thead').empty();
            });
            $('.ddlSearchFor').change(function () {
                if ($.fn.DataTable.isDataTable('#tblLocationMapping')) {
                    $('#tblLocationMapping').DataTable().destroy();
                }
                $('#tblLocationMapping tbody').empty();
                $('#tblLocationMapping thead').empty();
            });
        });


        function FillData() {
            var SearchBy = $('.ddlSearchBy').val();
            $('.txtSearch').val('');

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

            $.ajax({
                url: 'LocationMapping.aspx/LoadData',
                type: 'POST',
                dataType: 'json',
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify({ strSearchBy: $('.ddlSearchBy').val() }),
                success: function (result) {

                    if (result.d == "") {
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
                        var Data = result.d[0];
                        availableData = [];

                        for (var i = 0; i < Data.length; i++) {
                            availableData.push(Data[i]);
                        }
                        $(".txtSearch").autocomplete({
                            source: availableData,
                            minLength: 0,
                            scroll: true
                        });
                        $.unblockUI();
                        return false;
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    $.unblockUI();
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    event.preventDefault();
                    return false;
                }
            });
        }

        function CheckMain(chk) {

            if (chk == undefined) {
                if ($('.chkCheck').length == $('.chkCheck').find('input:checked').length)
                    $('.chkMain').prop('checked', true);
                else
                    $('.chkMain').prop('checked', false);
            }
            else {
                if ($(chk).is(':checked'))
                    $('.chkCheck').prop('checked', true);
                else
                    $('.chkCheck').prop('checked', false);

            }
        }

        function AddMoreRowMaterial(SearchFor) {

            $('table#tblLocationMapping tr#NoROW').remove();  // Remove NO ROW
            /// Add Dynamic Row to the existing Table
            var ind = $('#CountRowMaterial').val();
            ind = parseInt(ind) + 1;
            $('#CountRowMaterial').val(ind);

            if (ind == 1) {
                var strHead = "";
                if (SearchFor == "99") {
                    $('#tblLocationMapping > tbody').append("<tr><td align = center style='font-size:12px';><b>No Data Found</b></td></tr>");
                    return;
                }
                if (SearchFor == "1") {
                    strHead = "";
                    strHead = "<tr class='table-header-gradient'>"
                            + "<th align = center style='width: 3%;'><input type='checkbox' id='chkMain' name='chkMain' class='form-control search chkMain' onchange='CheckMain(this);'/></th>"
                            + "<th style='width: 3%;'>Sr</th>"
                            + "<th style='width: 15%'>Employee</th>"
                            + "<th style='width: 10%'>Latitude</th>"
                            + "<th style='width: 10%'>Longitude</th>"
                            + "<th style='width: 10%'>Office Lat</th>"
                            + "<th style='width: 10%'>Office Long</th>"
                            + "<th style='width: 20%'>Address</th>"
                            + "<th style='width: 12%'>Updated By</th>"
                            + "<th style='width: 8%'>Updated Date</th>";
                }
                else {
                    strHead = "";
                    strHead = "<tr class='table-header-gradient'>"
                            + "<th align = center style='width: 3%;'><input type='checkbox' id='chkMain' name='chkMain' class='form-control search chkMain' onchange='CheckMain(this);'/></th>"
                            + "<th style='width: 3%;'>Sr</th>"
                            + "<th style='width: 20%'>Customer</th>"
                            + "<th style='width: 10%'>Office Latitude</th>"
                            + "<th style='width: 10%'>Office Longitude</th>"
                            + "<th >Office Address</th>"
                            + "<th style='width: 10%'>Updated By</th>"
                            + "<th style='width: 6%'>Updated Date</th>";
                }
                $('#tblLocationMapping > thead').append(strHead);
            }

            var str = "";
            str = "<tr id='trMaterial" + ind + "'>"
                + "<td align = center><input type='checkbox' id='chkCheck" + ind + "' name='chkCheck' class='form-control search chkCheck' onchange='CheckMain();'/></td>"
                + "<td  align = center style='background-color:#d4d4d4'>" + ind + "</td>"
                + "<td id='Customer" + ind + "' class='Customer'></td>"
                + "<td><input type='text' id='txtHomeLat" + ind + "' name='txtHomeLat' class='form-control txtHomeLat txtbox' /></td>"
                + "<td><input type='text' id='txtHomeLong" + ind + "' name='txtHomeLong' class='form-control txtHomeLong txtbox' /></td>";
            if (SearchFor == "1") {
                str += "<td><input type='text' id='txtOfficeLat" + ind + "' name='txtOfficeLat' class='form-control txtOfficeLat txtbox' /></td>"
                 + "<td><input type='text' id='txtOfficeLong" + ind + "' name='txtOfficeLong' class='form-control txtOfficeLong txtbox' /></td>";
            }
            str += "<td id='txtAddress" + ind + "' class='txtAddress'></td>"
                + "<td id='UpdatedBy" + ind + "'  class='UpdatedBy' /></td>"
                + "<td id='UpdatedDate" + ind + "'  class='UpdatedDate' /></td>";
            str += "</tr>";
            $('#tblLocationMapping > tbody').append(str);

            $('.txtbox').attr('onkeypress', 'return isNumberKeyWithMinus(event)');
        }

        function GetDetail() {
            var cnt = 1;
            if ($.fn.DataTable.isDataTable('#tblLocationMapping')) {
                $('#tblLocationMapping').DataTable().destroy();
            }
            $('#tblLocationMapping tbody').empty();
            $('#tblLocationMapping thead').empty();

            $('#CountRowMaterial').val(0);

            var SearchID = $('.txtSearch').val().split('-').pop().trim();
            var SearchBy = $('.ddlSearchBy').val();
            var SearchFor = $('.ddlSearchFor').val();
            if (SearchID == '') {
                ModelMsg("Please Select Any Search With option", 3);
                event.preventDefault();
                return false;
            }
            if (SearchFor == '3' && SearchBy == '1') {
                ModelMsg("Please Select only Plant/City option for Dealer", 3);
                event.preventDefault();
                return false;
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

            $.ajax({
                url: 'LocationMapping.aspx/GetDetail',
                type: 'POST',
                dataType: 'json',
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify({ strSearchID: SearchID, strSearchBy: SearchBy, strSearchFor: SearchFor }),
                success: function (result) {

                    if (result == "") {
                        $.unblockUI();

                        event.preventDefault();
                        return false;
                    }
                    else if (result.d[0].indexOf("ERROR=") >= 0) {
                        $.unblockUI();
                        var ErrorMsg = result.d[0].split('=')[1].trim();
                        ModelMsg(ErrorMsg, 3);
                        event.preventDefault();
                        return false;
                    }
                    else {
                        if (result.d[0].length > 0) {
                            $('#gridSearch').show()
                            cnt = 1;
                            for (var i = 0; i < result.d[0].length; i++) {
                                AddMoreRowMaterial(SearchFor);
                                $('#Customer' + cnt).text(result.d[0][i].CodeName).css('background-color', '#d4d4d4');
                                $('#txtAddress' + cnt).text(result.d[0][i].Address).css('background-color', '#d4d4d4');
                                $('#txtHomeLat' + cnt).val(result.d[0][i].HomeLat);
                                $('#txtHomeLong' + cnt).val(result.d[0][i].HomeLong);
                                $('#txtOfficeLat' + cnt).val(result.d[0][i].OfficeLat);
                                $('#txtOfficeLong' + cnt).val(result.d[0][i].OfficeLong);
                                $('#UpdatedBy' + cnt).text(result.d[0][i].UpdatedBy).css('background-color', '#d4d4d4');
                                $('#UpdatedDate' + cnt).text(result.d[0][i].UpdatedDate).css('background-color', '#d4d4d4');
                                cnt++;
                            }
                            $("#tblLocationMapping").DataTable({
                                bFilter: false,
                                scrollCollapse: true,
                                "stripeClasses": ['odd-row', 'even-row'],
                                scrollY: '65vh',
                                "destroy": true,
                                scrollX: true,
                                responsive: true,
                                "bPaginate": false,
                                "ordering": false,
                                "bInfo": false
                            });

                        }
                        else {
                            $('#gridSearch').hide();
                            AddMoreRowMaterial(99);
                        }
                        $.unblockUI();
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

        function ClearLatLong() {
            if ($('#tblLocationMapping thead tr').length > 0) {
                $('#tblLocationMapping tr').each(function (row, tr) {
                    if ($("input[name='chkCheck']", this).is(":checked")) {
                        $(".txtHomeLat", this).val("");
                        $(".txtHomeLong", this).val("");
                        $(".txtOfficeLat", this).val("");
                        $(".txtOfficeLong", this).val("");
                        $("input[name='chkCheck']", this).prop('checked', false);
                        $("input[name='chkMain']").prop('checked', false);
                    }
                });
            }
            return false;
        }

        function btnSubmit_Click() {

            if ($('#tblLocationMapping thead tr').length <= 0) {
                $.unblockUI();
                $("#btnSubmit").removeAttr('disabled');
                ModelMsg("Please Search first", 3);
                event.preventDefault();
                return false;
            }
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
            var cnt = 0;
            rowCnt_Material = 0;
            var SearchFor = $('.ddlSearchFor').val();

            $('#tblLocationMapping  > tbody > tr').each(function (row, tr) {
                var HomeLatitude = $("input[name='txtHomeLat']", this).val();
                var HomeLongitude = $("input[name='txtHomeLong']", this).val();
                var OfficeLatitude = "";
                var OfficeLongitude = "";

                if (SearchFor == '1') {
                    OfficeLatitude = $("input[name='txtOfficeLat']", this).val();
                    OfficeLongitude = $("input[name='txtOfficeLong']", this).val();
                }

                var Customer = $('.Customer', this).text().split('-')[0].trim();

                var obj = {
                    Customer: Customer,
                    HomeLatitude: HomeLatitude,
                    HomeLongitude: HomeLongitude,
                    OfficeLatitude: OfficeLatitude,
                    OfficeLongitude: OfficeLongitude
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
                    url: 'LocationMapping.aspx/SaveData',
                    type: 'POST',
                    dataType: 'json',
                    data: JSON.stringify({ SearchFor: SearchFor, hidJsonInputMaterial: JSON.stringify(TableData_Material) }),
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
            padding: 0px 2px 0px 2px !important;
        }

        th {
            padding: 2px 2px 0px 2px !important;
        }

        .table > thead > tr > th {
            line-height: 2.428571;
        }

        .txtbox {
            font-size: 11px;
            height: 30px;
        }

        .ui-menu-item {
            font-size: 0.8em;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default" style="margin-top: 45px; margin-left: 18px;">
        <div class="panel-body _masterForm">
            <div class="row">
                <input type="hidden" id="CountRowMaterial" />
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSearchBy" runat="server" Text="Search By" class="input-group-addon" />
                        <asp:DropDownList ID="ddlSearchBy" class="ddlSearchBy" runat="server" CssClass="ddlSearchBy form-control">
                            <asp:ListItem Text="State" Value="1" Selected="True" />
                            <asp:ListItem Text="City" Value="2"></asp:ListItem>
                            <asp:ListItem Text="Plant" Value="3"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSearch" runat="server" Text="Search With" class="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtSearch" CssClass="txtSearch form-control" Style="background-color: rgb(250, 255, 189);" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSearchFor" runat="server" Text="Search For" class="input-group-addon" />
                        <asp:DropDownList ID="ddlSearchFor" class="ddlSearchFor" runat="server" CssClass="ddlSearchFor form-control">
                            <asp:ListItem Text="Employee" Value="1" Selected="True" />
                            <asp:ListItem Text="SuperStockist" Value="4"></asp:ListItem>
                            <asp:ListItem Text="Distributor" Value="2"></asp:ListItem>
                            <asp:ListItem Text="Dealer" Value="3"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-info" OnClientClick="GetDetail(); return false;" />
                        &nbsp;
                        <asp:Button ID="btnSubmit" runat="server" Text="Submit" CssClass="btn btn-success" OnClientClick="return btnSubmit_Click()" />
                        &nbsp;
                        <asp:Button ID="btnClear" runat="server" Text="Clear" TabIndex="5" CssClass="btn btn-danger" OnClick="btnClear_Click" />
                        &nbsp;
                <asp:LinkButton ID="btnExport" TabIndex="10" runat="server" OnClick="btnExport_Click" Style="min-width: 40px;"><img src="../Images/exceldownload.gif" style="width: 40px;vertical-align: middle;"/></asp:LinkButton>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:FileUpload ID="flIMappingUpload" runat="server" CssClass="form-control" Style="width: 60%;" />&nbsp;
                        <asp:Button ID="btnMappingUpload" runat="server" Text="Upload Mapping" OnClick="btnMappingUpload_Click" CssClass="btn btn-primary" Style="display: inline; width: 35%;" />
                    </div>
                </div>
                <div class="col-lg-4" id="gridSearch">
                    <asp:Button ID="btnClearLatLong" runat="server" Style="float: right" Text="Clear Lat/Long" TabIndex="5" CssClass="btn btn-danger" OnClientClick="ClearLatLong(); return false;" />
                    <asp:TextBox runat="server" placeholder="Search here" CssClass="txtSearchData form-control" MaxLength="100" Style="width: 70%;" />
                </div>
            </div>
            <table id="tblLocationMapping" class="table table-bordered" tabindex="10" style="width: 100%; font-size: 10px">
                <thead>
                </thead>
                <tbody>
                </tbody>
            </table>
        </div>
    </div>
</asp:Content>

