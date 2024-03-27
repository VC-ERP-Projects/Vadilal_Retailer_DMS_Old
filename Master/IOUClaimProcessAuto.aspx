<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="IOUClaimProcessAuto.aspx.cs" Inherits="Master_IOUClaimProcessAuto" %>

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
        var availableParent = [];

        var Version = '<% = Version%>';
        //var LogoURL = '../Images/LOGO.png';
        var LogoURL = '../Images/CompanyLogo/<% = LogoURL%>';
        var IpAddress;

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

        var availableCustomer = [];

        $(document).ready(function () {

            ClearControls();
            $("#tblCustomer").tableHeadFixer('60vh');
            ToDataURL(LogoURL, function (dataUrl) {
                imagebase64 = dataUrl;
            })
            FillData();
            $(document).on('click', '.btnEdit', function () {
                var checkBoxes = $(this).closest('tr').find('.chkEdit');
                if (checkBoxes.prop("checked") == true) {
                    checkBoxes.prop("checked", false);
                    $(this).closest('tr').find('.search,.checkbox').prop('disabled', false);
                    $(this).val('Update');
                } else {
                    checkBoxes.prop("checked", true);
                    $(this).closest('tr').find('.search,.checkbox').prop('disabled', true);
                    $(this).val('Edit');
                }
            })
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

        function AddMoreRow() {

            $('table#tblCustomer tr#NoROW').remove();  // Remove NO ROW

            /// Add Dynamic Row to the existing Table
            var ind = $('#CountRowCustomer').val();
            ind = parseInt(ind) + 1;
            $('#CountRowCustomer').val(ind);

            var str = "";
            str = "<tr id='trItem" + ind + "'>"
                + "<td class='txtSrNo' id='txtSrNo" + ind + "'>" + ind + "</td>"
                + "<td><input type='checkbox' id='chkEdit" + ind + "' class='chkEdit' checked/>"
                 + "<input type='button' class='btnEdit btnEditDelete' id='btnEdit" + ind + "' name='btnEdit' value = 'Edit' /></td>"
                + "<td><input type='button' class='btnDelete btnEditDelete' id='btnDelete" + ind + "' name='btnDelete' value = 'Delete' onclick='RemoveClaimRow(" + ind + ");' /></td>"
                + "<td><input type='text' id='AutoDistRegion" + ind + "' name='AutoDistRegion' onchange='ChangeData(this);' class='form-control search' /></td>"
                + "<td><input type='text' id='AutoDistCode" + ind + "' name='AutoDistCode' onchange='ChangeData(this);' class='form-control search'/></td>"
                + "<td><input type='text' id='ClaimAmount" + ind + "'name='ClaimAmount' onchange='ChangeData(this);' class='ClaimAmount form-control allownumericwithdecimal search' onpaste='return false;'/></td>"
                + "<td><input type='text' id='PurchaseAmount" + ind + "'name='PurchaseAmount' onchange='ChangeData(this);' class='PurchaseAmount form-control allownumericwithdecimal search' onpaste='return false;'/></td>"
                + "<td><input type='checkbox' id='chkIsActive" + ind + "' name='chkIsActive' onchange='ChangeData(this);' class='form-control checkbox'/></td>"
                + "<td id='tdCreateDate" + ind + "' class='tdCreateDate'></td>"
                + "<td id='tdCreateBy" + ind + "' class='tdCreateBy'></td>"
                + "<td id='tdUpdateOn" + ind + "' class='tdUpdateOn'></td>"
                + "<td id='tdUpdateBy" + ind + "' class='tdUpdateBy'></td>"
                + "<input type='hidden' id='hdnLineNum" + ind + "' name='hdnLineNum' value='" + ind + "' />"
                + "<input type='hidden' id='IsChange" + ind + "' name='IsChange' value='0' /></td>"
                + "<input type='hidden' class='IsDeleted' id='IsDeleted" + ind + "' name='IsDeleted' value='0' /></td>"
                + "<input type='text' id='txtDeleteFlag" + ind + "' name='txtDeleteFlag' style='display:none' value='false' />"
                + "<input type='hidden' class='hdnRegionID' id='hdnRegionID" + ind + "' name='hdnRegionID' /></td>"
                + "<input type='hidden' class='hdnDistID' id='hdnDistID" + ind + "' name='hdnDistID' /></td>"
                + "<input type='hidden' class='hdnOIOUID' id='hdnOIOUID" + ind + "' name='hdnOIOUID' /></td></tr>"

            $('#tblCustomer > tbody').append(str);
            $('.chkEdit').hide();
            $('.chkEdit').prop("checked", true);
            $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);

            $('#AutoDistRegion' + ind).autocomplete({
                source: function (request, response) {
                    $.ajax({
                        url: "SchemeEligibility.aspx/GetDistRegionCurrHierarchy",
                        type: 'POST',
                        dataType: "json",
                        data: "{ 'prefixText': '" + request.term + "'}",
                        contentType: "application/json; charset=utf-8",
                        success: function (data) {
                            response($.map(data.d, function (item) {
                                return {
                                    label: item.Text,
                                    value: item.Text,
                                    id: item.Value
                                };
                            }))
                        },
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                        }
                    });
                },
                select: function (event, ui) {
                    $('#AutoDistRegion' + ind).val(ui.item.value);
                    $('#hdnRegionID' + ind).val(ui.item.value.split('-')[2].trim());
                    $('#AutoDistCode' + ind).val("");
                    $('#hdnDistID' + ind).val(0);
                },
                change: function (event, ui) {
                    if (!ui.item) {
                        $('#AutoDistRegion' + ind).val("");
                        $('#hdnRegionID').val(0);
                        $('#AutoDistCode' + ind).val("");
                        $('#hdnDistID' + ind).val(0);
                    }
                },
                minLength: 1
            });
            $('#AutoDistRegion' + ind).on('change keyup', function () {
                if ($('#AutoDistRegion' + ind).val() == "") {
                    ClearDistRegionRow(ind);
                }
            });
            $('#AutoDistRegion' + ind).on('blur', function (e, ui) {
                if ($('#AutoDistRegion' + ind).val().trim() != "") {
                    if ($('#AutoDistRegion' + ind).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Region", 3);
                        $('#AutoDistRegion' + ind).val("");
                        $('#hdnRegionID' + ind).val(0);
                        return;
                    }
                    var txt = $('#AutoDistRegion' + ind).val().trim();
                    if (txt == "undefined" || txt == "") {
                        return false;
                    }
                    CheckDuplicateRegion($('#AutoDistRegion' + ind).val().trim(), ind);
                }
            });

            $("#AutoDistCode" + ind).autocomplete({
                source: function (request, response) {
                    var stateID = $("#AutoDistRegion" + ind).val() != "" && $("#AutoDistRegion" + ind).val() != undefined ? $("#AutoDistRegion" + ind).val().split("-")[2].trim() : "0";
                    $.ajax({
                        type: "POST",
                        url: "SchemeEligibility.aspx/GetDistributorCurrHierarchy",
                        dataType: "json",
                        data: "{ 'prefixText': '" + request.term + "','StateID': '" + stateID + "'}",
                        contentType: "application/json; charset=utf-8",
                        success: function (data) {
                            response($.map(data.d, function (item) {
                                return {
                                    label: item.Text,
                                    value: item.Text,
                                    id: item.Value
                                };
                            }))
                        },
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                        }
                    });
                },
                select: function (event, ui) {
                    $("#AutoDistCode").val(ui.item.value);
                    $('#hdnDistID' + ind).val(ui.item.value.split('-')[2].trim());
                },
                change: function (event, ui) {
                    if (!ui.item) {
                        $('#AutoDistCode').val("");
                        $('#hdnDistID').val(0);
                    }
                },
                minLength: 1
            });

            $('#AutoDistCode' + ind).on('change keyup', function () {
                if ($('#AutoDistCode' + ind).val() == "") {
                    ClearDistRow(ind);
                }
            });
            $('#AutoDistCode' + ind).on('blur', function (e, ui) {
                if ($('#AutoDistCode' + ind).val().trim() != "") {
                    if ($('#AutoDistCode' + ind).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Distributor", 3);
                        $('#AutoDistCode' + ind).val("");
                        $('#hdnDistID' + ind).val(0);
                        return;
                    }
                    var txt = $('#AutoDistCode' + ind).val().trim();
                    if (txt == "undefined" || txt == "") {
                        return false;
                    }
                    CheckDuplicateDist($('#AutoDistCode' + ind).val().trim(), ind);
                }
            });

            $(".allownumericwithdecimal").on("input", function (evt) {
                var self = $(this);
                self.val(self.val().replace(/[^0-9\.]/g, ''));
                if ((evt.which != 46 || self.val().indexOf('.') != -1) && (evt.which < 48 || evt.which > 57)) {
                    evt.preventDefault();
                }
            });
        }

        function RemoveClaimRow(row) {
            $('table#tblCustomer tr#trItem' + row).remove();
            $('table#tblCustomer tr#trItem' + row).find(".IsDeleted").val("1");
            $('table#tblCustomer tr#trItem' + (row + 1)).focus();
            $('#hdnIsRowDeleted').val("1");
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
                url: 'IOUClaimProcessAuto.aspx/Load',
                type: 'POST',
                dataType: 'json',
                contentType: 'application/json; charset=utf-8',
                success: function (result) {
                    $.unblockUI();

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
                        var items = result.d[0];
                        if (items.length > 0) {
                            $('#tblCustomer  > tbody > tr').each(function (row1, tr) {
                                // post table's data to Submit form using Json Format
                                $(this).remove();
                            });
                            var row = 1;
                            $('#CountRowCustomer').val(0);

                            for (var i = 0; i < items.length; i++) {
                                AddMoreRow();

                                row = $('#CountRowCustomer').val();
                                $('#chkEdit' + row).click();
                                $('#chkEdit' + row).prop("checked", false);

                                $('#hdnOIOUID' + row).val(items[i].OIOUID);
                                $('#hdnRegionID' + row).val(items[i].StateID);
                                $('#hdnDistID' + row).val(items[i].DistID);
                                $('#AutoDistRegion' + row).val(items[i].StateDesc);
                                $('#AutoDistCode' + row).val(items[i].DistDesc);
                                $('#ClaimAmount' + row).val(items[i].PerClaimAmt);
                                $('#PurchaseAmount' + row).val(items[i].PerPurchaseAmt);
                                $('#IsDeleted' + row).val(items[i].IsDeleted);

                                if (items[i].Active == false) {
                                    $('#chkIsActive' + row).prop("checked", false);
                                }
                                else {
                                    $('#chkIsActive' + row).prop("checked", true);
                                }
                                $('#tdCreateBy' + row).text(items[i].CreatedBy);
                                $('#tdCreateDate' + row).text(items[i].CreatedDate);
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
            AddMoreRow();
        }

        function CheckDuplicateDist(CustCode, row) {
            var Item = CustCode.split("-")[0].trim() + " - " + CustCode.split("-")[1].trim();
            var rowCnt_Customer = 1;
            var cnt = 0;
            var errRow = 0;

            $('#tblCustomer  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format
                if ($("input[name='AutoDistCode']", this).val().split("-").length == 3) {
                    var CustCode = $("input[name='AutoDistCode']", this).val().split("-")[0].trim() + " - " + $("input[name='AutoDistCode']", this).val().split("-")[1].trim();
                    var LineNum = $("input[name='hdnLineNum']", this).val();
                    if (CustCode != "") {
                        if (parseInt(row) != parseInt(LineNum)) {
                            if (Item == CustCode) {
                                cnt = 1;
                                errRow = row;
                                $('#AutoDistCode' + row).val('');
                                $('#hdnDistID' + row).val(0);
                                $('#ClaimAmount' + row).text('');
                                $('#PurchaseAmount' + row).text('');
                                $('#chkIsActive' + row).prop('checked', false);
                                $('#chkIsActive' + row).attr("disabled", false);
                                errormsg = 'Distributor = ' + CustCode + ' is already seleted at row : ' + rowCnt_Customer;
                                return false;
                            }
                        }
                    }
                }
                rowCnt_Customer++;
            });

            if (cnt == 1) {
                $('#AutoDistCode' + row).val('');
                ClearDistRow(row);
                ModelMsg(errormsg, 3);
                return false;
            }

            var ind = $('#CountRowCustomer').val();
            if (ind == row) {
                AddMoreRow();
            }

        }

        function CheckDuplicateRegion(CustCode, row) {

            var Item = CustCode.split("-")[0].trim() + " - " + CustCode.split("-")[1].trim();
            var rowCnt_Customer = 1;
            var cnt = 0;
            var errRow = 0;

            $('#tblCustomer  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format
                if ($("input[name='AutoDistRegion']", this).val().split("-").length == 3) {
                    var CustCode = $("input[name='AutoDistRegion']", this).val().split("-")[0].trim() + " - " + $("input[name='AutoDistRegion']", this).val().split("-")[1].trim();
                    var LineNum = $("input[name='hdnLineNum']", this).val();

                    if (CustCode != "") {
                        if (parseInt(row) != parseInt(LineNum)) {
                            if (Item == CustCode) {
                                cnt = 1;
                                errRow = row;
                                $('#AutoDistRegion' + row).val('');
                                $('#hdnRegionID' + row).val(0);
                                $('#hdnOIOUID' + row).val(0);
                                $('#chkIsActive' + row).prop('checked', false);
                                $('#chkIsActive' + row).attr("disabled", false);
                                errormsg = 'Region = ' + CustCode + ' is already seleted at row : ' + rowCnt_Customer;
                                return false;
                            }
                        }
                    }
                }
                //}

                rowCnt_Customer++;
            });

            if (cnt == 1) {
                $('#AutoDistRegion' + row).val('');
                ClearDistRegionRow(row);
                ModelMsg(errormsg, 3);
                return false;
            }

            var ind = $('#CountRowCustomer').val();
            if (ind == row) {
                AddMoreRow();
            }

        }

        function ClearDistRegionRow(row) {

            var rowCnt_Customer = 1;
            var cnt = 0;

            $('#tblCustomer > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var CustCode = $("input[name='AutoDistRegion']", this).val();
                if (CustCode == "") {
                }
                cnt++;
                rowCnt_Customer++;
            });

            if (cnt > 1) {
                var rowCnt_Customer = 1;
                $('#tblCustomer > tbody > tr').each(function (row1, tr) {
                    // post table's data to Submit form using Json Format                    
                    if (cnt != rowCnt_Customer) {
                        var CustCode = $("input[name='AutoDistRegion']", this).val();
                        if (CustCode == "") {
                            //$(this).remove();
                        }
                    }
                    rowCnt_Customer++;
                });
            }

            var lineNum = 1;
            $('#tblCustomer > tbody > tr').each(function (row, tr) {
                $(".txtSrNo", this).text(lineNum);
                lineNum++;
            });
        }



        function ClearDistRow(row) {

            var rowCnt_Customer = 1;
            var cnt = 0;

            $('#tblCustomer > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var CustCode = $("input[name='AutoDistCode']", this).val();
                if (CustCode == "") {
                    //$(this).remove();
                }
                cnt++;

                rowCnt_Customer++;
            });

            if (cnt > 1) {
                var rowCnt_Customer = 1;
                $('#tblCustomer > tbody > tr').each(function (row1, tr) {
                    // post table's data to Submit form using Json Format                    
                    if (cnt != rowCnt_Customer) {
                        var CustCode = $("input[name='AutoDistCode']", this).val();
                        if (CustCode == "") {
                        }
                    }

                    rowCnt_Customer++;
                });
            }

            var lineNum = 1;
            $('#tblCustomer > tbody > tr').each(function (row, tr) {
                $(".txtSrNo", this).text(lineNum);
                lineNum++;
            });

        }

        function ClearControls() {
            $('.divCustEntry').attr('style', 'display:none;');
            $('.divClaimReport').attr('style', 'display:none;');
            $('.btnSubmit').attr('style', 'display:none;');
            $('.btnSearch').attr('style', 'display:none;');

            if ($.fn.DataTable.isDataTable('.gvClaimHistory')) {
                $('.gvClaimHistory').DataTable().destroy();
            }

            $('.gvClaimHistory tbody').empty();

            if ($('.chkIsReport').find('input').is(':checked')) {
                $('.divClaimReport').removeAttr('style');
                $('.btnSearch').removeAttr('style');
            }
            else {
                $('.divCustEntry').removeAttr('style');
                $('.btnSubmit').removeAttr('style');

                $('#CountRowCustomer').val(0);
                //AddMoreRow();
            }

        }


        function Cancel() {
            window.location = "../Master/IOUClaimProcessAuto.aspx";
        }
        function ChangeData(txt) {
            $(txt).parent().parent().find("input[name='IsChange']").val("1");
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

            var TableData_Customer = [];
            var cnt = 0;

            rowCnt_Customer = 0;
            $('#tblCustomer  > tbody > tr').each(function (row, tr) {

                var OIOUID = $("input[name='hdnOIOUID']", this).val();
                var Region = $("input[name='AutoDistRegion']", this).val();
                var DistCode = $("input[name='AutoDistCode']", this).val();
                var ClaimAmount = $("input[name='ClaimAmount']", this).val();
                var PurchaseAmount = $("input[name='PurchaseAmount']", this).val();
                var IsActive = $("input[name='chkIsActive']", this).is(':checked');
                var IsDeleted = $("input[name='IsDeleted']", this).is(':checked');
                var IsChange = $("input[name='IsChange']", this).val().trim();

                var obj = {
                    OIOUID: OIOUID,
                    Region: Region,
                    DistCode: DistCode,
                    ClaimAmount: ClaimAmount,
                    PurchaseAmount: PurchaseAmount,
                    IsActive: IsActive,
                    IsDeleted: IsDeleted,
                    IsChange: IsChange,
                };
                TableData_Customer.push(obj);

                rowCnt_Customer++;

                if (Region == "" && DistCode == "" && (ClaimAmount != 0 || ClaimAmount != "") && (PurchaseAmount != 0 || PurchaseAmount != "")) {
                    ModelMsg("Please select region or distributor at row : " + rowCnt_Customer, 3);
                    IsValid = false;
                }

                if (Region != "" || DistCode != "") {
                    if (ClaimAmount == 0 || ClaimAmount == "") {
                        ModelMsg("Please enter valid percentage in % Of Claim Amount at row : " + rowCnt_Customer, 3);
                        IsValid = false;
                    }

                    if (PurchaseAmount == 0 || PurchaseAmount == "") {
                        ModelMsg("Please enter valid percentage in % Of Purchase Amount at row : " + rowCnt_Customer, 3);
                        IsValid = false;
                    }
                }


                if ($("input[name='ClaimAmount']", this).val() != "" && ClaimAmount > 100) {
                    ModelMsg("% Of Claim Amount should not be greater than 100% at row : " + rowCnt_Customer, 3);
                    IsValid = false;
                }
                if ($("input[name='PurchaseAmount']", this).val() != "" && PurchaseAmount > 100) {
                    ModelMsg("% Of Purchase Amount should not be greater than 100% at row : " + rowCnt_Customer, 3);
                    IsValid = false;
                }

            });

            if (cnt == 1) {
                $.unblockUI();
                ModelMsg(errormsg, 3);
                event.preventDefault();
                return false;
            }

            var CustomerData = JSON.stringify(TableData_Customer);

            var successMSG = true;

            if (IsValid) {
                var sv = $.ajax({
                    url: 'IOUClaimProcessAuto.aspx/SaveData',
                    type: 'POST',
                    dataType: 'json',
                    data: JSON.stringify({ hidJsonInputCustomer: CustomerData, IsAnyRowDeleted: $('#hdnIsRowDeleted').val() }),
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

        function GetReport() {

            if ($('.chkIsReport').find('input').is(':checked')) {

                ClearControls();

                $.ajax({
                    url: 'IOUClaimProcessAuto.aspx/LoadReport',
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    contentType: 'application/json; charset=utf-8',

                    success: function (result) {
                        if (result.d[0] == "") {
                            return false;
                        }
                        else if (result.d[0].indexOf("ERROR=") >= 0) {
                            var ErrorMsg = result.d[0].split('=')[1].trim();
                            ModelMsg(ErrorMsg, 3);
                            $("input[name='AutoDistCode']", this).val() == "";
                            return false;
                        }
                        else {

                            var ReportData = JSON.parse(result.d[0]);
                            var str = "";

                            for (var i = 0; i < ReportData.length; i++) {

                                str = "<tr><td>" + ReportData[i].SRNo + "</td>"
                                        + "<td>" + ReportData[i].StateName + "</td>"
                                        + "<td>" + ReportData[i].DistributorCodeName + "</td>"
                                        + "<td>" + ReportData[i].PerClaimAmt + "</td>"
                                        + "<td>" + ReportData[i].PerPurchaseAmt + "</td>"
                                        + "<td>" + ReportData[i].Active + "</td>"
                                        + "<td>" + ReportData[i].CreatedDate + "</td>"
                                        + "<td>" + ReportData[i].CreatedBy + "</td>"
                                        + "<td>" + ReportData[i].UpdatedOn + "</td>"
                                        + "<td>" + ReportData[i].UpdatedBy + "</td>"



                                $('.gvClaimHistory > tbody').append(str);
                            }
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        alert('Something is wrong...' + XMLHttpRequest.responseText);
                        return false;
                    }
                });

                if ($('.gvClaimHistory tbody tr').length > 0) {

                    var now = new Date();
                    Date.prototype.today = function () {
                        return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                    }
                    var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });
                    var aryJSONColTable = [];

                    aryJSONColTable.push({ "width": "15px", "sClass": "dtbodyCenter", "aTargets": 0 });
                    aryJSONColTable.push({ "width": "70px", "aTargets": 1 });
                    aryJSONColTable.push({ "width": "15px", "aTargets": 2 });
                    aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyRight", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyRight", "aTargets": 4 });
                    aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyCenter", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "30px", "aTargets": 6 });
                    aryJSONColTable.push({ "width": "60px", "aTargets": 7 });
                    aryJSONColTable.push({ "width": "100px", "aTargets": 8 });
                    aryJSONColTable.push({ "width": "100px", "aTargets": 9 });

                    $('.gvClaimHistory').DataTable({
                        bFilter: true,
                        scrollCollapse: true,
                        "stripeClasses": ['odd-row', 'even-row'],
                        destroy: true,
                        scrollY: '62vh',
                        scrollX: true,
                        responsive: true,
                        "bSort": false,
                        dom: 'Bfrtip',
                        "bPaginate": false,
                        autowidth: false,
                        "aoColumnDefs": aryJSONColTable,
                        "order": [[0, "asc"]],
                        buttons: [{ extend: 'copy', footer: true },
                           {
                               extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                               customize: function (csv) {
                                   var data = $("#lnkTitle").text() + '\n';
                                   data += 'UserId,' + $('.hdnUserName').val() + '\n';
                                   data += 'Created on,' + jsDate.toString() + '\n';
                                   return data + csv;
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

                                   sheet = ExportXLS(xlsx, 3);

                                   var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                   var r1 = Addrow(2, [{ key: 'A', value: 'UserId' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                   var r2 = Addrow(3, [{ key: 'A', value: 'Created on' }, { key: 'B', value: jsDate.toString() }]);
                                   sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + sheet.childNodes[0].childNodes[1].innerHTML;
                               }
                           },
                           {
                               extend: 'pdfHtml5',
                               orientation: 'landscape', //portrait
                               pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                               title: $("#lnkTitle").text(),
                               footer: 'false',
                               exportOptions: {
                                   columns: ':visible',
                                   search: 'applied',
                                   order: 'applied'
                               },
                               customize: function (doc) {
                                   doc.content.splice(0, 1);
                                   var now = new Date();
                                   doc.pageMargins = [20, 65, 20, 30];
                                   doc.defaultStyle.fontSize = 7;
                                   doc.styles.tableHeader.fontSize = 7;
                                   doc.styles.tableFooter.fontSize = 7;
                                   doc['header'] = (function () {
                                       return {
                                           columns: [
                                               {
                                                   alignment: 'left',
                                                   italics: false,
                                                   text: [
                                                      { text: $("#lnkTitle").text() + '\n' },
                                                       { text: 'User Name : ' + $('.hdnUserName').val() + "\n" }],
                                                   fontSize: 10,
                                                   height: 350,
                                               },
                                               {
                                                   alignment: 'right',
                                                   width: 70,
                                                   height: 45,
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
                                       doc.content[0].table.body[i][1].alignment = 'left';
                                       doc.content[0].table.body[i][2].alignment = 'left';
                                       doc.content[0].table.body[i][3].alignment = 'right';
                                       doc.content[0].table.body[i][4].alignment = 'right';
                                       doc.content[0].table.body[i][6].alignment = 'center';
                                       doc.content[0].table.body[i][8].alignment = 'center';
                                   };
                                   doc.content[0].table.body[0][0].alignment = 'center';
                                   doc.content[0].table.body[0][1].alignment = 'left';
                                   doc.content[0].table.body[0][2].alignment = 'left';
                                   doc.content[0].table.body[0][3].alignment = 'right';
                                   doc.content[0].table.body[0][4].alignment = 'right';
                                   doc.content[0].table.body[0][5].alignment = 'left';
                                   doc.content[0].table.body[0][6].alignment = 'center';
                                   doc.content[0].table.body[0][7].alignment = 'left';
                                   doc.content[0].table.body[0][8].alignment = 'center';
                                   doc.content[0].table.body[0][9].alignment = 'left';
                               }
                           }]
                    });
                }
            }
        }

    </script>

    <style>
        .ui-widget {
            font-size: 12px;
        }

        .search {
            font-size: 10px !important;
            height: 25px;
        }

        td.txtSrNo {
            text-align: center;
        }

        table#gvClaimHistory.dataTable tbody th, table.dataTable tbody td {
            padding: 5px 10px;
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

        table.dataTable tbody tr.odd-row {
            background-color: #e3e7ff;
        }

        table.dataTable tbody tr.even-row {
            background-color: #fff;
        }

        .search {
            background-color: lightyellow;
        }

        th.table-header-gradient {
            z-index: 9;
        }

        #page-content-wrapper {
            overflow: hidden;
        }

        table.gvClaimHistory.table.table-bordered.nowrap.no-footer.dataTable {
            width: 100% !important;
            margin: 0;
            table-layout: auto;
        }

        .dataTables_scrollHeadInner {
            width: auto;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <asp:HiddenField runat="server" ID="hdnIsRowDeleted" ClientIDMode="Static" Value="0" />
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-2">
                    <div class="input-group form-group">
                        <label class="input-group-addon">View Report</label>
                        <asp:CheckBox runat="server" CssClass="chkIsReport form-control" onchange="ClearControls();" />
                    </div>
                </div>

                <div class="col-lg-2">
                    <div class="input-group form-group">
                        <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                        <input type="button" id="btnSubmit" name="btnSubmit" value="Submit" class="btnSubmit btn btn-default" onclick="btnSubmit_Click()" tabindex="2" />
                        <input type="button" id="btnSearch" name="btnSearch" value="Process" class="btnSearch btn btn-default" onclick="GetReport();" tabindex="3" />
                        &nbsp
                        <input type="button" id="btnCancel" name="btnCancel" value="Cancel" onclick="Cancel()" class="btn btn-default" tabindex="4" />
                    </div>
                </div>
            </div>

            <input type="hidden" id="CountRowCustomer" />
            <div id="divCustEntry" class="divCustEntry" runat="server" style="max-height: 80vh; overflow-y: auto;">
                <table id="tblCustomer" class="table table-bordered" tabindex="1" style="font-size: 11px">
                    <thead>
                        <tr class="table-header-gradient">
                            <th style="width: 1.5%; text-align: center;">Sr</th>
                            <th style="width: 3%">Edit</th>
                            <th style="width: 3%">Delete</th>
                            <th style="width: 6%">Region</th>
                            <th style="width: 10%">Distributor Code & Name</th>
                            <th style="width: 5%" class="Claim">% Of Claim Amt.</th>
                            <th style="width: 6%">% Of Purchase Amt.</th>
                            <th style="width: 3%;">Active</th>
                            <th style="width: 6%">Created Date/Time</th>
                            <th style="width: 8%">Created By</th>
                            <th style="width: 6%">Updated Date/Time</th>
                            <th style="width: 8%">Updated By</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
            <div id="divClaimReport" runat="server" class="divClaimReport">
                <table id="gvClaimHistory" class="gvClaimHistory table table-bordered nowrap" style="overflow: auto; font-size: 11px;">
                    <thead>
                        <tr class="table-header-gradient">
                            <th>Sr</th>
                            <th>Region Name</th>
                            <th>Distributor Code & Name</th>
                            <th>% Of Claim Amt.</th>
                            <th>% Of Purchase Amt.</th>
                            <th>Active</th>
                            <th>Created Date/Time</th>
                            <th>Created By</th>
                            <th>Update Date/Time</th>
                            <th>Update By</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</asp:Content>

