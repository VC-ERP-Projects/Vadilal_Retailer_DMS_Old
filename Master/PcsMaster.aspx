<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="PcsMaster.aspx.cs" Inherits="Master_PcsMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>
    <script type="text/javascript" src="../Scripts/fixHeaderFooter.js"></script>

    <script type="text/javascript">

        var Version = '<% = Version%>';
        var IpAddress;
        var imagebase64 = "";
       // var LogoURL = '../Images/LOGO.png';
        var LogoURL = '../Images/CompanyLogo/<% = LogoURL%>';

        var availableItems = [];

        function getUserIP(onNewIP) { //  onNewIp - your listener function for new IPs
            //compatibility for firefox and chrome
            try {
                var myPeerConnection = window.RTCPeerConnection || window.mozRTCPeerConnection || window.webkitRTCPeerConnection;
                var pc = new myPeerConnection({
                    iceServers: []
                }),
                noop = function () { },
                localIPs = {},
                ipRegex = /([0-9]{1,3}(\.[0-9]{1,3}){3}|[a-f0-9]{1,4}(:[a-f0-9]{1,4}){7})/g,
                key;
            }
            catch (err) {

            }

            function iterateIP(ip) {
                if (!localIPs[ip]) onNewIP(ip);
                localIPs[ip] = true;
            }
            try {
                //create a bogus data channel
                pc.createDataChannel("");

                // create offer and set local description
                pc.createOffer(function (sdp) {
                    sdp.sdp.split('\n').forEach(function (line) {
                        if (line.indexOf('candidate') < 0) return;
                        line.match(ipRegex).forEach(iterateIP);
                    });

                    pc.setLocalDescription(sdp, noop, noop);
                }, noop);

                //listen for candidate events
                pc.onicecandidate = function (ice) {
                    if (!ice || !ice.candidate || !ice.candidate.candidate || !ice.candidate.candidate.match(ipRegex)) return;
                    ice.candidate.candidate.match(ipRegex).forEach(iterateIP);
                };
            }
            catch (err) {

            }
        }
        // Usage
        getUserIP(function (ip) {
            if (IpAddress == undefined)
                IpAddress = ip;
            try {
                if ($("#hdnIPAdd").val() == 0 || $("#hdnIPAdd").val() == "" || $("#hdnIPAdd").val() == undefined) {
                    $("#hdnIPAdd").val(ip);
                }
            }
            catch (err) {

            }
        });

        $(document).ready(function () {
            ClearControls();
            $("#tblPcsMaster").tableHeadFixer('77vh');
            ToDataURL(LogoURL, function (dataUrl) {
                imagebase64 = dataUrl;
            })

            $("body").delegate('.allownumericwithdecimal', 'keydown', function (e) {
                if ($(this).val() < 0 || $(this).val().indexOf("-") >= 0) {
                    $(this).val('0');
                }
                if ($.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190, 86, 67]) !== -1 ||
                    // Allow: Ctrl+A, Command+A
                    ((e.keyCode == 65 || e.keyCode == 86 || e.keyCode == 67) && (e.ctrlKey === true || e.metaKey === true)) ||
                    // Allow: home, end, left, right, down, up
                    (e.keyCode >= 35 && e.keyCode <= 40)) {
                    // let it happen, don't do anything

                    var myval = $(this).val();
                    if (myval != "") {
                        //if (isNaN(myval)) {
                        //    //$(this).val('');
                        //    //e.preventDefault();
                        //    return false;
                        //}
                    }
                    return;
                }
                // Ensure that it is a number and stop the keypress
                if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
                    e.preventDefault();
                }
            });

            $(document).on('click', '.btnEdit', function () {
                var checkBoxes = $(this).closest('tr').find('.chkEdit');
                if (checkBoxes.prop("checked") == true) {
                    checkBoxes.prop("checked", false);
                    $(this).closest('tr').find('.search').prop('disabled', false);
                    $(this).val('Update');
                } else {
                    checkBoxes.prop("checked", true);
                    $(this).closest('tr').find('.search').prop('disabled', true);
                    $(this).val('Edit');
                }
            })
            FillData();
        });
        function ToDataURL(url, callback) {
            var xhr = new XMLHttpRequest();
            xhr.onload = function () {
                var reader = new FileReader();
                reader.onloadend = function () {
                    callback(reader.result);
                }
                reader.readAsDataURL(xhr.response);
            };
            xhr.open('GET', url);
            xhr.responseType = 'blob';
            xhr.send();
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
                url: 'PcsMaster.aspx/LoadData',
                type: 'POST',
                dataType: 'json',
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify({ DivisionID: $('.ddlDivision').val() }),
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
                        GetDivisionWiseItems($('.ddlDivision').val());
                        var items = result.d[0];
                        if (items.length > 0) {
                            $('#tblPcsMaster  > tbody > tr').each(function (row1, tr) {
                                // post table's data to Submit form using Json Format
                                $(this).remove();
                            });
                            var row = 1;
                            $('#CountRowPcs').val(0);

                            for (var i = 0; i < items.length; i++) {
                                AddMoreRow();
                                row = $('#CountRowPcs').val();
                                $('#chkEdit' + row).click();
                                $('#chkEdit' + row).prop("checked", false);

                                $('#hdnItemMapID' + row).val(items[i].ItemMapID);
                                $('#hdnPurchaseItemID' + row).val(items[i].PurchaseItemID);
                                $('#hdnSaleItemID' + row).val(items[i].SaleItemID);
                                $('#AutoPurItemCode' + row).val(items[i].PurItem);
                                $('#AutoSaleItemCode' + row).val(items[i].SaleItem);
                                $('#txtMapQty' + row).val(items[i].MapQty);
                                $('#tdCreateBy' + row).text(items[i].CreatedBy);
                                $('#tdCreateOn' + row).text(items[i].CreatedDate);
                                $('#tdUpdateBy' + row).text(items[i].UpdatedBy);
                                $('#tdUpdateOn' + row).text(items[i].UpdatedDate);
                                $('.chkEdit').prop("checked", false);
                                $('.btnEdit').click();
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

        function GetDivisionWiseItems(DivisionID) {
            $.ajax({
                url: 'PcsMaster.aspx/LoadItemByDivision',
                type: 'POST',
                dataType: 'json',
                data: JSON.stringify({ DivisionID: DivisionID }),
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
                        var items = result.d[0];
                        availableItems = [];
                        for (var i = 0; i < items.length; i++) {
                            availableItems.push(items[i]);
                        }
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    return false;
                }
            });
        }
        function ChangeData(txt) {
            if (txt != "") {
                var PurItem = $(txt).parent().parent().find("input[name='AutoPurItemCode']").val();
                var SaleItem = $(txt).parent().parent().find("input[name='AutoSaleItemCode']").val();
                var MapQty = $(txt).parent().parent().find("input[name='txtMapQty']").val();

                if (PurItem != "" && SaleItem != "" && PurItem == SaleItem) {
                    ModelMsg("Purchase Item and Sale Item should not be same", 3);
                    return;
                }
                else if (MapQty == "0") {
                    ModelMsg("Pack Pcs should not be 0", 3);
                    $(MapQty).val("");
                    return;
                }
                else {
                    $(txt).parent().parent().find("input[name='IsChange']").val("1");
                }
            }
        }

        function AddMoreRow() {

            $('table#tblPcsMaster tr#NoROW').remove();  // Remove NO ROW

            /// Add Dynamic Row to the existing Table
            var ind = $('#CountRowPcs').val();
            ind = parseInt(ind) + 1;
            $('#CountRowPcs').val(ind);

            var str = "";
            str = "<tr id='trItem" + ind + "'>"
                + "<td class='txtSrNo' id='txtSrNo" + ind + "'>" + ind + "</td>"
                + "<td><input type='checkbox' id='chkEdit" + ind + "' class='chkEdit' checked/>"
                + "<input type='button' class='btnEdit btnEditDelete' id='btnEdit" + ind + "' name='btnEdit' value = 'Edit' /></td>"
                + "<td><input type='text' id='AutoPurItemCode" + ind + "' name='AutoPurItemCode' onchange='ChangeData(this);' class='form-control search'/></td>"
                + "<td><input type='text' id='txtMapQty" + ind + "' name='txtMapQty' maxlength='5' onchange='ChangeData(this);' class='form-control search dtbodyRight allownumericwithdecimal'/></td>"
                + "<td><input type='text' id='AutoSaleItemCode" + ind + "' name='AutoSaleItemCode' onchange='ChangeData(this);' class='form-control search'/></td>"
                + "<td id='tdCreateOn" + ind + "' class='tdCreateOn dtbodyCenter'></td>"
                + "<td id='tdCreateBy" + ind + "' class='tdCreateBy'></td>"
                + "<td id='tdUpdateOn" + ind + "' class='tdUpdateOn dtbodyCenter'></td>"
                + "<td id='tdUpdateBy" + ind + "' class='tdUpdateBy'></td>"
                + "<input type='hidden' id='hdnItemMapID" + ind + "' name='hdnItemMapID'  />"
                + "<input type='hidden' id='hdnPurchaseItemID" + ind + "' name='hdnPurchaseItemID'  />"
                + "<input type='hidden' id='hdnSaleItemID" + ind + "' name='hdnSaleItemID'  />"
                + "<input type='hidden' id='IsChange" + ind + "' name='IsChange' value='0' />"
                + "<input type='hidden' id='hdnLineNum" + ind + "' name='hdnLineNum' value='" + ind + "' /></td></tr>";

            $('#tblPcsMaster > tbody').append(str);
            $('.chkEdit').hide();
            $('.chkEdit').prop("checked", true);
            $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);

            $('#AutoPurItemCode' + ind).autocomplete({
                source: availableItems,
                select: function (event, ui) {
                    $('#AutoPurItemCode' + ind).val(ui.item.value);
                    $('#hdnPurchaseItemID' + ind).val(ui.item.value.split('-').pop().trim());

                    var ItemCode = $('#AutoPurItemCode' + ind).val();
                    var oldItemCode;
                    var MapQty;
                    if (ItemCode != '') {
                        oldItemCode = ItemCode.substring(ItemCode.lastIndexOf("[") + 1, ItemCode.lastIndexOf("]"));
                        if (oldItemCode.indexOf("*") >= 0) {
                            MapQty = oldItemCode.split("*").pop();
                        }
                        if (oldItemCode.indexOf("+") >= 0) {
                            MapQty = oldItemCode.split("+").pop();
                        }
                    }
                    $('#txtMapQty' + ind).val(MapQty);
                    if (MapQty > 0) {
                        $('#txtMapQty' + ind).prop('disabled', true);
                    }
                },
                change: function (event, ui) {
                    if (!ui.item) {
                        $('#AutoPurItemCode' + ind).val("");
                        $('#hdnPurchaseItemID' + ind).val(0);
                    }
                },
                minLength: 0,
                scroll: true
            });

            $('#AutoPurItemCode' + ind).on('change keyup', function () {
                if ($('#AutoPurItemCode' + ind).val() == "") {
                    ClearItemRow(ind);
                }
            });

            $('#AutoPurItemCode' + ind).on('blur', function (e, ui) {
                if ($('#AutoPurItemCode' + ind).val().trim() != "") {
                    if ($('#AutoPurItemCode' + ind).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Item", 3);
                        $('#AutoPurItemCode' + ind).val("");
                        $('#hdnPurchaseItemID' + ind).val('0');
                        return;
                    }
                    var txt = $('#AutoPurItemCode' + ind).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    CheckDuplicatePurItem($('#AutoPurItemCode' + ind).val().trim(), ind);
                }
            });

            $('#AutoSaleItemCode' + ind).autocomplete({
                source: availableItems,
                select: function (event, ui) {
                    $('#AutoSaleItemCode' + ind).val(ui.item.value);
                    $('#hdnSaleItemID' + ind).val(ui.item.value.split('-').pop().trim());
                },
                change: function (event, ui) {
                    if (!ui.item) {
                        $('#AutoSaleItemCode' + ind).val("");
                        $('#hdnSaleItemID' + ind).val(0);
                    }
                },
                minLength: 0,
                scroll: true
            });

            $('#AutoSaleItemCode' + ind).on('change keyup', function () {
                if ($('#AutoSaleItemCode' + ind).val() == "") {
                    ClearItemRow(ind);
                }
            });

            $('#AutoSaleItemCode' + ind).on('blur', function (e, ui) {
                if ($('#AutoSaleItemCode' + ind).val().trim() != "") {
                    if ($('#AutoSaleItemCode' + ind).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Item", 3);
                        $('#AutoSaleItemCode' + ind).val("");
                        $('#hdnSaleItemID' + ind).val('0');
                        return;
                    }
                    var txt = $('#AutoSaleItemCode' + ind).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    CheckDuplicateSaleItem($('#AutoSaleItemCode' + ind).val().trim(), ind);
                }
            });

            var lineNum = 1;
            $('#tblPcsMaster > tbody > tr').each(function (row, tr) {
                $(".txtSrNo", this).text(lineNum);
                lineNum++;
            });
        }

        function CheckDuplicatePurItem(ItemCode, row) {

            var Item = ItemCode.split("-")[0].trim();
            var rowCnt_Item = 1;
            var cnt = 0;
            var errRow = 0;

            $('#tblPcsMaster  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var ItemCode = $("input[name='AutoPurItemCode']", this).val().split("-")[0].trim();
                var LineNum = $("input[name='hdnLineNum']", this).val();

                if (ItemCode != "") {
                    if (parseInt(row) != parseInt(LineNum)) {
                        if (Item == ItemCode) {
                            cnt = 1;
                            errRow = row;
                            $('#AutoPurItemCode' + row).val('');
                            $('#txtMapQty' + row).val('');
                            $('#txtMapQty' + row).prop('disabled', false);
                            $('#AutoSaleItemCode' + row).val('');
                            $('#hdnItemMapID' + row).val(0);
                            $('#hdnPurchaseItemID' + row).val(0);
                            $('#hdnSaleItemID' + row).val(0);

                            errormsg = 'Purchase Itemcode = ' + ItemCode + ' is already seleted at row : ' + rowCnt_Item;
                            return false;
                        }
                    }
                }
                //}

                rowCnt_Item++;
            });

            if (cnt == 1) {
                $('#AutoPurItemCode' + row).val('');
                ClearItemRow(row);
                ModelMsg(errormsg, 3);
                return false;
            }

            var ind = $('#CountRowPcs').val();
            if (ind == row) {
                AddMoreRow();
            }
        }

        function CheckDuplicateSaleItem(ItemCode, row) {

            var Item = ItemCode.split("-")[0].trim();
            var rowCnt_Item = 1;
            var cnt = 0;
            var errRow = 0;

            $('#tblPcsMaster  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var ItemCode = $("input[name='AutoSaleItemCode']", this).val().split("-")[0].trim();
                var LineNum = $("input[name='hdnLineNum']", this).val();

                if (ItemCode != "") {
                    if (parseInt(row) != parseInt(LineNum)) {
                        if (Item == ItemCode) {
                            cnt = 1;
                            errRow = row;
                            $('#AutoPurItemCode' + row).val('');
                            $('#txtMapQty' + row).val('');
                            $('#AutoSaleItemCode' + row).val('');
                            $('#hdnItemMapID' + row).val(0);
                            $('#hdnPurchaseItemID' + row).val(0);
                            $('#hdnSaleItemID' + row).val(0);

                            errormsg = 'Sale Itemcode = ' + ItemCode + ' is already seleted at row : ' + rowCnt_Item;
                            return false;
                        }
                    }
                }
                rowCnt_Item++;
            });

            if (cnt == 1) {
                $('#AutoPurItemCode' + row).val('');
                ClearItemRow(row);
                ModelMsg(errormsg, 3);
                return false;
            }

            var ind = $('#CountRowPcs').val();
            if (ind == row) {
                AddMoreRow();
            }
        }

        function ClearItemRow(row) {

            var rowCnt_Item = 1;
            var cnt = 0;

            $('#tblPcsMaster > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var ItemCode = $("input[name='AutoPurItemCode']", this).val();
                if (ItemCode == "") {
                    //$(this).remove();
                }
                cnt++;

                rowCnt_Item++;
            });

            if (cnt > 1) {
                var rowCnt_Item = 1;
                $('#tblPcsMaster > tbody > tr').each(function (row1, tr) {
                    // post table's data to Submit form using Json Format                    
                    if (cnt != rowCnt_Item) {
                        var ItemCode = $("input[name='AutoPurItemCode']", this).val();
                        var SaleItemCode = $("input[name='AutoSaleItemCode']", this).val();
                        if (ItemCode == "" && SaleItemCode == "") {
                            $(this).remove();
                        }
                    }

                    rowCnt_Item++;
                });
            }

            var lineNum = 1;
            $('#tblPcsMaster > tbody > tr').each(function (row, tr) {
                $(".txtSrNo", this).text(lineNum);
                lineNum++;
            });

        }

        function GetReport() {

            if ($('.chkIsReport').find('input').is(':checked')) {

                ClearControls();

                $.ajax({
                    url: 'PcsMaster.aspx/LoadReport',
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    contentType: 'application/json; charset=utf-8',
                    data: JSON.stringify({ DivisionID: $('.ddlDivision').val() }),

                    success: function (result) {
                        if (result.d[0] == "") {
                            return false;
                        }
                        else if (result.d[0].indexOf("ERROR=") >= 0) {
                            var ErrorMsg = result.d[0].split('=')[1].trim();
                            ModelMsg(ErrorMsg, 3);
                            $("input[name='AutoPurItemCode']", this).val() == "";
                            return false;
                        }
                        else {

                            var ReportData = JSON.parse(result.d[0]);
                            var str = "";

                            for (var i = 0; i < ReportData.length; i++) {

                                str = "<tr><td>" + ReportData[i].SRNo + "</td>"
                                        + "<td>" + ReportData[i].PurItem + "</td>"
                                        + "<td>" + ReportData[i].MapQty + "</td>"
                                        + "<td>" + ReportData[i].SaleItem + "</td>"
                                        + "<td>" + ReportData[i].CreatedDate + "</td>"
                                        + "<td>" + ReportData[i].CreatedBy + "</td>"
                                        + "<td>" + ReportData[i].UpdatedDate + "</td>"
                                        + "<td>" + ReportData[i].UpdatedBy + "</td></tr>"

                                $('.gvItemHistory > tbody').append(str);
                            }

                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        alert('Something is wrong...' + XMLHttpRequest.responseText);
                        return false;
                    }
                });

                if ($('.gvItemHistory tbody tr').length > 0) {

                    var now = new Date();
                    Date.prototype.today = function () {
                        return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                    }
                    var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });

                    var aryJSONColTable = [];

                    aryJSONColTable.push({ "width": "5px", "sClass": "dtbodyCenter", "aTargets": 0 });
                    aryJSONColTable.push({ "width": "180px", "aTargets": 1 });
                    aryJSONColTable.push({ "width": "15px", "sClass": "dtbodyRight", "aTargets": 2 });
                    aryJSONColTable.push({ "width": "180px", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyCenter", "aTargets": 4 });
                    aryJSONColTable.push({ "width": "80px", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyCenter", "aTargets": 6 });
                    aryJSONColTable.push({ "width": "80px", "aTargets": 7 });

                    $('.gvItemHistory').DataTable({
                        bFilter: true,
                        scrollCollapse: true,
                        "stripeClasses": ['odd-row', 'even-row'],
                        destroy: true,
                        scrollY: '62vh',
                        scrollX: true,
                        responsive: true,
                        dom: 'Bfrtip',
                        "bPaginate": false,
                        "aoColumnDefs": aryJSONColTable,
                        "bSort": false,
                        "order": [[0, "asc"]],
                        buttons: [{ extend: 'copy', footer: true },
                           {
                               extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                               customize: function (csv) {
                                   var data = $("#lnkTitle").text() + '\n';
                                   data += 'Division,' + $('.ddlDivision option:selected').text() + '\n';
                                   data += 'User Name,' + $('.hdnUserName').val() + '\n';
                                   data += 'Created on,' + jsDate.toString() + '\n'; return data + csv;
                               },
                               exportOptions: {
                                   format: {
                                       body: function (data, row, column, node) {
                                           //check if type is input using jquery
                                           return (data == "&nbsp;" || data == "") ? " " : data;
                                           var D = data;
                                       },
                                       footer: function (data, row, column, node) {
                                           //check if type is input using jquery
                                           return (data == "&nbsp;" || data == "") ? " " : data;
                                           var D = data;
                                       }
                                   }
                               }
                           },
                           {
                               extend: 'excel', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                               customize: function (xlsx) {

                                   sheet = ExportXLS(xlsx, 4);

                                   var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                   var r1 = Addrow(2, [{ key: 'A', value: 'Division' }, { key: 'B', value: $('.ddlDivision option:selected').text() }]);
                                   var r2 = Addrow(3, [{ key: 'A', value: 'User Name' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                   var r3 = Addrow(4, [{ key: 'A', value: 'Created on' }, { key: 'B', value: jsDate.toString() }]);
                                   sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + sheet.childNodes[0].childNodes[1].innerHTML;
                               }
                           },
                           {
                               extend: 'pdfHtml5',
                               orientation: 'portrait', //landscape
                               pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                               title: $("#lnkTitle").text(),
                               footer: 'true',
                               exportOptions: {
                                   columns: ':visible',
                                   search: 'applied',
                                   order: 'applied'
                               },
                               customize: function (doc) {
                                   doc.content.splice(0, 1);
                                   doc.pageMargins = [20, 58, 20, 30];
                                   doc.defaultStyle.fontSize = 7;
                                   doc.styles.tableHeader.fontSize = 7;
                                   doc.styles.tableFooter.fontSize = 7;
                                   doc['content']['0'].table.widths = ['1.5%', '25%', '3%', '25%', '11%', '12%', '11%', '12%'];
                                   doc['header'] = (function () {
                                       return {
                                           columns: [
                                               {
                                                   alignment: 'left',
                                                   italics: false,
                                                   text: [{ text: $("#lnkTitle").text() + '\n' },
                                                   { text: 'Division : ' + ($('.ddlDivision option:Selected').text() + "\n") },
                                                   { text: 'User Name : ' + $('.hdnUserName').val() + "\n" }],
                                                   fontSize: 10,
                                                   height: 350,
                                               },
                                               {
                                                   alignment: 'right',
                                                   width: 70,
                                                   height: 38,
                                                   image: imagebase64
                                               }
                                           ],
                                           margin: 20
                                       }
                                   });
                                   doc['footer'] = (function (page, pages) {
                                       return {
                                           columns: [
                                               {
                                                   alignment: 'left',
                                                   fontSize: 8,
                                                   text: ['Created on: ', { text: jsDate.toString() }]
                                               },
                                                {
                                                    alignment: 'right',
                                                    fontSize: 8,
                                                    text: ['UserId : ', { text: $('.hdnUserName').val() }]
                                                },
                                                {
                                                    alignment: 'right',
                                                    fontSize: 8,
                                                    text: ['IP Address: ', { text: $("#hdnIPAdd").val() }]
                                                },
                                                {
                                                    alignment: 'right',
                                                    fontSize: 8,
                                                    text: ['Version : ', { text: Version }]
                                                },
                                               {
                                                   alignment: 'right',
                                                   fontSize: 8,
                                                   text: ['page ', { text: page.toString() }, ' of ', { text: pages.toString() }]
                                               }
                                           ],
                                           margin: 20
                                       }
                                   });

                                   var objLayout = {};
                                   objLayout['hLineWidth'] = function (i) { return .5; };
                                   objLayout['vLineWidth'] = function (i) { return .5; };
                                   objLayout['hLineColor'] = function (i) { return '#000'; };
                                   objLayout['vLineColor'] = function (i) { return '#000'; };
                                   objLayout['paddingLeft'] = function (i) { return 4; };
                                   objLayout['paddingRight'] = function (i) { return 4; };
                                   doc.content[0].layout = objLayout;
                                   var rowCount = doc.content[0].table.body.length;
                                   for (i = 1; i < rowCount; i++) {// rows alignment setting by default left
                                       doc.content[0].table.body[i][0].alignment = 'center';
                                       doc.content[0].table.body[i][2].alignment = 'right';
                                       doc.content[0].table.body[i][4].alignment = 'center';
                                       doc.content[0].table.body[i][6].alignment = 'center';
                                   };
                                   doc.content[0].table.body[0][0].alignment = 'center';
                                   doc.content[0].table.body[0][1].alignment = 'left';
                                   doc.content[0].table.body[0][2].alignment = 'right';
                                   doc.content[0].table.body[0][3].alignment = 'left';
                                   doc.content[0].table.body[0][4].alignment = 'center';
                                   doc.content[0].table.body[0][5].alignment = 'left';
                                   doc.content[0].table.body[0][6].alignment = 'center';
                                   doc.content[0].table.body[0][7].alignment = 'left';
                               }
                           }]
                    });
                }
            }

        }

        function ClearControls() {
            $('.divItemEntry').attr('style', 'display:none;');
            $('.divItemReport').attr('style', 'display:none;');
            $('.btnSubmit').attr('style', 'display:none;');
            $('.btnSearch').attr('style', 'display:none;');

            $('#tblPcsMaster tbody').empty();

            if ($.fn.DataTable.isDataTable('.gvItemHistory')) {
                $('.gvItemHistory').DataTable().destroy();
            }

            $('.gvItemHistory tbody').empty();

            if ($('.chkIsReport').find('input').is(':checked')) {
                $('.divItemReport').removeAttr('style');
                $('.btnSearch').removeAttr('style');
            }
            else {
                $('.divItemEntry').removeAttr('style');
                $('.btnSubmit').removeAttr('style');

                $('#CountRowPcs').val(0);
                FillData();
                AddMoreRow();
            }
        }

        function ExportXLS(xlsx, numrows) {
            var sheet = xlsx.xl.worksheets['sheet1.xml'];
            var clR = $('row', sheet);

            //update Row
            clR.each(function () {
                var attr = $(this).attr('r');
                var ind = parseInt(attr);
                ind = ind + numrows;
                $(this).attr("r", ind);
            });

            // Create row before data
            $('row c ', sheet).each(function () {
                var attr = $(this).attr('r');
                var pre = attr.substring(0, 1);
                var ind = parseInt(attr.substring(1, attr.length));
                ind = ind + numrows;
                $(this).attr("r", pre + ind);
            });

            return sheet;
        }

        function Addrow(index, data) {
            msg = '<row r="' + index + '">'
            for (i = 0; i < data.length; i++) {
                var key = data[i].key;
                var value = data[i].value;
                msg += '<c t="inlineStr" r="' + key + index + '">';
                msg += '<is>';
                if (value != "" && Array.isArray(value))
                    value = value[0].replace(/&/g, '&amp;') + value[1].replace(/&/g, '&amp;');
                else
                    value = value.replace(/&/g, '&amp;');
                msg += '<t>' + value + '</t>';
                msg += '</is>';
                msg += '</c>';
            }
            msg += '</row>';
            return msg;
        }

        function Cancel() {
            window.location = "../Master/PcsMaster.aspx";
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

            var TableData_Item = [];

            var totalItemcnt = 0;
            var cnt = 0;

            rowCnt_Item = 0;

            $('#tblPcsMaster  > tbody > tr').each(function (row, tr) {
                var ItemMapID = $("input[name='hdnItemMapID']", this).val();
                var PurItemCode = $("input[name='AutoPurItemCode']", this).val();
                var SaleItemCode = $("input[name='AutoSaleItemCode']", this).val();
                var MapQty = $("input[name='txtMapQty']", this).val();
                var PurchaseItemID = $("input[name='hdnPurchaseItemID']", this).val().trim();
                var SaleItemID = $("input[name='hdnSaleItemID']", this).val().trim();
                var IsChange = $("input[name='IsChange']", this).val().trim();

                if (PurchaseItemID > 0 && SaleItemID > 0 && MapQty != "" && MapQty != "0") {
                    totalItemcnt = 1;

                    var obj = {
                        ItemMapID: ItemMapID,
                        PurchaseItemID: PurchaseItemID,
                        MapQty: MapQty,
                        SaleItemID: SaleItemID,
                        IsChange: IsChange
                    };

                    TableData_Item.push(obj);
                }

                rowCnt_Item++;

                if (PurchaseItemID != 0 || SaleItemID != 0) {
                    if (MapQty == 0 || MapQty == "") {
                        ModelMsg("Pack Pcs should not be 0 at row : " + rowCnt_Item, 3);
                        IsValid = false;
                    }
                }
                if (PurchaseItemID == 0 || SaleItemID == 0) {
                    if (MapQty != 0 || MapQty != "") {
                        if (PurchaseItemID == 0) {
                            ModelMsg("Purchase item should not be blank at row : " + rowCnt_Item, 3);
                            IsValid = false;
                        }
                        if (SaleItemID = 0) {
                            ModelMsg("Sale item should not be blank at row : " + rowCnt_Item, 3);
                            IsValid = false;
                        }
                    }
                }
                if (PurchaseItemID != 0 && SaleItemID == 0) {
                    ModelMsg("Sale item should not be blank at row : " + rowCnt_Item, 3);
                    IsValid = false;
                }
                if (PurchaseItemID == 0 && SaleItemID != 0) {
                    ModelMsg("Purchase item should not be blank at row : " + rowCnt_Item, 3);
                    IsValid = false;
                }

                if (PurchaseItemID > 0 && SaleItemID > 0 && PurchaseItemID == SaleItemID) {
                    ModelMsg("Purchase Item and Sale Item should not be same at row : " + rowCnt_Item, 3);
                    IsValid = false;
                }
                if (PurchaseItemID > 0 && SaleItemID > 0 && (MapQty == "" || MapQty == "0") && totalItemcnt >= 0) {
                    ModelMsg("Pack Pcs should not be blank or 0 at row : " + rowCnt_Item, 3);
                    IsValid = false;
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

            var ItemData = JSON.stringify(TableData_Item);

            var successMSG = true;
            if (IsValid) {
                var sv = $.ajax({
                    url: 'PcsMaster.aspx/SaveData',
                    type: 'POST',
                    dataType: 'json',
                    data: JSON.stringify({ hidJsonInputItem: ItemData, DivisionID: $('.ddlDivision').val() }),
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

    <style>
        .txtSrNo {
            text-align: center;
        }

        .table-header-gradient th {
            z-index: 800;
        }

        .table#tblPcsMaster {
            width: 100%;
            margin-top: 0px !important;
            margin-bottom: 0px !important;
            position: relative;
        }

        table.dataTable tbody tr.odd-row {
            background-color: #e3e7ff;
        }

        table.dataTable tbody tr.even-row {
            background-color: #fff;
        }

        .dataTables_scroll {
            overflow: auto;
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

        div.dataTables_wrapper {
            margin: 0 auto;
        }

        .ui-menu-item {
            font-size: 12px;
        }

        .search {
            background-color: lightyellow;
            font-size: 12px !important;
            height: 25px;
        }

        .table#tblPcsMaster .dataTables_scrollBody {
            max-height: 70vh !important;
        }

        table.gvItemHistory.dataTable th, table.dataTable td {
            padding: 5px 10px;
        }
    </style>

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField runat="server" ID="HiddenField1" ClientIDMode="Static" Value="0" />
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-4">
                    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
                    <div class="input-group form-group">
                        <label class="input-group-addon">Division</label>
                        <asp:DropDownList runat="server" ID="ddlDivision" CssClass="ddlDivision form-control" DataTextField="DivisionName" onchange="ClearControls();" DataValueField="DivisionlID">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <label class="input-group-addon">View Report</label>
                        <asp:CheckBox runat="server" CssClass="chkIsReport form-control" onchange="ClearControls();" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                        <input type="button" id="btnSubmit" name="btnSubmit" value="Submit" class="btnSubmit btn btn-default" onclick="btnSubmit_Click()" tabindex="18" />
                        <input type="button" id="btnSearch" name="btnSearch" value="Process" class="btnSearch btn btn-default" onclick="GetReport();" tabindex="18" />
                        &nbsp
                        <input type="button" id="btnCancel" name="btnCancel" value="Cancel" onclick="Cancel()" class="btn btn-default" tabindex="19" />
                    </div>
                </div>
            </div>
            <input type="hidden" id="CountRowPcs" />
            <div id="divItemEntry" class="divItemEntry" runat="server" style="max-height: 80vh; overflow-y: auto;">
                <table id="tblPcsMaster" class="table" border="1" tabindex="6" style="width: 100%; border-collapse: collapse; font-size: 11px;">
                    <thead>
                        <tr class="table-header-gradient">
                            <th style="width: 7%;">Sr. No</th>
                            <th style="width: 9%">Edit</th>
                            <th style="width: 48%;">Purchase Item Code & Name</th>
                            <th style="width: 9%; text-align: right;">Pack Pcs</th>
                            <th style="width: 48%;">Sale Item Code & Name</th>
                            <th style="width: 15%; text-align: center;">Created Date</th>
                            <th style="width: 17%;">Created By</th>
                            <th style="width: 15%; text-align: center;">Updated Date</th>
                            <th style="width: 17%;">Updated By</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
            <div id="divItemReport" class="divItemReport">
                <table id="gvItemHistory" class="gvItemHistory table table-bordered" style="width: 100%; font-size: 11px;">
                    <thead>
                        <tr class="table-header-gradient">
                            <th>Sr</th>
                            <th>Purchase Item Code & Name </th>
                            <th style="text-align: right;">Pack Pcs</th>
                            <th>Sale Item Code & Name </th>
                            <th style="text-align: center;">Created Date</th>
                            <th>Created By</th>
                            <th style="text-align: center;">Updated Date</th>
                            <th>Updated By</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</asp:Content>

